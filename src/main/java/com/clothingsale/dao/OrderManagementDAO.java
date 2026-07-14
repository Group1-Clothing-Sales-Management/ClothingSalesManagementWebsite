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
        String loadSql = "SELECT o.order_status, o.shipment_id, o.shipping_fee "
                + "FROM [Order] o WHERE o.id = ?";
        String updateOrderSql = "UPDATE [Order] SET order_status = ?, updated_at = GETDATE() WHERE id = ?";
        String updateShipmentLinkSql = "UPDATE [Order] SET shipment_id = ?, updated_at = GETDATE() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            String currentStatus = null;
            int shipmentId = 0;
            BigDecimal shippingFee = BigDecimal.ZERO;

            try (PreparedStatement psLoad = conn.prepareStatement(loadSql)) {
                psLoad.setInt(1, orderId);
                try (ResultSet rs = psLoad.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }

                    currentStatus = rs.getString("order_status");
                    shipmentId = rs.getInt("shipment_id");
                    shippingFee = rs.getBigDecimal("shipping_fee");
                }
            }

            if (currentStatus == null || !OrderStatusHelper.RAW_PENDING.equalsIgnoreCase(currentStatus.trim())) {
                conn.rollback();
                return false;
            }

            int linkedShipmentId = shipmentId;
            if (linkedShipmentId <= 0 && shippingFee != null && shippingFee.compareTo(BigDecimal.ZERO) > 0) {
                linkedShipmentId = insertShipment(
                        conn,
                        "Internal Delivery",
                        "PENDING_PICKUP",
                        shippingFee);
            }

            try (PreparedStatement psOrder = conn.prepareStatement(updateOrderSql)) {
                psOrder.setString(1, OrderStatusHelper.RAW_CONFIRMED);
                psOrder.setInt(2, orderId);
                if (psOrder.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            if (linkedShipmentId > 0 && shipmentId <= 0) {
                try (PreparedStatement psLink = conn.prepareStatement(updateShipmentLinkSql)) {
                    psLink.setInt(1, linkedShipmentId);
                    psLink.setInt(2, orderId);
                    psLink.executeUpdate();
                }
            }

            conn.commit();
            return true;
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
        String loadSql = "SELECT o.order_status, o.shipment_id FROM [Order] o WHERE o.id = ?";
        String updateOrderSql = "UPDATE [Order] SET order_status = ?, updated_at = GETDATE() WHERE id = ?";
        String updateShipmentSql = "UPDATE Shipment SET shipping_status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            String currentStatus = null;
            int shipmentId = 0;

            try (PreparedStatement psLoad = conn.prepareStatement(loadSql)) {
                psLoad.setInt(1, orderId);
                try (ResultSet rs = psLoad.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    currentStatus = rs.getString("order_status");
                    shipmentId = rs.getInt("shipment_id");
                }
            }

            if (currentStatus == null || !OrderStatusHelper.RAW_PENDING.equalsIgnoreCase(currentStatus.trim())) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement psOrder = conn.prepareStatement(updateOrderSql)) {
                psOrder.setString(1, OrderStatusHelper.RAW_CANCELLED);
                psOrder.setInt(2, orderId);
                if (psOrder.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            if (shipmentId > 0) {
                try (PreparedStatement psShipment = conn.prepareStatement(updateShipmentSql)) {
                    psShipment.setString(1, "FAILED");
                    psShipment.setInt(2, shipmentId);
                    psShipment.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Tạo shipment khi một đơn cần được chuyển sang khâu giao hàng.
     */
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
