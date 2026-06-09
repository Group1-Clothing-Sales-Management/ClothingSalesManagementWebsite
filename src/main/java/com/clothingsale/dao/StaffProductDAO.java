package com.clothingsale.dao;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class StaffProductDAO {

    public List<StaffProductModel> getAllProductsFromDB() throws Exception {
        List<StaffProductModel> list = new ArrayList<>();
        String sql = "SELECT p.id, pv.id AS variant_id, p.product_name, b.brand_name, " +
                "c.category_name, pv.sku, pv.cost_price, pv.sale_price, " +
                "pv.stock_quantity, pv.status, " +
                "MAX(CASE WHEN a.attribute_name = 'Color' THEN vav.attribute_value END) AS color, " +
                "MAX(CASE WHEN a.attribute_name = 'Size'  THEN vav.attribute_value END) AS size " +
                "FROM Product p " +
                "JOIN Product_Variant pv       ON p.id = pv.product_id " +
                "JOIN Brand b                  ON p.brand_id = b.id " +
                "JOIN Category c               ON p.category_id = c.id " +
                "LEFT JOIN Variant_Attribute_Value vav ON pv.id = vav.variant_id " +
                "LEFT JOIN Attribute a          ON vav.attribute_id = a.id " +
                "GROUP BY p.id, pv.id, p.product_name, b.brand_name, c.category_name, " +
                "         pv.sku, pv.cost_price, pv.sale_price, pv.stock_quantity, pv.status";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StaffProductModel model = new StaffProductModel(
                        rs.getInt("id"),
                        rs.getInt("variant_id"),
                        rs.getString("product_name"),
                        rs.getString("brand_name"),
                        rs.getString("category_name"),
                        rs.getString("sku"),
                        rs.getBigDecimal("cost_price"),
                        rs.getBigDecimal("sale_price"),
                        rs.getInt("stock_quantity"),
                        rs.getString("status"),
                        rs.getString("color"),
                        rs.getString("size"));
                list.add(model);
            }
        }
        return list;
    }

    public boolean updateProductInDB(String sku, String newName, BigDecimal newSalePrice)
            throws Exception {
        String updateVariantSql = "UPDATE Product_Variant " +
                "SET sale_price = ? " +
                "WHERE sku = ?";
        String updateProductSql = "UPDATE Product SET product_name = ? " +
                "WHERE id = (SELECT product_id FROM Product_Variant WHERE sku = ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement psV = conn.prepareStatement(updateVariantSql)) {
                    psV.setBigDecimal(1, newSalePrice);
                    psV.setString(2, sku);
                    psV.executeUpdate();
                }

                try (PreparedStatement psP = conn.prepareStatement(updateProductSql)) {
                    psP.setString(1, newName);
                    psP.setString(2, sku);
                    psP.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void saveInventoryLog(int variantId, int changeQuantity, String staffUsername, String note)
            throws Exception {
        String sql = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) " +
                "VALUES (?, (SELECT id FROM [User] WHERE username = ?), ?, 'IMPORT', ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.setString(2, staffUsername);
            ps.setInt(3, changeQuantity);
            ps.setString(4, note);
            ps.executeUpdate();
        }
    }
}