package com.clothingsale.service;

import com.clothingsale.model.Order;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Central place for order lifecycle labels and display mapping.
 */
public final class OrderStatusHelper {

    public static final String RAW_PENDING = "PENDING";
    public static final String RAW_CONFIRMED = "CONFIRMED";
    public static final String RAW_SHIPPING = "SHIPPING";
    public static final String RAW_DELIVERED = "DELIVERED";
    public static final String RAW_CANCELLED = "CANCELLED";
    public static final String RAW_RETURNED = "RETURNED";
    public static final String RAW_PAID = "PAID";
    public static final String RAW_FAILED = "FAILED";

    public static final String DISPLAY_PENDING_APPROVAL = "PENDING_APPROVAL";
    public static final String DISPLAY_APPROVED = "APPROVED";
    public static final String DISPLAY_PREPARING = "PREPARING";
    public static final String DISPLAY_SHIPPING = "SHIPPING";
    public static final String DISPLAY_RECEIVED = "RECEIVED";
    public static final String DISPLAY_COMPLETED = "COMPLETED";
    public static final String DISPLAY_PAID = "PAID";
    public static final String DISPLAY_CANCELLED = "CANCELLED";
    public static final String DISPLAY_RETURNED = "RETURNED";
    public static final String DISPLAY_UNKNOWN = "UNKNOWN";

    private static final Map<String, String> LABELS = new LinkedHashMap<>();
    private static final Map<String, String> BADGE_CLASSES = new LinkedHashMap<>();
    private static final Map<String, String> SHIPPING_LABELS = new LinkedHashMap<>();
    private static final Map<String, String> SHIPPING_BADGE_CLASSES = new LinkedHashMap<>();
    private static final LinkedHashMap<String, String> STATUS_OPTIONS = new LinkedHashMap<>();

    static {
        LABELS.put(DISPLAY_PENDING_APPROVAL, "Chờ duyệt");
        LABELS.put(DISPLAY_APPROVED, "Đã duyệt");
        LABELS.put(DISPLAY_PREPARING, "Chuẩn bị hàng");
        LABELS.put(DISPLAY_SHIPPING, "Đang giao");
        LABELS.put(DISPLAY_RECEIVED, "Đã nhận hàng");
        LABELS.put(DISPLAY_COMPLETED, "Hoàn thành");
        LABELS.put(DISPLAY_PAID, "Đã thanh toán");
        LABELS.put(DISPLAY_CANCELLED, "Đã hủy");
        LABELS.put(DISPLAY_RETURNED, "Hoàn trả");
        LABELS.put(DISPLAY_UNKNOWN, "Không xác định");

        BADGE_CLASSES.put(DISPLAY_PENDING_APPROVAL, "status-pending");
        BADGE_CLASSES.put(DISPLAY_APPROVED, "status-confirmed");
        BADGE_CLASSES.put(DISPLAY_PREPARING, "status-preparing");
        BADGE_CLASSES.put(DISPLAY_SHIPPING, "status-shipping");
        BADGE_CLASSES.put(DISPLAY_RECEIVED, "status-delivered");
        BADGE_CLASSES.put(DISPLAY_COMPLETED, "status-completed");
        BADGE_CLASSES.put(DISPLAY_PAID, "status-paid");
        BADGE_CLASSES.put(DISPLAY_CANCELLED, "status-cancelled");
        BADGE_CLASSES.put(DISPLAY_RETURNED, "status-returned");
        BADGE_CLASSES.put(DISPLAY_UNKNOWN, "status-unknown");

        SHIPPING_LABELS.put("PENDING_PICKUP", "Chuẩn bị hàng");
        SHIPPING_LABELS.put(RAW_SHIPPING, "Đang giao");
        SHIPPING_LABELS.put(RAW_DELIVERED, "Đã nhận hàng");
        SHIPPING_LABELS.put(RAW_FAILED, "Giao thất bại");
        SHIPPING_LABELS.put(RAW_CANCELLED, "Đã hủy");

        SHIPPING_BADGE_CLASSES.put("PENDING_PICKUP", "status-preparing");
        SHIPPING_BADGE_CLASSES.put(RAW_SHIPPING, "status-shipping");
        SHIPPING_BADGE_CLASSES.put(RAW_DELIVERED, "status-delivered");
        SHIPPING_BADGE_CLASSES.put(RAW_FAILED, "status-cancelled");
        SHIPPING_BADGE_CLASSES.put(RAW_CANCELLED, "status-cancelled");

        STATUS_OPTIONS.put("ALL", "Tất cả");
        STATUS_OPTIONS.put(DISPLAY_PENDING_APPROVAL, "Chờ duyệt");
        STATUS_OPTIONS.put(DISPLAY_APPROVED, "Đã duyệt");
        STATUS_OPTIONS.put(DISPLAY_PREPARING, "Chuẩn bị hàng");
        STATUS_OPTIONS.put(DISPLAY_SHIPPING, "Đang giao");
        STATUS_OPTIONS.put(DISPLAY_RECEIVED, "Đã nhận hàng");
        STATUS_OPTIONS.put(DISPLAY_COMPLETED, "Hoàn thành");
        STATUS_OPTIONS.put(DISPLAY_PAID, "Đã thanh toán");
        STATUS_OPTIONS.put(DISPLAY_CANCELLED, "Đã hủy");
        STATUS_OPTIONS.put(DISPLAY_RETURNED, "Hoàn trả");
    }

