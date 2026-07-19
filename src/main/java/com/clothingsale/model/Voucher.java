package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class Voucher {

    private int id;
    private String code;
    private String title;

    private String discountType;
    private BigDecimal discountValue;

    private BigDecimal maxDiscountAmount;
    private BigDecimal minOrderValue;

    private Timestamp startDate;
    private Timestamp endDate;

    private int usageLimit;
    private int usedCount;
    private int limitPerUser;       // Giới hạn lượt dùng/mỗi User
    private String terminateReason; // Lý do dừng sớm campaigns
    private Integer categoryId;
    private String categoryName;
    private int userUsedCount;
    private BigDecimal applicableDiscount = BigDecimal.ZERO;
    private List<VoucherUsage> usageHistory = new ArrayList<>();

    public Voucher() {
    }

    public Voucher(int id, String code, String title, String discountType, BigDecimal discountValue, BigDecimal maxDiscountAmount, BigDecimal minOrderValue, Timestamp startDate, Timestamp endDate, int usageLimit, int usedCount, int limitPerUser, String terminateReason, Integer categoryId) {
        this.id = id;
        this.code = code;
        this.title = title;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxDiscountAmount = maxDiscountAmount;
        this.minOrderValue = minOrderValue;
        this.startDate = startDate;
        this.endDate = endDate;
        this.usageLimit = usageLimit;
        this.usedCount = usedCount;
        this.limitPerUser = limitPerUser;
        this.terminateReason = terminateReason;
        this.categoryId = categoryId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public int getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(int usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isAvailable() {

        return usedCount < usageLimit;
    }

    public int getLimitPerUser() {
        return limitPerUser;
    }

    public void setLimitPerUser(int limitPerUser) {
        this.limitPerUser = limitPerUser;
    }

    public String getTerminateReason() {
        return terminateReason;
    }

    public void setTerminateReason(String terminateReason) {
        this.terminateReason = terminateReason;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getUserUsedCount() { return userUsedCount; }
    public void setUserUsedCount(int userUsedCount) { this.userUsedCount = userUsedCount; }
    public BigDecimal getApplicableDiscount() { return applicableDiscount; }
    public void setApplicableDiscount(BigDecimal applicableDiscount) {
        this.applicableDiscount = applicableDiscount == null ? BigDecimal.ZERO : applicableDiscount;
    }
    public List<VoucherUsage> getUsageHistory() { return usageHistory; }
    public void setUsageHistory(List<VoucherUsage> usageHistory) {
        this.usageHistory = usageHistory == null ? new ArrayList<>() : usageHistory;
    }

    public String getCustomerStatus() {
        long now = System.currentTimeMillis();
        if (userUsedCount > 0) return "USED";
        if (startDate == null || startDate.getTime() > now || endDate == null
                || endDate.getTime() < now || usedCount >= usageLimit) return "EXPIRED";
        return "AVAILABLE";
    }

    public long getDaysRemaining() {
        if (endDate == null) return 0;
        long remaining = endDate.getTime() - System.currentTimeMillis();
        return Math.max(0, (long) Math.ceil(remaining / (double) TimeUnit.DAYS.toMillis(1)));
    }
    
}
