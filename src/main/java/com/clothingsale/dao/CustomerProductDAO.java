package com.clothingsale.dao;

import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerProductDAO { 

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice) {

        List<Product> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT p.id, p.product_name, p.slug, "
                + "p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, "
                + "p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url "
                + "FROM Product p "
                + "LEFT JOIN Product_Image img "
                + "ON p.id = img.product_id AND img.is_main = 1 "
                + "LEFT JOIN Product_Variant pv "
                + "ON p.id = pv.product_id "
                + "WHERE p.status <> 'DELETED' "
        );

        List<Object> params = new ArrayList<>();

        // Search theo tên
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND p.product_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        // Filter Category
        if (categoryId != null) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
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


        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Gán tham số
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }


            try (ResultSet rs = ps.executeQuery()) {

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


    // Lấy các Variant của một Product
    public List<ProductVariant> getVariantsByProductId(int productId) {

        List<ProductVariant> list = new ArrayList<>();

        String sql =
                "SELECT id, product_id, sku, cost_price, "
                + "sale_price, stock_quantity, status "
                + "FROM Product_Variant "
                + "WHERE product_id = ?";


        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {


            ps.setInt(1, productId);


            try (ResultSet rs = ps.executeQuery()) {


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