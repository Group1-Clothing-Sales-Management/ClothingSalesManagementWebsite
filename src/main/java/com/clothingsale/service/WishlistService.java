package com.clothingsale.service;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.dao.WishlistDAO;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.WishlistItem;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class WishlistService {

    private final WishlistDAO wishlistDAO = new WishlistDAO();
    private final CustomerProductDAO productDAO = new CustomerProductDAO();

    public List<WishlistItem> getWishlist(int userId) {
        List<WishlistItem> items = wishlistDAO.findByUserId(userId);
        List<Integer> productIds = new ArrayList<>();

        for (WishlistItem item : items) {
            if (item != null && item.getProductId() > 0) {
                productIds.add(item.getProductId());
            }
        }

        Map<Integer, List<ProductVariant>> variantsByProductId
                = productDAO.getVariantsByProductIds(productIds);

        for (WishlistItem item : items) {
            List<ProductVariant> variants = variantsByProductId.get(item.getProductId());
            item.setAvailableVariants(variants != null ? variants : Collections.emptyList());
        }

        return items;
    }

    public boolean addProduct(int userId, int productId, Integer variantId) {
        return wishlistDAO.addOrUpdateProduct(userId, productId, variantId);
    }

    public boolean updateProduct(int userId, int productId, int variantId) {
        return wishlistDAO.updateProduct(userId, productId, variantId);
    }

    public boolean deleteProduct(int userId, int productId) {
        return wishlistDAO.deleteProduct(userId, productId);
    }

    public int countByUserId(int userId) {
        return wishlistDAO.countByUserId(userId);
    }

    public Set<Integer> getWishlistProductIds(int userId) {
        return wishlistDAO.findProductIdsByUserId(userId);
    }
}
