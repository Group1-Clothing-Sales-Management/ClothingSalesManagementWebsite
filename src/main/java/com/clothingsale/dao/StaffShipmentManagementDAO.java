package com.clothingsale.dao;

import com.clothingsale.model.DeliveryReturnInspectionItem;
import com.clothingsale.model.StaffShipment;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class StaffShipmentManagementDAO {

    public static final String INSPECTION_PENDING = "PENDING_INSPECTION";
    public static final String INSPECTION_COMPLETED = "COMPLETED";

    public List<StaffShipment> getAllShipments(String keyword, String statusFilter) {
        List<StaffShipment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT s.id AS shipment_id, o.id AS order_id, o.order_code, o.recipient_name, o.recipient_phone, "
                + "ISNULL(o.address_detail, '') + "
                + "ISNULL(', ' + o.ward_name, '') + "
                + "ISNULL(', ' + o.province_name, '') AS delivery_address, "
                + "s.carrier_name, UPPER(TRIM(s.shipping_status)) AS shipping_status, "
                + "s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note, "
                + "dri.status AS return_inspection_status "
                + "FROM Shipment s "
                + "JOIN [Order] o ON o.shipment_id = s.id "
                + "LEFT JOIN dbo.Delivery_Return_Inspection dri ON dri.shipment_id = s.id "
                + "WHERE UPPER(TRIM(o.order_status)) NOT IN ('PENDING', 'CANCELLED') ");

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (o.order_code LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?) ");
            String search = "%" + keyword.trim() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND UPPER(TRIM(s.shipping_status)) = ? ");
            String normalizedStatus = statusFilter.trim().toUpperCase();
            params.add("FAILURE".equals(normalizedStatus) ? "FAILED" : normalizedStatus);
        }

        sql.append("ORDER BY o.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapShipment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public StaffShipment getShipmentById(int shipmentId) {
        String sql = "SELECT s.id AS shipment_id, o.id AS order_id, o.order_code, o.recipient_name, o.recipient_phone, "
                + "ISNULL(o.address_detail, '') + "
                + "ISNULL(', ' + o.ward_name, '') + "
                + "ISNULL(', ' + o.province_name, '') AS delivery_address, "
                + "s.carrier_name, UPPER(TRIM(s.shipping_status)) AS shipping_status, "
                + "s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note, "
                + "dri.status AS return_inspection_status "
                + "FROM Shipment s "
                + "JOIN [Order] o ON o.shipment_id = s.id "
                + "LEFT JOIN dbo.Delivery_Return_Inspection dri ON dri.shipment_id = s.id "
                + "WHERE s.id = ? AND UPPER(TRIM(o.order_status)) NOT IN ('PENDING', 'CANCELLED')";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapShipment(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật kết quả giao hàng.
     * Khi FAILED, phương thức chỉ tạo phiếu chờ kiểm tra hàng hoàn về; tuyệt đối
     * không cộng tồn kho ở bước này.
     */
    public boolean updateDeliveryOutcome(int shipmentId, String requestedStatus,
            String remarks, int staffId) {
        String newShippingStatus = normalizeOutcome(requestedStatus);
        if (shipmentId <= 0 || staffId <= 0 || newShippingStatus == null) {
            return false;
        }

        String queryShipment = "SELECT o.id AS order_id, o.order_status, "
                + "s.shipping_status, p.payment_method, p.payment_status "
                + "FROM Shipment s "
                + "JOIN [Order] o ON o.shipment_id = s.id "
                + "LEFT JOIN Payment p ON p.order_id = o.id "
                + "WHERE s.id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                String currentOrderStatus;
                String currentShippingStatus;
                String paymentMethod;
                String paymentStatus;

                try (PreparedStatement psCheck = conn.prepareStatement(queryShipment)) {
                    psCheck.setInt(1, shipmentId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        orderId = rs.getInt("order_id");
                        currentOrderStatus = normalize(rs.getString("order_status"));
                        currentShippingStatus = normalize(rs.getString("shipping_status"));
                        paymentMethod = normalize(rs.getString("payment_method"));
                        paymentStatus = normalize(rs.getString("payment_status"));
                    }
                }

                String expectedShippingStatus;
                String mappedOrderStatus;
                if ("SHIPPING".equals(newShippingStatus)) {
                    expectedShippingStatus = "PENDING_PICKUP";
                    mappedOrderStatus = "SHIPPING";
                    if (!"CONFIRMED".equals(currentOrderStatus)) {
                        conn.rollback();
                        return false;
                    }
                } else if ("SUCCESS".equals(newShippingStatus)) {
                    expectedShippingStatus = currentShippingStatus;
                    mappedOrderStatus = "SUCCESS";
                    if (!isValidFinalTransition(currentShippingStatus, currentOrderStatus)) {
                        conn.rollback();
                        return false;
                    }
                } else {
                    expectedShippingStatus = currentShippingStatus;
                    mappedOrderStatus = "RETURNED";
                    if (!isValidFinalTransition(currentShippingStatus, currentOrderStatus)) {
                        conn.rollback();
                        return false;
                    }
                }

                String updateShipment = "UPDATE Shipment SET shipping_status = ? "
                        + "WHERE id = ? AND UPPER(TRIM(shipping_status)) = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateShipment)) {
                    ps.setString(1, newShippingStatus);
                    ps.setInt(2, shipmentId);
                    ps.setString(3, expectedShippingStatus);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                String cleanRemarks = remarks == null ? null : remarks.trim();
                String orderNote = cleanRemarks == null || cleanRemarks.isEmpty()
                        ? null
                        : "[Delivery failure: " + cleanRemarks + "]";
                String updateOrder;
                if (orderNote == null) {
                    updateOrder = "UPDATE [Order] SET order_status = ?, updated_at = GETDATE() "
                            + "WHERE id = ? AND UPPER(TRIM(order_status)) = ?";
                } else {
                    updateOrder = "UPDATE [Order] SET order_status = ?, note = ?, updated_at = GETDATE() "
                            + "WHERE id = ? AND UPPER(TRIM(order_status)) = ?";
                }
                try (PreparedStatement ps = conn.prepareStatement(updateOrder)) {
                    ps.setString(1, mappedOrderStatus);
                    if (orderNote == null) {
                        ps.setInt(2, orderId);
                        ps.setString(3, currentOrderStatus);
                    } else {
                        ps.setString(2, orderNote);
                        ps.setInt(3, orderId);
                        ps.setString(4, currentOrderStatus);
                    }
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                if ("FAILED".equals(newShippingStatus)) {
                    createPendingReturnInspection(conn, shipmentId, orderId,
                            cleanRemarks, staffId);
                    updatePaymentAfterFailure(conn, orderId, paymentMethod, paymentStatus);
                } else if ("SUCCESS".equals(newShippingStatus)
                        && "COD".equals(paymentMethod)
                        && "UNPAID".equals(paymentStatus)) {
                    String updatePayment = "UPDATE Payment SET payment_status = 'PAID', payment_date = GETDATE() "
                            + "WHERE order_id = ? AND payment_status = 'UNPAID'";
                    try (PreparedStatement ps = conn.prepareStatement(updatePayment)) {
                        ps.setInt(1, orderId);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<DeliveryReturnInspectionItem> getReturnInspectionItems(int shipmentId) {
        List<DeliveryReturnInspectionItem> list = new ArrayList<>();
        String sql = "SELECT dri_item.*, ISNULL(pv.stock_quantity, 0) AS current_stock "
                + "FROM dbo.Delivery_Return_Inspection dri "
                + "JOIN dbo.Delivery_Return_Inspection_Item dri_item ON dri_item.inspection_id = dri.id "
                + "LEFT JOIN Product_Variant pv ON pv.id = dri_item.variant_id "
                + "WHERE dri.shipment_id = ? ORDER BY dri_item.id";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInspectionItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Hoàn tất kiểm tra hàng hoàn về và chỉ cộng số lượng đạt yêu cầu vào kho.
     */
    public boolean completeReturnInspection(int shipmentId, int staffId,
            Map<Integer, Integer> restockQuantities,
            Map<Integer, Integer> damagedQuantities,
            Map<Integer, String> itemNotes,
            String inspectionNote) throws SQLException {

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int inspectionId;
                int orderId;
                String status;
                String lockHeader = "SELECT id, order_id, status "
                        + "FROM dbo.Delivery_Return_Inspection WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE shipment_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(lockHeader)) {
                    ps.setInt(1, shipmentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        inspectionId = rs.getInt("id");
                        orderId = rs.getInt("order_id");
                        status = normalize(rs.getString("status"));
                    }
                }

                if (!INSPECTION_PENDING.equals(status)) {
                    conn.rollback();
                    return false;
                }

                List<DeliveryReturnInspectionItem> items = getReturnInspectionItems(conn, inspectionId);
                if (items.isEmpty()) {
                    throw new SQLException("No returned products were found for inspection.");
                }

                for (DeliveryReturnInspectionItem item : items) {
                    Integer restockValue = restockQuantities.get(item.getId());
                    Integer damagedValue = damagedQuantities.get(item.getId());
                    if (restockValue == null || damagedValue == null) {
                        throw new SQLException("Please inspect every returned product.");
                    }

                    int restock = restockValue;
                    int damaged = damagedValue;
                    if (restock < 0 || damaged < 0
                            || restock + damaged != item.getReturnQuantity()) {
                        throw new SQLException(
                                "For each product, restock quantity plus damaged quantity must equal the returned quantity.");
                    }
                    String itemNote = cleanText(itemNotes.get(item.getId()));
                    if (damaged > 0 && itemNote == null) {
                        throw new SQLException(
                                "A condition note is required for damaged or missing returned products.");
                    }
                    if (restock > 0 && (item.getVariantId() == null || item.getVariantId() <= 0)) {
                        throw new SQLException(
                                "A returned product no longer has a valid variant and cannot be added to inventory.");
                    }

                    if (restock > 0) {
                        addRestockToInventory(conn, item, restock, staffId,
                                inspectionId, inspectionNote);
                    }

                    String updateItem = "UPDATE dbo.Delivery_Return_Inspection_Item SET "
                            + "restock_quantity = ?, damaged_quantity = ?, item_note = ?, "
                            + "inspected = 1, inspected_by = ?, inspected_at = GETDATE() "
                            + "WHERE id = ? AND inspection_id = ? AND inspected = 0";
                    try (PreparedStatement ps = conn.prepareStatement(updateItem)) {
                        ps.setInt(1, restock);
                        ps.setInt(2, damaged);
                        ps.setString(3, itemNote);
                        ps.setInt(4, staffId);
                        ps.setInt(5, item.getId());
                        ps.setInt(6, inspectionId);
                        if (ps.executeUpdate() != 1) {
                            throw new SQLException("This returned product has already been processed.");
                        }
                    }
                }

                String finishHeader = "UPDATE dbo.Delivery_Return_Inspection SET status = 'COMPLETED', "
                        + "inspection_note = ?, inspected_by = ?, inspected_at = GETDATE() "
                        + "WHERE id = ? AND status = 'PENDING_INSPECTION'";
                try (PreparedStatement ps = conn.prepareStatement(finishHeader)) {
                    ps.setString(1, cleanText(inspectionNote));
                    ps.setInt(2, staffId);
                    ps.setInt(3, inspectionId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                // Order remains RETURNED. inventory_status remains DEDUCTED because the
                // original sale deduction already happened; this return is a separate
                // inventory movement recorded in Inventory_Log.
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE [Order] SET order_status = 'RETURNED', updated_at = GETDATE() WHERE id = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private StaffShipment mapShipment(ResultSet rs) throws SQLException {
        StaffShipment model = new StaffShipment();
        model.setShipmentId(rs.getInt("shipment_id"));
        model.setOrderId(rs.getInt("order_id"));
        model.setOrderCode(rs.getString("order_code"));
        model.setCustomerName(rs.getString("recipient_name"));
        model.setCustomerPhone(rs.getString("recipient_phone"));
        model.setDeliveryAddress(rs.getString("delivery_address"));
        model.setCarrierName(rs.getString("carrier_name"));
        model.setShippingStatus(rs.getString("shipping_status"));
        model.setTrackingCode(rs.getString("tracking_code"));
        model.setShippingCost(rs.getBigDecimal("shipping_cost"));
        model.setEstimatedDeliveryTime(rs.getTimestamp("estimated_delivery_time"));
        model.setNote(rs.getString("note"));
        model.setReturnInspectionStatus(rs.getString("return_inspection_status"));
        return model;
    }

    private DeliveryReturnInspectionItem mapInspectionItem(ResultSet rs) throws SQLException {
        DeliveryReturnInspectionItem item = new DeliveryReturnInspectionItem();
        item.setId(rs.getInt("id"));
        item.setInspectionId(rs.getInt("inspection_id"));
        item.setOrderDetailId(rs.getInt("order_detail_id"));
        int variantId = rs.getInt("variant_id");
        if (!rs.wasNull()) {
            item.setVariantId(variantId);
        }
        item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
        item.setVariantAttributesSnapshot(rs.getString("variant_attributes_snapshot"));
        item.setReturnQuantity(rs.getInt("return_quantity"));
        item.setRestockQuantity(rs.getInt("restock_quantity"));
        item.setDamagedQuantity(rs.getInt("damaged_quantity"));
        item.setCurrentStock(rs.getInt("current_stock"));
        item.setItemNote(rs.getString("item_note"));
        item.setInspected(rs.getBoolean("inspected"));
        int inspectedBy = rs.getInt("inspected_by");
        if (!rs.wasNull()) {
            item.setInspectedBy(inspectedBy);
        }
        item.setInspectedAt(rs.getTimestamp("inspected_at"));
        return item;
    }

    private List<DeliveryReturnInspectionItem> getReturnInspectionItems(
            Connection conn, int inspectionId) throws SQLException {
        List<DeliveryReturnInspectionItem> list = new ArrayList<>();
        String sql = "SELECT dri_item.*, ISNULL(pv.stock_quantity, 0) AS current_stock "
                + "FROM dbo.Delivery_Return_Inspection_Item dri_item WITH (UPDLOCK, HOLDLOCK) "
                + "LEFT JOIN Product_Variant pv ON pv.id = dri_item.variant_id "
                + "WHERE dri_item.inspection_id = ? ORDER BY dri_item.id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inspectionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInspectionItem(rs));
                }
            }
        }
        return list;
    }

    private void createPendingReturnInspection(Connection conn, int shipmentId,
            int orderId, String failureReason, int staffId) throws SQLException {
        String insertHeader = "INSERT INTO dbo.Delivery_Return_Inspection "
                + "(shipment_id, order_id, failure_reason, status, created_by) "
                + "VALUES (?, ?, ?, 'PENDING_INSPECTION', ?)";
        int inspectionId;
        try (PreparedStatement ps = conn.prepareStatement(
                insertHeader, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, shipmentId);
            ps.setInt(2, orderId);
            ps.setString(3, failureReason);
            ps.setInt(4, staffId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Could not create the returned-goods inspection record.");
                }
                inspectionId = keys.getInt(1);
            }
        }

        String insertItems = "INSERT INTO dbo.Delivery_Return_Inspection_Item "
                + "(inspection_id, order_detail_id, variant_id, product_name_snapshot, "
                + "variant_attributes_snapshot, return_quantity) "
                + "SELECT ?, od.id, od.variant_id, od.product_name_snapshot, "
                + "od.variant_attributes_snapshot, od.quantity "
                + "FROM Order_Detail od WHERE od.order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(insertItems)) {
            ps.setInt(1, inspectionId);
            ps.setInt(2, orderId);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("No order items were found for returned-goods inspection.");
            }
        }
    }

    private void addRestockToInventory(Connection conn,
            DeliveryReturnInspectionItem item, int restockQuantity, int staffId,
            int inspectionId, String inspectionNote) throws SQLException {
        int variantId = item.getVariantId();
        int quantityBefore;
        String productName;
        String sku;

        String lockVariant = "SELECT pv.stock_quantity, pv.sku, p.product_name "
                + "FROM Product_Variant pv WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN Product p ON p.id = pv.product_id WHERE pv.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(lockVariant)) {
            ps.setInt(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("The product variant no longer exists.");
                }
                quantityBefore = rs.getInt("stock_quantity");
                sku = rs.getString("sku");
                productName = rs.getString("product_name");
            }
        }

        String updateStock = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateStock)) {
            ps.setInt(1, restockQuantity);
            ps.setInt(2, variantId);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Could not add the inspected product back to inventory.");
            }
        }

        String log = "INSERT INTO Inventory_Log "
                + "(variant_id, user_id, product_name_snapshot, sku_snapshot, "
                + "quantity_before, change_quantity, quantity_after, transaction_type, "
                + "reference_type, reference_id, note) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 'DELIVERY_RETURN_IN', "
                + "'DELIVERY_RETURN_INSPECTION', ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(log)) {
            ps.setInt(1, variantId);
            ps.setInt(2, staffId);
            ps.setString(3, productName);
            ps.setString(4, sku);
            ps.setInt(5, quantityBefore);
            ps.setInt(6, restockQuantity);
            ps.setInt(7, quantityBefore + restockQuantity);
            ps.setInt(8, inspectionId);
            ps.setString(9, cleanText(inspectionNote));
            ps.executeUpdate();
        }
    }

    private String normalizeOutcome(String requestedStatus) {
        String status = normalize(requestedStatus);
        if ("FAILURE".equals(status)) {
            return "FAILED";
        }
        if ("SHIPPING".equals(status)
                || "SUCCESS".equals(status)
                || "FAILED".equals(status)) {
            return status;
        }
        return null;
    }

    private boolean isValidFinalTransition(String shippingStatus, String orderStatus) {
        return ("PENDING_PICKUP".equals(shippingStatus) && "CONFIRMED".equals(orderStatus))
                || ("SHIPPING".equals(shippingStatus) && "SHIPPING".equals(orderStatus));
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private String cleanText(String value) {
        if (value == null) {
            return null;
        }
        String cleaned = value.trim();
        return cleaned.isEmpty() ? null : cleaned;
    }

    private void updatePaymentAfterFailure(Connection conn, int orderId,
            String paymentMethod, String paymentStatus) throws SQLException {
        if ("PAID".equals(paymentStatus)) {
            String sql = "UPDATE Payment SET payment_status = 'REFUNDED', payment_date = GETDATE() "
                    + "WHERE order_id = ? AND payment_status = 'PAID'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
        } else if (!"COD".equals(paymentMethod) && "UNPAID".equals(paymentStatus)) {
            String sql = "UPDATE Payment SET payment_status = 'FAILED', payment_date = GETDATE() "
                    + "WHERE order_id = ? AND payment_status = 'UNPAID'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
        }
    }
}
