package com.clothingsale.controller;

import com.clothingsale.service.CustomerOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

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
        request.setAttribute("vouchers", service.getVouchersForUser(userId));
        request.setAttribute("now", new java.util.Date());
        request.getRequestDispatcher("/view/customer/customer_voucher_wallet.jsp").forward(request, response);
    }
}
