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

    private static final BigDecimal SHIPPING_FEE_PER_ORDER = new BigDecimal("30000");

    public StaffReport getRevenueReport(String startDate, String endDate, String timePeriod, String categoryId) {
        StaffReport data = new StaffReport();
        data.setTotalRevenue(BigDecimal.ZERO);
        data.setCompletedOrdersCount(0);

        Map<String, BigDecimal> timeMap = new LinkedHashMap<>();
        Map<String, BigDecimal> catMap = new LinkedHashMap<>();

        StringBuilder extraFilters = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (startDate != null && !startDate.trim().isEmpty()) {
            extraFilters.append("AND o.created_at >= CAST(? AS DATETIME) ");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            extraFilters.append("AND o.created_at <= CAST(? AS DATETIME) ");
            params.add(endDate.trim() + " 23:59:59");
        }
        if (categoryId != null && !categoryId.trim().isEmpty() && !"-1".equals(categoryId)) {
            extraFilters.append("AND o.id IN (SELECT od.order_id FROM Order_Detail od " +
                    "JOIN Product_Variant pv ON od.variant_id = pv.id " +
                    "JOIN Product p ON pv.product_id = p.id " +
                    "WHERE p.category_id = ?) ");
            params.add(Integer.parseInt(categoryId.trim()));
        }

        // Trừ phí ship (30.000đ/order) khỏi total_payment trước khi trừ tiếp refund
        String sqlOverview = "SELECT SUM(COALESCE(o.total_payment, 0) - " + SHIPPING_FEE_PER_ORDER
                + " - COALESCE(refund.refund_total, 0)) AS TotalRev, COUNT(o.id) AS TotalOrders "
                + "FROM [Order] o "
                + "LEFT JOIN ("
                + "SELECT rr.order_id, SUM(COALESCE(rr.refund_amount, 0)) AS refund_total "
                + "FROM Return_Request rr "
                + "LEFT JOIN Payment p ON p.order_id = rr.order_id "
                + "WHERE rr.status = 'COMPLETED' OR p.payment_status = 'REFUNDED' "
                + "GROUP BY rr.order_id"
                + ") refund ON refund.order_id = o.id "
                + "WHERE o.order_status IN ('SUCCESS','RETURNED') "
                + extraFilters;

        String dateGroupFormat = "FORMAT(o.created_at, 'yyyy-MM-dd')";
        if ("weekly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "'Tuần ' + CAST(DATEPART(week, o.created_at) AS VARCHAR) + '-' + CAST(YEAR(o.created_at) AS VARCHAR)";
        } else if ("monthly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "FORMAT(o.created_at, 'MM-yyyy')";
        } else if ("yearly".equalsIgnoreCase(timePeriod)) {
            dateGroupFormat = "CAST(YEAR(o.created_at) AS VARCHAR)";
        }

        // Trừ phí ship (30.000đ/order) khỏi total_payment trước khi trừ tiếp refund
        String sqlTimeBreakdown = "SELECT " + dateGroupFormat
                + " AS Period, SUM(COALESCE(o.total_payment, 0) - " + SHIPPING_FEE_PER_ORDER
                + " - COALESCE(refund.refund_total, 0)) AS Revenue " +
                "FROM [Order] o " +
                "LEFT JOIN ("
                + "SELECT rr.order_id, SUM(COALESCE(rr.refund_amount, 0)) AS refund_total "
                + "FROM Return_Request rr "
                + "LEFT JOIN Payment p ON p.order_id = rr.order_id "
                + "WHERE rr.status = 'COMPLETED' OR p.payment_status = 'REFUNDED' "
                + "GROUP BY rr.order_id"
                + ") refund ON refund.order_id = o.id " +
                "WHERE o.order_status IN ('SUCCESS','RETURNED') "
                + extraFilters;

        StringBuilder sqlTimeBreakdownWithGroup = new StringBuilder(sqlTimeBreakdown);
        sqlTimeBreakdownWithGroup.append(" GROUP BY ").append(dateGroupFormat).append(" ORDER BY Period ASC");

        // Category breakdown tính theo od.price * od.quantity (giá sản phẩm), không
        // liên quan đến total_payment/phí ship nên KHÔNG trừ 30.000đ ở đây
        StringBuilder sqlCatBreakdown = new StringBuilder(
                "SELECT c.category_name, SUM(COALESCE((od.price * od.quantity), 0) - COALESCE(refund.refund_value, 0)) AS CatRevenue "
                        +
                        "FROM Order_Detail od " +
                        "JOIN [Order] o ON od.order_id = o.id " +
                        "JOIN Product_Variant pv ON od.variant_id = pv.id " +
                        "JOIN Product p ON pv.product_id = p.id " +
                        "JOIN Category c ON p.category_id = c.id " +
                        "LEFT JOIN ("
                        + "SELECT ri.order_detail_id, SUM(COALESCE(ri.quantity * ri.unit_price, 0)) AS refund_value "
                        + "FROM Return_Request_Item ri "
                        + "JOIN Return_Request rr ON rr.id = ri.return_request_id "
                        + "LEFT JOIN Payment p ON p.order_id = rr.order_id "
                        + "WHERE rr.status = 'COMPLETED' OR p.payment_status = 'REFUNDED' "
                        + "GROUP BY ri.order_detail_id"
                        + ") refund ON refund.order_detail_id = od.id " +
                        "WHERE o.order_status IN ('SUCCESS','RETURNED') ");
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

            try (PreparedStatement ps = con.prepareStatement(sqlTimeBreakdownWithGroup.toString())) {
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