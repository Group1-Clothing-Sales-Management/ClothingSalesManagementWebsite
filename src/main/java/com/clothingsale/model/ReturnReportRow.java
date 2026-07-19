package com.clothingsale.model;

import java.math.BigDecimal;

/** Một dòng báo cáo tồn kho phát sinh từ hàng khách trả lại. */
public class ReturnReportRow {
    private String productName;
    private String sku;
    private int quantityReturned;
    private int currentStock;
    private BigDecimal refundAmount = BigDecimal.ZERO;

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public int getQuantityReturned() { return quantityReturned; }
    public void setQuantityReturned(int quantityReturned) { this.quantityReturned = quantityReturned; }
    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }
    public BigDecimal getRefundAmount() { return refundAmount; }
    public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount == null ? BigDecimal.ZERO : refundAmount; }
}
