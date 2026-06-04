package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.service.AdminManageProductService;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "AdminManageProduct", urlPatterns = {"/AdminManageProduct"})
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

        request.setAttribute("products", products);
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);

        // Forward chính xác về folder view admin của bạn
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

        response.sendRedirect(request.getContextPath() + "/AdminManageProduct");
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
