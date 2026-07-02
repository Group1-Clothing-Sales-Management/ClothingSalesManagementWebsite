package com.clothingsale.model;

import java.math.BigDecimal;
import java.util.Map;

public class StaffReport {
    private BigDecimal totalRevenue;
    private int completedOrdersCount;
    private Map<String, BigDecimal> revenueBreakdownTime;
    private Map<String, BigDecimal> revenueBreakdownCategory;

    public StaffReport() {
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getCompletedOrdersCount() {
        return completedOrdersCount;
    }

    public void setCompletedOrdersCount(int completedOrdersCount) {
        this.completedOrdersCount = completedOrdersCount;
    }

    public Map<String, BigDecimal> getRevenueBreakdownTime() {
        return revenueBreakdownTime;
    }

    public void setRevenueBreakdownTime(Map<String, BigDecimal> revenueBreakdownTime) {
        this.revenueBreakdownTime = revenueBreakdownTime;
    }

    public Map<String, BigDecimal> getRevenueBreakdownCategory() {
        return revenueBreakdownCategory;
    }

    public void setRevenueBreakdownCategory(Map<String, BigDecimal> revenueBreakdownCategory) {
        this.revenueBreakdownCategory = revenueBreakdownCategory;
    }
}