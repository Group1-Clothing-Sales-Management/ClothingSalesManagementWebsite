package com.clothingsale.model;

import java.math.BigDecimal;

public class StaffProductModel {
    private int id;
    private int variantId;
    private String productName;
    private String brandName;
    private String sku;
    private BigDecimal costPrice;
    private BigDecimal salePrice;
    private int stockQuantity;
    private String status;

    public StaffProductModel() {
    }

    public StaffProductModel(int id, int variantId, String productName, String brandName,
            String sku, BigDecimal costPrice, BigDecimal salePrice,
            int stockQuantity, String status) {
        this.id = id;
        this.variantId = variantId;
        this.productName = productName;
        this.brandName = brandName;
        this.sku = sku;
        this.costPrice = costPrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
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
}