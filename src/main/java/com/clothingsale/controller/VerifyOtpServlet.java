package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "VerifyOtp", urlPatterns = {"/customer/verify-otp"})
public class VerifyOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/register");
            return;
        }

        int userId = (int) session.getAttribute("pendingUserId");
        boolean ok = userDAO.verifyTokenForUser(userId, code);
        if (!ok) {
            request.setAttribute("errorMessage", "Invalid or expired code. Please try again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        // verification successful; remove pendingUserId
        session.removeAttribute("pendingUserId");
        response.sendRedirect(request.getContextPath() + "/customer/login?created=1");
    }
}
