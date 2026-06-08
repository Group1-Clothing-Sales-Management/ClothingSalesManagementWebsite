package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
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

    public boolean deleteProductSmartly(int id) {
        if (productDAO.isProductInOrders(id)) {
            System.out.println("⚠️ Product ID #" + id + " already exists in orders. Switching to soft delete.");
            return productDAO.softDeleteProduct(id);
        } else {
            System.out.println("✅ Product ID #" + id + " is not in any order. Proceeding with hard delete.");
            return productDAO.hardDeleteProduct(id);
        }
    }

    public List<Brand> getAllBrands() {
        return productDAO.getAllBrands();
    }

    public List<Category> getAllCategories() {
        return productDAO.getAllCategories();
    }
}
