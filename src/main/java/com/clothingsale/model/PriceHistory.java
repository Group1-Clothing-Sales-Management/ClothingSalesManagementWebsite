package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class PriceHistory {

    private long id;
    private Integer variantId;

    private String productNameSnapshot;
    private String skuSnapshot;
    private String colorSnapshot;
    private String sizeSnapshot;

    private BigDecimal oldListPrice;
    private BigDecimal newListPrice;

    private BigDecimal oldSalePrice;
    private BigDecimal newSalePrice;

    private BigDecimal costPriceSnapshot;

    private String changeType;
    private String changeReason;

    private Integer changedBy;
    private String changedByNameSnapshot;
    private Timestamp changedAt;

    public PriceHistory() {
    }

    public String getVariantDisplayName() {
        StringBuilder displayName = new StringBuilder();

        appendPart(displayName, productNameSnapshot);
        appendPart(displayName, sizeSnapshot);
        appendPart(displayName, colorSnapshot);

        return displayName.toString();
    }

    private void appendPart(
            StringBuilder builder,
            String value
    ) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (builder.length() > 0) {
            builder.append(" - ");
        }

        builder.append(value.trim());
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
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

    public void setProductNameSnapshot(
            String productNameSnapshot
    ) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getSkuSnapshot() {
        return skuSnapshot;
    }

    public void setSkuSnapshot(String skuSnapshot) {
        this.skuSnapshot = skuSnapshot;
    }

    public String getColorSnapshot() {
        return colorSnapshot;
    }

    public void setColorSnapshot(String colorSnapshot) {
        this.colorSnapshot = colorSnapshot;
    }

    public String getSizeSnapshot() {
        return sizeSnapshot;
    }

    public void setSizeSnapshot(String sizeSnapshot) {
        this.sizeSnapshot = sizeSnapshot;
    }

    public BigDecimal getOldListPrice() {
        return oldListPrice;
    }

    public void setOldListPrice(BigDecimal oldListPrice) {
        this.oldListPrice = oldListPrice;
    }

    public BigDecimal getNewListPrice() {
        return newListPrice;
    }

    public void setNewListPrice(BigDecimal newListPrice) {
        this.newListPrice = newListPrice;
    }

    public BigDecimal getOldSalePrice() {
        return oldSalePrice;
    }

    public void setOldSalePrice(BigDecimal oldSalePrice) {
        this.oldSalePrice = oldSalePrice;
    }

    public BigDecimal getNewSalePrice() {
        return newSalePrice;
    }

    public void setNewSalePrice(BigDecimal newSalePrice) {
        this.newSalePrice = newSalePrice;
    }

    public BigDecimal getCostPriceSnapshot() {
        return costPriceSnapshot;
    }

    public void setCostPriceSnapshot(
            BigDecimal costPriceSnapshot
    ) {
        this.costPriceSnapshot = costPriceSnapshot;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getChangeReason() {
        return changeReason;
    }

    public void setChangeReason(String changeReason) {
        this.changeReason = changeReason;
    }

    public Integer getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Integer changedBy) {
        this.changedBy = changedBy;
    }

    public String getChangedByNameSnapshot() {
        return changedByNameSnapshot;
    }

    public void setChangedByNameSnapshot(
            String changedByNameSnapshot
    ) {
        this.changedByNameSnapshot = changedByNameSnapshot;
    }

    public Timestamp getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(Timestamp changedAt) {
        this.changedAt = changedAt;
    }
}
