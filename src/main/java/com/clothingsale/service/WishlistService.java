package com.clothingsale.service;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.dao.WishlistDAO;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.WishlistItem;
import java.util.List;
import java.util.Set;

public class WishlistService {

    private final WishlistDAO wishlistDAO = new WishlistDAO();
    private final CustomerProductDAO productDAO = new CustomerProductDAO();

    public List<WishlistItem> getWishlist(int userId) {
        List<WishlistItem> items = wishlistDAO.findByUserId(userId);

        for (WishlistItem item : items) {
            List<ProductVariant> variants
                    = productDAO.getVariantsByProductId(item.getProductId());
            item.setAvailableVariants(variants);
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
