package com.clothingsale.dao;

import com.clothingsale.model.StaffShipment;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffShipmentManagementDAO {

    public List<StaffShipment> getAllShipments(String keyword, String statusFilter) {
        List<StaffShipment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT s.id AS shipment_id, o.id AS order_id, o.order_code, o.recipient_name, o.recipient_phone, " +
                        "ISNULL(o.address_detail, '') + " +
                        "ISNULL(', ' + w.ward_name, '') + " +
                        "ISNULL(', ' + d.district_name, '') + " +
                        "ISNULL(', ' + pr.province_name, '') AS delivery_address, " +
                        "s.carrier_name, UPPER(TRIM(s.shipping_status)) AS shipping_status, s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note "
                        +
                        "FROM Shipment s " +
                        "JOIN [Order] o ON o.shipment_id = s.id " +
                        "LEFT JOIN Ward w ON o.ward_id = w.id " +
                        "LEFT JOIN District d ON w.district_id = d.id " +
                        "LEFT JOIN Province pr ON d.province_id = pr.id " +
                        "WHERE UPPER(TRIM(o.order_status)) NOT IN ('PENDING', 'CANCELLED') ");

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
            // Keep compatibility with the old form value while storing the
            // schema-consistent FAILED status.
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
                    list.add(model);
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
                + "ISNULL(', ' + w.ward_name, '') + "
                + "ISNULL(', ' + d.district_name, '') + "
                + "ISNULL(', ' + pr.province_name, '') AS delivery_address, "
                + "s.carrier_name, UPPER(TRIM(s.shipping_status)) AS shipping_status, s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note "
                + "FROM Shipment s "
                + "JOIN [Order] o ON o.shipment_id = s.id "
                + "LEFT JOIN Ward w ON o.ward_id = w.id "
                + "LEFT JOIN District d ON w.district_id = d.id "
                + "LEFT JOIN Province pr ON d.province_id = pr.id "
                + "WHERE s.id = ? AND UPPER(TRIM(o.order_status)) NOT IN ('PENDING', 'CANCELLED')";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
                    return model;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateDeliveryOutcome(int shipmentId, String requestedStatus, String remarks) {
        String newShippingStatus = normalizeOutcome(requestedStatus);
        if (shipmentId <= 0 || newShippingStatus == null) {
            return false;
        }

        String queryShipment = "SELECT o.id AS order_id, o.order_status, "
                + "s.shipping_status, p.payment_method, p.payment_status "
                + "FROM Shipment s JOIN [Order] o ON o.shipment_id = s.id "
                + "LEFT JOIN Payment p ON p.order_id = o.id WHERE s.id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                String currentOrderStatus;
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
                    expectedShippingStatus = "SHIPPING";
                    mappedOrderStatus = "SUCCESS";
                    if (!"SHIPPING".equals(currentOrderStatus)) {
                        conn.rollback();
                        return false;
                    }
                } else {
                    expectedShippingStatus = "SHIPPING";
                    // A failed delivery is a returned order, not an invented
                    // FAILURE order status. This also makes stock restoration
                    // visible in the existing customer/order lifecycle.
                    mappedOrderStatus = "RETURNED";
                    if (!"SHIPPING".equals(currentOrderStatus)) {
                        conn.rollback();
                        return false;
                    }
                }

                String updateShipment = "UPDATE Shipment SET shipping_status = ? "
                        + "WHERE id = ? AND UPPER(TRIM(shipping_status)) = ?";
                try (PreparedStatement psS = conn.prepareStatement(updateShipment)) {
                    psS.setString(1, newShippingStatus);
                    psS.setInt(2, shipmentId);
                    psS.setString(3, expectedShippingStatus);
                    if (psS.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                String note = remarks == null || remarks.trim().isEmpty()
                        ? null
                        : "[Staff Note: " + remarks.trim() + "]";
                String updateOrder;
                if (note == null) {
                    updateOrder = "UPDATE [Order] SET order_status = ?, updated_at = GETDATE() "
                            + "WHERE id = ? AND order_status = ?";
                } else {
                    updateOrder = "UPDATE [Order] SET order_status = ?, note = ?, updated_at = GETDATE() "
                            + "WHERE id = ? AND order_status = ?";
                }
                try (PreparedStatement psO = conn.prepareStatement(updateOrder)) {
                    psO.setString(1, mappedOrderStatus);
                    if (note == null) {
                        psO.setInt(2, orderId);
                        psO.setString(3, currentOrderStatus);
                    } else {
                        psO.setString(2, note);
                        psO.setInt(3, orderId);
                        psO.setString(4, currentOrderStatus);
                    }
                    if (psO.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                if ("FAILED".equals(newShippingStatus)) {
                    restoreStockForOrder(conn, orderId);
                    refundVoucherForOrder(conn, orderId, "Refunded after failed delivery");
                    updatePaymentAfterFailure(conn, orderId, paymentMethod, paymentStatus);
                } else if ("SUCCESS".equals(newShippingStatus)
                        && "COD".equals(paymentMethod)
                        && "UNPAID".equals(paymentStatus)) {
                    String updatePayment = "UPDATE Payment SET payment_status = 'PAID', payment_date = GETDATE() "
                            + "WHERE order_id = ? AND payment_status = 'UNPAID'";
                    try (PreparedStatement psP = conn.prepareStatement(updatePayment)) {
                        psP.setInt(1, orderId);
                        psP.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private String normalizeOutcome(String requestedStatus) {
        String status = normalize(requestedStatus);
        if ("FAILURE".equals(status)) {
            return "FAILED";
        }
        if ("SHIPPING".equals(status) || "SUCCESS".equals(status) || "FAILED".equals(status)) {
            return status;
        }
        return null;
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private void restoreStockForOrder(Connection conn, int orderId) throws SQLException {
        String selectSql = "SELECT variant_id, quantity FROM Order_Detail WHERE order_id = ?";
        String restoreSql = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ? WHERE id = ?";

        try (PreparedStatement psDetails = conn.prepareStatement(selectSql);
                PreparedStatement psRestore = conn.prepareStatement(restoreSql)) {
            psDetails.setInt(1, orderId);
            try (ResultSet rs = psDetails.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");
                    if (!variantIsNull && variantId > 0 && quantity > 0) {
                        psRestore.setInt(1, quantity);
                        psRestore.setInt(2, variantId);
                        psRestore.addBatch();
                    }
                }
            }
            psRestore.executeBatch();
        }
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

    private void refundVoucherForOrder(Connection conn, int orderId, String note)
            throws SQLException {
        String selectSql = "SELECT voucher_id FROM Voucher_Usage WHERE order_id=? AND status='APPLIED'";
        String updateUsageSql = "UPDATE Voucher_Usage "
                + "SET status='REFUNDED', refunded_at=GETDATE(), note=? "
                + "WHERE order_id=? AND status='APPLIED'";
        String decrementSql = "UPDATE Voucher "
                + "SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END "
                + "WHERE id=?";

        java.util.List<Integer> voucherIds = new java.util.ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    voucherIds.add(rs.getInt("voucher_id"));
                }
            }
        }

        if (voucherIds.isEmpty()) {
            return;
        }

        try (PreparedStatement ps = conn.prepareStatement(updateUsageSql)) {
            ps.setString(1, note);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }

        try (PreparedStatement ps = conn.prepareStatement(decrementSql)) {
            for (Integer voucherId : voucherIds) {
                if (voucherId == null) {
                    continue;
                }
                ps.setInt(1, voucherId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}
