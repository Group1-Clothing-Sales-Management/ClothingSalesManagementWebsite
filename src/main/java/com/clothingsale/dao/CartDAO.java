package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

public class CartDAO {

    private static final String SELECT_CART_SQL =
            "SELECT c.variant_id, c.quantity, "
            + "pv.product_id, pv.sale_price, "
            + "p.product_name, "
            + "COALESCE(variant_img.image_url, product_img.image_url) AS main_image, "
            + "pv.color, pv.size "
            + "FROM Cart c "
            + "INNER JOIN Product_Variant pv "
            + "ON c.variant_id = pv.id "
            + "INNER JOIN Product p "
            + "ON pv.product_id = p.id "
            + "OUTER APPLY ("
            + "    SELECT TOP 1 pi.image_url "
            + "    FROM Product_Image pi "
            + "    WHERE pi.product_id = pv.product_id "
            + "    AND pi.variant_id = pv.id "
            + "    ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
            + ") variant_img "
            + "OUTER APPLY ("
            + "    SELECT TOP 1 pi.image_url "
            + "    FROM Product_Image pi "
            + "    WHERE pi.product_id = p.id "
            + "    AND pi.variant_id IS NULL "
            + "    ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
            + ") product_img "
            + "WHERE c.user_id = ?";

    private static final String DELETE_CART_SQL =
            "DELETE FROM Cart WHERE user_id = ?";

    private static final String INSERT_CART_SQL =
            "INSERT INTO Cart (user_id, variant_id, quantity) VALUES (?, ?, ?)";

    private static final String CHECK_STOCK_SQL =
            "SELECT pv.stock_quantity "
            + "FROM Product_Variant pv "
            + "JOIN Product p ON pv.product_id = p.id "
            + "WHERE pv.id = ? "
            + "AND pv.status = 'ACTIVE' "
            + "AND p.status = 'ACTIVE'";

    private static final String SELECT_ACTIVE_VARIANT_FOR_CART_SQL =
            "SELECT pv.id AS variant_id, "
            + "pv.product_id, pv.sale_price, pv.stock_quantity, "
            + "p.product_name, "
            + "COALESCE(variant_img.image_url, product_img.image_url) AS main_image, "
            + "pv.color, pv.size "
            + "FROM Product_Variant pv "
            + "INNER JOIN Product p "
            + "ON pv.product_id = p.id "
            + "OUTER APPLY ("
            + "    SELECT TOP 1 pi.image_url "
            + "    FROM Product_Image pi "
            + "    WHERE pi.product_id = pv.product_id "
            + "    AND pi.variant_id = pv.id "
            + "    ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
            + ") variant_img "
            + "OUTER APPLY ("
            + "    SELECT TOP 1 pi.image_url "
            + "    FROM Product_Image pi "
            + "    WHERE pi.product_id = p.id "
            + "    AND pi.variant_id IS NULL "
            + "    ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
            + ") product_img "
            + "WHERE pv.id = ? "
            + "AND pv.status = 'ACTIVE' "
            + "AND p.status = 'ACTIVE' "
            + "AND ISNULL(pv.sale_price, 0) > 0";

    public Map<Integer, CartItem> loadCart(int userId) {

        Map<Integer, CartItem> result = new HashMap<>();

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                return result;
            }

