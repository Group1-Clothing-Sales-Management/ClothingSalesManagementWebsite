package com.clothingsale.dao;

import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.util.DBConnection;
import com.clothingsale.service.OrderStatusHelper;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chịu trách nhiệm đọc và cập nhật dữ liệu quản lý đơn hàng.
 * Tất cả truy vấn ở đây đều bám theo schema hiện có để tránh phá vỡ dữ liệu sẵn
 * có.
 */
public class OrderManagementDAO {

    /**
     * Lấy danh sách đơn hàng để hiển thị trên màn hình quản trị.
     * Có hỗ trợ lọc theo từ khóa và trạng thái.
     */
    public List<Order> getOrders(String keyword, String statusFilter) {
        List<Order> orders = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.id, o.order_code, o.user_id, o.voucher_id, o.shipment_id, ");
        sql.append("       o.recipient_name, o.recipient_phone, o.ward_id, o.address_detail, ");
        sql.append("       o.total_items_price, o.discount_amount, o.shipping_fee, o.total_payment, ");
        sql.append("       o.order_status, o.note, o.created_at, o.updated_at, ");
        sql.append(
                "       u.username AS customer_username, u.full_name AS customer_full_name, u.email AS customer_email, ");
        sql.append(
                "       s.carrier_name AS shipment_carrier_name, s.tracking_code AS shipment_tracking_code, s.shipping_status, ");
        sql.append("       p.payment_method, p.payment_status, ");
        sql.append(
                "       ISNULL((SELECT COUNT(*) FROM Order_Detail od WHERE od.order_id = o.id), 0) AS detail_count, ");
        sql.append("       pr.province_name, d.district_name, w.ward_name ");
        sql.append("FROM [Order] o ");
        sql.append("LEFT JOIN [User] u ON o.user_id = u.id ");
        sql.append("LEFT JOIN Shipment s ON o.shipment_id = s.id ");
        sql.append("LEFT JOIN Payment p ON o.id = p.order_id ");
        sql.append("LEFT JOIN Ward w ON o.ward_id = w.id ");
        sql.append("LEFT JOIN District d ON w.district_id = d.id ");
        sql.append("LEFT JOIN Province pr ON d.province_id = pr.id ");
        sql.append("WHERE 1 = 1 ");

        List<Object> parameters = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (o.order_code LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ? ");
            sql.append("OR u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?) ");
            String likeValue = "%" + keyword.trim() + "%";
            for (int i = 0; i < 6; i++) {
                parameters.add(likeValue);
            }
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND o.order_status = ? ");
            parameters.add(statusFilter.trim().toUpperCase());
        }

        sql.append("ORDER BY o.created_at DESC, o.id DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParameters(ps, parameters);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    /**
     * Lấy chi tiết một đơn hàng để hiển thị ở màn hình detail.
     */
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.id, o.order_code, o.user_id, o.voucher_id, o.shipment_id, "
                + "       o.recipient_name, o.recipient_phone, o.ward_id, o.address_detail, "
                + "       o.total_items_price, o.discount_amount, o.shipping_fee, o.total_payment, "
                + "       o.order_status, o.note, o.created_at, o.updated_at, "
                + "       u.username AS customer_username, u.full_name AS customer_full_name, u.email AS customer_email, "
                + "       s.carrier_name AS shipment_carrier_name, s.tracking_code AS shipment_tracking_code, s.shipping_status, "
                + "       p.payment_method, p.payment_status, "
                + "       ISNULL((SELECT COUNT(*) FROM Order_Detail od WHERE od.order_id = o.id), 0) AS detail_count, "
                + "       pr.province_name, d.district_name, w.ward_name "
                + "FROM [Order] o "
                + "LEFT JOIN [User] u ON o.user_id = u.id "
                + "LEFT JOIN Shipment s ON o.shipment_id = s.id "
                + "LEFT JOIN Payment p ON o.id = p.order_id "
                + "LEFT JOIN Ward w ON o.ward_id = w.id "
                + "LEFT JOIN District d ON w.district_id = d.id "
                + "LEFT JOIN Province pr ON d.province_id = pr.id "
                + "WHERE o.id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrderRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy danh sách line-items của một đơn hàng.
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> details = new ArrayList<>();
        String sql = "SELECT id, order_id, variant_id, product_name_snapshot, "
                + "       variant_attributes_snapshot, quantity, price "
                + "FROM Order_Detail WHERE order_id = ? ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setId(rs.getInt("id"));
                    detail.setOrderId(rs.getInt("order_id"));
                    detail.setVariantId(rs.getInt("variant_id"));
                    detail.setProductNameSnapshot(rs.getString("product_name_snapshot"));
                    detail.setVariantAttributesSnapshot(rs.getString("variant_attributes_snapshot"));
                    detail.setQuantity(rs.getInt("quantity"));
                    detail.setPrice(rs.getBigDecimal("price"));

                    BigDecimal price = detail.getPrice() != null ? detail.getPrice() : BigDecimal.ZERO;
                    detail.setLineTotal(price.multiply(BigDecimal.valueOf(detail.getQuantity())));

                    details.add(detail);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return details;
    }

    /**
     * Lấy trạng thái hiện tại của đơn hàng trước khi cập nhật.
     */
    public String getCurrentOrderStatus(int orderId) {
        String sql = "SELECT order_status FROM [Order] WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("order_status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean approveOrder(int orderId) {
        String loadSql
                = "SELECT o.order_status, o.inventory_status, "
                + "       o.shipment_id, o.shipping_fee "
                + "FROM [Order] o WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE o.id = ?";

        String updateOrderSql
                = "UPDATE [Order] "
                + "SET order_status = ?, "
                + "    inventory_status = 'DEDUCTED', "
                + "    updated_at = GETDATE() "
                + "WHERE id = ? "
                + "AND order_status = ? "
                + "AND inventory_status = ?";

        String updateShipmentLinkSql
                = "UPDATE [Order] "
                + "SET shipment_id = ?, updated_at = GETDATE() "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                String currentStatus;
                String inventoryStatus;
                int shipmentId;
                BigDecimal shippingFee;

                try (PreparedStatement psLoad
                        = conn.prepareStatement(loadSql)) {

                    psLoad.setInt(1, orderId);

                    try (ResultSet rs = psLoad.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }

                        currentStatus = rs.getString("order_status");
                        inventoryStatus = rs.getString("inventory_status");
                        shipmentId = rs.getInt("shipment_id");
                        shippingFee = rs.getBigDecimal("shipping_fee");
                    }
                }

                if (currentStatus == null
                        || !OrderStatusHelper.RAW_PENDING.equalsIgnoreCase(
                                currentStatus.trim())) {

                    conn.rollback();
                    return false;
                }

                inventoryStatus = inventoryStatus == null
                        ? "NONE"
                        : inventoryStatus.trim().toUpperCase();

                if ("RESERVED".equals(inventoryStatus)) {
                    commitReservedInventory(
                            conn,
                            orderId
                    );

                } else if ("LEGACY_DEDUCTED".equals(inventoryStatus)) {
                    synchronizeLegacyFifoBatches(
                            conn,
                            orderId
                    );

                } else {
                    conn.rollback();
                    return false;
                }

                int linkedShipmentId = shipmentId;

                if (linkedShipmentId <= 0
                        && shippingFee != null
                        && shippingFee.compareTo(BigDecimal.ZERO) > 0) {

                    linkedShipmentId = insertShipment(
                            conn,
                            "Internal Delivery",
                            "PENDING_PICKUP",
                            shippingFee
                    );
                }

                try (PreparedStatement psOrder
                        = conn.prepareStatement(updateOrderSql)) {

                    psOrder.setString(
                            1,
                            OrderStatusHelper.RAW_CONFIRMED
                    );
                    psOrder.setInt(2, orderId);
                    psOrder.setString(
                            3,
                            OrderStatusHelper.RAW_PENDING
                    );
                    psOrder.setString(4, inventoryStatus);

                    if (psOrder.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                if (linkedShipmentId > 0 && shipmentId <= 0) {
                    try (PreparedStatement psLink
                            = conn.prepareStatement(
                                    updateShipmentLinkSql)) {

                        psLink.setInt(1, linkedShipmentId);
                        psLink.setInt(2, orderId);
                        psLink.executeUpdate();
                    }
                }

                conn.commit();
                return true;

            } catch (Exception transactionError) {
                conn.rollback();
                throw transactionError;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cancel a pending order without touching the Shipment module unless a
     * shipment row already exists.
     */
    public boolean cancelOrderByStaff(int orderId) {
        String loadSql
                = "SELECT o.order_status, o.inventory_status, "
                + "       o.shipment_id, o.voucher_id "
                + "FROM [Order] o WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE o.id = ?";

        String updateOrderSql
                = "UPDATE [Order] "
                + "SET order_status = ?, "
                + "    inventory_status = 'RELEASED', "
                + "    updated_at = GETDATE() "
                + "WHERE id = ? "
                + "AND order_status = ? "
                + "AND inventory_status = ?";

        String updateShipmentSql
                = "UPDATE Shipment "
                + "SET shipping_status = ? "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                String currentStatus;
                String inventoryStatus;
                int shipmentId;
                Integer voucherId;

                try (PreparedStatement psLoad
                        = conn.prepareStatement(loadSql)) {

                    psLoad.setInt(1, orderId);

                    try (ResultSet rs = psLoad.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }

                        currentStatus = rs.getString("order_status");
                        inventoryStatus = rs.getString("inventory_status");
                        shipmentId = rs.getInt("shipment_id");

                        int loadedVoucherId
                                = rs.getInt("voucher_id");

                        voucherId = rs.wasNull()
                                ? null
                                : loadedVoucherId;
                    }
                }

                if (currentStatus == null
                        || !OrderStatusHelper.RAW_PENDING.equalsIgnoreCase(
                                currentStatus.trim())) {

                    conn.rollback();
                    return false;
                }

                inventoryStatus = inventoryStatus == null
                        ? "NONE"
                        : inventoryStatus.trim().toUpperCase();

                if (!isPendingCancellationInventoryStatus(
                        inventoryStatus)) {

                    conn.rollback();
                    return false;
                }

                try (PreparedStatement psOrder
                        = conn.prepareStatement(updateOrderSql)) {

                    psOrder.setString(
                            1,
                            OrderStatusHelper.RAW_CANCELLED
                    );
                    psOrder.setInt(2, orderId);
                    psOrder.setString(
                            3,
                            OrderStatusHelper.RAW_PENDING
                    );
                    psOrder.setString(4, inventoryStatus);

                    if (psOrder.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                if ("RESERVED".equals(inventoryStatus)) {
                    releaseReservedStockForOrder(
                            conn,
                            orderId
                    );

                } else if ("LEGACY_DEDUCTED".equals(
                        inventoryStatus)) {

                    restoreLegacyStockForOrder(
                            conn,
                            orderId
                    );
                }

                releaseVoucherUsage(
                        conn,
                        voucherId
                );

                if (shipmentId > 0) {
                    try (PreparedStatement psShipment
                            = conn.prepareStatement(
                                    updateShipmentSql)) {

                        psShipment.setString(1, "FAILED");
                        psShipment.setInt(2, shipmentId);
                        psShipment.executeUpdate();
                    }
                }

                conn.commit();
                return true;

            } catch (Exception transactionError) {
                conn.rollback();
                throw transactionError;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Tạo shipment khi một đơn cần được chuyển sang khâu giao hàng.
     */
    private void commitReservedInventory(
            Connection conn,
            int orderId)
            throws SQLException {

        String sql
                = "SELECT variant_id, quantity "
                + "FROM Order_Detail "
                + "WHERE order_id=? "
                + "ORDER BY id";

        List<Integer> variantIds = new ArrayList<>();
        List<Integer> quantities = new ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");

                    if (variantIsNull || quantity <= 0) {
                        throw new SQLException(
                                "Order contains an invalid variant."
                        );
                    }

                    variantIds.add(variantId);
                    quantities.add(quantity);
                }
            }
        }

        if (variantIds.isEmpty()) {
            throw new SQLException(
                    "Order does not contain any order details."
            );
        }

        for (int i = 0; i < variantIds.size(); i++) {
            deductReservedVariant(
                    conn,
                    orderId,
                    variantIds.get(i),
                    quantities.get(i)
            );
        }
    }

    private void deductReservedVariant(
            Connection conn,
            int orderId,
            int variantId,
            int quantity)
            throws SQLException {

        String loadSql
                = "SELECT pv.stock_quantity, "
                + "       pv.reserved_quantity, "
                + "       pv.sku, "
                + "       p.product_name "
                + "FROM Product_Variant pv "
                + "WITH (UPDLOCK, HOLDLOCK) "
                + "INNER JOIN Product p "
                + "    ON p.id = pv.product_id "
                + "WHERE pv.id=?";

        String updateSql
                = "UPDATE Product_Variant "
                + "SET stock_quantity = stock_quantity - ?, "
                + "    reserved_quantity = reserved_quantity - ? "
                + "WHERE id=? "
                + "AND stock_quantity >= ? "
                + "AND reserved_quantity >= ?";

        int quantityBefore;
        int reservedBefore;
        String sku;
        String productName;

        try (PreparedStatement ps = conn.prepareStatement(loadSql)) {
            ps.setInt(1, variantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException(
                            "Variant not found: " + variantId
                    );
                }

                quantityBefore = rs.getInt("stock_quantity");
                reservedBefore = rs.getInt("reserved_quantity");
                sku = rs.getString("sku");
                productName = rs.getString("product_name");
            }
        }

        if (quantityBefore < quantity
                || reservedBefore < quantity) {

            throw new SQLException(
                    "Reserved inventory is insufficient for variant "
                    + variantId
            );
        }

        consumeFifoBatches(
                conn,
                variantId,
                quantity
        );

        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setInt(3, variantId);
            ps.setInt(4, quantity);
            ps.setInt(5, quantity);

            if (ps.executeUpdate() == 0) {
                throw new SQLException(
                        "Inventory changed while approving variant "
                        + variantId
                );
            }
        }

        insertInventoryLog(
                conn,
                variantId,
                productName,
                sku,
                quantityBefore,
                -quantity,
                quantityBefore - quantity,
                "SALE_OUT",
                orderId,
                "Stock deducted after order approval."
        );
    }

    private void synchronizeLegacyFifoBatches(
            Connection conn,
            int orderId)
            throws SQLException {

        String detailSql
                = "SELECT variant_id, quantity "
                + "FROM Order_Detail "
                + "WHERE order_id=? "
                + "ORDER BY id";

        String variantSql
                = "SELECT pv.stock_quantity, pv.sku, "
                + "       p.product_name "
                + "FROM Product_Variant pv "
                + "WITH (UPDLOCK, HOLDLOCK) "
                + "INNER JOIN Product p "
                + "    ON p.id = pv.product_id "
                + "WHERE pv.id=?";

        List<Integer> variantIds = new ArrayList<>();
        List<Integer> quantities = new ArrayList<>();

        try (PreparedStatement detail
                = conn.prepareStatement(detailSql)) {

            detail.setInt(1, orderId);

            try (ResultSet rs = detail.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");

                    if (variantIsNull || quantity <= 0) {
                        throw new SQLException(
                                "Legacy order contains an invalid variant."
                        );
                    }

                    variantIds.add(variantId);
                    quantities.add(quantity);
                }
            }
        }

        if (variantIds.isEmpty()) {
            throw new SQLException(
                    "Legacy order does not contain order details."
            );
        }

        for (int i = 0; i < variantIds.size(); i++) {
            int variantId = variantIds.get(i);
            int quantity = quantities.get(i);

            consumeFifoBatches(
                    conn,
                    variantId,
                    quantity
            );

            int quantityAfter;
            String sku;
            String productName;

            try (PreparedStatement variant
                    = conn.prepareStatement(variantSql)) {

                variant.setInt(1, variantId);

                try (ResultSet variantRs
                        = variant.executeQuery()) {

                    if (!variantRs.next()) {
                        throw new SQLException(
                                "Variant not found: " + variantId
                        );
                    }

                    quantityAfter = variantRs.getInt(
                            "stock_quantity"
                    );
                    sku = variantRs.getString("sku");
                    productName = variantRs.getString(
                            "product_name"
                    );
                }
            }

            insertInventoryLog(
                    conn,
                    variantId,
                    productName,
                    sku,
                    null,
                    -quantity,
                    quantityAfter,
                    "SALE_LEGACY_SYNC",
                    orderId,
                    "FIFO batches synchronized for an order "
                    + "whose Product_Variant stock was deducted "
                    + "before the reservation migration."
            );
        }
    }

