package com.clothingsale.dao;

import com.clothingsale.model.Product;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminManageProductDAO {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.id, p.product_name, p.slug, p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "WHERE p.status <> 'DELETED' "
                + "ORDER BY p.id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setProductName(rs.getString("product_name"));
                p.setSlug(rs.getString("slug"));
                p.setBrandId(rs.getInt("brand_id"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setShortDescription(rs.getString("short_description"));
                p.setLongDescription(rs.getString("long_description"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                p.setUpdatedAt(rs.getTimestamp("updated_at"));
                p.setMainImageUrl(rs.getString("main_image_url"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.id, p.product_name, p.slug, p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setProductName(rs.getString("product_name"));
                    p.setSlug(rs.getString("slug"));
                    p.setBrandId(rs.getInt("brand_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setShortDescription(rs.getString("short_description"));
                    p.setLongDescription(rs.getString("long_description"));
                    p.setStatus(rs.getString("status"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setUpdatedAt(rs.getTimestamp("updated_at"));
                    p.setMainImageUrl(rs.getString("main_image_url"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertProductWithImage(Product p, String imageName) {
        String sqlProd = "INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlImg = "INSERT INTO Product_Image (product_id, image_url, is_main) VALUES (?, ?, 1)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psProd = conn.prepareStatement(sqlProd, Statement.RETURN_GENERATED_KEYS)) {
                psProd.setString(1, p.getProductName());
                psProd.setString(2, p.getSlug());
                psProd.setInt(3, p.getBrandId());
                psProd.setInt(4, p.getCategoryId());
                psProd.setString(5, p.getShortDescription());
                psProd.setString(6, p.getLongDescription());
                psProd.setString(7, p.getStatus());

                int affectedRows = psProd.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }

                int productId = 0;
                try (ResultSet generatedKeys = psProd.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        productId = generatedKeys.getInt(1);
                    }
                }

                if (productId > 0 && imageName != null) {
                    try (PreparedStatement psImg = conn.prepareStatement(sqlImg)) {
                        psImg.setInt(1, productId);
                        psImg.setString(2, imageName);
                        psImg.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProduct(Product p, String imageName) {
        String sqlProd = "UPDATE Product SET product_name = ?, slug = ?, brand_id = ?, category_id = ?, short_description = ?, long_description = ?, status = ?, updated_at = GETDATE() WHERE id = ?";
        String sqlCheckImg = "SELECT id FROM Product_Image WHERE product_id = ? AND is_main = 1";
        String sqlUpdateImg = "UPDATE Product_Image SET image_url = ? WHERE product_id = ? AND is_main = 1";
        String sqlInsertImg = "INSERT INTO Product_Image (product_id, image_url, is_main) VALUES (?, ?, 1)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psProd = conn.prepareStatement(sqlProd)) {
                psProd.setString(1, p.getProductName());
                psProd.setString(2, p.getSlug());
                psProd.setInt(3, p.getBrandId());
                psProd.setInt(4, p.getCategoryId());
                psProd.setString(5, p.getShortDescription());
                psProd.setString(6, p.getLongDescription());
                psProd.setString(7, p.getStatus());
                psProd.setInt(8, p.getId());
                psProd.executeUpdate();

                if (imageName != null) {
                    boolean hasMainImg = false;
                    try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckImg)) {
                        psCheck.setInt(1, p.getId());
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                hasMainImg = true;
                            }
                        }
                    }

                    if (hasMainImg) {
                        try (PreparedStatement psUpImg = conn.prepareStatement(sqlUpdateImg)) {
                            psUpImg.setString(1, imageName);
                            psUpImg.setInt(2, p.getId());
                            psUpImg.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psInsImg = conn.prepareStatement(sqlInsertImg)) {
                            psInsImg.setInt(1, p.getId());
                            psInsImg.setString(2, imageName);
                            psInsImg.executeUpdate();
                        }
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * SỬA LỖI TÊN BẢNG: Kiểm tra xem sản phẩm đã nằm trong đơn hàng (thông qua
     * Product_Variant) chưa
     */
    public boolean isProductInOrders(int productId) {
        String sql = "SELECT COUNT(*) FROM Order_Detail WHERE variant_id IN (SELECT id FROM Product_Variant WHERE product_id = ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean softDeleteProduct(int id) {
        String sql = "UPDATE Product SET status = 'DELETED', updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * SỬA LỖI TÊN BẢNG: Thực hiện chuỗi xóa cứng qua bảng Product_Variant chuẩn
     * schema
     */
    public boolean hardDeleteProduct(int id) {
        String deleteAttrValue = "DELETE FROM Variant_Attribute_Value WHERE variant_id IN (SELECT id FROM Product_Variant WHERE product_id = ?)";
        String deleteVariant = "DELETE FROM Product_Variant WHERE product_id = ?";
        String deleteImages = "DELETE FROM Product_Image WHERE product_id = ?";
        String deleteProduct = "DELETE FROM Product WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(deleteAttrValue); PreparedStatement ps2 = conn.prepareStatement(deleteVariant); PreparedStatement ps3 = conn.prepareStatement(deleteImages); PreparedStatement ps4 = conn.prepareStatement(deleteProduct)) {

                ps1.setInt(1, id);
                ps1.executeUpdate();
                ps2.setInt(1, id);
                ps2.executeUpdate();
                ps3.setInt(1, id);
                ps3.executeUpdate();
                ps4.setInt(1, id);
                int affectedRows = ps4.executeUpdate();

                conn.commit();
                return affectedRows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * THÊM MỚI ĐỘNG: Lấy dữ liệu Thương hiệu thực tế từ bảng Brand
     */
    public List<Brand> getAllBrands() {
        List<Brand> brands = new ArrayList<>();
        String sql = "SELECT id, brand_name, slug FROM Brand";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Brand b = new Brand();
                b.setId(rs.getInt("id"));
                b.setBrandName(rs.getString("brand_name"));
                b.setSlug(rs.getString("slug"));
                brands.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return brands;
    }

    /**
     * THÊM MỚI ĐỘNG: Lấy dữ liệu Danh mục thực tế từ bảng Category
     */
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, category_name, slug FROM Category WHERE status = 1";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                categories.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    /**
     * THÊM MỚI AN TOÀN: Lấy danh sách các biến thể Variant kèm chi tiết thuộc
     * tính (Color, Size) theo Product ID
     */
    public List<com.clothingsale.model.ProductVariant> getVariantsByProductId(int productId) {
        List<com.clothingsale.model.ProductVariant> list = new ArrayList<>();
        // Câu lệnh SQL bóc tách các thuộc tính Color, Size thông qua các câu truy vấn con lồng nhau để tối ưu tốc độ load
        String sql = "SELECT pv.id, pv.product_id, pv.sku, pv.cost_price, pv.sale_price, pv.stock_quantity, pv.status, "
                + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav JOIN Attribute a ON vav.attribute_id = a.id WHERE vav.variant_id = pv.id AND a.attribute_name = 'Color') as color, "
                + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav JOIN Attribute a ON vav.attribute_id = a.id WHERE vav.variant_id = pv.id AND a.attribute_name = 'Size') as size "
                + "FROM Product_Variant pv "
                + "WHERE pv.product_id = ?";

        // Sử dụng Try-with-resources để tự động giải phóng kết nối, tránh treo bảng dữ liệu
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.clothingsale.model.ProductVariant v = new com.clothingsale.model.ProductVariant();
                    v.setId(rs.getInt("id"));

                    int prodId = rs.getInt("product_id");
                    if (!rs.wasNull()) {
                        v.setProductId(prodId);
                    }

                    v.setSku(rs.getString("sku"));
                    v.setCostPrice(rs.getBigDecimal("cost_price"));
                    v.setSalePrice(rs.getBigDecimal("sale_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setStatus(rs.getString("status"));

                    // Ghép các thuộc tính động Color và Size thành chuỗi mô tả
                    String color = rs.getString("color");
                    String size = rs.getString("size");
                    StringBuilder details = new StringBuilder();
                    if (color != null && !color.trim().isEmpty()) {
                        details.append("Color: ").append(color);
                    }
                    if (size != null && !size.trim().isEmpty()) {
                        if (details.length() > 0) {
                            details.append(" / ");
                        }
                        details.append("Size: ").append(size);
                    }
                    if (details.length() == 0) {
                        details.append("Standard");
                    }

                    // Gán chuỗi mô tả này vào thuộc tính attributeDetails của đối tượng ProductVariant
                    v.setAttributeDetails(details.toString());

                    list.add(v);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Lỗi SQL tại hàm getVariantsByProductId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }


    public boolean insertProductWithMatrixVariants(Product p, String imageName, List<com.clothingsale.model.ProductVariant> variants) {
        String sqlProd = "INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlImg = "INSERT INTO Product_Image (product_id, image_url, is_main) VALUES (?, ?, 1)";
        String sqlVariant = "INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES (?, ?, ?, ?, ?, ?)";
        String sqlAttrValue = "INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement psProd = null;
        PreparedStatement psImg = null;
        PreparedStatement psVariant = null;
        PreparedStatement psAttrValue = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Kích hoạt cơ chế quản lý giao dịch thủ công

            // BƯỚC 1: Lưu thông tin sản phẩm chính để lấy ID tăng tự động
            int productId = 0;
            psProd = conn.prepareStatement(sqlProd, Statement.RETURN_GENERATED_KEYS);
            psProd.setString(1, p.getProductName());
            psProd.setString(2, p.getSlug());
            psProd.setInt(3, p.getBrandId());
            psProd.setInt(4, p.getCategoryId());
            psProd.setString(5, p.getShortDescription());
            psProd.setString(6, p.getLongDescription());
            psProd.setString(7, p.getStatus());

            int affectedRows = psProd.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            try (ResultSet generatedKeys = psProd.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    productId = generatedKeys.getInt(1);
                }
            }

            if (productId == 0) {
                conn.rollback();
                return false;
            }

            // BƯỚC 2: Lưu tệp tin hình ảnh đại diện chính nếu Admin có tải lên
            if (imageName != null && !imageName.trim().isEmpty()) {
                psImg = conn.prepareStatement(sqlImg);
                psImg.setInt(1, productId);
                psImg.setString(2, imageName);
                psImg.executeUpdate();
            }

            // Truy vấn lấy khóa ngoại của 2 nhóm thuộc tính hệ thống 'Color' và 'Size'
            int colorAttrId = getAttributeIdByName(conn, "Color");
            int sizeAttrId = getAttributeIdByName(conn, "Size");

            // BƯỚC 3: Duyệt mảng ma trận tổ hợp để thêm đồng bộ bản ghi Variant & Đặc tính chi tiết
            psVariant = conn.prepareStatement(sqlVariant, Statement.RETURN_GENERATED_KEYS);
            psAttrValue = conn.prepareStatement(sqlAttrValue);

            for (com.clothingsale.model.ProductVariant v : variants) {
                // 3.1. Thêm bản ghi định danh biến thể vào Product_Variant
                psVariant.setInt(1, productId);
                psVariant.setString(2, v.getSku());
                psVariant.setBigDecimal(3, v.getCostPrice());
                psVariant.setBigDecimal(4, v.getSalePrice());
                psVariant.setInt(5, v.getStockQuantity());
                psVariant.setString(6, v.getStatus());
                psVariant.executeUpdate();

                int variantId = 0;
                try (ResultSet gkVariant = psVariant.getGeneratedKeys()) {
                    if (gkVariant.next()) {
                        variantId = gkVariant.getInt(1);
                    }
                }

                // 3.2. Bóc tách an toàn chuỗi gom "Color|Size" để phân bổ vào bảng trung gian cầu nối m-n
                if (variantId > 0 && v.getAttributeDetails() != null) {
                    String[] tokens = v.getAttributeDetails().split("\\|");
                    String colorValue = tokens.length > 0 ? tokens[0].trim() : null;
                    String sizeValue = tokens.length > 1 ? tokens[1].trim() : null;

                    // Đẩy thuộc tính màu sắc tự do vào Batch
                    if (colorValue != null && !colorValue.isEmpty() && colorAttrId > 0) {
                        psAttrValue.setInt(1, variantId);
                        psAttrValue.setInt(2, colorAttrId);
                        psAttrValue.setString(3, colorValue);
                        psAttrValue.addBatch();
                    }

                    // Đẩy kích cỡ tick chọn vào Batch
                    if (sizeValue != null && !sizeValue.isEmpty() && sizeAttrId > 0) {
                        psAttrValue.setInt(1, variantId);
                        psAttrValue.setInt(2, sizeAttrId);
                        psAttrValue.setString(3, sizeValue);
                        psAttrValue.addBatch();
                    }
                }
            }

            // Thực thi chèn mảng đồng loạt (Batch Execution) để tối ưu hiệu năng
            psAttrValue.executeBatch();

            conn.commit(); // Hoàn tất thành công trọn vẹn chuỗi Transaction dữ liệu
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    System.err.println("❌ Critical SQL Error under Admin Action! System automatically rolled back.");
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            // Đóng an toàn các tài nguyên để bảo vệ bộ nhớ hệ thống
            try {
                if (psAttrValue != null) {
                    psAttrValue.close();
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
                if (psImg != null) {
                    psImg.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psProd != null) {
                    psProd.close();
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
    }

    /**
     * Hàm phụ trợ lấy nhanh hoặc tự động sinh Attribute ID để đảm bảo không bị
     * lỗi khóa ngoại
     */
    private int getAttributeIdByName(Connection conn, String attrName) throws SQLException {
        String selectSql = "SELECT id FROM Attribute WHERE attribute_name = ?";
        String insertSql = "INSERT INTO Attribute (attribute_name) VALUES (?)";

        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, attrName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }

        // Nếu trong DB chưa có sẵn bản ghi 'Color' hay 'Size', tự động khởi tạo luôn
        try (PreparedStatement psIns = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            psIns.setString(1, attrName);
            psIns.executeUpdate();
            try (ResultSet rsKeys = psIns.getGeneratedKeys()) {
                if (rsKeys.next()) {
                    return rsKeys.getInt(1);
                }
            }
        }
        return 0;
    }
}
