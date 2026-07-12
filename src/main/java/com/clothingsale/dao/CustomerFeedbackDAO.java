package com.clothingsale.dao;

import com.clothingsale.model.Feedback;
import com.clothingsale.util.DBConnection;

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
 * Kiểm tra user có được phép tạo feedback hay không
 *
 * Điều kiện: - Đã mua sản phẩm - Đơn hàng đã giao (DELIVERED) - Chưa feedback
 * sản phẩm này
 */
public boolean canCreateFeedback(int userId, int productId) {

        return hasPurchasedDeliveredProduct(userId, productId)
                && !hasFeedback(userId, productId);

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
                + "AND s.shipping_status = 'DELIVERED'";

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
    public Integer getDeliveredOrderId(int userId, int productId) {

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
                + "AND s.shipping_status = 'DELIVERED' "
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
    /**
     * Tạo Feedback mới
     */
    public boolean createFeedback(Feedback feedback) {

        String sql =
                "INSERT INTO Feedback ("
                + "user_id, "
                + "product_id, "
                + "order_id, "
                + "rating, "
                + "comment, "
                + "status"
                + ") "
                + "VALUES (?,?,?,?,?,?)";

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

            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getComment());

            // Feedback mới mặc định hiển thị
            ps.setBoolean(6, feedback.isVisible());

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
