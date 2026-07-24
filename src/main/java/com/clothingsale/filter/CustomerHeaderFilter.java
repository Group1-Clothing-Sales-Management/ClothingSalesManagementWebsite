package com.clothingsale.filter;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Category;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletContext;
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
    "/cart",
    "/cart/*",
    "/wishlist",
    "/wishlist/*",
    "/customer/*",
    "/feedback/*"
})
public class CustomerHeaderFilter implements Filter {

    private static final String CATEGORIES_CACHE_KEY
            = "customerHeaderCategoriesCache";
    private static final String CATEGORIES_CACHE_TIME_KEY
            = "customerHeaderCategoriesCacheTime";

    private static final long CATEGORIES_CACHE_TTL_MS
            = 5 * 60 * 1000L;

    private final CustomerProductDAO productDAO
            = new CustomerProductDAO();

    @Override
    public void doFilter(ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        request.setAttribute(
                "headerCategories",
                getCachedHeaderCategories(
                        request.getServletContext()
                )
        );

        chain.doFilter(request, response);
    }

    private List<Category> getCachedHeaderCategories(
            ServletContext context) {

        long now = System.currentTimeMillis();

        synchronized (context) {
            Object cachedCategories
                    = context.getAttribute(
                            CATEGORIES_CACHE_KEY
                    );

            Object cachedTime
                    = context.getAttribute(
                            CATEGORIES_CACHE_TIME_KEY
                    );

            if (cachedCategories instanceof List
                    && cachedTime instanceof Long
                    && now - (Long) cachedTime
                    < CATEGORIES_CACHE_TTL_MS) {

                return castCategoryList(cachedCategories);
            }

            /*
             * Header phải nhận cây Category cha-con, không dùng danh sách
             * phẳng. Nhờ đó mọi trang Customer chỉ hiển thị Category cha trên
             * thanh menu và Category con trong dropdown.
             */
            List<Category> refreshedCategories
                    = productDAO.getHeaderCategories();

            if (refreshedCategories == null) {
                refreshedCategories
                        = Collections.emptyList();
            }

            context.setAttribute(
                    CATEGORIES_CACHE_KEY,
                    refreshedCategories
            );

            context.setAttribute(
                    CATEGORIES_CACHE_TIME_KEY,
                    now
            );

            return refreshedCategories;
        }
    }

    @SuppressWarnings("unchecked")
    private List<Category> castCategoryList(
            Object cachedCategories) {

        return (List<Category>) cachedCategories;
    }
}