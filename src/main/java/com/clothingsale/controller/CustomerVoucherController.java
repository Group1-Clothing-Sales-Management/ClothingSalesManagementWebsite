package com.clothingsale.controller;

import com.clothingsale.model.Voucher;
import com.clothingsale.service.CustomerOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet("/customer/vouchers")
public class CustomerVoucherController extends HttpServlet {
    private final CustomerOrderService service = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }
        int userId = (Integer) session.getAttribute("authUserId");
        String statusFilter = normalizeStatus(request.getParameter("status"));
        List<Voucher> allVouchers = service.getVouchersForUser(userId);

        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("allCount", allVouchers.size());
        request.setAttribute("availableCount", countByStatus(allVouchers, "AVAILABLE"));
        request.setAttribute("expiredCount", countByStatus(allVouchers, "EXPIRED"));
        request.setAttribute("usedCount", countByStatus(allVouchers, "USED"));
        request.setAttribute("vouchers", filterByStatus(allVouchers, statusFilter));
        request.setAttribute("now", new java.util.Date());
        request.getRequestDispatcher("/view/customer/customer_voucher_wallet.jsp").forward(request, response);
    }

    private List<Voucher> filterByStatus(List<Voucher> vouchers, String statusFilter) {
        if ("ALL".equals(statusFilter)) {
            return vouchers;
        }

        List<Voucher> result = new ArrayList<>();
        for (Voucher voucher : vouchers) {
            if (voucher != null && statusFilter.equals(voucher.getCustomerStatus())) {
                result.add(voucher);
            }
        }
        return result;
    }

    private int countByStatus(List<Voucher> vouchers, String status) {
        int count = 0;
        for (Voucher voucher : vouchers) {
            if (voucher != null && status.equals(voucher.getCustomerStatus())) {
                count++;
            }
        }
        return count;
    }

    private String normalizeStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "ALL";
        }

        String normalized = status.trim().toUpperCase(Locale.ROOT);
        switch (normalized) {
            case "AVAILABLE":
            case "EXPIRED":
            case "USED":
                return normalized;
            default:
                return "ALL";
        }
    }
}