            try (PreparedStatement ps = conn.prepareStatement(SELECT_CART_SQL)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {

                        int variantId = rs.getInt("variant_id");
                        int quantity = rs.getInt("quantity");
                        int productId = rs.getInt("product_id");

                        BigDecimal price = rs.getBigDecimal("sale_price");
                        String productName = rs.getString("product_name");
                        String imageUrl = rs.getString("main_image");
                        String color = rs.getString("color");
                        String size = rs.getString("size");
                        StringBuilder attributes = new StringBuilder();
                        if (color != null && !color.trim().isEmpty()) {
                            attributes.append("Color: ").append(color.trim());
                        }
                        if (size != null && !size.trim().isEmpty()) {
                            if (attributes.length() > 0) {
                                attributes.append(" / ");
                            }
                            attributes.append("Size: ").append(size.trim());
                        }

                        CartItem item = new CartItem();

                        item.setVariantId(variantId);
                        item.setProductId(productId);
                        item.setProductName(
                                productName != null ? productName : "");
                        item.setPrice(
                                price != null ? price : BigDecimal.ZERO);
                        item.setQuantity(quantity);
                        item.setImageUrl(imageUrl);
                        item.setColor(color);
                        item.setSize(size);
                        item.setAttributes(
                                attributes.length() > 0 ? attributes.toString() : "Standard");

                        result.put(variantId, item);
                    }
                }
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        return result;
    }

    public boolean saveCart(int userId, Map<Integer, CartItem> cart) {

        if (cart == null) {
            return false;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            try {

                try (PreparedStatement del =
                        conn.prepareStatement(DELETE_CART_SQL)) {

                    del.setInt(1, userId);
                    del.executeUpdate();
                }

                try (PreparedStatement ins =
                        conn.prepareStatement(INSERT_CART_SQL)) {

                    for (CartItem item : cart.values()) {

                        if (item == null) {
                            continue;
                        }

                        int qty = item.getQuantity();

                        if (qty <= 0) {
                            continue;
                        }

                        ins.setInt(1, userId);
                        ins.setInt(2, item.getVariantId());
                        ins.setInt(3, qty);

                        ins.addBatch();
                    }

                    ins.executeBatch();
                }

                conn.commit();
                return true;

            } catch (SQLException ex) {

                conn.rollback();
                throw ex;
            }

        } catch (SQLException ex) {

            ex.printStackTrace();
            return false;
        }
    }

    public boolean clearCart(int userId) {

        Connection conn = null;

        try {

            conn = DBConnection.getConnection();

            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps =
                    conn.prepareStatement(DELETE_CART_SQL)) {

                ps.setInt(1, userId);

                return ps.executeUpdate() > 0;
            }

        } catch (SQLException ex) {

            ex.printStackTrace();
            return false;

        } finally {

            DBConnection.closeConnection(conn);
        }
    }

    public int getAvailableStock(int variantId) {

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                return 0;
            }

            try (PreparedStatement ps =
                    conn.prepareStatement(CHECK_STOCK_SQL)) {

                ps.setInt(1, variantId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        return rs.getInt("stock_quantity");
                    }
                }
            }

        } catch (SQLException ex) {

            ex.printStackTrace();
        }

        return 0;
    }

    public Map<Integer, Integer> getAvailableStockByVariantIds(Collection<Integer> variantIds) {
        Map<Integer, Integer> stocks = new HashMap<>();
        List<Integer> cleanVariantIds = new ArrayList<>();

        if (variantIds != null) {
            for (Integer variantId : variantIds) {
                if (variantId != null && variantId > 0 && !cleanVariantIds.contains(variantId)) {
                    cleanVariantIds.add(variantId);
                }
            }
        }

        if (cleanVariantIds.isEmpty()) {
            return stocks;
        }

        String sql = "SELECT pv.id, pv.stock_quantity "
                + "FROM Product_Variant pv "
                + "JOIN Product p ON pv.product_id = p.id "
                + "WHERE pv.id IN (" + placeholders(cleanVariantIds.size()) + ") "
                + "AND pv.status = 'ACTIVE' "
                + "AND p.status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return stocks;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < cleanVariantIds.size(); i++) {
                    ps.setInt(i + 1, cleanVariantIds.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        stocks.put(rs.getInt("id"), rs.getInt("stock_quantity"));
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        return stocks;
    }

    public boolean isProductAvailable(int variantId) {
        return getAvailableStock(variantId) > 0;
    }

    public CartItem getActiveVariantCartItem(int variantId) {

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps =
                    conn.prepareStatement(SELECT_ACTIVE_VARIANT_FOR_CART_SQL)) {

                ps.setInt(1, variantId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        CartItem item = new CartItem();

                        item.setVariantId(rs.getInt("variant_id"));
                        item.setProductId(rs.getInt("product_id"));
                        item.setProductName(rs.getString("product_name"));
                        item.setPrice(
                                rs.getBigDecimal("sale_price") != null
                                ? rs.getBigDecimal("sale_price")
                                : BigDecimal.ZERO);
                        item.setImageUrl(rs.getString("main_image"));
                        item.setColor(rs.getString("color"));
                        item.setSize(rs.getString("size"));
                        item.setAttributes(buildAttributes(
                                rs.getString("color"),
                                rs.getString("size")));

                        return item;
                    }
                }
            }

        } catch (SQLException ex) {

            ex.printStackTrace();
        }

        return null;
    }

    private String buildAttributes(String color, String size) {
        StringBuilder attributes = new StringBuilder();

        if (color != null && !color.trim().isEmpty()) {
            attributes.append("Color: ").append(color.trim());
        }

        if (size != null && !size.trim().isEmpty()) {
            if (attributes.length() > 0) {
                attributes.append(" / ");
            }
            attributes.append("Size: ").append(size.trim());
        }

        return attributes.length() > 0 ? attributes.toString() : "Standard";
    }

    private String placeholders(int count) {
        StringJoiner joiner = new StringJoiner(",");
        for (int i = 0; i < count; i++) {
            joiner.add("?");
        }
        return joiner.toString();
    }
}