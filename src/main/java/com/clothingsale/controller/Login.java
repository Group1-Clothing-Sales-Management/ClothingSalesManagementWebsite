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

@WebServlet(name = "Login", urlPatterns = {"/admin-staff-login", "/login"})
public class Login extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String ADMIN_ROLE = "ADMIN";
    private static final String STAFF_ROLE = "STAFF";

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String messageType = request.getParameter("error");
        String logout = request.getParameter("logout");

        if (session != null && session.getAttribute("authUserId") != null
                && messageType == null && logout == null) {
            redirectByRole(session, response, request);
            return;
        }

        if ("unauthorized".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "Vui lòng đăng nhập để tiếp tục.");
        } else if ("forbidden".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "Tài khoản hiện tại không có quyền truy cập trang này.");
        } else if ("timeout".equalsIgnoreCase(messageType)) {
            request.setAttribute("errorMessage", "Phiên làm việc đã hết hạn, vui lòng đăng nhập lại.");
        } else if ("1".equals(logout)) {
            request.setAttribute("successMessage", "Bạn đã đăng xuất khỏi hệ thống.");
        }

        request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        request.setAttribute("username", username != null ? username.trim() : "");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.authenticateInternalAccount(username.trim(), password);
        if (user == null) {
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);
        session.setAttribute("authUserId", user.getId());
        session.setAttribute("authUsername", user.getUsername());
        session.setAttribute("authFullName", user.getFullName());
        session.setAttribute("authRoleId", user.getRoleId());
        session.setAttribute("authRoleName", user.getRoleName());

        redirectByRole(session, response, request);
    }

    private void redirectByRole(HttpSession session, HttpServletResponse response, HttpServletRequest request)
            throws IOException {
        Object roleObj = session.getAttribute("authRoleName");
        String roleName = roleObj != null ? roleObj.toString() : null;
        String contextPath = request.getContextPath();

        if (ADMIN_ROLE.equalsIgnoreCase(roleName)) {
            response.sendRedirect(contextPath + "/AdminDashboard");
        } else if (STAFF_ROLE.equalsIgnoreCase(roleName)) {
            response.sendRedirect(contextPath + "/StaffManageProducts");
        } else {
            session.invalidate();
            response.sendRedirect(contextPath + "/admin-staff-login?error=unauthorized");
        }
    }
}
