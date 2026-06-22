package com.clothingsale.filter;

import java.io.IOException;
import java.util.Locale;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class AuthFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        String path = getRequestPath(request);

        // 1. Nếu là đường dẫn công khai, cho qua luôn
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        String roleName = session != null ? (String) session.getAttribute("authRoleName") : null;
        boolean loggedIn = session != null && session.getAttribute("authUserId") != null;

        // 2. Chưa đăng nhập -> Đá về trang đăng nhập phù hợp
        if (!loggedIn) {
            // Nếu đang truy cập admin/staff area, redirect tới admin login
            if (isAdminPath(path) || isStaffPath(path) || path.startsWith("/admin")) {
                response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            } else {
                // Mặc định các thao tác customer cần đăng nhập -> gửi đến customer login
                response.sendRedirect(request.getContextPath() + "/customer/login?error=unauthorized");
            }
            return;
        }

        // --- ĐOẠN XỬ LÝ NGOẠI LỆ GỘP ĐƯỜNG DẪN DASHBOARD ---
        // Nếu đang truy cập vào trang dashboard dùng chung
        if ("/admin/dashboard".equals(path) || "/AdminDashboard".equals(path)) {
            // Cho phép cả ADMIN và STAFF cùng vào
            if ("ADMIN".equalsIgnoreCase(roleName) || "STAFF".equalsIgnoreCase(roleName)) {
                chain.doFilter(request, response);
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/login?error=forbidden");
                return;
            }
        }
        // --------------------------------------------------

        // 3. Nếu vào các trang Admin khác (Quản lý User, Xoá sản phẩm, mã giảm giá...)
        // -> Chỉ ADMIN được vào
        if (isAdminPath(path) && !isAdminRole(roleName)) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=forbidden");
            return;
        }

        // 4. Nếu vào các trang Staff cũ -> STAFF hoặc ADMIN đều vào được
        if (isStaffPath(path) && !isStaffOrAdminRole(roleName)) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=forbidden");
            return;
        }

        chain.doFilter(request, response);
    }

    private String getRequestPath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        if (contextPath != null && !contextPath.isEmpty() && uri.startsWith(contextPath)) {
            return uri.substring(contextPath.length());
        }
        return uri;
    }

    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty() || "/".equals(path) || "/index.html".equals(path)) {
            return true;
        }
        String lowerPath = path.toLowerCase(Locale.ROOT);
        // Allow only public static assets, the homepage, and explicit auth endpoints
        return lowerPath.startsWith("/admin-staff-login")
                || lowerPath.startsWith("/login")
                || lowerPath.startsWith("/home") 
                || lowerPath.startsWith("/customer")
                || lowerPath.startsWith("/cart")
                || lowerPath.startsWith("/admin/login")
                || lowerPath.startsWith("/customer/login")
                || lowerPath.startsWith("/customer/register")
                || lowerPath.startsWith("/customer/verify")
                || lowerPath.startsWith("/view/auth/")
                || lowerPath.startsWith("/cart")
                || lowerPath.startsWith("/cart/add")
                || lowerPath.startsWith("/cart/update")
                || lowerPath.startsWith("/cart/remove")                
                || lowerPath.startsWith("/product")
                || lowerPath.startsWith("/product/detail")
                || lowerPath.startsWith("/customer/address")
                || lowerPath.startsWith("/customer/checkout")
                || lowerPath.startsWith("/uploads/")
                || lowerPath.startsWith("/css/")
                || lowerPath.startsWith("/js/")
                || lowerPath.startsWith("/images/")
                || lowerPath.startsWith("/assets/")
                || lowerPath.startsWith("/webjars/")
                || "/favicon.ico".equals(lowerPath);
    }

    private boolean isAdminPath(String path) {
        return path.startsWith("/AdminDashboard")
                || path.startsWith("/admin/dashboard")
                || path.startsWith("/AdminManageProduct")
                || path.startsWith("/admin/manage-product")
                || path.startsWith("/view/admin/");
    }

    private boolean isStaffPath(String path) {
        return path.startsWith("/StaffManageProducts")
                || path.startsWith("/staff/products")
                || "/StaffManageCustomers.jsp".equals(path)
                || "/StaffManageProducts.jsp".equals(path)
                || "/StaffViewProduct.jsp".equals(path)
                || "/StaffEditProduct.jsp".equals(path)
                || path.startsWith("/StaffManageOrders")
                || path.startsWith("/staff/orders")
                || path.startsWith("/admin/feedback")
                || path.startsWith("/staff/feedback")
                || path.startsWith("/admin/products")
                || "/StaffManageOrders.jsp".equals(path)
                || "/StaffManageFeedback.jsp".equals(path);
    }

    private boolean isAdminRole(String roleName) {
        return "ADMIN".equalsIgnoreCase(roleName);
    }

    private boolean isStaffOrAdminRole(String roleName) {
        return "STAFF".equalsIgnoreCase(roleName) || "ADMIN".equalsIgnoreCase(roleName);
    }
}
