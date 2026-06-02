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
        // Thiết lập chuẩn mã hóa UTF-8 để không bị lỗi font chữ tiếng Việt khi lưu vào SQL Server
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // 1. Thu thập dữ liệu text thông thường từ Form gửi lên
            String productName = request.getParameter("productName");
            String slug = request.getParameter("slug");
            int brandId = Integer.parseInt(request.getParameter("brandId"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String shortDescription = request.getParameter("shortDescription");
            String longDescription = request.getParameter("longDescription");
            String status = request.getParameter("status");

            // 2. Xử lý lưu File Ảnh tải lên thư mục vật lý vật chủ trên Server
            Part filePart = request.getPart("productImage"); // Lấy thẻ chứa file ảnh
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // Đặt tên file ảnh duy nhất để không bị đè file nếu trùng tên (Dùng tiền tố thời gian hệ thống)
            String savedFileName = System.currentTimeMillis() + "_" + originalFileName;

            // Xác định đường dẫn tuyệt đối dẫn đến thư mục chứa ảnh uploads/product/ bên trong Server chạy tạm thời
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "product";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs(); // Tự động tạo cây thư mục nếu Server chưa có sẵn
            }

            // Lưu file ảnh vật lý xuống đĩa cứng Server
            String fileFullPath = uploadPath + File.separator + savedFileName;
            filePart.write(fileFullPath);

            // 3. Đóng gói dữ liệu vào đối tượng Model Product
            Product newProduct = new Product();
            newProduct.setProductName(productName);
            newProduct.setSlug(slug);
            newProduct.setBrandId(brandId);
            newProduct.setCategoryId(categoryId);
            newProduct.setShortDescription(shortDescription);
            newProduct.setLongDescription(longDescription);
            newProduct.setStatus(status);

            // 4. Gọi tầng Service điều phối nạp dữ liệu vào Database
            boolean isSuccess = productService.addProduct(newProduct, savedFileName);

            if (isSuccess) {
                System.out.println("✅ Thêm sản phẩm mới thành công!");
            } else {
                System.err.println("❌ Thêm sản phẩm thất bại tại tầng Database.");
            }

        } catch (Exception e) {
            System.err.println("❌ Lỗi nghiêm trọng trong quá trình xử lý Form nhận Product:");
            e.printStackTrace();
        }

        // 5. Điều hướng Redirect quay trở lại trang danh sách sạch để tránh lặp dữ liệu trùng khi người dùng nhấn F5
        response.sendRedirect(request.getContextPath() + "/AdminManageProduct");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
