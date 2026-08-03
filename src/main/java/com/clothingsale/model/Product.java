package com.clothingsale.model;

import java.sql.Timestamp;
import java.util.List;

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
    private List<ProductVariant> variants;

    // Homepage configuration managed from Admin Product Management.
    private boolean featured;
    private Integer featuredDisplayOrder;

    /** Khởi tạo đối tượng Product. */
    public Product() {
    }

    /** Khởi tạo đối tượng Product. */
    public Product(int id, String productName, String slug, int brandId, int categoryId, String shortDescription, String longDescription, String status, Timestamp createdAt, Timestamp updatedAt, String mainImageUrl) {
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

    /** Khởi tạo đối tượng Product. */
    public Product(int id, String productName, String slug, int brandId, int categoryId, String shortDescription, String longDescription, String status, Timestamp createdAt, Timestamp updatedAt, String mainImageUrl, boolean featured, Integer featuredDisplayOrder) {
        this(id, productName, slug, brandId, categoryId, shortDescription,
                longDescription, status, createdAt, updatedAt, mainImageUrl);
        this.featured = featured;
        this.featuredDisplayOrder = featuredDisplayOrder;
    }

    /** Lấy ID. */
    public int getId() {
        return id;
    }

    /** Gán ID. */
    public void setId(int id) {
        this.id = id;
    }

    /** Lấy tên Product. */
    public String getProductName() {
        return productName;
    }

    /** Gán tên Product. */
    public void setProductName(String productName) {
        this.productName = productName;
    }

    /** Lấy slug. */
    public String getSlug() {
        return slug;
    }

    /** Gán slug. */
    public void setSlug(String slug) {
        this.slug = slug;
    }

    /** Lấy Brand ID. */
    public int getBrandId() {
        return brandId;
    }

    /** Gán Brand ID. */
    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    /** Lấy Category ID. */
    public int getCategoryId() {
        return categoryId;
    }

    /** Gán Category ID. */
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    /** Lấy mô tả ngắn. */
    public String getShortDescription() {
        return shortDescription;
    }

    /** Gán mô tả ngắn. */
    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    /** Lấy mô tả chi tiết. */
    public String getLongDescription() {
        return longDescription;
    }

    /** Gán mô tả chi tiết. */
    public void setLongDescription(String longDescription) {
        this.longDescription = longDescription;
    }

    /** Lấy trạng thái. */
    public String getStatus() {
        return status;
    }

    /** Gán trạng thái. */
    public void setStatus(String status) {
        this.status = status;
    }

    /** Lấy thời điểm tạo. */
    public Timestamp getCreatedAt() {
        return createdAt;
    }

    /** Gán thời điểm tạo. */
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /** Lấy thời điểm cập nhật. */
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    /** Gán thời điểm cập nhật. */
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    /** Lấy ảnh chính. */
    public String getMainImageUrl() {
        return mainImageUrl;
    }

    /** Gán ảnh chính. */
    public void setMainImageUrl(String mainImageUrl) {
        this.mainImageUrl = mainImageUrl;
    }

    /** Lấy danh sách Variant. */
    public List<ProductVariant> getVariants() {
        return variants;
    }

    /** Gán danh sách Variant. */
    public void setVariants(List<ProductVariant> variants) {
        this.variants = variants;
    }

    /** Kiểm tra Product đang Featured. */
    public boolean isFeatured() {
        return featured;
    }

    /** Gán trạng thái Featured. */
    public void setFeatured(boolean featured) {
        this.featured = featured;
    }

    /** Lấy thứ tự Featured. */
    public Integer getFeaturedDisplayOrder() {
        return featuredDisplayOrder;
    }

    /** Gán thứ tự Featured. */
    public void setFeaturedDisplayOrder(Integer featuredDisplayOrder) {
        this.featuredDisplayOrder = featuredDisplayOrder;
    }
}