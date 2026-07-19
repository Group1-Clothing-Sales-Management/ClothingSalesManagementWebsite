package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;
import com.clothingsale.model.Order;
import com.clothingsale.model.ReorderResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet("/customer/orders")
public class CustomerViewOrderController
        extends HttpServlet {

    private final CustomerOrderService service
            = new CustomerOrderService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");

            return;
        }

        int userId =
                (Integer) session.getAttribute(
                        "authUserId");

        Object orderMessage = session.getAttribute("orderMessage");
        if (orderMessage != null) {
            request.setAttribute("orderMessage", orderMessage.toString());
            session.removeAttribute("orderMessage");
        }

        Object orderError = session.getAttribute("orderError");
        if (orderError != null) {
            request.setAttribute("orderError", orderError.toString());
            session.removeAttribute("orderError");
        }

        String statusFilter =
                normalize(
                        request.getParameter("status"));

        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute(
                "orders",
                filterOrders(
                        service.getOrdersByUserId(userId),
                        statusFilter));

        request.getRequestDispatcher(
                "/view/customer/customer_view_order.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");

            return;
        }

        String action = request.getParameter("action");

        if (!"reorder".equalsIgnoreCase(action)) {
            response.sendRedirect(
                    buildOrdersRedirect(request));
            return;
        }

        int userId =
                (Integer) session.getAttribute(
                        "authUserId");

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (Exception e) {
            session.setAttribute("orderError", "Invalid order.");
            response.sendRedirect(
                    buildOrdersRedirect(request));
            return;
        }

        ReorderResult result =
                service.reorderToCart(userId, orderId);

        if (result.isSuccess()) {
            session.setAttribute("cart", service.getCartMap(userId));
            session.setAttribute("checkoutSelectedVariantIds", result.getVariantIds());
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout");
        } else {
            session.setAttribute("orderError", result.getMessage());
            response.sendRedirect(
                    buildOrdersRedirect(request));
        }
    }

    private String buildOrdersRedirect(HttpServletRequest request) {
        StringBuilder redirect =
                new StringBuilder(
                        request.getContextPath()
                        + "/customer/orders");

        String status =
                request.getParameter("status");

        if (status != null && !status.trim().isEmpty()) {
            redirect.append("?")
                    .append("status=")
                    .append(URLEncoder.encode(
                            status.trim(),
                            StandardCharsets.UTF_8));
        }

        return redirect.toString();
    }

    private List<Order> filterOrders(
            List<Order> orders,
            String statusFilter) {

        if (statusFilter.isEmpty() || "ALL".equals(statusFilter)) {
            return orders;
        }

        List<Order> result = new ArrayList<>();

        for (Order order : orders) {
            if (matchesFilter(order, statusFilter)) {
                result.add(order);
            }
        }

        return result;
    }

    private boolean matchesFilter(
            Order order,
            String statusFilter) {

        if (order == null) {
            return false;
        }

        String orderStatus = normalize(order.getOrderStatus());
        String displayStatus = normalize(order.getDisplayStatus());
        String shippingStatus = normalize(order.getShippingStatus());
        String paymentStatus = normalize(order.getPaymentStatus());

        switch (statusFilter) {
            case "WAIT_PAYMENT":
                return isAny(orderStatus, "PENDING")
                        || isAny(displayStatus, "PENDING", "PENDING_APPROVAL")
                        || isAny(paymentStatus, "PENDING", "UNPAID");
            case "SHIPPING":
                return isAny(orderStatus, "SHIPPING")
                        || isAny(displayStatus, "SHIPPING")
                        || isAny(shippingStatus, "SHIPPING");
            case "WAIT_DELIVERY":
                return isAny(displayStatus, "CONFIRMED", "APPROVED", "PREPARING")
                        || isAny(shippingStatus, "PENDING_PICKUP");
            case "COMPLETED":
                return isAny(orderStatus, "DELIVERED", "SUCCESS", "COMPLETED", "PAID")
                        || isAny(displayStatus, "DELIVERED", "SUCCESS", "RECEIVED", "COMPLETED", "PAID")
                        || isAny(shippingStatus, "DELIVERED", "SUCCESS");
            case "CANCELLED":
                return isAny(orderStatus, "CANCELLED", "FAILED")
                        || isAny(displayStatus, "CANCELLED")
                        || isAny(shippingStatus, "CANCELLED", "FAILED");
            case "RETURNED":
                return isAny(orderStatus, "RETURNED")
                        || isAny(displayStatus, "RETURNED")
                        || isAny(shippingStatus, "RETURNED");
            case "RETURN_REQUESTED":
                return isAny(orderStatus, "RETURN_REQUESTED")
                        || isAny(displayStatus, "RETURN_REQUESTED");
            default:
                return isAny(orderStatus, statusFilter)
                        || isAny(displayStatus, statusFilter)
                        || isAny(shippingStatus, statusFilter)
                        || isAny(paymentStatus, statusFilter);
        }
    }

    private boolean isAny(
            String value,
            String... candidates) {

        for (String candidate : candidates) {
            if (value.equals(normalize(candidate))) {
                return true;
            }
        }

        return false;
    }

    private String normalize(String value) {
        return value == null
                ? ""
                : value.trim().toUpperCase(Locale.ROOT);
    }
}
