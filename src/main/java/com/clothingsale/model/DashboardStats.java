package com.clothingsale.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DashboardStats {

    private String selectedRange;
    private String rangeLabel;
    private String startDate;
    private String endDate;
    private boolean groupedByMonth;

    private BigDecimal revenue = BigDecimal.ZERO;
    private BigDecimal previousRevenue = BigDecimal.ZERO;
    private double revenueChangePercent;

    private int paidOrders;
    private int previousPaidOrders;
    private double paidOrdersChangePercent;

    private BigDecimal averageOrderValue = BigDecimal.ZERO;

    private int newCustomers;
    private int previousNewCustomers;
    private double newCustomersChangePercent;

    private int pendingOrders;
    private int shippingOrders;
    private int lowStockCount;
    private int unansweredFeedbackCount;

    private List<RevenuePoint> revenueTrend = new ArrayList<>();
    private Map<String, Integer> orderStatusDistribution = new LinkedHashMap<>();
    private List<TopProduct> topProducts = new ArrayList<>();
    private List<LowStockItem> lowStockItems = new ArrayList<>();
    private List<RecentOrder> recentOrders = new ArrayList<>();

    private String errorMessage;

    public String getSelectedRange() {
        return selectedRange;
    }

    public void setSelectedRange(String selectedRange) {
        this.selectedRange = selectedRange;
    }

    public String getRangeLabel() {
        return rangeLabel;
    }

    public void setRangeLabel(String rangeLabel) {
        this.rangeLabel = rangeLabel;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public boolean isGroupedByMonth() {
        return groupedByMonth;
    }

    public void setGroupedByMonth(boolean groupedByMonth) {
        this.groupedByMonth = groupedByMonth;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue == null ? BigDecimal.ZERO : revenue;
    }

    public BigDecimal getPreviousRevenue() {
        return previousRevenue;
    }

    public void setPreviousRevenue(BigDecimal previousRevenue) {
        this.previousRevenue = previousRevenue == null ? BigDecimal.ZERO : previousRevenue;
    }

    public double getRevenueChangePercent() {
        return revenueChangePercent;
    }

    public void setRevenueChangePercent(double revenueChangePercent) {
        this.revenueChangePercent = revenueChangePercent;
    }

    public int getPaidOrders() {
        return paidOrders;
    }

    public void setPaidOrders(int paidOrders) {
        this.paidOrders = paidOrders;
    }

    public int getPreviousPaidOrders() {
        return previousPaidOrders;
    }

    public void setPreviousPaidOrders(int previousPaidOrders) {
        this.previousPaidOrders = previousPaidOrders;
    }

    public double getPaidOrdersChangePercent() {
        return paidOrdersChangePercent;
    }

    public void setPaidOrdersChangePercent(double paidOrdersChangePercent) {
        this.paidOrdersChangePercent = paidOrdersChangePercent;
    }

    public BigDecimal getAverageOrderValue() {
        return averageOrderValue;
    }

    public void setAverageOrderValue(BigDecimal averageOrderValue) {
        this.averageOrderValue = averageOrderValue == null ? BigDecimal.ZERO : averageOrderValue;
    }

    public int getNewCustomers() {
        return newCustomers;
    }

    public void setNewCustomers(int newCustomers) {
        this.newCustomers = newCustomers;
    }

    public int getPreviousNewCustomers() {
        return previousNewCustomers;
    }

    public void setPreviousNewCustomers(int previousNewCustomers) {
        this.previousNewCustomers = previousNewCustomers;
    }

    public double getNewCustomersChangePercent() {
        return newCustomersChangePercent;
    }

    public void setNewCustomersChangePercent(double newCustomersChangePercent) {
        this.newCustomersChangePercent = newCustomersChangePercent;
    }

    public int getPendingOrders() {
        return pendingOrders;
    }

    public void setPendingOrders(int pendingOrders) {
        this.pendingOrders = pendingOrders;
    }

    public int getShippingOrders() {
        return shippingOrders;
    }

    public void setShippingOrders(int shippingOrders) {
        this.shippingOrders = shippingOrders;
    }

    public int getLowStockCount() {
        return lowStockCount;
    }

    public void setLowStockCount(int lowStockCount) {
        this.lowStockCount = lowStockCount;
    }

    public int getUnansweredFeedbackCount() {
        return unansweredFeedbackCount;
    }

    public void setUnansweredFeedbackCount(int unansweredFeedbackCount) {
        this.unansweredFeedbackCount = unansweredFeedbackCount;
    }

    public List<RevenuePoint> getRevenueTrend() {
        return revenueTrend;
    }

    public void setRevenueTrend(List<RevenuePoint> revenueTrend) {
        this.revenueTrend = revenueTrend == null ? new ArrayList<>() : revenueTrend;
    }

    public Map<String, Integer> getOrderStatusDistribution() {
        return orderStatusDistribution;
    }

    public void setOrderStatusDistribution(Map<String, Integer> orderStatusDistribution) {
        this.orderStatusDistribution = orderStatusDistribution == null
                ? new LinkedHashMap<>() : orderStatusDistribution;
    }

    public List<TopProduct> getTopProducts() {
        return topProducts;
    }

    public void setTopProducts(List<TopProduct> topProducts) {
        this.topProducts = topProducts == null ? new ArrayList<>() : topProducts;
    }

    public List<LowStockItem> getLowStockItems() {
        return lowStockItems;
    }

    public void setLowStockItems(List<LowStockItem> lowStockItems) {
        this.lowStockItems = lowStockItems == null ? new ArrayList<>() : lowStockItems;
    }

    public List<RecentOrder> getRecentOrders() {
        return recentOrders;
    }

    public void setRecentOrders(List<RecentOrder> recentOrders) {
        this.recentOrders = recentOrders == null ? new ArrayList<>() : recentOrders;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public static class RevenuePoint {

        private String periodKey;
        private String label;
        private BigDecimal revenue = BigDecimal.ZERO;
        private int orders;

        public RevenuePoint() {
        }

        public RevenuePoint(String periodKey, String label, BigDecimal revenue, int orders) {
            this.periodKey = periodKey;
            this.label = label;
            this.revenue = revenue == null ? BigDecimal.ZERO : revenue;
            this.orders = orders;
        }

        public String getPeriodKey() {
            return periodKey;
        }

        public void setPeriodKey(String periodKey) {
            this.periodKey = periodKey;
        }

        public String getLabel() {
            return label;
        }

        public void setLabel(String label) {
            this.label = label;
        }

        public BigDecimal getRevenue() {
            return revenue;
        }

        public void setRevenue(BigDecimal revenue) {
            this.revenue = revenue == null ? BigDecimal.ZERO : revenue;
        }

        public int getOrders() {
            return orders;
        }

        public void setOrders(int orders) {
            this.orders = orders;
        }
    }

    public static class TopProduct {

        private String productName;
        private int soldQuantity;
        private int orderCount;
        private BigDecimal revenue = BigDecimal.ZERO;

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public int getSoldQuantity() {
            return soldQuantity;
        }

        public void setSoldQuantity(int soldQuantity) {
            this.soldQuantity = soldQuantity;
        }

        public int getOrderCount() {
            return orderCount;
        }

        public void setOrderCount(int orderCount) {
            this.orderCount = orderCount;
        }

        public BigDecimal getRevenue() {
            return revenue;
        }

        public void setRevenue(BigDecimal revenue) {
            this.revenue = revenue == null ? BigDecimal.ZERO : revenue;
        }
    }

    public static class LowStockItem {

        private int productId;
        private int variantId;
        private String productName;
        private String sku;
        private int stockQuantity;
        private String stockLevel;

        public int getProductId() {
            return productId;
        }

        public void setProductId(int productId) {
            this.productId = productId;
        }

        public int getVariantId() {
            return variantId;
        }

        public void setVariantId(int variantId) {
            this.variantId = variantId;
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

        public int getStockQuantity() {
            return stockQuantity;
        }

        public void setStockQuantity(int stockQuantity) {
            this.stockQuantity = stockQuantity;
        }

        public String getStockLevel() {
            return stockLevel;
        }

        public void setStockLevel(String stockLevel) {
            this.stockLevel = stockLevel;
        }
    }

    public static class RecentOrder {

        private int orderId;
        private String orderCode;
        private String customerName;
        private BigDecimal totalPayment = BigDecimal.ZERO;
        private String orderStatus;
        private String paymentStatus;
        private String shippingStatus;
        private String createdAt;

        public int getOrderId() {
            return orderId;
        }

        public void setOrderId(int orderId) {
            this.orderId = orderId;
        }

        public String getOrderCode() {
            return orderCode;
        }

        public void setOrderCode(String orderCode) {
            this.orderCode = orderCode;
        }

        public String getCustomerName() {
            return customerName;
        }

        public void setCustomerName(String customerName) {
            this.customerName = customerName;
        }

        public BigDecimal getTotalPayment() {
            return totalPayment;
        }

        public void setTotalPayment(BigDecimal totalPayment) {
            this.totalPayment = totalPayment == null ? BigDecimal.ZERO : totalPayment;
        }

        public String getOrderStatus() {
            return orderStatus;
        }

        public void setOrderStatus(String orderStatus) {
            this.orderStatus = orderStatus;
        }

        public String getPaymentStatus() {
            return paymentStatus;
        }

        public void setPaymentStatus(String paymentStatus) {
            this.paymentStatus = paymentStatus;
        }

        public String getShippingStatus() {
            return shippingStatus;
        }

        public void setShippingStatus(String shippingStatus) {
            this.shippingStatus = shippingStatus;
        }

        public String getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(String createdAt) {
            this.createdAt = createdAt;
        }
    }
}
