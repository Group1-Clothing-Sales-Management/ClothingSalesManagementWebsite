package com.clothingsale.dao;

import com.clothingsale.model.ProductBatch;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.Supplier;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminInventoryDAO {

    /**
     * HÀM XEM LỊCH SỬ NHẬP HÀNG Bổ sung JOIN với Import_Receipt để lấy mã phiếu
     * nhập tổng (receipt_code)
     */
    public List<ProductBatch> adminGetImportHistory() {
        List<ProductBatch> list = new ArrayList<>();
        String sql = "SELECT pb.id, pb.variant_id, pb.batch_code, pb.cost_price, pb.sale_price, "
                + "pb.initial_quantity, pb.current_quantity, pb.created_at, pb.import_receipt_id, "
                + "pv.sku, p.product_name, ir.receipt_code "
                + "FROM Product_Batch pb "
                + "JOIN Product_Variant pv ON pb.variant_id = pv.id "
                + "JOIN Product p ON pv.product_id = p.id "
                + "LEFT JOIN Import_Receipt ir ON pb.import_receipt_id = ir.id "
                + "ORDER BY pb.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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

                // Gắn mã phiếu nhập tổng vào chuỗi hiển thị để Admin dễ theo dõi
                String receiptCode = rs.getString("receipt_code");
                String displayCode = (receiptCode != null) ? receiptCode + " - " + rs.getString("batch_code") : rs.getString("batch_code");

                // Ép thông tin Snapshot text vào thuộc tính có sẵn để đẩy ra UI
                batch.setBatchCode(displayCode + "|" + rs.getString("product_name") + " (" + rs.getString("sku") + ")");

                list.add(batch);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * HÀM LẤY DANH SÁCH BIẾN THỂ ĐỂ PHỤC VỤ FORM NHẬP HÀNG Đã xóa các truy vấn
     * con liên quan đến bảng Variant_Attribute_Value (EAV), Lấy trực tiếp size
     * và color từ Product_Variant
     */
    public List<ProductVariant> getAllActiveVariantsForImport() {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.id, pv.sku, pv.cost_price, pv.sale_price, pv.color, pv.size, p.product_name "
                + "FROM Product_Variant pv "
                + "JOIN Product p ON pv.product_id = p.id "
                + "WHERE pv.status <> 'DELETED' AND p.status <> 'DELETED' "
                + "ORDER BY p.product_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductVariant v = new ProductVariant();
                v.setId(rs.getInt("id"));
                v.setSku(rs.getString("sku"));
                v.setCostPrice(rs.getBigDecimal("cost_price"));
                v.setSalePrice(rs.getBigDecimal("sale_price"));

                String prodName = rs.getString("product_name");
                String color = rs.getString("color");
                String size = rs.getString("size");
                StringBuilder sb = new StringBuilder(prodName);

                // Nối chuỗi Thuộc tính
                if ((color != null && !color.trim().isEmpty()) || (size != null && !size.trim().isEmpty())) {
                    sb.append(" [");
                    if (color != null && !color.trim().isEmpty()) {
                        sb.append("Color: ").append(color);
                    }
                    if (size != null && !size.trim().isEmpty()) {
                        if (color != null && !color.trim().isEmpty()) {
                            sb.append(" | ");
                        }
                        sb.append("Size: ").append(size);
                    }
                    sb.append("]");
                }

                v.setAttributeDetails(sb.toString());
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * XỬ LÝ TRANSACTION NHẬP HÀNG AN TOÀN (NHẬP 1 SẢN PHẨM) Đã bổ sung tham số
     * supplierId và totalAmount để tạo Import_Receipt
     */
    public boolean adminExecuteStockImport(ProductBatch batch, int supplierId, int adminUserId, double totalAmount, String note) {
        Connection conn = null;
        PreparedStatement psReceipt = null;
        PreparedStatement psBatch = null;
        PreparedStatement psLog = null;
        PreparedStatement psVariant = null;
        ResultSet rsKeys = null;
        boolean isSuccess = false;

        String insertReceiptSQL = "INSERT INTO Import_Receipt (receipt_code, supplier_id, user_id, total_amount, status) VALUES (?, ?, ?, ?, 'COMPLETED')";
        String insertBatchSQL = "INSERT INTO Product_Batch (variant_id, batch_code, cost_price, sale_price, initial_quantity, current_quantity, import_receipt_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        String insertLogSQL = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note, created_at) VALUES (?, ?, ?, 'IMPORT', ?, GETDATE())";
        String updateVariantSQL = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ?, cost_price = ?, sale_price = ? WHERE id = ?";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Kích hoạt Transaction

            // 1. Tạo Phiếu Nhập Tổng (Master)
            psReceipt = conn.prepareStatement(insertReceiptSQL, Statement.RETURN_GENERATED_KEYS);
            String receiptCode = "RC-" + System.currentTimeMillis();
            psReceipt.setString(1, receiptCode);
            psReceipt.setInt(2, supplierId);
            psReceipt.setInt(3, adminUserId);
            psReceipt.setDouble(4, totalAmount);
            psReceipt.executeUpdate();

            int importReceiptId = 0;
            rsKeys = psReceipt.getGeneratedKeys();
            if (rsKeys.next()) {
                importReceiptId = rsKeys.getInt(1);
            }

            // 2. Thực thi bảng Product_Batch (Detail)
            psBatch = conn.prepareStatement(insertBatchSQL);
            psBatch.setInt(1, batch.getVariantId());
            psBatch.setString(2, batch.getBatchCode());
            psBatch.setBigDecimal(3, batch.getCostPrice());
            psBatch.setBigDecimal(4, batch.getSalePrice());
            psBatch.setInt(5, batch.getInitialQuantity());
            psBatch.setInt(6, batch.getInitialQuantity());
            psBatch.setInt(7, importReceiptId); // Gắn với phiếu nhập vừa tạo
            psBatch.executeUpdate();

            // 3. Thực thi bảng Inventory_Log
            psLog = conn.prepareStatement(insertLogSQL);
            psLog.setInt(1, batch.getVariantId());
            psLog.setInt(2, adminUserId);
            psLog.setInt(3, batch.getInitialQuantity());
            psLog.setString(4, receiptCode + " - " + note);
            psLog.executeUpdate();

            // 4. Cập nhật tồn kho ở bảng Product_Variant
            psVariant = conn.prepareStatement(updateVariantSQL);
            psVariant.setInt(1, batch.getInitialQuantity());
            psVariant.setBigDecimal(2, batch.getCostPrice());
            psVariant.setBigDecimal(3, batch.getSalePrice());
            psVariant.setInt(4, batch.getVariantId());
            psVariant.executeUpdate();

            conn.commit();
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
                if (rsKeys != null) {
                    rsKeys.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psReceipt != null) {
                    psReceipt.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psBatch != null) {
                    psBatch.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psLog != null) {
                    psLog.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psVariant != null) {
                    psVariant.close();
                }
            } catch (Exception e) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
        return isSuccess;
    }

    /**
     * XỬ LÝ TRANSACTION NHẬP NHIỀU MẶT HÀNG (BATCH EXECUTION) Đã bổ sung tham
     * số supplierId và totalAmount để tạo Import_Receipt
     */
    public boolean adminExecuteMultiStockImport(int supplierId, int adminUserId, double totalAmount, String note, List<ProductBatch> batchList) {
        Connection conn = null;
        PreparedStatement psReceipt = null;
        PreparedStatement psBatch = null;
        PreparedStatement psLog = null;
        PreparedStatement psVariant = null;
        ResultSet rsKeys = null;
        boolean isSuccess = false;

        String insertReceiptSQL = "INSERT INTO Import_Receipt (receipt_code, supplier_id, user_id, total_amount, status) VALUES (?, ?, ?, ?, 'COMPLETED')";
        String insertBatchSQL = "INSERT INTO Product_Batch (variant_id, batch_code, cost_price, sale_price, initial_quantity, current_quantity, import_receipt_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        String insertLogSQL = "INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note, created_at) VALUES (?, ?, ?, 'IMPORT', ?, GETDATE())";
        String updateVariantSQL = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ?, cost_price = ?, sale_price = ? WHERE id = ?";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Tạo Phiếu Nhập Tổng (Master)
            psReceipt = conn.prepareStatement(insertReceiptSQL, Statement.RETURN_GENERATED_KEYS);
            String receiptCode = "RC-" + System.currentTimeMillis();
            psReceipt.setString(1, receiptCode);
            psReceipt.setInt(2, supplierId);
            psReceipt.setInt(3, adminUserId);
            psReceipt.setDouble(4, totalAmount);
            psReceipt.executeUpdate();

            int importReceiptId = 0;
            rsKeys = psReceipt.getGeneratedKeys();
            if (rsKeys.next()) {
                importReceiptId = rsKeys.getInt(1);
            }

            // Chuẩn bị Batch Statement cho danh sách sản phẩm
            psBatch = conn.prepareStatement(insertBatchSQL);
            psLog = conn.prepareStatement(insertLogSQL);
            psVariant = conn.prepareStatement(updateVariantSQL);

            for (ProductBatch batch : batchList) {
                // 2. Thêm vào Batch list của Lô Hàng
                psBatch.setInt(1, batch.getVariantId());
                psBatch.setString(2, batch.getBatchCode());
                psBatch.setBigDecimal(3, batch.getCostPrice());
                psBatch.setBigDecimal(4, batch.getSalePrice());
                psBatch.setInt(5, batch.getInitialQuantity());
                psBatch.setInt(6, batch.getInitialQuantity());
                psBatch.setInt(7, importReceiptId);
                psBatch.addBatch();

                // 3. Thêm vào Batch list của Log kho
                psLog.setInt(1, batch.getVariantId());
                psLog.setInt(2, adminUserId);
                psLog.setInt(3, batch.getInitialQuantity());
                psLog.setString(4, receiptCode + " - " + note);
                psLog.addBatch();

                // 4. Thêm vào Batch list cập nhật Variant
                psVariant.setInt(1, batch.getInitialQuantity());
                psVariant.setBigDecimal(2, batch.getCostPrice());
                psVariant.setBigDecimal(3, batch.getSalePrice());
                psVariant.setInt(4, batch.getVariantId());
                psVariant.addBatch();
            }

            // Thực thi toàn bộ lệnh Batch trong 1 lần gửi mạng duy nhất
            psBatch.executeBatch();
            psLog.executeBatch();
            psVariant.executeBatch();

            conn.commit();
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
                if (rsKeys != null) {
                    rsKeys.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psReceipt != null) {
                    psReceipt.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psBatch != null) {
                    psBatch.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psLog != null) {
                    psLog.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psVariant != null) {
                    psVariant.close();
                }
            } catch (Exception e) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
        return isSuccess;
    }

    /**
     * Lấy danh sách tất cả các Nhà cung cấp đang hoạt động
     */
    public List<Supplier> getAllSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT id, supplier_name, phone, address, status FROM Supplier WHERE status = 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Supplier s = new Supplier();
                s.setId(rs.getInt("id"));
                s.setSupplierName(rs.getString("supplier_name"));
                s.setPhone(rs.getString("phone"));
                s.setAddress(rs.getString("address"));
                s.setStatus(rs.getBoolean("status"));
                suppliers.add(s);
            }
        } catch (SQLException e) {
            System.err.println("❌ Lỗi SQL tại hàm getAllSuppliers: " + e.getMessage());
            e.printStackTrace();
        }
        return suppliers;
    }
}
