package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class CartDAO {

    private static final String SELECT_CART_SQL =
            "SELECT c.variant_id, c.quantity, pv.product_id, pv.sale_price, "
            + "p.product_name, img.image_url AS main_image "
            + "FROM Cart c "
            + "LEFT JOIN Product_Variant pv ON c.variant_id = pv.id "
            + "LEFT JOIN Product p ON pv.product_id = p.id "
            + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
            + "WHERE c.user_id = ?";

    private static final String DELETE_CART_SQL =
            "DELETE FROM Cart WHERE user_id = ?";

    private static final String INSERT_CART_SQL =
            "INSERT INTO Cart (user_id, variant_id, quantity) VALUES (?, ?, ?)";

    private static final String CHECK_STOCK_SQL =
            "SELECT stock_quantity "
            + "FROM Product_Variant "
            + "WHERE id = ? AND status = 'ACTIVE'";

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

                        CartItem item = new CartItem();

                        item.setVariantId(variantId);
                        item.setProductId(productId);
                        item.setProductName(
                                productName != null ? productName : "");
                        item.setPrice(
                                price != null ? price : BigDecimal.ZERO);
                        item.setQuantity(quantity);
                        item.setImageUrl(imageUrl);

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

    public boolean isProductAvailable(int variantId) {
        return getAvailableStock(variantId) > 0;
    }
}