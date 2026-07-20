package com.clothingsale.dao;

import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminManageCategoryDAO {

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();

        String sql = "SELECT c.id, c.category_name, c.slug, c.status, "
                + "SUM(CASE WHEN p.status = 'ACTIVE' THEN 1 ELSE 0 END) AS product_count "
                + "FROM Category c "
                + "LEFT JOIN Product p ON p.category_id = c.id "
                + "GROUP BY c.id, c.category_name, c.slug, c.status "
                + "ORDER BY c.status DESC, c.category_name ASC";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();

                category.setId(rs.getInt("id"));
                category.setCategoryName(rs.getString("category_name"));
                category.setSlug(rs.getString("slug"));
                category.setStatus(rs.getInt("status"));
                category.setProductCount(rs.getInt("product_count"));

                categories.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
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

    public boolean updateCategoryStatus(int id, int status) {
        if (id <= 0 || (status != 0 && status != 1)) {
            return false;
        }

        String sql;

        if (status == 0) {
            sql = "UPDATE Category "
                    + "SET status = 0 "
                    + "WHERE id = ? "
                    + "AND NOT EXISTS ("
                    + "    SELECT 1 "
                    + "    FROM Product "
                    + "    WHERE Product.category_id = Category.id "
                    + "    AND Product.status = 'ACTIVE'"
                    + ")";
        } else {
            sql = "UPDATE Category "
                    + "SET status = 1 "
                    + "WHERE id = ?";
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean existsByName(String categoryName, int excludedId) {
        String sql = "SELECT COUNT(*) FROM Category "
                + "WHERE LOWER(LTRIM(RTRIM(category_name))) "
                + "= LOWER(LTRIM(RTRIM(?)))";

        if (excludedId > 0) {
            sql += " AND id <> ?";
        }

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, categoryName);

            if (excludedId > 0) {
                ps.setInt(2, excludedId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();

            // Không tiếp tục insert/update khi việc kiểm tra gặp lỗi.
            return true;
        }
    }

    /**
     * check slug
     */
    public boolean existsBySlug(String slug, int excludedId) {
        String sql = "SELECT COUNT(*) FROM Category "
                + "WHERE LOWER(LTRIM(RTRIM(slug))) "
                + "= LOWER(LTRIM(RTRIM(?)))";

        if (excludedId > 0) {
            sql += " AND id <> ?";
        }

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);

            if (excludedId > 0) {
                ps.setInt(2, excludedId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    public int countActiveProductsByCategory(int categoryId) {
        String sql = "SELECT COUNT(*) FROM Product "
                + "WHERE category_id = ? "
                + "AND status = 'ACTIVE'";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }
}
