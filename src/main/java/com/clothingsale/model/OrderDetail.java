/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clothingsale.model;

import java.math.BigDecimal;

public class OrderDetail {

    private int id;
    private int orderId;
    private int variantId;
    private String productNameSnapshot;
    private String variantAttributesSnapshot;
    private int quantity;
    private BigDecimal price;
    private BigDecimal lineTotal;
    private int productId;
    private String currentProductName;
    private BigDecimal currentPrice;
    private int currentStock;
    private String currentProductStatus;
    private String currentVariantStatus;
    private String currentImageUrl;
    private boolean reorderable;
    private String reorderNote;

    public OrderDetail() {
    }

    public OrderDetail(int id, int orderId, int variantId, String productNameSnapshot,
            String variantAttributesSnapshot, int quantity, BigDecimal price) {
        this.id = id;
        this.orderId = orderId;
        this.variantId = variantId;
        this.productNameSnapshot = productNameSnapshot;
        this.variantAttributesSnapshot = variantAttributesSnapshot;
        this.quantity = quantity;
        this.price = price;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public String getProductNameSnapshot() {
        return productNameSnapshot;
    }

    public void setProductNameSnapshot(String productNameSnapshot) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getVariantAttributesSnapshot() {
        return variantAttributesSnapshot;
    }

    public void setVariantAttributesSnapshot(String variantAttributesSnapshot) {
        this.variantAttributesSnapshot = variantAttributesSnapshot;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getLineTotal() {
        return lineTotal;
    }

    public void setLineTotal(BigDecimal lineTotal) {
        this.lineTotal = lineTotal;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getCurrentProductName() {
        return currentProductName;
    }

    public void setCurrentProductName(String currentProductName) {
        this.currentProductName = currentProductName;
    }

    public BigDecimal getCurrentPrice() {
        return currentPrice;
    }

    public void setCurrentPrice(BigDecimal currentPrice) {
        this.currentPrice = currentPrice;
    }

    public int getCurrentStock() {
        return currentStock;
    }

    public void setCurrentStock(int currentStock) {
        this.currentStock = currentStock;
    }

    public String getCurrentProductStatus() {
        return currentProductStatus;
    }

    public void setCurrentProductStatus(String currentProductStatus) {
        this.currentProductStatus = currentProductStatus;
    }

    public String getCurrentVariantStatus() {
        return currentVariantStatus;
    }

    public void setCurrentVariantStatus(String currentVariantStatus) {
        this.currentVariantStatus = currentVariantStatus;
    }

    public String getCurrentImageUrl() {
        return currentImageUrl;
    }

    public void setCurrentImageUrl(String currentImageUrl) {
        this.currentImageUrl = currentImageUrl;
    }

    public boolean isReorderable() {
        return reorderable;
    }

    public void setReorderable(boolean reorderable) {
        this.reorderable = reorderable;
    }

    public String getReorderNote() {
        return reorderNote;
    }

    public void setReorderNote(String reorderNote) {
        this.reorderNote = reorderNote;
    }
}
