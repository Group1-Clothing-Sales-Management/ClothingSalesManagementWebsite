package com.clothingsale.service;

import com.clothingsale.dao.OrderManagementDAO;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Service layer for the order management screen.
 * This class centralizes status-transition rules so the controller stays lean.
 */
public class OrderManagementService {

    private final OrderManagementDAO dao = new OrderManagementDAO();

    /**
     * Fetch orders by keyword and status filter.
     */
    public List<Order> getOrders(String keyword, String statusFilter) {
        return dao.getOrders(keyword, statusFilter);
    }

    /**
     * Fetch order details by order ID.
     */
    public Order getOrderById(int orderId) {
        return dao.getOrderById(orderId);
    }

    /**
     * Fetch the line items belonging to an order.
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        return dao.getOrderDetails(orderId);
    }

    /**
     * Create a walk-in order for a purchase made directly at the shop.
     * The controller passes a small set of fields and the DAO handles the
     * transaction, stock deduction, order detail insert, and payment record.
     */
    public String createStoreOrder(String recipientName,
            String recipientPhone,
            int variantId,
            int quantity,
            String paymentMethod,
            String note) {
        return dao.createInStoreOrder(
                recipientName,
                recipientPhone,
                variantId,
                quantity,
                paymentMethod,
                note);
    }

    /**
     * Status options used in the list filter dropdown.
     */
    public List<String> getStatusOptions() {
        return Arrays.asList("ALL", "PENDING", "CONFIRMED", "SHIPPING", "DELIVERED", "CANCELLED", "RETURNED");
    }

    /**
     * Return the allowed next statuses for the current order.
     * The UI uses this list to render the quick-action buttons and update dropdown.
     */
    public List<String> getAllowedNextStatuses(String currentStatus) {
        String normalized = normalizeStatus(currentStatus);

        switch (normalized) {
            case "PENDING":
                return Arrays.asList("CONFIRMED", "CANCELLED");
            case "CONFIRMED":
                return Arrays.asList("SHIPPING", "CANCELLED");
            case "SHIPPING":
                return Arrays.asList("DELIVERED", "RETURNED");
            case "DELIVERED":
                return Collections.singletonList("RETURNED");
            default:
                return new ArrayList<>();
        }
    }

    /**
     * Process an order status change triggered by staff/admin actions.
     */
    public String changeOrderStatus(int orderId, String requestedStatus) {
        if (orderId <= 0) {
            return "Invalid order ID.";
        }

        String targetStatus = normalizeStatus(requestedStatus);
        if (!isAllowedOrderStatus(targetStatus)) {
            return "Invalid order status.";
        }

        String currentStatus = dao.getCurrentOrderStatus(orderId);
        if (currentStatus == null) {
            return "The order to update could not be found.";
        }

        currentStatus = normalizeStatus(currentStatus);
        if (currentStatus.equals(targetStatus)) {
            return "The order is already in " + targetStatus + " status.";
        }

        if (!canTransition(currentStatus, targetStatus)) {
            return "Cannot transition the order from " + currentStatus + " to " + targetStatus + ".";
        }

        boolean updated = dao.updateOrderStatus(orderId, targetStatus);
        if (updated) {
            return "SUCCESS";
        }

        return "Failed to update the order status. Please try again.";
    }

    /**
     * Normalize a status value so comparisons stay consistent.
     */
    private String normalizeStatus(String status) {
        return status == null ? "" : status.trim().toUpperCase();
    }

    /**
     * Check whether a status is supported by the order lifecycle.
     */
    private boolean isAllowedOrderStatus(String status) {
        return Arrays.asList("PENDING", "CONFIRMED", "SHIPPING", "DELIVERED", "CANCELLED", "RETURNED")
                .contains(status);
    }

    /**
     * Check whether the current status can move to the target status.
     */
    private boolean canTransition(String currentStatus, String targetStatus) {
        switch (currentStatus) {
            case "PENDING":
                return Arrays.asList("CONFIRMED", "CANCELLED").contains(targetStatus);
            case "CONFIRMED":
                return Arrays.asList("SHIPPING", "CANCELLED").contains(targetStatus);
            case "SHIPPING":
                return Arrays.asList("DELIVERED", "RETURNED").contains(targetStatus);
            case "DELIVERED":
                return "RETURNED".equals(targetStatus);
            default:
                return false;
        }
    }
}
