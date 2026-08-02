package com.clothingsale.dao;

import com.clothingsale.model.Category;
import com.clothingsale.model.Voucher;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

public class AdminVoucherDAO {

    private static final String SCOPE_TABLE = "Voucher_Category_Scope";

    private static final String VOUCHER_SCOPE_SELECT
            = "SELECT v.*, "
            + "parentCategory.category_name, "
            + "parentCategory.parent_id AS category_parent_id, "
            + "CASE WHEN parentCategory.id IS NOT NULL AND EXISTS ("
            + "    SELECT 1 FROM Category child "
            + "    WHERE child.parent_id = parentCategory.id AND child.status = 1"
            + ") THEN 1 ELSE 0 END AS category_has_children, "
            + "CASE "
            + "    WHEN v.category_id IS NULL THEN 1 "
            + "    WHEN parentCategory.id IS NOT NULL "
            + "         AND parentCategory.status = 1 "
            + "         AND parentCategory.parent_id IS NULL "
            + "         AND EXISTS ("
            + "             SELECT 1 FROM " + SCOPE_TABLE + " scopeRow "
            + "             WHERE scopeRow.voucher_id = v.id"
            + "         ) "
            + "         AND NOT EXISTS ("
            + "             SELECT 1 "
            + "             FROM " + SCOPE_TABLE + " scopeRow "
            + "             LEFT JOIN Category selectedCategory "
            + "                    ON selectedCategory.id = scopeRow.category_id "
            + "             LEFT JOIN Category selectedParent "
            + "                    ON selectedParent.id = selectedCategory.parent_id "
            + "             WHERE scopeRow.voucher_id = v.id "
            + "               AND (selectedCategory.id IS NULL "
            + "                    OR selectedCategory.status <> 1 "
            + "                    OR (selectedCategory.parent_id IS NOT NULL "
            + "                        AND ISNULL(selectedParent.status, 0) <> 1))"
            + "         ) "
            + "    THEN 1 ELSE 0 "
            + "END AS category_scope_active "
            + "FROM Voucher v "
            + "LEFT JOIN Category parentCategory ON parentCategory.id = v.category_id ";

    public List<Voucher> getAllVouchers(String search, String statusFilter) {
        List<Voucher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(VOUCHER_SCOPE_SELECT);
        sql.append("WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (v.code LIKE ? OR v.title LIKE ? "
                    + "OR parentCategory.category_name LIKE ? "
                    + "OR EXISTS (SELECT 1 FROM ").append(SCOPE_TABLE)
                    .append(" scopeSearch JOIN Category scopeCategory ")
                    .append("ON scopeCategory.id = scopeSearch.category_id ")
                    .append("WHERE scopeSearch.voucher_id = v.id ")
                    .append("AND scopeCategory.category_name LIKE ?)) ");
        }

