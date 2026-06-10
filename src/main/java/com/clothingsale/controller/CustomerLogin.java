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

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Please enter username and password.");
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByUsernameOrEmail(username.trim());
        if (user == null) {
            request.setAttribute("errorMessage", "Invalid credentials.");
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
                request.setAttribute("errorMessage", "Invalid credentials.");
                request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
                return;
            }
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", "Invalid credentials.");
            request.getRequestDispatcher("/view/auth/customer_login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("customerId", user.getId());
        session.setAttribute("customerUsername", user.getUsername());
        session.setAttribute("customerFullName", user.getFullName());

        response.sendRedirect(request.getContextPath() + "/");
    }
}
