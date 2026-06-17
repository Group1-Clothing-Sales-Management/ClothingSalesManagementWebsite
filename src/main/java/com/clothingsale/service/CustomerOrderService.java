package com.clothingsale.service;

import com.clothingsale.dao.CustomerOrderDAO;
import com.clothingsale.model.UserAddress;

import java.util.List;

public class CustomerOrderService {

    private final CustomerOrderDAO dao =
            new CustomerOrderDAO();

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
}