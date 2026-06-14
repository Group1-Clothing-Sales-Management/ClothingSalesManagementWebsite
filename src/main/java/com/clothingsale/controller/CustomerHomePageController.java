package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(
        name = "CustomerHomePageController",
        urlPatterns = {"/home"}
)
public class CustomerHomePageController extends HttpServlet {

    private CustomerProductService productService 
            = new CustomerProductService();
 
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
                    maxPrice
            );

            request.setAttribute("products", products);

            request.getRequestDispatcher(
                    "/view/customer/CustomerHomePage.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "System error while loading products."
            );

            request.getRequestDispatcher(
                    "/view/customer/CustomerHomePage.jsp"
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
}