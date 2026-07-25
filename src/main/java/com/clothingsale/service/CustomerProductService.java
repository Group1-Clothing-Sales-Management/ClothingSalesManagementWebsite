package com.clothingsale.service;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.Category;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class CustomerProductService {

    private static final int DEFAULT_HOMEPAGE_LIMIT = 8;
    private static final int MAX_HOMEPAGE_LIMIT = 50;

    private final CustomerProductDAO productDAO = new CustomerProductDAO();

    public List<Category> getActiveCategories() {
        return productDAO.getActiveCategories();
    }

    public List<Category> getHeaderCategories() {
        return productDAO.getHeaderCategories();
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice,
            String sort) {

        List<Product> products = productDAO.getProducts(
                keyword,
                categoryId,
                brandId,
                minPrice,
                maxPrice,
                sort
        );

        populateVariants(products);

        return products;
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            Integer brandId,
            Double minPrice,
            Double maxPrice,
            String sort,
            int limit) {

        List<Product> products = productDAO.getProducts(
                keyword,
                categoryId,
                brandId,
                minPrice,
                maxPrice,
                sort,
                limit
        );

        populateVariants(products);

        return products;
    }

    public List<Product> getFeaturedProducts(int limit) {
        int safeLimit = normalizeHomepageLimit(limit);
        return prepareHomepageProducts(
                productDAO.getFeaturedProducts(safeLimit)
        );
    }

    public List<Product> getBestSellingProducts(int limit) {
        int safeLimit = normalizeHomepageLimit(limit);
        return prepareHomepageProducts(
                productDAO.getBestSellingProducts(safeLimit)
        );
    }

    public List<Product> getOnSaleProducts(int limit) {
        int safeLimit = normalizeHomepageLimit(limit);
        return prepareHomepageProducts(
                productDAO.getOnSaleProducts(safeLimit)
        );
    }

    public Product getProductById(int id) {

        return productDAO.getProductById(id);

    }

    public List<ProductVariant> getVariantsByProductId(int productId) {

        return productDAO.getVariantsByProductId(productId);
    }

    public CartItem getBuyNowItem(int variantId,
            int quantity) {

        return productDAO.getBuyNowItem(
                variantId,
                quantity);
    }

    public List<String> getColors(int productId) {

        return productDAO.getColors(productId);

    }

    public List<String> getSizes(int productId) {

        return productDAO.getSizes(productId);

    }

    private List<Product> prepareHomepageProducts(List<Product> products) {
        if (products == null || products.isEmpty()) {
            return Collections.emptyList();
        }

        List<Product> validProducts = new ArrayList<>();
        for (Product product : products) {
            if (product != null) {
                validProducts.add(product);
            }
        }

        if (validProducts.isEmpty()) {
            return Collections.emptyList();
        }

        populateVariants(validProducts);
        return validProducts;
    }

    private int normalizeHomepageLimit(int limit) {
        if (limit <= 0) {
            return DEFAULT_HOMEPAGE_LIMIT;
        }
        return Math.min(limit, MAX_HOMEPAGE_LIMIT);
    }

    private void populateVariants(List<Product> products) {
        if (products == null || products.isEmpty()) {
            return;
        }

        List<Integer> productIds = new ArrayList<>();
        for (Product product : products) {
            if (product != null && !productIds.contains(product.getId())) {
                productIds.add(product.getId());
            }
        }

        if (productIds.isEmpty()) {
            return;
        }

        Map<Integer, List<ProductVariant>> variantsByProductId
                = productDAO.getVariantsByProductIds(productIds);

        for (Product product : products) {
            if (product == null) {
                continue;
            }

            List<ProductVariant> variants
                    = variantsByProductId.get(product.getId());

            product.setVariants(
                    variants != null
                            ? variants
                            : Collections.emptyList()
            );
        }
    }
}