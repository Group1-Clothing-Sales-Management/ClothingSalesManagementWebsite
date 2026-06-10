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

@WebServlet(name = "CustomerRegister", urlPatterns = {"/customer/register"})
public class CustomerRegister extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        request.setAttribute("username", username != null ? username : "");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()
                || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please fill required fields.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPhone(phone);

        // If developer or simple flow: allow creating ACTIVE account directly when "useOtp" != "1"
        String useOtp = request.getParameter("useOtp");
        if ("1".equals(useOtp)) {
            int userId = userDAO.createCustomerPending(user, password);
            if (userId <= 0) {
                request.setAttribute("errorMessage", "Unable to create account. Username or email may exist.");
                request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
                return;
            }

            // generate 6-digit OTP and store token
            String otp = String.format("%06d", (int) (Math.random() * 900000) + 100000);
            java.sql.Timestamp expiry = new java.sql.Timestamp(System.currentTimeMillis() + 15 * 60 * 1000);
            boolean tokenCreated = userDAO.createSecurityToken(userId, otp, expiry);

            // in real app send email; here we log it and forward to verify page
            System.out.println("[OTP] userId=" + userId + " otp=" + otp);

            if (!tokenCreated) {
                request.setAttribute("errorMessage", "Unable to generate verification token. Please try again.");
                request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
                return;
            }

            // keep pending user id in session for verification step
            HttpSession session = request.getSession(true);
            session.setAttribute("pendingUserId", userId);
            request.setAttribute("infoMessage", "A verification code has been sent to your email. Use it to activate your account.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        // Default: create ACTIVE customer (no OTP) so user can sign in immediately
        boolean ok = userDAO.createCustomer(user, password);
        if (!ok) {
            request.setAttribute("errorMessage", "Unable to create account. Username or email may exist.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/login?created=1");
    }
}
