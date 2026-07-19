package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

public class CustomerProductDAO {

    public List<Category> getActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, category_name, slug, status "
                + "FROM Category WHERE status = 1 ORDER BY id ASC";

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

        return getProducts(keyword, categoryId, brandId, minPrice, maxPrice, sort, 0);
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice,
            String sort,
            int limit) {

        List<Product> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String topClause = limit > 0 ? "TOP " + limit + " " : "";

        StringBuilder sql = new StringBuilder(
                "SELECT " + topClause
                + "p.id, p.product_name, p.slug, "
                + "p.brand_id, p.category_id, "
                + "p.short_description, p.long_description, "
                + "p.status, p.created_at, p.updated_at, "
                + "img.image_url AS main_image_url, "
                + "MIN(pv.sale_price) AS min_sale_price, "
                + "MAX(pv.sale_price) AS max_sale_price "
                + "FROM Product p "
                + "OUTER APPLY ("
                + " SELECT TOP 1 pi.image_url "
                + " FROM Product_Image pi "
                + " WHERE pi.product_id = p.id "
                + " ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
                + ") img "
                + "LEFT JOIN Product_Variant pv "
                + "ON p.id = pv.product_id AND pv.status = 'ACTIVE' "
                + "WHERE p.status <> 'DELETED' "
        );

        appendProductFilters(sql, params, keyword, categoryId, brandId, minPrice, maxPrice);

        sql.append("GROUP BY p.id, p.product_name, p.slug, p.brand_id, p.category_id, ")
                .append("p.short_description, p.long_description, p.status, ")
                .append("p.created_at, p.updated_at, img.image_url ");

        appendProductSort(sql, sort);

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Could not load customer products.");
            e.printStackTrace();
        }

        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.id, p.product_name, p.short_description, "
                + "p.long_description, p.created_at, img.image_url "
                + "FROM Product p "
                + "OUTER APPLY ("
                + " SELECT TOP 1 pi.image_url "
                + " FROM Product_Image pi "
                + " WHERE pi.product_id = p.id "
                + " ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
                + ") img "
                + "WHERE p.id = ? "
                + "AND p.status = 'ACTIVE'";
        Product product = null;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    product = new Product();
                    product.setId(rs.getInt("id"));
                    product.setProductName(rs.getString("product_name"));
                    product.setShortDescription(rs.getString("short_description"));
                    product.setLongDescription(rs.getString("long_description"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    product.setMainImageUrl(rs.getString("image_url"));
                    product.setVariants(getVariantsByProductId(id));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return product;
    }

    public List<ProductVariant> getVariantsByProductId(int productId) {
        return getVariantsByProductIds(Collections.singletonList(productId))
                .getOrDefault(productId, Collections.emptyList());
    }

    public Map<Integer, List<ProductVariant>> getVariantsByProductIds(List<Integer> productIds) {
        Map<Integer, List<ProductVariant>> variantsByProductId = new LinkedHashMap<>();
        List<Integer> cleanProductIds = new ArrayList<>();

        if (productIds != null) {
            for (Integer productId : productIds) {
                if (productId != null && productId > 0 && !cleanProductIds.contains(productId)) {
                    cleanProductIds.add(productId);
                    variantsByProductId.put(productId, new ArrayList<>());
                }
            }
        }

        if (cleanProductIds.isEmpty()) {
            return variantsByProductId;
        }

        String sql = "SELECT pv.id, pv.product_id, pv.sku, pv.cost_price, "
                + "pv.sale_price, pv.stock_quantity, pv.status, "
                + "color.attribute_value AS color, "
                + "size.attribute_value AS size "
                + "FROM Product_Variant pv "
                + "OUTER APPLY ("
                + " SELECT TOP 1 vav.attribute_value "
                + " FROM Variant_Attribute_Value vav "
                + " JOIN Attribute a ON vav.attribute_id = a.id "
                + " WHERE vav.variant_id = pv.id AND a.attribute_name = 'Color'"
                + ") color "
                + "OUTER APPLY ("
                + " SELECT TOP 1 vav.attribute_value "
                + " FROM Variant_Attribute_Value vav "
                + " JOIN Attribute a ON vav.attribute_id = a.id "
                + " WHERE vav.variant_id = pv.id AND a.attribute_name = 'Size'"
                + ") size "
                + "WHERE pv.product_id IN (" + placeholders(cleanProductIds.size()) + ") "
                + "AND pv.status = 'ACTIVE' "
                + "ORDER BY pv.product_id, pv.id";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < cleanProductIds.size(); i++) {
                ps.setInt(i + 1, cleanProductIds.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant variant = mapVariant(rs);
                    variantsByProductId
                            .computeIfAbsent(variant.getProductId(), ignored -> new ArrayList<>())
                            .add(variant);
                }
            }
        } catch (SQLException e) {
            System.err.println("Could not load product variants.");
            e.printStackTrace();
        }

        return variantsByProductId;
    }

    public CartItem getBuyNowItem(int variantId, int quantity) {
        String sql = "SELECT pv.id AS variant_id, "
                + "pv.product_id, "
                + "pv.sale_price, "
                + "p.product_name, "
                + "img.image_url AS main_image, "
                + "color.attribute_value AS color, "
                + "size.attribute_value AS size "
                + "FROM Product_Variant pv "
                + "JOIN Product p ON pv.product_id=p.id "
                + "OUTER APPLY ("
                + " SELECT TOP 1 pi.image_url "
                + " FROM Product_Image pi "
                + " WHERE pi.product_id = p.id "
                + " ORDER BY pi.is_main DESC, pi.sort_order, pi.id"
                + ") img "
                + "OUTER APPLY ("
                + " SELECT TOP 1 vav.attribute_value "
                + " FROM Variant_Attribute_Value vav "
                + " JOIN Attribute a ON a.id=vav.attribute_id "
                + " WHERE vav.variant_id=pv.id AND a.attribute_name='Color'"
                + ") color "
                + "OUTER APPLY ("
                + " SELECT TOP 1 vav.attribute_value "
                + " FROM Variant_Attribute_Value vav "
                + " JOIN Attribute a ON a.id=vav.attribute_id "
                + " WHERE vav.variant_id=pv.id AND a.attribute_name='Size'"
                + ") size "
                + "WHERE pv.id=?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, variantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setVariantId(rs.getInt("variant_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setPrice(rs.getBigDecimal("sale_price"));
                    item.setQuantity(quantity);
                    item.setImageUrl(rs.getString("main_image"));
                    item.setColor(rs.getString("color"));
                    item.setSize(rs.getString("size"));
                    return item;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private void appendProductFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice) {

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND p.product_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        if (categoryId != null) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }

        if (brandId != null) {
            sql.append("AND p.brand_id = ? ");
            params.add(brandId);
        }

        if (minPrice != null) {
            sql.append("AND pv.sale_price >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append("AND pv.sale_price <= ? ");
            params.add(maxPrice);
        }
    }

    private void appendProductSort(StringBuilder sql, String sort) {
        if ("priceAsc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY CASE WHEN MIN(pv.sale_price) IS NULL THEN 1 ELSE 0 END, ")
                    .append("MIN(pv.sale_price) ASC, p.created_at DESC");
        } else if ("priceDesc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY CASE WHEN MAX(pv.sale_price) IS NULL THEN 1 ELSE 0 END, ")
                    .append("MAX(pv.sale_price) DESC, p.created_at DESC");
        } else {
            sql.append("ORDER BY p.created_at DESC");
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
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        product.setMainImageUrl(rs.getString("main_image_url"));
        return product;
    }

    private ProductVariant mapVariant(ResultSet rs) throws SQLException {
        ProductVariant variant = new ProductVariant();
        variant.setId(rs.getInt("id"));
        variant.setProductId(rs.getInt("product_id"));
        variant.setSku(rs.getString("sku"));
        variant.setCostPrice(rs.getBigDecimal("cost_price"));
        variant.setSalePrice(rs.getBigDecimal("sale_price"));
        variant.setStockQuantity(rs.getInt("stock_quantity"));
        variant.setStatus(rs.getString("status"));
        variant.setColor(rs.getString("color"));
        variant.setSize(rs.getString("size"));
        variant.setAttributeDetails(buildAttributeDetails(
                rs.getString("color"),
                rs.getString("size")));
        return variant;
    }

    private String buildAttributeDetails(String color, String size) {
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
        return details.length() > 0 ? details.toString() : "Standard";
    }

    private String placeholders(int count) {
        StringJoiner joiner = new StringJoiner(",");
        for (int i = 0; i < count; i++) {
            joiner.add("?");
        }
        return joiner.toString();
    }
}