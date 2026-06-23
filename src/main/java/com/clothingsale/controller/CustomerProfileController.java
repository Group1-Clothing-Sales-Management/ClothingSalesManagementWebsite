package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.User;
import java.io.IOException;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerProfileController", urlPatterns = {"/customer/profile"})
public class CustomerProfileController extends HttpServlet {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern FULL_NAME_PATTERN = Pattern.compile("^[\\p{L} ]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0[1-9]\\d{8}$");
    private static final Pattern AVATAR_URL_PATTERN = Pattern.compile("^https?://[^\\s\"'<>]{1,247}$");
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer userId = getCustomerUserId(request, response);
        if (userId == null) {
            return;
        }

        User user = userDAO.findById(userId);
        if (user == null || !"CUSTOMER".equalsIgnoreCase(user.getRoleName())) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/customer/login?error=unauthorized");
            return;
        }

        request.setAttribute("profile", user);
        request.getRequestDispatcher("/view/customer/CustomerProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer userId = getCustomerUserId(request, response);
        if (userId == null) {
            return;
        }

        User currentUser = userDAO.findById(userId);
        if (currentUser == null || !"CUSTOMER".equalsIgnoreCase(currentUser.getRoleName())) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/customer/login?error=unauthorized");
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String avatarUrl = trim(request.getParameter("avatarUrl"));

        String error = validateProfile(userId, fullName, email, phone, avatarUrl);
        if (error != null) {
            currentUser.setFullName(fullName);
            currentUser.setEmail(email);
            currentUser.setPhone(phone);
            currentUser.setAvatarUrl(avatarUrl);
            request.setAttribute("profile", currentUser);
            request.setAttribute("errorMessage", error);
            if (isInvalidPhone(phone)) {
                currentUser.setPhone("");
                request.setAttribute("phoneError", error);
                request.setAttribute("focusField", "phone");
            }
            request.getRequestDispatcher("/view/customer/CustomerProfile.jsp").forward(request, response);
            return;
        }

        User updatedUser = new User();
        updatedUser.setId(userId);
        updatedUser.setFullName(fullName);
        updatedUser.setEmail(email);
        updatedUser.setPhone(phone);
        updatedUser.setAvatarUrl(avatarUrl);

        if (!userDAO.updateCustomerProfile(updatedUser)) {
            currentUser.setFullName(fullName);
            currentUser.setEmail(email);
            currentUser.setPhone(phone);
            currentUser.setAvatarUrl(avatarUrl);
            request.setAttribute("profile", currentUser);
            request.setAttribute("errorMessage", "Could not update profile. Please try again.");
            request.getRequestDispatcher("/view/customer/CustomerProfile.jsp").forward(request, response);
            return;
        }

        User savedUser = userDAO.findById(userId);
        HttpSession session = request.getSession(false);
        if (session != null && savedUser != null) {
            session.setAttribute("customerFullName", savedUser.getFullName());
            session.setAttribute("authFullName", savedUser.getFullName());
            session.setAttribute("authUsername", savedUser.getUsername());
        }

        response.sendRedirect(request.getContextPath() + "/customer/profile?updated=1");
    }

    private Integer getCustomerUserId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("authUserId") : null;
        String roleName = session != null ? (String) session.getAttribute("authRoleName") : null;

        if (!(userIdObj instanceof Integer) || !"CUSTOMER".equalsIgnoreCase(roleName)) {
            response.sendRedirect(request.getContextPath() + "/customer/login?error=unauthorized");
            return null;
        }

        return (Integer) userIdObj;
    }

    private String validateProfile(int userId, String fullName, String email, String phone, String avatarUrl) {
        if (fullName == null || fullName.isEmpty()) {
            return "Full name is required.";
        }
        if (fullName.length() > 255) {
            return "Full name is too long.";
        }
        if (!FULL_NAME_PATTERN.matcher(fullName).matches()) {
            return "Full name must contain only letters and spaces (no digits or special characters). Example: Nguyễn Văn A";
        }
        if (email == null || email.isEmpty()) {
            return "Email is required.";
        }
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return "Invalid email format.";
        }
        if (userDAO.isEmailUsedByOtherUser(email, userId)) {
            return "Email already in use.";
        }
        if (phone != null && !phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches()) {
            return "Invalid phone number. Expect 10 digits starting with single 0 (e.g. 0123456789), not 00...";
        }
        if (avatarUrl != null && !avatarUrl.isEmpty()) {
            if (avatarUrl.length() > 255) {
                return "Avatar URL must be 255 characters or less.";
            }
            if (!AVATAR_URL_PATTERN.matcher(avatarUrl).matches()) {
                return "Avatar URL must be a valid http:// or https:// image URL.";
            }
        }
        return null;
    }

    private boolean isInvalidPhone(String phone) {
        return phone != null && !phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches();
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
