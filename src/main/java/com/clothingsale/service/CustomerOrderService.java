package com.clothingsale.service;

import com.clothingsale.dao.CartDAO;
import com.clothingsale.dao.CustomerOrderDAO;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.model.ReorderResult;
import com.clothingsale.model.UserAddress;
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
import java.util.HashSet;

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
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        for (Voucher voucher : dao.getVouchersForUser(userId)) {
            if (code.trim().equalsIgnoreCase(voucher.getCode())
                    && "AVAILABLE".equals(voucher.getCustomerStatus())
                    && voucher.isCategoryScopeActive()) {
                return voucher;
            }
        }

        return null;
    }

    public List<Voucher> getVouchersForUser(int userId) {
        return dao.getVouchersForUser(userId);
    }

    /**
     * Prepares every voucher for the checkout modal. Each voucher receives its
     * eligible subtotal, estimated discount, usable state and a user-facing
     * reason when it cannot be selected.
     */
    public List<Voucher> getCheckoutVouchers(
            int userId,
            List<CartItem> cartItems) {

        List<Voucher> vouchers = dao.getVouchersForUser(userId);
        Map<Integer, Integer> categoryParentMap
                = dao.getActiveCategoryParentMap();

        for (Voucher voucher : vouchers) {
            BigDecimal applicableSubtotal = calculateApplicableSubtotal(
                    cartItems,
                    voucher,
                    categoryParentMap
            );

            voucher.setApplicableSubtotal(applicableSubtotal);
            voucher.setApplicableDiscount(BigDecimal.ZERO);
            voucher.setAmountNeeded(BigDecimal.ZERO);
            voucher.setEligibleForCheckout(false);
            voucher.setCheckoutIneligibilityReason(null);

            String status = voucher.getCustomerStatus();

            if (!voucher.isCategoryScopeActive()) {
                voucher.setCheckoutIneligibilityReason(
                        "The voucher category is currently inactive."
                );
                continue;
            }

            if ("USED".equals(status)) {
                voucher.setCheckoutIneligibilityReason(
                        "You have reached the usage limit for this voucher."
                );
                continue;
            }

            if ("UPCOMING".equals(status)) {
                voucher.setCheckoutIneligibilityReason(
                        "This voucher campaign has not started yet."
                );
                continue;
            }

            if ("EXHAUSTED".equals(status)) {
                voucher.setCheckoutIneligibilityReason(
                        "This voucher has reached its total usage limit."
                );
                continue;
            }

            if (!"AVAILABLE".equals(status)) {
                voucher.setCheckoutIneligibilityReason(
                        "This voucher is expired or no longer available."
                );
                continue;
            }

            if (applicableSubtotal.compareTo(BigDecimal.ZERO) <= 0) {
                voucher.setCheckoutIneligibilityReason(
                        "No product in your checkout belongs to the applicable category."
                );
                continue;
            }

            BigDecimal minimumSpend = safeMoney(voucher.getMinOrderValue());
            if (applicableSubtotal.compareTo(minimumSpend) < 0) {
                voucher.setAmountNeeded(
                        minimumSpend.subtract(applicableSubtotal)
                                .max(BigDecimal.ZERO)
                );
                voucher.setCheckoutIneligibilityReason(
                        "The eligible product value has not reached the minimum spend."
                );
                continue;
            }

            voucher.setApplicableDiscount(
                    calculateDiscount(applicableSubtotal, voucher)
            );
            voucher.setEligibleForCheckout(true);
        }

        vouchers.sort((first, second) -> {
            if (first.isEligibleForCheckout() != second.isEligibleForCheckout()) {
                return first.isEligibleForCheckout() ? -1 : 1;
            }

            int discountCompare = second.getApplicableDiscount()
                    .compareTo(first.getApplicableDiscount());
            if (discountCompare != 0) {
                return discountCompare;
            }

            if (first.getEndDate() == null && second.getEndDate() == null) {
                return 0;
            }
            if (first.getEndDate() == null) {
                return 1;
            }
            if (second.getEndDate() == null) {
                return -1;
            }
            return first.getEndDate().compareTo(second.getEndDate());
        });

        return vouchers;
    }

    public List<Voucher> getEligibleVouchers(
            int userId,
            List<CartItem> cartItems) {

        List<Voucher> eligible = new ArrayList<>();
        for (Voucher voucher : getCheckoutVouchers(userId, cartItems)) {
            if (voucher.isEligibleForCheckout()) {
                eligible.add(voucher);
            }
        }
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
                "COD",
                "GHN",
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
                "COD",
                "GHN",
                cartItems
        );
    }

    public boolean cancelOrder(int orderId, int userId) {
        return dao.cancelOrder(orderId, userId);
    }

    public BigDecimal calculateApplicableSubtotal(
            List<CartItem> cartItems,
            Voucher voucher) {

        return calculateApplicableSubtotal(
                cartItems,
                voucher,
                dao.getActiveCategoryParentMap()
        );
    }

    private BigDecimal calculateApplicableSubtotal(
            List<CartItem> cartItems,
            Voucher voucher,
            Map<Integer, Integer> categoryParentMap) {

        if (cartItems == null || cartItems.isEmpty()) {
            return BigDecimal.ZERO;
        }

        boolean globalScope = voucher == null || voucher.isGlobalScope();
        List<Integer> selectedCategoryIds = voucher == null
                ? Collections.emptyList()
                : voucher.getSelectedCategoryIds();

        BigDecimal applicableSubtotal = BigDecimal.ZERO;

        for (CartItem item : cartItems) {
            if (item == null
                    || item.getPrice() == null
                    || item.getQuantity() <= 0) {
                continue;
            }

            if (!isCategoryWithinScope(
                    item.getCategoryId(),
                    globalScope,
                    selectedCategoryIds,
                    categoryParentMap)) {
                continue;
            }

            applicableSubtotal = applicableSubtotal.add(
                    item.getPrice().multiply(
                            BigDecimal.valueOf(item.getQuantity())
                    )
            );
        }

        return applicableSubtotal;
    }

    private boolean isCategoryWithinScope(
            int productCategoryId,
            boolean globalScope,
            List<Integer> selectedCategoryIds,
            Map<Integer, Integer> categoryParentMap) {

        if (globalScope) {
            return true;
        }

        if (productCategoryId <= 0
                || selectedCategoryIds == null
                || selectedCategoryIds.isEmpty()
                || categoryParentMap == null
                || !categoryParentMap.containsKey(productCategoryId)) {
            return false;
        }

        Set<Integer> scopeIds = new HashSet<>(selectedCategoryIds);
        Integer currentCategoryId = productCategoryId;
        Set<Integer> visited = new HashSet<>();

        while (currentCategoryId != null && visited.add(currentCategoryId)) {
            if (scopeIds.contains(currentCategoryId)) {
                return true;
            }
            currentCategoryId = categoryParentMap.get(currentCategoryId);
        }

        return false;
    }

    private BigDecimal safeMoney(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    public BigDecimal calculateDiscount(
            BigDecimal applicableSubtotal,
            Voucher voucher) {

        if (voucher == null
                || applicableSubtotal == null
                || applicableSubtotal.compareTo(BigDecimal.ZERO) <= 0
                || applicableSubtotal.compareTo(
                        safeMoney(voucher.getMinOrderValue())) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discountValue = voucher.getDiscountValue();
        if (discountValue == null
                || discountValue.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount;

        if ("PERCENTAGE".equalsIgnoreCase(voucher.getDiscountType())) {
            discount = applicableSubtotal
                    .multiply(discountValue)
                    .divide(
                            BigDecimal.valueOf(100),
                            2,
                            RoundingMode.HALF_UP
                    );

            if (voucher.getMaxDiscountAmount() != null
                    && voucher.getMaxDiscountAmount()
                            .compareTo(BigDecimal.ZERO) > 0
                    && discount.compareTo(
                            voucher.getMaxDiscountAmount()) > 0) {

                discount = voucher.getMaxDiscountAmount();
            }
        } else {
            discount = discountValue;
        }

        return discount
                .min(applicableSubtotal)
                .max(BigDecimal.ZERO);
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