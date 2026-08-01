package com.clothingsale.model;

import java.sql.Timestamp;

/**
 * Địa chỉ giao hàng đã được chuẩn hóa theo dữ liệu từ AddressApiService.
 * Hệ thống hiện sử dụng mô hình hai cấp: Province -> Ward.
 */
public class UserAddress {

    private int id;
    private int userId;
    private String recipientName;
    private String recipientPhone;
    private String addressDetail;
    private String provinceCode;
    private String provinceName;
    private String wardCode;
    private String wardName;
    private boolean isDefault;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public UserAddress() {
    }

    public UserAddress(
            int id,
            int userId,
            String recipientName,
            String recipientPhone,
            String addressDetail,
            String provinceCode,
            String provinceName,
            String wardCode,
            String wardName,
            boolean isDefault) {

        this.id = id;
        this.userId = userId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.addressDetail = addressDetail;
        this.provinceCode = provinceCode;
        this.provinceName = provinceName;
        this.wardCode = wardCode;
        this.wardName = wardName;
        this.isDefault = isDefault;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
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

    public String getAddressDetail() {
        return addressDetail;
    }

    public void setAddressDetail(String addressDetail) {
        this.addressDetail = addressDetail;
    }

    public String getProvinceCode() {
        return provinceCode;
    }

    public void setProvinceCode(String provinceCode) {
        this.provinceCode = provinceCode;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    public String getWardCode() {
        return wardCode;
    }

    public void setWardCode(String wardCode) {
        this.wardCode = wardCode;
    }

    public String getWardName() {
        return wardName;
    }

    public void setWardName(String wardName) {
        this.wardName = wardName;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
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