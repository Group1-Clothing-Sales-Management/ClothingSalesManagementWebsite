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

    // Thông tin mở rộng phục vụ màn hình quản lý đơn hàng
    private String customerUsername;
    private String customerFullName;
    private String customerEmail;
    private String shipmentCarrierName;
    private String shipmentTrackingCode;
    private String shippingStatus;
    private String displayStatus;
    private String displayStatusLabel;
    private String displayStatusBadgeClass;
    private String shippingStatusLabel;
    private String shippingStatusBadgeClass;
    private String paymentMethod;
    private String paymentStatus;
    private int detailCount;
    private String provinceName;
    private String districtName;
    private String wardName;

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

    public String getCustomerUsername() {
        return customerUsername;
    }

    public void setCustomerUsername(String customerUsername) {
        this.customerUsername = customerUsername;
    }

    public String getCustomerFullName() {
        return customerFullName;
    }

    public void setCustomerFullName(String customerFullName) {
        this.customerFullName = customerFullName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getShipmentCarrierName() {
        return shipmentCarrierName;
    }

    public void setShipmentCarrierName(String shipmentCarrierName) {
        this.shipmentCarrierName = shipmentCarrierName;
    }

    public String getShipmentTrackingCode() {
        return shipmentTrackingCode;
    }

    public void setShipmentTrackingCode(String shipmentTrackingCode) {
        this.shipmentTrackingCode = shipmentTrackingCode;
    }

    public String getShippingStatus() {
        return shippingStatus;
    }

    public void setShippingStatus(String shippingStatus) {
        this.shippingStatus = shippingStatus;
    }

    public String getDisplayStatus() {
        return displayStatus;
    }

    public void setDisplayStatus(String displayStatus) {
        this.displayStatus = displayStatus;
    }

    public String getDisplayStatusLabel() {
        return displayStatusLabel;
    }

    public void setDisplayStatusLabel(String displayStatusLabel) {
        this.displayStatusLabel = displayStatusLabel;
    }

    public String getDisplayStatusBadgeClass() {
        return displayStatusBadgeClass;
    }

    public void setDisplayStatusBadgeClass(String displayStatusBadgeClass) {
        this.displayStatusBadgeClass = displayStatusBadgeClass;
    }

    public String getShippingStatusLabel() {
        return shippingStatusLabel;
    }

    public void setShippingStatusLabel(String shippingStatusLabel) {
        this.shippingStatusLabel = shippingStatusLabel;
    }

    public String getShippingStatusBadgeClass() {
        return shippingStatusBadgeClass;
    }

    public void setShippingStatusBadgeClass(String shippingStatusBadgeClass) {
        this.shippingStatusBadgeClass = shippingStatusBadgeClass;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public int getDetailCount() {
        return detailCount;
    }

    public void setDetailCount(int detailCount) {
        this.detailCount = detailCount;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getWardName() {
        return wardName;
    }

    public void setWardName(String wardName) {
        this.wardName = wardName;
    }
}
