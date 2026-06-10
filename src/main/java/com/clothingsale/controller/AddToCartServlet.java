package com.clothingsale.controller;

import com.clothingsale.model.CartItem;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AddToCart", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
            session.setAttribute("cart", cart);
        }

        String variantIdStr = request.getParameter("variantId");
        String productIdStr = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String attributes = request.getParameter("attributes");
        String priceStr = request.getParameter("price");
        String qtyStr = request.getParameter("quantity");
        String imageUrl = request.getParameter("imageUrl");

        int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
        int productId = Integer.parseInt(productIdStr != null ? productIdStr : "0");
        int quantity = 1;
        try { quantity = Integer.parseInt(qtyStr); } catch (Exception e) {}
        java.math.BigDecimal price = BigDecimal.ZERO;
        try { price = new BigDecimal(priceStr); } catch (Exception e) {}

        CartItem item = cart.get(variantId);
        if (item == null) {
            item = new CartItem();
            item.setVariantId(variantId);
            item.setProductId(productId);
            item.setProductName(productName);
            item.setAttributes(attributes);
            item.setPrice(price);
            item.setQuantity(quantity);
            item.setImageUrl(imageUrl);
            cart.put(variantId, item);
        } else {
            item.setQuantity(item.getQuantity() + quantity);
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
