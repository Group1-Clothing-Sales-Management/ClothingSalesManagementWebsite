package com.clothingsale.service;

import com.clothingsale.dao.CartDAO;
import com.clothingsale.dao.CustomerOrderDAO;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.model.ReorderResult;
import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Province;
import com.clothingsale.model.District;
import com.clothingsale.model.Ward;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;
import com.clothingsale.model.Voucher;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;

public class CustomerOrderService {

    private final CustomerOrderDAO dao = new CustomerOrderDAO();
    private final CartDAO cartDAO = new CartDAO();

    // =================== ADDRESS ===================
    public List<UserAddress> getAddressesByUserId(int userId) {
        return dao.getAddressesByUserId(userId);
    }

    public UserAddress getAddressById(int addressId) {
        return dao.getAddressById(addressId);
    }

    public UserAddress getDefaultAddress(int userId) {
        return dao.getDefaultAddress(userId);
    }

    public boolean addAddress(UserAddress address) {
        return dao.addAddress(address);
    }

    public boolean updateAddress(UserAddress address) {
        return dao.updateAddress(address);
    }

    public boolean deleteAddress(int userId, int addressId) {
        return dao.deleteAddress(userId, addressId);
    }

    public boolean setDefaultAddress(int userId, int addressId) {
        return dao.setDefaultAddress(userId, addressId);
    }

    public List<Province> getAllProvinces() {
        return dao.getAllProvinces();
    }

    public List<District> getDistrictsByProvince(String provinceId) {
        return dao.getDistrictsByProvince(provinceId);
    }

    public List<Ward> getWardsByDistrict(String districtId) {
        return dao.getWardsByDistrict(districtId);
    }

    // =================== CART ===================
    public List<CartItem> getCartItems(int userId) {
        return dao.getCartItems(userId);
    }

    public List<CartItem> getCartItems(int userId, Set<Integer> selectedVariantIds) {
        return dao.getCartItems(userId, selectedVariantIds);
    }

    public BigDecimal getCartTotal(int userId) {
        return dao.getCartTotal(userId);
    }

    public BigDecimal getCartTotal(int userId, Set<Integer> selected) {
        return dao.getCartTotal(userId, selected);
    }

    public Voucher getVoucherByCode(String code) {
        return dao.getVoucherByCode(code);
    }

    public Voucher getAvailableVoucherForUser(int userId, String code) {
        if (code == null) {
            return null;
        }
        for (Voucher voucher : dao.getVouchersForUser(userId)) {
            if (code.trim().equalsIgnoreCase(voucher.getCode())
                    && "AVAILABLE".equals(voucher.getCustomerStatus())) {
                return voucher;
            }
        }
        return null;
    }

    public List<Voucher> getVouchersForUser(int userId) {
        return dao.getVouchersForUser(userId);
    }

    public List<Voucher> getEligibleVouchers(int userId, BigDecimal subtotal) {
        List<Voucher> eligible = new ArrayList<>();
        Timestamp now = new Timestamp(System.currentTimeMillis());
        for (Voucher voucher : dao.getVouchersForUser(userId)) {
            boolean active = voucher.getStartDate() != null && voucher.getEndDate() != null
                    && !now.before(voucher.getStartDate()) && !now.after(voucher.getEndDate());
            if (active && voucher.isAvailable() && voucher.getUserUsedCount() == 0
                    && subtotal.compareTo(voucher.getMinOrderValue()) >= 0) {
                voucher.setApplicableDiscount(calculateDiscount(subtotal, voucher));
                eligible.add(voucher);
            }
        }
        eligible.sort((a, b) -> b.getApplicableDiscount().compareTo(a.getApplicableDiscount()));
        return eligible;
    }

