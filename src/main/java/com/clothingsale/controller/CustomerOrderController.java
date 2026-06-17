package com.clothingsale.controller;

import com.clothingsale.model.UserAddress;
import com.clothingsale.service.CustomerOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/customer/checkout")
public class CustomerOrderController
        extends HttpServlet {

    private final CustomerOrderService service
            = new CustomerOrderService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");

            return;
        }

        int userId
                = (Integer) session.getAttribute(
                        "authUserId");
        BigDecimal total
                = service.getCartTotal(userId);

        List<UserAddress> addresses
                = service.getAddressesByUserId(userId);

        request.setAttribute(
                "addresses",
                addresses);
        request.setAttribute(
                "cartItems",
                service.getCartItems(userId));

        request.setAttribute(
                "cartTotal",
                total);

        request.getRequestDispatcher(
                "/view/customer/CustomerCheckout.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);
        int addressId
                = Integer.parseInt(
                        request.getParameter(
                                "addressId"));
        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");
            return;
        }

        int userId
                = (Integer) session.getAttribute(
                        "authUserId");

        if (!service.validateCheckout(userId)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid");

            return;
        }

        String voucherCode
                = request.getParameter("voucherCode");

        String note
                = request.getParameter("note");

        boolean success
                = service.placeOrder(
                        userId,
                        addressId,
                        voucherCode,    
                        note);

        if (success) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders");
        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=1");
        }
    }
}
