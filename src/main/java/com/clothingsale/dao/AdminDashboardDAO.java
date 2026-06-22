package com.clothingsale.dao;

import com.clothingsale.model.DashboardStats;

import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

public class AdminDashboardDAO {

    public DashboardStats getDashboardOverviewStats() {
        DashboardStats dto = new DashboardStats();

        // 1. Tính doanh thu tháng hiện tại (Chỉ tính các đơn hoàn thành DELIVERED)
        String sqlMonthlyRevenue = "SELECT SUM(total_payment) AS revenue FROM [Order] "
                + "WHERE order_status = 'DELIVERED' "
                + "AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE())";

        // 2. Đếm số đơn hàng mới (Trạng thái PENDING)
        String sqlNewOrders = "SELECT COUNT(*) AS total FROM [Order] WHERE order_status = 'PENDING'";

        // 3. Đếm tổng số lượng sản phẩm biến thể đang kinh doanh
        String sqlTotalProducts = "SELECT COUNT(*) AS total FROM Product_Variant WHERE status = 'ACTIVE'";

        // 4. Đếm tổng số lượng khách hàng (Role CUSTOMER)
        String sqlTotalCustomers = "SELECT COUNT(*) AS total FROM [User] u "
                + "JOIN Role r ON u.role_id = r.id WHERE r.role_name = 'CUSTOMER'";

        try (Connection con = DBConnection.getConnection()) {

            // Thực thi lấy các số liệu dạng thẻ
            try (PreparedStatement ps = con.prepareStatement(sqlMonthlyRevenue); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dto.setMonthlyRevenue(rs.getBigDecimal("revenue") != null ? rs.getBigDecimal("revenue") : BigDecimal.ZERO);
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sqlNewOrders); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dto.setNewOrdersCount(rs.getInt("total"));
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sqlTotalProducts); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dto.setTotalProductsCount(rs.getInt("total"));
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sqlTotalCustomers); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dto.setTotalCustomersCount(rs.getInt("total"));
                }
            }

            // 5. Lấy dữ liệu xu hướng doanh thu 6 tháng gần nhất để vẽ biểu đồ đường
            String sqlTrend = "SELECT FORMAT(created_at, 'MM-yyyy') AS [MonthYear], SUM(total_payment) AS Total "
                    + "FROM [Order] WHERE order_status = 'DELIVERED' "
                    + "AND created_at >= DATEADD(month, -5, GETDATE()) "
                    + "GROUP BY FORMAT(created_at, 'MM-yyyy'), YEAR(created_at), MONTH(created_at) "
                    + "ORDER BY YEAR(created_at) ASC, MONTH(created_at) ASC";

            Map<String, BigDecimal> trendMap = new LinkedHashMap<>();
            try (PreparedStatement ps = con.prepareStatement(sqlTrend); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trendMap.put(rs.getString("MonthYear"), rs.getBigDecimal("Total"));
                }
            }
            dto.setRevenueTrend(trendMap);

            // 6. Lấy tỷ lệ danh mục sản phẩm (Đếm số sản phẩm bán ra theo Category) để vẽ biểu đồ tròn
            String sqlCategoryShare = "SELECT c.category_name, SUM(od.quantity) AS TotalSold "
                    + "FROM Order_Detail od "
                    + "JOIN Product_Variant pv ON od.variant_id = pv.id "
                    + "JOIN Product p ON pv.product_id = p.id "
                    + "JOIN Category c ON p.category_id = c.id "
                    + "JOIN [Order] o ON od.order_id = o.id "
                    + "WHERE o.order_status = 'DELIVERED' "
                    + "GROUP BY c.category_name";

            Map<String, Integer> catMap = new LinkedHashMap<>();
            try (PreparedStatement ps = con.prepareStatement(sqlCategoryShare); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    catMap.put(rs.getString("category_name"), rs.getInt("TotalSold"));
                }
            }
            dto.setCategoryShare(catMap);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }
}