    private void consumeFifoBatches(
            Connection conn,
            int variantId,
            int requestedQuantity)
            throws SQLException {

        String selectSql
                = "SELECT id, current_quantity "
                + "FROM Product_Batch "
                + "WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE variant_id=? "
                + "AND current_quantity > 0 "
                + "ORDER BY created_at ASC, id ASC";

        String updateSql
                = "UPDATE Product_Batch "
                + "SET current_quantity=?, "
                + "    status=? "
                + "WHERE id=? "
                + "AND current_quantity=?";

        List<Integer> batchIds = new ArrayList<>();
        List<Integer> batchQuantities = new ArrayList<>();
        int totalBatchQuantity = 0;

        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, variantId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int currentQuantity = rs.getInt(
                            "current_quantity"
                    );

                    batchIds.add(rs.getInt("id"));
                    batchQuantities.add(currentQuantity);
                    totalBatchQuantity += currentQuantity;
                }
            }
        }

        if (totalBatchQuantity < requestedQuantity) {
            throw new SQLException(
                    "FIFO batch stock is insufficient for variant "
                    + variantId
            );
        }

        int remaining = requestedQuantity;

        for (int i = 0;
                i < batchIds.size() && remaining > 0;
                i++) {

            int batchId = batchIds.get(i);
            int currentQuantity = batchQuantities.get(i);
            int deducted = Math.min(
                    currentQuantity,
                    remaining
            );
            int quantityAfter = currentQuantity - deducted;
            String status = quantityAfter == 0
                    ? "DEPLETED"
                    : "AVAILABLE";

            try (PreparedStatement update
                    = conn.prepareStatement(updateSql)) {

                update.setInt(1, quantityAfter);
                update.setString(2, status);
                update.setInt(3, batchId);
                update.setInt(4, currentQuantity);

                if (update.executeUpdate() == 0) {
                    throw new SQLException(
                            "Batch changed while approving order."
                    );
                }
            }

            remaining -= deducted;
        }

        if (remaining != 0) {
            throw new SQLException(
                    "Could not complete FIFO stock deduction."
            );
        }
    }

    private void insertInventoryLog(
            Connection conn,
            int variantId,
            String productName,
            String sku,
            Integer quantityBefore,
            int changeQuantity,
            Integer quantityAfter,
            String transactionType,
            int orderId,
            String note)
            throws SQLException {

        String sql
                = "INSERT INTO Inventory_Log "
                + "("
                + "variant_id,"
                + "user_id,"
                + "product_name_snapshot,"
                + "sku_snapshot,"
                + "quantity_before,"
                + "change_quantity,"
                + "quantity_after,"
                + "transaction_type,"
                + "reference_type,"
                + "reference_id,"
                + "note"
                + ") VALUES (?,?,?,?,?,?,?,?,?,?,?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.setNull(2, Types.INTEGER);
            ps.setString(3, productName);
            ps.setString(4, sku);

            if (quantityBefore == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, quantityBefore);
            }

            ps.setInt(6, changeQuantity);

            if (quantityAfter == null) {
                ps.setNull(7, Types.INTEGER);
            } else {
                ps.setInt(7, quantityAfter);
            }

            ps.setString(8, transactionType);
            ps.setString(9, "ORDER");
            ps.setInt(10, orderId);
            ps.setString(11, note);
            ps.executeUpdate();
        }
    }

    private boolean isPendingCancellationInventoryStatus(
            String inventoryStatus) {

        return "RESERVED".equals(inventoryStatus)
                || "LEGACY_DEDUCTED".equals(inventoryStatus)
                || "NONE".equals(inventoryStatus);
    }

    private void releaseReservedStockForOrder(
            Connection conn,
            int orderId)
            throws SQLException {

        String selectSql
                = "SELECT variant_id, quantity "
                + "FROM Order_Detail "
                + "WHERE order_id=?";

        String updateSql
                = "UPDATE Product_Variant "
                + "SET reserved_quantity = reserved_quantity - ? "
                + "WHERE id=? "
                + "AND reserved_quantity >= ?";

        List<Integer> variantIds = new ArrayList<>();
        List<Integer> quantities = new ArrayList<>();

        try (PreparedStatement select
                = conn.prepareStatement(selectSql)) {

            select.setInt(1, orderId);

            try (ResultSet rs = select.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");

                    if (!variantIsNull && quantity > 0) {
                        variantIds.add(variantId);
                        quantities.add(quantity);
                    }
                }
            }
        }

        for (int i = 0; i < variantIds.size(); i++) {
            int variantId = variantIds.get(i);
            int quantity = quantities.get(i);

            try (PreparedStatement update
                    = conn.prepareStatement(updateSql)) {

                update.setInt(1, quantity);
                update.setInt(2, variantId);
                update.setInt(3, quantity);

                if (update.executeUpdate() == 0) {
                    throw new SQLException(
                            "Reserved stock is inconsistent for variant "
                            + variantId
                    );
                }
            }
        }
    }

    private void restoreLegacyStockForOrder(
            Connection conn,
            int orderId)
            throws SQLException {

        String selectSql
                = "SELECT variant_id, quantity "
                + "FROM Order_Detail "
                + "WHERE order_id=?";

        String updateSql
                = "UPDATE Product_Variant "
                + "SET stock_quantity = stock_quantity + ? "
                + "WHERE id=?";

        List<Integer> variantIds = new ArrayList<>();
        List<Integer> quantities = new ArrayList<>();

        try (PreparedStatement select
                = conn.prepareStatement(selectSql)) {

            select.setInt(1, orderId);

            try (ResultSet rs = select.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");

                    if (!variantIsNull && quantity > 0) {
                        variantIds.add(variantId);
                        quantities.add(quantity);
                    }
                }
            }
        }

        for (int i = 0; i < variantIds.size(); i++) {
            int variantId = variantIds.get(i);
            int quantity = quantities.get(i);

            try (PreparedStatement update
                    = conn.prepareStatement(updateSql)) {

                update.setInt(1, quantity);
                update.setInt(2, variantId);

                if (update.executeUpdate() == 0) {
                    throw new SQLException(
                            "Legacy stock could not be restored for variant "
                            + variantId
                    );
                }
            }
        }
    }

    private void releaseVoucherUsage(
            Connection conn,
            Integer voucherId)
            throws SQLException {

        if (voucherId == null || voucherId <= 0) {
            return;
        }

        String sql
                = "UPDATE Voucher "
                + "SET used_count = used_count - 1 "
                + "WHERE id=? "
                + "AND used_count > 0";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        }
    }

    private int insertShipment(Connection conn,
            String carrierName,
            String shippingStatus,
            BigDecimal shippingCost) throws SQLException {

        String sql = "INSERT INTO Shipment (carrier_name, shipping_status, tracking_code, shipping_cost, estimated_delivery_time) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, carrierName);
            ps.setString(2, shippingStatus);
            ps.setNull(3, Types.VARCHAR);
            ps.setBigDecimal(4, shippingCost == null ? BigDecimal.ZERO : shippingCost);
            ps.setNull(5, Types.TIMESTAMP);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }

        throw new SQLException("Failed to create shipment record.");
    }

    /**
     * Mark a VNPay payment as paid after staff confirms the transfer.
     */
    public boolean markVnpayPaymentAsPaid(int orderId) {
        String loadSql = "SELECT payment_method, payment_status FROM Payment WHERE order_id = ?";
        String updateSql = "UPDATE Payment "
                + "SET payment_status = 'PAID', transaction_reference = ?, payment_date = GETDATE() "
                + "WHERE order_id = ?";
        String updateOrderSql = "UPDATE [Order] SET updated_at = GETDATE() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            String paymentMethod = null;
            String paymentStatus = null;

            try (PreparedStatement psLoad = conn.prepareStatement(loadSql)) {
                psLoad.setInt(1, orderId);
                try (ResultSet rs = psLoad.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }

                    paymentMethod = rs.getString("payment_method");
                    paymentStatus = rs.getString("payment_status");
                }
            }

            if (paymentMethod == null || !"VNPAY".equalsIgnoreCase(paymentMethod.trim())) {
                conn.rollback();
                return false;
            }

            if ("PAID".equalsIgnoreCase(paymentStatus)) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setString(1, "MANUAL-" + orderId);
                psUpdate.setInt(2, orderId);
                if (psUpdate.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement psOrder = conn.prepareStatement(updateOrderSql)) {
                psOrder.setInt(1, orderId);
                psOrder.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đổ dữ liệu từ ResultSet vào model Order.
     */
    private Order mapOrderRow(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getInt("id"));
        order.setOrderCode(rs.getString("order_code"));
        order.setUserId(rs.getInt("user_id"));
        order.setVoucherId(rs.getInt("voucher_id"));
        order.setShipmentId(rs.getInt("shipment_id"));
        order.setRecipientName(rs.getString("recipient_name"));
        order.setRecipientPhone(rs.getString("recipient_phone"));
        order.setWardId(rs.getString("ward_id"));
        order.setAddressDetail(rs.getString("address_detail"));
        order.setTotalItemsPrice(rs.getBigDecimal("total_items_price"));
        order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        order.setShippingFee(rs.getBigDecimal("shipping_fee"));
        order.setTotalPayment(rs.getBigDecimal("total_payment"));
        order.setOrderStatus(rs.getString("order_status"));
        order.setNote(rs.getString("note"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));

        order.setCustomerUsername(rs.getString("customer_username"));
        order.setCustomerFullName(rs.getString("customer_full_name"));
        order.setCustomerEmail(rs.getString("customer_email"));
        order.setShipmentCarrierName(rs.getString("shipment_carrier_name"));
        order.setShipmentTrackingCode(rs.getString("shipment_tracking_code"));
        order.setShippingStatus(rs.getString("shipping_status"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setPaymentStatus(rs.getString("payment_status"));
        order.setDetailCount(rs.getInt("detail_count"));
        order.setProvinceName(rs.getString("province_name"));
        order.setDistrictName(rs.getString("district_name"));
        order.setWardName(rs.getString("ward_name"));

        return order;
    }

    /**
     * Gán lần lượt các tham số cho PreparedStatement theo đúng thứ tự đã build ở
     * query.
     */
    private void bindParameters(PreparedStatement ps, List<Object> parameters) throws SQLException {
        for (int i = 0; i < parameters.size(); i++) {
            Object value = parameters.get(i);
            int index = i + 1;

            if (value instanceof String) {
                ps.setString(index, (String) value);
            } else if (value instanceof Integer) {
                ps.setInt(index, (Integer) value);
            } else {
                ps.setObject(index, value);
            }
        }
    }

}