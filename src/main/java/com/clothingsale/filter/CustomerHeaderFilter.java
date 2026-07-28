package com.clothingsale.filter;

import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.Category;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

@WebFilter(
        filterName = "CustomerHeaderFilter",
        urlPatterns = {
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
        },
        dispatcherTypes = {
            DispatcherType.REQUEST,
            DispatcherType.FORWARD
        }
)
public class CustomerHeaderFilter implements Filter {

    private final CustomerProductDAO productDAO
            = new CustomerProductDAO();

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain
    ) throws IOException, ServletException {

        /*
         * Không sử dụng cache theo thời gian.
         *
         * Mỗi HTTP request mới sẽ lấy danh sách Category mới nhất từ DB.
         * Khi request được forward sang JSP, thuộc tính đã tồn tại nên không
         * truy vấn lần thứ hai trong cùng một request.
         */
        if (request.getAttribute("headerCategories") == null) {
            List<Category> headerCategories
                    = productDAO.getHeaderCategories();

            if (headerCategories == null) {
                headerCategories = Collections.emptyList();
            }

            request.setAttribute(
                    "headerCategories",
                    headerCategories
            );
        }

        chain.doFilter(request, response);
    }
}