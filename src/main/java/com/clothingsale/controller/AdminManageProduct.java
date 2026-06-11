package com.clothingsale.controller;

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
import java.util.ArrayList;

@WebServlet(
        name = "AdminManageProduct",
        urlPatterns = {"/AdminManageProduct", "/admin/manage-product", "/admin/products"}
)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminManageProduct extends HttpServlet {

    private final AdminManageProductService productService = new AdminManageProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> products = productService.getAllProducts();
        List<Brand> brands = productService.getAllBrands();
        List<Category> categories = productService.getAllCategories();

        if (products != null) {
            for (Product p : products) {
                try {
                    List<com.clothingsale.model.ProductVariant> varList = productService.getVariantsByProductId(p.getId());
                    p.setVariants(varList);
                } catch (Exception ex) {
                    System.err.println("Lỗi nạp Variant cho sản phẩm ID " + p.getId() + ": " + ex.getMessage());
                    p.setVariants(new ArrayList<>()); // Nếu lỗi thì gán danh sách rỗng để JSP không bị lỗi Null pointer
                }
            }
        }

        request.setAttribute("products", products);
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);

        // Forward về folder view admin để hiển thị giao diện Accordion lồng nhau
        request.getRequestDispatcher("/view/admin/admin_product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            if ("UPDATE".equals(action)) {
                int id = Integer.parseInt(request.getParameter("productId"));
                Product product = extractProductFromRequest(request);
                product.setId(id);

                Part filePart = request.getPart("productImage");
                String savedFileName = handleImageUpload(filePart);

                productService.updateProduct(product, savedFileName);

            } else if ("DELETE".equals(action)) {
                int id = Integer.parseInt(request.getParameter("productId"));
                productService.deleteProductSmartly(id);

            } else {
                Product product = extractProductFromRequest(request);
                Part filePart = request.getPart("productImage");
                String savedFileName = handleImageUpload(filePart);

                productService.addProduct(product, savedFileName);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-product");
    }

    private String handleImageUpload(Part filePart) throws IOException {
        if (filePart != null && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String savedFileName = System.currentTimeMillis() + "_" + originalFileName;
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "product";

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
}
