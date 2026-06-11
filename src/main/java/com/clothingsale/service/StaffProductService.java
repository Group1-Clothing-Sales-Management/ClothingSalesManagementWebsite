package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.util.List;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, int variantId, String name,
            String color, String size, String currentStaff) {

        if (name == null || name.trim().isEmpty()) {
            return "Invalid input data. Product name is required.";
        }

        try {
            boolean isUpdated = productDAO.updateProductInDB(sku, name, color, size);

            if (isUpdated) {
                String actionLog = "Staff updated product -> New name: " + name
                        + " | Color: " + (color != null ? color : "—")
                        + " | Size: " + (size != null ? size : "—");
                productDAO.saveInventoryLog(variantId, 0, currentStaff, actionLog);
                return "SUCCESS";
            } else {
                return "Product not found or database operation failed.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "System error: the database connection was interrupted. Please try again later.";
        }
    }
}