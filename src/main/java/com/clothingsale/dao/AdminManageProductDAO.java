package com.clothingsale.dao;

import com.clothingsale.model.Product;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AdminManageProductDAO {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();

        // Câu lệnh SQL truy vấn kết hợp lấy ảnh chính (is_main = 1) từ bảng Product_Image
        String sql = "SELECT p.id, p.product_name, p.slug, p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
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

                // Trường tạm thời để gom đường dẫn ảnh đại diện hiển thị ra JSTL
                p.setMainImageUrl(rs.getString("main_image_url"));

                list.add(p);
            }
        } catch (SQLException e) {
            System.err.println("❌ Lỗi lấy danh sách sản phẩm kèm ảnh chính:");
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertProductWithImage(Product p, String imageName) {
        String sqlProduct = "INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        String sqlImage = "INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES (?, ?, 1, 0)";

        Connection conn = null;
        PreparedStatement psProd = null;
        PreparedStatement psImg = null;
        ResultSet rsKeys = null;

        try {
            conn = DBConnection.getConnection();
            // Tắt chế độ AutoCommit để tạo Transaction an toàn bảo vệ toàn vẹn dữ liệu
            conn.setAutoCommit(false);

            // 1. Chèn dữ liệu vào bảng Product
            psProd = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS);
            psProd.setString(1, p.getProductName());
            psProd.setString(2, p.getSlug());
            psProd.setInt(3, p.getBrandId());
            psProd.setInt(4, p.getCategoryId());
            psProd.setString(5, p.getShortDescription());
            psProd.setString(6, p.getLongDescription());
            psProd.setString(7, p.getStatus());

            int affectedRows = psProd.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("❌ Thêm sản phẩm thất bại, không có dòng nào bị ảnh hưởng.");
            }

            // Lấy mã ID tự động tăng của sản phẩm vừa sinh ra
            rsKeys = psProd.getGeneratedKeys();
            int newProductId = 0;
            if (rsKeys.next()) {
                newProductId = rsKeys.getInt(1);
            }

            // 2. Chèn dữ liệu tên file ảnh vào bảng Product_Image liên kết qua newProductId
            psImg = conn.prepareStatement(sqlImage);
            psImg.setInt(1, newProductId);
            psImg.setString(2, imageName);
            psImg.executeUpdate();

            // Nếu cả 2 hành động thành công, tiến hành đẩy dữ liệu lên SQL Server thật
            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    System.err.println("💥 Có lỗi xảy ra, đang khôi phục dữ liệu (Rollback)...");
                    conn.rollback(); // Hủy bỏ thao tác nếu 1 trong 2 lệnh lỗi
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            // Đóng tất cả kết nối tài nguyên an toàn
            try {
                if (rsKeys != null) {
                    rsKeys.close();
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
                if (psImg != null) {
                    psImg.close();
                }
            } catch (Exception e) {
            }
            DBConnection.closeConnection(conn);
        }
    }
}
