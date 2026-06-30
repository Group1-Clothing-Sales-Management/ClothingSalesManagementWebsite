package com.clothingsale.dao;

import com.clothingsale.model.StaffReport;
import com.clothingsale.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class StaffReportDAO {

    public StaffReport getRevenueReport(String startDate, String endDate, String timePeriod, String categoryId) {
        StaffReport data = new StaffReport();
        data.setTotalRevenue(BigDecimal.ZERO);
        data.setCompletedOrdersCount(0);

        Map<String, BigDecimal> timeMap = new LinkedHashMap<>();
        Map<String, BigDecimal> catMap = new LinkedHashMap<>();

        StringBuilder baseQuery = new StringBuilder("FROM [Order] o WHERE o.order_status = 'SUCCESS' ");
        List<Object> params = new ArrayList<>();

        if (startDate != null && !startDate.trim().isEmpty()) {
            baseQuery.append("AND o.created_at >= CAST(? AS DATETIME) ");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            baseQuery.append("AND o.created_at <= CAST(? AS DATETIME) ");
            params.add(endDate.trim() + " 23:59:59");
        }
        if (categoryId != null && !categoryId.trim().isEmpty() && !"-1".equals(categoryId)) {
            baseQuery.append("AND o.id IN (SELECT od.order_id FROM Order_Detail od " +
                    "JOIN Product_Variant pv ON od.variant_id = pv.id " +
                    "JOIN Product p ON pv.product_id = p.id " +
                    "WHERE p.category_id = ?) ");
            params.add(Integer.parseInt(categoryId.trim()));
        }

        String sqlOverview = "SELECT SUM(o.total_payment) AS TotalRev, COUNT(o.id) AS TotalOrders "
                + baseQuery.toString();

        String dateGroupFormat = "FORMAT(o.created_at, 'yyyy-MM-dd')";
        if ("weekly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "'Tuần ' + CAST(DATEPART(week, o.created_at) AS VARCHAR) + '-' + CAST(YEAR(o.created_at) AS VARCHAR)";
        } else if ("monthly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "FORMAT(o.created_at, 'MM-yyyy')";
        } else if ("yearly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "CAST(YEAR(o.created_at) AS VARCHAR)";
        }

        String sqlTimeBreakdown = "SELECT " + dateGroupFormat + " AS Period, SUM(o.total_payment) AS Revenue " +
                baseQuery.toString() +
                " GROUP BY " + dateGroupFormat +
                " ORDER BY Period ASC";

        StringBuilder sqlCatBreakdown = new StringBuilder(
                "SELECT c.category_name, SUM(od.price * od.quantity) AS CatRevenue " +
                        "FROM Order_Detail od " +
                        "JOIN [Order] o ON od.order_id = o.id " +
                        "JOIN Product_Variant pv ON od.variant_id = pv.id " +
                        "JOIN Product p ON pv.product_id = p.id " +
                        "JOIN Category c ON p.category_id = c.id " +
                        "WHERE o.order_status = 'SUCCESS' ");
        List<Object> catParams = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sqlCatBreakdown.append("AND o.created_at >= CAST(? AS DATETIME) ");
            catParams.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sqlCatBreakdown.append("AND o.created_at <= CAST(? AS DATETIME) ");
            catParams.add(endDate.trim() + " 23:59:59");
        }
        if (categoryId != null && !categoryId.trim().isEmpty() && !"-1".equals(categoryId)) {
            sqlCatBreakdown.append("AND p.category_id = ? ");
            catParams.add(Integer.parseInt(categoryId.trim()));
        }
        sqlCatBreakdown.append("GROUP BY c.category_name");

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlOverview)) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        data.setTotalRevenue(
                                rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO);
                        data.setCompletedOrdersCount(rs.getInt("TotalOrders"));
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(sqlTimeBreakdown)) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        timeMap.put(rs.getString("Period"), rs.getBigDecimal("Revenue"));
                    }
                }
            }
            data.setRevenueBreakdownTime(timeMap);

            try (PreparedStatement ps = con.prepareStatement(sqlCatBreakdown.toString())) {
                for (int i = 0; i < catParams.size(); i++) {
                    ps.setObject(i + 1, catParams.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        catMap.put(rs.getString("category_name"), rs.getBigDecimal("CatRevenue"));
                    }
                }
            }
            data.setRevenueBreakdownCategory(catMap);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return data;
    }
}