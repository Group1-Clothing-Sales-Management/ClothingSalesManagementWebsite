package com.clothingsale.dao;

import com.clothingsale.model.DashboardStats;
import com.clothingsale.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminDashboardDAO {

    private static final int LOW_STOCK_THRESHOLD = 5;
    private static final DateTimeFormatter RECENT_ORDER_TIME_FORMAT
            = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm");

    public DashboardStats getDashboardOverviewStats(
            LocalDateTime start,
            LocalDateTime endExclusive,
            LocalDateTime previousStart,
            LocalDateTime previousEndExclusive,
            boolean groupByMonth) throws SQLException {

        DashboardStats stats = new DashboardStats();
        List<String> failedSections = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection()) {
            if (connection == null) {
                throw new SQLException("Database connection is unavailable.");
            }

            loadSection("current sales summary", failedSections,
                    () -> loadSalesSummary(connection, start, endExclusive, stats, false));
            loadSection("previous sales summary", failedSections,
                    () -> loadSalesSummary(connection, previousStart, previousEndExclusive, stats, true));
            loadSection("operational summary", failedSections,
                    () -> loadOperationalSummary(connection, stats));
            loadSection("revenue trend", failedSections,
                    () -> stats.setRevenueTrend(
                            loadRevenueTrend(connection, start, endExclusive, groupByMonth)));
            loadSection("order status", failedSections,
                    () -> stats.setOrderStatusDistribution(
                            loadOrderStatusDistribution(connection, start, endExclusive)));
            loadSection("top products", failedSections,
                    () -> stats.setTopProducts(loadTopProducts(connection, start, endExclusive)));
            loadSection("inventory alerts", failedSections,
                    () -> stats.setLowStockItems(loadLowStockItems(connection)));
            loadSection("recent orders", failedSections,
                    () -> stats.setRecentOrders(loadRecentOrders(connection)));
        }

        if (!failedSections.isEmpty()) {
            stats.setErrorMessage(
                    "Some dashboard sections could not be loaded: "
                    + String.join(", ", failedSections) + ".");
        }

        return stats;
    }

    /**
     * A sale is recognized when its latest payment is PAID, or when an order
     * has reached DELIVERED (needed for the current COD flow, which may leave
     * the Payment row as UNPAID). This prevents delivered COD orders from
     * disappearing from the dashboard.
     */
    private void loadSalesSummary(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive,
            DashboardStats stats,
            boolean previousPeriod) throws SQLException {

        BigDecimal revenue;
        int completedSales;

        try {
            SalesAggregate aggregate = queryRecognizedSales(
                    connection, start, endExclusive);
            revenue = aggregate.revenue;
            completedSales = aggregate.orderCount;
        } catch (SQLException primaryError) {
            System.err.println("[Dashboard] Recognized-sales query failed. "
                    + "Using DELIVERED-order fallback. Cause: "
                    + primaryError.getMessage());
            SalesAggregate aggregate = queryDeliveredSalesFallback(
                    connection, start, endExclusive);
            revenue = aggregate.revenue;
            completedSales = aggregate.orderCount;
        }

        int newCustomers = queryNewCustomers(connection, start, endExclusive);

        if (previousPeriod) {
            stats.setPreviousRevenue(revenue);
            stats.setPreviousPaidOrders(completedSales);
            stats.setPreviousNewCustomers(newCustomers);
        } else {
            stats.setRevenue(revenue);
            stats.setPaidOrders(completedSales);
            stats.setNewCustomers(newCustomers);
        }
    }

    private SalesAggregate queryRecognizedSales(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql = recognizedSalesCte()
                + "SELECT COALESCE(SUM(rs.recognized_amount), 0) AS revenue, "
                + "       COUNT(*) AS completed_sales "
                + "FROM RecognizedSales rs "
                + "WHERE rs.recognized_at >= ? "
                + "  AND rs.recognized_at < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new SalesAggregate(
                            safeBigDecimal(rs.getBigDecimal("revenue")),
                            rs.getInt("completed_sales"));
                }
            }
        }
        return new SalesAggregate(BigDecimal.ZERO, 0);
    }

    private SalesAggregate queryDeliveredSalesFallback(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql
                = "SELECT COALESCE(SUM(o.total_payment), 0) AS revenue, "
                + "       COUNT(*) AS completed_sales "
                + "FROM [Order] o "
                + "WHERE o.order_status = 'DELIVERED' "
                + "  AND COALESCE(o.updated_at, o.created_at) >= ? "
                + "  AND COALESCE(o.updated_at, o.created_at) < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new SalesAggregate(
                            safeBigDecimal(rs.getBigDecimal("revenue")),
                            rs.getInt("completed_sales"));
                }
            }
        }
        return new SalesAggregate(BigDecimal.ZERO, 0);
    }

    private int queryNewCustomers(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql
                = "SELECT COUNT(*) AS new_customers "
                + "FROM [User] u "
                + "JOIN Role r ON r.id = u.role_id "
                + "WHERE r.role_name = 'CUSTOMER' "
                + "  AND u.status = 'ACTIVE' "
                + "  AND u.created_at >= ? "
                + "  AND u.created_at < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("new_customers") : 0;
            }
        }
    }

    private void loadOperationalSummary(
            Connection connection,
            DashboardStats stats) throws SQLException {

        String sql
                = "SELECT "
                + "  (SELECT COUNT(*) FROM [Order] "
                + "    WHERE order_status = 'PENDING') AS pending_orders, "
                + "  (SELECT COUNT(*) FROM [Order] "
                + "    WHERE order_status = 'SHIPPING') AS shipping_orders, "
                + "  (SELECT COUNT(*) "
                + "     FROM Product_Variant pv "
                + "     JOIN Product p ON p.id = pv.product_id "
                + "    WHERE p.status = 'ACTIVE' "
                + "      AND pv.status = 'ACTIVE' "
                + "      AND pv.stock_quantity BETWEEN 0 AND ?) "
                + "      AS low_stock_count";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, LOW_STOCK_THRESHOLD);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setPendingOrders(rs.getInt("pending_orders"));
                    stats.setShippingOrders(rs.getInt("shipping_orders"));
                    stats.setLowStockCount(rs.getInt("low_stock_count"));
                }
            }
        }

        stats.setUnansweredFeedbackCount(
                loadUnansweredFeedbackCount(connection));
    }

    /**
     * The repository supports both the migrated Feedback schema and an older
     * schema without admin_response. Do not let that optional migration break
     * the complete dashboard.
     */
    private int loadUnansweredFeedbackCount(Connection connection) throws SQLException {
        String migratedSql
                = "SELECT COUNT(*) AS total "
                + "FROM Feedback f "
                + "WHERE f.status = 1 "
                + "  AND (f.admin_response IS NULL "
                + "       OR LTRIM(RTRIM(CONVERT(NVARCHAR(4000), f.admin_response))) = '')";

        try (PreparedStatement ps = connection.prepareStatement(migratedSql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt("total") : 0;
        } catch (SQLException migratedSchemaError) {
            System.err.println("[Dashboard] Feedback response columns are not "
                    + "available. Treating all visible feedback as unanswered. Cause: "
                    + migratedSchemaError.getMessage());

            String legacySql
                    = "SELECT COUNT(*) AS total FROM Feedback WHERE status = 1";
            try (PreparedStatement ps = connection.prepareStatement(legacySql); ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total") : 0;
            }
        }
    }

    private List<DashboardStats.RevenuePoint> loadRevenueTrend(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive,
            boolean groupByMonth) throws SQLException {

        try {
            return loadRecognizedRevenueTrend(
                    connection, start, endExclusive, groupByMonth);
        } catch (SQLException primaryError) {
            System.err.println("[Dashboard] Recognized revenue trend failed. "
                    + "Using DELIVERED-order fallback. Cause: "
                    + primaryError.getMessage());
            return loadDeliveredRevenueTrendFallback(
                    connection, start, endExclusive, groupByMonth);
        }
    }

    private List<DashboardStats.RevenuePoint> loadRecognizedRevenueTrend(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive,
            boolean groupByMonth) throws SQLException {

        String periodExpression = groupByMonth
                ? "DATEFROMPARTS(YEAR(rs.recognized_at), MONTH(rs.recognized_at), 1)"
                : "CAST(rs.recognized_at AS DATE)";

        String sql = recognizedSalesCte()
                + "SELECT " + periodExpression + " AS period_start, "
                + "       COALESCE(SUM(rs.recognized_amount), 0) AS revenue, "
                + "       COUNT(*) AS completed_sales "
                + "FROM RecognizedSales rs "
                + "WHERE rs.recognized_at >= ? "
                + "  AND rs.recognized_at < ? "
                + "GROUP BY " + periodExpression + " "
                + "ORDER BY period_start";

        return executeRevenueTrend(connection, sql, start, endExclusive,
                "completed_sales");
    }

    private List<DashboardStats.RevenuePoint> loadDeliveredRevenueTrendFallback(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive,
            boolean groupByMonth) throws SQLException {

        String recognizedDate = "COALESCE(o.updated_at, o.created_at)";
        String periodExpression = groupByMonth
                ? "DATEFROMPARTS(YEAR(" + recognizedDate + "), MONTH(" + recognizedDate + "), 1)"
                : "CAST(" + recognizedDate + " AS DATE)";

        String sql
                = "SELECT " + periodExpression + " AS period_start, "
                + "       COALESCE(SUM(o.total_payment), 0) AS revenue, "
                + "       COUNT(*) AS completed_sales "
                + "FROM [Order] o "
                + "WHERE o.order_status = 'DELIVERED' "
                + "  AND " + recognizedDate + " >= ? "
                + "  AND " + recognizedDate + " < ? "
                + "GROUP BY " + periodExpression + " "
                + "ORDER BY period_start";

        return executeRevenueTrend(connection, sql, start, endExclusive,
                "completed_sales");
    }

    private List<DashboardStats.RevenuePoint> executeRevenueTrend(
            Connection connection,
            String sql,
            LocalDateTime start,
            LocalDateTime endExclusive,
            String orderCountColumn) throws SQLException {

        List<DashboardStats.RevenuePoint> points = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate periodDate = rs.getDate("period_start").toLocalDate();
                    DashboardStats.RevenuePoint point = new DashboardStats.RevenuePoint();
                    point.setPeriodKey(periodDate.toString());
                    point.setRevenue(safeBigDecimal(rs.getBigDecimal("revenue")));
                    point.setOrders(rs.getInt(orderCountColumn));
                    points.add(point);
                }
            }
        }
        return points;
    }

    private Map<String, Integer> loadOrderStatusDistribution(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql
                = "SELECT order_status, COUNT(*) AS total "
                + "FROM [Order] "
                + "WHERE created_at >= ? "
                + "  AND created_at < ? "
                + "GROUP BY order_status";

        Map<String, Integer> distribution = new LinkedHashMap<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    distribution.put(rs.getString("order_status"), rs.getInt("total"));
                }
            }
        }
        return distribution;
    }

    private List<DashboardStats.TopProduct> loadTopProducts(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        try {
            return loadRecognizedTopProducts(connection, start, endExclusive);
        } catch (SQLException primaryError) {
            System.err.println("[Dashboard] Recognized top-products query failed. "
                    + "Using DELIVERED-order fallback. Cause: "
                    + primaryError.getMessage());
            return loadDeliveredTopProductsFallback(
                    connection, start, endExclusive);
        }
    }

    private List<DashboardStats.TopProduct> loadRecognizedTopProducts(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql = recognizedSalesCte()
                + "SELECT TOP 5 "
                + "       od.product_name_snapshot, "
                + "       SUM(od.quantity) AS sold_quantity, "
                + "       COUNT(DISTINCT od.order_id) AS order_count, "
                + "       SUM(CAST(od.quantity AS DECIMAL(18,2)) * od.price) "
                + "           AS product_revenue "
                + "FROM Order_Detail od "
                + "JOIN RecognizedSales rs ON rs.order_id = od.order_id "
                + "WHERE rs.recognized_at >= ? "
                + "  AND rs.recognized_at < ? "
                + "GROUP BY od.product_name_snapshot "
                + "ORDER BY sold_quantity DESC, product_revenue DESC";

        return executeTopProducts(connection, sql, start, endExclusive);
    }

    private List<DashboardStats.TopProduct> loadDeliveredTopProductsFallback(
            Connection connection,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        String sql
                = "SELECT TOP 5 "
                + "       od.product_name_snapshot, "
                + "       SUM(od.quantity) AS sold_quantity, "
                + "       COUNT(DISTINCT od.order_id) AS order_count, "
                + "       SUM(CAST(od.quantity AS DECIMAL(18,2)) * od.price) "
                + "           AS product_revenue "
                + "FROM Order_Detail od "
                + "JOIN [Order] o ON o.id = od.order_id "
                + "WHERE o.order_status = 'DELIVERED' "
                + "  AND COALESCE(o.updated_at, o.created_at) >= ? "
                + "  AND COALESCE(o.updated_at, o.created_at) < ? "
                + "GROUP BY od.product_name_snapshot "
                + "ORDER BY sold_quantity DESC, product_revenue DESC";

        return executeTopProducts(connection, sql, start, endExclusive);
    }

    private List<DashboardStats.TopProduct> executeTopProducts(
            Connection connection,
            String sql,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {

        List<DashboardStats.TopProduct> products = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, start, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DashboardStats.TopProduct product = new DashboardStats.TopProduct();
                    product.setProductName(rs.getString("product_name_snapshot"));
                    product.setSoldQuantity(rs.getInt("sold_quantity"));
                    product.setOrderCount(rs.getInt("order_count"));
                    product.setRevenue(
                            safeBigDecimal(rs.getBigDecimal("product_revenue")));
                    products.add(product);
                }
            }
        }
        return products;
    }

    private List<DashboardStats.LowStockItem> loadLowStockItems(
            Connection connection) throws SQLException {

        String sql
                = "SELECT TOP 8 "
                + "       p.id AS product_id, "
                + "       pv.id AS variant_id, "
                + "       p.product_name, "
                + "       pv.sku, "
                + "       pv.stock_quantity "
                + "FROM Product_Variant pv "
                + "JOIN Product p ON p.id = pv.product_id "
                + "WHERE p.status = 'ACTIVE' "
                + "  AND pv.status = 'ACTIVE' "
                + "  AND pv.stock_quantity BETWEEN 0 AND ? "
                + "ORDER BY pv.stock_quantity ASC, "
                + "         p.product_name ASC, pv.sku ASC";

        List<DashboardStats.LowStockItem> items = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, LOW_STOCK_THRESHOLD);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int stockQuantity = rs.getInt("stock_quantity");
                    DashboardStats.LowStockItem item = new DashboardStats.LowStockItem();
                    item.setProductId(rs.getInt("product_id"));
                    item.setVariantId(rs.getInt("variant_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSku(rs.getString("sku"));
                    item.setStockQuantity(stockQuantity);
                    item.setStockLevel(
                            stockQuantity == 0 ? "Out of stock" : "Low stock");
                    items.add(item);
                }
            }
        }
        return items;
    }

    private List<DashboardStats.RecentOrder> loadRecentOrders(
            Connection connection) throws SQLException {

        String sql
                = "SELECT TOP 8 "
                + "       o.id AS order_id, "
                + "       o.order_code, "
                + "       COALESCE(u.full_name, o.recipient_name, "
                + "                'Guest customer') AS customer_name, "
                + "       o.total_payment, "
                + "       o.order_status, "
                + "       COALESCE(pay.payment_status, 'UNPAID') "
                + "           AS payment_status, "
                + "       COALESCE(s.shipping_status, 'NOT_CREATED') "
                + "           AS shipping_status, "
                + "       o.created_at "
                + "FROM [Order] o "
                + "LEFT JOIN [User] u ON u.id = o.user_id "
                + "LEFT JOIN Shipment s ON s.id = o.shipment_id "
                + "OUTER APPLY ( "
                + "    SELECT TOP 1 p.payment_status "
                + "    FROM Payment p "
                + "    WHERE p.order_id = o.id "
                + "    ORDER BY CASE WHEN p.payment_date IS NULL "
                + "                  THEN 1 ELSE 0 END, "
                + "             p.payment_date DESC, p.id DESC "
                + ") pay "
                + "ORDER BY o.created_at DESC, o.id DESC";

        List<DashboardStats.RecentOrder> orders = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DashboardStats.RecentOrder order = new DashboardStats.RecentOrder();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderCode(rs.getString("order_code"));
                order.setCustomerName(rs.getString("customer_name"));
                order.setTotalPayment(
                        safeBigDecimal(rs.getBigDecimal("total_payment")));
                order.setOrderStatus(rs.getString("order_status"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setShippingStatus(rs.getString("shipping_status"));

                Timestamp createdAt = rs.getTimestamp("created_at");
                order.setCreatedAt(createdAt == null
                        ? "—"
                        : createdAt.toLocalDateTime()
                                .format(RECENT_ORDER_TIME_FORMAT));
                orders.add(order);
            }
        }
        return orders;
    }

    private String recognizedSalesCte() {
        return "WITH LatestPayment AS ( "
                + "    SELECT p.order_id, p.amount, p.payment_status, "
                + "           p.payment_date, "
                + "           ROW_NUMBER() OVER ( "
                + "               PARTITION BY p.order_id "
                + "               ORDER BY CASE WHEN p.payment_date IS NULL "
                + "                             THEN 1 ELSE 0 END, "
                + "                        p.payment_date DESC, p.id DESC "
                + "           ) AS rn "
                + "    FROM Payment p "
                + "), RecognizedSales AS ( "
                + "    SELECT o.id AS order_id, "
                + "           CASE "
                + "             WHEN lp.payment_status = 'PAID' "
                + "                  AND lp.payment_date IS NOT NULL "
                + "               THEN lp.payment_date "
                + "             WHEN o.order_status = 'DELIVERED' "
                + "               THEN COALESCE(o.updated_at, o.created_at) "
                + "           END AS recognized_at, "
                + "           CASE "
                + "             WHEN lp.payment_status = 'PAID' "
                + "               THEN COALESCE(lp.amount, o.total_payment) "
                + "             ELSE o.total_payment "
                + "           END AS recognized_amount "
                + "    FROM [Order] o "
                + "    LEFT JOIN LatestPayment lp "
                + "           ON lp.order_id = o.id AND lp.rn = 1 "
                + "    WHERE o.order_status NOT IN ('CANCELLED', 'RETURNED') "
                + "      AND ((lp.payment_status = 'PAID' "
                + "            AND lp.payment_date IS NOT NULL) "
                + "           OR o.order_status = 'DELIVERED') "
                + ") ";
    }

    private void loadSection(
            String sectionName,
            List<String> failedSections,
            SqlTask task) {
        try {
            task.run();
        } catch (SQLException ex) {
            failedSections.add(sectionName);
            System.err.println("[Dashboard] Failed to load " + sectionName
                    + ": " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    private void setDateRange(
            PreparedStatement ps,
            LocalDateTime start,
            LocalDateTime endExclusive) throws SQLException {
        ps.setTimestamp(1, Timestamp.valueOf(start));
        ps.setTimestamp(2, Timestamp.valueOf(endExclusive));
    }

    private BigDecimal safeBigDecimal(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    @FunctionalInterface
    private interface SqlTask {

        void run() throws SQLException;
    }

    private static class SalesAggregate {

        private final BigDecimal revenue;
        private final int orderCount;

        private SalesAggregate(BigDecimal revenue, int orderCount) {
            this.revenue = revenue;
            this.orderCount = orderCount;
        }
    }
}
