package com.clothingsale.controller;

import com.clothingsale.model.Category;
import com.clothingsale.model.StaffReport;
import com.clothingsale.service.AdminManageProductService;
import com.clothingsale.service.StaffReportService;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StaffReportController", urlPatterns = { "/staff/reports", "/staff/revenue-report" })
public class StaffReportController extends HttpServlet {

    private final StaffReportService staffReportService = new StaffReportService();
    private final AdminManageProductService adminProductService = new AdminManageProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String timePeriod = request.getParameter("timePeriod");
        String categoryId = request.getParameter("categoryId");

        if (startDate != null && endDate != null && !startDate.isEmpty() && !endDate.isEmpty()) {
            if (startDate.compareTo(endDate) > 0) {
                request.setAttribute("errorMessage", "Start date cannot be later than end date!");
            }
        }

        List<Category> categories = adminProductService.getAllCategories();
        request.setAttribute("categories", categories);

        StaffReport reportData = staffReportService.generateRevenueReport(startDate, endDate, timePeriod, categoryId);
        request.setAttribute("reportData", reportData);

        request.setAttribute("selectedStartDate", startDate);
        request.setAttribute("selectedEndDate", endDate);
        request.setAttribute("selectedTimePeriod", timePeriod);
        request.setAttribute("selectedCategoryId", categoryId);

        request.getRequestDispatcher("/view/staff/StaffManageReports.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String timePeriod = request.getParameter("timePeriod");
        String categoryId = request.getParameter("categoryId");
        String format = request.getParameter("format");

        StaffReport reportData = staffReportService.generateRevenueReport(startDate, endDate, timePeriod, categoryId);

        if ("excel".equalsIgnoreCase(format)) {
            response.setContentType("application/vnd.ms-excel; charset=UTF-8");
            response.setHeader("Content-Disposition",
                    "attachment; filename=RevenueReport_" + System.currentTimeMillis() + ".xls");

            try (PrintWriter writer = response.getWriter()) {
                writer.println(
                        "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>");
                writer.println("<head><meta charset='UTF-8'>");
                writer.println("<style>");
                writer.println("  body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }");
                writer.println("  .title { font-size: 16pt; font-weight: bold; color: #1e3a8a; text-align: center; }");
                writer.println("  .stat-table { border-collapse: collapse; margin-top: 15px; }");
                writer.println(
                        "  .stat-table th { background-color: #1e40af; color: #ffffff; font-weight: bold; padding: 8px; border: 1px solid #cbd5e1; }");
                writer.println("  .stat-table td { padding: 8px; border: 1px solid #cbd5e1; text-align: left; }");
                writer.println("  .number { text-align: right; mso-number-format:'#,##0'; }");
                writer.println("  .highlight { background-color: #f0fdf4; font-weight: bold; }");
                writer.println("</style>");
                writer.println("</head><body>");

                writer.println(
                        "<table width='100%'><tr><td colspan='2' class='title'>CLOTHES SHOP REVENUE REPORT</td></tr></table><br/>");

                writer.println("<table class='stat-table' width='400'>");
                writer.println("  <tr class='highlight'><td>Total Revenue</td><td class='number'>"
                        + reportData.getTotalRevenue() + " USD</td></tr>");
                writer.println("  <tr class='highlight'><td>Completed Orders</td><td class='number'>"
                        + reportData.getCompletedOrdersCount() + "</td></tr>");
                writer.println("</table><br/>");

                writer.println("<h3>1. REVENUE BREAKDOWN BY TIME</h3>");
                writer.println("<table class='stat-table' width='500'>");
                writer.println("  <thead><tr><th>Time Period</th><th>Actual Revenue (USD)</th></tr></thead>");
                writer.println("  <tbody>");
                for (Map.Entry<String, BigDecimal> entry : reportData.getRevenueBreakdownTime().entrySet()) {
                    writer.println("    <tr><td>" + entry.getKey() + "</td><td class='number'>" + entry.getValue()
                            + "</td></tr>");
                }
                writer.println("  </tbody>");
                writer.println("</table><br/>");

                writer.println("<h3>2. REVENUE BREAKDOWN BY CATEGORY</h3>");
                writer.println("<table class='stat-table' width='500'>");
                writer.println(
                        "  <thead><tr><th>Product Category Name</th><th>Distributed Revenue (USD)</th></tr></thead>");
                writer.println("  <tbody>");
                for (Map.Entry<String, BigDecimal> entry : reportData.getRevenueBreakdownCategory().entrySet()) {
                    writer.println("    <tr><td>" + entry.getKey() + "</td><td class='number'>" + entry.getValue()
                            + "</td></tr>");
                }
                writer.println("  </tbody>");
                writer.println("</table>");

                writer.println("</body></html>");
            }
        }
    }
}
