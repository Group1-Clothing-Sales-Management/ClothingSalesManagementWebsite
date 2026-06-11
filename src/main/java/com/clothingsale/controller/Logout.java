package com.clothingsale.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
    name = "Logout",
    // Support customer and admin logout entry points.
    urlPatterns = {"/logout", "/admin/logout", "/customer/logout"}
)
public class Logout extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String roleName = session != null && session.getAttribute("authRoleName") != null
                ? session.getAttribute("authRoleName").toString() : null;

        if (session != null) {
            session.invalidate();
        }

        // If the user was a customer (or the request targeted customer logout), return to homepage.
        String uri = request.getRequestURI();
        boolean requestedCustomer = uri != null && uri.toLowerCase().contains("/customer/logout");

        if (requestedCustomer || (roleName != null && "CUSTOMER".equalsIgnoreCase(roleName))) {
            response.sendRedirect(request.getContextPath() + "/");
        } else {
            // Default: send admin/staff to admin login
            response.sendRedirect(request.getContextPath() + "/admin/login?logout=1");
        }
    }
}
