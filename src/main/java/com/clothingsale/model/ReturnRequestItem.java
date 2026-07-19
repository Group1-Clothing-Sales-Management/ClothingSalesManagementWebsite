package com.clothingsale.model;

import java.math.BigDecimal;

/** Dòng sản phẩm được chọn trong yêu cầu đổi trả. */
public class ReturnRequestItem {

    private int id;
    private int returnRequestId;
    private int orderDetailId;
    private int variantId;
    private String productNameSnapshot;
    private String variantAttributesSnapshot;
    private int orderedQuantity;
    private int quantity;
    private BigDecimal unitPrice = BigDecimal.ZERO;
    private int currentStock;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getReturnRequestId() { return returnRequestId; }
    public void setReturnRequestId(int returnRequestId) { this.returnRequestId = returnRequestId; }
    public int getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(int orderDetailId) { this.orderDetailId = orderDetailId; }
    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }
    public String getProductNameSnapshot() { return productNameSnapshot; }
    public void setProductNameSnapshot(String productNameSnapshot) { this.productNameSnapshot = productNameSnapshot; }
    public String getVariantAttributesSnapshot() { return variantAttributesSnapshot; }
    public void setVariantAttributesSnapshot(String variantAttributesSnapshot) { this.variantAttributesSnapshot = variantAttributesSnapshot; }
    public int getOrderedQuantity() { return orderedQuantity; }
    public void setOrderedQuantity(int orderedQuantity) { this.orderedQuantity = orderedQuantity; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice == null ? BigDecimal.ZERO : unitPrice; }
    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }
    public BigDecimal getLineTotal() { return unitPrice.multiply(BigDecimal.valueOf(quantity)); }
}
