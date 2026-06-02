package com.clothingsale.dao;

import com.clothingsale.model.Product;
import com.clothingsale.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
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
}
