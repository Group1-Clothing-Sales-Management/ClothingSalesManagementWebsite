package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.EmailVerificationStatus;
import com.clothingsale.model.User;
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
    private static final int MAX_INVALID_ATTEMPTS = 5;
    private static final String VERIFICATION_CONTEXT_LOGIN = "LOGIN";
    private static final String PENDING_STATUS = "CLOCK";
    private static final String PENDING_STATUS_LEGACY = "PENDING";
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "No pending verification session found. Please sign in or register first.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        Integer userId = asInteger(session.getAttribute("pendingUserId"));
        User user = userId != null ? userDAO.findById(userId) : null;
        if (user == null) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "Your pending account could not be found. Please sign in or register again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() != null && "ACTIVE".equalsIgnoreCase(user.getStatus())) {
            boolean loginFlow = isLoginVerificationFlow(session);
            clearPendingSession(session);
            if (loginFlow) {
                establishCustomerSession(session, user);
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/login?verified=1");
            }
            return;
        }

        if (!isPendingStatus(user.getStatus())) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "This account is not waiting for verification anymore.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        request.setAttribute("verificationAllowed", Boolean.TRUE);
        request.setAttribute("pendingEmail", user.getEmail());
        request.setAttribute("pendingUsername", user.getUsername());
        request.setAttribute("verificationContext", getVerificationContext(session));
        request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String code = request.getParameter("code");
        if (code != null) {
            code = code.trim();
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "Your verification session has expired. Please sign in or register again.");
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
            request.setAttribute("errorMessage", "Your account was not found. Please sign in or register again.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() != null && "ACTIVE".equalsIgnoreCase(user.getStatus())) {
            boolean loginFlow = isLoginVerificationFlow(session);
            clearPendingSession(session);
            if (loginFlow) {
                establishCustomerSession(session, user);
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/login?verified=1");
            }
            return;
        }

        if (!isPendingStatus(user.getStatus())) {
            clearPendingSession(session);
            request.setAttribute("verificationAllowed", Boolean.FALSE);
            request.setAttribute("errorMessage", "This account is not waiting for verification anymore.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        int attempts = asInteger(session.getAttribute("verificationAttempts")) != null
                ? asInteger(session.getAttribute("verificationAttempts"))
                : 0;
        if (attempts >= MAX_INVALID_ATTEMPTS) {
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("errorMessage", "Too many invalid attempts. Please resend a new code.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if (code == null || !code.matches("^\\d{6}$")) {
            attempts++;
            session.setAttribute("verificationAttempts", attempts);
            request.setAttribute("verificationAllowed", Boolean.TRUE);
            request.setAttribute("verificationContext", getVerificationContext(session));
            request.setAttribute("errorMessage", "Verification code must be exactly 6 digits.");
            request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        EmailVerificationStatus status = userDAO.verifyTokenForUser(userId, code);
        switch (status) {
            case SUCCESS:
                handleVerifiedCustomer(request, response, session, user);
                return;
            case ALREADY_ACTIVE:
                boolean loginFlow = isLoginVerificationFlow(session);
                clearPendingSession(session);
                if (loginFlow) {
                    establishCustomerSession(session, user);
                    response.sendRedirect(request.getContextPath() + "/home");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/login?verified=1");
                }
                return;
            case CODE_EXPIRED:
                request.setAttribute("verificationAllowed", Boolean.TRUE);
                request.setAttribute("verificationContext", getVerificationContext(session));
                request.setAttribute("errorMessage", "This code has expired. Please resend a new one.");
                request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
                return;
            case CODE_USED:
                request.setAttribute("verificationAllowed", Boolean.TRUE);
                request.setAttribute("verificationContext", getVerificationContext(session));
                request.setAttribute("errorMessage", "This code has already been used. Please resend a new one.");
                request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
                return;
            case INVALID_CODE:
                attempts++;
                session.setAttribute("verificationAttempts", attempts);
                request.setAttribute("verificationAllowed", Boolean.TRUE);
                request.setAttribute("verificationContext", getVerificationContext(session));
                if (attempts >= MAX_INVALID_ATTEMPTS) {
                    request.setAttribute("errorMessage", "Too many invalid attempts. Please resend a new code.");
                } else {
                    request.setAttribute("errorMessage", "Invalid verification code. Please check and try again.");
                }
                request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
                return;
            case USER_NOT_FOUND:
            case NOT_PENDING:
                clearPendingSession(session);
                request.setAttribute("verificationAllowed", Boolean.FALSE);
                request.setAttribute("errorMessage", "This account is not waiting for verification anymore.");
                request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
                return;
            default:
                request.setAttribute("verificationAllowed", Boolean.TRUE);
                request.setAttribute("verificationContext", getVerificationContext(session));
                request.setAttribute("errorMessage", "Unable to verify right now. Please try again.");
                request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
        }
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

    private boolean isLoginVerificationFlow(HttpSession session) {
        String context = getVerificationContext(session);
        return VERIFICATION_CONTEXT_LOGIN.equalsIgnoreCase(context);
    }

    private String getVerificationContext(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("pendingVerificationContext");
        return value != null ? value.toString() : null;
    }

    private void handleVerifiedCustomer(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User user) throws IOException {
        if (isLoginVerificationFlow(session)) {
            clearPendingSession(session);
            establishCustomerSession(session, user);
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        clearPendingSession(session);
        response.sendRedirect(request.getContextPath() + "/customer/login?verified=1");
    }

    private void establishCustomerSession(HttpSession session, User user) {
        if (session == null || user == null) {
            return;
        }

        session.setAttribute("customerId", user.getId());
        session.setAttribute("customerUsername", user.getUsername());
        session.setAttribute("customerFullName", user.getFullName());
        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("authUserId", user.getId());
        session.setAttribute("authUsername", user.getUsername());
        session.setAttribute("authFullName", user.getFullName());
        session.setAttribute("authRoleId", user.getRoleId());
        session.setAttribute("authRoleName", user.getRoleName());
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
