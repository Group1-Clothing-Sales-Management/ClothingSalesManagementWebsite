package com.clothingsale.dao;

import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.clothingsale.model.ProductBatch;

public class InventoryDAO {

    public boolean importGoods(ProductBatch batch, int userId, String note) {
        Connection conn = null;
        PreparedStatement psBatch = null;
        PreparedStatement psLog = null;
        PreparedStatement psVariant = null;
        boolean success = false;

        String insertBatchSQL = "INSERT INTO Product_Batch (variant_id, batch_code, cost_price, sale_price, initial_quantity, current_quantity) VALUES (?, ?, ?, ?, ?, ?)";
        String insertLogSQL = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) VALUES (?, ?, ?, 'IMPORT', ?)";
        String updateVariantSQL = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ?, cost_price = ?, sale_price = ? WHERE id = ?";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Kích hoạt Database Transaction

            // 1. Insert vào bảng Product_Batch
            psBatch = conn.prepareStatement(insertBatchSQL);
            psBatch.setInt(1, batch.getVariantId());
            psBatch.setString(2, batch.getBatchCode());
            psBatch.setBigDecimal(3, batch.getCostPrice());
            psBatch.setBigDecimal(4, batch.getSalePrice());
            psBatch.setInt(5, batch.getInitialQuantity());
            psBatch.setInt(6, batch.getInitialQuantity()); // Lúc mới nhập, current_quantity = initial_quantity
            psBatch.executeUpdate();

            // 2. Insert vào bảng Inventory_Log cũ của bạn
            psLog = conn.prepareStatement(insertLogSQL);
            psLog.setInt(1, batch.getVariantId());
            psLog.setInt(2, userId);
            psLog.setInt(3, batch.getInitialQuantity());
            psLog.setString(4, note);
            psLog.executeUpdate();

            // 3. Update lại tổng số lượng và giá mới nhất ở bảng Product_Variant cũ
            psVariant = conn.prepareStatement(updateVariantSQL);
            psVariant.setInt(1, batch.getInitialQuantity());
            psVariant.setBigDecimal(2, batch.getCostPrice());
            psVariant.setBigDecimal(3, batch.getSalePrice());
            psVariant.setInt(4, batch.getVariantId());
            psVariant.executeUpdate();

            conn.commit(); // Thành công toàn bộ -> Commit dữ liệu
            success = true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            try {
                if (psBatch != null) {
                    psBatch.close();
                }
                if (psLog != null) {
                    psLog.close();
                }
                if (psVariant != null) {
                    psVariant.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return success;
    }
}
