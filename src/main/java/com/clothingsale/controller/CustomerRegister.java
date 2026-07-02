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

@WebServlet(name = "CustomerRegister", urlPatterns = {"/customer/register"})
public class CustomerRegister extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int OTP_EXPIRY_MINUTES = 15;
    private static final long OTP_RESEND_COOLDOWN_MS = 30_000L;
    private static final String VERIFICATION_CONTEXT_REGISTER = "REGISTER";
    private static final String PENDING_STATUS = "CLOCK";
    private static final String PENDING_STATUS_LEGACY = "PENDING";
    private final UserDAO userDAO = new UserDAO();
    private final MailtrapEmailService mailService = new MailtrapEmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = normalize(request.getParameter("username"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = normalize(request.getParameter("fullName"));
        String email = normalize(request.getParameter("email"));
        String phone = normalize(request.getParameter("phone"));

        request.setAttribute("username", username);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        if (!isNotBlank(username) || !isNotBlank(password) || !isNotBlank(confirmPassword)
                || !isNotBlank(fullName) || !isNotBlank(email)) {
            forwardWithError(request, response, "Please fill in all required fields.");
            return;
        }

        if (username.length() < 3 || username.length() > 50) {
            forwardWithError(request, response, "Username must be between 3 and 50 characters.");
            return;
        }

        if (!username.matches("^[A-Za-z0-9._-]+$")) {
            forwardWithError(request, response, "Username can only contain letters, numbers, dot, underscore, and hyphen.");
            return;
        }

        if (password.length() < 6) {
            forwardWithError(request, response, "Password must be at least 6 characters.");
            return;
        }

        if (password.length() > 255) {
            forwardWithError(request, response, "Password is too long.");
            return;
        }

        if (!password.equals(confirmPassword)) {
            forwardWithError(request, response, "Password confirmation does not match.");
            return;
        }

        if (fullName.length() > 255) {
            forwardWithError(request, response, "Full name is too long.");
            return;
        }

        if (!fullName.matches("^[\\p{L} ]+$")) {
            forwardWithError(request, response, "Full name can only contain letters and spaces.");
            return;
        }

        String emailRegex = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$";
        if (!email.matches(emailRegex)) {
            forwardWithError(request, response, "Invalid email format.");
            return;
        }

        if (!isNotBlank(phone)) {
            phone = "";
        } else if (!phone.matches("^0[1-9]\\d{8}$")) {
            forwardWithError(request, response, "Invalid phone number. Expect 10 digits starting with a single 0.");
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);

        User existingByUsername = userDAO.findByUsername(username);
        User existingByEmail = userDAO.findByEmail(email);

        if (existingByUsername != null && existingByEmail != null
                && existingByUsername.getId() != existingByEmail.getId()) {
            forwardWithError(request, response, "Username and email already belong to different accounts.");
            return;
        }

        User existingAccount = existingByUsername != null ? existingByUsername : existingByEmail;
        int userId;
        boolean reusedPendingAccount = false;

        if (existingAccount != null) {
            if ("ACTIVE".equalsIgnoreCase(existingAccount.getStatus())) {
                forwardWithError(request, response, "An active account already uses this username or email. Please sign in.");
                return;
            }

            if (!isPendingStatus(existingAccount.getStatus())) {
                forwardWithError(request, response, "This account exists but is not ready for verification. Please contact support.");
                return;
            }

            user.setId(existingAccount.getId());
            if (!userDAO.updatePendingCustomer(user, password)) {
                forwardWithError(request, response, "Unable to update the pending account. Please try again.");
                return;
            }

            userId = existingAccount.getId();
            reusedPendingAccount = true;
        } else {
            userId = userDAO.createCustomerPending(user, password);
            if (userId <= 0) {
                forwardWithError(request, response, "Unable to create account. Username or email may already exist.");
                return;
            }
        }

        Timestamp expiry = new Timestamp(System.currentTimeMillis() + OTP_EXPIRY_MINUTES * 60_000L);
        String verificationCode = userDAO.generateEmailVerificationCode(userId, expiry);
        if (verificationCode == null) {
            forwardWithError(request, response, "Unable to generate verification code. Please try again.");
            return;
        }

        boolean emailSent = false;
        try {
            mailService.sendVerificationCode(email, fullName, verificationCode, OTP_EXPIRY_MINUTES);
            emailSent = true;
        } catch (IllegalStateException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
        } catch (MessagingException ex) {
            request.setAttribute("errorMessage", "We could not send the verification email right now. Please try resend in a moment.");
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("pendingUserId", userId);
        session.setAttribute("pendingEmail", email);
        session.setAttribute("pendingUsername", username);
        session.setAttribute("pendingVerificationContext", VERIFICATION_CONTEXT_REGISTER);
        session.setAttribute("verificationLastSentAt", System.currentTimeMillis());
        session.setAttribute("verificationAttempts", 0);
        session.setAttribute("verificationExpiresAt", expiry.getTime());

        if (emailSent) {
            request.setAttribute("infoMessage", reusedPendingAccount
                    ? "Your pending account has been updated. We sent a new verification code to your email."
                    : "A verification code has been sent to your email. Use it to activate your account.");
        } else if (request.getAttribute("errorMessage") == null) {
            request.setAttribute("errorMessage", "Account is pending, but the verification email could not be sent. Please resend the code after checking SMTP settings.");
        }

        request.setAttribute("verificationAllowed", Boolean.TRUE);
        request.setAttribute("verificationContext", VERIFICATION_CONTEXT_REGISTER);
        request.setAttribute("pendingEmail", email);
        request.getRequestDispatcher("/view/auth/verify_otp.jsp").forward(request, response);
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim();
    }

    private boolean isNotBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private boolean isPendingStatus(String status) {
        return status != null && (PENDING_STATUS.equalsIgnoreCase(status)
                || PENDING_STATUS_LEGACY.equalsIgnoreCase(status));
    }
}
