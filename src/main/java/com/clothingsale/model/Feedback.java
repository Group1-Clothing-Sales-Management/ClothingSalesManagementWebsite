package com.clothingsale.model;

import java.sql.Timestamp;

/**
 * Model trung gian cho bảng Feedback.
 * Lớp này gom cả dữ liệu gốc trong bảng và dữ liệu join để JSP hiển thị chi tiết
 * mà không cần viết SQL phức tạp trong giao diện.
 */
public class Feedback {

    // ----- Dữ liệu gốc của feedback -----
    private int id;
    private int userId;
    private int productId;
    private Integer orderId;
    private Integer orderDetailId;
    private Integer variantId;
    private String size;
    private String color;
    private int rating;
    private String comment;
    private boolean visible;
    private String adminResponse;
    private Integer responseBy;
    private Timestamp respondedAt;
    private Timestamp createdAt;

    // ----- Dữ liệu mở rộng để hiển thị trên màn hình Staff/Admin -----
    private String customerUsername;
    private String customerFullName;
    private String customerEmail;
    private String productName;
    private String productSlug;
    private String productImageUrl;
    private String orderCode;
    private String responderUsername;
    private String responderFullName;

    public Feedback() {
        // Constructor rỗng để JSP/DAO có thể khởi tạo dễ dàng.
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

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public Integer getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(Integer orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public Integer getVariantId() {
        return variantId;
    }

    public void setVariantId(Integer variantId) {
        this.variantId = variantId;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public String getAdminResponse() {
        return adminResponse;
    }

    public void setAdminResponse(String adminResponse) {
        this.adminResponse = adminResponse;
    }

    public Integer getResponseBy() {
        return responseBy;
    }

    public void setResponseBy(Integer responseBy) {
        this.responseBy = responseBy;
    }

    public Timestamp getRespondedAt() {
        return respondedAt;
    }

    public void setRespondedAt(Timestamp respondedAt) {
        this.respondedAt = respondedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductSlug() {
        return productSlug;
    }

    public void setProductSlug(String productSlug) {
        this.productSlug = productSlug;
    }

    public String getProductImageUrl() {
        return productImageUrl;
    }

    public void setProductImageUrl(String productImageUrl) {
        this.productImageUrl = productImageUrl;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getResponderUsername() {
        return responderUsername;
    }

    public void setResponderUsername(String responderUsername) {
        this.responderUsername = responderUsername;
    }

    public String getResponderFullName() {
        return responderFullName;
    }

    public void setResponderFullName(String responderFullName) {
        this.responderFullName = responderFullName;
    }
}
