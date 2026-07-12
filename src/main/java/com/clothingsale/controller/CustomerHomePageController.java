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

    private CustomerProductService productService 
            = new CustomerProductService();
    private final WishlistService wishlistService = new WishlistService();
 
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Nhận dữ liệu từ thanh tìm kiếm và filter
        String keyword = request.getParameter("keyword");

        String categoryStr = request.getParameter("categoryId");
        String brandStr = request.getParameter("brandId");

        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String sort = request.getParameter("sort");
        
        Integer categoryId = null;
        Integer brandId = null;
        Double minPrice = null;
        Double maxPrice = null;

        try {
            if (categoryStr != null && !categoryStr.isEmpty()) {
                categoryId = Integer.parseInt(categoryStr);
            }

            if (brandStr != null && !brandStr.isEmpty()) {
                brandId = Integer.parseInt(brandStr);
            }

            if (minPriceStr != null && !minPriceStr.isEmpty()) {
                minPrice = Double.parseDouble(minPriceStr);
            }

            if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
                maxPrice = Double.parseDouble(maxPriceStr);
            }

            // Lấy danh sách sản phẩm
            List<Product> products = productService.getProducts(
                    keyword,
                    categoryId,
                    brandId,
                    minPrice,
                    maxPrice,
                    sort
            );

            request.setAttribute("products", products);
            populateWishlistState(request);

            request.getRequestDispatcher(
                    "/view/customer/customer_home_page.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "System error while loading products."
            );

            request.getRequestDispatcher(
                    "/view/customer/customer_home_page.jsp"
            ).forward(request, response);
        }
    }


    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }


    @Override
    public String getServletInfo() {
        return "Customer Home Page Controller";
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
