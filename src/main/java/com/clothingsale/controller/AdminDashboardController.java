package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.DashboardStats;
import com.clothingsale.service.AdminDashboardService;
import com.clothingsale.service.AdminManageProductService;
import com.clothingsale.service.StaffProductService;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
        name = "AdminDashboardController",
        urlPatterns = {"/admin/dashboard", "/dashboard"}
)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminDashboardController extends HttpServlet {

    private final AdminManageProductService adminProductService = new AdminManageProductService();
    private final StaffProductService staffProductService = new StaffProductService();
    private final AdminDashboardService adminDashboardService = new AdminDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy dữ liệu số liệu thống kê truyền sang JSP
        DashboardStats stats = adminDashboardService.getDashboardOverview();
        request.setAttribute("dashboardData", stats);

        // 2. Lấy dữ liệu danh sách sản phẩm/danh mục để hiển thị ở các tab quản lý
        try {
            List<Product> listP = adminProductService.getAllProducts();
            List<Brand> listB = adminProductService.getAllBrands();
            List<Category> listC = adminProductService.getAllCategories();

            request.setAttribute("listP", listP);
            request.setAttribute("listB", listB);
            request.setAttribute("listC", listC);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/view/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String roleName = (String) session.getAttribute("roleName");
        String username = (String) session.getAttribute("username");
        String action = request.getParameter("action");

        try {
            if ("UPDATE".equals(action)) {
                if ("STAFF".equalsIgnoreCase(roleName) || "ADMIN".equalsIgnoreCase(roleName)) {
                    String sku = request.getParameter("sku");
                    int variantId = Integer.parseInt(request.getParameter("variantId"));
                    String productName = request.getParameter("productName");

                    // Sử dụng luồng truyền tham số chuẩn xác từ file cũ
                    staffProductService.updateProductDetails(sku, variantId, productName, roleName, username, action);
                }
            } else if ("DELETE".equals(action) && "ADMIN".equalsIgnoreCase(roleName)) {
                int id = Integer.parseInt(request.getParameter("productId"));
                adminProductService.deleteProductSmartly(id);
            } else if ("INSERT".equals(action) && "ADMIN".equalsIgnoreCase(roleName)) {
                Product p = new Product();
                p.setProductName(request.getParameter("productName"));
                p.setSlug(request.getParameter("slug"));
                p.setStatus(request.getParameter("status"));
                adminProductService.addProduct(p, null);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        String tabParam = request.getParameter("variantId") != null || "products".equals(request.getParameter("tab")) ? "?tab=products" : "";
        response.sendRedirect(request.getContextPath() + "/admin/dashboard" + tabParam);
    }
}
