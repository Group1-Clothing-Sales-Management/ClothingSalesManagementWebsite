package com.clothingsale.dao;

import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.Category;
import com.clothingsale.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerProductDAO {

    public List<Category> getActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "WITH AvailableCategory AS ( "
                + "SELECT DISTINCT c.id, c.category_name, c.slug, c.status, c.parent_id "
                + "FROM Category c "
                + "JOIN Product p ON p.category_id = c.id "
                + "JOIN Product_Variant pv ON pv.product_id = p.id "
                + "WHERE c.status = 1 "
                + "AND p.status = 'ACTIVE' "
                + "AND pv.status = 'ACTIVE' "
                + "AND pv.stock_quantity > 0 "
                + "UNION ALL "
                + "SELECT parent.id, parent.category_name, parent.slug, parent.status, parent.parent_id "
                + "FROM Category parent "
                + "JOIN AvailableCategory child ON child.parent_id = parent.id "
                + "WHERE parent.status = 1 "
                + ") "
                + "SELECT DISTINCT id, category_name, slug, status "
                + "FROM AvailableCategory "
                + "ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setCategoryName(rs.getString("category_name"));
                category.setSlug(rs.getString("slug"));
                category.setStatus(rs.getInt("status"));
                categories.add(category);
            }
        } catch (SQLException e) {
            System.err.println("Could not load customer header categories.");
            e.printStackTrace();
        }

        return categories;
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice,
            String sort) {

        List<Product> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (categoryId != null) {
            sql.append("WITH CategoryScope AS ( ")
                    .append("SELECT id FROM Category WHERE id = ? AND status = 1 ")
                    .append("UNION ALL ")
                    .append("SELECT c.id FROM Category c ")
                    .append("JOIN CategoryScope cs ON c.parent_id = cs.id ")
                    .append("WHERE c.status = 1 ")
                    .append(") ");
            params.add(categoryId);
        }

        sql.append("SELECT DISTINCT p.id, p.product_name, p.slug, "
                + "p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, "
                + "p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img "
                + "ON p.id = img.product_id AND img.is_main = 1 "
                + "JOIN Product_Variant pv "
                + "ON p.id = pv.product_id "
                + "AND pv.status = 'ACTIVE' "
                + "AND pv.stock_quantity > 0 "
                + "WHERE p.status = 'ACTIVE' "
        );

        // Search theo tên
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND p.product_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        // Filter Category
        if (categoryId != null) {
            sql.append("AND p.category_id IN (SELECT id FROM CategoryScope) ");
        }

        // Filter Brand
        if (brandId != null) {
            sql.append("AND p.brand_id = ? ");
            params.add(brandId);
        }

        // Giá tối thiểu
        if (minPrice != null) {
            sql.append("AND pv.sale_price >= ? ");
            params.add(minPrice);
        }

        // Giá tối đa
        if (maxPrice != null) {
            sql.append("AND pv.sale_price <= ? ");
            params.add(maxPrice);
        }

        sql.append("ORDER BY p.created_at DESC");

        try ( Connection conn = DBConnection.getConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Gán tham số
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try ( ResultSet rs = ps.executeQuery()) {

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

            }

        } catch (SQLException e) {
            System.err.println("❌ Lỗi khi lấy danh sách sản phẩm Customer:");
            e.printStackTrace();
        }

        return list;
    }

    public Product getProductById(int id) {

        String sql
                = "SELECT p.id, p.product_name, p.short_description, "
                + "p.long_description, p.created_at, img.image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img "
                + "ON p.id = img.product_id AND img.is_main = 1 "
                + "WHERE p.id = ? "
                + "AND p.status = 'ACTIVE'";
        Product product = null;

        try (
                 Connection conn = DBConnection.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                product = new Product();

                product.setId(rs.getInt("id"));
                product.setProductName(
                        rs.getString("product_name"));

                product.setShortDescription(
                        rs.getString("short_description"));

                product.setLongDescription(
                        rs.getString("long_description"));

                product.setCreatedAt(
                        rs.getTimestamp("created_at"));

                product.setMainImageUrl(
                        rs.getString("image_url"));

                // Load danh sách variant
                product.setVariants(
                        getVariantsByProductId(id));
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return product;
    }

    // Lấy các Variant của một Product
    public List<ProductVariant> getVariantsByProductId(int productId) {

        List<ProductVariant> list = new ArrayList<>();

        String sql
                = "SELECT pv.id, pv.product_id, pv.sku, pv.cost_price, "
                + "pv.sale_price, pv.stock_quantity, pv.status, "
                + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav "
                + "JOIN Attribute a ON vav.attribute_id = a.id "
                + "WHERE vav.variant_id = pv.id AND a.attribute_name = 'Color') AS color, "
                + "(SELECT TOP 1 vav.attribute_value FROM Variant_Attribute_Value vav "
                + "JOIN Attribute a ON vav.attribute_id = a.id "
                + "WHERE vav.variant_id = pv.id AND a.attribute_name = 'Size') AS size "
                + "FROM Product_Variant pv "
                + "WHERE pv.product_id = ? "
                + "AND pv.status = 'ACTIVE' "
                + "AND pv.stock_quantity > 0";

        try ( Connection conn = DBConnection.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try ( ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    ProductVariant variant = new ProductVariant();

                    variant.setId(rs.getInt("id"));
                    variant.setProductId(rs.getInt("product_id"));
                    variant.setSku(rs.getString("sku"));
                    variant.setCostPrice(
                            rs.getBigDecimal("cost_price")
                    );
                    variant.setSalePrice(
                            rs.getBigDecimal("sale_price")
                    );
                    variant.setStockQuantity(
                            rs.getInt("stock_quantity")
                    );
                    variant.setStatus(
                            rs.getString("status")
                    );
                    String color = rs.getString("color");
                    String size = rs.getString("size");
                    StringBuilder details = new StringBuilder();
                    if (color != null && !color.trim().isEmpty()) {
                        details.append("Color: ").append(color.trim());
                    }
                    if (size != null && !size.trim().isEmpty()) {
                        if (details.length() > 0) {
                            details.append(" / ");
                        }
                        details.append("Size: ").append(size.trim());
                    }
                    variant.setAttributeDetails(
                            details.length() > 0 ? details.toString() : "Standard"
                    );

                    list.add(variant);
                }

            }

        } catch (SQLException e) {

            System.err.println(
                    "❌ Lỗi lấy Product Variant:"
            );

            e.printStackTrace();
        }

        return list;
    }
}
