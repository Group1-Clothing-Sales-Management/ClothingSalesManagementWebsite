package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;

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

        request.setAttribute(
                "orders",
                service.getOrdersByUserId(userId));

        request.getRequestDispatcher(
                "/view/customer/CustomerViewOrder.jsp")
                .forward(request, response);
    }
}