package com.clothingsale.service;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;

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

    public List<ProductVariant> getVariantsByProductId(int productId) {

        return productDAO.getVariantsByProductId(productId);
    }
}
