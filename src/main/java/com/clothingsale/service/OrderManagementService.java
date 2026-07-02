package com.clothingsale.service;

import com.clothingsale.dao.OrderManagementDAO;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Service layer for the order management screen.
 * This class centralizes status-transition rules so the controller stays lean.
 */
public class OrderManagementService {

    private final OrderManagementDAO dao = new OrderManagementDAO();
    private static final String VNPAY_BANK_ID = readConfig("CLOTHINGSALE_VNPAY_BANK_ID", "clothingsale.vnpay.bankId", "mbbank");
    private static final String VNPAY_ACCOUNT_NO = readConfig("CLOTHINGSALE_VNPAY_ACCOUNT_NO", "clothingsale.vnpay.accountNo", "0123456789");
    private static final String VNPAY_TEMPLATE = readConfig("CLOTHINGSALE_VNPAY_TEMPLATE", "clothingsale.vnpay.template", "compact2");
    private static final String VNPAY_ACCOUNT_NAME = readConfig("CLOTHINGSALE_VNPAY_ACCOUNT_NAME", "clothingsale.vnpay.accountName", "Clothing Sale");

    /**
     * Fetch orders by keyword and status filter.
     */
    public List<Order> getOrders(String keyword, String statusFilter) {
        List<Order> orders = dao.getOrders(keyword, null);
        List<Order> enriched = new ArrayList<>();
        String normalizedFilter = normalizeStatus(statusFilter);

        for (Order order : orders) {
            Order item = enrichOrder(order);
            if (item == null) {
                continue;
            }
            if (!"ALL".equals(normalizedFilter)
                    && !normalizedFilter.isEmpty()
                    && !normalizedFilter.equals(item.getDisplayStatus())) {
                continue;
            }
            enriched.add(item);
        }

        return enriched;
    }

    /**
     * Fetch order details by order ID.
     */
    public Order getOrderById(int orderId) {
        return enrichOrder(dao.getOrderById(orderId));
    }

    /**
     * Fetch the line items belonging to an order.
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        return dao.getOrderDetails(orderId);
    }

    /**
     * Return true when the order is a VNPay order that still needs manual payment confirmation.
     */
    public boolean needsVnpayTransferInfo(Order order) {
        if (order == null) {
            return false;
        }

        return "VNPAY".equalsIgnoreCase(order.getPaymentMethod())
                && (order.getPaymentStatus() == null || "UNPAID".equalsIgnoreCase(order.getPaymentStatus().trim()));
    }

    /**
     * Build the VietQR URL for an order payment.
     */
    public String buildVnpayQrUrl(Order order) {
        if (order == null || !hasVnpayTransferConfig()) {
            return null;
        }

        BigDecimal amount = getVnpayTransferAmount(order);
        String amountValue = amount == null
                ? "0"
                : amount.max(BigDecimal.ZERO).setScale(0, java.math.RoundingMode.HALF_UP).toPlainString();

        return "https://img.vietqr.io/image/"
                + VNPAY_BANK_ID.trim()
                + "-"
                + VNPAY_ACCOUNT_NO.trim()
                + "-"
                + VNPAY_TEMPLATE.trim()
                + ".png?amount="
                + encodeUrl(amountValue)
                + "&addInfo="
                + encodeUrl(getVnpayTransferDescription(order))
                + "&accountName="
                + encodeUrl(VNPAY_ACCOUNT_NAME.trim());
    }

    /**
     * The transfer description is the order ID as requested by the business flow.
     */
    public String getVnpayTransferDescription(Order order) {
        return order == null ? "" : String.valueOf(order.getId());
    }

    /**
     * Use the product subtotal for the QR amount so the transfer amount matches the item value.
     */
    public BigDecimal getVnpayTransferAmount(Order order) {
        if (order == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal amount = order.getTotalItemsPrice();
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            amount = order.getTotalPayment();
        }
        return amount == null ? BigDecimal.ZERO : amount;
    }

    public String getVnpayBankId() {
        return VNPAY_BANK_ID;
    }

    public String getVnpayAccountNo() {
        return VNPAY_ACCOUNT_NO;
    }

    public String getVnpayTemplate() {
        return VNPAY_TEMPLATE;
    }

    public String getVnpayAccountName() {
        return VNPAY_ACCOUNT_NAME;
    }

    public boolean hasVnpayTransferConfig() {
        return !VNPAY_BANK_ID.trim().isEmpty()
                && !VNPAY_ACCOUNT_NO.trim().isEmpty()
                && !VNPAY_TEMPLATE.trim().isEmpty()
                && !VNPAY_ACCOUNT_NAME.trim().isEmpty();
    }

