package com.clothingsale.service;

import com.clothingsale.dao.ReturnRequestDAO;
import com.clothingsale.model.Order;
import com.clothingsale.model.ReturnReportRow;
import com.clothingsale.model.ReturnRequest;
import com.clothingsale.model.ReturnRequestItem;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;
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
        List<ReturnRequest> requests = dao.getCustomerRequests(userId);
        for (ReturnRequest request : requests) request.setItems(dao.getItems(request.getId()));
        return requests;
    }

    /** Tạo yêu cầu sau khi kiểm tra dữ liệu cơ bản ở service và dữ liệu chi tiết ở DAO. */
    public String createRequest(int userId, int orderId, String type, String reason, String note,
            Map<Integer, Integer> quantities) {
        if (getEligibleOrder(userId, orderId) == null) return "This order is not eligible for a return request.";
        if (!Arrays.asList("RETURN", "EXCHANGE").contains(normalize(type))) return "Please select a valid request type.";
        if (reason == null || reason.trim().isEmpty()) return "Please select a reason.";
        try {
            String code = "RET-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            dao.createRequest(code, userId, orderId, normalize(type), reason.trim(), trim(note), quantities == null ? Collections.emptyMap() : quantities);
            return "SUCCESS";
        } catch (SQLException e) {
            return e.getMessage() == null ? "Could not create the return request." : e.getMessage();
        }
    }

    public ReturnRequest getCustomerRequest(int userId, int requestId) {
        ReturnRequest request = dao.getById(requestId);
        return request != null && request.getCustomerId() == userId ? request : null;
    }

    // Chuyển thông tin bổ sung của khách vào đúng hồ sơ để Staff có thể kiểm tra lại.
    public String supplementInfo(int userId, int requestId, String note) {
        try { return dao.supplementInfo(requestId, userId, note) ? "SUCCESS" : "This request does not need additional information."; }
        catch (SQLException e) { return e.getMessage() == null ? "Could not update the return request." : e.getMessage(); }
    }

    public List<ReturnRequest> getStaffRequests(String keyword, String status) {
        List<ReturnRequest> requests = dao.getStaffRequests(keyword, status);
        for (ReturnRequest request : requests) request.setItems(dao.getItems(request.getId()));
        return requests;
    }

    public ReturnRequest getRequest(int id) { return dao.getById(id); }
    public Map<String, Integer> getStatusCounts() { return dao.getStatusCounts(); }
    public java.math.BigDecimal getTotalRefunded() { return dao.getTotalRefunded(); }
    public List<ReturnReportRow> getReportRows() { return dao.getReportRows(); }

    public String review(int id, int userId, String status, String note) { return execute(() -> dao.review(id, userId, normalize(status), trim(note)), "The return request was reviewed successfully."); }
    public String receive(int id, int userId, String note) { return execute(() -> dao.receive(id, userId, trim(note)), "The returned products were received and added to inventory."); }
    public String requestRefund(int id, int userId, String note) { return execute(() -> dao.requestRefund(id, userId, trim(note)), "The refund was submitted for Admin approval."); }
    public String approveRefund(int id, int userId, String note) { return execute(() -> dao.approveRefund(id, userId, trim(note)), "The refund was approved and completed."); }
    public String rejectRefund(int id, int userId, String note) { return execute(() -> dao.rejectRefund(id, userId, trim(note)), "The refund request was rejected."); }

    public Map<String, String> getStatusOptions() {
        Map<String, String> result = new LinkedHashMap<>();
        result.put("ALL", "All statuses"); result.put("PENDING", "Pending review"); result.put("INFO_REQUIRED", "Information required"); result.put("APPROVED", "Approved"); result.put("RECEIVED", "Products received"); result.put("REFUND_PENDING", "Refund pending approval"); result.put("COMPLETED", "Completed"); result.put("REJECTED", "Rejected");
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
    @FunctionalInterface private interface DatabaseAction { boolean run() throws SQLException; }
}
