package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductVariant {

    private int id;
    private int productId;

    private String sku;
    private String color;
    private String size;

    private BigDecimal costPrice;

    private BigDecimal listPrice;

    private BigDecimal salePrice;

    private int stockQuantity;
    private String status;

    private String attributeDetails;

    private Timestamp priceUpdatedAt;
    private Integer priceUpdatedBy;
    private String imageUrl;
    private Timestamp imageUpdatedAt;

    public ProductVariant() {
    }

    public ProductVariant(
            int id,
            int productId,
            String sku,
            BigDecimal costPrice,
            BigDecimal salePrice,
            int stockQuantity,
            String status
    ) {
        this.id = id;
        this.productId = productId;
        this.sku = sku;
        this.costPrice = costPrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.status = status;
    }

    public ProductVariant(
            int id,
            int productId,
            String sku,
            String color,
            String size,
            BigDecimal costPrice,
            BigDecimal listPrice,
            BigDecimal salePrice,
            int stockQuantity,
            String status,
            Timestamp priceUpdatedAt,
            Integer priceUpdatedBy
    ) {
        this.id = id;
        this.productId = productId;
        this.sku = sku;
        this.color = color;
        this.size = size;
        this.costPrice = costPrice;
        this.listPrice = listPrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.status = status;
        this.priceUpdatedAt = priceUpdatedAt;
        this.priceUpdatedBy = priceUpdatedBy;
    }

    public boolean isPriced() {
        return listPrice != null
                && salePrice != null
                && listPrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(BigDecimal.ZERO) > 0;
    }

    public boolean isBelowCost() {
        return costPrice != null
                && salePrice != null
                && salePrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(costPrice) < 0;
    }

    public String getDisplayName() {
        StringBuilder displayName = new StringBuilder();

        appendDisplayPart(displayName, sku);
        appendDisplayPart(displayName, size);
        appendDisplayPart(displayName, color);

        return displayName.toString();
    }

    private void appendDisplayPart(
            StringBuilder builder,
            String value
    ) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (builder.length() > 0) {
            builder.append(" - ");
        }

        builder.append(value.trim());
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

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public void setListPrice(BigDecimal listPrice) {
        this.listPrice = listPrice;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAttributeDetails() {
        return attributeDetails;
    }

    public void setAttributeDetails(String attributeDetails) {
        this.attributeDetails = attributeDetails;
    }

    public Timestamp getPriceUpdatedAt() {
        return priceUpdatedAt;
    }

    public void setPriceUpdatedAt(Timestamp priceUpdatedAt) {
        this.priceUpdatedAt = priceUpdatedAt;
    }

    public Integer getPriceUpdatedBy() {
        return priceUpdatedBy;
    }

    public void setPriceUpdatedBy(Integer priceUpdatedBy) {
        this.priceUpdatedBy = priceUpdatedBy;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Timestamp getImageUpdatedAt() {
        return imageUpdatedAt;
    }

    public void setImageUpdatedAt(Timestamp imageUpdatedAt) {
        this.imageUpdatedAt = imageUpdatedAt;
    }
}
