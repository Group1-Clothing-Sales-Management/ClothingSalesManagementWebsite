package com.clothingsale.service;

import com.clothingsale.dao.CustomerOrderDAO;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.UserAddress;
import java.math.BigDecimal;

import java.util.List;

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
    public List<CartItem> getCartItems(
            int userId) {

        return dao.getCartItems(userId);
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

    public BigDecimal getCartTotal(
            int userId) {

        return dao.getCartTotal(userId);
    }

    public String generateOrderCode() {

        return "ORD"
                + System.currentTimeMillis();
    }

    public boolean validateCheckout(
            int userId) {

        UserAddress address
                = dao.getDefaultAddress(userId);

        BigDecimal total
                = dao.getCartTotal(userId);

        return address != null
                && total.compareTo(BigDecimal.ZERO) > 0;
    }
}