        if (statusFilter != null && !"ALL".equalsIgnoreCase(statusFilter)) {
            if ("EXHAUSTED".equalsIgnoreCase(statusFilter)) {
                sql.append("AND v.used_count >= v.usage_limit ");
            } else if ("UPCOMING".equalsIgnoreCase(statusFilter)) {
                sql.append("AND GETDATE() < v.start_date AND v.used_count < v.usage_limit ");
            } else if ("EXPIRED".equalsIgnoreCase(statusFilter)) {
                sql.append("AND GETDATE() > v.end_date AND v.used_count < v.usage_limit ");
            } else if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
                sql.append("AND GETDATE() BETWEEN v.start_date AND v.end_date "
                        + "AND v.used_count < v.usage_limit ");
            }
        }

        sql.append("ORDER BY v.start_date DESC, v.id DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (search != null && !search.trim().isEmpty()) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(1, pattern);
                ps.setString(2, pattern);
                ps.setString(3, pattern);
                ps.setString(4, pattern);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToVoucher(rs));
                }
            }

            loadScopeCategories(conn, list);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Voucher getVoucherById(int id) {
        String sql = VOUCHER_SCOPE_SELECT + "WHERE v.id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Voucher voucher = mapResultSetToVoucher(rs);
                    List<Voucher> vouchers = new ArrayList<>();
                    vouchers.add(voucher);
                    loadScopeCategories(conn, vouchers);
                    return voucher;
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
                + "usage_limit, used_count, limit_per_user, category_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS)) {

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
                setNullableInteger(ps, 12, voucher.getCategoryId());

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        conn.rollback();
                        return false;
                    }
                    voucher.setId(keys.getInt(1));
                }
            }

            insertScopeCategories(
                    conn,
                    voucher.getId(),
                    voucher.getSelectedCategoryIds()
            );

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            return false;
        } finally {
            restoreAndClose(conn);
        }
    }

    public boolean updateVoucher(Voucher voucher) {
        String sql = "UPDATE Voucher SET title = ?, discount_type = ?, discount_value = ?, "
                + "max_discount_amount = ?, min_order_value = ?, start_date = ?, "
                + "end_date = ?, usage_limit = ?, limit_per_user = ?, category_id = ? "
                + "WHERE id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, voucher.getTitle());
                ps.setString(2, voucher.getDiscountType());
                ps.setBigDecimal(3, voucher.getDiscountValue());
                ps.setBigDecimal(4, voucher.getMaxDiscountAmount());
                ps.setBigDecimal(5, voucher.getMinOrderValue());
                ps.setTimestamp(6, voucher.getStartDate());
                ps.setTimestamp(7, voucher.getEndDate());
                ps.setInt(8, voucher.getUsageLimit());
                ps.setInt(9, voucher.getLimitPerUser());
                setNullableInteger(ps, 10, voucher.getCategoryId());
                ps.setInt(11, voucher.getId());

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            deleteScopeCategories(conn, voucher.getId());
            insertScopeCategories(
                    conn,
                    voucher.getId(),
                    voucher.getSelectedCategoryIds()
            );

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            return false;
        } finally {
            restoreAndClose(conn);
        }
    }

    public boolean terminateVoucherEarly(int id, Timestamp newEndDate, String reason) {
        String sql = "UPDATE Voucher SET end_date = ?, terminate_reason = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, newEndDate);
            ps.setString(2, reason);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns active root categories and their active direct children. The
     * voucher form uses the root as a group and the children as multi-select
     * options. A root without children is selectable by itself.
     */
    public List<Category> getAllCategoriesSimple() {
        Map<Integer, Category> all = new LinkedHashMap<>();
        List<Category> roots = new ArrayList<>();

        String sql = "SELECT c.id, c.category_name, c.slug, c.parent_id, "
                + "c.description, c.status "
                + "FROM Category c "
                + "LEFT JOIN Category parent ON parent.id = c.parent_id "
                + "WHERE c.status = 1 "
                + "AND (c.parent_id IS NULL OR parent.status = 1) "
                + "ORDER BY "
                + "CASE WHEN c.parent_id IS NULL THEN c.id ELSE c.parent_id END, "
                + "CASE WHEN c.parent_id IS NULL THEN 0 ELSE 1 END, "
                + "c.category_name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category category = mapCategory(rs);
                all.put(category.getId(), category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return roots;
        }

        for (Category category : all.values()) {
            if (category.getParentId() == null) {
                roots.add(category);
                continue;
            }

            Category parent = all.get(category.getParentId());
            if (parent != null) {
                parent.addChild(category);
            }
        }

        return roots;
    }

    public Category getCategoryById(int id) {
        String sql = "SELECT id, category_name, slug, parent_id, description, status "
                + "FROM Category WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCategory(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean hasActiveChildren(int parentCategoryId) {
        String sql = "SELECT COUNT(*) FROM Category "
                + "WHERE parent_id = ? AND status = 1";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, parentCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean checkCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE code = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void loadScopeCategories(
            Connection conn,
            List<Voucher> vouchers) throws SQLException {

        if (vouchers == null || vouchers.isEmpty()) {
            return;
        }

        Map<Integer, Voucher> voucherById = new LinkedHashMap<>();
        StringJoiner placeholders = new StringJoiner(",");

        for (Voucher voucher : vouchers) {
            voucher.setSelectedCategoryIds(new ArrayList<>());
            voucher.setSelectedCategoryNames(new ArrayList<>());
            voucherById.put(voucher.getId(), voucher);
            placeholders.add("?");
        }

        String sql = "SELECT scopeRow.voucher_id, category.id, category.category_name "
                + "FROM " + SCOPE_TABLE + " scopeRow "
                + "JOIN Category category ON category.id = scopeRow.category_id "
                + "WHERE scopeRow.voucher_id IN (" + placeholders + ") "
                + "ORDER BY scopeRow.voucher_id, category.category_name";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (Integer voucherId : voucherById.keySet()) {
                ps.setInt(index++, voucherId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = voucherById.get(rs.getInt("voucher_id"));
                    if (voucher != null) {
                        voucher.addSelectedCategoryId(rs.getInt("id"));
                        voucher.addSelectedCategoryName(rs.getString("category_name"));
                    }
                }
            }
        }
    }

    private void insertScopeCategories(
            Connection conn,
            int voucherId,
            List<Integer> categoryIds) throws SQLException {

        if (categoryIds == null || categoryIds.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO " + SCOPE_TABLE
                + " (voucher_id, category_id) VALUES (?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Integer categoryId : categoryIds) {
                if (categoryId == null || categoryId <= 0) {
                    continue;
                }
                ps.setInt(1, voucherId);
                ps.setInt(2, categoryId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void deleteScopeCategories(Connection conn, int voucherId)
            throws SQLException {

        String sql = "DELETE FROM " + SCOPE_TABLE + " WHERE voucher_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        }
    }

    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher voucher = new Voucher();
        voucher.setId(rs.getInt("id"));
        voucher.setCode(rs.getString("code"));
        voucher.setTitle(rs.getString("title"));
        voucher.setDiscountType(rs.getString("discount_type"));
        voucher.setDiscountValue(rs.getBigDecimal("discount_value"));
        voucher.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
        voucher.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        voucher.setStartDate(rs.getTimestamp("start_date"));
        voucher.setEndDate(rs.getTimestamp("end_date"));
        voucher.setUsageLimit(rs.getInt("usage_limit"));
        voucher.setUsedCount(rs.getInt("used_count"));
        voucher.setLimitPerUser(rs.getInt("limit_per_user"));
        voucher.setTerminateReason(rs.getString("terminate_reason"));

        int categoryId = rs.getInt("category_id");
        voucher.setCategoryId(rs.wasNull() ? null : categoryId);
        voucher.setCategoryName(rs.getString("category_name"));

        int parentId = rs.getInt("category_parent_id");
        voucher.setCategoryParentId(rs.wasNull() ? null : parentId);
        voucher.setCategoryHasChildren(rs.getBoolean("category_has_children"));
        voucher.setCategoryScopeActive(rs.getBoolean("category_scope_active"));

        return voucher;
    }

    private Category mapCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setCategoryName(rs.getString("category_name"));
        category.setSlug(rs.getString("slug"));

        int parentId = rs.getInt("parent_id");
        category.setParentId(rs.wasNull() ? null : parentId);
        category.setDescription(rs.getString("description"));
        category.setStatus(rs.getInt("status"));
        return category;
    }

    private void setNullableInteger(
            PreparedStatement ps,
            int index,
            Integer value) throws SQLException {

        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (SQLException ignored) {
        }
    }

    private void restoreAndClose(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
        } catch (SQLException ignored) {
        }
        try {
            conn.close();
        } catch (SQLException ignored) {
        }
    }
}