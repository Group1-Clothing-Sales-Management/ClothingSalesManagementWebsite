package com.clothingsale.service;

import com.clothingsale.dao.AdminInventoryDAO;
import com.clothingsale.model.ImportReceipt;
import com.clothingsale.model.ImportReceiptDetail;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.Supplier;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AdminInventoryService {

    private static final int MAX_LINE_QUANTITY = 1_000_000;

    private static final BigDecimal MAX_UNIT_COST =
            new BigDecimal("9999999999.99");

    private final AdminInventoryDAO inventoryDAO;

    public AdminInventoryService() {
        this.inventoryDAO = new AdminInventoryDAO();
    }

    public List<ProductVariant> getImportableVariants() {
        return inventoryDAO.getAllActiveVariantsForImport();
    }

    public List<Supplier> getActiveSuppliers() {
        return inventoryDAO.getAllSuppliers();
    }

    public List<ImportReceipt> getReceipts() {
        return inventoryDAO.getAllImportReceipts();
    }

    public ImportReceipt getReceipt(int receiptId) {
        requirePositiveId(receiptId, "Receipt ID");
        return inventoryDAO.getImportReceiptById(receiptId);
    }

    public List<ImportReceiptDetail> getReceiptDetails(int receiptId) {
        requirePositiveId(receiptId, "Receipt ID");
        return inventoryDAO.getImportReceiptDetails(receiptId);
    }

    public int createDraft(
            int supplierId,
            int userId,
            String vendorReference,
            String note,
            List<ImportReceiptDetail> details
    ) throws SQLException {

        requirePositiveId(supplierId, "Supplier");
        requirePositiveId(userId, "Authenticated user");

        validateLength(vendorReference, 100, "Vendor reference");
        validateLength(note, 500, "Note");

        if (details == null || details.isEmpty()) {
            throw new IllegalArgumentException(
                    "Add at least one product variant to the receipt."
            );
        }

        Set<Integer> variantIds = new HashSet<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (ImportReceiptDetail detail : details) {
            requirePositiveId(detail.getVariantId(), "Product variant");

            if (!variantIds.add(detail.getVariantId())) {
                throw new IllegalArgumentException(
                        "The same product variant cannot appear twice."
                );
            }

            if (detail.getQuantity() <= 0
                    || detail.getQuantity() > MAX_LINE_QUANTITY) {
                throw new IllegalArgumentException(
                        "Quantity must be between 1 and "
                        + MAX_LINE_QUANTITY + "."
                );
            }

            if (detail.getUnitCost() == null
                    || detail.getUnitCost().compareTo(BigDecimal.ZERO) <= 0
                    || detail.getUnitCost().compareTo(MAX_UNIT_COST) > 0) {
                throw new IllegalArgumentException(
                        "Unit cost must be greater than zero."
                );
            }

            BigDecimal normalizedUnitCost =
                    detail.getUnitCost().setScale(
                            2,
                            RoundingMode.HALF_UP
                    );

            BigDecimal lineTotal = normalizedUnitCost
                    .multiply(BigDecimal.valueOf(detail.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP);

            detail.setUnitCost(normalizedUnitCost);
            detail.setLineTotal(lineTotal);

            totalAmount = totalAmount.add(lineTotal);
        }

        return inventoryDAO.createDraftReceipt(
                supplierId,
                userId,
                trimToNull(vendorReference),
                trimToNull(note),
                totalAmount,
                details
        );
    }

    public void confirmReceipt(
            int receiptId,
            int userId
    ) throws SQLException {

        requirePositiveId(receiptId, "Receipt ID");
        requirePositiveId(userId, "Authenticated user");

        boolean success = inventoryDAO.confirmDraftReceipt(
                receiptId,
                userId
        );

        if (!success) {
            throw new IllegalStateException(
                    "The receipt does not exist, has no items, "
                    + "or is no longer in DRAFT status."
            );
        }
    }

    public void cancelDraft(int receiptId) throws SQLException {
        requirePositiveId(receiptId, "Receipt ID");

        if (!inventoryDAO.cancelDraftReceipt(receiptId)) {
            throw new IllegalStateException(
                    "Only a DRAFT receipt can be cancelled."
            );
        }
    }

    private static void requirePositiveId(
            int value,
            String fieldName
    ) {
        if (value <= 0) {
            throw new IllegalArgumentException(
                    fieldName + " is invalid."
            );
        }
    }

    private static void validateLength(
            String value,
            int maximumLength,
            String fieldName
    ) {
        if (value != null
                && value.trim().length() > maximumLength) {
            throw new IllegalArgumentException(
                    fieldName
                    + " must not exceed "
                    + maximumLength
                    + " characters."
            );
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}