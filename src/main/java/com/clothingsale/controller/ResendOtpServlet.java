package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.User;
import com.clothingsale.util.MailtrapEmailService;
import java.io.IOException;
import java.sql.Timestamp;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ResendOtp", urlPatterns = {"/customer/resend-otp"})
public class ResendOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int OTP_EXPIRY_MINUTES = 15;
    private static final long RESEND_COOLDOWN_MS = 30_000L;
    private static final String PENDING_STATUS = "CLOCK";
    private static final String PENDING_STATUS_LEGACY = "PENDING";
    private final UserDAO userDAO = new UserDAO();
    private final MailtrapEmailService mailService = new MailtrapEmailService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "No pending verification session found. Please sign in or register again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        Integer userId = asInteger(session.getAttribute("pendingUserId"));
        if (userId == null) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "Invalid verification session. Please sign in or register again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findById(userId);
        if (user == null) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "Your pending account could not be found. Please sign in or register again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() != null && "ACTIVE".equalsIgnoreCase(user.getStatus())) {
            clearPendingSession(session);
            response.sendRedirect(request.getContextPath() + "/customer/login?verified=1");
            return;
        }

        if (!isPendingStatus(user.getStatus())) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "This account is not waiting for verification anymore.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        Long lastSentAt = asLong(session.getAttribute("verificationLastSentAt"));
        long now = System.currentTimeMillis();
        if (lastSentAt != null && now - lastSentAt < RESEND_COOLDOWN_MS) {
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("errorMessage", "Please wait a moment before requesting another code.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        Timestamp expiry = new Timestamp(now + OTP_EXPIRY_MINUTES * 60_000L);
        String code = userDAO.generateEmailVerificationCode(userId, expiry);
        if (code == null) {
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("errorMessage", "Unable to generate a new verification code. Please try again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        try {
            mailService.sendVerificationCode(user.getEmail(), user.getFullName(), code, OTP_EXPIRY_MINUTES);
            session.setAttribute("verificationLastSentAt", now);
            session.setAttribute("verificationAttempts", 0);
            session.setAttribute("pendingEmail", user.getEmail());
            session.setAttribute("pendingUsername", user.getUsername());
            session.setAttribute("pendingVerificationContext", getVerificationContext(session));
            session.setAttribute("verificationExpiresAt", expiry.getTime());
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("infoMessage", "A new verification code has been sent to your email.");
        } catch (IllegalStateException ex) {
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("errorMessage", ex.getMessage());
        } catch (MessagingException ex) {
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("errorMessage", "We could not send the verification email right now. Please try again later.");
        }

        request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
    }

    private Integer asInteger(Object value) {
        if (value instanceof Integer) {
            return (Integer) value;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return null;
    }

    private Long asLong(Object value) {
        if (value instanceof Long) {
            return (Long) value;
        }
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return null;
    }

    private String getVerificationContext(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("pendingVerificationContext");
        return value != null ? value.toString() : null;
    }

    private void clearPendingSession(HttpSession session) {
        if (session == null) {
            return;
        }

        session.removeAttribute("pendingUserId");
        session.removeAttribute("pendingEmail");
        session.removeAttribute("pendingUsername");
        session.removeAttribute("pendingVerificationContext");
        session.removeAttribute("verificationAttempts");
        session.removeAttribute("verificationLastSentAt");
        session.removeAttribute("verificationExpiresAt");
    }

    private boolean isPendingStatus(String status) {
        return status != null && (PENDING_STATUS.equalsIgnoreCase(status)
                || PENDING_STATUS_LEGACY.equalsIgnoreCase(status));
    }
}
