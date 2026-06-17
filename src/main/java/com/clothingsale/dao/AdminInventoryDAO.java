package com.clothingsale.dao;

import com.clothingsale.model.ProductBatch;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminInventoryDAO {

    public java.util.List<ProductBatch> adminGetImportHistory() {
        java.util.List<ProductBatch> list = new java.util.ArrayList<>();
        // Câu lệnh JOIN đồng bộ chuẩn xác theo schema.sql: Product_Batch -> Product_Variant -> Product
        String sql = "SELECT pb.id, pb.variant_id, pb.batch_code, pb.cost_price, pb.sale_price, "
                + "pb.initial_quantity, pb.current_quantity, pb.created_at, "
                + "pv.sku, p.product_name "
                + "FROM Product_Batch pb "
                + "JOIN Product_Variant pv ON pb.variant_id = pv.id "
                + "JOIN Product p ON pv.product_id = p.id "
                + "ORDER BY pb.created_at DESC";

        try (Connection conn = com.clothingsale.util.DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); java.sql.ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductBatch batch = new ProductBatch();
                batch.setId(rs.getInt("id"));
                batch.setVariantId(rs.getInt("variant_id"));
                batch.setBatchCode(rs.getString("batch_code"));
                batch.setCostPrice(rs.getBigDecimal("cost_price"));
                batch.setSalePrice(rs.getBigDecimal("sale_price"));
                batch.setInitialQuantity(rs.getInt("initial_quantity"));
                batch.setCurrentQuantity(rs.getInt("current_quantity"));
                batch.setCreatedAt(rs.getTimestamp("created_at"));

                // Ép tạm thông tin Snapshot text vào thuộc tính có sẵn để đẩy ra UI mà không sửa Model gốc
                batch.setBatchCode(rs.getString("batch_code") + "|" + rs.getString("product_name") + " (" + rs.getString("sku") + ")");

                list.add(batch);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Xử lý Transaction an toàn: 1. Chèn bản ghi lô mới vào Product_Batch. 2.
     * Lưu vết biến động vào Inventory_Log. 3. Cộng dồn stock_quantity và cập
     * nhật giá mới tại Product_Variant.
     */
    public boolean adminExecuteStockImport(ProductBatch batch, int adminUserId, String note) {
        Connection conn = null;
        PreparedStatement psBatch = null;
        PreparedStatement psLog = null;
        PreparedStatement psVariant = null;
        boolean isSuccess = false;

        // Khớp chuẩn xác tên bảng và tên cột trong schema.sql
        String insertBatchSQL = "INSERT INTO Product_Batch (variant_id, batch_code, cost_price, sale_price, initial_quantity, current_quantity, created_at) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        String insertLogSQL = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note, created_at) VALUES (?, ?, ?, 'IMPORT', ?, GETDATE())";
        String updateVariantSQL = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ?, cost_price = ?, sale_price = ? WHERE id = ?";

        try {
            conn = com.clothingsale.util.DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Thực thi bảng Product_Batch
            psBatch = conn.prepareStatement(insertBatchSQL);
            psBatch.setInt(1, batch.getVariantId());
            psBatch.setString(2, batch.getBatchCode());
            psBatch.setBigDecimal(3, batch.getCostPrice());
            psBatch.setBigDecimal(4, batch.getSalePrice());
            psBatch.setInt(5, batch.getInitialQuantity());
            psBatch.setInt(6, batch.getInitialQuantity()); // Lô mới: current_quantity = initial_quantity
            psBatch.executeUpdate();

            // 2. Thực thi bảng Inventory_Log
            psLog = conn.prepareStatement(insertLogSQL);
            psLog.setInt(1, batch.getVariantId());
            psLog.setInt(2, adminUserId);
            psLog.setInt(3, batch.getInitialQuantity());
            psLog.setString(4, note);
            psLog.executeUpdate();

            // 3. Thực thi bảng Product_Variant (Cập nhật stock_quantity, cost_price, sale_price theo id)
            psVariant = conn.prepareStatement(updateVariantSQL);
            psVariant.setInt(1, batch.getInitialQuantity());
            psVariant.setBigDecimal(2, batch.getCostPrice());
            psVariant.setBigDecimal(3, batch.getSalePrice());
            psVariant.setInt(4, batch.getVariantId());
            psVariant.executeUpdate();

            conn.commit(); // Hoàn thành chuỗi thao tác đồng bộ
            isSuccess = true;
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
        return isSuccess;
    }

    public List<com.clothingsale.model.ProductVariant> getAllActiveVariantsForImport() {
    List<com.clothingsale.model.ProductVariant> list = new ArrayList<>();
    // Câu lệnh SQL nâng cao kết hợp bảng Product và bóc tách Color/Size tự động từ Variant_Attribute_Value
    String sql = "SELECT pv.id, pv.sku, p.product_name, "
               + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav JOIN Attribute a ON vav.attribute_id = a.id WHERE vav.variant_id = pv.id AND a.attribute_name = 'Color') as color, "
               + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav JOIN Attribute a ON vav.attribute_id = a.id WHERE vav.variant_id = pv.id AND a.attribute_name = 'Size') as size "
               + "FROM Product_Variant pv "
               + "JOIN Product p ON pv.product_id = p.id "
               + "WHERE pv.status <> 'DELETED' AND p.status <> 'DELETED' "
               + "ORDER BY p.product_name ASC";

    try (Connection conn = DBConnection.getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql); 
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            com.clothingsale.model.ProductVariant v = new com.clothingsale.model.ProductVariant();
            v.setId(rs.getInt("id"));
            v.setSku(rs.getString("sku"));
            
            // Xử lý chuỗi thông tin chi tiết Variant trực quan: [Tên sản phẩm] - Color: Red / Size: L
            String prodName = rs.getString("product_name");
            String color = rs.getString("color");
            String size = rs.getString("size");
            StringBuilder sb = new StringBuilder(prodName);
            
            if ((color != null && !color.isEmpty()) || (size != null && !size.isEmpty())) {
                sb.append(" (");
                if (color != null && !color.isEmpty()) sb.append("Color: ").append(color);
                if (size != null && !size.isEmpty()) {
                    if (color != null && !color.isEmpty()) sb.append(" / ");
                    sb.append("Size: ").append(size);
                }
                sb.append(")");
            }
            
            // Mượn tạm trường attributeDetails làm nhãn hiển thị text trên Dropdown UI
            v.setAttributeDetails(sb.toString());
            list.add(v);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}

}
