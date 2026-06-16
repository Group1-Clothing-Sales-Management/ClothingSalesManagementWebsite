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

        // normalize
        username = username == null ? "" : username.trim();
        password = password == null ? "" : password;
        fullName = fullName == null ? "" : fullName.trim();
        email = email == null ? "" : email.trim();
        phone = phone == null ? "" : phone.trim();

        request.setAttribute("username", username);

        // basic validation
        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || email.isEmpty()) {
            request.setAttribute("errorMessage", "Please fill required fields.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        if (username.length() > 50) {
            request.setAttribute("errorMessage", "Username is too long (max 50 chars).");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() > 255) {
            request.setAttribute("errorMessage", "Password is too long.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        if (fullName.length() > 255) {
            request.setAttribute("errorMessage", "Full name is too long.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        // fullName must contain only letters and spaces (no digits or special characters)
        // allow Unicode letters for Vietnamese names
        if (!fullName.matches("^[\\p{L} ]+$")) {
            request.setAttribute("errorMessage", "Full name must contain only letters and spaces (no digits or special characters). Example: Nguyễn Văn A");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        // basic email format check
        String emailRegex = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$";
        if (!email.matches(emailRegex)) {
            request.setAttribute("errorMessage", "Invalid email format.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        // phone optional but if provided must be 10 digits, start with single 0 (not '00'), e.g. 0123456789
        if (!phone.isEmpty()) {
            if (!phone.matches("^0[1-9]\\d{8}$")) {
                request.setAttribute("errorMessage", "Invalid phone number. Expect 10 digits starting with single 0 (e.g. 0123456789), not 00...");
                request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
                return;
            }
        }

        // check duplicates
        if (userDAO.findByUsername(username) != null) {
            request.setAttribute("errorMessage", "Username already exists.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }
        if (userDAO.findByUsernameOrEmail(email) != null) {
            request.setAttribute("errorMessage", "Email already in use.");
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
