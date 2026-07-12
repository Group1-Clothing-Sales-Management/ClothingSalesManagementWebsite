package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;
import com.clothingsale.service.WishlistService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Set;

@WebServlet("/products")
public class CustomerViewProductController extends HttpServlet {

    private final CustomerProductService service
            = new CustomerProductService();
    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        Double minPrice = null;
        Double maxPrice = null;

        try {
            if (request.getParameter("minPrice") != null
                    && !request.getParameter("minPrice").isBlank()) {

                minPrice = Double.parseDouble(
                        request.getParameter("minPrice"));
            }

            if (request.getParameter("maxPrice") != null
                    && !request.getParameter("maxPrice").isBlank()) {

                maxPrice = Double.parseDouble(
                        request.getParameter("maxPrice"));
            }

        } catch (Exception e) {
        }

        String sort = request.getParameter("sort");

        List<Product> products
                = service.getProducts(
                        keyword,
                        null,
                        null,
                        minPrice,
                        maxPrice,
                        sort);

        request.setAttribute("products", products);
        populateWishlistState(request);

        request.getRequestDispatcher(
                "/view/customer/customer_view_product_list.jsp")
                .forward(request, response);
    }

    private void populateWishlistState(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("authUserId") : null;

        if (userIdObj instanceof Integer) {
            int userId = (Integer) userIdObj;
            Set<Integer> productIds = wishlistService.getWishlistProductIds(userId);
            request.setAttribute("wishlistProductIds", productIds);
            session.setAttribute("wishlistCount", productIds.size());
        } else {
            request.setAttribute("wishlistProductIds", Collections.emptySet());
        }
    }
}
