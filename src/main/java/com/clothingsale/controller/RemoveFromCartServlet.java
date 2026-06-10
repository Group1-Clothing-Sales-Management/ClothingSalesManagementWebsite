package com.clothingsale.controller;

import com.clothingsale.model.CartItem;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "RemoveFromCart", urlPatterns = {"/cart/remove"})
public class RemoveFromCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String variantIdStr = request.getParameter("variantId");
        int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
        cart.remove(variantId);

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
