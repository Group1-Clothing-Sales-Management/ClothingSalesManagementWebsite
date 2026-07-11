package com.clothingsale.service;

import com.clothingsale.dao.AdminVoucherDAO;
import com.clothingsale.model.Voucher;
import com.clothingsale.model.Category;
import java.math.BigDecimal;
import java.util.List;

public class AdminVoucherService {

    private final AdminVoucherDAO voucherDAO = new AdminVoucherDAO();

    public List<Voucher> getAllVouchers(String search, String statusFilter) {
        return voucherDAO.getAllVouchers(search, statusFilter);
    }

    public Voucher getVoucherById(int id) {
        return voucherDAO.getVoucherById(id);
    }

    public List<Category> getAllCategoriesSimple() {
        return voucherDAO.getAllCategoriesSimple();
    }

    public String createVoucher(Voucher voucher) {
        if (voucherDAO.checkCodeExists(voucher.getCode())) {
            return "Voucher code '" + voucher.getCode() + "' already exists in the system!";
        }

        if (voucher.getLimitPerUser() <= 0) {
            return "Per-customer limit must be at least 1!";
        }

        if ("PERCENTAGE".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0
                    || voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                return "Percentage discount must be between 1% and 100%!";
            }
            if (voucher.getMaxDiscountAmount() == null) {
                return "Please specify a maximum discount limit for percentage-based vouchers!";
            }
        } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
                return "Fixed discount amount must be greater than 0!";
            }
            voucher.setMaxDiscountAmount(voucher.getDiscountValue());
        }

        if (voucher.getStartDate() == null || voucher.getEndDate() == null) {
            return "Please select both start and end dates!";
        }
        
        // KIỂM TRA NGÀY TẠI BACKEND: Đảm bảo thông báo lỗi đồng bộ Toast
        if (!voucher.getEndDate().after(voucher.getStartDate())) {
            return "Validation Error: Campaign End Date & Time must occur strictly after the Start Date!";
        }
        
        if (voucher.getUsageLimit() <= 0) {
            return "Total supply limit must be greater than 0!";
        }

        boolean isSuccess = voucherDAO.insertVoucher(voucher);
        return isSuccess ? "SUCCESS" : "System error occurred while creating the voucher!";
    }

    public String updateVoucher(Voucher voucher) {
        Voucher currentDB = voucherDAO.getVoucherById(voucher.getId());
        if (currentDB == null) {
            return "Voucher not found!";
        }

        if (voucher.getLimitPerUser() <= 0) {
            return "Per-customer limit must be at least 1!";
        }

        java.util.Date now = new java.util.Date();
        if (currentDB.getUsedCount() >= currentDB.getUsageLimit() || now.after(currentDB.getEndDate())) {
            return "Cannot modify a voucher that is already expired or fully exhausted.";
        }
        
        if (voucher.getUsageLimit() < currentDB.getUsedCount()) {
            return "Total supply limit cannot be lower than the already used count (" + currentDB.getUsedCount() + ").";
        }
        
        // KIỂM TRA NGÀY TẠI BACKEND: Chặn lỗi Logic bằng Toast thay vì JS Alert
        if (!voucher.getEndDate().after(voucher.getStartDate())) {
            return "Validation Error: Campaign End Date & Time must occur strictly after the Start Date!";
        }

        // ĐỒNG BỘ VALIDATION TỪ LUỒNG CREATE SANG UPDATE ĐỂ BẢO VỆ DỮ LIỆU
        if ("PERCENTAGE".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0
                    || voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                return "Percentage discount must be between 1% and 100%!";
            }
            if (voucher.getMaxDiscountAmount() == null) {
                return "Please specify a maximum discount limit for percentage-based vouchers!";
            }
        } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
                return "Fixed discount amount must be greater than 0!";
            }
            voucher.setMaxDiscountAmount(voucher.getDiscountValue());
        }

        boolean isSuccess = voucherDAO.updateVoucher(voucher);
        return isSuccess ? "SUCCESS" : "System error occurred while updating the voucher.";
    }

    public String terminateVoucherEarly(int id, int daysLeft, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return "Please provide a reason for the early termination notice.";
        }
        if (daysLeft < 0) {
            return "Grace period days cannot be negative.";
        }

        Voucher currentDB = voucherDAO.getVoucherById(id);
        if (currentDB == null) {
            return "Voucher details not found.";
        }

        long extraMillis = (long) daysLeft * 24 * 60 * 60 * 1000;
        java.sql.Timestamp newEndDate = new java.sql.Timestamp(System.currentTimeMillis() + extraMillis);

        if (newEndDate.after(currentDB.getEndDate())) {
            return "Calculated grace period exceeds the original end date. No adjustments applied.";
        }

        boolean isSuccess = voucherDAO.terminateVoucherEarly(id, newEndDate, reason.trim());
        return isSuccess ? "SUCCESS" : "System error occurred while scheduling early termination.";
    }
}
