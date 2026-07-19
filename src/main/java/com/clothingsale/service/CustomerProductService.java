package com.clothingsale.service;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.CartItem;

import java.util.List;

public class CustomerProductService {

    private final CustomerProductDAO productDAO = new CustomerProductDAO();

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

        for (Product product : products) {

            List<ProductVariant> variants
                    = productDAO.getVariantsByProductId(product.getId());

            product.setVariants(variants);
        }

        return products;
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
}
