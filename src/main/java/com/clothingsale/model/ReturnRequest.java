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
    // Thông tin tài khoản nhận tiền do khách hàng cung cấp để tạo mã VietQR.
    private String refundBankId;
    private String refundBankName;
    private String refundAccountName;
    private String refundAccountNumber;
    private String refundQrUrl;
    private String refundTransferDescription;
    // Đường dẫn ảnh chứng từ được Staff/Admin tải lên sau khi chuyển khoản.
    private String refundProofPath;
    private Integer refundConfirmedBy;
    private Timestamp refundConfirmedAt;
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
    public String getRefundBankId() { return refundBankId; }
    public void setRefundBankId(String refundBankId) { this.refundBankId = refundBankId; }
    public String getRefundBankName() { return refundBankName; }
    public void setRefundBankName(String refundBankName) { this.refundBankName = refundBankName; }
    public String getRefundAccountName() { return refundAccountName; }
    public void setRefundAccountName(String refundAccountName) { this.refundAccountName = refundAccountName; }
    public String getRefundAccountNumber() { return refundAccountNumber; }
    public void setRefundAccountNumber(String refundAccountNumber) { this.refundAccountNumber = refundAccountNumber; }
    public String getRefundQrUrl() { return refundQrUrl; }
    public void setRefundQrUrl(String refundQrUrl) { this.refundQrUrl = refundQrUrl; }
    public String getRefundTransferDescription() { return refundTransferDescription; }
    public void setRefundTransferDescription(String refundTransferDescription) { this.refundTransferDescription = refundTransferDescription; }
    public String getRefundProofPath() { return refundProofPath; }
    public void setRefundProofPath(String refundProofPath) { this.refundProofPath = refundProofPath; }
    public Integer getRefundConfirmedBy() { return refundConfirmedBy; }
    public void setRefundConfirmedBy(Integer refundConfirmedBy) { this.refundConfirmedBy = refundConfirmedBy; }
    public Timestamp getRefundConfirmedAt() { return refundConfirmedAt; }
    public void setRefundConfirmedAt(Timestamp refundConfirmedAt) { this.refundConfirmedAt = refundConfirmedAt; }
    /** Nhãn trạng thái thân thiện hơn cho giao diện tiếng Anh. */
    public String getStatusLabel() {
        if (status == null) return "Unknown";
        switch (status) {
            case "PENDING": return "Pending review";
            case "INFO_REQUIRED": return "Information required";
            case "APPROVED": return "Approved - awaiting transfer";
            case "RECEIVED": return "Products received";
            case "REFUND_PENDING": return "Refund pending approval";
            case "COMPLETED": return "Refund completed";
            case "REJECTED": return "Rejected";
            case "CANCELLED": return "Cancelled - package not received";
            default: return status;
        }
    }
    public List<ReturnRequestItem> getItems() { return items; }
    public void setItems(List<ReturnRequestItem> items) { this.items = items == null ? new ArrayList<>() : items; }
}
