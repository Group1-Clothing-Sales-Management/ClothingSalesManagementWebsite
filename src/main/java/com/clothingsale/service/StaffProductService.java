package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.util.List;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, int variantId, String color,
            String size, String currentStaff) {

        if (sku == null || sku.trim().isEmpty()) {
            return "Invalid input data. SKU is required.";
        }

        try {
            boolean isUpdated = productDAO.updateProductInDB(sku, color, size);

            if (isUpdated) {
                String actionLog = "Staff updated product variant -> SKU: " + sku
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
