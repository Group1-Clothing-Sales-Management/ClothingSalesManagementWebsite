package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;
import com.clothingsale.model.ReorderResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

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

        request.setAttribute(
                "orders",
                service.getOrdersByUserId(userId));

        request.getRequestDispatcher(
                "/view/customer/CustomerViewOrder.jsp")
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
                    request.getContextPath()
                    + "/customer/orders");
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
                    request.getContextPath()
                    + "/customer/orders");
            return;
        }

        ReorderResult result =
                service.reorderToCart(userId, orderId);

        if (result.isSuccess()) {
            session.setAttribute("cart", service.getCartMap(userId));
            session.setAttribute("cartMessage", result.getMessage());
            response.sendRedirect(
                    request.getContextPath()
                    + "/cart?skipMerge=1");
        } else {
            session.setAttribute("orderError", result.getMessage());
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders");
        }
    }
}
