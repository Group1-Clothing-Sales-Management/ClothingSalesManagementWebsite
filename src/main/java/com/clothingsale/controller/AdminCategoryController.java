package com.clothingsale.controller;

import com.clothingsale.dao.AdminManageCategoryDAO;
import com.clothingsale.model.Category;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(
        name = "AdminManageCategory",
        urlPatterns = {"/admin/manage-category", "/admin/categories"}
)
public class AdminCategoryController extends HttpServlet {

    private final AdminManageCategoryDAO categoryDAO = new AdminManageCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // Luồng hiển thị danh sách luôn chạy để đảm bảo bảng dữ liệu luôn có data
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);

        if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Category category = categoryDAO.getCategoryById(id);
                if (category != null) {
                    // Đẩy đối tượng cần sửa lên request để JSP nhận biết chế độ "Sửa"
                    request.setAttribute("category", category);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // TẤT CẢ các hành động GET đều đổ về duy nhất một trang này
        request.getRequestDispatcher("/view/admin/admin_category.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String statusRedirect = "success";

        try {
            if ("ADD".equals(action)) {
                String name = request.getParameter("categoryName");
                String slug = request.getParameter("slug");

                Category c = new Category();
                c.setCategoryName(name);
                c.setSlug(slug);

                if (!categoryDAO.insertCategory(c)) {
                    statusRedirect = "error";
                }

            } else if ("UPDATE".equals(action)) {
                int id = Integer.parseInt(request.getParameter("categoryId"));
                String name = request.getParameter("categoryName");
                String slug = request.getParameter("slug");

                Category c = new Category();
                c.setId(id);
                c.setCategoryName(name);
                c.setSlug(slug);

                if (!categoryDAO.updateCategory(c)) {
                    statusRedirect = "error";
                }

            } else if ("DELETE".equals(action)) {
                int id = Integer.parseInt(request.getParameter("categoryId"));
                if (!categoryDAO.softDeleteCategory(id)) {
                    statusRedirect = "error";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            statusRedirect = "error";
        }

        // Post-Redirect-Get pattern chuẩn quy tắc dự án của bạn
        response.sendRedirect(request.getContextPath() + "/admin/manage-category?status=" + statusRedirect);
    }
}
