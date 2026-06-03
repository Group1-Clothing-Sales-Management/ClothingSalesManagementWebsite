package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Product;
import java.util.List;

public class AdminManageProductService {

    private final AdminManageProductDAO productDAO = new AdminManageProductDAO();

    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    public boolean addProduct(Product p, String imageName) {
        return productDAO.insertProductWithImage(p, imageName);
    }

    public Product getProductById(int id) {
        return productDAO.getProductById(id);
    }

    public boolean updateProduct(Product p, String imageName) {
        return productDAO.updateProduct(p, imageName);
    }
}
