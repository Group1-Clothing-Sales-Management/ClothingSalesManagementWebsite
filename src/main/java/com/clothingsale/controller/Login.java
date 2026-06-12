package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
        name = "Login",
        // Use the canonical /admin/login route while keeping the legacy entry URL alive.
        urlPatterns = {"/admin-staff-login", "/admin/login", "/login"}
)
public class Login extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String ADMIN_ROLE = "ADMIN";
    private static final String STAFF_ROLE = "STAFF";

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String messageType = request.getParameter("error");
        String logout = request.getParameter("logout");

        if (session != null && session.getAttribute("authUserId") != null
                && messageType == null && logout == null) {
            redirectByRole(session, response, request);
            return;
        }

        if ("unauthorized".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "Please sign in to continue.");
        } else if ("forbidden".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "The current account does not have permission to access this page.");
        } else if ("timeout".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "Your session has expired. Please sign in again.");
        } else if ("1".equals(logout)) {
            request.setAttribute("successMessage", "You have signed out successfully.");
        }

        request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        request.setAttribute("username", username != null ? username.trim() : "");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Please enter both username and password.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        // allow login by username OR email for any role
        User user = userDAO.findByUsernameOrEmail(username.trim());
        if (user == null) {
            request.setAttribute("errorMessage", "The username or password is incorrect.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("errorMessage", "Account not active. Please verify your email.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        boolean matched = false;
        try {
            matched = com.clothingsale.util.SecurityUtil.checkPassword(password, user.getPassword());
        } catch (IllegalArgumentException ex) {
            matched = false;
        }

        if (!matched) {
            request.setAttribute("errorMessage", "The username or password is incorrect.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        // Prevent customer accounts from signing in via the admin/staff login form
        String roleName = user.getRoleName();
        if (roleName != null && "CUSTOMER".equalsIgnoreCase(roleName)) {
            request.setAttribute("errorMessage", "This account is a customer account. Please sign in via the customer login page.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("authUserId", user.getId());
        session.setAttribute("authUsername", user.getUsername());
        session.setAttribute("authFullName", user.getFullName());
        session.setAttribute("authRoleId", user.getRoleId());
        session.setAttribute("authRoleName", user.getRoleName());

        redirectByRole(session, response, request);
    }

    private void redirectByRole(HttpSession session, HttpServletResponse response, HttpServletRequest request)
        throws IOException {
    Object roleObj = session.getAttribute("authRoleName");
    String roleName = roleObj != null ? roleObj.toString() : null;
    String contextPath = request.getContextPath();

    // Admin & Staff -> admin dashboard
    if ("ADMIN".equalsIgnoreCase(roleName) || "STAFF".equalsIgnoreCase(roleName)) {
        response.sendRedirect(contextPath + "/admin/dashboard");
    }
    // Customer -> front page
    else if ("CUSTOMER".equalsIgnoreCase(roleName)) {
        response.sendRedirect(contextPath + "/");
    } else {
        session.invalidate();
        response.sendRedirect(contextPath + "/admin/login?error=unauthorized");
    }
}
}
