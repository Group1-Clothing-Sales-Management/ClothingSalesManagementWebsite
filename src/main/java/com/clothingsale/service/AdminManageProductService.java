package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import java.util.List;
import java.text.Normalizer;
import java.util.Locale;

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

    public boolean deleteProductSmartly(int id) {
        if (productDAO.isProductInOrders(id)) {
            System.out.println("⚠️ Product ID #" + id + " already exists in orders. Switching to soft delete.");
            return productDAO.softDeleteProduct(id);
        } else {
            System.out.println("✅ Product ID #" + id + " is not in any order. Proceeding with hard delete.");
            return productDAO.hardDeleteProduct(id);
        }
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

}
