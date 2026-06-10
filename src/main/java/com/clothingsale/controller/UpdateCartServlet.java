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

@WebServlet(name = "UpdateCart", urlPatterns = {"/cart/update"})
public class UpdateCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
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
        String qtyStr = request.getParameter("quantity");
        int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
        int quantity = 1;
        try { quantity = Integer.parseInt(qtyStr); } catch (Exception e) {}

        CartItem item = cart.get(variantId);
        if (item != null) {
            if (quantity <= 0) {
                cart.remove(variantId);
            } else {
                item.setQuantity(quantity);
            }
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
