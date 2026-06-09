package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.StaffProductModel;
import com.clothingsale.service.AdminManageProductService;
import com.clothingsale.service.StaffProductService;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
        name = "AdminDashboard",
        urlPatterns = {"/admin/dashboard", "/dashboard"} // Mở rộng tiếp nhận cả 2 URL để quy hoạch chung
)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminDashboard extends HttpServlet {

    private final AdminManageProductService adminProductService = new AdminManageProductService();
    private final StaffProductService staffProductService = new StaffProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : "";

        // Tải các tài nguyên chung cho Form Dropdown (Thương hiệu & Danh mục)
        List<Brand> brands = adminProductService.getAllBrands();
        List<Category> categories = adminProductService.getAllCategories();
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);

        // PHÂN CHIA LOAD DỮ LIỆU ĐỔ VÀO 2 BẢNG KHÁC NHAU THEO QUYỀN (Mục 4)
        try {
            if ("ADMIN".equalsIgnoreCase(roleName)) {
                List<Product> products = adminProductService.getAllProducts();
                request.setAttribute("products", products);
            } else if ("STAFF".equalsIgnoreCase(roleName)) {
                List<StaffProductModel> productList = staffProductService.getAllProducts();
                request.setAttribute("productList", productList);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Chuyển tiếp về giao diện trang chủ tích hợp duy nhất
        request.getRequestDispatcher("/view/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : "";
        String username = (session != null) ? (String) session.getAttribute("authUsername") : "system";
        
        String action = request.getParameter("action");

        try {
            if ("UPDATE".equals(action)) {
                if ("ADMIN".equalsIgnoreCase(roleName)) {
                    // Nhánh xử lý Update của Admin
                    int id = Integer.parseInt(request.getParameter("productId"));
                    Product p = new Product();
                    p.setId(id);
                    p.setProductName(request.getParameter("productName"));
                    p.setSlug(request.getParameter("slug"));
                    p.setStatus(request.getParameter("status"));
                    // Do dùng chung form cơ bản, giữ nguyên các hàm phụ từ AdminManageProduct cũ
                    adminProductService.updateProduct(p, null);
                } else if ("STAFF".equalsIgnoreCase(roleName)) {
                    // Nhánh xử lý Update của Staff: chỉ được cập nhật Tên, cấu trúc thuộc tính
                    String sku = request.getParameter("sku");
                    int variantId = Integer.parseInt(request.getParameter("variantId"));
                    String productName = request.getParameter("productName");
                    String salePriceStr = request.getParameter("salePrice"); // Giá hiển thị, không đổi hoặc giữ nguyên theo cấu hình khoá

                    staffProductService.updateProductDetails(sku, variantId, productName, salePriceStr, username);
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

        // Đồng bộ chuyển hướng quay trở lại màn hình chính của Tab tương ứng
        String tabParam = request.getParameter("variantId") != null || "products".equals(request.getParameter("tab")) ? "?tab=products" : "";
        response.sendRedirect(request.getContextPath() + "/admin/dashboard" + tabParam);
    }
}