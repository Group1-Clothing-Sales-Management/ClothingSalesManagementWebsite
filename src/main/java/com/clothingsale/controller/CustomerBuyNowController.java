package com.clothingsale.controller;

import com.clothingsale.model.CartItem;
import com.clothingsale.service.CustomerProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/customer/buy-now")
public class CustomerBuyNowController extends HttpServlet {

    private final CustomerProductService productService =
            new CustomerProductService();

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/customer/login");
            return;
        }

        try {

            int variantId = Integer.parseInt(
                    request.getParameter("variantId"));

            int quantity = Integer.parseInt(
                    request.getParameter("quantity"));

            CartItem item =
                    productService.getBuyNowItem(
                            variantId,
                            quantity);

            if (item == null) {

                response.sendRedirect(
                        request.getContextPath() + "/home");
                return;
            }

            List<CartItem> items = new ArrayList<>();
            items.add(item);

            session.setAttribute("buyNowItems", items);

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?buyNow=1");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath() + "/home");
        }

    }

}