package com.clothingsale.dao;

import com.clothingsale.model.Voucher;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminVoucherDAO {

    // READ: Lấy danh sách Voucher kèm bộ lọc Tìm kiếm & Trạng thái
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
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // READ: Lấy thông tin chi tiết Voucher theo ID
    public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM Voucher WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
                    return v;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE: Thêm mới Voucher
    public boolean insertVoucher(Voucher voucher) {
        String sql = "INSERT INTO Voucher (code, title, discount_type, discount_value, "
                + "max_discount_amount, min_order_value, start_date, end_date, "
                + "usage_limit, used_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE: Cập nhật Voucher thông thường
    public boolean updateVoucher(Voucher voucher) {
        String sql = "UPDATE Voucher SET title = ?, discount_type = ?, discount_value = ?, "
                + "max_discount_amount = ?, min_order_value = ?, start_date = ?, "
                + "end_date = ?, usage_limit = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, voucher.getTitle());
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getDiscountValue());
            ps.setBigDecimal(4, voucher.getMaxDiscountAmount());
            ps.setBigDecimal(5, voucher.getMinOrderValue());
            ps.setTimestamp(6, voucher.getStartDate());
            ps.setTimestamp(7, voucher.getEndDate());
            ps.setInt(8, voucher.getUsageLimit());
            ps.setInt(9, voucher.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE SPECIAL: Xử lý dừng sớm lộ trình đệm (Giải quyết triệt để lỗi Connection lồng nhau)
    public boolean terminateVoucherEarly(int id, java.sql.Timestamp newEndDate, String reason) {
        String selectSql = "SELECT title FROM Voucher WHERE id = ?";
        String updateSql = "UPDATE Voucher SET end_date = ?, title = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            String currentTitle = "";

            // 1. Đọc dữ liệu title cũ ngay trong kết nối này
            try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                psSelect.setInt(1, id);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        currentTitle = rs.getString("title");
                    } else {
                        return false;
                    }
                }
            }

            // Xử lý làm sạch tiêu đề chuỗi tránh lặp vết cũ
            if (currentTitle.contains("(Concluding Early:")) {
                currentTitle = currentTitle.substring(0, currentTitle.indexOf("(Concluding Early:"));
            }
            String updatedTitle = currentTitle.trim() + " (Concluding Early: " + reason + ")";

            // 2. Chạy lệnh cập nhật luôn dữ liệu
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setTimestamp(1, newEndDate);
                psUpdate.setString(2, updatedTitle);
                psUpdate.setInt(3, id);
                return psUpdate.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // CHECK: Kiểm tra trùng mã Code
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
    
    public int getTotalSavedCount(int voucherId) {
        String sql = "SELECT COUNT(user_id) FROM User_Saved_Voucher WHERE voucher_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0; // Trả về 0 nếu có lỗi hoặc chưa ai lưu
    }
}
