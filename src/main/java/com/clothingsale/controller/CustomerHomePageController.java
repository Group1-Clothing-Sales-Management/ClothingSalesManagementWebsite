package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;
import com.clothingsale.service.WishlistService;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
        name = "CustomerHomePageController",
        urlPatterns = {"/Home", "/home"}
)
public class CustomerHomePageController extends HttpServlet {

    private static final int FEATURED_PRODUCT_LIMIT = 8;
    private static final int BEST_SELLER_PRODUCT_LIMIT = 8;
    private static final int ON_SALE_PRODUCT_LIMIT = 8;

    private final CustomerProductService productService
            = new CustomerProductService();
    private final WishlistService wishlistService
            = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            /*
             * CustomerHeaderFilter normally prepares headerCategories.
             * This fallback keeps the Homepage usable if the controller is
             * invoked without passing through the filter.
             */
            if (request.getAttribute("headerCategories") == null) {
                request.setAttribute(
                        "headerCategories",
                        productService.getHeaderCategories()
                );
            }

            List<Product> featuredProducts
                    = productService.getFeaturedProducts(
                            FEATURED_PRODUCT_LIMIT
                    );

            List<Product> bestSellerProducts
                    = productService.getBestSellingProducts(
                            BEST_SELLER_PRODUCT_LIMIT
                    );

            List<Product> onSaleProducts
                    = productService.getOnSaleProducts(
                            ON_SALE_PRODUCT_LIMIT
                    );

            request.setAttribute(
                    "featuredProducts",
                    featuredProducts
            );
            request.setAttribute(
                    "bestSellerProducts",
                    bestSellerProducts
            );
            request.setAttribute(
                    "onSaleProducts",
                    onSaleProducts
            );

            populateWishlistState(request);

        } catch (Exception e) {
            e.printStackTrace();

            /*
             * Keep the Homepage renderable even if one data section fails.
             * The JSP can hide sections whose lists are empty.
             */
            request.setAttribute(
                    "featuredProducts",
                    Collections.emptyList()
            );
            request.setAttribute(
                    "bestSellerProducts",
                    Collections.emptyList()
            );
            request.setAttribute(
                    "onSaleProducts",
                    Collections.emptyList()
            );
            request.setAttribute(
                    "wishlistProductIds",
                    Collections.emptySet()
            );
            request.setAttribute(
                    "errorMessage",
                    "System error while loading the homepage."
            );
        }

        request.getRequestDispatcher(
                "/view/customer/customer_home_page.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/home"
        );
    }

    @Override
    public String getServletInfo() {
        return "Customer Homepage Controller";
    }

    private void populateWishlistState(
            HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        Object userIdObject = session != null
                ? session.getAttribute("authUserId")
                : null;

        if (!(userIdObject instanceof Number)) {
            request.setAttribute(
                    "wishlistProductIds",
                    Collections.emptySet()
            );
            return;
        }

        int userId = ((Number) userIdObject).intValue();

        if (userId <= 0) {
            request.setAttribute(
                    "wishlistProductIds",
                    Collections.emptySet()
            );
            return;
        }

        try {
            Set<Integer> wishlistProductIds
                    = wishlistService.getWishlistProductIds(userId);

            if (wishlistProductIds == null) {
                wishlistProductIds = Collections.emptySet();
            }

            request.setAttribute(
                    "wishlistProductIds",
                    wishlistProductIds
            );
            session.setAttribute(
                    "wishlistCount",
                    wishlistProductIds.size()
            );

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute(
                    "wishlistProductIds",
                    Collections.emptySet()
            );
        }
    }
}