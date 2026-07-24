package com.clothingsale.dao;

import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class AdminManageProductDAO {

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();

        String sql = "SELECT p.id, p.product_name, p.slug, p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, p.status, "
                + "p.is_featured, p.featured_display_order, "
                + "p.created_at, p.updated_at, img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img "
                + "ON img.product_id = p.id "
                + "AND img.variant_id IS NULL "
                + "AND img.is_main = 1 "
                + "WHERE p.status <> 'DELETED' "
                + "ORDER BY p.id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                products.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public Product getProductById(int productId) {
        String sql = "SELECT p.id, p.product_name, p.slug, p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, p.status, "
                + "p.is_featured, p.featured_display_order, "
                + "p.created_at, p.updated_at, img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img "
                + "ON img.product_id = p.id "
                + "AND img.variant_id IS NULL "
                + "AND img.is_main = 1 "
                + "WHERE p.id = ? AND p.status <> 'DELETED'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapProduct(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean insertProductWithImage(Product product, String imageName) {
        String insertProductSql = "INSERT INTO Product "
                + "(product_name, slug, brand_id, category_id, "
                + "short_description, long_description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertImageSql = "INSERT INTO Product_Image "
                + "(product_id, variant_id, image_url, is_main, "
                + "sort_order, updated_at) "
                + "VALUES (?, NULL, ?, 1, 0, SYSDATETIME())";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int productId;

                try (PreparedStatement ps = conn.prepareStatement(
                        insertProductSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setString(1, product.getProductName());
                    ps.setString(2, product.getSlug());
                    setNullableInt(ps, 3, product.getBrandId());
                    ps.setInt(4, product.getCategoryId());
                    ps.setString(5, product.getShortDescription());
                    ps.setString(6, product.getLongDescription());
                    ps.setString(7, product.getStatus());

                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            conn.rollback();
                            return false;
                        }
                        productId = keys.getInt(1);
                        product.setId(productId);
                    }
                }

                if (imageName != null && !imageName.trim().isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(insertImageSql)) {
                        ps.setInt(1, productId);
                        ps.setString(2, imageName.trim());
                        ps.executeUpdate();
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
     * Cập nhật thông tin Product và ảnh chính.
     *
     * Không kiểm tra Category ACTIVE tại DAO vì update ảnh/tên/mô tả vẫn được
     * phép khi Product đang nằm trong Category inactive. Ràng buộc đổi Category
     * và kích hoạt Product được xử lý tại Service.
     */
    public boolean updateProduct(Product product, String newImageName) {
        String updateProductSql = "UPDATE Product SET "
                + "product_name = ?, slug = ?, brand_id = ?, category_id = ?, "
                + "short_description = ?, long_description = ?, status = ?, "
                + "updated_at = GETDATE() "
                + "WHERE id = ? AND status <> 'DELETED'";

        String deactivateVariantsSql = "UPDATE Product_Variant "
                + "SET status = 'INACTIVE' "
                + "WHERE product_id = ? AND status <> 'INACTIVE'";

        String clearFeaturedSql = "UPDATE Product SET "
                + "is_featured = 0, featured_display_order = NULL, "
                + "updated_at = GETDATE() WHERE id = ?";

        String findImageSql = "SELECT TOP 1 id FROM Product_Image "
                + "WHERE product_id = ? "
                + "AND variant_id IS NULL "
                + "AND is_main = 1 "
                + "ORDER BY id";
        String updateImageSql = "UPDATE Product_Image "
                + "SET image_url = ?, updated_at = GETDATE() "
                + "WHERE product_id = ? "
                + "AND variant_id IS NULL "
                + "AND is_main = 1";
        String insertImageSql = "INSERT INTO Product_Image "
                + "(product_id, variant_id, image_url, is_main, "
                + "sort_order, updated_at) "
                + "VALUES (?, NULL, ?, 1, 0, SYSDATETIME())";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement ps = conn.prepareStatement(updateProductSql)) {
                    ps.setString(1, product.getProductName());
                    ps.setString(2, product.getSlug());
                    setNullableInt(ps, 3, product.getBrandId());
                    ps.setInt(4, product.getCategoryId());
                    ps.setString(5, product.getShortDescription());
                    ps.setString(6, product.getLongDescription());
                    ps.setString(7, product.getStatus());
                    ps.setInt(8, product.getId());

                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                if ("INACTIVE".equals(product.getStatus())) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            deactivateVariantsSql)) {
                        ps.setInt(1, product.getId());
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = conn.prepareStatement(
                            clearFeaturedSql)) {
                        ps.setInt(1, product.getId());
                        ps.executeUpdate();
                    }
                }

                if (newImageName != null && !newImageName.trim().isEmpty()) {
                    boolean hasMainImage;

                    try (PreparedStatement ps = conn.prepareStatement(findImageSql)) {
                        ps.setInt(1, product.getId());

                        try (ResultSet rs = ps.executeQuery()) {
                            hasMainImage = rs.next();
                        }
                    }

                    if (hasMainImage) {
                        try (PreparedStatement ps = conn.prepareStatement(updateImageSql)) {
                            ps.setString(1, newImageName.trim());
                            ps.setInt(2, product.getId());
                            ps.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement ps = conn.prepareStatement(insertImageSql)) {
                            ps.setInt(1, product.getId());
                            ps.setString(2, newImageName.trim());
                            ps.executeUpdate();
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

    public boolean isCategoryActive(int categoryId) {
        if (categoryId <= 0) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM Category "
                + "WHERE id = ? AND status = 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isProductInOrders(int productId) {
        String sql = "SELECT COUNT(*) FROM Order_Detail "
                + "WHERE variant_id IN "
                + "(SELECT id FROM Product_Variant WHERE product_id = ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa mềm Product và đồng thời vô hiệu hóa toàn bộ Variant.
     */
    public boolean softDeleteProduct(int productId) {
        String deactivateVariantsSql = "UPDATE Product_Variant "
                + "SET status = 'INACTIVE' WHERE product_id = ?";

        String deleteProductSql = "UPDATE Product "
                + "SET status = 'DELETED', is_featured = 0, "
                + "featured_display_order = NULL, updated_at = GETDATE() "
                + "WHERE id = ? AND status <> 'DELETED'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        deactivateVariantsSql)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                int affectedRows;

                try (PreparedStatement ps = conn.prepareStatement(deleteProductSql)) {
                    ps.setInt(1, productId);
                    affectedRows = ps.executeUpdate();
                }

                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
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
     * Giữ lại để tương thích với code cũ. Luồng hiện tại nên ưu tiên xóa mềm.
     */
    public boolean hardDeleteProduct(int productId) {
        String deleteVariantsSql = "DELETE FROM Product_Variant "
                + "WHERE product_id = ?";
        String deleteImagesSql = "DELETE FROM Product_Image "
                + "WHERE product_id = ?";
        String deleteProductSql = "DELETE FROM Product WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement ps = conn.prepareStatement(deleteVariantsSql)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(deleteImagesSql)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                int affectedRows;

                try (PreparedStatement ps = conn.prepareStatement(deleteProductSql)) {
                    ps.setInt(1, productId);
                    affectedRows = ps.executeUpdate();
                }

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
     * Lấy thứ tự tiếp theo khi bật Featured cho một Product mới.
     */
    public int getNextFeaturedDisplayOrder() {
        String sql = "SELECT ISNULL(MAX(featured_display_order), 0) + 1 "
                + "FROM Product WHERE is_featured = 1 "
                + "AND status <> 'DELETED'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return 1;
        }
    }

    /**
     * Product chỉ đủ điều kiện Featured khi Product và Category đang hoạt động,
     * đồng thời có ít nhất một Variant ACTIVE với giá bán hợp lệ.
     */
    public boolean isProductEligibleForFeatured(int productId) {
        if (productId <= 0) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM Product p "
                + "INNER JOIN Category c ON c.id = p.category_id "
                + "WHERE p.id = ? "
                + "AND p.status = 'ACTIVE' "
                + "AND c.status = 1 "
                + "AND EXISTS ("
                + "SELECT 1 FROM Product_Variant pv "
                + "WHERE pv.product_id = p.id "
                + "AND pv.status = 'ACTIVE' "
                + "AND ISNULL(pv.list_price, 0) > 0 "
                + "AND ISNULL(pv.sale_price, 0) > 0 "
                + "AND pv.sale_price <= pv.list_price"
                + ")";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Bật hoặc tắt Product trong khu vực Featured Products của Homepage.
     * Phương thức này không thay đổi status, giá hoặc tồn kho của Product.
     */
    public boolean updateFeaturedStatus(
            int productId,
            boolean featured,
            Integer displayOrder) {

        if (productId <= 0) {
            return false;
        }

        String sql;

        if (featured) {
            if (displayOrder == null || displayOrder < 1) {
                return false;
            }

            sql = "UPDATE p SET p.is_featured = 1, "
                    + "p.featured_display_order = ?, "
                    + "p.updated_at = GETDATE() "
                    + "FROM Product p "
                    + "INNER JOIN Category c ON c.id = p.category_id "
                    + "WHERE p.id = ? "
                    + "AND p.status = 'ACTIVE' "
                    + "AND c.status = 1 "
                    + "AND EXISTS ("
                    + "SELECT 1 FROM Product_Variant pv "
                    + "WHERE pv.product_id = p.id "
                    + "AND pv.status = 'ACTIVE' "
                    + "AND ISNULL(pv.list_price, 0) > 0 "
                    + "AND ISNULL(pv.sale_price, 0) > 0 "
                    + "AND pv.sale_price <= pv.list_price"
                    + ")";
        } else {
            sql = "UPDATE Product SET is_featured = 0, "
                    + "featured_display_order = NULL, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status <> 'DELETED'";
        }

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            if (featured) {
                ps.setInt(1, displayOrder);
                ps.setInt(2, productId);
            } else {
                ps.setInt(1, productId);
            }

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Brand> getAllBrands() {
        List<Brand> brands = new ArrayList<>();
        String sql = "SELECT id, brand_name, slug FROM Brand "
                + "ORDER BY brand_name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Brand brand = new Brand();
                brand.setId(rs.getInt("id"));
                brand.setBrandName(rs.getString("brand_name"));
                brand.setSlug(rs.getString("slug"));
                brands.add(brand);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return brands;
    }

    /**
     * Dùng cho trang Edit để Category hiện tại vẫn xuất hiện dù đã inactive.
     */
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, category_name, slug, status "
                + "FROM Category "
                + "ORDER BY status DESC, category_name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapCategory(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    /**
     * Dùng cho form tạo Product: chỉ cho chọn Category đang active.
     */
    public List<Category> getActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, category_name, slug, status "
                + "FROM Category WHERE status = 1 "
                + "ORDER BY category_name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapCategory(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    public List<ProductVariant> getVariantsByProductId(int productId) {
        List<ProductVariant> variants = new ArrayList<>();

        String sql = "SELECT pv.id, pv.product_id, pv.sku, "
                + "pv.color, pv.size, "
                + "pv.cost_price, pv.list_price, pv.sale_price, "
                + "pv.stock_quantity, pv.status, "
                + "img.image_url AS variant_image_url, "
                + "img.updated_at AS image_updated_at "
                + "FROM Product_Variant pv "
                + "LEFT JOIN Product_Image img "
                + "ON img.variant_id = pv.id "
                + "AND img.product_id = pv.product_id "
                + "AND img.is_main = 1 "
                + "WHERE pv.product_id = ? "
                + "ORDER BY pv.id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    variants.add(mapVariant(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return variants;
    }

    public ProductVariant getVariantById(int productId, int variantId) {
        String sql = "SELECT pv.id, pv.product_id, pv.sku, "
                + "pv.color, pv.size, "
                + "pv.cost_price, pv.list_price, pv.sale_price, "
                + "pv.stock_quantity, pv.status, "
                + "img.image_url AS variant_image_url, "
                + "img.updated_at AS image_updated_at "
                + "FROM Product_Variant pv "
                + "LEFT JOIN Product_Image img "
                + "ON img.variant_id = pv.id "
                + "AND img.product_id = pv.product_id "
                + "AND img.is_main = 1 "
                + "WHERE pv.product_id = ? "
                + "AND pv.id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, variantId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapVariant(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean insertProductWithMatrixVariants(
            Product product,
            String imageName,
            List<ProductVariant> variants) {

        String insertProductSql = "INSERT INTO Product "
                + "(product_name, slug, brand_id, category_id, "
                + "short_description, long_description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertImageSql = "INSERT INTO Product_Image "
                + "(product_id, image_url, is_main) VALUES (?, ?, 1)";

        String insertVariantSql = "INSERT INTO Product_Variant "
                + "(product_id, sku, cost_price, list_price, sale_price, "
                + "stock_quantity, status, color, size) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int productId;

                try (PreparedStatement ps = conn.prepareStatement(
                        insertProductSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setString(1, product.getProductName());
                    ps.setString(2, product.getSlug());
                    setNullableInt(ps, 3, product.getBrandId());
                    ps.setInt(4, product.getCategoryId());
                    ps.setString(5, product.getShortDescription());
                    ps.setString(6, product.getLongDescription());
                    ps.setString(7, product.getStatus());

                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            conn.rollback();
                            return false;
                        }
                        productId = keys.getInt(1);
                        product.setId(productId);
                    }
                }

                if (imageName != null && !imageName.trim().isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(insertImageSql)) {
                        ps.setInt(1, productId);
                        ps.setString(2, imageName.trim());
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertVariantSql)) {
                    for (ProductVariant variant : variants) {
                        variant.setProductId(productId);
                        ps.setInt(1, productId);
                        ps.setString(2, variant.getSku());
                        ps.setBigDecimal(3, zeroIfNull(variant.getCostPrice()));
                        ps.setBigDecimal(4, zeroIfNull(variant.getListPrice()));
                        ps.setBigDecimal(5, zeroIfNull(variant.getSalePrice()));
                        ps.setInt(6, variant.getStockQuantity());
                        ps.setString(7, variant.getStatus());
                        ps.setString(8, variant.getColor());
                        ps.setString(9, variant.getSize());
                        ps.addBatch();
                    }

                    ps.executeBatch();
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
     * Variant chỉ được ACTIVE khi Category, Product và giá bán đều hợp lệ.
     */
    public boolean updateVariantStatus(
            int productId,
            int variantId,
            String status) {

        String sql;

        if ("ACTIVE".equals(status)) {
            sql = "UPDATE pv SET pv.status = 'ACTIVE' "
                    + "FROM Product_Variant pv "
                    + "INNER JOIN Product p ON p.id = pv.product_id "
                    + "INNER JOIN Category c ON c.id = p.category_id "
                    + "WHERE pv.id = ? AND pv.product_id = ? "
                    + "AND p.status = 'ACTIVE' "
                    + "AND c.status = 1 "
                    + "AND ISNULL(pv.list_price, 0) > 0 "
                    + "AND ISNULL(pv.sale_price, 0) > 0 "
                    + "AND pv.sale_price <= pv.list_price";
        } else if ("INACTIVE".equals(status)) {
            sql = "UPDATE Product_Variant SET status = 'INACTIVE' "
                    + "WHERE id = ? AND product_id = ?";
        } else {
            return false;
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, variantId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean insertSingleVariant(ProductVariant variant) {
        if (variant == null || variantCombinationExists(
                variant.getProductId(),
                variant.getSize(),
                variant.getColor())) {
            return false;
        }

        String sql = "INSERT INTO Product_Variant "
                + "(product_id, sku, cost_price, list_price, sale_price, "
                + "stock_quantity, status, color, size) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, variant.getProductId());
            ps.setString(2, variant.getSku());
            ps.setBigDecimal(3, zeroIfNull(variant.getCostPrice()));
            ps.setBigDecimal(4, zeroIfNull(variant.getListPrice()));
            ps.setBigDecimal(5, zeroIfNull(variant.getSalePrice()));
            ps.setInt(6, variant.getStockQuantity());
            ps.setString(7, variant.getStatus());
            ps.setString(8, variant.getColor());
            ps.setString(9, variant.getSize());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean variantCombinationExists(
            int productId,
            String size,
            String color) {

        if (productId <= 0 || size == null || color == null) {
            return true;
        }

        String sql = "SELECT COUNT(*) FROM Product_Variant "
                + "WHERE product_id = ? "
                + "AND UPPER(LTRIM(RTRIM(size))) = UPPER(LTRIM(RTRIM(?))) "
                + "AND UPPER(LTRIM(RTRIM(color))) = UPPER(LTRIM(RTRIM(?)))";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setString(2, size.trim());
            ps.setString(3, color.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();

            // Fail closed: không chèn nếu không kiểm tra được trùng.
            return true;
        }
    }

    public boolean insertVariants(List<ProductVariant> variants) {
        if (variants == null || variants.isEmpty()) {
            return false;
        }

        String sql = "INSERT INTO Product_Variant "
                + "(product_id, sku, cost_price, list_price, sale_price, "
                + "stock_quantity, status, color, size) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (ProductVariant variant : variants) {
                    ps.setInt(1, variant.getProductId());
                    ps.setString(2, variant.getSku());
                    ps.setBigDecimal(3, zeroIfNull(variant.getCostPrice()));
                    ps.setBigDecimal(4, zeroIfNull(variant.getListPrice()));
                    ps.setBigDecimal(5, zeroIfNull(variant.getSalePrice()));
                    ps.setInt(6, variant.getStockQuantity());
                    ps.setString(7, variant.getStatus());
                    ps.setString(8, variant.getColor());
                    ps.setString(9, variant.getSize());
                    ps.addBatch();
                }

                ps.executeBatch();
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

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setProductName(rs.getString("product_name"));
        product.setSlug(rs.getString("slug"));
        product.setBrandId(rs.getInt("brand_id"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setShortDescription(rs.getString("short_description"));
        product.setLongDescription(rs.getString("long_description"));
        product.setStatus(rs.getString("status"));
        product.setFeatured(rs.getBoolean("is_featured"));

        int featuredDisplayOrder = rs.getInt("featured_display_order");
        product.setFeaturedDisplayOrder(
                rs.wasNull() ? null : featuredDisplayOrder);

        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        product.setMainImageUrl(rs.getString("main_image_url"));
        return product;
    }

    private Category mapCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setCategoryName(rs.getString("category_name"));
        category.setSlug(rs.getString("slug"));
        category.setStatus(rs.getInt("status"));
        return category;
    }

    private ProductVariant mapVariant(ResultSet rs) throws SQLException {
        ProductVariant variant = new ProductVariant();
        variant.setId(rs.getInt("id"));
        variant.setProductId(rs.getInt("product_id"));
        variant.setSku(rs.getString("sku"));
        variant.setColor(rs.getString("color"));
        variant.setSize(rs.getString("size"));
        variant.setCostPrice(rs.getBigDecimal("cost_price"));
        variant.setListPrice(rs.getBigDecimal("list_price"));
        variant.setSalePrice(rs.getBigDecimal("sale_price"));
        variant.setStockQuantity(rs.getInt("stock_quantity"));
        variant.setStatus(rs.getString("status"));
        variant.setImageUrl(rs.getString("variant_image_url"));
        variant.setImageUpdatedAt(rs.getTimestamp("image_updated_at"));

        StringBuilder details = new StringBuilder();

        if (variant.getColor() != null
                && !variant.getColor().trim().isEmpty()) {
            details.append("Color: ")
                    .append(variant.getColor().trim());
        }

        if (variant.getSize() != null
                && !variant.getSize().trim().isEmpty()) {
            if (details.length() > 0) {
                details.append(" / ");
            }

            details.append("Size: ")
                    .append(variant.getSize().trim());
        }

        variant.setAttributeDetails(
                details.length() > 0 ? details.toString() : "Standard"
        );

        return variant;
    }

    private BigDecimal zeroIfNull(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private void setNullableInt(
            PreparedStatement statement,
            int parameterIndex,
            int value) throws SQLException {

        if (value > 0) {
            statement.setInt(parameterIndex, value);
        } else {
            statement.setNull(parameterIndex, Types.INTEGER);
        }
    }

    public boolean updateVariantInfo(int productId, int variantId,
            String size, String color, String status) {

        String sql = "UPDATE Product_Variant "
                + "SET size = ?, color = ?, status = ? "
                + "WHERE id = ? AND product_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, size);
            ps.setString(2, color);
            ps.setString(3, status);
            ps.setInt(4, variantId);
            ps.setInt(5, productId);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean variantCombinationExistsForUpdate(
            int productId,
            int variantId,
            String size,
            String color) {

        if (productId <= 0
                || variantId <= 0
                || size == null
                || color == null) {
            return true;
        }

        String sql = "SELECT COUNT(*) "
                + "FROM Product_Variant "
                + "WHERE product_id = ? "
                + "AND id <> ? "
                + "AND UPPER(LTRIM(RTRIM(size))) "
                + "= UPPER(LTRIM(RTRIM(?))) "
                + "AND UPPER(LTRIM(RTRIM(color))) "
                + "= UPPER(LTRIM(RTRIM(?)))";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, variantId);
            ps.setString(3, size.trim());
            ps.setString(4, color.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();

            // Không cho cập nhật nếu không kiểm tra được dữ liệu trùng.
            return true;
        }
    }

    public boolean saveProductMainImage(
            int productId,
            String imageUrl) {

        if (productId <= 0
                || imageUrl == null
                || imageUrl.isBlank()) {
            return false;
        }

        String findImageSql
                = "SELECT TOP 1 id "
                + "FROM Product_Image "
                + "WHERE product_id = ? "
                + "AND variant_id IS NULL "
                + "ORDER BY is_main DESC, sort_order, id";

        String clearMainSql
                = "UPDATE Product_Image "
                + "SET is_main = 0 "
                + "WHERE product_id = ? "
                + "AND variant_id IS NULL "
                + "AND is_main = 1";

        String updateImageSql
                = "UPDATE Product_Image "
                + "SET image_url = ?, "
                + "is_main = 1, "
                + "sort_order = 0, "
                + "updated_at = SYSDATETIME() "
                + "WHERE id = ?";

        String insertImageSql
                = "INSERT INTO Product_Image "
                + "(product_id, variant_id, image_url, "
                + "is_main, sort_order, updated_at) "
                + "VALUES (?, NULL, ?, 1, 0, SYSDATETIME())";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                Integer imageId = null;

                try (PreparedStatement ps
                        = conn.prepareStatement(findImageSql)) {

                    ps.setInt(1, productId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            imageId = rs.getInt("id");
                        }
                    }
                }

                try (PreparedStatement ps
                        = conn.prepareStatement(clearMainSql)) {

                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                int affectedRows;

                if (imageId != null) {
                    try (PreparedStatement ps
                            = conn.prepareStatement(updateImageSql)) {

                        ps.setString(1, imageUrl.trim());
                        ps.setInt(2, imageId);
                        affectedRows = ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps
                            = conn.prepareStatement(insertImageSql)) {

                        ps.setInt(1, productId);
                        ps.setString(2, imageUrl.trim());
                        affectedRows = ps.executeUpdate();
                    }
                }

                if (affectedRows != 1) {
                    conn.rollback();
                    return false;
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean saveVariantMainImage(
            int productId,
            int variantId,
            String imageUrl) {

        if (productId <= 0
                || variantId <= 0
                || imageUrl == null
                || imageUrl.isBlank()) {
            return false;
        }

        String updateSql = "UPDATE Product_Image "
                + "SET image_url = ?, "
                + "is_main = 1, "
                + "sort_order = 0, "
                + "updated_at = SYSDATETIME() "
                + "WHERE product_id = ? "
                + "AND variant_id = ? "
                + "AND is_main = 1";

        String insertSql = "INSERT INTO Product_Image "
                + "(product_id, variant_id, image_url, "
                + "is_main, sort_order, updated_at) "
                + "SELECT ?, ?, ?, 1, 0, SYSDATETIME() "
                + "WHERE EXISTS ("
                + "SELECT 1 FROM Product_Variant "
                + "WHERE id = ? AND product_id = ?"
                + ")";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int affectedRows;

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, imageUrl.trim());
                    ps.setInt(2, productId);
                    ps.setInt(3, variantId);

                    affectedRows = ps.executeUpdate();
                }

                if (affectedRows == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setInt(1, productId);
                        ps.setInt(2, variantId);
                        ps.setString(3, imageUrl.trim());
                        ps.setInt(4, variantId);
                        ps.setInt(5, productId);

                        affectedRows = ps.executeUpdate();
                    }
                }

                if (affectedRows != 1) {
                    conn.rollback();
                    return false;
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }

                e.printStackTrace();
                return false;

            } finally {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}