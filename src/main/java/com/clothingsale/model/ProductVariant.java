/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clothingsale.model;

import java.math.BigDecimal;

public class ProductVariant {

    private int id;
    private int productId;
    private String sku;
    private BigDecimal costPrice;
    private BigDecimal salePrice;
    private int stockQuantity;
    private String status;
    private String attributeDetails;

    public ProductVariant() {
    }

    public ProductVariant(int id, int productId, String sku, BigDecimal costPrice,
            BigDecimal salePrice, int stockQuantity, String status) {
        this.id = id;
        this.productId = productId;
        this.sku = sku;
        this.costPrice = costPrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.status = status;
    }

    // Getters and Setters
    public String getAttributeDetails() {
        return attributeDetails;
    }

    public void setAttributeDetails(String attributeDetails) {
        this.attributeDetails = attributeDetails;
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
