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
        request.setAttribute("categories", productDAO.getAllCategories());
        request.setAttribute("brands", productDAO.getAllBrands());
        switch (action) {
            case "view":
                showProductDetails(request, response);
                break;
            case "edit":
                showEditForm(request, response);
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

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

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

        String statusRedirect = "success";

        try {
            if ("UPDATE".equalsIgnoreCase(action)) {
                // SỬA: Lấy productId bằng request.getParameter trước, nếu trống mới dùng Multipart để tăng độ an toàn
                String idRaw = request.getParameter("productId");
                if (idRaw == null || idRaw.trim().isEmpty()) {
                    idRaw = getMultipartParameter(request, "productId");
                }
                if (idRaw == null || idRaw.trim().isEmpty()) {
                    idRaw = request.getParameter("id");
                }

                if (idRaw != null && !idRaw.trim().isEmpty()) {
                    int id = Integer.parseInt(idRaw.trim());
                    Product product = extractProductFromRequest(request);
                    product.setId(id);

                    // SỬA: Tự động sinh Slug hợp lệ theo tên mới sửa của sản phẩm để tránh trùng Unique Key trong DB
                    if (product.getProductName() != null && !product.getProductName().trim().isEmpty()) {
                        String cleanSlug = product.getProductName().toLowerCase()
                                .replaceAll("[^a-z0-9\\s]", "")
                                .replaceAll("\\s+", "-");
                        product.setSlug(cleanSlug + "-" + id); // Đuôi ID đảm bảo không bao giờ trùng lặp
                    } else {
                        product.setSlug("updated-product-" + id);
                    }

                    Part filePart = request.getPart("productImage");
                    String savedFileName = handleImageUpload(filePart);

                    // Thực hiện gọi sang Service để cập nhật thông tin chính vào DB
                    boolean isUpdated = productService.updateProduct(product, savedFileName);
                    if (!isUpdated) {
                        statusRedirect = "error";
                    }
                } else {
                    System.err.println("❌ Không tìm thấy productId hợp lệ từ Request khi Update!");
                    statusRedirect = "error";
                }
            } else if ("DELETE".equals(action)) {

                String idRaw = request.getParameter("productId");
                if (idRaw == null) {
                    idRaw = request.getParameter("id");
                }

                if (idRaw != null && !idRaw.trim().isEmpty()) {
                    int id = Integer.parseInt(idRaw.trim());
                    boolean isDeleted = productDAO.softDeleteProduct(id);
                    if (!isDeleted) {
                        statusRedirect = "error";
                    }
                } else {
                    statusRedirect = "error";
                }

            } else if ("ADD".equals(action)) {
                Product product = extractProductFromRequest(request);

                // TỰ ĐỘNG SINH SLUG THEO THỜI GIAN ĐỂ TRÁNH LỖI TRÙNG KHÓA DUY NHẤT (UNIQUE KEY)
                if (product.getProductName() != null) {
                    String cleanSlug = product.getProductName().toLowerCase()
                            .replaceAll("[^a-z0-9\\s]", "")
                            .replaceAll("\\s+", "-");
                    product.setSlug(cleanSlug + "-" + System.currentTimeMillis());
                }

                Part filePart = request.getPart("productImage");
                String savedFileName = handleImageUpload(filePart);

                java.util.List<com.clothingsale.model.ProductVariant> variantsList = new java.util.ArrayList<>();

                int index = 0;
                while (true) {
                    // SỬA: Dùng getMultipartParameter thay vì request.getParameter
                    String skuParam = getMultipartParameter(request, "variants[" + index + "].skuCode");
                    if (skuParam == null) {
                        break;
                    }

                    String colorParam = getMultipartParameter(request, "variants[" + index + "].color");
                    String sizeParam = getMultipartParameter(request, "variants[" + index + "].size");
                    String statusParam = getMultipartParameter(request, "variants[" + index + "].status");

                    if (!skuParam.trim().isEmpty()) {
                        com.clothingsale.model.ProductVariant variant = new com.clothingsale.model.ProductVariant();
                        variant.setSku(skuParam.trim().toUpperCase());
                        variant.setStatus(statusParam != null ? statusParam : "ACTIVE");

                        variant.setSalePrice(java.math.BigDecimal.ZERO);
                        variant.setCostPrice(java.math.BigDecimal.ZERO);
                        variant.setStockQuantity(0);

                        // Đảm bảo không bị NullPointerException nếu màu sắc/kích cỡ để trống
                        String colorStr = (colorParam != null) ? colorParam.trim() : "Standard";
                        String sizeStr = (sizeParam != null) ? sizeParam.trim() : "FreeSize";
                        variant.setAttributeDetails(colorStr + "|" + sizeStr);

                        variantsList.add(variant);
                    }
                    index++;
                }

                // Kiểm tra nghiệp vụ: Nếu Admin không tích chọn biến thể nào, thông báo lỗi luôn
                if (variantsList.isEmpty()) {
                    System.err.println("⚠️ Cảnh báo: Không có biến thể nào được tạo ra từ giao diện!");
                    statusRedirect = "error";
                } else {
                    boolean isAdded = productDAO.insertProductWithMatrixVariants(product, savedFileName, variantsList);
                    if (!isAdded) {
                        statusRedirect = "error";
                    }
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

            // Thêm khối try-catch bọc riêng việc ghi file để nếu lỗi hình ảnh, dữ liệu text (sản phẩm) vẫn được cập nhật vào cơ sở dữ liệu
            try {
                filePart.write(uploadPath + File.separator + savedFileName);
                return savedFileName;
            } catch (Exception e) {
                System.err.println("⚠️ Không thể ghi file lên ổ cứng (Có thể do quyền thư mục): " + e.getMessage());
                // Trả về một tên file mặc định hoặc giữ nguyên để không bị crash cả luồng xử lý
                return null;
            }
        }
        return null;
    }

    private Product extractProductFromRequest(HttpServletRequest request) {
        Product product = new Product();

        product.setProductName(getMultipartParameter(request, "productName"));
        product.setSlug(getMultipartParameter(request, "slug"));

        String brandIdRaw = getMultipartParameter(request, "brandId");
        product.setBrandId(brandIdRaw != null && !brandIdRaw.trim().isEmpty() ? Integer.parseInt(brandIdRaw.trim()) : 0);

        String categoryIdRaw = getMultipartParameter(request, "categoryId");
        product.setCategoryId(categoryIdRaw != null && !categoryIdRaw.trim().isEmpty() ? Integer.parseInt(categoryIdRaw.trim()) : 0);

        product.setShortDescription(getMultipartParameter(request, "shortDescription"));
        product.setLongDescription(getMultipartParameter(request, "longDescription"));
        product.setStatus(getMultipartParameter(request, "status"));

        return product;
    }

    private String getMultipartParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            try {
                Part part = request.getPart(paramName);
                if (part != null) {
                    try (java.util.Scanner scanner = new java.util.Scanner(part.getInputStream(), "UTF-8")) {
                        if (scanner.hasNextLine()) {
                            value = scanner.nextLine().trim();
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("⚠️ Lỗi trích xuất Part " + paramName + ": " + e.getMessage());
            }
        }
        return value;
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

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));

            // Gọi DAO lấy thông tin sản phẩm và các thuộc tính liên quan (Category, Brand)
            AdminManageProductDAO productDAO = new AdminManageProductDAO();
            Product product = productDAO.getProductById(productId);

            // Đẩy dữ liệu lên bộ nhớ Request để trang JSP sửa đổi có thể hiển thị dữ liệu cũ
            request.setAttribute("product", product);
            request.setAttribute("categories", productDAO.getAllCategories());
            request.setAttribute("brands", productDAO.getAllBrands());

            // Chuyển hướng (Forward) sang trang JSP đảm nhận việc sửa đổi sản phẩm
            request.getRequestDispatcher("/view/admin/admin_edit_product.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/AdminManageProduct?action=LIST");
        }
    }
}
