/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Order {

    private int id;
    private String orderCode;
    private int userId;
    private int voucherId;
    private int shipmentId;
    private String recipientName;
    private String recipientPhone;
    private String wardId;
    private String addressDetail;
    private BigDecimal totalItemsPrice;
    private BigDecimal discountAmount;
    private BigDecimal shippingFee;
    private BigDecimal totalPayment;
    private String orderStatus;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Order() {
    }

    public Order(int id, String orderCode, int userId, int voucherId, int shipmentId,
            String recipientName, String recipientPhone, String wardId, String addressDetail,
            BigDecimal totalItemsPrice, BigDecimal discountAmount, BigDecimal shippingFee,
            BigDecimal totalPayment, String orderStatus, String note, Timestamp createdAt,
            Timestamp updatedAt) {
        this.id = id;
        this.orderCode = orderCode;
        this.userId = userId;
        this.voucherId = voucherId;
        this.shipmentId = shipmentId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.wardId = wardId;
        this.addressDetail = addressDetail;
        this.totalItemsPrice = totalItemsPrice;
        this.discountAmount = discountAmount;
        this.shippingFee = shippingFee;
        this.totalPayment = totalPayment;
        this.orderStatus = orderStatus;
        this.note = note;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getWardId() {
        return wardId;
    }

    public void setWardId(String wardId) {
        this.wardId = wardId;
    }

    public String getAddressDetail() {
        return addressDetail;
    }

    public void setAddressDetail(String addressDetail) {
        this.addressDetail = addressDetail;
    }

    public BigDecimal getTotalItemsPrice() {
        return totalItemsPrice;
    }

    public void setTotalItemsPrice(BigDecimal totalItemsPrice) {
        this.totalItemsPrice = totalItemsPrice;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public BigDecimal getTotalPayment() {
        return totalPayment;
    }

    public void setTotalPayment(BigDecimal totalPayment) {
        this.totalPayment = totalPayment;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
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
}
