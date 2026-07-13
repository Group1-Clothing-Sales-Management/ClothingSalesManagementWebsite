package com.clothingsale.filter;

import com.clothingsale.dao.CustomerProductDAO;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

@WebFilter(urlPatterns = {
    "/home",
    "/Home",
    "/products",
    "/product",
    "/product/*",
    "/customer/*"
})
public class CustomerHeaderFilter implements Filter {

    private final CustomerProductDAO productDAO = new CustomerProductDAO();

    @Override
    public void doFilter(ServletRequest request,
            ServletResponse response,
            FilterChain chain) throws IOException, ServletException {

        request.setAttribute("headerCategories", productDAO.getActiveCategories());
        chain.doFilter(request, response);
    }
}
