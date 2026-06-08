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

    // Lấy dữ liệu sản phẩm kết hợp biến thể (Thỏa mãn Normal Flow - Bước 3)
    public List<StaffProductModel> getAllProductsFromDB() throws Exception {
        List<StaffProductModel> list = new ArrayList<>();
        String sql = "SELECT p.id, pv.id AS variant_id, p.product_name, b.brand_name, " +
                "pv.sku, pv.cost_price, pv.sale_price, pv.stock_quantity, pv.status " +
                "FROM Product p " +
                "JOIN Product_Variant pv ON p.id = pv.product_id " +
                "JOIN Brand b ON p.brand_id = b.id";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StaffProductModel model = new StaffProductModel(
                        rs.getInt("id"),
                        rs.getInt("variant_id"),
                        rs.getString("product_name"),
                        rs.getString("brand_name"),
                        rs.getString("sku"),
                        rs.getBigDecimal("cost_price"),
                        rs.getBigDecimal("sale_price"),
                        rs.getInt("stock_quantity"),
                        rs.getString("status"));
                list.add(model);
            }
        }
        return list;
    }

    // Cập nhật thông tin chi tiết (Thỏa mãn Postconditions & UC-02.1)
    public boolean updateProductInDB(String sku, String newName, BigDecimal newSalePrice, int newStock)
            throws Exception {
        String updateVariantSql = "UPDATE Product_Variant SET sale_price = ?, stock_quantity = ?, status = ? WHERE sku = ?";
        String updateProductSql = "UPDATE Product SET product_name = ? WHERE id = (SELECT product_id FROM Product_Variant WHERE sku = ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bật Transaction hóa an toàn hệ thống

            try (PreparedStatement psV = conn.prepareStatement(updateVariantSql)) {
                psV.setBigDecimal(1, newSalePrice);
                psV.setInt(2, newStock);
                psV.setString(3, newStock == 0 ? "INACTIVE" : "ACTIVE");
                psV.setString(4, sku);
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
            return false;
        }
    }

    // BR3: Lưu vết hoạt động đổi dữ liệu vào bảng Log kho kèm mã nhân viên
    public void saveInventoryLog(int variantId, String staffName, String note) throws Exception {
        String sql = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) " +
                "VALUES (?, (SELECT id FROM [User] WHERE username = ?), 0, 'IMPORT', ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.setString(2, staffName);
            ps.setString(3, note);
            ps.executeUpdate();
        }
    }
}