    private OrderStatusHelper() {
    }

    public static LinkedHashMap<String, String> getStatusOptions() {
        return new LinkedHashMap<>(STATUS_OPTIONS);
    }

    public static String normalize(String status) {
        return status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
    }

    public static String resolveDisplayStatus(Order order) {
        if (order == null) {
            return DISPLAY_UNKNOWN;
        }

        String rawStatus = normalize(order.getOrderStatus());
        String shippingStatus = normalize(order.getShippingStatus());
        String paymentStatus = normalize(order.getPaymentStatus());
        boolean isStoreSale = order.getUserId() <= 0;

        if (RAW_CANCELLED.equals(rawStatus)) {
            return DISPLAY_CANCELLED;
        }

        if (RAW_RETURNED.equals(rawStatus)) {
            return DISPLAY_RETURNED;
        }

        if (RAW_PAID.equals(rawStatus)) {
            return DISPLAY_PAID;
        }

        if (RAW_PENDING.equals(rawStatus)) {
            return DISPLAY_PENDING_APPROVAL;
        }

        if (RAW_CONFIRMED.equals(rawStatus)) {
            if ("PENDING_PICKUP".equals(shippingStatus)) {
                return DISPLAY_PREPARING;
            }

            if (RAW_SHIPPING.equals(shippingStatus)) {
                return DISPLAY_SHIPPING;
            }

            if (RAW_DELIVERED.equals(shippingStatus)) {
                return RAW_PAID.equals(paymentStatus) ? DISPLAY_COMPLETED : DISPLAY_RECEIVED;
            }

            if (isStoreSale && RAW_PAID.equals(paymentStatus)) {
                return DISPLAY_PAID;
            }

            return DISPLAY_APPROVED;
        }

        if (RAW_SHIPPING.equals(rawStatus)) {
            if ("PENDING_PICKUP".equals(shippingStatus)) {
                return DISPLAY_PREPARING;
            }
            if (RAW_SHIPPING.equals(shippingStatus)) {
                return DISPLAY_SHIPPING;
            }
            if (RAW_DELIVERED.equals(shippingStatus)) {
                return RAW_PAID.equals(paymentStatus) ? DISPLAY_COMPLETED : DISPLAY_RECEIVED;
            }
            return DISPLAY_SHIPPING;
        }

        if (RAW_DELIVERED.equals(rawStatus)) {
            return RAW_PAID.equals(paymentStatus) ? DISPLAY_COMPLETED : DISPLAY_RECEIVED;
        }

        if (RAW_FAILED.equals(rawStatus)) {
            return DISPLAY_CANCELLED;
        }

        return rawStatus.isEmpty() ? DISPLAY_UNKNOWN : rawStatus;
    }

    public static String getDisplayLabel(String displayStatus) {
        return LABELS.getOrDefault(normalize(displayStatus), LABELS.get(DISPLAY_UNKNOWN));
    }

    public static String getBadgeClass(String displayStatus) {
        return BADGE_CLASSES.getOrDefault(normalize(displayStatus), BADGE_CLASSES.get(DISPLAY_UNKNOWN));
    }

    public static String resolveShippingLabel(String shippingStatus) {
        String normalized = normalize(shippingStatus);
        return SHIPPING_LABELS.getOrDefault(normalized, normalized.isEmpty() ? "N/A" : normalized);
    }

    public static String resolveShippingBadgeClass(String shippingStatus) {
        String normalized = normalize(shippingStatus);
        return SHIPPING_BADGE_CLASSES.getOrDefault(normalized, "status-unknown");
    }

    public static String resolveRawStatusFromDisplay(String status) {
        String normalized = normalize(status);

        if (DISPLAY_PENDING_APPROVAL.equals(normalized)) {
            return RAW_PENDING;
        }
        if (DISPLAY_APPROVED.equals(normalized) || DISPLAY_PREPARING.equals(normalized)) {
            return RAW_CONFIRMED;
        }
        if (DISPLAY_SHIPPING.equals(normalized)) {
            return RAW_SHIPPING;
        }
        if (DISPLAY_RECEIVED.equals(normalized) || DISPLAY_COMPLETED.equals(normalized)) {
            return RAW_DELIVERED;
        }
        if (DISPLAY_PAID.equals(normalized)) {
            return RAW_PAID;
        }
        if (DISPLAY_CANCELLED.equals(normalized)) {
            return RAW_CANCELLED;
        }
        if (DISPLAY_RETURNED.equals(normalized)) {
            return RAW_RETURNED;
        }

        return normalized;
    }

    public static boolean isFilterableDisplayStatus(String status) {
        String normalized = normalize(status);
        return Arrays.asList(
                DISPLAY_PENDING_APPROVAL,
                DISPLAY_APPROVED,
                DISPLAY_PREPARING,
                DISPLAY_SHIPPING,
                DISPLAY_RECEIVED,
                DISPLAY_COMPLETED,
                DISPLAY_PAID,
                DISPLAY_CANCELLED,
                DISPLAY_RETURNED)
                .contains(normalized);
    }
}
