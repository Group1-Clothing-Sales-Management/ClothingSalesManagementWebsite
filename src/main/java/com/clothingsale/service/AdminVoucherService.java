package com.clothingsale.service;

import com.clothingsale.dao.AdminVoucherDAO;
import com.clothingsale.model.Category;
import com.clothingsale.model.Voucher;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
        if (voucher == null) {
            return "Voucher information is required.";
        }

        if (voucher.getCode() == null || voucher.getCode().trim().isEmpty()) {
            return "Voucher code is required.";
        }

        if (voucherDAO.checkCodeExists(voucher.getCode())) {
            return "Voucher code '" + voucher.getCode() + "' already exists in the system!";
        }

        String validationError = validateVoucherConfiguration(voucher);
        if (validationError != null) {
            return validationError;
        }

        boolean success = voucherDAO.insertVoucher(voucher);
        return success
                ? "SUCCESS"
                : "System error occurred while creating the voucher!";
    }

    public String updateVoucher(Voucher voucher) {
        if (voucher == null) {
            return "Voucher information is required.";
        }

        Voucher currentDB = voucherDAO.getVoucherById(voucher.getId());
        if (currentDB == null) {
            return "Voucher not found!";
        }

        String validationError = validateVoucherConfiguration(voucher);
        if (validationError != null) {
            return validationError;
        }

        java.util.Date now = new java.util.Date();
        if (currentDB.getUsedCount() >= currentDB.getUsageLimit()
                || now.after(currentDB.getEndDate())) {
            return "Cannot modify a voucher that is already expired or fully exhausted.";
        }

        if (voucher.getUsageLimit() < currentDB.getUsedCount()) {
            return "Total supply limit cannot be lower than the already used count ("
                    + currentDB.getUsedCount() + ").";
        }

        if (!voucher.getEndDate().equals(currentDB.getEndDate())) {
            long bufferMillis = 48L * 60 * 60 * 1000;
            java.util.Date minSafeDate = new java.util.Date(now.getTime() + bufferMillis);

            if (voucher.getEndDate().before(minSafeDate)) {
                return "Customer Protection Policy: The new End Date must be at least 48 hours from the current time.";
            }
        }

        boolean success = voucherDAO.updateVoucher(voucher);
        return success
                ? "SUCCESS"
                : "System error occurred while updating the voucher.";
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
        java.sql.Timestamp newEndDate
                = new java.sql.Timestamp(System.currentTimeMillis() + extraMillis);

        if (newEndDate.after(currentDB.getEndDate())) {
            return "Calculated grace period exceeds the original end date. No adjustments applied.";
        }

        boolean success = voucherDAO.terminateVoucherEarly(
                id,
                newEndDate,
                reason.trim()
        );

        return success
                ? "SUCCESS"
                : "System error occurred while scheduling early termination.";
    }

    private String validateVoucherConfiguration(Voucher voucher) {
        if (voucher.getTitle() == null || voucher.getTitle().trim().isEmpty()) {
            return "Campaign title is required.";
        }

        if (voucher.getLimitPerUser() <= 0) {
            return "Per-customer limit must be at least 1!";
        }

        if (voucher.getMinOrderValue() == null) {
            voucher.setMinOrderValue(BigDecimal.ZERO);
        }

        if (voucher.getUsageLimit() <= 0) {
            return "Total supply limit must be greater than 0!";
        }

        String categoryError = validateCategoryScope(voucher);
        if (categoryError != null) {
            return categoryError;
        }

        String moneyValidationError = validateVndAmounts(voucher);
        if (moneyValidationError != null) {
            return moneyValidationError;
        }

        if ("PERCENTAGE".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue() == null
                    || voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0
                    || voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                return "Percentage discount must be between 1% and 100%!";
            }

            if (voucher.getMaxDiscountAmount() == null
                    || voucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) <= 0) {
                return "Please specify a maximum discount limit greater than 0 for percentage-based vouchers!";
            }
        } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue() == null
                    || voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
                return "Fixed discount amount must be greater than 0!";
            }

            voucher.setMaxDiscountAmount(voucher.getDiscountValue());
        } else {
            return "Invalid discount type.";
        }

        if (voucher.getStartDate() == null || voucher.getEndDate() == null) {
            return "Please select both start and end dates!";
        }

        if (!voucher.getEndDate().after(voucher.getStartDate())) {
            return "Validation Error: Campaign End Date & Time must occur strictly after the Start Date!";
        }

        return null;
    }

    private String validateCategoryScope(Voucher voucher) {
        Integer parentCategoryId = voucher.getCategoryId();
        List<Integer> selectedCategoryIds = voucher.getSelectedCategoryIds();

        if (parentCategoryId == null) {
            voucher.setSelectedCategoryIds(new ArrayList<>());
            voucher.setSelectedCategoryNames(new ArrayList<>());
            return null;
        }

        Category parent = voucherDAO.getCategoryById(parentCategoryId);
        if (parent == null) {
            return "The selected parent category does not exist.";
        }

        if (parent.getStatus() != 1) {
            return "The selected parent category is inactive. Restore it before creating or updating the voucher.";
        }

        if (parent.getParentId() != null) {
            return "Please select a root category in the Parent Category field.";
        }

        if (selectedCategoryIds == null || selectedCategoryIds.isEmpty()) {
            return "Please select at least one applicable category.";
        }

        Set<Integer> uniqueIds = new HashSet<>();
        List<Integer> normalizedIds = new ArrayList<>();

        for (Integer selectedId : selectedCategoryIds) {
            if (selectedId == null || selectedId <= 0 || !uniqueIds.add(selectedId)) {
                continue;
            }

            Category selectedCategory = voucherDAO.getCategoryById(selectedId);
            if (selectedCategory == null) {
                return "One of the selected applicable categories does not exist.";
            }

            if (selectedCategory.getStatus() != 1) {
                return "The category '" + selectedCategory.getCategoryName()
                        + "' is inactive and cannot be used by the voucher.";
            }

            boolean validDirectChild = selectedCategory.getParentId() != null
                    && selectedCategory.getParentId().equals(parentCategoryId);
            boolean validStandaloneRoot = selectedCategory.getParentId() == null
                    && selectedCategory.getId() == parentCategoryId
                    && !voucherDAO.hasActiveChildren(parentCategoryId);

            if (!validDirectChild && !validStandaloneRoot) {
                return "All selected categories must belong to the selected parent category.";
            }

            normalizedIds.add(selectedId);
        }

        if (normalizedIds.isEmpty()) {
            return "Please select at least one applicable category.";
        }

        voucher.setSelectedCategoryIds(normalizedIds);
        return null;
    }

    private String validateVndAmounts(Voucher voucher) {
        if (!isWholeVnd(voucher.getMinOrderValue())
                || voucher.getMinOrderValue().compareTo(BigDecimal.ZERO) < 0) {
            return "Minimum eligible spend must be a non-negative whole ₫ amount!";
        }

        if (voucher.getMaxDiscountAmount() != null
                && (!isWholeVnd(voucher.getMaxDiscountAmount())
                || voucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) < 0)) {
            return "Maximum discount must be a non-negative whole ₫ amount!";
        }

        if ("FIXED_AMOUNT".equals(voucher.getDiscountType())
                && !isWholeVnd(voucher.getDiscountValue())) {
            return "Fixed discount must be a whole ₫ amount!";
        }

        return null;
    }

    private boolean isWholeVnd(BigDecimal value) {
        return value != null && value.stripTrailingZeros().scale() <= 0;
    }
}