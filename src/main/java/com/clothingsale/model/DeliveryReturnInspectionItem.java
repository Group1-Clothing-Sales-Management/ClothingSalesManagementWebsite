package com.clothingsale.model;

import java.sql.Timestamp;

/**
 * Một dòng hàng được hoàn về sau khi giao hàng thất bại.
 * Chỉ restockQuantity mới được cộng lại vào tồn kho sau khi Staff xác nhận kiểm tra.
 */
public class DeliveryReturnInspectionItem {

    private int id;
    private int inspectionId;
    private int orderDetailId;
    private Integer variantId;
    private String productNameSnapshot;
    private String variantAttributesSnapshot;
    private int returnQuantity;
    private int restockQuantity;
    private int damagedQuantity;
    private int currentStock;
    private String itemNote;
    private boolean inspected;
    private Integer inspectedBy;
    private Timestamp inspectedAt;

    public DeliveryReturnInspectionItem() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getInspectionId() {
        return inspectionId;
    }

    public void setInspectionId(int inspectionId) {
        this.inspectionId = inspectionId;
    }

    public int getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(int orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public Integer getVariantId() {
        return variantId;
    }

    public void setVariantId(Integer variantId) {
        this.variantId = variantId;
    }

    public String getProductNameSnapshot() {
        return productNameSnapshot;
    }

    public void setProductNameSnapshot(String productNameSnapshot) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getVariantAttributesSnapshot() {
        return variantAttributesSnapshot;
    }

    public void setVariantAttributesSnapshot(String variantAttributesSnapshot) {
        this.variantAttributesSnapshot = variantAttributesSnapshot;
    }

    public int getReturnQuantity() {
        return returnQuantity;
    }

    public void setReturnQuantity(int returnQuantity) {
        this.returnQuantity = returnQuantity;
    }

    public int getRestockQuantity() {
        return restockQuantity;
    }

    public void setRestockQuantity(int restockQuantity) {
        this.restockQuantity = restockQuantity;
    }

    public int getDamagedQuantity() {
        return damagedQuantity;
    }

    public void setDamagedQuantity(int damagedQuantity) {
        this.damagedQuantity = damagedQuantity;
    }

    public int getCurrentStock() {
        return currentStock;
    }

    public void setCurrentStock(int currentStock) {
        this.currentStock = currentStock;
    }

    public String getItemNote() {
        return itemNote;
    }

    public void setItemNote(String itemNote) {
        this.itemNote = itemNote;
    }

    public boolean isInspected() {
        return inspected;
    }

    public void setInspected(boolean inspected) {
        this.inspected = inspected;
    }

    public Integer getInspectedBy() {
        return inspectedBy;
    }

    public void setInspectedBy(Integer inspectedBy) {
        this.inspectedBy = inspectedBy;
    }

    public Timestamp getInspectedAt() {
        return inspectedAt;
    }

    public void setInspectedAt(Timestamp inspectedAt) {
        this.inspectedAt = inspectedAt;
    }
}