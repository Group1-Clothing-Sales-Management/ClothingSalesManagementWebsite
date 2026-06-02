package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Product;
import java.util.List;

public class AdminManageProductService {
    
    private final AdminManageProductDAO productDAO = new AdminManageProductDAO();

    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }
}