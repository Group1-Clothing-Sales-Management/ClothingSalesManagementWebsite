package com.clothingsale.controller;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Product;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.service.AdminManageProductService;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(
        name = "AdminManageProduct",
        urlPatterns = {"/AdminManageProduct", "/admin/manage-product", "/admin/products"}
)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminProductController extends HttpServlet {

    private final AdminManageProductService productService = new AdminManageProductService();
    private final AdminManageProductDAO productDAO = new AdminManageProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "view":
                showProductDetails(request, response);
                break;
            case "edit":
                // Đọc thông tin sản phẩm cần sửa để hiển thị lên form gộp nếu cần
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Product product = productDAO.getProductById(id);
                    request.setAttribute("productToEdit", product);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
                listProducts(request, response);
                break;
            case "list":
            default:
                listProducts(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Đảm bảo đồng bộ hóa bảng mã hóa ký tự tiếng Việt
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // GIẢI PHÁP 1: Lấy hành động 'action' từ Query String (URL) trước để tránh lỗi Multipart nuốt tham số
        String action = request.getParameter("action");

        // GIẢI PHÁP 2: Nếu lấy từ URL vẫn null, tiến hành bóc tách thủ công từ Part text của Form dữ liệu
        if (action == null && request.getContentType() != null && request.getContentType().startsWith("multipart/form-data")) {
            try {
                Part actionPart = request.getPart("action");
                if (actionPart != null) {
                    try (java.util.Scanner scanner = new java.util.Scanner(actionPart.getInputStream(), "UTF-8")) {
                        if (scanner.hasNext()) {
                            action = scanner.next().trim();
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("⚠️ Lỗi trích xuất hành động từ Multipart Form: " + e.getMessage());
            }
        }

        // Biến hỗ trợ thiết lập trạng thái phản hồi về giao diện (Success/Error)
        String statusRedirect = "success";

        try {
            if ("UPDATE".equals(action)) {
                // Kiểm tra tham số ID sản phẩm bắt buộc
                String idRaw = request.getParameter("productId");
                if (idRaw == null || idRaw.trim().isEmpty()) {
                    // Fallback bóc tách từ part nếu bị multipart làm ẩn mất parameter
                    Part idPart = request.getPart("productId");
                    if (idPart != null) {
                        try (java.util.Scanner scanner = new java.util.Scanner(idPart.getInputStream(), "UTF-8")) {
                            if (scanner.hasNext()) {
                                idRaw = scanner.next().trim();
                            }
                        }
                    }
                }

                if (idRaw != null && !idRaw.trim().isEmpty()) {
                    int id = Integer.parseInt(idRaw.trim());
                    Product product = extractProductFromRequest(request);
                    product.setId(id);

                    // Xử lý tệp tin hình ảnh tải lên
                    Part filePart = request.getPart("productImage");
                    String savedFileName = handleImageUpload(filePart);

                    boolean isUpdated = productService.updateProduct(product, savedFileName);
                    if (!isUpdated) {
                        statusRedirect = "error";
                    }
                } else {
                    statusRedirect = "error";
                }

            } else if ("DELETE".equals(action)) {
                // Đồng bộ kiểm tra cả 'productId' (từ form) lẫn 'id' (từ thẻ <a> cũ nếu có)
                String idRaw = request.getParameter("productId");
                if (idRaw == null) {
                    idRaw = request.getParameter("id");
                }

                if (idRaw != null && !idRaw.trim().isEmpty()) {
                    int id = Integer.parseInt(idRaw.trim());
                    boolean isDeleted = productService.deleteProductSmartly(id);
                    if (!isDeleted) {
                        statusRedirect = "error";
                    }
                } else {
                    statusRedirect = "error";
                }

            } else if ("ADD".equals(action)) {
                // Thực hiện tính năng THÊM MỚI (ADD) dựa trên logic gốc của bạn
                Product product = extractProductFromRequest(request);
                Part filePart = request.getPart("productImage");
                String savedFileName = handleImageUpload(filePart);

                boolean isAdded = productService.addProduct(product, savedFileName);
                if (!isAdded) {
                    statusRedirect = "error";
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi nghiêm trọng tại AdminManageProduct.doPost: " + e.getMessage());
            e.printStackTrace();
            statusRedirect = "error";
        }

        // Chuyển hướng kèm theo tham số trạng thái để trang JSP có thể hiển thị Alert thông báo rõ ràng
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=" + statusRedirect);
    }

    private String handleImageUpload(Part filePart) throws IOException {
        if (filePart != null && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String savedFileName = System.currentTimeMillis() + "_" + originalFileName;

            String baseRealPath = getServletContext().getRealPath("");
            String uploadPath;
            if (baseRealPath == null) {
                uploadPath = System.getProperty("user.dir") + File.separator + "uploads" + File.separator + "product";
            } else {
                uploadPath = baseRealPath + File.separator + "uploads" + File.separator + "product";
            }

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            filePart.write(uploadPath + File.separator + savedFileName);
            return savedFileName;
        }
        return null;
    }

    private Product extractProductFromRequest(HttpServletRequest request) {
        Product product = new Product();
        product.setProductName(request.getParameter("productName"));
        product.setSlug(request.getParameter("slug"));
        product.setBrandId(Integer.parseInt(request.getParameter("brandId")));
        product.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
        product.setShortDescription(request.getParameter("shortDescription"));
        product.setLongDescription(request.getParameter("longDescription"));
        product.setStatus(request.getParameter("status"));
        return product;
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productService.getAllProducts();
        List<Category> categories = productDAO.getAllCategories();
        List<Brand> brands = productDAO.getAllBrands();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);

        request.getRequestDispatcher("/view/admin/admin_product.jsp").forward(request, response);
    }

    private void showProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            Product product = productDAO.getProductById(productId);

            if (product != null) {
                List<ProductVariant> variants = productDAO.getVariantsByProductId(productId);
                request.setAttribute("product", product);
                request.setAttribute("variants", variants);
                request.getRequestDispatcher("/view/admin/product_detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=ProductNotFound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=InvalidId");
        }
    }
}
