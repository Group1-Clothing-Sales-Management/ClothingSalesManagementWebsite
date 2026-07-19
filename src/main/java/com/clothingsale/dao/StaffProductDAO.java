package com.clothingsale.dao;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

    /**
     * Staff can update only the selected variant's color and size.
     * Product name is deliberately not part of this update.
     */
    public boolean updateProductInDB(String sku, String newColor, String newSize)
            throws Exception {
        String updateVariantSql = "UPDATE Product_Variant SET color = ?, size = ? WHERE sku = ?";
        String upsertAttrSql = "MERGE INTO Variant_Attribute_Value AS target " +
                "USING (SELECT pv.id AS vid, a.id AS aid " +
                "       FROM Product_Variant pv " +
                "       JOIN Attribute a ON a.attribute_name = ? " +
                "       WHERE pv.sku = ?) AS src " +
                "ON target.variant_id = src.vid AND target.attribute_id = src.aid " +
                "WHEN MATCHED THEN " +
                "    UPDATE SET target.attribute_value = ? " +
                "WHEN NOT MATCHED THEN " +
                "    INSERT (variant_id, attribute_id, attribute_value) " +
                "    VALUES (src.vid, src.aid, ?);";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updatedRows;
                try (PreparedStatement psVariant = conn.prepareStatement(updateVariantSql)) {
                    psVariant.setString(1, blankToNull(newColor));
                    psVariant.setString(2, blankToNull(newSize));
                    psVariant.setString(3, sku);
                    updatedRows = psVariant.executeUpdate();
                }

                if (updatedRows == 0) {
                    conn.rollback();
                    return false;
                }

                updateAttribute(conn, upsertAttrSql, sku, "Color", newColor);
                updateAttribute(conn, upsertAttrSql, sku, "Size", newSize);

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private void updateAttribute(Connection conn, String upsertAttrSql, String sku,
            String attributeName, String value) throws Exception {
        if (value == null || value.trim().isEmpty()) {
            String deleteSql = "DELETE target FROM Variant_Attribute_Value target "
                    + "JOIN Product_Variant pv ON pv.id = target.variant_id "
                    + "JOIN Attribute a ON a.id = target.attribute_id "
                    + "WHERE pv.sku = ? AND a.attribute_name = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, sku);
                ps.setString(2, attributeName);
                ps.executeUpdate();
            }
            return;
        }

        try (PreparedStatement ps = conn.prepareStatement(upsertAttrSql)) {
            ps.setString(1, attributeName);
            ps.setString(2, sku);
            ps.setString(3, value.trim());
            ps.setString(4, value.trim());
            ps.executeUpdate();
        }
    }

    private String blankToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
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