    public String confirmVnpayPayment(int orderId) {
        if (orderId <= 0) {
            return "Invalid order ID.";
        }

        Order order = getOrderById(orderId);
        if (order == null) {
            return "The order to update could not be found.";
        }

        if (!"VNPAY".equalsIgnoreCase(order.getPaymentMethod())) {
            return "This order does not use VNPay payment.";
        }

        if (order.getPaymentStatus() != null && !"UNPAID".equalsIgnoreCase(order.getPaymentStatus().trim())) {
            if ("PAID".equalsIgnoreCase(order.getPaymentStatus().trim())) {
                return "This order has already been marked as paid.";
            }
            return "Only unpaid VNPay orders can be confirmed from this screen.";
        }

        return dao.markVnpayPaymentAsPaid(orderId)
                ? "SUCCESS"
                : "Failed to confirm the VNPay payment. Please try again.";
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
        return createStoreOrder(recipientName, recipientPhone, variantId, quantity, paymentMethod, note, false, null);
    }

    public String createStoreOrder(String recipientName,
            String recipientPhone,
            int variantId,
            int quantity,
            String paymentMethod,
            String note,
            boolean deliveryOrder,
            String deliveryAddress) {
        return dao.createInStoreOrder(
                recipientName,
                recipientPhone,
                variantId,
                quantity,
                paymentMethod,
                note,
                deliveryOrder,
                deliveryAddress);
    }

    /**
     * Status options used in the list filter dropdown.
     */
    public Map<String, String> getStatusOptions() {
        return new LinkedHashMap<>(OrderStatusHelper.getStatusOptions());
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

        String targetStatus = OrderStatusHelper.resolveRawStatusFromDisplay(requestedStatus);
        if (!isAllowedOrderStatus(targetStatus)) {
            return "Invalid order status.";
        }

        String currentStatus = dao.getCurrentOrderStatus(orderId);
        if (currentStatus == null) {
            return "The order to update could not be found.";
        }

        currentStatus = normalizeStatus(currentStatus);
        if (OrderStatusHelper.RAW_CONFIRMED.equals(targetStatus)) {
            if (OrderStatusHelper.RAW_CONFIRMED.equals(currentStatus)) {
                return "The order is already approved.";
            }

            if (!OrderStatusHelper.RAW_PENDING.equals(currentStatus)) {
                return "Only pending orders can be approved.";
            }

            return dao.approveOrder(orderId) ? "SUCCESS" : "Failed to approve the order. Please try again.";
        }

        if (OrderStatusHelper.RAW_CANCELLED.equals(targetStatus)) {
            if (OrderStatusHelper.RAW_CANCELLED.equals(currentStatus)) {
                return "The order is already cancelled.";
            }

            if (!OrderStatusHelper.RAW_PENDING.equals(currentStatus)) {
                return "Only pending orders can be cancelled from the order screen.";
            }

            return dao.cancelOrderByStaff(orderId) ? "SUCCESS" : "Failed to cancel the order. Please try again.";
        }

        return "Invalid order status.";
    }

    /**
     * Normalize a status value so comparisons stay consistent.
     */
    private String normalizeStatus(String status) {
        return OrderStatusHelper.normalize(status);
    }

    /**
     * Check whether a status is supported by the order lifecycle.
     */
    private boolean isAllowedOrderStatus(String status) {
        return Arrays.asList(
                OrderStatusHelper.RAW_PENDING,
                OrderStatusHelper.RAW_CONFIRMED,
                OrderStatusHelper.RAW_SHIPPING,
                OrderStatusHelper.RAW_DELIVERED,
                OrderStatusHelper.RAW_CANCELLED,
                OrderStatusHelper.RAW_RETURNED)
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

    private Order enrichOrder(Order order) {
        if (order == null) {
            return null;
        }

        String displayStatus = OrderStatusHelper.resolveDisplayStatus(order);
        order.setDisplayStatus(displayStatus);
        order.setDisplayStatusLabel(OrderStatusHelper.getDisplayLabel(displayStatus));
        order.setDisplayStatusBadgeClass(OrderStatusHelper.getBadgeClass(displayStatus));
        order.setShippingStatusLabel(OrderStatusHelper.resolveShippingLabel(order.getShippingStatus()));
        order.setShippingStatusBadgeClass(OrderStatusHelper.resolveShippingBadgeClass(order.getShippingStatus()));
        return order;
    }

    private String encodeUrl(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return value == null ? "" : value;
        }
    }

    private static String readConfig(String envName, String propertyName, String defaultValue) {
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue.trim();
        }

        String propertyValue = System.getProperty(propertyName);
        if (propertyValue != null && !propertyValue.trim().isEmpty()) {
            return propertyValue.trim();
        }

        return defaultValue == null ? "" : defaultValue;
    }
}
