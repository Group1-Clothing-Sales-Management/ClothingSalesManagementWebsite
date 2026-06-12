package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductBatch {

    private int id;
    private int variantId;
    private String batchCode;
    private BigDecimal costPrice;
    private BigDecimal salePrice;
    private int initialQuantity;
    private int currentQuantity;
    private Timestamp createdAt;

    public ProductBatch() {
    }

    public ProductBatch(int id, int variantId, String batchCode, BigDecimal costPrice,
            BigDecimal salePrice, int initialQuantity, int currentQuantity, Timestamp createdAt) {
        this.id = id;
        this.variantId = variantId;
        this.batchCode = batchCode;
        this.costPrice = costPrice;
        this.salePrice = salePrice;
        this.initialQuantity = initialQuantity;
        this.currentQuantity = currentQuantity;
        this.createdAt = createdAt;
    }

    // Getters và Setters
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

    public String getBatchCode() {
        return batchCode;
    }

    public void setBatchCode(String batchCode) {
        this.batchCode = batchCode;
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

    public int getInitialQuantity() {
        return initialQuantity;
    }

    public void setInitialQuantity(int initialQuantity) {
        this.initialQuantity = initialQuantity;
    }

    public int getCurrentQuantity() {
        return currentQuantity;
    }

    public void setCurrentQuantity(int currentQuantity) {
        this.currentQuantity = currentQuantity;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
