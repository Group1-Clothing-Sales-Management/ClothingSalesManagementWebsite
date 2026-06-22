package com.clothingsale.controller;

import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.model.StaffProductModel;
import com.clothingsale.service.OrderManagementService;
import com.clothingsale.service.StaffProductService;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Shared servlet for Staff/Admin to view and manage orders.
 * This page focuses on the list view, detail view, and status changes.
 */
@WebServlet(name = "StaffManageOrders", urlPatterns = {"/StaffManageOrders", "/staff/orders", "/admin/orders"})
public class StaffManageOrders extends HttpServlet {

    private final OrderManagementService service = new OrderManagementService();
    private final StaffProductService productService = new StaffProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdminLoggedIn(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("view".equalsIgnoreCase(action)) {
            handleView(request, response);
        } else {
            handleList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdminLoggedIn(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        if ("confirm".equalsIgnoreCase(action)) {
            handleStatusChange(request, response, "CONFIRMED");
        } else if ("cancel".equalsIgnoreCase(action)) {
            handleStatusChange(request, response, "CANCELLED");
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            handleStatusChange(request, response, request.getParameter("newStatus"));
        } else if ("createStoreOrder".equalsIgnoreCase(action)) {
            handleCreateStoreOrder(request, response);
        } else {
            response.sendRedirect(buildOrdersBasePath(request));
        }
    }

    /**
     * Show the order list with keyword/status filters.
     */
    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        List<Order> orders = service.getOrders(keyword, status);
        List<StaffProductModel> storeProducts;
        boolean hasSellableProducts = false;
        try {
            // The order-creation modal needs the live product list so staff can
            // pick a sellable variant without leaving the order screen.
            storeProducts = productService.getAllProducts();
            for (StaffProductModel item : storeProducts) {
                if (item != null && item.getStockQuantity() > 0) {
                    hasSellableProducts = true;
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            storeProducts = Collections.emptyList();
        }

        request.setAttribute("orders", orders);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status == null || status.trim().isEmpty() ? "ALL" : status.trim().toUpperCase());
        request.setAttribute("statusOptions", service.getStatusOptions());
        request.setAttribute("storeProducts", storeProducts);
        request.setAttribute("hasSellableProducts", hasSellableProducts);
        request.setAttribute("ordersBasePath", buildOrdersBasePath(request));
        request.setAttribute("pageMode", "list");
        request.getRequestDispatcher("/StaffManageOrders.jsp").forward(request, response);
    }

    /**
     * Show the detail screen for a specific order.
     */
    private void handleView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = parseId(request.getParameter("id"));
        Order order = service.getOrderById(orderId);

        if (order == null) {
            request.setAttribute("errorMsg", "Order not found.");
            handleList(request, response);
            return;
        }

        List<OrderDetail> details = service.getOrderDetails(orderId);
        request.setAttribute("order", order);
        request.setAttribute("orderDetails", details);
        request.setAttribute("ordersBasePath", buildOrdersBasePath(request));
        request.setAttribute("pageMode", "detail");
        request.getRequestDispatcher("/StaffManageOrders.jsp").forward(request, response);
    }

    /**
     * Handle order status updates.
     * If the action came from the detail screen, redirect back to that order.
     */
    private void handleStatusChange(HttpServletRequest request, HttpServletResponse response, String requestedStatus)
            throws IOException {

        int orderId = parseId(request.getParameter("id"));
        String result = service.changeOrderStatus(orderId, requestedStatus);
        String redirectMode = request.getParameter("returnMode");

        if ("SUCCESS".equals(result)) {
            request.getSession().setAttribute("successMsg", "Order status updated successfully.");
        } else {
            request.getSession().setAttribute("errorMsg", result);
        }

        if ("detail".equalsIgnoreCase(redirectMode)) {
            response.sendRedirect(buildOrdersBasePath(request) + "?action=view&id=" + orderId);
        } else {
            response.sendRedirect(buildOrdersBasePath(request));
        }
    }

    /**
     * Create a counter sale directly from the order management screen.
     * The form is intentionally small so staff can finish a walk-in purchase in
     * a few clicks without touching the online checkout flow.
     */
    private void handleCreateStoreOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String recipientName = trimToEmpty(request.getParameter("recipientName"));
        String recipientPhone = trimToEmpty(request.getParameter("recipientPhone"));
        String note = trimToEmpty(request.getParameter("note"));
        String paymentMethod = trimToEmpty(request.getParameter("paymentMethod"));
        String fulfillmentType = trimToEmpty(request.getParameter("fulfillmentType"));
        String deliveryAddress = trimToEmpty(request.getParameter("deliveryAddress"));
        int variantId = parseId(request.getParameter("variantId"));
        int quantity = parseId(request.getParameter("quantity"));
        boolean deliveryOrder = "DELIVERY".equalsIgnoreCase(fulfillmentType);

        String result = service.createStoreOrder(
                recipientName,
                recipientPhone,
                variantId,
                quantity,
                paymentMethod,
                note,
                deliveryOrder,
                deliveryAddress);

        if ("SUCCESS".equals(result)) {
            request.getSession().setAttribute("successMsg", "Store order created successfully.");
        } else {
            request.getSession().setAttribute("errorMsg", result);
        }

        response.sendRedirect(buildOrdersBasePath(request));
    }

    /**
     * Ensure only logged-in Staff/Admin users can access this page.
     */
    private boolean isStaffOrAdminLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return false;
        }

        Object role = session.getAttribute("authRoleName");
        if (role == null
                || (!"ADMIN".equalsIgnoreCase(role.toString()) && !"STAFF".equalsIgnoreCase(role.toString()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return false;
        }

        return true;
    }

    /**
     * Parse an ID safely; return 0 so the controller can follow its fallback flow.
     */
    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Trim user input safely so blank fields do not leak extra spaces into the
     * stored order record.
     */
    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Return the current orders base URL so redirects preserve whether the user
     * came from /admin/orders or /staff/orders.
     */
    private String buildOrdersBasePath(HttpServletRequest request) {
        String path = request.getServletPath();
        if ("/admin/orders".equals(path)) {
            return request.getContextPath() + "/admin/orders";
        }
        return request.getContextPath() + "/staff/orders";
    }
}
