package com.clothingsale.controller;

import com.clothingsale.model.Category;
import com.clothingsale.service.AdminManageCategoryService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(
        name = "AdminManageCategory",
        urlPatterns = {
            "/admin/manage-category",
            "/admin/categories"
        }
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

        List<Category> parentCategories
                = categoryService.getRootCategories();

        int activeCount = 0;
        int inactiveCount = 0;
        int rootCount = 0;
        int subcategoryCount = 0;

        for (Category category : categories) {
            if (category.getStatus() == 1) {
                activeCount++;
            } else {
                inactiveCount++;
            }

            if (category.getParentId() == null) {
                rootCount++;
            } else {
                subcategoryCount++;
            }
        }

        request.setAttribute("categories", categories);
        request.setAttribute(
                "parentCategories",
                parentCategories
        );

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
        request.setAttribute(
                "rootCategoryCount",
                rootCount
        );
        request.setAttribute(
                "subcategoryCount",
                subcategoryCount
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

        String action = normalizeAction(
                request.getParameter("action")
        );

        String status;

        switch (action) {
            case "ADD":
                status = categoryService.addCategory(
                        request.getParameter("categoryName"),
                        parseNullableId(
                                request.getParameter(
                                        "parentCategoryId"
                                )
                        ),
                        request.getParameter("description")
                );
                break;

            case "UPDATE":
                status = categoryService.updateCategory(
                        parseRequiredId(
                                request.getParameter("categoryId")
                        ),
                        request.getParameter("categoryName"),
                        parseNullableId(
                                request.getParameter(
                                        "parentCategoryId"
                                )
                        ),
                        request.getParameter("description")
                );
                break;

            case "DEACTIVATE":
                status = categoryService.deactivateCategory(
                        parseRequiredId(
                                request.getParameter("categoryId")
                        )
                );
                break;

            case "RESTORE":
                status = categoryService.restoreCategory(
                        parseRequiredId(
                                request.getParameter("categoryId")
                        )
                );
                break;

            default:
                status = "invalid-action";
                break;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-category?status="
                + URLEncoder.encode(
                        status,
                        StandardCharsets.UTF_8
                )
        );
    }

    private String normalizeAction(String action) {
        return action == null
                ? ""
                : action.trim().toUpperCase();
    }

    private int parseRequiredId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : -1;
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Giá trị rỗng hoặc 0 nghĩa là Category cấp gốc.
     */
    private Integer parseNullableId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            int id = Integer.parseInt(value.trim());
            return id > 0 ? id : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}