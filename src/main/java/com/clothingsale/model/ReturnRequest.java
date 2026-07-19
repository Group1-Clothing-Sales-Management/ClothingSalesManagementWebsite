package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model đại diện cho một yêu cầu đổi trả và hoàn tiền của khách hàng.
 * Giữ model đơn giản để JSP có thể đọc trực tiếp mà không cần logic phức tạp.
 */
public class ReturnRequest {

    private int id;
    private String requestCode;
    private int orderId;
    private String orderCode;
    private int customerId;
    private String customerName;
    private String customerEmail;
    private String requestType;
    private String reason;
    private String customerNote;
    private String staffNote;
    private BigDecimal refundAmount = BigDecimal.ZERO;
    private String status;
    private Timestamp requestedAt;
    private Timestamp reviewedAt;
    private Timestamp receivedAt;
    private Timestamp refundRequestedAt;
    private Timestamp refundedAt;
    private List<ReturnRequestItem> items = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getCustomerNote() { return customerNote; }
    public void setCustomerNote(String customerNote) { this.customerNote = customerNote; }
    public String getStaffNote() { return staffNote; }
    public void setStaffNote(String staffNote) { this.staffNote = staffNote; }
    public BigDecimal getRefundAmount() { return refundAmount; }
    public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount == null ? BigDecimal.ZERO : refundAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }
    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }
    public Timestamp getReceivedAt() { return receivedAt; }
    public void setReceivedAt(Timestamp receivedAt) { this.receivedAt = receivedAt; }
    public Timestamp getRefundRequestedAt() { return refundRequestedAt; }
    public void setRefundRequestedAt(Timestamp refundRequestedAt) { this.refundRequestedAt = refundRequestedAt; }
    public Timestamp getRefundedAt() { return refundedAt; }
    public void setRefundedAt(Timestamp refundedAt) { this.refundedAt = refundedAt; }
    public List<ReturnRequestItem> getItems() { return items; }
    public void setItems(List<ReturnRequestItem> items) { this.items = items == null ? new ArrayList<>() : items; }
}
