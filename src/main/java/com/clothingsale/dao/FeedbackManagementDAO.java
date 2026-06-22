package com.clothingsale.dao;

import com.clothingsale.model.Feedback;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý toàn bộ truy vấn liên quan đến Feedback.
 * Tách lớp này ra giúp Servlet chỉ lo điều hướng request/response, còn SQL nằm
 * gọn trong một chỗ để dễ bảo trì.
 */
public class FeedbackManagementDAO {

    /**
     * Lấy toàn bộ feedback kèm thông tin sản phẩm, khách hàng và người trả lời.
     * Danh sách được sắp xếp mới nhất lên đầu để Staff/Admin xử lý nhanh.
     */
    public List<Feedback> getAllFeedbacks() throws SQLException {
        List<Feedback> list = new ArrayList<>();
        String extendedSql = buildExtendedFeedbackSql(null);
        String legacySql = buildLegacyFeedbackSql(null);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try {
                list.addAll(loadFeedbacks(conn, extendedSql));
            } catch (SQLException extendedError) {
                // Nếu DB chưa được migrate lên schema mới thì dùng câu query cũ để
                // vẫn xem được danh sách feedback thay vì làm hỏng cả trang.
                list.clear();
                list.addAll(loadFeedbacks(conn, legacySql));
            }
        }
        return list;
    }

    /**
     * Lấy một feedback theo id để hiển thị màn hình chi tiết.
     */
    public Feedback getFeedbackById(int id) throws SQLException {
        String extendedSql = buildExtendedFeedbackSql("WHERE f.id = ?");
        String legacySql = buildLegacyFeedbackSql("WHERE f.id = ?");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try {
                Feedback feedback = loadSingleFeedback(conn, extendedSql, id);
                if (feedback != null) {
                    return feedback;
                }
            } catch (SQLException extendedError) {
                return loadSingleFeedback(conn, legacySql, id);
            }
        }
        return null;
    }

    /**
     * Lưu nội dung phản hồi của Staff/Admin.
     * Nếu feedback đã có phản hồi cũ thì cập nhật đè lên để thao tác đơn giản.
     */
    public boolean updateResponse(int feedbackId, String response, int responderId) throws SQLException {
        String sql = "UPDATE Feedback "
                + "SET admin_response = ?, "
                + "response_by = ?, "
                + "responded_at = GETDATE() "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, response);
            ps.setInt(2, responderId);
            ps.setInt(3, feedbackId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Xóa feedback khỏi cơ sở dữ liệu.
     * Chúng ta xóa cứng ở đây vì feedback là dữ liệu nghiệp vụ nhỏ, không cần lưu log phức tạp.
     */
    public boolean deleteFeedback(int feedbackId) throws SQLException {
        String sql = "DELETE FROM Feedback WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Chuyển ResultSet sang object Feedback để tránh lặp code giữa list/detail.
     */
    private Feedback mapFeedback(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setId(rs.getInt("id"));
        feedback.setUserId(rs.getInt("user_id"));
        feedback.setProductId(rs.getInt("product_id"));

        int orderId = rs.getInt("order_id");
        feedback.setOrderId(rs.wasNull() ? null : orderId);

        feedback.setRating(rs.getInt("rating"));
        feedback.setComment(rs.getString("comment"));
        feedback.setVisible(rs.getBoolean("status"));
        feedback.setAdminResponse(rs.getString("admin_response"));

        int responseBy = rs.getInt("response_by");
        feedback.setResponseBy(rs.wasNull() ? null : responseBy);

        feedback.setRespondedAt(rs.getTimestamp("responded_at"));
        feedback.setCreatedAt(rs.getTimestamp("created_at"));
        feedback.setCustomerUsername(rs.getString("customer_username"));
        feedback.setCustomerFullName(rs.getString("customer_full_name"));
        feedback.setCustomerEmail(rs.getString("customer_email"));
        feedback.setProductName(rs.getString("product_name"));
        feedback.setProductSlug(rs.getString("product_slug"));
        feedback.setProductImageUrl(rs.getString("product_image_url"));
        feedback.setOrderCode(rs.getString("order_code"));
        feedback.setResponderUsername(rs.getString("responder_username"));
        feedback.setResponderFullName(rs.getString("responder_full_name"));
        return feedback;
    }

    /**
     * Query mới: có các cột phản hồi của Staff/Admin.
     * `whereClause` có thể là null hoặc "WHERE ...".
     */
    private String buildExtendedFeedbackSql(String whereClause) {
        String sql = "SELECT "
                + "f.id, "
                + "f.user_id, "
                + "f.product_id, "
                + "f.order_id, "
                + "f.rating, "
                + "f.comment, "
                + "f.status, "
                + "f.admin_response, "
                + "f.response_by, "
                + "f.responded_at, "
                + "f.created_at, "
                + "u.username AS customer_username, "
                + "u.full_name AS customer_full_name, "
                + "u.email AS customer_email, "
                + "p.product_name, "
                + "p.slug AS product_slug, "
                + "img.image_url AS product_image_url, "
                + "o.order_code, "
                + "responder.username AS responder_username, "
                + "responder.full_name AS responder_full_name "
                + "FROM Feedback f "
                + "LEFT JOIN [User] u ON f.user_id = u.id "
                + "LEFT JOIN Product p ON f.product_id = p.id "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "LEFT JOIN [Order] o ON f.order_id = o.id "
                + "LEFT JOIN [User] responder ON f.response_by = responder.id ";
        if (whereClause != null && !whereClause.trim().isEmpty()) {
            sql += whereClause + " ";
        }
        sql += "ORDER BY f.created_at DESC, f.id DESC";
        return sql;
    }

    /**
     * Query cũ: chỉ dùng những cột chắc chắn đã có trong DB hiện tại.
     * Dùng làm fallback để trang list vẫn chạy nếu schema chưa migrate.
     */
    private String buildLegacyFeedbackSql(String whereClause) {
        String sql = "SELECT "
                + "f.id, "
                + "f.user_id, "
                + "f.product_id, "
                + "f.order_id, "
                + "f.rating, "
                + "f.comment, "
                + "f.status, "
                + "f.created_at, "
                + "u.username AS customer_username, "
                + "u.full_name AS customer_full_name, "
                + "u.email AS customer_email, "
                + "p.product_name, "
                + "p.slug AS product_slug, "
                + "img.image_url AS product_image_url, "
                + "o.order_code "
                + "FROM Feedback f "
                + "LEFT JOIN [User] u ON f.user_id = u.id "
                + "LEFT JOIN Product p ON f.product_id = p.id "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "LEFT JOIN [Order] o ON f.order_id = o.id ";
        if (whereClause != null && !whereClause.trim().isEmpty()) {
            sql += whereClause + " ";
        }
        sql += "ORDER BY f.created_at DESC, f.id DESC";
        return sql;
    }

    /**
     * Dùng chung cho list và detail để giảm trùng code giữa 2 query path.
     */
    private List<Feedback> loadFeedbacks(Connection conn, String sql) throws SQLException {
        List<Feedback> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapFeedbackSafely(rs));
            }
        }
        return list;
    }

    /**
     * Lấy 1 feedback theo query đã có sẵn và id đầu vào.
     */
    private Feedback loadSingleFeedback(Connection conn, String sql, int id) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapFeedbackSafely(rs);
                }
            }
        }
        return null;
    }

    /**
     * Map dữ liệu an toàn: cột nào không tồn tại thì trả về null thay vì làm fail cả trang.
     */
    private Feedback mapFeedbackSafely(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setId(getInt(rs, "id"));
        feedback.setUserId(getInt(rs, "user_id"));
        feedback.setProductId(getInt(rs, "product_id"));

        Integer orderId = getNullableInt(rs, "order_id");
        feedback.setOrderId(orderId);

        feedback.setRating(getInt(rs, "rating"));
        feedback.setComment(getString(rs, "comment"));
        feedback.setVisible(getBoolean(rs, "status"));
        feedback.setAdminResponse(getString(rs, "admin_response"));

        feedback.setResponseBy(getNullableInt(rs, "response_by"));
        feedback.setRespondedAt(getTimestamp(rs, "responded_at"));
        feedback.setCreatedAt(getTimestamp(rs, "created_at"));
        feedback.setCustomerUsername(getString(rs, "customer_username"));
        feedback.setCustomerFullName(getString(rs, "customer_full_name"));
        feedback.setCustomerEmail(getString(rs, "customer_email"));
        feedback.setProductName(getString(rs, "product_name"));
        feedback.setProductSlug(getString(rs, "product_slug"));
        feedback.setProductImageUrl(getString(rs, "product_image_url"));
        feedback.setOrderCode(getString(rs, "order_code"));
        feedback.setResponderUsername(getString(rs, "responder_username"));
        feedback.setResponderFullName(getString(rs, "responder_full_name"));
        return feedback;
    }

    private String getString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException e) {
            return null;
        }
    }

    private int getInt(ResultSet rs, String column) {
        try {
            return rs.getInt(column);
        } catch (SQLException e) {
            return 0;
        }
    }

    private Integer getNullableInt(ResultSet rs, String column) {
        try {
            int value = rs.getInt(column);
            return rs.wasNull() ? null : value;
        } catch (SQLException e) {
            return null;
        }
    }

    private boolean getBoolean(ResultSet rs, String column) {
        try {
            return rs.getBoolean(column);
        } catch (SQLException e) {
            return false;
        }
    }

    private java.sql.Timestamp getTimestamp(ResultSet rs, String column) {
        try {
            return rs.getTimestamp(column);
        } catch (SQLException e) {
            return null;
        }
    }
}
