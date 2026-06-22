package com.clothingsale.service;

import com.clothingsale.dao.CustomerOrderDAO;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.UserAddress;
import java.math.BigDecimal;

import java.util.List;
import java.util.Set;

public class CustomerOrderService {

    private final CustomerOrderDAO dao
            = new CustomerOrderDAO();

    //===================Address==================
    public List<UserAddress> getAddressesByUserId(
            int userId) {
        return dao.getAddressesByUserId(userId);
    }

    public UserAddress getAddressById(
            int addressId) {
        return dao.getAddressById(addressId);
    }

    public UserAddress getDefaultAddress(
            int userId) {
        return dao.getDefaultAddress(userId);
    }

    public boolean addAddress(
            UserAddress address) {
        return dao.addAddress(address);
    }

    public boolean updateAddress(
            UserAddress address) {
        return dao.updateAddress(address);
    }

    public boolean deleteAddress(
            int userId,
            int addressId) {
        return dao.deleteAddress(
                userId,
                addressId);
    }

    public boolean setDefaultAddress(
            int userId,
            int addressId) {
        return dao.setDefaultAddress(
                userId,
                addressId);
    }

    //===============Order===================
    public List<Order> getOrdersByUserId(
            int userId) {

        List<Order> orders = dao.getOrdersByUserId(userId);
        for (Order order : orders) {
            enrichOrder(order);
        }
        return orders;
    }

    public List<CartItem> getCartItems(
            int userId) {

        return dao.getCartItems(userId);
    }

    public List<CartItem> getCartItems(
            int userId,
            Set<Integer> selectedVariantIds) {

        return dao.getCartItems(
                userId,
                selectedVariantIds);
    }

    public boolean placeOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note) {

        return dao.placeOrder(
                userId,
                addressId,
                voucherCode,
                note);
    }

    public boolean placeOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note,
            Set<Integer> selectedVariantIds) {

        return dao.placeOrder(
                userId,
                addressId,
                voucherCode,
                note,
                selectedVariantIds);
    }

    public boolean cancelOrder(
            int orderId,
            int userId) {

        return dao.cancelOrder(
                orderId,
                userId);
    }

    public BigDecimal getCartTotal(
            int userId) {

        return dao.getCartTotal(userId);
    }

    public BigDecimal getCartTotal(
            int userId,
            Set<Integer> selectedVariantIds) {

        return dao.getCartTotal(
                userId,
                selectedVariantIds);
    }

    public String generateOrderCode() {

        return "ORD"
                + System.currentTimeMillis();
    }

    public boolean validateCheckout(
            int userId) {

        return validateCheckout(
                userId,
                null);
    }

    public boolean validateCheckout(
            int userId,
            Set<Integer> selectedVariantIds) {

        UserAddress address
                = dao.getDefaultAddress(userId);

        BigDecimal total
                = dao.getCartTotal(
                        userId,
                        selectedVariantIds);

        return address != null
                && total.compareTo(BigDecimal.ZERO) > 0;
    }

    private void enrichOrder(Order order) {
        if (order == null) {
            return;
        }

        String displayStatus = OrderStatusHelper.resolveDisplayStatus(order);
        order.setDisplayStatus(displayStatus);
        order.setDisplayStatusLabel(OrderStatusHelper.getDisplayLabel(displayStatus));
        order.setDisplayStatusBadgeClass(OrderStatusHelper.getBadgeClass(displayStatus));
        order.setShippingStatusLabel(OrderStatusHelper.resolveShippingLabel(order.getShippingStatus()));
        order.setShippingStatusBadgeClass(OrderStatusHelper.resolveShippingBadgeClass(order.getShippingStatus()));
    }
}
