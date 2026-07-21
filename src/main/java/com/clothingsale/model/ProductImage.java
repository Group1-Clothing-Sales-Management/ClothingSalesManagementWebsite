package com.clothingsale.model;

import java.sql.Timestamp;

public class ProductImage {

    private int id;
    private int productId;
    private Integer variantId;
    private String imageUrl;
    private boolean main;
    private int sortOrder;
    private Timestamp updatedAt;

    public ProductImage() {
    }

    public ProductImage(int id, int productId, Integer variantId,
            String imageUrl, boolean main, int sortOrder,
            Timestamp updatedAt) {
        this.id = id;
        this.productId = productId;
        this.variantId = variantId;
        this.imageUrl = imageUrl;
        this.main = main;
        this.sortOrder = sortOrder;
        this.updatedAt = updatedAt;
    }

    public boolean isProductImage() {
        return variantId == null;
    }

    public boolean isVariantImage() {
        return variantId != null;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public Integer getVariantId() {
        return variantId;
    }

    public void setVariantId(Integer variantId) {
        this.variantId = variantId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isMain() {
        return main;
    }

    public void setMain(boolean main) {
        this.main = main;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}