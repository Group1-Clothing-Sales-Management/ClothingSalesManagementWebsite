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
                "pv.stock_quantity, pv.status, pv.color, pv.size " +
                "FROM Product p " +
                "JOIN Product_Variant pv       ON p.id = pv.product_id " +
                "JOIN Brand b                  ON p.brand_id = b.id " +
                "JOIN Category c               ON p.category_id = c.id";

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
    public boolean updateProductInDB(String currentSku, String newSku,
            String newColor, String newSize)
            throws Exception {
        String updateVariantSql = "UPDATE Product_Variant SET sku = ?, color = ?, size = ? WHERE sku = ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psVariant = conn.prepareStatement(updateVariantSql)) {
                psVariant.setString(1, newSku);
                psVariant.setString(2, blankToNull(newColor));
                psVariant.setString(3, blankToNull(newSize));
                psVariant.setString(4, currentSku);
                return psVariant.executeUpdate() > 0;
            }
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
