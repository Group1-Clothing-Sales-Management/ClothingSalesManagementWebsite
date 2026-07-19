package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, int variantId, String color,
            String size, String currentStaff) {

        if (sku == null || sku.trim().isEmpty()) {
            return "Invalid input data. SKU is required.";
        }

        if (size == null || size.trim().isEmpty()) {
            return "Invalid input data. Size is required.";
        }

        try {
            String currentSku = sku.trim();
            StaffProductModel currentProduct = findProduct(variantId, currentSku);
            if (currentProduct == null) {
                return "Product not found or database operation failed.";
            }

            String updatedSku = buildSkuWithNewSize(
                    currentSku,
                    currentProduct.getSize(),
                    size);

            if (updatedSku == null) {
                return "Cannot update SKU because the current size is not part of the SKU.";
            }

            boolean isUpdated = productDAO.updateProductInDB(
                    currentSku,
                    updatedSku,
                    color,
                    size);

            if (isUpdated) {
                String actionLog = "Staff updated product variant -> SKU: " + currentSku
                        + (currentSku.equals(updatedSku) ? "" : " -> " + updatedSku)
                        + " | Color: " + (color != null ? color : "—")
                        + " | Size: " + (size != null ? size : "—");
                productDAO.saveInventoryLog(variantId, 0, currentStaff, actionLog);
                return "SUCCESS";
            } else {
                return "Product not found or database operation failed.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "System error: the database connection was interrupted. Please try again later.";
        }
    }

    private StaffProductModel findProduct(int variantId, String sku) throws Exception {
        for (StaffProductModel product : getAllProducts()) {
            if (product.getVariantId() == variantId
                    || (product.getSku() != null && product.getSku().equalsIgnoreCase(sku))) {
                return product;
            }
        }
        return null;
    }

    /**
     * Keeps the existing SKU format and replaces only its size segment. This
     * supports both legacy SKUs ending in size and newer SKUs containing size
     * before the color segment.
     */
    private String buildSkuWithNewSize(String sku, String currentSize, String newSize) {
        String normalizedNewSize = normalizeSkuPart(newSize);
        if (normalizedNewSize.isEmpty()) {
            return null;
        }

        if (currentSize == null || currentSize.trim().isEmpty()
                || currentSize.trim().equalsIgnoreCase(newSize.trim())) {
            return sku;
        }

        String normalizedCurrentSize = normalizeSkuPart(currentSize);
        Pattern sizePattern = Pattern.compile(
                "(?i)(^|-)" + Pattern.quote(normalizedCurrentSize) + "(?=-|$)");
        Matcher matcher = sizePattern.matcher(sku);
        int lastMatchStart = -1;
        int lastMatchEnd = -1;
        String prefix = "";
        while (matcher.find()) {
            lastMatchStart = matcher.start();
            lastMatchEnd = matcher.end();
            prefix = matcher.group(1);
        }

        if (lastMatchStart < 0) {
            return null;
        }

        return sku.substring(0, lastMatchStart)
                + prefix
                + normalizedNewSize
                + sku.substring(lastMatchEnd);
    }

    private String normalizeSkuPart(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "";
        }

        String normalized = java.text.Normalizer.normalize(
                value.trim(),
                java.text.Normalizer.Form.NFD);

        normalized = normalized
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toUpperCase(Locale.ROOT)
                .replaceAll("[^A-Z0-9]+", "-")
                .replaceAll("^-+|-+$", "");

        return normalized;
    }
}
