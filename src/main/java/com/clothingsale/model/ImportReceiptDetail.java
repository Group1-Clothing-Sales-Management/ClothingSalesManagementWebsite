package com.clothingsale.model;

import java.math.BigDecimal;

public class ImportReceiptDetail {

    private int id;
    private int importReceiptId;
    private int variantId;

    private String sku;
    private String productName;
    private String attributeDetails;

    private int quantity;
    private BigDecimal unitCost;
    private BigDecimal lineTotal;

    public ImportReceiptDetail() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getImportReceiptId() {
        return importReceiptId;
    }

    public void setImportReceiptId(int importReceiptId) {
        this.importReceiptId = importReceiptId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getAttributeDetails() {
        return attributeDetails;
    }

    public void setAttributeDetails(String attributeDetails) {
        this.attributeDetails = attributeDetails;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitCost() {
        return unitCost;
    }

    public void setUnitCost(BigDecimal unitCost) {
        this.unitCost = unitCost;
    }

    public BigDecimal getLineTotal() {
        return lineTotal;
    }

    public void setLineTotal(BigDecimal lineTotal) {
        this.lineTotal = lineTotal;
    }
}
