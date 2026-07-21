package com.clothingsale.service;

import com.clothingsale.dao.ReturnRequestDAO;
import com.clothingsale.model.Order;
import com.clothingsale.model.ReturnReportRow;
import com.clothingsale.model.ReturnRequest;
import com.clothingsale.model.ReturnRequestItem;
import com.clothingsale.model.RefundBank;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Service giữ luật nghiệp vụ để controller chỉ nhận request và chuyển hướng.
 * Thời hạn đổi trả được đặt là 14 ngày kể từ lúc đơn chuyển sang DELIVERED.
 */
public class ReturnRequestService {

    private static final long RETURN_WINDOW_DAYS = 14;
    private final ReturnRequestDAO dao = new ReturnRequestDAO();
    private final CustomerOrderService customerOrderService = new CustomerOrderService();

    // Danh mục dùng cho dropdown. Bank ID là mã mà VietQR chấp nhận trong URL.
    private static final List<RefundBank> REFUND_BANKS = Arrays.asList(
            new RefundBank("VCB", "Vietcombank"),
            new RefundBank("BIDV", "BIDV"),
            new RefundBank("CTG", "VietinBank"),
            new RefundBank("AGRIBANK", "Agribank"),
            new RefundBank("TCB", "Techcombank"),
            new RefundBank("MB", "MBBank"),
            new RefundBank("ACB", "ACB"),
            new RefundBank("VPB", "VPBank"),
            new RefundBank("TPB", "TPBank"),
            new RefundBank("STB", "Sacombank"),
            new RefundBank("HDB", "HDBank"),
            new RefundBank("VIB", "VIB"),
            new RefundBank("MSB", "MSB"),
            new RefundBank("SHB", "SHB"),
            new RefundBank("OCB", "OCB"),
            new RefundBank("EIB", "Eximbank"),
            new RefundBank("SCB", "SCB"),
            new RefundBank("SEAB", "SeABank"),
            new RefundBank("LPB", "LPBank"),
            new RefundBank("CAKE", "CAKE by VPBank")
    );

    /** Lấy đơn khách được phép chọn để tạo yêu cầu mới. */
    public Order getEligibleOrder(int userId, int orderId) {
        for (Order order : customerOrderService.getOrdersByUserId(userId)) {
            if (order.getId() == orderId && isDelivered(order) && withinReturnWindow(order)) {
                if (!dao.hasOpenRequest(orderId)) return order;
            }
        }
        return null;
    }

    public List<ReturnRequestItem> getOrderItems(int userId, int orderId) {
        return dao.getCustomerOrderItems(userId, orderId);
    }

    public List<ReturnRequest> getCustomerRequests(int userId) {
        expireUnreceivedApprovedRequests();
        List<ReturnRequest> requests = dao.getCustomerRequests(userId);
        for (ReturnRequest request : requests) request.setItems(dao.getItems(request.getId()));
        return requests;
    }

