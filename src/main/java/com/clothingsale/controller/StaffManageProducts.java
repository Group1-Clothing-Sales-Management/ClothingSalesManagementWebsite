/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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

/**
 * @author Admin
 */
@WebServlet(name = "StaffManageProducts", urlPatterns = { "/StaffManageProducts" })
public class StaffManageProducts extends HttpServlet {

    private StaffProductService productService = new StaffProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // BR1: Phân quyền tài khoản
        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String action = request.getParameter("action");
        String sku = request.getParameter("sku");

        try {
            // Lấy danh sách sản phẩm (Dùng chung cho cả 3 trường hợp)
            List<StaffProductModel> list = productService.getAllProducts();

            // Xử lý View
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
            // Xử lý Edit
            else if ("edit".equals(action) && sku != null) {
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.setAttribute("staffUser", currentStaff);
                        request.getRequestDispatcher("StaffEditProduct.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Mặc định: Hiển thị danh sách
            request.setAttribute("productList", list);
            request.getRequestDispatcher("/StaffManageProducts.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "E1: Lỗi hệ thống khi tải dữ liệu.");
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

        // Đón nhận dữ liệu
        String sku = request.getParameter("sku");
        String newName = request.getParameter("productName");
        String salePriceStr = request.getParameter("salePrice");
        String stockStr = request.getParameter("stockQuantity");

        // Gọi Service (BR2, BR3)
        String result = productService.updateProductDetails(sku, newName, salePriceStr, stockStr, currentStaff);

        if (result.equals("SUCCESS")) {
            request.setAttribute("successMessage", "Cập nhật thông tin sản phẩm và lưu vết lịch sử (BR3) thành công!");
        } else {
            request.setAttribute("errorMessage", result);
        }

        try {
            List<StaffProductModel> list = productService.getAllProducts();
            request.setAttribute("productList", list);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "E1: Lỗi hệ thống nạp lại dữ liệu.");
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
