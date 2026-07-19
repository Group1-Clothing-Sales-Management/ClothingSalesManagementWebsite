package com.clothingsale.filter;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Category;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.ServletContext;
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

    private static final String CATEGORIES_CACHE_KEY = "customerHeaderCategoriesCache";
    private static final String CATEGORIES_CACHE_TIME_KEY = "customerHeaderCategoriesCacheTime";
    private static final long CATEGORIES_CACHE_TTL_MS = 5 * 60 * 1000L;

    private final CustomerProductDAO productDAO = new CustomerProductDAO();

    @Override
    public void doFilter(ServletRequest request,
            ServletResponse response,
            FilterChain chain) throws IOException, ServletException {

        request.setAttribute("headerCategories", getCachedCategories(request.getServletContext()));
        chain.doFilter(request, response);
    }

    private List<Category> getCachedCategories(ServletContext context) {
        long now = System.currentTimeMillis();

        synchronized (context) {
            Object cached = context.getAttribute(CATEGORIES_CACHE_KEY);
            Object cachedAt = context.getAttribute(CATEGORIES_CACHE_TIME_KEY);

            if (cached instanceof List
                    && cachedAt instanceof Long
                    && now - (Long) cachedAt < CATEGORIES_CACHE_TTL_MS) {
                return (List<Category>) cached;
            }

            List<Category> categories = productDAO.getActiveCategories();
            context.setAttribute(CATEGORIES_CACHE_KEY, categories);
            context.setAttribute(CATEGORIES_CACHE_TIME_KEY, now);
            return categories;
        }
    }
}
