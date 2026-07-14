package com.clothingsale.model;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;

public class PriceManagementItem {

    private int variantId;
    private int productId;

    private String productName;
    private String sku;
    private String color;
    private String size;

    private BigDecimal costPrice;
    private BigDecimal listPrice;
    private BigDecimal salePrice;

    private int stockQuantity;

    private String variantStatus;
    private String productStatus;

    private Timestamp priceUpdatedAt;
    private Integer priceUpdatedBy;
    private String priceUpdatedByName;

    public PriceManagementItem() {
    }

    /**
     * Lợi nhuận gộp trên một sản phẩm.
     *
     * profit = salePrice - costPrice
     */
    public BigDecimal getProfitAmount() {
        if (salePrice == null || costPrice == null) {
            return BigDecimal.ZERO;
        }

        return salePrice
                .subtract(costPrice)
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Biên lợi nhuận tính theo giá bán.
     *
     * margin = (salePrice - costPrice) / salePrice * 100
     */
    public BigDecimal getMarginPercentage() {
        if (salePrice == null
                || costPrice == null
                || salePrice.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        return salePrice
                .subtract(costPrice)
                .divide(
                        salePrice,
                        6,
                        RoundingMode.HALF_UP
                )
                .multiply(new BigDecimal("100"))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Phần trăm tăng từ giá vốn lên giá bán.
     *
     * markup = (salePrice - costPrice) / costPrice * 100
     */
    public BigDecimal getMarkupPercentage() {
        if (salePrice == null
                || costPrice == null
                || costPrice.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        return salePrice
                .subtract(costPrice)
                .divide(
                        costPrice,
                        6,
                        RoundingMode.HALF_UP
                )
                .multiply(new BigDecimal("100"))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Phần trăm giảm từ giá niêm yết xuống giá bán.
     */
    public BigDecimal getDiscountPercentage() {
        if (listPrice == null
                || salePrice == null
                || listPrice.compareTo(BigDecimal.ZERO) <= 0
                || salePrice.compareTo(listPrice) >= 0) {
            return BigDecimal.ZERO;
        }

        return listPrice
                .subtract(salePrice)
                .divide(
                        listPrice,
                        6,
                        RoundingMode.HALF_UP
                )
                .multiply(new BigDecimal("100"))
                .setScale(2, RoundingMode.HALF_UP);
    }

    public boolean isUnpriced() {
        return listPrice == null
                || salePrice == null
                || listPrice.compareTo(BigDecimal.ZERO) <= 0
                || salePrice.compareTo(BigDecimal.ZERO) <= 0;
    }

    public boolean isBelowCost() {
        return salePrice != null
                && costPrice != null
                && salePrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(costPrice) < 0;
    }

    public boolean isDiscounted() {
        return listPrice != null
                && salePrice != null
                && listPrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(listPrice) < 0;
    }

    /**
     * Trạng thái dùng để hiển thị badge trên JSP.
     */
    public String getPriceStatus() {
        if (isUnpriced()) {
            return "UNPRICED";
        }

        if (isBelowCost()) {
            return "BELOW_COST";
        }

        if (isDiscounted()) {
            return "DISCOUNTED";
        }

        return "REGULAR";
    }

    /**
     * Tên hiển thị đúng yêu cầu:
     * Product name - Size - Color
     */
    public String getDisplayName() {
        StringBuilder displayName = new StringBuilder();

        appendPart(displayName, productName);
        appendPart(displayName, size);
        appendPart(displayName, color);

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

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public void setListPrice(BigDecimal listPrice) {
        this.listPrice = listPrice;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public String getVariantStatus() {
        return variantStatus;
    }

    public void setVariantStatus(String variantStatus) {
        this.variantStatus = variantStatus;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }

    public Timestamp getPriceUpdatedAt() {
        return priceUpdatedAt;
    }

    public void setPriceUpdatedAt(Timestamp priceUpdatedAt) {
        this.priceUpdatedAt = priceUpdatedAt;
    }

    public Integer getPriceUpdatedBy() {
        return priceUpdatedBy;
    }

    public void setPriceUpdatedBy(Integer priceUpdatedBy) {
        this.priceUpdatedBy = priceUpdatedBy;
    }

    public String getPriceUpdatedByName() {
        return priceUpdatedByName;
    }

    public void setPriceUpdatedByName(
            String priceUpdatedByName
    ) {
        this.priceUpdatedByName = priceUpdatedByName;
    }
}