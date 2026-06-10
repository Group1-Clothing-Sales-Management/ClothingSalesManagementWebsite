package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ResendOtp", urlPatterns = {"/customer/resend-otp"})
public class ResendOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/register");
            return;
        }

        int userId = (int) session.getAttribute("pendingUserId");

        // generate new OTP
        String otp = String.format("%06d", (int) (Math.random() * 900000) + 100000);
        java.sql.Timestamp expiry = new java.sql.Timestamp(System.currentTimeMillis() + 15 * 60 * 1000);
        boolean tokenCreated = userDAO.createSecurityToken(userId, otp, expiry);

        if (!tokenCreated) {
            request.setAttribute("errorMessage", "Unable to generate verification token. Please try again.");
        } else {
            // In development we print OTP to server log to help debugging
            System.out.println("[OTP-RESEND] userId=" + userId + " otp=" + otp);
            request.setAttribute("infoMessage", "A new verification code has been generated and sent.");
            request.setAttribute("devOtp", otp);
        }

        request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
    }
}
