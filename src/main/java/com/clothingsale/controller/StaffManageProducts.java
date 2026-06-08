package com.clothingsale.controller;

import com.clothingsale.model.StaffProductModel;
import com.clothingsale.service.StaffProductService;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffManageProducts", urlPatterns = { "/staff/products" })
public class StaffManageProducts extends HttpServlet {

    private StaffProductService productService = new StaffProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Resolve the current account role for the sidebar header.
        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String action = request.getParameter("action");
        String sku = request.getParameter("sku");

        try {
            // Load the product list once and reuse it for every view mode.
            List<StaffProductModel> list = productService.getAllProducts();

            // View mode.
            if ("view".equals(action) && sku != null) {
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.setAttribute("staffUser", currentStaff);
                        request.getRequestDispatcher("/StaffViewProduct.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Edit mode.
            else if ("edit".equals(action) && sku != null) {
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.setAttribute("staffUser", currentStaff);
                        request.getRequestDispatcher("/StaffEditProduct.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Default: show the list view.
            request.setAttribute("productList", list);
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "E1: System error while loading data.");
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        // Read form data from the update request.
        String sku = request.getParameter("sku");
        String newName = request.getParameter("productName");
        String salePriceStr = request.getParameter("salePrice");
        String stockStr = request.getParameter("stockQuantity");

        // Call the service layer for validation and persistence.
        String result = productService.updateProductDetails(sku, newName, salePriceStr, stockStr, currentStaff);

        if (result.equals("SUCCESS")) {
            request.setAttribute("successMessage", "Product information was updated and the inventory history log was saved (BR3).");
        } else {
            request.setAttribute("errorMessage", result);
        }

        try {
            List<StaffProductModel> list = productService.getAllProducts();
            request.setAttribute("productList", list);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "E1: System error while reloading data.");
        }

        request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Staff Manage Product Controller Custom Template NetBeans";
    }

    private String getCurrentStaff(HttpServletRequest request) {
        String currentStaff = "staff01";
        HttpSession session = request.getSession(false);
        if (session != null) {
            String sessionUsername = (String) session.getAttribute("authUsername");
            String sessionFullName = (String) session.getAttribute("authFullName");
            if (sessionUsername != null && !sessionUsername.trim().isEmpty()) {
                currentStaff = sessionUsername;
            } else if (sessionFullName != null && !sessionFullName.trim().isEmpty()) {
                currentStaff = sessionFullName;
            }
        }
        return currentStaff;
    }
}
