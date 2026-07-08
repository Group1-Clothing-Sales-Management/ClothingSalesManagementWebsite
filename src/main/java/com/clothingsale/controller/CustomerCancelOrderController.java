package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/customer/cancel-order")
public class CustomerCancelOrderController
        extends HttpServlet {

    private final CustomerOrderService service
            = new CustomerOrderService();

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

        int userId =
                (Integer) session.getAttribute(
                        "authUserId");

        int orderId =
                Integer.parseInt(
                        request.getParameter(
                                "orderId"));

        boolean success =
                service.cancelOrder(
                        orderId,
                        userId);

        if (success) {

            session.setAttribute(
                    "orderMessage",
                    "Order cancelled successfully.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders?status=CANCELLED");

        } else {

            session.setAttribute(
                    "orderError",
                    "Could not cancel this order. Please try again.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders");

        }
    }
}
