package com.clothingsale.dao;

import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class AdminManageCategoryDAO {

    /**
     * Trả về danh sách phẳng nhưng được sắp xếp theo:
     * Parent Category -> các Subcategory trực thuộc.
     */
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();

        String sql
                = "SELECT c.id, c.category_name, c.slug, c.parent_id, "
                + "       c.description, c.status, "
                + "       ("
                + "           SELECT COUNT(*) "
                + "           FROM dbo.Product p "
                + "           WHERE p.status = 'ACTIVE' "
                + "           AND ("
                + "               p.category_id = c.id "
                + "               OR ("
                + "                   c.parent_id IS NULL "
                + "                   AND p.category_id IN ("
                + "                       SELECT child.id "
                + "                       FROM dbo.Category child "
                + "                       WHERE child.parent_id = c.id"
                + "                   )"
                + "               )"
                + "           )"
                + "       ) AS product_count "
                + "FROM dbo.Category c "
                + "ORDER BY "
                + "    CASE WHEN c.parent_id IS NULL THEN c.id ELSE c.parent_id END, "
                + "    CASE WHEN c.parent_id IS NULL THEN 0 ELSE 1 END, "
                + "    c.category_name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapCategory(rs, true));
            }
        } catch (SQLException e) {
            System.err.println("Could not load admin categories.");
            e.printStackTrace();
        }

        return categories;
    }

    /**
     * Dùng cho dropdown Parent Category.
     * Chỉ Category cấp gốc mới có thể làm Parent.
     */
    public List<Category> getRootCategories() {
        List<Category> categories = new ArrayList<>();

        String sql
                = "SELECT id, category_name, slug, parent_id, "
                + "       description, status "
                + "FROM dbo.Category "
                + "WHERE parent_id IS NULL "
                + "ORDER BY status DESC, category_name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapCategory(rs, false));
            }
        } catch (SQLException e) {
            System.err.println("Could not load root categories.");
            e.printStackTrace();
        }

        return categories;
    }

    public Category getCategoryById(int id) {
        String sql
                = "SELECT id, category_name, slug, parent_id, "
                + "       description, status "
                + "FROM dbo.Category "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCategory(rs, false);
                }
            }
        } catch (SQLException e) {
            System.err.println("Could not find category id " + id + ".");
            e.printStackTrace();
        }

        return null;
    }

    public boolean insertCategory(Category category) {
        String sql
                = "INSERT INTO dbo.Category "
                + "    (category_name, slug, parent_id, description, status) "
                + "VALUES (?, ?, ?, ?, 1)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getSlug());
            setNullableInteger(ps, 3, category.getParentId());
            ps.setString(4, category.getDescription());

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("Could not insert category.");
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateCategory(Category category) {
        String sql
                = "UPDATE dbo.Category "
                + "SET category_name = ?, "
                + "    slug = ?, "
                + "    parent_id = ?, "
                + "    description = ? "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getSlug());
            setNullableInteger(ps, 3, category.getParentId());
            ps.setString(4, category.getDescription());
            ps.setInt(5, category.getId());

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("Could not update category id "
                    + category.getId() + ".");
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateCategoryStatus(int id, int status) {
        if (id <= 0 || (status != 0 && status != 1)) {
            return false;
        }

        String sql
                = "UPDATE dbo.Category "
                + "SET status = ? "
                + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, status);
            ps.setInt(2, id);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("Could not update category status.");
            e.printStackTrace();
            return false;
        }
    }

    public boolean existsByName(String categoryName, int excludedId) {
        String sql
                = "SELECT COUNT(*) "
                + "FROM dbo.Category "
                + "WHERE LOWER(LTRIM(RTRIM(category_name))) "
                + "      = LOWER(LTRIM(RTRIM(?)))";

        if (excludedId > 0) {
            sql += " AND id <> ?";
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, categoryName);

            if (excludedId > 0) {
                ps.setInt(2, excludedId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Could not validate category name.");
            e.printStackTrace();

            // Không cho ghi dữ liệu khi bước kiểm tra duy nhất thất bại.
            return true;
        }
    }

    /**
     * Lấy tên các Category khác để Service kiểm tra tên gần trùng.
     *
     * Ví dụ được xem là trùng:
     * - Men jeans
     * - Mens Jeans
     * - Men's Jeans
     */
    public List<String> getCategoryNamesForDuplicateCheck(
            int excludedId
    ) {
        List<String> categoryNames = new ArrayList<>();

        String sql
                = "SELECT category_name "
                + "FROM dbo.Category "
                + "WHERE (? <= 0 OR id <> ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, excludedId);
            ps.setInt(2, excludedId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    categoryNames.add(
                            rs.getString("category_name")
                    );
                }
            }

            return categoryNames;
        } catch (SQLException e) {
            System.err.println(
                    "Could not load category names for duplicate check."
            );
            e.printStackTrace();

            /*
             * null biểu thị lỗi DB để Service không tiếp tục insert/update.
             */
            return null;
        }
    }

    public boolean existsBySlug(String slug, int excludedId) {
        String sql
                = "SELECT COUNT(*) "
                + "FROM dbo.Category "
                + "WHERE LOWER(LTRIM(RTRIM(slug))) "
                + "      = LOWER(LTRIM(RTRIM(?)))";

        if (excludedId > 0) {
            sql += " AND id <> ?";
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, slug);

            if (excludedId > 0) {
                ps.setInt(2, excludedId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Could not validate category slug.");
            e.printStackTrace();
            return true;
        }
    }

    /**
     * Với Category cha: đếm Product ACTIVE của chính Category cha
     * và toàn bộ Subcategory trực thuộc.
     *
     * Với Subcategory: chỉ đếm Product ACTIVE của chính Subcategory.
     */
    public int countActiveProductsByCategory(int categoryId) {
        String sql
                = "SELECT COUNT(*) "
                + "FROM dbo.Product p "
                + "WHERE p.status = 'ACTIVE' "
                + "AND ("
                + "    p.category_id = ? "
                + "    OR p.category_id IN ("
                + "        SELECT child.id "
                + "        FROM dbo.Category child "
                + "        WHERE child.parent_id = ?"
                + "    )"
                + ")";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            ps.setInt(2, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            System.err.println(
                    "Could not count active products for category."
            );
            e.printStackTrace();
            return -1;
        }
    }

    public int countChildren(int categoryId) {
        String sql
                = "SELECT COUNT(*) "
                + "FROM dbo.Category "
                + "WHERE parent_id = ?";

        return executeCount(sql, categoryId);
    }

    public int countActiveChildren(int categoryId) {
        String sql
                = "SELECT COUNT(*) "
                + "FROM dbo.Category "
                + "WHERE parent_id = ? "
                + "AND status = 1";

        return executeCount(sql, categoryId);
    }

    private int executeCount(String sql, int categoryId) {
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            System.err.println("Could not count category dependencies.");
            e.printStackTrace();
            return -1;
        }
    }

    private Category mapCategory(ResultSet rs, boolean hasProductCount)
            throws SQLException {

        Category category = new Category();

        category.setId(rs.getInt("id"));
        category.setCategoryName(rs.getString("category_name"));
        category.setSlug(rs.getString("slug"));

        int parentId = rs.getInt("parent_id");
        category.setParentId(rs.wasNull() ? null : parentId);

        category.setDescription(rs.getString("description"));
        category.setStatus(rs.getInt("status"));

        if (hasProductCount) {
            category.setProductCount(rs.getInt("product_count"));
        }

        return category;
    }

    private void setNullableInteger(
            PreparedStatement ps,
            int parameterIndex,
            Integer value
    ) throws SQLException {

        if (value == null) {
            ps.setNull(parameterIndex, Types.INTEGER);
        } else {
            ps.setInt(parameterIndex, value);
        }
    }
}