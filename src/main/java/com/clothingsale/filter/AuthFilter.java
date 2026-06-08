package com.clothingsale.filter;

import java.io.IOException;
import java.util.Locale;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
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

        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        String roleName = session != null ? (String) session.getAttribute("authRoleName") : null;
        boolean loggedIn = session != null && session.getAttribute("authUserId") != null;

        if (!loggedIn) {
            response.sendRedirect(request.getContextPath() + "/admin-staff-login?error=unauthorized");
            return;
        }

        if (isAdminPath(path) && !isAdminRole(roleName)) {
            response.sendRedirect(request.getContextPath() + "/admin-staff-login?error=forbidden");
            return;
        }

        if (isStaffPath(path) && !isStaffOrAdminRole(roleName)) {
            response.sendRedirect(request.getContextPath() + "/admin-staff-login?error=forbidden");
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
        return lowerPath.startsWith("/admin-staff-login")
                || lowerPath.startsWith("/login")
                || lowerPath.startsWith("/logout")
                || lowerPath.startsWith("/admin/logout")
                || lowerPath.startsWith("/view/auth/")
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
                || path.startsWith("/AdminManageProduct")
                || path.startsWith("/admin/manage-product")
                || path.startsWith("/view/admin/");
    }

    private boolean isStaffPath(String path) {
        return path.startsWith("/StaffManageProducts")
                || "/StaffManageProducts.jsp".equals(path)
                || "/StaffViewProduct.jsp".equals(path)
                || "/StaffEditProduct.jsp".equals(path);
    }

    private boolean isAdminRole(String roleName) {
        return "ADMIN".equalsIgnoreCase(roleName);
    }

    private boolean isStaffOrAdminRole(String roleName) {
        return "STAFF".equalsIgnoreCase(roleName) || "ADMIN".equalsIgnoreCase(roleName);
    }
}
