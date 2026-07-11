package com.clothingsale.dao;

import com.clothingsale.model.Voucher;
import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminVoucherDAO {

    public List<Voucher> getAllVouchers(String search, String statusFilter) {
        List<Voucher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Voucher WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (code LIKE ? OR title LIKE ?) ");
        }

        if (statusFilter != null && !"ALL".equals(statusFilter)) {
            if ("EXHAUSTED".equals(statusFilter)) {
                sql.append(" AND used_count >= usage_limit ");
            } else if ("UPCOMING".equals(statusFilter)) {
                sql.append(" AND GETDATE() < start_date AND used_count < usage_limit ");
            } else if ("EXPIRED".equals(statusFilter)) {
                sql.append(" AND GETDATE() > end_date AND used_count < usage_limit ");
            } else if ("ACTIVE".equals(statusFilter)) {
                sql.append(" AND GETDATE() BETWEEN start_date AND end_date AND used_count < usage_limit ");
            }
        }
        sql.append(" ORDER BY start_date DESC ");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher v = mapResultSetToVoucher(rs);
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM Voucher WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertVoucher(Voucher voucher) {
        String sql = "INSERT INTO Voucher (code, title, discount_type, discount_value, "
                + "max_discount_amount, min_order_value, start_date, end_date, "
                + "usage_limit, used_count, limit_per_user, category_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucher.getCode().trim().toUpperCase());
            ps.setString(2, voucher.getTitle());
            ps.setString(3, voucher.getDiscountType());
            ps.setBigDecimal(4, voucher.getDiscountValue());
            ps.setBigDecimal(5, voucher.getMaxDiscountAmount());
            ps.setBigDecimal(6, voucher.getMinOrderValue());
            ps.setTimestamp(7, voucher.getStartDate());
            ps.setTimestamp(8, voucher.getEndDate());
            ps.setInt(9, voucher.getUsageLimit());
            ps.setInt(10, 0);
            ps.setInt(11, voucher.getLimitPerUser());
            if (voucher.getCategoryId() != null) {
                ps.setInt(12, voucher.getCategoryId());
            } else {
                ps.setNull(12, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateVoucher(Voucher voucher) {
        String sql = "UPDATE Voucher SET title = ?, discount_type = ?, discount_value = ?, "
                + "max_discount_amount = ?, min_order_value = ?, start_date = ?, "
                + "end_date = ?, usage_limit = ?, limit_per_user = ?, category_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucher.getTitle());
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getDiscountValue());
            ps.setBigDecimal(4, voucher.getMaxDiscountAmount());
            ps.setBigDecimal(5, voucher.getMinOrderValue());
            ps.setTimestamp(6, voucher.getStartDate());
            ps.setTimestamp(7, voucher.getEndDate());
            ps.setInt(8, voucher.getUsageLimit());
            ps.setInt(9, voucher.getLimitPerUser());
            if (voucher.getCategoryId() != null) {
                ps.setInt(10, voucher.getCategoryId());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setInt(11, voucher.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // FIX NGHIỆP VỤ ISSUE 2: Cập nhật lý do dừng rõ ràng không lồng kết nối phức tạp
    public boolean terminateVoucherEarly(int id, java.sql.Timestamp newEndDate, String reason) {
        String updateSql = "UPDATE Voucher SET end_date = ?, terminate_reason = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setTimestamp(1, newEndDate);
            ps.setString(2, reason);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Hàm lấy nhanh danh mục phục vụ chọn phạm vi áp dụng (Voucher Scope)
    public List<Category> getAllCategoriesSimple() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, category_name FROM Category WHERE status = 1";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setCategoryName(rs.getString("category_name"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean checkCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE code = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getInt("id"));
        v.setCode(rs.getString("code"));
        v.setTitle(rs.getString("title"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getBigDecimal("discount_value"));
        v.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
        v.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setUsageLimit(rs.getInt("usage_limit"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setLimitPerUser(rs.getInt("limit_per_user"));
        v.setTerminateReason(rs.getString("terminate_reason"));
        int catId = rs.getInt("category_id");
        v.setCategoryId(rs.wasNull() ? null : catId);
        return v;
    }
}
