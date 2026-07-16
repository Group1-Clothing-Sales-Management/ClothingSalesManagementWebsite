package com.clothingsale.controller;

import com.clothingsale.service.AdminManageCategoryService;
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

    private final AdminManageCategoryService categoryService
            = new AdminManageCategoryService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        List<Category> categories
                = categoryService.getAllCategories();

        int activeCount = 0;
        int inactiveCount = 0;

        for (Category category : categories) {
            if (category.getStatus() == 1) {
                activeCount++;
            } else {
                inactiveCount++;
            }
        }

        request.setAttribute("categories", categories);

        request.setAttribute(
                "totalCategoryCount",
                categories.size()
        );

        request.setAttribute(
                "activeCategoryCount",
                activeCount
        );

        request.setAttribute(
                "inactiveCategoryCount",
                inactiveCount
        );

        request.getRequestDispatcher(
                "/view/admin/admin_category.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String status;

        if (action == null) {
            status = "invalid-action";
        } else {
            switch (action.trim().toUpperCase()) {
                case "ADD":
                    status = categoryService.addCategory(
                            request.getParameter("categoryName")
                    );
                    break;

                case "UPDATE":
                    status = categoryService.updateCategory(
                            parseId(
                                    request.getParameter("categoryId")
                            ),
                            request.getParameter("categoryName")
                    );
                    break;

                case "DEACTIVATE":
                    status = categoryService.deactivateCategory(
                            parseId(
                                    request.getParameter("categoryId")
                            )
                    );
                    break;

                case "RESTORE":
                    status = categoryService.restoreCategory(
                            parseId(
                                    request.getParameter("categoryId")
                            )
                    );
                    break;

                default:
                    status = "invalid-action";
                    break;
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-category?status="
                + status
        );
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
