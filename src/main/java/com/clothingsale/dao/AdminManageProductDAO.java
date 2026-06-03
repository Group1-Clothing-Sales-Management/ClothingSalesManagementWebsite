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
    // 1. Lấy thông tin sản phẩm theo ID để hiển thị lên Form sửa

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
            System.err.println("❌ Lỗi lấy chi tiết sản phẩm theo ID:");
            e.printStackTrace();
        }
        return null;
    }

// 2. Cập nhật thông tin sản phẩm (Xử lý Transaction nếu thay đổi ảnh)
    public boolean updateProduct(Product p, String newImageName) {
        String sqlProduct = "UPDATE Product SET product_name = ?, slug = ?, brand_id = ?, category_id = ?, "
                + "short_description = ?, long_description = ?, status = ?, updated_at = GETDATE() WHERE id = ?";

        String sqlCheckImg = "SELECT id FROM Product_Image WHERE product_id = ?, AND is_main = 1";
        String sqlInsertImg = "INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES (?, ?, 1, 0)";
        String sqlUpdateImg = "UPDATE Product_Image SET image_url = ? WHERE product_id = ? AND is_main = 1";

        Connection conn = null;
        PreparedStatement psProd = null;
        PreparedStatement psImg = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bật Transaction

            // Update bảng Product
            psProd = conn.prepareStatement(sqlProduct);
            psProd.setString(1, p.getProductName());
            psProd.setString(2, p.getSlug());
            psProd.setInt(3, p.getBrandId());
            psProd.setInt(4, p.getCategoryId());
            psProd.setString(5, p.getShortDescription());
            psProd.setString(6, p.getLongDescription());
            psProd.setString(7, p.getStatus());
            psProd.setInt(8, p.getId());
            psProd.executeUpdate();

            // Nếu người dùng có upload ảnh mới, tiến hành cập nhật hoặc chèn mới ảnh đại diện
            if (newImageName != null && !newImageName.trim().isEmpty()) {
                boolean hasMainImg = false;

                // Kiểm tra xem trước đó sản phẩm đã có ảnh đại diện chưa
                try (PreparedStatement psCheck = conn.prepareStatement("SELECT COUNT(*) FROM Product_Image WHERE product_id = ? AND is_main = 1")) {
                    psCheck.setInt(1, p.getId());
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            hasMainImg = true;
                        }
                    }
                }

                if (hasMainImg) {
                    // Đã có ảnh -> Cập nhật tên file ảnh mới
                    psImg = conn.prepareStatement("UPDATE Product_Image SET image_url = ? WHERE product_id = ? AND is_main = 1");
                    psImg.setString(1, newImageName);
                    psImg.setInt(2, p.getId());
                } else {
                    // Chưa có ảnh -> Chèn mới bản ghi ảnh
                    psImg = conn.prepareStatement("INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES (?, ?, 1, 0)");
                    psImg.setInt(1, p.getId());
                    psImg.setString(2, newImageName);
                }
                psImg.executeUpdate();
            }

            conn.commit(); // Hoàn tất nghiệp vụ hoàn chỉnh
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
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
