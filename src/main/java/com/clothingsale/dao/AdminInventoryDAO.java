package com.clothingsale.dao;

import com.clothingsale.model.ImportReceipt;
import com.clothingsale.model.ImportReceiptDetail;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.Supplier;
import com.clothingsale.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class AdminInventoryDAO {

    private static final DateTimeFormatter RECEIPT_TIME_FORMAT
            = DateTimeFormatter.ofPattern(
                    "yyyyMMdd-HHmmss",
                    Locale.ENGLISH
            );

    /* =========================================================
       LOAD PRODUCT VARIANTS
       ========================================================= */
    public List<ProductVariant> getAllActiveVariantsForImport() {
        List<ProductVariant> variants = new ArrayList<>();

        String sql
                = "SELECT "
                + "pv.id, "
                + "pv.product_id, "
                + "pv.sku, "
                + "pv.cost_price, "
                + "pv.sale_price, "
                + "pv.stock_quantity, "
                + "pv.status, "
                + "pv.color, "
                + "pv.size, "
                + "p.product_name "
                + "FROM Product_Variant pv "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "WHERE pv.status <> 'DELETED' "
                + "AND p.status <> 'DELETED' "
                + "ORDER BY p.product_name, pv.sku";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                ProductVariant variant = new ProductVariant();

                String productName
                        = resultSet.getString("product_name");

                String sku
                        = resultSet.getString("sku");

                String color = normalizeVariantValue(
                        resultSet.getString("color")
                );

                String size = normalizeVariantValue(
                        resultSet.getString("size")
                );

                /*
     * Fallback cho dữ liệu cũ:
     * RT-BLZR-GRY-L
     * Phần cuối = Size
     * Phần kế cuối = Color
                 */
                if (sku != null && !sku.trim().isEmpty()) {
                    String[] skuParts = sku.trim().split("-");

                    if (size == null && skuParts.length >= 1) {
                        size = skuParts[skuParts.length - 1];
                    }

                    if (color == null && skuParts.length >= 2) {
                        color = convertColorCode(
                                skuParts[skuParts.length - 2]
                        );
                    }
                }

                variant.setId(
                        resultSet.getInt("id")
                );

                variant.setProductId(
                        resultSet.getInt("product_id")
                );

                variant.setSku(sku);

                variant.setCostPrice(
                        resultSet.getBigDecimal("cost_price")
                );

                variant.setSalePrice(
                        resultSet.getBigDecimal("sale_price")
                );

                variant.setStockQuantity(
                        resultSet.getInt("stock_quantity")
                );

                variant.setStatus(
                        resultSet.getString("status")
                );

                variant.setColor(color);
                variant.setSize(size);

                variant.setAttributeDetails(
                        buildVariantDisplayName(
                                productName,
                                size,
                                color
                        )
                );

                variants.add(variant);
            }
        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load product variants.",
                    exception
            );
        }

        return variants;
    }

    /* =========================================================
       LOAD SUPPLIERS
       ========================================================= */
    public List<Supplier> getAllSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();

        String sql
                = "SELECT "
                + "id, supplier_name, phone, address, status "
                + "FROM Supplier "
                + "WHERE status = 1 "
                + "ORDER BY supplier_name";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                Supplier supplier = new Supplier();

                supplier.setId(resultSet.getInt("id"));
                supplier.setSupplierName(
                        resultSet.getString("supplier_name")
                );
                supplier.setPhone(
                        resultSet.getString("phone")
                );
                supplier.setAddress(
                        resultSet.getString("address")
                );
                supplier.setStatus(
                        resultSet.getBoolean("status")
                );

                suppliers.add(supplier);
            }
        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load suppliers.",
                    exception
            );
        }

        return suppliers;
    }

    /* =========================================================
       LOAD ALL RECEIPTS
       ========================================================= */
    public List<ImportReceipt> getAllImportReceipts() {
        List<ImportReceipt> receipts = new ArrayList<>();

        String sql
                = "SELECT "
                + "ir.id, "
                + "ir.receipt_code, "
                + "ir.supplier_id, "
                + "s.supplier_name, "
                + "ir.user_id, "
                + "creator.full_name AS created_by_name, "
                + "ir.total_amount, "
                + "ir.created_at, "
                + "ir.status, "
                + "ir.note, "
                + "ir.vendor_reference, "
                + "ir.confirmed_by, "
                + "confirmer.full_name AS confirmed_by_name, "
                + "ir.confirmed_at, "
                + "COUNT(ird.id) AS item_count, "
                + "COALESCE(SUM(ird.quantity), 0) "
                + "AS total_quantity "
                + "FROM Import_Receipt ir "
                + "INNER JOIN Supplier s "
                + "ON s.id = ir.supplier_id "
                + "INNER JOIN [User] creator "
                + "ON creator.id = ir.user_id "
                + "LEFT JOIN [User] confirmer "
                + "ON confirmer.id = ir.confirmed_by "
                + "LEFT JOIN Import_Receipt_Detail ird "
                + "ON ird.import_receipt_id = ir.id "
                + "GROUP BY "
                + "ir.id, "
                + "ir.receipt_code, "
                + "ir.supplier_id, "
                + "s.supplier_name, "
                + "ir.user_id, "
                + "creator.full_name, "
                + "ir.total_amount, "
                + "ir.created_at, "
                + "ir.status, "
                + "ir.note, "
                + "ir.vendor_reference, "
                + "ir.confirmed_by, "
                + "confirmer.full_name, "
                + "ir.confirmed_at "
                + "ORDER BY ir.created_at DESC, ir.id DESC";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                receipts.add(mapReceipt(resultSet));
            }
        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load stock receipts.",
                    exception
            );
        }

        return receipts;
    }

    /* =========================================================
       LOAD ONE RECEIPT
       ========================================================= */
    public ImportReceipt getImportReceiptById(int receiptId) {
        String sql
                = "SELECT "
                + "ir.id, "
                + "ir.receipt_code, "
                + "ir.supplier_id, "
                + "s.supplier_name, "
                + "ir.user_id, "
                + "creator.full_name AS created_by_name, "
                + "ir.total_amount, "
                + "ir.created_at, "
                + "ir.status, "
                + "ir.note, "
                + "ir.vendor_reference, "
                + "ir.confirmed_by, "
                + "confirmer.full_name AS confirmed_by_name, "
                + "ir.confirmed_at, "
                + "COUNT(ird.id) AS item_count, "
                + "COALESCE(SUM(ird.quantity), 0) "
                + "AS total_quantity "
                + "FROM Import_Receipt ir "
                + "INNER JOIN Supplier s "
                + "ON s.id = ir.supplier_id "
                + "INNER JOIN [User] creator "
                + "ON creator.id = ir.user_id "
                + "LEFT JOIN [User] confirmer "
                + "ON confirmer.id = ir.confirmed_by "
                + "LEFT JOIN Import_Receipt_Detail ird "
                + "ON ird.import_receipt_id = ir.id "
                + "WHERE ir.id = ? "
                + "GROUP BY "
                + "ir.id, "
                + "ir.receipt_code, "
                + "ir.supplier_id, "
                + "s.supplier_name, "
                + "ir.user_id, "
                + "creator.full_name, "
                + "ir.total_amount, "
                + "ir.created_at, "
                + "ir.status, "
                + "ir.note, "
                + "ir.vendor_reference, "
                + "ir.confirmed_by, "
                + "confirmer.full_name, "
                + "ir.confirmed_at";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, receiptId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapReceipt(resultSet);
                }
            }
        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load stock receipt.",
                    exception
            );
        }

        return null;
    }

    /* =========================================================
       LOAD RECEIPT DETAILS
       ========================================================= */
    public List<ImportReceiptDetail> getImportReceiptDetails(
            int receiptId
    ) {
        List<ImportReceiptDetail> details = new ArrayList<>();

        String sql
                = "SELECT "
                + "ird.id, "
                + "ird.import_receipt_id, "
                + "ird.variant_id, "
                + "ird.quantity, "
                + "ird.unit_cost, "
                + "ird.line_total, "
                + "pv.sku, "
                + "p.product_name, "
                + "pv.color, "
                + "pv.size "
                + "FROM Import_Receipt_Detail ird "
                + "INNER JOIN Product_Variant pv "
                + "ON pv.id = ird.variant_id "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "WHERE ird.import_receipt_id = ? "
                + "ORDER BY ird.id";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, receiptId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    ImportReceiptDetail detail
                            = new ImportReceiptDetail();

                    detail.setId(resultSet.getInt("id"));

                    detail.setImportReceiptId(
                            resultSet.getInt(
                                    "import_receipt_id"
                            )
                    );

                    detail.setVariantId(
                            resultSet.getInt("variant_id")
                    );

                    detail.setQuantity(
                            resultSet.getInt("quantity")
                    );

                    detail.setUnitCost(
                            resultSet.getBigDecimal("unit_cost")
                    );

                    detail.setLineTotal(
                            resultSet.getBigDecimal("line_total")
                    );

                    detail.setSku(
                            resultSet.getString("sku")
                    );

                    detail.setProductName(
                            resultSet.getString("product_name")
                    );

                    detail.setAttributeDetails(
                            buildAttributeText(
                                    resultSet.getString("color"),
                                    resultSet.getString("size")
                            )
                    );

                    details.add(detail);
                }
            }
        } catch (SQLException exception) {
            throw new IllegalStateException(
                    "Unable to load receipt details.",
                    exception
            );
        }

        return details;
    }

    /* =========================================================
       CREATE DRAFT
       ========================================================= */
    public int createDraftReceipt(
            int supplierId,
            int userId,
            String vendorReference,
            String note,
            BigDecimal totalAmount,
            List<ImportReceiptDetail> details
    ) throws SQLException {

        String validateSupplierSql
                = "SELECT 1 "
                + "FROM Supplier "
                + "WHERE id = ? "
                + "AND status = 1";

        String validateVariantSql
                = "SELECT 1 "
                + "FROM Product_Variant pv "
                + "INNER JOIN Product p "
                + "ON p.id = pv.product_id "
                + "WHERE pv.id = ? "
                + "AND pv.status <> 'DELETED' "
                + "AND p.status <> 'DELETED'";

        String insertReceiptSql
                = "INSERT INTO Import_Receipt ("
                + "receipt_code, "
                + "supplier_id, "
                + "user_id, "
                + "total_amount, "
                + "status, "
                + "note, "
                + "vendor_reference, "
                + "created_at"
                + ") VALUES (?, ?, ?, ?, 'DRAFT', ?, ?, GETDATE())";

        String insertDetailSql
                = "INSERT INTO Import_Receipt_Detail ("
                + "import_receipt_id, "
                + "variant_id, "
                + "quantity, "
                + "unit_cost, "
                + "line_total"
                + ") VALUES (?, ?, ?, ?, ?)";

        try (
                Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);

            try {
                assertExists(
                        connection,
                        validateSupplierSql,
                        supplierId,
                        "The supplier does not exist or is inactive."
                );

                try (
                        PreparedStatement validateVariant
                        = connection.prepareStatement(
                                validateVariantSql
                        )) {
                            for (ImportReceiptDetail detail : details) {
                                validateVariant.setInt(
                                        1,
                                        detail.getVariantId()
                                );

                                try (
                                        ResultSet resultSet
                                        = validateVariant.executeQuery()) {
                                    if (!resultSet.next()) {
                                        throw new SQLException(
                                                "Product variant #"
                                                + detail.getVariantId()
                                                + " is unavailable."
                                        );
                                    }
                                }
                            }
                        }

                        String receiptCode = generateReceiptCode();
                        int receiptId;

                        try (
                                PreparedStatement insertReceipt
                                = connection.prepareStatement(
                                        insertReceiptSql,
                                        Statement.RETURN_GENERATED_KEYS
                                )) {
                                    insertReceipt.setString(1, receiptCode);
                                    insertReceipt.setInt(2, supplierId);
                                    insertReceipt.setInt(3, userId);
                                    insertReceipt.setBigDecimal(
                                            4,
                                            totalAmount
                                    );
                                    insertReceipt.setString(5, note);
                                    insertReceipt.setString(
                                            6,
                                            vendorReference
                                    );

                                    if (insertReceipt.executeUpdate() != 1) {
                                        throw new SQLException(
                                                "Unable to create receipt."
                                        );
                                    }

                                    try (
                                            ResultSet generatedKeys
                                            = insertReceipt.getGeneratedKeys()) {
                                        if (!generatedKeys.next()) {
                                            throw new SQLException(
                                                    "Unable to obtain receipt ID."
                                            );
                                        }

                                        receiptId = generatedKeys.getInt(1);
                                    }
                                }

                                try (
                                        PreparedStatement insertDetail
                                        = connection.prepareStatement(
                                                insertDetailSql
                                        )) {
                                            for (ImportReceiptDetail detail : details) {
                                                insertDetail.setInt(1, receiptId);
                                                insertDetail.setInt(
                                                        2,
                                                        detail.getVariantId()
                                                );
                                                insertDetail.setInt(
                                                        3,
                                                        detail.getQuantity()
                                                );
                                                insertDetail.setBigDecimal(
                                                        4,
                                                        detail.getUnitCost()
                                                );
                                                insertDetail.setBigDecimal(
                                                        5,
                                                        detail.getLineTotal()
                                                );

                                                insertDetail.addBatch();
                                            }

                                            insertDetail.executeBatch();
                                        }

                                        connection.commit();
                                        return receiptId;

            } catch (SQLException | RuntimeException exception) {
                rollbackQuietly(connection);
                throw exception;

            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /* =========================================================
       CONFIRM RECEIPT AND POST INVENTORY
       ========================================================= */
    public boolean confirmDraftReceipt(
            int receiptId,
            int confirmedByUserId
    ) throws SQLException {

        String lockReceiptSql
                = "SELECT receipt_code, status "
                + "FROM Import_Receipt "
                + "WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE id = ?";

        String loadDetailsSql
                = "SELECT "
                + "ird.id, "
                + "ird.variant_id, "
                + "ird.quantity, "
                + "ird.unit_cost, "
                + "pv.status AS variant_status, "
                + "p.status AS product_status "
                + "FROM Import_Receipt_Detail ird "
                + "LEFT JOIN Product_Variant pv "
                + "ON pv.id = ird.variant_id "
                + "LEFT JOIN Product p "
                + "ON p.id = pv.product_id "
                + "WHERE ird.import_receipt_id = ? "
                + "ORDER BY ird.id";

        String insertBatchSql
                = "INSERT INTO Product_Batch ("
                + "variant_id, "
                + "batch_code, "
                + "cost_price, "
                + "initial_quantity, "
                + "current_quantity, "
                + "import_receipt_id, "
                + "import_receipt_detail_id, "
                + "created_at"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";

        String insertLogSql
                = "INSERT INTO Inventory_Log ("
                + "variant_id, "
                + "user_id, "
                + "change_quantity, "
                + "transaction_type, "
                + "note, "
                + "created_at"
                + ") VALUES (?, ?, ?, 'IMPORT', ?, GETDATE())";

        /*
         * Cập nhật:
         * - stock_quantity
         * - cost_price theo giá vốn bình quân
         * Không cập nhật sale_price.
         */
        String updateVariantSql
                = "UPDATE Product_Variant "
                + "SET cost_price = "
                + "CAST(("
                + "((cost_price * stock_quantity) + (? * ?)) "
                + "/ NULLIF(stock_quantity + ?, 0)"
                + ") AS DECIMAL(18,2)), "
                + "stock_quantity = stock_quantity + ? "
                + "WHERE id = ? "
                + "AND status <> 'DELETED'";

        String completeReceiptSql
                = "UPDATE Import_Receipt "
                + "SET status = 'COMPLETED', "
                + "confirmed_by = ?, "
                + "confirmed_at = GETDATE() "
                + "WHERE id = ? "
                + "AND status = 'DRAFT'";

        try (
                Connection connection = DBConnection.getConnection()) {
            connection.setTransactionIsolation(
                    Connection.TRANSACTION_SERIALIZABLE
            );

            connection.setAutoCommit(false);

            try {
                String receiptCode;

                try (
                        PreparedStatement lockReceipt
                        = connection.prepareStatement(
                                lockReceiptSql
                        )) {
                            lockReceipt.setInt(1, receiptId);

                            try (
                                    ResultSet resultSet
                                    = lockReceipt.executeQuery()) {
                                if (!resultSet.next()) {
                                    rollbackQuietly(connection);
                                    return false;
                                }

                                if (!"DRAFT".equalsIgnoreCase(
                                        resultSet.getString("status")
                                )) {
                                    rollbackQuietly(connection);
                                    return false;
                                }

                                receiptCode
                                        = resultSet.getString("receipt_code");
                            }
                        }

                        List<ImportReceiptDetail> details
                                = new ArrayList<>();

                        try (
                                PreparedStatement loadDetails
                                = connection.prepareStatement(
                                        loadDetailsSql
                                )) {
                                    loadDetails.setInt(1, receiptId);

                                    try (
                                            ResultSet resultSet
                                            = loadDetails.executeQuery()) {
                                        while (resultSet.next()) {
                                            String variantStatus
                                                    = resultSet.getString(
                                                            "variant_status"
                                                    );

                                            String productStatus
                                                    = resultSet.getString(
                                                            "product_status"
                                                    );

                                            if (variantStatus == null
                                                    || productStatus == null
                                                    || "DELETED".equalsIgnoreCase(
                                                            variantStatus
                                                    )
                                                    || "DELETED".equalsIgnoreCase(
                                                            productStatus
                                                    )) {
                                                throw new SQLException(
                                                        "A product variant is "
                                                        + "no longer available."
                                                );
                                            }

                                            ImportReceiptDetail detail
                                                    = new ImportReceiptDetail();

                                            detail.setId(
                                                    resultSet.getInt("id")
                                            );

                                            detail.setVariantId(
                                                    resultSet.getInt("variant_id")
                                            );

                                            detail.setQuantity(
                                                    resultSet.getInt("quantity")
                                            );

                                            detail.setUnitCost(
                                                    resultSet.getBigDecimal(
                                                            "unit_cost"
                                                    )
                                            );

                                            details.add(detail);
                                        }
                                    }
                                }

                                if (details.isEmpty()) {
                                    rollbackQuietly(connection);
                                    return false;
                                }

                                try (
                                        PreparedStatement insertBatch
                                        = connection.prepareStatement(
                                                insertBatchSql
                                        ); PreparedStatement insertLog
                                        = connection.prepareStatement(
                                                insertLogSql
                                        ); PreparedStatement updateVariant
                                        = connection.prepareStatement(
                                                updateVariantSql
                                        )) {
                                            int sequence = 1;

                                            for (ImportReceiptDetail detail : details) {
                                                String batchCode
                                                        = receiptCode
                                                        + "-"
                                                        + String.format(
                                                                Locale.ENGLISH,
                                                                "%03d",
                                                                sequence++
                                                        );

                                                insertBatch.setInt(
                                                        1,
                                                        detail.getVariantId()
                                                );
                                                insertBatch.setString(2, batchCode);
                                                insertBatch.setBigDecimal(
                                                        3,
                                                        detail.getUnitCost()
                                                );
                                                insertBatch.setInt(
                                                        4,
                                                        detail.getQuantity()
                                                );
                                                insertBatch.setInt(
                                                        5,
                                                        detail.getQuantity()
                                                );
                                                insertBatch.setInt(6, receiptId);
                                                insertBatch.setInt(
                                                        7,
                                                        detail.getId()
                                                );
                                                insertBatch.addBatch();

                                                insertLog.setInt(
                                                        1,
                                                        detail.getVariantId()
                                                );
                                                insertLog.setInt(
                                                        2,
                                                        confirmedByUserId
                                                );
                                                insertLog.setInt(
                                                        3,
                                                        detail.getQuantity()
                                                );
                                                insertLog.setString(
                                                        4,
                                                        "Stock receipt "
                                                        + receiptCode
                                                        + " confirmed. Batch: "
                                                        + batchCode
                                                );
                                                insertLog.addBatch();

                                                updateVariant.setBigDecimal(
                                                        1,
                                                        detail.getUnitCost()
                                                );
                                                updateVariant.setInt(
                                                        2,
                                                        detail.getQuantity()
                                                );
                                                updateVariant.setInt(
                                                        3,
                                                        detail.getQuantity()
                                                );
                                                updateVariant.setInt(
                                                        4,
                                                        detail.getQuantity()
                                                );
                                                updateVariant.setInt(
                                                        5,
                                                        detail.getVariantId()
                                                );
                                                updateVariant.addBatch();
                                            }

                                            insertBatch.executeBatch();
                                            insertLog.executeBatch();

                                            int[] updatedRows
                                                    = updateVariant.executeBatch();

                                            for (int updatedRow : updatedRows) {
                                                if (updatedRow == 0
                                                        || updatedRow
                                                        == Statement.EXECUTE_FAILED) {
                                                    throw new SQLException(
                                                            "A product variant became "
                                                            + "unavailable during confirmation."
                                                    );
                                                }
                                            }
                                        }

                                        try (
                                                PreparedStatement completeReceipt
                                                = connection.prepareStatement(
                                                        completeReceiptSql
                                                )) {
                                                    completeReceipt.setInt(
                                                            1,
                                                            confirmedByUserId
                                                    );
                                                    completeReceipt.setInt(2, receiptId);

                                                    if (completeReceipt.executeUpdate() != 1) {
                                                        throw new SQLException(
                                                                "The receipt status changed "
                                                                + "during confirmation."
                                                        );
                                                    }
                                                }

                                                connection.commit();
                                                return true;

            } catch (SQLException | RuntimeException exception) {
                rollbackQuietly(connection);
                throw exception;

            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /* =========================================================
       CANCEL DRAFT
       ========================================================= */
    public boolean cancelDraftReceipt(
            int receiptId
    ) throws SQLException {

        String sql
                = "UPDATE Import_Receipt "
                + "SET status = 'CANCELLED' "
                + "WHERE id = ? "
                + "AND status = 'DRAFT'";

        try (
                Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, receiptId);
            return statement.executeUpdate() == 1;
        }
    }

    /* =========================================================
       HELPERS
       ========================================================= */
    private ImportReceipt mapReceipt(
            ResultSet resultSet
    ) throws SQLException {

        ImportReceipt receipt = new ImportReceipt();

        receipt.setId(resultSet.getInt("id"));

        receipt.setReceiptCode(
                resultSet.getString("receipt_code")
        );

        receipt.setSupplierId(
                resultSet.getInt("supplier_id")
        );

        receipt.setSupplierName(
                resultSet.getString("supplier_name")
        );

        receipt.setUserId(
                resultSet.getInt("user_id")
        );

        receipt.setCreatedByName(
                resultSet.getString("created_by_name")
        );

        receipt.setTotalAmount(
                resultSet.getBigDecimal("total_amount")
        );

        receipt.setCreatedAt(
                resultSet.getTimestamp("created_at")
        );

        receipt.setStatus(
                resultSet.getString("status")
        );

        receipt.setNote(
                resultSet.getString("note")
        );

        receipt.setVendorReference(
                resultSet.getString("vendor_reference")
        );

        int confirmedBy
                = resultSet.getInt("confirmed_by");

        receipt.setConfirmedBy(
                resultSet.wasNull()
                ? null
                : confirmedBy
        );

        receipt.setConfirmedByName(
                resultSet.getString("confirmed_by_name")
        );

        receipt.setConfirmedAt(
                resultSet.getTimestamp("confirmed_at")
        );

        receipt.setItemCount(
                resultSet.getInt("item_count")
        );

        receipt.setTotalQuantity(
                resultSet.getInt("total_quantity")
        );

        return receipt;
    }

    private static void assertExists(
            Connection connection,
            String sql,
            int id,
            String errorMessage
    ) throws SQLException {

        try (
                PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, id);

            try (
                    ResultSet resultSet
                    = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new SQLException(errorMessage);
                }
            }
        }
    }

    private static String generateReceiptCode() {
        String timePart
                = LocalDateTime.now().format(
                        RECEIPT_TIME_FORMAT
                );

        String randomPart
                = UUID.randomUUID()
                        .toString()
                        .substring(0, 6)
                        .toUpperCase(Locale.ENGLISH);

        return "IR-" + timePart + "-" + randomPart;
    }

    private static String buildVariantDisplayName(
            String productName,
            String size,
            String color
    ) {
        List<String> parts = new ArrayList<>();

        if (productName != null
                && !productName.trim().isEmpty()) {
            parts.add(productName.trim());
        }

        if (size != null
                && !size.trim().isEmpty()) {
            parts.add(size.trim());
        }

        if (color != null
                && !color.trim().isEmpty()) {
            parts.add(color.trim());
        }

        return String.join(" - ", parts);
    }

    private static String normalizeVariantValue(
            String value
    ) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }

    private static String convertColorCode(
            String colorCode
    ) {
        if (colorCode == null) {
            return null;
        }

        switch (colorCode.trim().toUpperCase()) {
            case "BLK":
                return "Black";

            case "WHT":
                return "White";

            case "GRY":
            case "GR":
                return "Gray";

            case "RED":
                return "Red";

            case "BLU":
                return "Blue";

            case "NVY":
                return "Navy";

            case "GRN":
                return "Green";

            case "BRN":
                return "Brown";

            case "BEI":
                return "Beige";

            case "PNK":
                return "Pink";

            default:
                return colorCode.trim().toUpperCase();
        }
    }

    private static String buildAttributeText(
            String color,
            String size
    ) {
        List<String> values = new ArrayList<>();

        if (color != null && !color.trim().isEmpty()) {
            values.add("Color: " + color.trim());
        }

        if (size != null && !size.trim().isEmpty()) {
            values.add("Size: " + size.trim());
        }

        return String.join(" | ", values);
    }

    private static void rollbackQuietly(
            Connection connection
    ) {
        try {
            connection.rollback();
        } catch (SQLException ignored) {
            // Giữ lại exception ban đầu.
        }
    }
}
