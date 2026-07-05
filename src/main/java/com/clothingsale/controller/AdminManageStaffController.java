package com.clothingsale.controller;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/staffs")
public class AdminManageStaffController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                request.setAttribute("pageMode", "add");
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
                break;
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                User staff = userDAO.findById(id);
                if (staff == null || !"STAFF".equals(staff.getRoleName())) {
                    response.sendRedirect(request.getContextPath() + "/admin/staffs");
                    return;
                }
                request.setAttribute("staff", staff);
                request.setAttribute("pageMode", "edit");
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
                break;

            case "toggle":
                try {
                    int toggleId = Integer.parseInt(request.getParameter("id"));
                    boolean toggled = userDAO.toggleStaffStatus(toggleId);
                    if (toggled) {
                        request.getSession().setAttribute("successMsg", "Thay đổi trạng thái (Xóa/Mở) tài khoản thành công!");
                    } else {
                        request.getSession().setAttribute("errorMsg", "Không thể thay đổi trạng thái!");
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMsg", "ID không hợp lệ!");
                }
                // Chạy xong redirect về lại trang danh sách
                response.sendRedirect(request.getContextPath() + "/admin/staffs");
                break;
            case "list":
            default:
                String keyword = request.getParameter("keyword");
                List<User> staffs = userDAO.getAllStaffs(keyword);
                request.setAttribute("staffs", staffs);
                request.setAttribute("keyword", keyword);
                request.setAttribute("pageMode", "list");
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            User staff = new User();
            staff.setUsername(request.getParameter("username"));
            staff.setFullName(request.getParameter("fullName"));
            staff.setEmail(request.getParameter("email"));
            staff.setPhone(request.getParameter("phone"));
            staff.setStatus(request.getParameter("status"));
            String password = request.getParameter("password");

            // Validate đơn giản (Có thể tái sử dụng logic error map của bạn)
            if (userDAO.findByUsername(staff.getUsername()) != null) {
                request.setAttribute("errors_general", "Username đã tồn tại!");
                request.setAttribute("formData", staff);
                request.setAttribute("pageMode", "add");
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
                return;
            }

            boolean success = userDAO.createStaff(staff, password);
            if (success) {
                session.setAttribute("successMsg", "Thêm nhân viên thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/staffs");
            } else {
                request.setAttribute("errors_general", "Có lỗi xảy ra khi thêm nhân viên.");
                request.setAttribute("pageMode", "add");
                request.getRequestDispatcher("/view/admin/admin_manage_staff.jsp").forward(request, response);
            }

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            User staff = userDAO.findById(id);
            if (staff != null) {
                staff.setFullName(request.getParameter("fullName"));
                staff.setEmail(request.getParameter("email"));
                staff.setPhone(request.getParameter("phone"));
                staff.setStatus(request.getParameter("status"));

                boolean success = userDAO.updateStaffProfile(staff);
                if (success) {
                    session.setAttribute("successMsg", "Cập nhật nhân viên thành công!");
                } else {
                    session.setAttribute("errorMsg", "Cập nhật thất bại.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/staffs");
        }
    }
}