    // =================== ORDER CORE ===================
    public boolean placeOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note,
            String paymentMethod,
            String carrierName,
            Set<Integer> selectedVariantIds
    ) {
        return dao.placeOrder(
                userId,
                addressId,
                voucherCode,
                note,
                paymentMethod,
                carrierName,
                selectedVariantIds
        );
    }

    public boolean placeBuyNowOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note,
            String paymentMethod,
            String carrierName,
            List<CartItem> cartItems) {

        return dao.placeBuyNowOrder(
                userId,
                addressId,
                voucherCode,
                note,
                paymentMethod,
                carrierName,
                cartItems);
    }

    public boolean cancelOrder(int orderId, int userId) {
        return dao.cancelOrder(orderId, userId);
    }

    public BigDecimal calculateDiscount(BigDecimal subtotal, Voucher voucher) {

        if (voucher == null) {
            return BigDecimal.ZERO;
        }

        if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount;

        if ("PERCENTAGE".equalsIgnoreCase(voucher.getDiscountType())) {

            discount = subtotal
                    .multiply(voucher.getDiscountValue())
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

            if (voucher.getMaxDiscountAmount() != null
                    && discount.compareTo(voucher.getMaxDiscountAmount()) > 0) {

                discount = voucher.getMaxDiscountAmount();
            }

        } else {

            discount = voucher.getDiscountValue();
        }

        return discount.min(subtotal).max(BigDecimal.ZERO);
    }

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = dao.getOrdersByUserId(userId);
        List<Integer> orderIds = new ArrayList<>();
        for (Order order : orders) {
            if (order != null) {
                orderIds.add(order.getId());
            }
        }

        Map<Integer, List<OrderDetail>> detailsByOrderId
                = dao.getOrderDetailsByOrderIds(userId, orderIds);

        for (Order order : orders) {
            enrichOrder(order);
            List<OrderDetail> details = detailsByOrderId.get(order.getId());
            order.setDetails(details != null ? details : Collections.emptyList());
        }
        return orders;
    }

    public List<Order> getActiveOrdersByUserId(int userId) {
        List<Order> result = new java.util.ArrayList<>();

        for (Order order : getOrdersByUserId(userId)) {
            if (!isHistoryOrder(order)) {
                result.add(order);
            }
        }

        return result;
    }

    public List<Order> getOrderHistoryByUserId(int userId) {
        List<Order> result = new java.util.ArrayList<>();

        for (Order order : getOrdersByUserId(userId)) {
            if (isHistoryOrder(order)) {
                result.add(order);
            }
        }

        return result;
    }

    public Map<Integer, CartItem> getCartMap(int userId) {
        return cartDAO.loadCart(userId);
    }

    public ReorderResult reorderToCart(int userId, int orderId) {
        List<OrderDetail> details = dao.getOrderDetailsByOrderId(orderId, userId);

        if (details.isEmpty()) {
            return new ReorderResult(
                    false,
                    0,
                    0,
                    "Order not found or has no items to reorder.");
        }

        Map<Integer, CartItem> cart = cartDAO.loadCart(userId);

        int addedQuantity = 0;
        int skippedLines = 0;
        int adjustedLines = 0;
        Set<Integer> reorderedVariantIds = new LinkedHashSet<>();

        for (OrderDetail detail : details) {
            if (detail == null || detail.getVariantId() <= 0) {
                skippedLines++;
                continue;
            }

            CartItem currentItem
                    = cartDAO.getActiveVariantCartItem(detail.getVariantId());
            int stock = cartDAO.getAvailableStock(detail.getVariantId());

            if (currentItem == null || stock <= 0) {
                skippedLines++;
                continue;
            }

            CartItem existing = cart.get(detail.getVariantId());
            int existingQty = existing != null ? existing.getQuantity() : 0;
            int availableToAdd = stock - existingQty;

            if (availableToAdd <= 0) {
                skippedLines++;
                continue;
            }

            int requestedQty = Math.max(1, detail.getQuantity());
            int addQty = Math.min(requestedQty, availableToAdd);

            if (addQty < requestedQty) {
                adjustedLines++;
            }

            currentItem.setQuantity(existingQty + addQty);
            cart.put(detail.getVariantId(), currentItem);
            reorderedVariantIds.add(detail.getVariantId());
            addedQuantity += addQty;
        }

        if (addedQuantity <= 0) {
            return new ReorderResult(
                    false,
                    0,
                    skippedLines,
                    "Cannot recreate this order because all items are inactive or out of stock.");
        }

        boolean saved = cartDAO.saveCart(userId, cart);

        if (!saved) {
            return new ReorderResult(
                    false,
                    0,
                    skippedLines,
                    "Could not update your cart. Please try again.");
        }

        String message;
        if (skippedLines > 0 || adjustedLines > 0) {
            message = "Added " + addedQuantity
                    + " item(s) to your cart. Some items were skipped or adjusted to current stock.";
        } else {
            message = "Recreated this order in your cart with current product prices.";
        }

        return new ReorderResult(
                true,
                addedQuantity,
                skippedLines,
                message,
                reorderedVariantIds);
    }

    public boolean validateCheckout(int userId) {
        return validateCheckout(userId, null);
    }

    public boolean validateCheckout(int userId, Set<Integer> selectedVariantIds) {

        UserAddress address = dao.getDefaultAddress(userId);

        BigDecimal total = dao.getCartTotal(userId, selectedVariantIds);

        return address != null && total.compareTo(BigDecimal.ZERO) > 0;
    }

    public String generateOrderCode() {
        return "ORD" + System.currentTimeMillis();
    }

    // =================== INTERNAL ===================
    private void enrichOrder(Order order) {
        if (order == null) {
            return;
        }

        String displayStatus
                = OrderStatusHelper.resolveDisplayStatus(order);

        order.setDisplayStatus(displayStatus);
        order.setDisplayStatusLabel(
                OrderStatusHelper.getDisplayLabel(displayStatus)
        );

        order.setDisplayStatusBadgeClass(
                OrderStatusHelper.getBadgeClass(displayStatus)
        );

        order.setShippingStatusLabel(
                OrderStatusHelper.resolveShippingLabel(order.getShippingStatus())
        );

        order.setShippingStatusBadgeClass(
                OrderStatusHelper.resolveShippingBadgeClass(order.getShippingStatus())
        );
    }

    private boolean isHistoryOrder(Order order) {
        if (order == null) {
            return false;
        }

        return isHistoryStatus(order.getOrderStatus())
                || isHistoryStatus(order.getDisplayStatus())
                || isHistoryStatus(order.getShippingStatus());
    }

    private boolean isHistoryStatus(String status) {
        if (status == null) {
            return false;
        }

        String normalized = status.trim().toUpperCase();

        return "CANCELLED".equals(normalized)
                || "DELIVERED".equals(normalized)
                || "SUCCESS".equals(normalized)
                || "RECEIVED".equals(normalized)
                || "COMPLETED".equals(normalized)
                || "PAID".equals(normalized)
                || "RETURNED".equals(normalized)
                || "FAILED".equals(normalized);
    }
}