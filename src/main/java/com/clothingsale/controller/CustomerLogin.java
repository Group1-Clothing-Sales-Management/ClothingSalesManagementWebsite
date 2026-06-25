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

@WebServlet(name = "CustomerLogin", urlPatterns = {"/customer/login"})
public class CustomerLogin extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String created = request.getParameter("created");
        if ("1".equals(created)) {
            request.setAttribute("successMessage", "Account created successfully. Please sign in.");
        }
        request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null) username = username.trim();
        if (password == null) password = "";

        HttpSession session = request.getSession(true);
        // simple session-based rate limit: lock after 5 failed attempts for 5 minutes
        Object lockedObj = session.getAttribute("loginLockedUntil");
        if (lockedObj instanceof Long) {
            long until = (Long) lockedObj;
            if (System.currentTimeMillis() < until) {
                request.setAttribute("errorMessage", "Account temporarily locked. Please try again later.");
                request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
                return;
            } else {
                session.removeAttribute("loginLockedUntil");
                session.removeAttribute("loginAttempts");
            }
        }

        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Please enter username and password.");
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }
        User user = userDAO.findByUsernameOrEmail(username);
        if (user == null) {
            // increment attempts
            Integer at = (Integer) session.getAttribute("loginAttempts");
            at = (at == null) ? 1 : at + 1;
            session.setAttribute("loginAttempts", at);
            if (at >= 5) {
                session.setAttribute("loginLockedUntil", System.currentTimeMillis() + 5 * 60 * 1000);
                request.setAttribute("errorMessage", "Account temporarily locked due to multiple failed attempts.");
            } else {
                request.setAttribute("errorMessage", "Account does not exist.");
            }
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("errorMessage", "Account not active. Please verify your email or resend activation code.");
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }

        // verify password using SecurityUtil
        try {
            boolean ok = com.clothingsale.util.SecurityUtil.checkPassword(password, user.getPassword());
            if (!ok) {
                Integer at = (Integer) session.getAttribute("loginAttempts");
                at = (at == null) ? 1 : at + 1;
                session.setAttribute("loginAttempts", at);
                if (at >= 5) {
                    session.setAttribute("loginLockedUntil", System.currentTimeMillis() + 5 * 60 * 1000);
                    request.setAttribute("errorMessage", "Account temporarily locked due to multiple failed attempts.");
                } else {
                    request.setAttribute("errorMessage", "Incorrect password.");
                }
                request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
                return;
            }
            // successful login -> clear attempts
            session.removeAttribute("loginAttempts");
            session.removeAttribute("loginLockedUntil");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", "Invalid credentials.");
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }
        // Set both customer-specific and unified auth attributes so filters/controllers work consistently
        session.setAttribute("customerId", user.getId());
        session.setAttribute("customerUsername", user.getUsername());
        session.setAttribute("customerFullName", user.getFullName());

        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("authUserId", user.getId());
        session.setAttribute("authUsername", user.getUsername());
        session.setAttribute("authFullName", user.getFullName());
        session.setAttribute("authRoleId", user.getRoleId());
        session.setAttribute("authRoleName", user.getRoleName());

        response.sendRedirect(request.getContextPath() + "/home");
    }
}
