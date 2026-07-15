package com.clothingsale.controller;

import com.clothingsale.model.ReorderResult;
import com.clothingsale.service.CustomerOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

@WebServlet("/customer/order-history")
public class CustomerOrderHistoryController extends HttpServlet {

    private final CustomerOrderService service = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        response.sendRedirect(buildHistoryRedirect(request));
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        String action = request.getParameter("action");

        if (!"reorder".equalsIgnoreCase(action)) {
            response.sendRedirect(buildHistoryRedirect(request));
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (Exception e) {
            session.setAttribute("orderError", "Invalid order.");
            response.sendRedirect(buildHistoryRedirect(request));
            return;
        }

        int userId = (Integer) session.getAttribute("authUserId");
        ReorderResult result = service.reorderToCart(userId, orderId);

        if (result.isSuccess()) {
            session.setAttribute("cart", service.getCartMap(userId));
            session.setAttribute("checkoutSelectedVariantIds", result.getVariantIds());
            response.sendRedirect(request.getContextPath() + "/customer/checkout");
        } else {
            session.setAttribute("orderError", result.getMessage());
            response.sendRedirect(buildHistoryRedirect(request));
        }
    }

    private String buildHistoryRedirect(HttpServletRequest request) {
        StringBuilder redirect = new StringBuilder(
                request.getContextPath()
                + "/customer/orders");
        String status = mapLegacyStatus(request.getParameter("status"));

        if (status != null && !status.trim().isEmpty()) {
            redirect.append("?status=")
                    .append(URLEncoder.encode(
                            status.trim(),
                            StandardCharsets.UTF_8));
        }

        return redirect.toString();
    }

    private String mapLegacyStatus(String status) {
        if (status == null) {
            return "";
        }

        String normalized = status.trim().toUpperCase(Locale.ROOT);

        if ("DELIVERED".equals(normalized)
                || "RECEIVED".equals(normalized)) {
            return "COMPLETED";
        }

        return normalized;
    }
}
