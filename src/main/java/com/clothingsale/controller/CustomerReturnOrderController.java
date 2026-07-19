package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/customer/return-order")
public class CustomerReturnOrderController extends HttpServlet {

    private final CustomerOrderService service = new CustomerOrderService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (Exception e) {
            session.setAttribute("orderError", "Invalid order.");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        String reason = request.getParameter("reason");
        int userId = (Integer) session.getAttribute("authUserId");
        boolean success = service.requestReturnOrder(orderId, userId, reason);

        if (success) {
            session.setAttribute("orderMessage", "Return request submitted. Staff will review it soon.");
            response.sendRedirect(request.getContextPath() + "/customer/orders?status=RETURN_REQUESTED");
        } else {
            session.setAttribute("orderError", "Could not submit a return request for this order.");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }
}
