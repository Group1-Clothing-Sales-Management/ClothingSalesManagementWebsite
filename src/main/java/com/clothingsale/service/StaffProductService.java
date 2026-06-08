package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.math.BigDecimal;
import java.util.List;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    // Load the full product list from the database.
    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, String name, String priceStr, String stockStr, String currentStaff) {

        // BR2: Validate required fields before touching the database.
        if (name == null || name.trim().isEmpty() || priceStr == null || stockStr == null || priceStr.trim().isEmpty()
                || stockStr.trim().isEmpty()) {
            return "Invalid input data. Name, sale price, and stock quantity are required.";
        }

        try {
            BigDecimal salePrice = new BigDecimal(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);

            // Validate the stock quantity and sale price values.
            if (stockQuantity < 0) {
                return "Stock quantity cannot be negative.";
            }
            if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                return "Sale price cannot be less than 0.";
            }

            // Persist the update through the DAO layer.
            boolean isUpdated = productDAO.updateProductInDB(sku, name, salePrice, stockQuantity);

            if (isUpdated) {
                List<StaffProductModel> currentList = productDAO.getAllProductsFromDB();
                for (StaffProductModel item : currentList) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        String actionLog = "Staff successfully updated product -> New name: " + name + " | New price: "
                                + salePrice + " VND | New stock: " + stockQuantity;
                        productDAO.saveInventoryLog(item.getVariantId(), currentStaff, actionLog);
                        break;
                    }
                }
                return "SUCCESS";
            } else {
                return "Product not found or database operation failed.";
            }

        } catch (NumberFormatException e) {
            return "The sale price or stock quantity has an invalid numeric format.";
        } catch (Exception e) {
            e.printStackTrace();
            return "System error: the database connection was interrupted. Please try again later.";
        }
    }
}
