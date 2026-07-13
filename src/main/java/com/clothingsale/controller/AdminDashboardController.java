package com.clothingsale.controller;

import com.clothingsale.model.DashboardStats;
import com.clothingsale.service.AdminDashboardService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;

@WebServlet(
        name = "AdminDashboardController",
        urlPatterns = {"/admin/dashboard", "/dashboard"}
)
public class AdminDashboardController extends HttpServlet {

    private static final ZoneId BUSINESS_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private final AdminDashboardService dashboardService
            = new AdminDashboardService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String range = request.getParameter("range");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        DashboardStats stats;

        try {
            stats = dashboardService.getDashboardOverview(
                    range, startDate, endDate);
        } catch (IllegalArgumentException ex) {
            stats = loadFallbackDashboard();
            stats.setErrorMessage(
                    ex.getMessage() + " Showing This Month instead.");
        } catch (Exception ex) {
            System.err.println("[Dashboard] Fatal dashboard error: "
                    + ex.getMessage());
            ex.printStackTrace();
            stats = createUnavailableDashboard();
            stats.setErrorMessage(
                    "Dashboard data is temporarily unavailable. "
                    + "Check the server log for the exact database error.");
        }

        request.setAttribute("dashboardData", stats);
        request.setAttribute(
                "revenueTrendJson", gson.toJson(stats.getRevenueTrend()));
        request.setAttribute(
                "orderStatusJson",
                gson.toJson(stats.getOrderStatusDistribution()));

        request.getRequestDispatcher("/view/admin/dashboard.jsp")
                .forward(request, response);
    }

    private DashboardStats loadFallbackDashboard() {
        try {
            return dashboardService.getDashboardOverview(
                    "this_month", null, null);
        } catch (Exception ex) {
            System.err.println("[Dashboard] Fallback dashboard failed: "
                    + ex.getMessage());
            ex.printStackTrace();
            return createUnavailableDashboard();
        }
    }

    private DashboardStats createUnavailableDashboard() {
        LocalDate today = LocalDate.now(BUSINESS_ZONE);

        DashboardStats stats = new DashboardStats();
        stats.setSelectedRange("this_month");
        stats.setRangeLabel("This Month");
        stats.setStartDate(today.withDayOfMonth(1).toString());
        stats.setEndDate(today.toString());
        return stats;
    }
}
