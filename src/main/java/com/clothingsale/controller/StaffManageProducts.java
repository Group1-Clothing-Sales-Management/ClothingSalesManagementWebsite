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

@WebServlet(name = "StaffManageProducts", urlPatterns = { "/StaffManageProducts", "/staff/products" })
public class StaffManageProducts extends HttpServlet {

    private StaffProductService productService = new StaffProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String action = request.getParameter("action");
        String sku = request.getParameter("sku");

        try {
            List<StaffProductModel> list = productService.getAllProducts();

            if ("view".equals(action) && sku != null) {
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.getRequestDispatcher("/StaffViewProduct.jsp").forward(request, response);
                        return;
                    }
                }
            } else if ("edit".equals(action) && sku != null) {
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.getRequestDispatcher("/StaffEditProduct.jsp").forward(request, response);
                        return;
                    }
                }
            }

            request.setAttribute("productList", list);
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "E1: System error while loading data.");
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String sku = request.getParameter("sku");
        String variantIdStr = request.getParameter("variantId");
        String newName = request.getParameter("productName");
        String color = request.getParameter("color");
        String size = request.getParameter("size");

        int variantId = 0;
        try {
            variantId = Integer.parseInt(variantIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid variant ID.");
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);
            return;
        }

        String result = productService.updateProductDetails(sku, variantId, newName, color, size, currentStaff);

        if (result.equals("SUCCESS")) {
            request.setAttribute("successMessage", "Product updated and inventory log saved successfully.");
        } else {
            request.setAttribute("errorMessage", result);
        }

        try {
            request.setAttribute("productList", productService.getAllProducts());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "E1: System error while reloading data.");
        }

        request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Staff Manage Product Controller";
    }

    private String getCurrentStaff(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String username = (String) session.getAttribute("authUsername");
            String fullName = (String) session.getAttribute("authFullName");
            if (username != null && !username.trim().isEmpty())
                return username;
            if (fullName != null && !fullName.trim().isEmpty())
                return fullName;
        }
        return "staff01";
    }
}