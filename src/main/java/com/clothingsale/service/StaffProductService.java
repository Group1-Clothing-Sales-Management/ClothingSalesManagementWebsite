package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.math.BigDecimal;
import java.util.List;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, int variantId, String name, String priceStr, String currentStaff) {

        if (name == null || name.trim().isEmpty()
                || priceStr == null || priceStr.trim().isEmpty()) {
            return "Invalid input data. Name and sale price are required.";
        }

        try {
            BigDecimal salePrice = new BigDecimal(priceStr);

            if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                return "Sale price cannot be less than 0.";
            }

            boolean isUpdated = productDAO.updateProductInDB(sku, name, salePrice);

            if (isUpdated) {
                String actionLog = "Staff updated product -> New name: " + name
                        + " | New price: " + salePrice + " VND";
                productDAO.saveInventoryLog(variantId, 0, currentStaff, actionLog);
                return "SUCCESS";
            } else {
                return "Product not found or database operation failed.";
            }

        } catch (NumberFormatException e) {
            return "The sale price has an invalid numeric format.";
        } catch (Exception e) {
            e.printStackTrace();
            return "System error: the database connection was interrupted. Please try again later.";
        }
    }
}