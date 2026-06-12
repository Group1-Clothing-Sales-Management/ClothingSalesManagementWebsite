package com.clothingsale.model;

import java.sql.Timestamp;
import java.util.List; // 1. Bổ sung import List

public class Product {

    private int id;
    private String productName;
    private String slug;
    private int brandId;
    private int categoryId;
    private String shortDescription;
    private String longDescription;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String mainImageUrl;

    // 2. Thêm thuộc tính variants để liên kết dữ liệu quan hệ 1-N
    private List<ProductVariant> variants;

    public Product() {
    }

    // Constructor cũ giữ nguyên hoặc bổ sung nếu cần
    public Product(int id, String productName, String slug, int brandId, int categoryId,
            String shortDescription, String longDescription, String status,
            Timestamp createdAt, Timestamp updatedAt, String mainImageUrl) {
        this.id = id;
        this.productName = productName;
        this.slug = slug;
        this.brandId = brandId;
        this.categoryId = categoryId;
        this.shortDescription = shortDescription;
        this.longDescription = longDescription;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.mainImageUrl = mainImageUrl;
    }

    // 3. Bổ sung Getter và Setter cho thuộc tính variants (Bắt buộc để JSTL EL hoạt động)
    public List<ProductVariant> getVariants() {
        return variants;
    }

    public void setVariants(List<ProductVariant> variants) {
        this.variants = variants;
    }

    // Các Getters và Setters cũ bên dưới giữ nguyên hoàn toàn...
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    public String getLongDescription() {
        return longDescription;
    }

    public void setLongDescription(String longDescription) {
        this.longDescription = longDescription;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getMainImageUrl() {
        return mainImageUrl;
    }

    public void setMainImageUrl(String mainImageUrl) {
        this.mainImageUrl = mainImageUrl;
    }
}
