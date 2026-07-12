package com.clothingsale.controller;

import com.clothingsale.model.User;
import com.clothingsale.service.AdminManageStaffService;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/staffs")
public class AdminManageStaffController extends HttpServlet {

    // Service này giữ phần validate và gọi DAO, còn servlet chỉ lo điều phối request/response.
    private final AdminManageStaffService staffService = new AdminManageStaffService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "list";
        }

        switch (action) {
            case "add":
                // Mode add chỉ cần set cờ giao diện, không cần nạp dữ liệu từ DB.
                User emptyForm = new User();
                emptyForm.setStatus("ACTIVE");
                request.setAttribute("formData", emptyForm);
                request.setAttribute("pageMode", "add");
                request.setAttribute("staffBasePath", buildStaffBasePath(request));
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
                break;
            case "edit":
                handleShowEdit(request, response);
                break;
            case "list":
            default:
                handleList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            handleAdd(request, response);
        } else if ("update".equals(action)) {
            handleUpdate(request, response);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(buildStaffBasePath(request));
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");

        // Danh sách staff được lấy qua service để controller không phải biết chi tiết query.
        List<User> staffs = staffService.getStaffs(keyword);
        request.setAttribute("staffs", staffs);
        request.setAttribute("keyword", keyword);
        request.setAttribute("staffBasePath", buildStaffBasePath(request));
        request.setAttribute("pageMode", "list");
        request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
    }

    private void handleShowEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        User staff = staffService.getStaffById(id);

        if (staff == null) {
            request.getSession().setAttribute("errorMsg", "Không tìm thấy tài khoản staff cần chỉnh sửa.");
            response.sendRedirect(buildStaffBasePath(request));
            return;
        }

        request.setAttribute("staff", staff);
        request.setAttribute("staffBasePath", buildStaffBasePath(request));
        request.setAttribute("pageMode", "edit");
        request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User staff = buildStaffFromRequest(request, 0);
        String password = request.getParameter("password");

        Map<String, String> errors = staffService.createStaff(staff, password);
        if (errors.isEmpty()) {
            request.getSession().setAttribute("successMsg", "Tạo tài khoản staff thành công.");
            response.sendRedirect(buildStaffBasePath(request));
            return;
        }

        request.setAttribute("errors", errors);
        request.setAttribute("formData", staff);
        request.setAttribute("staffBasePath", buildStaffBasePath(request));
        request.setAttribute("pageMode", "add");
        request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        User staff = buildStaffFromRequest(request, id);

        Map<String, String> errors = staffService.updateStaff(staff);
        if (errors.isEmpty()) {
            request.getSession().setAttribute("successMsg", "Cập nhật tài khoản staff thành công.");
            response.sendRedirect(buildStaffBasePath(request));
            return;
        }

        request.setAttribute("errors", errors);
        request.setAttribute("staff", staff);
        request.setAttribute("staffBasePath", buildStaffBasePath(request));
        request.setAttribute("pageMode", "edit");
        request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = parseId(request.getParameter("id"));
        boolean deleted = staffService.deleteStaffAccount(id);

        if (deleted) {
            request.getSession().setAttribute("successMsg", "Đã xóa mềm tài khoản staff.");
        } else {
            request.getSession().setAttribute("errorMsg", "Không thể xóa tài khoản staff. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(buildStaffBasePath(request));
    }

    /**
     * Gom dữ liệu form về một model User để service xử lý.
     * Cách này giúp tránh phải đọc từng parameter ở nhiều nơi.
     */
    private User buildStaffFromRequest(HttpServletRequest request, int id) {
        User staff = new User();
        staff.setId(id);
        staff.setUsername(request.getParameter("username"));
        staff.setFullName(request.getParameter("fullName"));
        staff.setEmail(request.getParameter("email"));
        staff.setPhone(request.getParameter("phone"));
        staff.setStatus(request.getParameter("status"));
        return staff;
    }

    private int parseId(String raw) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception ex) {
            return 0;
        }
    }

    /**
     * Route này là màn hình quản lý staff riêng của admin, nên chỉ ADMIN mới được vào.
     */
    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return false;
        }

        Object role = session.getAttribute("authRoleName");
        if (role == null || !"ADMIN".equalsIgnoreCase(role.toString())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return false;
        }

        return true;
    }

    private String buildStaffBasePath(HttpServletRequest request) {
        return request.getContextPath() + "/admin/staffs";
    }
}
