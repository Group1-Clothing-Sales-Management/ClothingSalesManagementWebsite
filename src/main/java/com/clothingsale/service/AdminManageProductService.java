package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import java.util.List;
import java.text.Normalizer;
import java.util.Locale;
import com.clothingsale.model.ProductVariant;
import java.util.HashSet;
import java.util.Set;
import java.math.BigDecimal;


public class AdminManageProductService {

    private final AdminManageProductDAO productDAO = new AdminManageProductDAO();

    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    public boolean addProduct(Product p, String imageName) {
        return productDAO.insertProductWithImage(p, imageName);
    }

    public Product getProductById(int id) {
        return productDAO.getProductById(id);
    }

    public boolean updateProduct(Product p, String imageName) {
        return productDAO.updateProduct(p, imageName);
    }

    public boolean deleteProductSmartly(int productId) {
        if (productId <= 0) {
            return false;
        }

        return productDAO.softDeleteProduct(productId);
    }

    public List<Brand> getAllBrands() {
        return productDAO.getAllBrands();
    }

    public List<Category> getAllCategories() {
        return productDAO.getAllCategories();
    }

    public List<com.clothingsale.model.ProductVariant> getVariantsByProductId(int productId) {
        return productDAO.getVariantsByProductId(productId);
    }

    public String validateProduct(Product product) {
        if (product == null) {
            return "invalid-product";
        }

        String productName = product.getProductName();

        if (productName == null || productName.trim().isEmpty()) {
            return "name-required";
        }

        if (productName.trim().length() > 150) {
            return "name-too-long";
        }

        if (product.getCategoryId() <= 0) {
            return "category-required";
        }

        String status = product.getStatus();

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            return "invalid-status";
        }

        product.setProductName(productName.trim());

        if (product.getShortDescription() != null) {
            product.setShortDescription(product.getShortDescription().trim());
        }

        if (product.getLongDescription() != null) {
            product.setLongDescription(product.getLongDescription().trim());
        }

        return null;
    }

    public String generateSlug(String productName, int productId) {
        String slug = Normalizer.normalize(
                productName.trim(),
                Normalizer.Form.NFD
        );

        slug = slug.replaceAll("\\p{M}", "");
        slug = slug.replace('đ', 'd').replace('Đ', 'D');
        slug = slug.toLowerCase(Locale.ROOT);
        slug = slug.replaceAll("[^a-z0-9]+", "-");
        slug = slug.replaceAll("^-|-$", "");

        if (slug.isEmpty()) {
            slug = "product";
        }

        return slug + "-" + productId;
    }

    public boolean updateVariantStatus(
            int productId,
            int variantId,
            String status
    ) {
        if (productId <= 0 || variantId <= 0) {
            return false;
        }

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            return false;
        }

        return productDAO.updateVariantStatus(
                productId,
                variantId,
                status
        );
    }

    public boolean addSingleVariant(com.clothingsale.model.ProductVariant variant) {
        return productDAO.insertSingleVariant(variant);
    }

    public String generateBaseSku(String productName) {
        if (productName == null || productName.trim().isEmpty()) {
            return "PRODUCT";
        }

        String sku = Normalizer.normalize(
                productName.trim(),
                Normalizer.Form.NFD
        );

        sku = sku.replaceAll("\\p{M}", "");
        sku = sku.replace('đ', 'd').replace('Đ', 'D');
        sku = sku.toUpperCase(Locale.ROOT);
        sku = sku.replaceAll("[^A-Z0-9]+", "-");
        sku = sku.replaceAll("^-|-$", "");

        return sku.isEmpty() ? "PRODUCT" : sku;
    }

    public String generateVariantSku(String productName, String size, String color) {
        String productPart = normalizeSkuPart(productName);
        String sizePart = normalizeSkuPart(size);
        String colorPart = normalizeSkuPart(color);

        return productPart + "-" + sizePart + "-" + colorPart;
    }

    private String normalizeSkuPart(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "na";
        }

        String normalized = java.text.Normalizer.normalize(
                value.trim(),
                java.text.Normalizer.Form.NFD
        );

        normalized = normalized
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(java.util.Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");

        return normalized.isEmpty() ? "na" : normalized;
    }

    public boolean createProductWithVariants(
            Product product,
            String imageName,
            List<ProductVariant> variants) {

        if (!validateVariants(variants)) {
            return false;
        }

        for (ProductVariant variant : variants) {
            prepareNewVariant(variant);
        }

        return productDAO.insertProductWithMatrixVariants(
                product,
                imageName,
                variants
        );
    }

    public boolean addVariants(
            int productId,
            List<ProductVariant> variants) {

        if (productId <= 0 || !validateVariants(variants)) {
            return false;
        }

        for (ProductVariant variant : variants) {
            prepareNewVariant(variant);
            variant.setProductId(productId);

            boolean existed = productDAO.variantCombinationExists(
                    productId,
                    variant.getSize(),
                    variant.getColor()
            );

            if (existed) {
                return false;
            }
        }

        return productDAO.insertVariants(variants);
    }

    private boolean validateVariants(List<ProductVariant> variants) {
    if (variants == null || variants.isEmpty()) {
        return false;
    }

    Set<String> combinations = new HashSet<>();
    Set<String> skuCodes = new HashSet<>();

    for (ProductVariant variant : variants) {
        if (variant == null
                || variant.getSize() == null
                || variant.getSize().trim().isEmpty()
                || variant.getColor() == null
                || variant.getColor().trim().isEmpty()
                || variant.getSku() == null
                || variant.getSku().trim().isEmpty()) {

            return false;
        }

        String size = normalizeVariantValue(variant.getSize());
        String color = normalizeVariantValue(variant.getColor());

        String combinationKey = size + "|" + color;
        String skuKey = variant.getSku()
                .trim()
                .toLowerCase(Locale.ROOT);

        // Không xét status.
        if (!combinations.add(combinationKey)) {
            return false;
        }

        if (!skuCodes.add(skuKey)) {
            return false;
        }

        variant.setSize(variant.getSize().trim());
        variant.setColor(variant.getColor().trim());
        variant.setStatus("INACTIVE");
    }

    return true;
}
    private String normalizeVariantValue(String value) {
    String normalized = Normalizer.normalize(
            value.trim(),
            Normalizer.Form.NFD
    );

    normalized = normalized
            .replaceAll("\\p{M}", "")
            .replace('đ', 'd')
            .replace('Đ', 'D')
            .toLowerCase(Locale.ROOT)
            .replaceAll("\\s+", " ");

    return normalized;
}

    private void prepareNewVariant(ProductVariant variant) {
        variant.setCostPrice(BigDecimal.ZERO);
        variant.setSalePrice(BigDecimal.ZERO);
        variant.setStockQuantity(0);
        variant.setStatus("INACTIVE");

        variant.setSize(variant.getSize().trim());
        variant.setColor(variant.getColor().trim());
    }

    private String limitSkuPart(String value, int maxLength) {
        if (value == null || value.isEmpty()) {
            return "NA";
        }

        return value.length() <= maxLength
                ? value
                : value.substring(0, maxLength);
    }

}
