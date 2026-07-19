package com.clothingsale.controller;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.service.AdminManageProductService;
import com.clothingsale.util.ProductImageStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.ArrayList;

@WebServlet(name = "AdminManageProduct", urlPatterns = {"/AdminManageProduct", "/admin/manage-product", "/admin/products"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class AdminProductController extends HttpServlet {

    private final AdminManageProductService productService = new AdminManageProductService();
    private final AdminManageProductDAO productDAO = new AdminManageProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action.toLowerCase(Locale.ROOT)) {
            case "view":
                showProductDetails(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = getMultipartParameter(request, "action");
        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
            return;
        }

        try {
            switch (action.toUpperCase(Locale.ROOT)) {
                case "UPDATE_PRODUCT":
                    handleUpdateProduct(request, response);
                    break;
                case "UPDATE_VARIANT_STATUS":
                    handleUpdateVariantStatus(request, response);
                    break;
                case "ADD_VARIANT":
                case "ADD_VARIANTS":
                    handleAddVariants(request, response);
                    break;
                case "ADD":
                    handleAddProduct(request, response);
                    break;
                case "DELETE":
                    handleDeleteProduct(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-action");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=error");
        }
    }

    private void handleUpdateProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int productId;
        try {
            productId = Integer.parseInt(getMultipartParameter(request, "productId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
            return;
        }

        Product oldProduct = productService.getProductById(productId);
        if (oldProduct == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=product-not-found");
            return;
        }

        Product product;
        try {
            product = extractProductFromRequest(request);
        } catch (NumberFormatException e) {
            redirectToEdit(response, productId, "invalid-request");
            return;
        }

        product.setId(productId);
        String validationError = productService.validateProduct(product);
        if (validationError != null) {
            redirectToEdit(response, productId, validationError);
            return;
        }

        product.setSlug(productService.generateSlug(product.getProductName(), productId));
        String newImageName = null;

        try {
            Part imagePart = request.getPart("productImage");
            if (hasUploadedFile(imagePart)) {
                newImageName = saveProductImage(imagePart);
            }
        } catch (IllegalArgumentException e) {
            redirectToEdit(response, productId, "invalid-image");
            return;
        } catch (IOException e) {
            redirectToEdit(response, productId, "image-upload-failed");
            return;
        }

        boolean updated = productService.updateProduct(product, newImageName);
        if (!updated) {
            deleteProductImage(newImageName);
            redirectToEdit(response, productId, "update-failed");
            return;
        }

        if (newImageName != null && oldProduct.getMainImageUrl() != null
                && !newImageName.equals(oldProduct.getMainImageUrl())) {
            deleteProductImage(oldProduct.getMainImageUrl());
        }

        redirectToEdit(response, productId, "product-updated");
    }

    private void handleUpdateVariantStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int productId;
        int variantId;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
            variantId = Integer.parseInt(request.getParameter("variantId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
            return;
        }

        String status = request.getParameter("status");
        boolean updated = productService.updateVariantStatus(productId, variantId, status);
        String result = updated ? "variant-updated" : "variant-update-failed";

        response.sendRedirect(request.getContextPath()
                + "/admin/manage-product?action=view&id=" + productId + "&status=" + result);
    }

    private void handleAddVariants(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        int productId;

        try {
            productId = Integer.parseInt(
                    getMultipartParameter(request, "productId")
            );
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
            return;
        }

        Product product = productService.getProductById(productId);

        if (product == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=product-not-found"
            );
            return;
        }

        List<ProductVariant> variants;

        try {
            variants = readVariantsFromRequest(
                    request,
                    productId,
                    product.getProductName()
            );
        } catch (IllegalArgumentException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?action=view&id="
                    + productId
                    + "&status=variant-invalid"
            );
            return;
        }

        if (variants.isEmpty()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?action=view&id="
                    + productId
                    + "&status=variant-required"
            );
            return;
        }

        boolean added = productService.addVariants(productId, variants);

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-product?action=view&id="
                + productId
                + "&status="
                + (added ? "variants-added" : "variant-duplicate")
        );
    }

    private void handleAddProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Product product;
        try {
            product = extractProductFromRequest(request);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
            return;
        }

        String validationError = productService.validateProduct(product);
        if (validationError != null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=" + validationError);
            return;
        }

        String cleanSlug = product.getProductName().toLowerCase(Locale.ROOT)
                .replace('đ', 'd').replace('Đ', 'D')
                .replaceAll("[^a-z0-9\\s-]", "")
                .trim().replaceAll("\\s+", "-");
        product.setSlug((cleanSlug.isEmpty() ? "product" : cleanSlug) + "-" + System.currentTimeMillis());

        String savedImageName = null;
        try {
            Part imagePart = request.getPart("productImage");
            if (hasUploadedFile(imagePart)) {
                savedImageName = saveProductImage(imagePart);
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-image");
            return;
        } catch (IOException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=image-upload-failed");
            return;
        }

        List<ProductVariant> variants;

        try {
            variants = readVariantsFromRequest(
                    request,
                    0,
                    product.getProductName()
            );
        } catch (IllegalArgumentException e) {
            deleteProductImage(savedImageName);

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=variant-invalid"
            );
            return;
        }

        if (variants.isEmpty()) {
            deleteProductImage(savedImageName);
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=variant-required");
            return;
        }

        boolean added = productService.createProductWithVariants(product, savedImageName, variants);
        if (!added) {
            deleteProductImage(savedImageName);
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=" + (added ? "success" : "error"));
    }

    private void handleDeleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idRaw = request.getParameter("productId");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            idRaw = request.getParameter("id");
        }

        try {
            int productId = Integer.parseInt(idRaw);
            boolean deleted = productService.deleteProductSmartly(productId);
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=" + (deleted ? "deleted" : "error"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
        }
    }

    private boolean hasUploadedFile(Part part) {
        return part != null && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty() && part.getSize() > 0;
    }

    private String saveProductImage(Part filePart) throws IOException {
        String originalName = Paths.get(
                filePart.getSubmittedFileName()
        ).getFileName().toString();

        String extension = getFileExtension(originalName)
                .toLowerCase(Locale.ROOT);

        String contentType = filePart.getContentType();

        boolean validExtension
                = extension.equals("jpg")
                || extension.equals("jpeg")
                || extension.equals("png")
                || extension.equals("webp");

        boolean validContentType
                = contentType != null
                && (contentType.equals("image/jpeg")
                || contentType.equals("image/png")
                || contentType.equals("image/webp"));

        if (!validExtension || !validContentType) {
            throw new IllegalArgumentException(
                    "Unsupported image format"
            );
        }

        String savedName
                = System.currentTimeMillis()
                + "_"
                + UUID.randomUUID()
                        .toString()
                        .substring(0, 8)
                + "."
                + extension;

        Path targetFile = ProductImageStorage.resolveFile(savedName);

        try (InputStream inputStream = filePart.getInputStream()) {
            Files.copy(
                    inputStream,
                    targetFile,
                    StandardCopyOption.REPLACE_EXISTING
            );
        }

        return savedName;
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex >= 0 && dotIndex < fileName.length() - 1 ? fileName.substring(dotIndex + 1) : "";
    }

    private void deleteProductImage(String imageName) {
        if (imageName == null || imageName.trim().isEmpty()) {
            return;
        }

        try {
            Path imageFile = ProductImageStorage.resolveFile(imageName);
            Files.deleteIfExists(imageFile);
        } catch (Exception e) {
            System.err.println(
                    "Could not delete product image: "
                    + e.getMessage()
            );
        }
    }

    private Product extractProductFromRequest(HttpServletRequest request) {
        Product product = new Product();
        product.setProductName(getMultipartParameter(request, "productName"));

        String brandId = getMultipartParameter(request, "brandId");
        product.setBrandId(brandId == null || brandId.trim().isEmpty() ? 0 : Integer.parseInt(brandId.trim()));

        String categoryId = getMultipartParameter(request, "categoryId");
        product.setCategoryId(categoryId == null || categoryId.trim().isEmpty() ? 0 : Integer.parseInt(categoryId.trim()));

        product.setShortDescription(getMultipartParameter(request, "shortDescription"));
        product.setLongDescription(getMultipartParameter(request, "longDescription"));
        product.setStatus(getMultipartParameter(request, "status"));
        return product;
    }

    private String getMultipartParameter(HttpServletRequest request, String parameterName) {
        String value = request.getParameter(parameterName);
        if (value != null) {
            return value.trim();
        }

        try {
            Part part = request.getPart(parameterName);
            if (part == null) {
                return null;
            }
            try (java.util.Scanner scanner = new java.util.Scanner(part.getInputStream(), "UTF-8")) {
                return scanner.hasNextLine() ? scanner.nextLine().trim() : null;
            }
        } catch (Exception e) {
            return null;
        }
    }

    private void redirectToEdit(HttpServletResponse response, int productId, String status) throws IOException {
        response.sendRedirect(getServletContext().getContextPath()
                + "/admin/manage-product?action=edit&id=" + productId + "&status=" + status);
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("products", productService.getAllProducts());
        request.setAttribute("categories", productService.getAllCategories());
        request.setAttribute("brands", productService.getAllBrands());
        request.getRequestDispatcher("/view/admin/admin_product.jsp").forward(request, response);
    }

    private void showProductDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            Product product = productService.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=product-not-found");
                return;
            }

            request.setAttribute("product", product);
            request.setAttribute("variants", productService.getVariantsByProductId(productId));
            request.getRequestDispatcher("/view/admin/product_detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            Product product = productService.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=product-not-found");
                return;
            }

            request.setAttribute("product", product);
            request.setAttribute("categories", productService.getAllCategories());
            request.setAttribute("brands", productService.getAllBrands());
            request.getRequestDispatcher("/view/admin/admin_edit_product.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?status=invalid-request");
        }
    }

    private List<ProductVariant> readVariantsFromRequest(
            HttpServletRequest request,
            int productId,
            String productName) {

        List<ProductVariant> variants = new ArrayList<>();

        for (int index = 0;; index++) {
            String size = getMultipartParameter(
                    request,
                    "variants[" + index + "].size"
            );

            String color = getMultipartParameter(
                    request,
                    "variants[" + index + "].color"
            );

            if (size == null && color == null) {
                break;
            }

            if (size == null
                    || size.trim().isEmpty()
                    || color == null
                    || color.trim().isEmpty()) {

                throw new IllegalArgumentException(
                        "Size and color are required"
                );
            }

            size = size.trim();
            color = color.trim();

            ProductVariant variant = new ProductVariant();
            variant.setProductId(productId);
            variant.setSize(size);
            variant.setColor(color);

            variant.setSku(
                    productService.generateVariantSku(
                            productName,
                            size,
                            color
                    )
            );

            // Variant mới luôn chưa sẵn sàng bán.
            variant.setStatus("INACTIVE");
            variant.setCostPrice(java.math.BigDecimal.ZERO);
            variant.setSalePrice(java.math.BigDecimal.ZERO);
            variant.setStockQuantity(0);
            variant.setAttributeDetails(color + "|" + size);

            variants.add(variant);
        }

        return variants;
    }
}
