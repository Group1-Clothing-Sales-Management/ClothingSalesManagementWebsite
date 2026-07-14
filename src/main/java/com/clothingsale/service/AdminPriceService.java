package com.clothingsale.service;

import com.clothingsale.dao.AdminPriceDAO;
import com.clothingsale.model.PriceHistory;
import com.clothingsale.model.PriceManagementItem;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public class AdminPriceService {

    private static final BigDecimal MAX_PRICE = new BigDecimal("9999999999999999.99");
    private final AdminPriceDAO priceDAO = new AdminPriceDAO();

    public List<PriceManagementItem> searchPrices(String keyword, String priceStatus) {
        String normalizedKeyword = trimToNull(keyword);

        if (normalizedKeyword != null && normalizedKeyword.length() > 200) {
            throw new IllegalArgumentException("Search keyword must not exceed 200 characters.");
        }

        return priceDAO.searchPrices(normalizedKeyword, priceStatus);
    }

    public PriceManagementItem getPriceByVariantId(int variantId) {
        validatePositiveId(variantId, "Product variant");

        PriceManagementItem item = priceDAO.getPriceByVariantId(variantId);

        if (item == null) {
            throw new IllegalArgumentException("Product variant does not exist.");
        }

        return item;
    }

    public List<PriceHistory> getPriceHistory(int variantId) {
        validatePositiveId(variantId, "Product variant");
        return priceDAO.getPriceHistory(variantId);
    }

    public void updatePrice(int variantId, BigDecimal listPrice, BigDecimal salePrice,
            String reason, int authenticatedUserId) {

        validatePositiveId(variantId, "Product variant");
        validatePositiveId(authenticatedUserId, "Authenticated user");

        BigDecimal normalizedListPrice = normalizePrice(listPrice, "List price");
        BigDecimal normalizedSalePrice = normalizePrice(salePrice, "Sale price");
        String normalizedReason = trimToNull(reason);

        if (normalizedSalePrice.compareTo(normalizedListPrice) > 0) {
            throw new IllegalArgumentException("Sale price cannot be greater than list price.");
        }

        if (normalizedReason != null && normalizedReason.length() > 500) {
            throw new IllegalArgumentException("Change reason must not exceed 500 characters.");
        }

        PriceManagementItem currentPrice = getPriceByVariantId(variantId);

        if ("DELETED".equalsIgnoreCase(currentPrice.getProductStatus())
                || "DELETED".equalsIgnoreCase(currentPrice.getVariantStatus())) {
            throw new IllegalStateException("Deleted products cannot be repriced.");
        }

        if (normalizedSalePrice.compareTo(currentPrice.getCostPrice()) < 0 && normalizedReason == null) {
            throw new IllegalArgumentException("A reason is required when the sale price is below cost.");
        }

        boolean updated = priceDAO.updatePrice(
                variantId,
                normalizedListPrice,
                normalizedSalePrice,
                normalizedReason,
                authenticatedUserId
        );

        if (!updated) {
            throw new IllegalStateException("The new price is identical to the current price.");
        }
    }

    private BigDecimal normalizePrice(BigDecimal price, String fieldName) {
        if (price == null) {
            throw new IllegalArgumentException(fieldName + " is required.");
        }

        BigDecimal normalizedPrice = price.setScale(2, RoundingMode.HALF_UP);

        if (normalizedPrice.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException(fieldName + " must be greater than zero.");
        }

        if (normalizedPrice.compareTo(MAX_PRICE) > 0) {
            throw new IllegalArgumentException(fieldName + " exceeds the supported value.");
        }

        return normalizedPrice;
    }

    private void validatePositiveId(int value, String fieldName) {
        if (value <= 0) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmedValue = value.trim();
        return trimmedValue.isEmpty() ? null : trimmedValue;
    }
}
