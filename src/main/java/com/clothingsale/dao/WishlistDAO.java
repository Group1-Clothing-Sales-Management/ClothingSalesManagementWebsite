package com.clothingsale.dao;

import com.clothingsale.model.WishlistItem;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WishlistDAO {

    private static final Logger LOGGER = Logger.getLogger(WishlistDAO.class.getName());

    private static final String SELECT_BY_USER_SQL
            = "SELECT w.user_id, w.product_id, w.variant_id, w.created_at, w.updated_at, "
            + "p.product_name, p.slug, p.status AS product_status, "
            + "img.image_url AS main_image_url, pv.sku, pv.sale_price, "
            + "pv.stock_quantity, pv.status AS variant_status, "
            + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav "
            + " JOIN Attribute a ON a.id = vav.attribute_id "
            + " WHERE vav.variant_id = pv.id AND a.attribute_name = 'Color') AS color, "
            + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav "
            + " JOIN Attribute a ON a.id = vav.attribute_id "
            + " WHERE vav.variant_id = pv.id AND a.attribute_name = 'Size') AS size "
            + "FROM Wishlist w "
            + "JOIN Product p ON p.id = w.product_id "
            + "OUTER APPLY (SELECT TOP 1 pi.image_url FROM Product_Image pi "
            + " WHERE pi.product_id = p.id ORDER BY pi.is_main DESC, pi.sort_order, pi.id) img "
            + "LEFT JOIN Product_Variant pv ON pv.id = w.variant_id "
            + "WHERE w.user_id = ? "
            + "ORDER BY w.updated_at DESC, w.created_at DESC";

    public List<WishlistItem> findByUserId(int userId) {
        List<WishlistItem> items = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null) {
                return items;
            }

            try (PreparedStatement statement = connection.prepareStatement(SELECT_BY_USER_SQL)) {
                statement.setInt(1, userId);

                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        WishlistItem item = new WishlistItem();
                        item.setUserId(resultSet.getInt("user_id"));
                        item.setProductId(resultSet.getInt("product_id"));
                        item.setVariantId(resultSet.getInt("variant_id"));
                        item.setProductName(resultSet.getString("product_name"));
                        item.setSlug(resultSet.getString("slug"));
                        item.setMainImageUrl(resultSet.getString("main_image_url"));
                        item.setProductStatus(resultSet.getString("product_status"));
                        item.setVariantStatus(resultSet.getString("variant_status"));
                        item.setSku(resultSet.getString("sku"));
                        item.setSalePrice(resultSet.getBigDecimal("sale_price"));
                        item.setStockQuantity(resultSet.getInt("stock_quantity"));
                        item.setCreatedAt(resultSet.getTimestamp("created_at"));
                        item.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                        item.setAttributeDetails(buildAttributeDetails(
                                resultSet.getString("color"),
                                resultSet.getString("size"),
                                item.getVariantId()));
                        items.add(item);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Could not load wishlist for user " + userId, ex);
        }

        return items;
    }

    public boolean addOrUpdateProduct(int userId, int productId, Integer variantId) {
        Connection connection = null;

        try {
            connection = DBConnection.getConnection();
            if (connection == null) {
                return false;
            }

            connection.setAutoCommit(false);

            if (!isActiveProduct(connection, productId)) {
                connection.rollback();
                return false;
            }

            Integer selectedVariantId = variantId;
            if (selectedVariantId == null || selectedVariantId <= 0) {
                selectedVariantId = findFirstActiveVariantId(connection, productId);
            } else if (!isActiveVariantForProduct(connection, productId, selectedVariantId)) {
                connection.rollback();
                return false;
            }

            String updateSql = "UPDATE Wishlist SET variant_id = ?, updated_at = GETDATE() "
                    + "WHERE user_id = ? AND product_id = ?";
            int affectedRows;

            try (PreparedStatement update = connection.prepareStatement(updateSql)) {
                setNullableInt(update, 1, selectedVariantId);
                update.setInt(2, userId);
                update.setInt(3, productId);
                affectedRows = update.executeUpdate();
            }

            if (affectedRows == 0) {
                String insertSql = "INSERT INTO Wishlist "
                        + "(user_id, product_id, variant_id, created_at, updated_at) "
                        + "VALUES (?, ?, ?, GETDATE(), GETDATE())";

                try (PreparedStatement insert = connection.prepareStatement(insertSql)) {
                    insert.setInt(1, userId);
                    insert.setInt(2, productId);
                    setNullableInt(insert, 3, selectedVariantId);
                    insert.executeUpdate();
                }
            }

            connection.commit();
            return true;
        } catch (SQLException ex) {
            rollbackQuietly(connection);
            LOGGER.log(Level.SEVERE, "Could not add product " + productId + " to wishlist", ex);
            return false;
        } finally {
            restoreAndClose(connection);
        }
    }

    public boolean updateProduct(int userId, int productId, int variantId) {
        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null
                    || !isActiveVariantForProduct(connection, productId, variantId)) {
                return false;
            }

            String sql = "UPDATE Wishlist SET variant_id = ?, updated_at = GETDATE() "
                    + "WHERE user_id = ? AND product_id = ?";

            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, variantId);
                statement.setInt(2, userId);
                statement.setInt(3, productId);
                return statement.executeUpdate() == 1;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Could not update product " + productId + " in wishlist", ex);
            return false;
        }
    }

    public boolean deleteProduct(int userId, int productId) {
        String sql = "DELETE FROM Wishlist WHERE user_id = ? AND product_id = ?";

        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null) {
                return false;
            }

            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, userId);
                statement.setInt(2, productId);
                return statement.executeUpdate() == 1;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Could not delete product " + productId + " from wishlist", ex);
            return false;
        }
    }

    public int countByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM Wishlist WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null) {
                return 0;
            }

            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, userId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    return resultSet.next() ? resultSet.getInt(1) : 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Could not count wishlist products for user " + userId, ex);
            return 0;
        }
    }

    public Set<Integer> findProductIdsByUserId(int userId) {
        Set<Integer> productIds = new HashSet<>();
        String sql = "SELECT product_id FROM Wishlist WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null) {
                return productIds;
            }

            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, userId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        productIds.add(resultSet.getInt("product_id"));
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Could not load wishlist product ids for user " + userId, ex);
        }

        return productIds;
    }

    private boolean isActiveProduct(Connection connection, int productId) throws SQLException {
        String sql = "SELECT 1 FROM Product WHERE id = ? AND status = 'ACTIVE'";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private boolean isActiveVariantForProduct(Connection connection, int productId, int variantId)
            throws SQLException {
        if (variantId <= 0) {
            return false;
        }

        String sql = "SELECT 1 FROM Product_Variant "
                + "WHERE id = ? AND product_id = ? AND status = 'ACTIVE'";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            statement.setInt(2, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private Integer findFirstActiveVariantId(Connection connection, int productId) throws SQLException {
        String sql = "SELECT TOP 1 id FROM Product_Variant "
                + "WHERE product_id = ? AND status = 'ACTIVE' ORDER BY id";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt("id") : null;
            }
        }
    }

    private String buildAttributeDetails(String color, String size, int variantId) {
        StringBuilder details = new StringBuilder();

        if (color != null && !color.trim().isEmpty()) {
            details.append("Color: ").append(color.trim());
        }
        if (size != null && !size.trim().isEmpty()) {
            if (details.length() > 0) {
                details.append(" / ");
            }
            details.append("Size: ").append(size.trim());
        }

        if (details.length() > 0) {
            return details.toString();
        }
        return variantId > 0 ? "Standard" : "No variant selected";
    }

    private void setNullableInt(PreparedStatement statement, int index, Integer value)
            throws SQLException {
        if (value == null) {
            statement.setNull(index, Types.INTEGER);
        } else {
            statement.setInt(index, value);
        }
    }

    private void rollbackQuietly(Connection connection) {
        if (connection == null) {
            return;
        }

        try {
            connection.rollback();
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Could not roll back wishlist transaction", ex);
        }
    }

    private void restoreAndClose(Connection connection) {
        if (connection == null) {
            return;
        }

        try {
            connection.setAutoCommit(true);
        } catch (SQLException ex) {
            LOGGER.log(Level.FINE, "Could not restore auto-commit", ex);
        } finally {
            DBConnection.closeConnection(connection);
        }
    }
}
