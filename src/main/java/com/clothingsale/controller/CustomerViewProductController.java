package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/products")
public class CustomerViewProductController extends HttpServlet {

    private final CustomerProductService service
            = new CustomerProductService();

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

        request.getRequestDispatcher(
                "/view/customer/CustomerViewProductList.jsp")
                .forward(request, response);
    }
}