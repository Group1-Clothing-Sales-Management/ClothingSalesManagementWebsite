package com.clothingsale.dao;

import com.clothingsale.model.StaffShipment;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffShipmentManagementDAO {

    /**
     * UC-09.1: Lấy danh sách thông tin vận chuyển kèm bộ lọc tìm kiếm và trạng thái
     */
    public List<StaffShipment> getAllShipments(String keyword, String statusFilter) {
        List<StaffShipment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT s.id AS shipment_id, o.id AS order_id, o.order_code, o.recipient_name, o.recipient_phone, " +
                        "o.address_detail + ', ' + w.ward_name + ', ' + d.district_name + ', ' + pr.province_name AS delivery_address, "
                        +
                        "s.carrier_name, s.shipping_status, s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note "
                        +
                        "FROM Shipment s " +
                        "JOIN [Order] o ON o.shipment_id = s.id " +
                        "LEFT JOIN Ward w ON o.ward_id = w.id " +
                        "LEFT JOIN District d ON w.district_id = d.id " +
                        "LEFT JOIN Province pr ON d.province_id = pr.id " +
                        "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (o.order_code LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?) ");
            String search = "%" + keyword.trim() + "%";
            params.add(search);
            params.add(search);
            params.add(search);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND s.shipping_status = ? ");
            params.add(statusFilter.trim().toUpperCase());
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

    /**
     * Lấy chi tiết bản ghi vận chuyển theo ID
     */
    public StaffShipment getShipmentById(int shipmentId) {
        String sql = "SELECT s.id AS shipment_id, o.id AS order_id, o.order_code, o.recipient_name, o.recipient_phone, "
                +
                "o.address_detail + ', ' + w.ward_name + ', ' + d.district_name + ', ' + pr.province_name AS delivery_address, "
                +
                "s.carrier_name, s.shipping_status, s.tracking_code, s.shipping_cost, s.estimated_delivery_time, o.note "
                +
                "FROM Shipment s " +
                "JOIN [Order] o ON o.shipment_id = s.id " +
                "LEFT JOIN Ward w ON o.ward_id = w.id " +
                "LEFT JOIN District d ON w.district_id = d.id " +
                "LEFT JOIN Province pr ON d.province_id = pr.id " +
                "WHERE s.id = ?";
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

    /**
     * UC-09.2: Cập nhật kết quả giao hàng (Thành công / Thất bại) và đồng bộ trạng
     * thái liên quan
     */
    public boolean updateDeliveryOutcome(int shipmentId, String outcomeStatus, String remarks) {
        String queryShipment = "SELECT s.shipping_status, o.id AS order_id, p.payment_method, p.payment_status " +
                "FROM Shipment s JOIN [Order] o ON o.shipment_id = s.id " +
                "LEFT JOIN Payment p ON p.order_id = o.id WHERE s.id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement psCheck = conn.prepareStatement(queryShipment)) {
                psCheck.setInt(1, shipmentId);
                String currentShippingStatus = null;
                int orderId = 0;
                String paymentMethod = null;
                String paymentStatus = null;

                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentShippingStatus = rs.getString("shipping_status");
                        orderId = rs.getInt("order_id");
                        paymentMethod = rs.getString("payment_method");
                        paymentStatus = rs.getString("payment_status");
                    }
                }

                // Ràng buộc: Chỉ xử lý đơn có trạng thái SHIPPING (In Transit)
                if (currentShippingStatus == null || !"SHIPPING".equalsIgnoreCase(currentShippingStatus)) {
                    conn.rollback();
                    return false;
                }

                // 1. Cập nhật bảng Shipment
                String updateShipment = "UPDATE Shipment SET shipping_status = ? WHERE id = ?";
                try (PreparedStatement psS = conn.prepareStatement(updateShipment)) {
                    psS.setString(1, outcomeStatus);
                    psS.setInt(2, shipmentId);
                    psS.executeUpdate();
                }

                // 2. Cập nhật bảng Order tương ứng
                String orderStatus = "DELIVERED".equalsIgnoreCase(outcomeStatus) ? "DELIVERED" : "CANCELLED";
                String updateOrder = "UPDATE [Order] SET order_status = ?, note = ISNULL(note, '') + ?, updated_at = GETDATE() WHERE id = ?";
                try (PreparedStatement psO = conn.prepareStatement(updateOrder)) {
                    psO.setString(1, orderStatus);
                    psO.setString(2,
                            remarks != null && !remarks.trim().isEmpty() ? " [Staff Note: " + remarks.trim() + "]"
                                    : "");
                    psO.setInt(3, orderId);
                    psO.executeUpdate();
                }

                // 3. Đồng bộ trạng thái Payment dựa theo Lifecycle của hệ thống (Nếu giao thành
                // công qua COD)
                if ("DELIVERED".equalsIgnoreCase(outcomeStatus) && "COD".equalsIgnoreCase(paymentMethod)
                        && "UNPAID".equalsIgnoreCase(paymentStatus)) {
                    String updatePayment = "UPDATE Payment SET payment_status = 'PAID', payment_date = GETDATE() WHERE order_id = ?";
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
}