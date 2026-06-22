package com.clothingsale.model;

import java.math.BigDecimal;
import java.util.Map;

public class DashboardStats {

    private BigDecimal monthlyRevenue;
    private int newOrdersCount;
    private int totalProductsCount;
    private int totalCustomersCount;

    // Dữ liệu phục vụ biểu đồ (Charts)
    private Map<String, BigDecimal> revenueTrend;
    private Map<String, Integer> categoryShare;

    public DashboardStats() {
    }

    public BigDecimal getMonthlyRevenue() {
        return monthlyRevenue;
    }

    public void setMonthlyRevenue(BigDecimal monthlyRevenue) {
        this.monthlyRevenue = monthlyRevenue;
    }

    public int getNewOrdersCount() {
        return newOrdersCount;
    }

    public void setNewOrdersCount(int newOrdersCount) {
        this.newOrdersCount = newOrdersCount;
    }

    public int getTotalProductsCount() {
        return totalProductsCount;
    }

    public void setTotalProductsCount(int totalProductsCount) {
        this.totalProductsCount = totalProductsCount;
    }

    public int getTotalCustomersCount() {
        return totalCustomersCount;
    }

    public void setTotalCustomersCount(int totalCustomersCount) {
        this.totalCustomersCount = totalCustomersCount;
    }

    public Map<String, BigDecimal> getRevenueTrend() {
        return revenueTrend;
    }

    public void setRevenueTrend(Map<String, BigDecimal> revenueTrend) {
        this.revenueTrend = revenueTrend;
    }

    public Map<String, Integer> getCategoryShare() {
        return categoryShare;
    }

    public void setCategoryShare(Map<String, Integer> categoryShare) {
        this.categoryShare = categoryShare;
    }
}
