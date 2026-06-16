package com.clothingsale.dao;

import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminManageCategoryDAO {

    // Lấy toàn bộ danh mục chưa bị xóa mềm (status = 1)
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, category_name, slug, status FROM Category WHERE status = 1 ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                c.setStatus(rs.getInt("status"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tìm kiếm danh mục theo ID để phục vụ tính năng Sửa
    public Category getCategoryById(int id) {
        String sql = "SELECT id, category_name, slug, status FROM Category WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category c = new Category();
                    c.setId(rs.getInt("id"));
                    c.setCategoryName(rs.getString("category_name"));
                    c.setSlug(rs.getString("slug"));
                    c.setStatus(rs.getInt("status"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm mới danh mục sản phẩm
    public boolean insertCategory(Category c) {
        String sql = "INSERT INTO Category (category_name, slug, status) VALUES (?, ?, 1)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getSlug());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin danh mục
    public boolean updateCategory(Category c) {
        String sql = "UPDATE Category SET category_name = ?, slug = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getSlug());
            ps.setInt(3, c.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa mềm danh mục sản phẩm (chuyển status thành 0) để không làm mất toàn bộ liên kết của sản phẩm cũ
    public boolean softDeleteCategory(int id) {
        String sql = "UPDATE Category SET status = 0 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