    /** Tạo yêu cầu sau khi kiểm tra dữ liệu cơ bản ở service và dữ liệu chi tiết ở DAO. */
    public String createRequest(int userId, int orderId, String type, String reason, String note,
            String bankId, String accountName, String accountNumber, Map<Integer, Integer> quantities) {
        if (getEligibleOrder(userId, orderId) == null) return "This order is not eligible for a return request.";
        if (!Arrays.asList("RETURN", "EXCHANGE").contains(normalize(type))) return "Please select a valid request type.";
        if (reason == null || reason.trim().isEmpty()) return "Please select a reason.";
        RefundBank bank = findBank(bankId);
        if (bank == null) return "Please select a supported bank.";
        if (accountName == null || accountName.trim().length() < 2 || accountName.trim().length() > 120) {
            return "Please enter a valid account holder name.";
        }
        if (accountNumber == null || !accountNumber.trim().matches("[0-9]{4,25}")) {
            return "Please enter a valid bank account number.";
        }
        try {
            String code = "RET-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            dao.createRequest(code, userId, orderId, normalize(type), reason.trim(), trim(note),
                    bank.getBankId(), bank.getBankName(), accountName.trim(), accountNumber.trim(),
                    quantities == null ? Collections.emptyMap() : quantities);
            return "SUCCESS";
        } catch (SQLException e) {
            return e.getMessage() == null ? "Could not create the return request." : e.getMessage();
        }
    }

    public ReturnRequest getCustomerRequest(int userId, int requestId) {
        expireUnreceivedApprovedRequests();
        ReturnRequest request = dao.getById(requestId);
        return request != null && request.getCustomerId() == userId ? request : null;
    }

    // Chuyển thông tin bổ sung của khách vào đúng hồ sơ để Staff có thể kiểm tra lại.
    public String supplementInfo(int userId, int requestId, String note) {
        try { return dao.supplementInfo(requestId, userId, note) ? "SUCCESS" : "This request does not need additional information."; }
        catch (SQLException e) { return e.getMessage() == null ? "Could not update the return request." : e.getMessage(); }
    }

    public List<ReturnRequest> getStaffRequests(String keyword, String status) {
        expireUnreceivedApprovedRequests();
        List<ReturnRequest> requests = dao.getStaffRequests(keyword, status);
        for (ReturnRequest request : requests) request.setItems(dao.getItems(request.getId()));
        return requests;
    }

    public ReturnRequest getRequest(int id) {
        expireUnreceivedApprovedRequests();
        return dao.getById(id);
    }
    public Map<String, Integer> getStatusCounts() { return dao.getStatusCounts(); }
    public java.math.BigDecimal getTotalRefunded() { return dao.getTotalRefunded(); }
    public List<ReturnReportRow> getReportRows() { return dao.getReportRows(); }

    public String review(int id, int userId, String status, String note) {
        String normalizedStatus = normalize(status);
        if ("APPROVED".equals(normalizedStatus)) {
            ReturnRequest request = dao.getById(id);
            if (request == null) return "Return request not found.";
            if (request.getRefundBankId() == null || request.getRefundAccountNumber() == null
                    || request.getRefundAccountName() == null || request.getRefundAccountName().trim().isEmpty()) {
                return "The customer has not provided refund bank details.";
            }
            String transferDescription = "REFUND " + request.getOrderCode();
            String qrUrl = buildRefundQrUrl(request);
            return execute(() -> dao.review(id, userId, normalizedStatus, trim(note), qrUrl, transferDescription),
                    "The return request was approved and the VietQR code was generated.");
        }
        return execute(() -> dao.review(id, userId, normalizedStatus, trim(note)), "The return request was reviewed successfully.");
    }
    public String receive(int id, int userId, String note) {
        // Kiểm tra hạn 3 ngày ngay cả khi Staff gửi POST trực tiếp mà chưa mở lại trang chi tiết.
        expireUnreceivedApprovedRequests();
        return execute(() -> dao.receive(id, userId, trim(note)), "The returned products were received and added to inventory.");
    }
    public String requestRefund(int id, int userId, String note) { return execute(() -> dao.requestRefund(id, userId, trim(note)), "The refund was submitted for Admin approval."); }
    public String approveRefund(int id, int userId, String note) { return execute(() -> dao.approveRefund(id, userId, trim(note)), "The refund was approved and completed."); }
    public String rejectRefund(int id, int userId, String note) { return execute(() -> dao.rejectRefund(id, userId, trim(note)), "The refund request was rejected."); }
    public String confirmRefund(int id, int userId, String note, String proofPath) {
        return execute(() -> dao.confirmRefund(id, userId, trim(note), proofPath),
                "The refund was confirmed and the customer can now view the proof.");
    }

    /** Chạy dọn dẹp và không để lỗi database làm hỏng màn hình người dùng. */
    public void expireUnreceivedApprovedRequests() {
        try {
            dao.cancelExpiredApprovedRequests();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<RefundBank> getRefundBanks() {
        return REFUND_BANKS;
    }

    /** Tạo quicklink VietQR theo đúng template QR-Only. */
    public String buildRefundQrUrl(ReturnRequest request) {
        if (request == null || request.getRefundBankId() == null
                || request.getRefundAccountNumber() == null) return null;
        BigDecimal amount = request.getRefundAmount() == null ? BigDecimal.ZERO : request.getRefundAmount();
        String description = "REFUND " + request.getOrderCode();
        return "https://img.vietqr.io/image/"
                + encode(request.getRefundBankId()) + "-"
                + encode(request.getRefundAccountNumber()) + "-qr_only.png?amount="
                + encode(amount.setScale(0, java.math.RoundingMode.HALF_UP).toPlainString())
                + "&addInfo=" + encode(description)
                + "&accountName=" + encode(request.getRefundAccountName());
    }

    public Map<String, String> getStatusOptions() {
        Map<String, String> result = new LinkedHashMap<>();
        result.put("ALL", "All statuses"); result.put("PENDING", "Pending review"); result.put("INFO_REQUIRED", "Information required"); result.put("APPROVED", "Approved - awaiting package"); result.put("RECEIVED", "Products received"); result.put("REFUND_PENDING", "Refund pending approval"); result.put("COMPLETED", "Completed"); result.put("REJECTED", "Rejected"); result.put("CANCELLED", "Cancelled");
        return result;
    }

    private String execute(DatabaseAction action, String successMessage) {
        try { return action.run() ? "SUCCESS:" + successMessage : "The requested status change is not allowed."; }
        catch (SQLException e) { return e.getMessage() == null ? "Could not update the return request." : e.getMessage(); }
    }

    private boolean isDelivered(Order order) { String s = order.getOrderStatus(); return "DELIVERED".equalsIgnoreCase(s) || "SUCCESS".equalsIgnoreCase(s) || "COMPLETED".equalsIgnoreCase(s) || "RECEIVED".equalsIgnoreCase(s); }
    // Dữ liệu hiện tại chưa lưu riêng thời điểm giao thành công, nên dùng updatedAt
    // (thời điểm cuối đơn được cập nhật) làm mốc gần nhất cho thời hạn 14 ngày.
    private boolean withinReturnWindow(Order order) {
        java.sql.Timestamp baseTime = order.getUpdatedAt() != null ? order.getUpdatedAt() : order.getCreatedAt();
        return baseTime != null && Duration.between(baseTime.toInstant(), Instant.now()).toDays() <= RETURN_WINDOW_DAYS;
    }
    private String normalize(String value) { return value == null ? "" : value.trim().toUpperCase(); }
    private String trim(String value) { return value == null ? null : value.trim(); }
    private RefundBank findBank(String bankId) {
        String normalized = normalize(bankId);
        for (RefundBank bank : REFUND_BANKS) if (bank.getBankId().equalsIgnoreCase(normalized)) return bank;
        return null;
    }
    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
    @FunctionalInterface private interface DatabaseAction { boolean run() throws SQLException; }
}
