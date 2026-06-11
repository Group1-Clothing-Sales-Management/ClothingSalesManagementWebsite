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
}
