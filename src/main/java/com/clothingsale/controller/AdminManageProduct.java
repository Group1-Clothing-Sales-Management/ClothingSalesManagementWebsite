/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.AdminManageProductService;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.PrintWriter;

/**
 *
 * @author Nhat Quy
 */
@WebServlet(name = "AdminManageProduct", urlPatterns = {"/AdminManageProduct"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class AdminManageProduct extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminManageProduct</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminManageProduct at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private final AdminManageProductService productService = new AdminManageProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. Gọi service lấy danh sách từ database
        List<Product> products = productService.getAllProducts();

        // 2. Gắn danh sách vào request attribute
        request.setAttribute("products", products);

        request.getRequestDispatcher("/view/admin/admin_product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Phân loại hành động bằng trường ẩn "action" gửi từ Form lên (mặc định trống là thêm mới)
        String action = request.getParameter("action");

        try {
            String productName = request.getParameter("productName");
            String slug = request.getParameter("slug");
            int brandId = Integer.parseInt(request.getParameter("brandId"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String shortDescription = request.getParameter("shortDescription");
            String longDescription = request.getParameter("longDescription");
            String status = request.getParameter("status");

            // Xử lý File Ảnh
            Part filePart = request.getPart("productImage");
            String savedFileName = null;

            // Kiểm tra xem người dùng có thực sự chọn/tải ảnh mới lên không
            if (filePart != null && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
                String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                savedFileName = System.currentTimeMillis() + "_" + originalFileName;

                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "product";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                filePart.write(uploadPath + File.separator + savedFileName);
            }

            // Đóng gói dữ liệu đối tượng
            Product product = new Product();
            product.setProductName(productName);
            product.setSlug(slug);
            product.setBrandId(brandId);
            product.setCategoryId(categoryId);
            product.setShortDescription(shortDescription);
            product.setLongDescription(longDescription);
            product.setStatus(status);

            if ("UPDATE".equals(action)) {
                // Trường hợp Cập Nhật sản phẩm
                int id = Integer.parseInt(request.getParameter("productId"));
                product.setId(id);

                boolean isSuccess = productService.updateProduct(product, savedFileName);
                if (isSuccess) {
                    System.out.println("✅ Cập nhật sản phẩm ID #" + id + " thành công!");
                } else {
                    System.err.println("❌ Cập nhật sản phẩm thất bại tại Database.");
                }
            } else {
                // Trường hợp Thêm Mới mặc định (giữ nguyên code cũ của bạn)
                boolean isSuccess = productService.addProduct(product, savedFileName);
                if (isSuccess) {
                    System.out.println("✅ Thêm sản phẩm mới thành công!");
                } else {
                    System.err.println("❌ Thêm sản phẩm thất bại tại tầng Database.");
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Lỗi xử lý Form Product:");
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/AdminManageProduct");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
