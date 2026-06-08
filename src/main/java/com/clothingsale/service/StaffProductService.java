package com.clothingsale.service;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.dao.StaffProductDAO;
import java.math.BigDecimal;
import java.util.List;

public class StaffProductService {

    private StaffProductDAO productDAO = new StaffProductDAO();

    // Lấy toàn bộ danh sách sản phẩm từ DB
    public List<StaffProductModel> getAllProducts() throws Exception {
        return productDAO.getAllProductsFromDB();
    }

    public String updateProductDetails(String sku, String name, String priceStr, String stockStr, String currentStaff) {

        // BR2: Kiểm tra các trường bắt buộc không được để trống (Chặn lỗi Exception E2)
        if (name == null || name.trim().isEmpty() || priceStr == null || stockStr == null || priceStr.trim().isEmpty()
                || stockStr.trim().isEmpty()) {
            return "Dữ liệu nhập vào không hợp lệ! Tên, giá bán và số lượng không được để trống.";
        }

        try {
            BigDecimal salePrice = new BigDecimal(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);

            // Kiểm tra giá trị logic của số lượng tồn kho
            if (stockQuantity < 0) {
                return "Số lượng tồn kho không thể là số âm!";
            }
            if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                return "Giá bán không thể nhỏ hơn 0đ!";
            }

            // Gọi DAO thực thi cập nhật xuống Database
            boolean isUpdated = productDAO.updateProductInDB(sku, name, salePrice, stockQuantity);

            if (isUpdated) {
                List<StaffProductModel> currentList = productDAO.getAllProductsFromDB();
                for (StaffProductModel item : currentList) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        String actionLog = "Staff cập nhật thành công sản phẩm -> Tên mới: " + name + " | Giá mới: "
                                + salePrice + "đ | Tồn kho mới: " + stockQuantity;
                        productDAO.saveInventoryLog(item.getVariantId(), currentStaff, actionLog);
                        break;
                    }
                }
                return "SUCCESS";
            } else {
                return "Không tìm thấy sản phẩm hoặc lỗi thao tác kết nối CSDL.";
            }

        } catch (NumberFormatException e) {
            return "Định dạng giá bán hoặc số lượng nhập vào không đúng kiểm dữ liệu số.";
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi hệ thống mất kết nối CSDL đột ngột. Vui lòng thử lại sau.";
        }
    }
}