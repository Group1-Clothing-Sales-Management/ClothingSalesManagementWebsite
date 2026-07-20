package com.clothingsale.dao;

import com.clothingsale.model.Feedback;
import com.clothingsale.util.DBConnection;

import com.clothingsale.model.OrderDetail;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerFeedbackDAO {

    /**
     * Lấy tất cả feedback của một sản phẩm Chỉ hiển thị feedback đang được phép
     * hiển thị (status = 1)
     */
    public List<Feedback> getFeedbackByProduct(int productId) {

        List<Feedback> list = new ArrayList<>();

        String sql
                = "SELECT f.*, "
                + "u.username, "
                + "u.full_name, "
                + "u.email, "
                + "p.product_name, "
                + "p.slug, "
                + "img.image_url, "
                + "o.order_code "
                + "FROM Feedback f "
                + "INNER JOIN [User] u ON f.user_id = u.id "
                + "INNER JOIN Product p ON f.product_id = p.id "
                + "LEFT JOIN Product_Image img "
                + "ON p.id = img.product_id "
                + "AND img.is_main = 1 "
                + "LEFT JOIN [Order] o "
                + "ON f.order_id = o.id "
                + "WHERE f.product_id = ? "
                + "AND f.status = 1 "
                + "ORDER BY f.created_at DESC";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Feedback fb = new Feedback();

                fb.setId(rs.getInt("id"));
                fb.setUserId(rs.getInt("user_id"));
                fb.setProductId(rs.getInt("product_id"));

                int orderId = rs.getInt("order_id");
                if (!rs.wasNull()) {
                    fb.setOrderId(orderId);
                }

                fb.setRating(rs.getInt("rating"));
                fb.setComment(rs.getString("comment"));

                // SQL dùng cột status
                fb.setVisible(rs.getBoolean("status"));

                fb.setAdminResponse(rs.getString("admin_response"));

                int responseBy = rs.getInt("response_by");
                if (!rs.wasNull()) {
                    fb.setResponseBy(responseBy);
                }

                fb.setRespondedAt(rs.getTimestamp("responded_at"));
                fb.setCreatedAt(rs.getTimestamp("created_at"));

                // Thông tin customer
                fb.setCustomerUsername(rs.getString("username"));
                fb.setCustomerFullName(rs.getString("full_name"));
                fb.setCustomerEmail(rs.getString("email"));

                // Thông tin product
                fb.setProductName(rs.getString("product_name"));
                fb.setProductSlug(rs.getString("slug"));
                fb.setProductImageUrl(rs.getString("image_url"));

                // Order
                fb.setOrderCode(rs.getString("order_code"));

                list.add(fb);
            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;
    }

    /**
     * Lấy feedback của chính user đối với sản phẩm
     */
    public Feedback getUserFeedback(int userId, int productId) {

        String sql
                = "SELECT * "
                + "FROM Feedback "
                + "WHERE user_id = ? "
                + "AND product_id = ?";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                Feedback fb = new Feedback();

                fb.setId(rs.getInt("id"));
                fb.setUserId(rs.getInt("user_id"));
                fb.setProductId(rs.getInt("product_id"));

                int orderId = rs.getInt("order_id");
                if (!rs.wasNull()) {
                    fb.setOrderId(orderId);
                }

                fb.setRating(rs.getInt("rating"));
                fb.setComment(rs.getString("comment"));
                fb.setVisible(rs.getBoolean("status"));

                fb.setAdminResponse(
                        rs.getString("admin_response")
                );

                int responseBy = rs.getInt("response_by");
                if (!rs.wasNull()) {
                    fb.setResponseBy(responseBy);
                }

                fb.setRespondedAt(
                        rs.getTimestamp("responded_at")
                );

                fb.setCreatedAt(
                        rs.getTimestamp("created_at")
                );

                return fb;
            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return null;
    }

    /**
     * Tính điểm đánh giá trung bình
     */
    public BigDecimal getAverageRating(int productId) {

        String sql
                = "SELECT AVG(CAST(rating AS DECIMAL(10,2))) avgRating "
                + "FROM Feedback "
                + "WHERE product_id = ? "
                + "AND status = 1";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                BigDecimal avg
                        = rs.getBigDecimal("avgRating");

                return avg == null
                        ? BigDecimal.ZERO
                        : avg;
            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return BigDecimal.ZERO;
    }

/**
     * Kiểm tra user có được phép tạo feedback hay không cho một dòng đơn hàng cụ thể.
     *
     * Điều kiện: - Đã mua sản phẩm trong Order_Detail - Đơn hàng đã giao (DELIVERED)
     * - Chưa feedback cho order_detail đó - Không có return/refund hoàn tất cho dòng đó
     */
    public boolean canCreateFeedback(int userId, int productId, int orderDetailId) {

        return hasEligibleDeliveredOrderDetail(userId, productId, orderDetailId)
                && !hasFeedbackForOrderDetail(userId, orderDetailId)
                && !hasCompletedReturnForOrderDetail(orderDetailId);

    }

    public List<OrderDetail> getEligibleOrderDetailsForFeedback(int userId, int productId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT od.id, od.order_id, od.variant_id, od.product_name_snapshot, od.variant_attributes_snapshot, od.quantity, od.price, "
                + "pv.product_id, p.product_name, o.order_code "
                + "FROM Order_Detail od "
                + "INNER JOIN [Order] o ON o.id = od.order_id "
                + "INNER JOIN Shipment s ON o.shipment_id = s.id "
                + "LEFT JOIN Product_Variant pv ON pv.id = od.variant_id "
                + "LEFT JOIN Product p ON p.id = pv.product_id "
                + "WHERE o.user_id = ? "
                + "AND (pv.product_id = ? OR p.id = ?) "
                + "AND s.shipping_status IN ('DELIVERED', 'SUCCESS') "
                + "AND NOT EXISTS (SELECT 1 FROM Feedback f WHERE f.user_id = ? AND f.order_detail_id = od.id) "
                + "AND NOT EXISTS (SELECT 1 FROM Return_Request_Item rri "
                + "INNER JOIN Return_Request rr ON rr.id = rri.return_request_id "
                + "WHERE rri.order_detail_id = od.id AND rr.status = 'COMPLETED') "
                + "ORDER BY o.created_at DESC, od.id DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.setInt(3, productId);
            ps.setInt(4, userId);

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
                    detail.setProductId(rs.getInt("product_id"));
                    detail.setCurrentProductName(rs.getString("product_name"));
                    list.add(detail);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private boolean hasEligibleDeliveredOrderDetail(int userId, int productId, int orderDetailId) {
        String sql = "SELECT TOP 1 1 "
                + "FROM Order_Detail od "
                + "INNER JOIN [Order] o ON o.id = od.order_id "
                + "INNER JOIN Shipment s ON o.shipment_id = s.id "
                + "LEFT JOIN Product_Variant pv ON pv.id = od.variant_id "
                + "WHERE o.user_id = ? "
                + "AND od.id = ? "
                + "AND (pv.product_id = ? OR pv.product_id IS NULL) "
                + "AND s.shipping_status IN ('DELIVERED', 'SUCCESS')";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, orderDetailId);
            ps.setInt(3, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private boolean hasFeedbackForOrderDetail(int userId, int orderDetailId) {
        String sql = "SELECT COUNT(*) total FROM Feedback WHERE user_id = ? AND order_detail_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, orderDetailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private boolean hasCompletedReturnForOrderDetail(int orderDetailId) {
        String sql = "SELECT TOP 1 1 FROM Return_Request_Item rri "
                + "INNER JOIN Return_Request rr ON rr.id = rri.return_request_id "
                + "WHERE rri.order_detail_id = ? AND rr.status = 'COMPLETED'";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderDetailId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Kiểm tra user đã mua sản phẩm và đơn hàng đã giao
     */
    public boolean hasPurchasedDeliveredProduct(int userId, int productId) {

        String sql =
                "SELECT TOP 1 o.id "
                + "FROM [Order] o "
                + "INNER JOIN Shipment s "
                + "ON o.shipment_id = s.id "
                + "INNER JOIN Order_Detail od "
                + "ON o.id = od.order_id "
                + "INNER JOIN Product_Variant pv "
                + "ON od.variant_id = pv.id "
                + "WHERE o.user_id = ? "
                + "AND pv.product_id = ? "
                + "AND s.shipping_status IN ('DELIVERED', 'SUCCESS')";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    /**
     * Kiểm tra user đã feedback sản phẩm chưa
     */
    public boolean hasFeedback(int userId, int productId) {

        String sql =
                "SELECT COUNT(*) total "
                + "FROM Feedback "
                + "WHERE user_id = ? "
                + "AND product_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt("total") > 0;

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    /**
     * Lấy Order đã giao của user đối với sản phẩm
     * Dùng khi insert feedback để lưu order_id
     */
    public Integer getOrderIdForDetail(int orderDetailId) {
        String sql = "SELECT order_id FROM Order_Detail WHERE id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderDetailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("order_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public Integer getDeliveredOrderId(int userId, int productId) {

        String sql =
                "SELECT TOP 1 od.id "
                + "FROM [Order] o "
                + "INNER JOIN Shipment s "
                + "ON o.shipment_id = s.id "
                + "INNER JOIN Order_Detail od "
                + "ON o.id = od.order_id "
                + "INNER JOIN Product_Variant pv "
                + "ON od.variant_id = pv.id "
                + "WHERE o.user_id = ? "
                + "AND pv.product_id = ? "
                + "AND s.shipping_status IN ('DELIVERED', 'SUCCESS') "
                + "AND NOT EXISTS (SELECT 1 FROM Feedback f WHERE f.user_id = ? AND f.order_detail_id = od.id) "
                + "AND NOT EXISTS (SELECT 1 FROM Return_Request_Item rri INNER JOIN Return_Request rr ON rr.id = rri.return_request_id WHERE rri.order_detail_id = od.id AND rr.status = 'COMPLETED') "
                + "ORDER BY o.created_at DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt("id");

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return null;
    }
    public static String extractVariantAttributeValue(String snapshot, String attributeName) {
        if (snapshot == null || snapshot.trim().isEmpty()) {
            return null;
        }

        String normalized = snapshot.trim();
        String[] parts = normalized.split(",");
        for (String part : parts) {
            String trimmed = part.trim();
            int separatorIndex = trimmed.indexOf(':');
            if (separatorIndex < 0) {
                continue;
            }

            String key = trimmed.substring(0, separatorIndex).trim().toLowerCase();
            String value = trimmed.substring(separatorIndex + 1).trim();
            if (attributeName.equalsIgnoreCase(key)) {
                return value.isEmpty() ? null : value;
            }
        }

        return null;
    }

    /**
     * Tạo Feedback mới
     */
    public boolean createFeedback(Feedback feedback) {

        String sql =
                "INSERT INTO Feedback ("
                + "user_id, "
                + "product_id, "
                + "order_id, "
                + "order_detail_id, "
                + "variant_id, "
                + "size, "
                + "color, "
                + "rating, "
                + "comment, "
                + "status"
                + ") "
                + "VALUES (?,?,?,?,?,?,?,?,?,?)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, feedback.getUserId());
            ps.setInt(2, feedback.getProductId());

            if (feedback.getOrderId() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, feedback.getOrderId());
            }

            if (feedback.getOrderDetailId() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, feedback.getOrderDetailId());
            }

            if (feedback.getVariantId() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, feedback.getVariantId());
            }

            ps.setString(6, feedback.getSize());
            ps.setString(7, feedback.getColor());
            ps.setInt(8, feedback.getRating());
            ps.setString(9, feedback.getComment());

            // Feedback mới mặc định hiển thị
            ps.setBoolean(10, feedback.isVisible());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    /**
     * Cập nhật Feedback
     * Chỉ owner mới được sửa
     */
    public boolean updateFeedback(Feedback feedback) {

        String sql =
                "UPDATE Feedback "
                + "SET rating = ?, "
                + "comment = ? "
                + "WHERE id = ? "
                + "AND user_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, feedback.getRating());
            ps.setString(2, feedback.getComment());
            ps.setInt(3, feedback.getId());
            ps.setInt(4, feedback.getUserId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

}
