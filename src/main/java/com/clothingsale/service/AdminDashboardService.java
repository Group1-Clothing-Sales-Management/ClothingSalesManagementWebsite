package com.clothingsale.service;

import com.clothingsale.dao.AdminDashboardDAO;
import com.clothingsale.model.DashboardStats;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class AdminDashboardService {

    private static final ZoneId BUSINESS_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final int MAX_CUSTOM_RANGE_DAYS = 366;

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    public DashboardStats getDashboardOverview(
            String rangeKey,
            String customStart,
            String customEnd) throws SQLException {

        DashboardDateRange range = resolveRange(rangeKey, customStart, customEnd);
        boolean groupByMonth = ChronoUnit.DAYS.between(range.startDate, range.endDateExclusive) > 62;

        long periodDays = ChronoUnit.DAYS.between(range.startDate, range.endDateExclusive);
        LocalDate previousEnd = range.startDate;
        LocalDate previousStart = previousEnd.minusDays(periodDays);

        DashboardStats stats = dashboardDAO.getDashboardOverviewStats(
                range.startDate.atStartOfDay(),
                range.endDateExclusive.atStartOfDay(),
                previousStart.atStartOfDay(),
                previousEnd.atStartOfDay(),
                groupByMonth
        );

        stats.setSelectedRange(range.rangeKey);
        stats.setRangeLabel(range.rangeLabel);
        stats.setStartDate(range.startDate.toString());
        stats.setEndDate(range.endDateExclusive.minusDays(1).toString());
        stats.setGroupedByMonth(groupByMonth);

        stats.setRevenueChangePercent(calculateChange(
                stats.getRevenue(), stats.getPreviousRevenue()));
        stats.setPaidOrdersChangePercent(calculateChange(
                stats.getPaidOrders(), stats.getPreviousPaidOrders()));
        stats.setNewCustomersChangePercent(calculateChange(
                stats.getNewCustomers(), stats.getPreviousNewCustomers()));

        if (stats.getPaidOrders() > 0) {
            stats.setAverageOrderValue(stats.getRevenue().divide(
                    BigDecimal.valueOf(stats.getPaidOrders()),
                    0,
                    RoundingMode.HALF_UP));
        } else {
            stats.setAverageOrderValue(BigDecimal.ZERO);
        }

        stats.setRevenueTrend(fillMissingRevenuePeriods(
                stats.getRevenueTrend(), range.startDate, range.endDateExclusive, groupByMonth));
        stats.setOrderStatusDistribution(normalizeOrderStatuses(
                stats.getOrderStatusDistribution()));

        return stats;
    }

    private DashboardDateRange resolveRange(
            String requestedRange,
            String customStart,
            String customEnd) {

        String rangeKey = requestedRange == null || requestedRange.trim().isEmpty()
                ? "this_month"
                : requestedRange.trim().toLowerCase(Locale.ENGLISH);

        LocalDate today = LocalDate.now(BUSINESS_ZONE);

        switch (rangeKey) {
            case "today":
                return new DashboardDateRange(
                        "today", "Today", today, today.plusDays(1));

            case "last_7_days":
                return new DashboardDateRange(
                        "last_7_days", "Last 7 Days", today.minusDays(6), today.plusDays(1));

            case "last_30_days":
                return new DashboardDateRange(
                        "last_30_days", "Last 30 Days", today.minusDays(29), today.plusDays(1));

            case "last_month":
                LocalDate firstDayOfCurrentMonth = today.withDayOfMonth(1);
                LocalDate firstDayOfPreviousMonth = firstDayOfCurrentMonth.minusMonths(1);
                return new DashboardDateRange(
                        "last_month", "Last Month",
                        firstDayOfPreviousMonth, firstDayOfCurrentMonth);

            case "custom":
                return resolveCustomRange(customStart, customEnd);

            case "this_month":
            default:
                LocalDate firstDay = today.withDayOfMonth(1);
                return new DashboardDateRange(
                        "this_month", "This Month", firstDay, today.plusDays(1));
        }
    }

    private DashboardDateRange resolveCustomRange(String customStart, String customEnd) {
        if (customStart == null || customEnd == null
                || customStart.trim().isEmpty() || customEnd.trim().isEmpty()) {
            throw new IllegalArgumentException("Start date and end date are required.");
        }

        try {
            LocalDate start = LocalDate.parse(customStart.trim());
            LocalDate endInclusive = LocalDate.parse(customEnd.trim());

            if (endInclusive.isBefore(start)) {
                throw new IllegalArgumentException("End date cannot be before start date.");
            }

            long totalDays = ChronoUnit.DAYS.between(start, endInclusive) + 1;
            if (totalDays > MAX_CUSTOM_RANGE_DAYS) {
                throw new IllegalArgumentException(
                        "Custom date range cannot exceed " + MAX_CUSTOM_RANGE_DAYS + " days.");
            }

            return new DashboardDateRange(
                    "custom", "Custom Range", start, endInclusive.plusDays(1));
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Date format must be yyyy-MM-dd.", ex);
        }
    }

    private List<DashboardStats.RevenuePoint> fillMissingRevenuePeriods(
            List<DashboardStats.RevenuePoint> rawPoints,
            LocalDate start,
            LocalDate endExclusive,
            boolean groupByMonth) {

        Map<String, DashboardStats.RevenuePoint> rawByKey = new HashMap<>();
        if (rawPoints != null) {
            for (DashboardStats.RevenuePoint point : rawPoints) {
                rawByKey.put(point.getPeriodKey(), point);
            }
        }

        List<DashboardStats.RevenuePoint> completed = new ArrayList<>();

        if (groupByMonth) {
            DateTimeFormatter labelFormatter
                    = DateTimeFormatter.ofPattern("MMM yyyy", Locale.ENGLISH);
            YearMonth current = YearMonth.from(start);
            YearMonth last = YearMonth.from(endExclusive.minusDays(1));

            while (!current.isAfter(last)) {
                LocalDate periodDate = current.atDay(1);
                String key = periodDate.toString();
                DashboardStats.RevenuePoint raw = rawByKey.get(key);
                completed.add(new DashboardStats.RevenuePoint(
                        key,
                        current.format(labelFormatter),
                        raw == null ? BigDecimal.ZERO : raw.getRevenue(),
                        raw == null ? 0 : raw.getOrders()
                ));
                current = current.plusMonths(1);
            }
        } else {
            DateTimeFormatter labelFormatter
                    = DateTimeFormatter.ofPattern("MMM d", Locale.ENGLISH);
            LocalDate current = start;

            while (current.isBefore(endExclusive)) {
                String key = current.toString();
                DashboardStats.RevenuePoint raw = rawByKey.get(key);
                completed.add(new DashboardStats.RevenuePoint(
                        key,
                        current.format(labelFormatter),
                        raw == null ? BigDecimal.ZERO : raw.getRevenue(),
                        raw == null ? 0 : raw.getOrders()
                ));
                current = current.plusDays(1);
            }
        }

        return completed;
    }

    private Map<String, Integer> normalizeOrderStatuses(Map<String, Integer> rawStatuses) {
        Map<String, Integer> raw = rawStatuses == null
                ? new HashMap<>() : rawStatuses;

        Map<String, Integer> normalized = new LinkedHashMap<>();
        normalized.put("Pending", raw.getOrDefault("PENDING", 0));
        normalized.put("Confirmed", raw.getOrDefault("CONFIRMED", 0));
        normalized.put("Shipping", raw.getOrDefault("SHIPPING", 0));
        normalized.put("Delivered", raw.getOrDefault("DELIVERED", 0));
        normalized.put("Cancelled", raw.getOrDefault("CANCELLED", 0));
        normalized.put("Returned", raw.getOrDefault("RETURNED", 0));
        return normalized;
    }

    private double calculateChange(BigDecimal current, BigDecimal previous) {
        BigDecimal safeCurrent = current == null ? BigDecimal.ZERO : current;
        BigDecimal safePrevious = previous == null ? BigDecimal.ZERO : previous;

        if (safePrevious.compareTo(BigDecimal.ZERO) == 0) {
            return safeCurrent.compareTo(BigDecimal.ZERO) == 0 ? 0.0 : 100.0;
        }

        return safeCurrent.subtract(safePrevious)
                .divide(safePrevious, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(1, RoundingMode.HALF_UP)
                .doubleValue();
    }

    private double calculateChange(int current, int previous) {
        if (previous == 0) {
            return current == 0 ? 0.0 : 100.0;
        }
        return BigDecimal.valueOf(current - previous)
                .divide(BigDecimal.valueOf(previous), 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(1, RoundingMode.HALF_UP)
                .doubleValue();
    }

    private static class DashboardDateRange {

        private final String rangeKey;
        private final String rangeLabel;
        private final LocalDate startDate;
        private final LocalDate endDateExclusive;

        private DashboardDateRange(
                String rangeKey,
                String rangeLabel,
                LocalDate startDate,
                LocalDate endDateExclusive) {
            this.rangeKey = rangeKey;
            this.rangeLabel = rangeLabel;
            this.startDate = startDate;
            this.endDateExclusive = endDateExclusive;
        }
    }
}
