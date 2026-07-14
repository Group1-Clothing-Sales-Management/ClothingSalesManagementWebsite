package com.clothingsale.dao;

import com.clothingsale.model.PriceHistory;
import com.clothingsale.model.PriceManagementItem;
import com.clothingsale.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class AdminPriceDAO {

    /**
     * Lấy danh sách giá theo keyword và trạng thái giá.
     *
     * priceStatus: ALL UNPRICED BELOW_COST DISCOUNTED REGULAR
     */
    public List<PriceManagementItem> searchPrices(
            String keyword,
            String priceStatus
    ) {
        List<PriceManagementItem> priceItems
                = new ArrayList<>();

        StringBuilder sql = new StringBuilder();

        sql.append(
                "SELECT "
                + "pv.id AS variant_id, "
                + "pv.product_id, "
                + "p.product_name, "
                + "pv.sku, "
                + "pv.color, "
                + "pv.size, "
                + "pv.cost_price, "
                + "pv.list_price, "
                + "pv.sale_price, "
                + "pv.stock_quantity, "
                + "pv.status AS variant_status, "
                + "p.status AS product_status, "
                + "pv.price_updated_at, "
                + "pv.price_updated_by, "
                + "u.full_name AS price_updated_by_name "
                + "FROM Product_Variant pv "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "LEFT JOIN [User] u "
                + "ON u.id = pv.price_updated_by "
                + "WHERE 1 = 1 "
                + "AND ISNULL(p.status, '') <> 'DELETED' "
                + "AND ISNULL(pv.status, '') <> 'DELETED' "
        );

        List<Object> parameters = new ArrayList<>();

        String normalizedKeyword = trimToNull(keyword);

        if (normalizedKeyword != null) {
            sql.append(
                    "AND ("
                    + "p.product_name LIKE ? "
                    + "OR pv.sku LIKE ? "
                    + "OR pv.color LIKE ? "
                    + "OR pv.size LIKE ?"
                    + ") "
            );

            String searchValue
                    = "%" + normalizedKeyword + "%";

            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
        }

        String normalizedPriceStatus
                = normalizePriceStatus(priceStatus);

        if ("UNPRICED".equals(normalizedPriceStatus)) {
            sql.append(
                    "AND ("
                    + "pv.list_price IS NULL "
                    + "OR pv.sale_price IS NULL "
                    + "OR pv.list_price <= 0 "
                    + "OR pv.sale_price <= 0"
                    + ") "
            );

        } else if ("BELOW_COST".equals(
                normalizedPriceStatus
        )) {
            sql.append(
                    "AND pv.sale_price > 0 "
                    + "AND pv.sale_price < pv.cost_price "
            );

        } else if ("DISCOUNTED".equals(
                normalizedPriceStatus
        )) {
            sql.append(
                    "AND pv.list_price > 0 "
                    + "AND pv.sale_price > 0 "
                    + "AND pv.sale_price < pv.list_price "
            );

        } else if ("REGULAR".equals(
                normalizedPriceStatus
        )) {
            sql.append(
                    "AND pv.list_price > 0 "
                    + "AND pv.sale_price > 0 "
                    + "AND pv.sale_price = pv.list_price "
                    + "AND pv.sale_price >= pv.cost_price "
            );
        }

        sql.append(
                "ORDER BY "
                + "p.product_name ASC, "
                + "pv.size ASC, "
                + "pv.color ASC, "
                + "pv.id ASC"
        );

        try (
                Connection connection = requireConnection(); PreparedStatement statement
                = connection.prepareStatement(
                        sql.toString()
                )) {
            bindParameters(statement, parameters);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                while (resultSet.next()) {
                    priceItems.add(
                            mapPriceManagementItem(resultSet)
                    );
                }
            }

        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load the price list.",
                    exception
            );
        }

        return priceItems;
    }

    /**
     * Lấy một variant để hiển thị form cập nhật giá.
     */
    public PriceManagementItem getPriceByVariantId(
            int variantId
    ) {
        String sql
                = "SELECT "
                + "pv.id AS variant_id, "
                + "pv.product_id, "
                + "p.product_name, "
                + "pv.sku, "
                + "pv.color, "
                + "pv.size, "
                + "pv.cost_price, "
                + "pv.list_price, "
                + "pv.sale_price, "
                + "pv.stock_quantity, "
                + "pv.status AS variant_status, "
                + "p.status AS product_status, "
                + "pv.price_updated_at, "
                + "pv.price_updated_by, "
                + "u.full_name AS price_updated_by_name "
                + "FROM Product_Variant pv "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "LEFT JOIN [User] u "
                + "ON u.id = pv.price_updated_by "
                + "WHERE pv.id = ?";

        try (
                Connection connection = requireConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapPriceManagementItem(resultSet);
                }
            }

        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load the product price.",
                    exception
            );
        }

        return null;
    }

    /**
     * Lấy lịch sử thay đổi giá của một variant.
     */
    public List<PriceHistory> getPriceHistory(
            int variantId
    ) {
        List<PriceHistory> priceHistories
                = new ArrayList<>();

        String sql
                = "SELECT "
                + "id, "
                + "variant_id, "
                + "product_name_snapshot, "
                + "sku_snapshot, "
                + "color_snapshot, "
                + "size_snapshot, "
                + "old_list_price, "
                + "new_list_price, "
                + "old_sale_price, "
                + "new_sale_price, "
                + "cost_price_snapshot, "
                + "change_type, "
                + "change_reason, "
                + "changed_by, "
                + "changed_by_name_snapshot, "
                + "changed_at "
                + "FROM Product_Variant_Price_History "
                + "WHERE variant_id = ? "
                + "ORDER BY changed_at DESC, id DESC";

        try (
                Connection connection = requireConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                while (resultSet.next()) {
                    priceHistories.add(
                            mapPriceHistory(resultSet)
                    );
                }
            }

        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load the price history.",
                    exception
            );
        }

        return priceHistories;
    }

    /**
     * Cập nhật list_price và sale_price.
     *
     * Việc UPDATE và INSERT history được thực hiện trong cùng một transaction.
     */
    public boolean updatePrice(
            int variantId,
            BigDecimal newListPrice,
            BigDecimal newSalePrice,
            String reason,
            int changedByUserId
    ) {
        Connection connection = null;

        try {
            connection = requireConnection();

            connection.setTransactionIsolation(
                    Connection.TRANSACTION_SERIALIZABLE
            );
            connection.setAutoCommit(false);

            String changedByName
                    = getAdminName(
                            connection,
                            changedByUserId
                    );

            LockedPriceData currentPrice
                    = lockAndGetCurrentPrice(
                            connection,
                            variantId
                    );

            validateVariantForUpdate(currentPrice);
            if (newSalePrice.compareTo(currentPrice.costPrice) < 0 && trimToNull(reason) == null) {
                throw new IllegalArgumentException("A reason is required when the sale price is below cost.");
            }
            boolean sameListPrice
                    = currentPrice.listPrice.compareTo(
                            newListPrice
                    ) == 0;

            boolean sameSalePrice
                    = currentPrice.salePrice.compareTo(
                            newSalePrice
                    ) == 0;

            if (sameListPrice && sameSalePrice) {
                connection.rollback();
                return false;
            }

            updateVariantPrice(
                    connection,
                    variantId,
                    newListPrice,
                    newSalePrice,
                    changedByUserId
            );

            insertPriceHistory(
                    connection,
                    variantId,
                    currentPrice,
                    newListPrice,
                    newSalePrice,
                    reason,
                    changedByUserId,
                    changedByName
            );

            connection.commit();
            return true;

        } catch (SQLException exception) {
            rollbackQuietly(connection);

            throw new IllegalStateException(
                    "Unable to update the product price.",
                    exception
            );

        } catch (RuntimeException exception) {
            rollbackQuietly(connection);
            throw exception;

        } finally {
            closeQuietly(connection);
        }
    }

    private String getAdminName(
            Connection connection,
            int userId
    ) throws SQLException {
        String sql
                = "SELECT u.full_name "
                + "FROM [User] u "
                + "INNER JOIN Role r "
                + "ON r.id = u.role_id "
                + "WHERE u.id = ? "
                + "AND u.status = 'ACTIVE' "
                + "AND r.role_name = 'ADMIN'";

        try (
                PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new IllegalArgumentException(
                            "Only an active admin can "
                            + "update product prices."
                    );
                }

                return resultSet.getString("full_name");
            }
        }
    }

    /**
     * Lock variant để tránh hai admin cập nhật cùng một giá tại cùng thời điểm.
     */
    private LockedPriceData lockAndGetCurrentPrice(
            Connection connection,
            int variantId
    ) throws SQLException {
        String sql
                = "SELECT "
                + "pv.id, "
                + "pv.sku, "
                + "pv.color, "
                + "pv.size, "
                + "pv.cost_price, "
                + "pv.list_price, "
                + "pv.sale_price, "
                + "pv.status AS variant_status, "
                + "p.product_name, "
                + "p.status AS product_status "
                + "FROM Product_Variant pv "
                + "WITH (UPDLOCK, HOLDLOCK) "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "WHERE pv.id = ?";

        try (
                PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new IllegalArgumentException(
                            "Product variant does not exist."
                    );
                }

                LockedPriceData priceData
                        = new LockedPriceData();

                priceData.productName
                        = resultSet.getString(
                                "product_name"
                        );

                priceData.sku
                        = resultSet.getString("sku");

                priceData.color
                        = resultSet.getString("color");

                priceData.size
                        = resultSet.getString("size");

                priceData.costPrice
                        = safeMoney(
                                resultSet.getBigDecimal(
                                        "cost_price"
                                )
                        );

                priceData.listPrice
                        = safeMoney(
                                resultSet.getBigDecimal(
                                        "list_price"
                                )
                        );

                priceData.salePrice
                        = safeMoney(
                                resultSet.getBigDecimal(
                                        "sale_price"
                                )
                        );

                priceData.variantStatus
                        = resultSet.getString(
                                "variant_status"
                        );

                priceData.productStatus
                        = resultSet.getString(
                                "product_status"
                        );

                return priceData;
            }
        }
    }

    private void validateVariantForUpdate(
            LockedPriceData priceData
    ) {
        if (priceData == null) {
            throw new IllegalArgumentException(
                    "Product variant does not exist."
            );
        }

        if ("DELETED".equalsIgnoreCase(
                priceData.variantStatus
        )) {
            throw new IllegalStateException(
                    "The product variant was deleted."
            );
        }

        if ("DELETED".equalsIgnoreCase(
                priceData.productStatus
        )) {
            throw new IllegalStateException(
                    "The product was deleted."
            );
        }
    }

    private void updateVariantPrice(
            Connection connection,
            int variantId,
            BigDecimal newListPrice,
            BigDecimal newSalePrice,
            int changedByUserId
    ) throws SQLException {
        String sql
                = "UPDATE Product_Variant "
                + "SET list_price = ?, "
                + "sale_price = ?, "
                + "price_updated_at = SYSDATETIME(), "
                + "price_updated_by = ? "
                + "WHERE id = ?";

        try (
                PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setBigDecimal(1, newListPrice);
            statement.setBigDecimal(2, newSalePrice);
            statement.setInt(3, changedByUserId);
            statement.setInt(4, variantId);

            int affectedRows = statement.executeUpdate();

            if (affectedRows != 1) {
                throw new SQLException(
                        "The variant price could not be updated."
                );
            }
        }
    }

    private void insertPriceHistory(
            Connection connection,
            int variantId,
            LockedPriceData currentPrice,
            BigDecimal newListPrice,
            BigDecimal newSalePrice,
            String reason,
            int changedByUserId,
            String changedByName
    ) throws SQLException {
        String sql
                = "INSERT INTO "
                + "Product_Variant_Price_History ("
                + "variant_id, "
                + "product_name_snapshot, "
                + "sku_snapshot, "
                + "color_snapshot, "
                + "size_snapshot, "
                + "old_list_price, "
                + "new_list_price, "
                + "old_sale_price, "
                + "new_sale_price, "
                + "cost_price_snapshot, "
                + "change_type, "
                + "change_reason, "
                + "changed_by, "
                + "changed_by_name_snapshot, "
                + "changed_at"
                + ") VALUES ("
                + "?, ?, ?, ?, ?, "
                + "?, ?, ?, ?, ?, "
                + "'MANUAL_UPDATE', ?, ?, ?, "
                + "SYSDATETIME()"
                + ")";

        try (
                PreparedStatement statement
                = connection.prepareStatement(sql)) {
            int parameterIndex = 1;

            statement.setInt(
                    parameterIndex++,
                    variantId
            );

            statement.setNString(
                    parameterIndex++,
                    currentPrice.productName
            );

            statement.setString(
                    parameterIndex++,
                    currentPrice.sku
            );

            setNullableNString(
                    statement,
                    parameterIndex++,
                    currentPrice.color
            );

            setNullableNString(
                    statement,
                    parameterIndex++,
                    currentPrice.size
            );

            statement.setBigDecimal(
                    parameterIndex++,
                    currentPrice.listPrice
            );

            statement.setBigDecimal(
                    parameterIndex++,
                    newListPrice
            );

            statement.setBigDecimal(
                    parameterIndex++,
                    currentPrice.salePrice
            );

            statement.setBigDecimal(
                    parameterIndex++,
                    newSalePrice
            );

            statement.setBigDecimal(
                    parameterIndex++,
                    currentPrice.costPrice
            );

            setNullableNString(
                    statement,
                    parameterIndex++,
                    trimToNull(reason)
            );

            statement.setInt(
                    parameterIndex++,
                    changedByUserId
            );

            statement.setNString(
                    parameterIndex,
                    changedByName
            );

            int affectedRows = statement.executeUpdate();

            if (affectedRows != 1) {
                throw new SQLException(
                        "Price history could not be saved."
                );
            }
        }
    }

    private PriceManagementItem mapPriceManagementItem(
            ResultSet resultSet
    ) throws SQLException {
        PriceManagementItem item
                = new PriceManagementItem();

        item.setVariantId(
                resultSet.getInt("variant_id")
        );

        item.setProductId(
                resultSet.getInt("product_id")
        );

        item.setProductName(
                resultSet.getString("product_name")
        );

        item.setSku(
                resultSet.getString("sku")
        );

        item.setColor(
                resultSet.getString("color")
        );

        item.setSize(
                resultSet.getString("size")
        );

        item.setCostPrice(
                safeMoney(
                        resultSet.getBigDecimal(
                                "cost_price"
                        )
                )
        );

        item.setListPrice(
                safeMoney(
                        resultSet.getBigDecimal(
                                "list_price"
                        )
                )
        );

        item.setSalePrice(
                safeMoney(
                        resultSet.getBigDecimal(
                                "sale_price"
                        )
                )
        );

        item.setStockQuantity(
                resultSet.getInt("stock_quantity")
        );

        item.setVariantStatus(
                resultSet.getString("variant_status")
        );

        item.setProductStatus(
                resultSet.getString("product_status")
        );

        item.setPriceUpdatedAt(
                resultSet.getTimestamp(
                        "price_updated_at"
                )
        );

        int updatedBy
                = resultSet.getInt("price_updated_by");

        if (resultSet.wasNull()) {
            item.setPriceUpdatedBy(null);
        } else {
            item.setPriceUpdatedBy(updatedBy);
        }

        item.setPriceUpdatedByName(
                resultSet.getString(
                        "price_updated_by_name"
                )
        );

        return item;
    }

    private PriceHistory mapPriceHistory(
            ResultSet resultSet
    ) throws SQLException {
        PriceHistory history = new PriceHistory();

        history.setId(
                resultSet.getLong("id")
        );

        int variantId = resultSet.getInt("variant_id");

        if (resultSet.wasNull()) {
            history.setVariantId(null);
        } else {
            history.setVariantId(variantId);
        }

        history.setProductNameSnapshot(
                resultSet.getString("product_name_snapshot")
        );

        history.setSkuSnapshot(resultSet.getString("sku_snapshot"));

        history.setColorSnapshot(resultSet.getString("color_snapshot"));

        history.setSizeSnapshot(
                resultSet.getString(
                        "size_snapshot"
                )
        );

        history.setOldListPrice(
                resultSet.getBigDecimal(
                        "old_list_price"
                )
        );

        history.setNewListPrice(
                resultSet.getBigDecimal(
                        "new_list_price"
                )
        );

        history.setOldSalePrice(
                resultSet.getBigDecimal(
                        "old_sale_price"
                )
        );

        history.setNewSalePrice(
                resultSet.getBigDecimal(
                        "new_sale_price"
                )
        );

        history.setCostPriceSnapshot(
                resultSet.getBigDecimal(
                        "cost_price_snapshot"
                )
        );

        history.setChangeType(
                resultSet.getString("change_type")
        );

        history.setChangeReason(
                resultSet.getString("change_reason")
        );

        int changedBy
                = resultSet.getInt("changed_by");

        if (resultSet.wasNull()) {
            history.setChangedBy(null);
        } else {
            history.setChangedBy(changedBy);
        }

        history.setChangedByNameSnapshot(
                resultSet.getString(
                        "changed_by_name_snapshot"
                )
        );

        history.setChangedAt(
                resultSet.getTimestamp("changed_at")
        );

        return history;
    }

    private void bindParameters(
            PreparedStatement statement,
            List<Object> parameters
    ) throws SQLException {
        for (int index = 0;
                index < parameters.size();
                index++) {
            Object value = parameters.get(index);

            if (value instanceof String) {
                statement.setNString(
                        index + 1,
                        value.toString()
                );
            } else if (value instanceof Integer) {
                statement.setInt(
                        index + 1,
                        (Integer) value
                );
            } else {
                statement.setObject(
                        index + 1,
                        value
                );
            }
        }
    }

    private String normalizePriceStatus(
            String value
    ) {
        String normalized = trimToNull(value);

        if (normalized == null) {
            return "ALL";
        }

        normalized = normalized.toUpperCase(
                Locale.ROOT
        );

        if ("UNPRICED".equals(normalized)
                || "BELOW_COST".equals(normalized)
                || "DISCOUNTED".equals(normalized)
                || "REGULAR".equals(normalized)) {
            return normalized;
        }

        return "ALL";
    }

    private BigDecimal safeMoney(
            BigDecimal value
    ) {
        if (value == null) {
            return BigDecimal.ZERO;
        }

        return value;
    }

    private String trimToNull(
            String value
    ) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim();

        if (normalized.isEmpty()) {
            return null;
        }

        return normalized;
    }

    private void setNullableNString(
            PreparedStatement statement,
            int parameterIndex,
            String value
    ) throws SQLException {
        if (value == null) {
            statement.setNull(
                    parameterIndex,
                    Types.NVARCHAR
            );
        } else {
            statement.setNString(
                    parameterIndex,
                    value
            );
        }
    }

    private Connection requireConnection()
            throws SQLException {
        Connection connection
                = DBConnection.getConnection();

        if (connection == null) {
            throw new SQLException(
                    "Database connection is unavailable."
            );
        }

        return connection;
    }

    private void rollbackQuietly(
            Connection connection
    ) {
        if (connection == null) {
            return;
        }

        try {
            connection.rollback();
        } catch (SQLException ignored) {
            // Giữ nguyên exception gốc.
        }
    }

    private void closeQuietly(
            Connection connection
    ) {
        if (connection == null) {
            return;
        }

        try {
            connection.close();
        } catch (SQLException ignored) {
            // Không làm thay đổi kết quả nghiệp vụ.
        }
    }

    /**
     * Dữ liệu nội bộ dùng trong transaction cập nhật giá.
     */
    private static class LockedPriceData {

        private String productName;
        private String sku;
        private String color;
        private String size;

        private BigDecimal costPrice;
        private BigDecimal listPrice;
        private BigDecimal salePrice;

        private String variantStatus;
        private String productStatus;
    }
}
