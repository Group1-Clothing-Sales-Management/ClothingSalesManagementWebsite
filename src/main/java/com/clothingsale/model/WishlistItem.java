package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class WishlistItem {

    private int userId;
    private int productId;
    private int variantId;
    private String productName;
    private String slug;
    private String mainImageUrl;
    private String productStatus;
    private String variantStatus;
    private String sku;
    private String attributeDetails;
    private BigDecimal salePrice;
    private int stockQuantity;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<ProductVariant> availableVariants;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getMainImageUrl() {
        return mainImageUrl;
    }

    public void setMainImageUrl(String mainImageUrl) {
        this.mainImageUrl = mainImageUrl;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }

    public String getVariantStatus() {
        return variantStatus;
    }

    public void setVariantStatus(String variantStatus) {
        this.variantStatus = variantStatus;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getAttributeDetails() {
        return attributeDetails;
    }

    public void setAttributeDetails(String attributeDetails) {
        this.attributeDetails = attributeDetails;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<ProductVariant> getAvailableVariants() {
        return availableVariants;
    }

    public void setAvailableVariants(List<ProductVariant> availableVariants) {
        this.availableVariants = availableVariants;
    }

    public boolean isAvailable() {
        return "ACTIVE".equalsIgnoreCase(productStatus)
                && "ACTIVE".equalsIgnoreCase(variantStatus)
                && stockQuantity > 0;
    }
}
