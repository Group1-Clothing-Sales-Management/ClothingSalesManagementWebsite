package com.clothingsale.controller;

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
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@WebServlet(
        name = "AdminManageProduct",
        urlPatterns = {
            "/AdminManageProduct",
            "/admin/manage-product",
            "/admin/products"
        }
)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminProductController extends HttpServlet {

    private static final int MAX_VARIANT_ROWS = 200;

    private final AdminManageProductService productService
            = new AdminManageProductService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action.trim().toLowerCase(Locale.ROOT)) {
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
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = getMultipartParameter(request, "action");

        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
            return;
        }

        try {
            switch (action.trim().toUpperCase(Locale.ROOT)) {
                case "UPDATE_PRODUCT":
                    handleUpdateProduct(request, response);
                    break;
                case "UPDATE_VARIANT":
                    handleUpdateVariant(request, response);
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
                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/manage-product?status=invalid-action"
                    );
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=error"
            );
        }
    }

    private void handleUpdateProduct(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

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

        Product oldProduct = productService.getProductById(productId);

        if (oldProduct == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=product-not-found"
            );
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

        String validationError
                = productService.validateProductForUpdate(
                        oldProduct,
                        product
                );

        if (validationError != null) {
            redirectToEdit(
                    response,
                    productId,
                    validationError
            );
            return;
        }

        product.setSlug(
                productService.generateSlug(
                        product.getProductName(),
                        productId
                )
        );

        String newImageName = null;

        try {
            Part imagePart = request.getPart("productImage");

            if (hasUploadedFile(imagePart)) {
                newImageName = saveProductImage(imagePart);
            }
        } catch (IllegalArgumentException e) {
            redirectToEdit(
                    response,
                    productId,
                    "invalid-image"
            );
            return;
        } catch (IOException e) {
            redirectToEdit(
                    response,
                    productId,
                    "image-upload-failed"
            );
            return;
        }

        boolean updated = productService.updateProduct(
                product,
                newImageName
        );

        if (!updated) {
            deleteProductImage(newImageName);
            redirectToEdit(
                    response,
                    productId,
                    "update-failed"
            );
            return;
        }

        if (newImageName != null
                && oldProduct.getMainImageUrl() != null
                && !newImageName.equals(
                        oldProduct.getMainImageUrl())) {

            deleteProductImage(
                    oldProduct.getMainImageUrl()
            );
        }

        redirectToEdit(
                response,
                productId,
                "product-updated"
        );
    }

    private void handleUpdateVariant(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int productId;
        int variantId;

        try {
            productId = Integer.parseInt(
                    getMultipartParameter(request, "productId")
            );

            variantId = Integer.parseInt(
                    getMultipartParameter(request, "variantId")
            );
        } catch (Exception e) {
            redirectToProductDetail(
                    response,
                    0,
                    "invalid-request"
            );
            return;
        }

        ProductVariant oldVariant = productService.getVariantById(
                productId,
                variantId
        );

        if (oldVariant == null) {
            redirectToProductDetail(
                    response,
                    productId,
                    "variant-not-found"
            );
            return;
        }

        String size = getMultipartParameter(request, "size");
        String color = getMultipartParameter(request, "color");
        String status = getMultipartParameter(request, "status");

        String updateError = productService.updateVariantInfo(
                productId,
                variantId,
                size,
                color,
                status
        );

        if (updateError != null) {
            redirectToProductDetail(
                    response,
                    productId,
                    updateError
            );
            return;
        }

        Part imagePart = request.getPart("variantImage");

        if (hasUploadedFile(imagePart)) {
            String newImageName;

            try {
                newImageName = saveVariantImage(
                        imagePart,
                        productId,
                        variantId,
                        size,
                        color
                );
            } catch (IllegalArgumentException e) {
                rollbackVariantInfo(
                        productId,
                        variantId,
                        oldVariant
                );

                redirectToProductDetail(
                        response,
                        productId,
                        "invalid-image"
                );
                return;
            } catch (IOException e) {
                rollbackVariantInfo(
                        productId,
                        variantId,
                        oldVariant
                );

                redirectToProductDetail(
                        response,
                        productId,
                        "image-upload-failed"
                );
                return;
            }

            String imageError = productService.saveVariantMainImage(
                    productId,
                    variantId,
                    newImageName
            );

            if (imageError != null) {
                rollbackVariantInfo(
                        productId,
                        variantId,
                        oldVariant
                );

                /*
             * Không xóa nếu tên mới giống ảnh cũ,
             * vì database cũ vẫn đang sử dụng file đó.
                 */
                if (oldVariant.getImageUrl() == null
                        || !newImageName.equals(
                                oldVariant.getImageUrl()
                        )) {

                    deleteProductImage(newImageName);
                }

                redirectToProductDetail(
                        response,
                        productId,
                        imageError
                );
                return;
            }

            /*
         * Chỉ xóa ảnh cũ sau khi:
         * 1. File mới đã lưu thành công.
         * 2. Database đã cập nhật thành công.
             */
            if (oldVariant.getImageUrl() != null
                    && !oldVariant.getImageUrl().isBlank()
                    && !oldVariant.getImageUrl().equals(
                            newImageName
                    )) {

                deleteProductImage(oldVariant.getImageUrl());
            }
        }

        redirectToProductDetail(
                response,
                productId,
                "variant-updated"
        );
    }

    private void rollbackVariantInfo(
            int productId,
            int variantId,
            ProductVariant oldVariant) {

        if (oldVariant == null) {
            return;
        }

        productService.updateVariantInfo(
                productId,
                variantId,
                oldVariant.getSize(),
                oldVariant.getColor(),
                oldVariant.getStatus()
        );
    }

    private void redirectToProductDetail(
            HttpServletResponse response,
            int productId,
            String status) throws IOException {

        String redirectUrl = getServletContext().getContextPath()
                + "/admin/manage-product?action=view";

        if (productId > 0) {
            redirectUrl += "&id=" + productId;
        }

        if (status != null && !status.isBlank()) {
            redirectUrl += "&status=" + status;
        }

        response.sendRedirect(redirectUrl);
    }

    private void handleUpdateVariantStatus(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int productId;
        int variantId;

        try {
            productId = Integer.parseInt(
                    request.getParameter("productId")
            );

            variantId = Integer.parseInt(
                    request.getParameter("variantId")
            );
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
            return;
        }

        String status = request.getParameter("status");

        boolean updated = productService.updateVariantStatus(
                productId,
                variantId,
                status
        );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-product?action=view&id="
                + productId
                + "&status="
                + (updated
                        ? "variant-updated"
                        : "variant-update-failed")
        );
    }

    private void handleAddVariants(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int productId;

        try {
            productId = Integer.parseInt(
                    getMultipartParameter(
                            request,
                            "productId"
                    )
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

        boolean added = productService.addVariants(
                productId,
                variants
        );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-product?action=view&id="
                + productId
                + "&status="
                + (added
                        ? "variants-added"
                        : "variant-duplicate")
        );
    }

    private void handleAddProduct(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Product product;

        try {
            product = extractProductFromRequest(request);
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
            return;
        }

        // Product mới luôn chưa sẵn sàng bán.
        product.setStatus("INACTIVE");

        String validationError
                = productService.validateProductForCreate(product);

        if (validationError != null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status="
                    + validationError
            );
            return;
        }

        String cleanSlug = productService.generateSlug(
                product.getProductName(),
                (int) (System.currentTimeMillis() % Integer.MAX_VALUE)
        );

        product.setSlug(cleanSlug);

        String savedImageName = null;

        try {
            Part imagePart = request.getPart("productImage");

            if (hasUploadedFile(imagePart)) {
                savedImageName = saveProductImage(imagePart);
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-image"
            );
            return;
        } catch (IOException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=image-upload-failed"
            );
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

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=variant-required"
            );
            return;
        }

        boolean added = productService.createProductWithVariants(
                product,
                savedImageName,
                variants
        );

        if (!added) {
            deleteProductImage(savedImageName);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-product?status="
                + (added ? "success" : "error")
        );
    }

    private void handleDeleteProduct(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String idRaw = request.getParameter("productId");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            idRaw = request.getParameter("id");
        }

        try {
            int productId = Integer.parseInt(idRaw);

            boolean deleted
                    = productService.deleteProductSmartly(productId);

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status="
                    + (deleted ? "deleted" : "error")
            );
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
        }
    }

    private Product extractProductFromRequest(
            HttpServletRequest request) {

        Product product = new Product();

        product.setProductName(
                getMultipartParameter(
                        request,
                        "productName"
                )
        );

        String brandId = getMultipartParameter(
                request,
                "brandId"
        );

        product.setBrandId(
                brandId == null || brandId.trim().isEmpty()
                ? 0
                : Integer.parseInt(brandId.trim())
        );

        String categoryId = getMultipartParameter(
                request,
                "categoryId"
        );

        product.setCategoryId(
                categoryId == null
                || categoryId.trim().isEmpty()
                ? 0
                : Integer.parseInt(categoryId.trim())
        );

        product.setShortDescription(
                getMultipartParameter(
                        request,
                        "shortDescription"
                )
        );

        product.setLongDescription(
                getMultipartParameter(
                        request,
                        "longDescription"
                )
        );

        product.setStatus(
                getMultipartParameter(
                        request,
                        "status"
                )
        );

        return product;
    }

    private List<ProductVariant> readVariantsFromRequest(
            HttpServletRequest request,
            int productId,
            String productName) {

        List<ProductVariant> variants
                = new ArrayList<>();

        for (int index = 0;
                index < MAX_VARIANT_ROWS;
                index++) {

            String size = getMultipartParameter(
                    request,
                    "variants[" + index + "].size"
            );

            String color = getMultipartParameter(
                    request,
                    "variants[" + index + "].color"
            );

            // Cho phép danh sách có index bị khuyết do admin xóa một dòng.
            if ((size == null || size.trim().isEmpty())
                    && (color == null || color.trim().isEmpty())) {
                continue;
            }

            if (size == null || size.trim().isEmpty()
                    || color == null
                    || color.trim().isEmpty()) {
                throw new IllegalArgumentException(
                        "Size and color are required"
                );
            }

            size = size.trim();
            color = color.trim();

            ProductVariant variant
                    = new ProductVariant();

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

            variant.setCostPrice(BigDecimal.ZERO);
            variant.setListPrice(BigDecimal.ZERO);
            variant.setSalePrice(BigDecimal.ZERO);
            variant.setStockQuantity(0);
            variant.setStatus("INACTIVE");
            variant.setAttributeDetails(
                    color + "|" + size
            );

            variants.add(variant);
        }

        return variants;
    }

    private boolean hasUploadedFile(Part part) {
        return part != null
                && part.getSubmittedFileName() != null
                && !part.getSubmittedFileName()
                        .trim()
                        .isEmpty()
                && part.getSize() > 0;
    }

    /**
     * Lưu ảnh ngoài thư mục deploy. ProductImageStorage đang trỏ tới the
     * project-root upload directory.
     */
    private String saveProductImage(Part filePart)
            throws IOException {

        String originalName = Paths.get(
                filePart.getSubmittedFileName()
        ).getFileName().toString();

        String extension = getFileExtension(
                originalName
        ).toLowerCase(Locale.ROOT);

        String contentType = filePart.getContentType();

        boolean validExtension
                = "jpg".equals(extension)
                || "jpeg".equals(extension)
                || "png".equals(extension)
                || "webp".equals(extension);

        boolean validContentType
                = contentType != null
                && ("image/jpeg".equals(contentType)
                || "image/png".equals(contentType)
                || "image/webp".equals(contentType));

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

        Path targetFile
                = ProductImageStorage.resolveFile(
                        savedName
                );

        try (InputStream inputStream
                = filePart.getInputStream()) {

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

        return dotIndex >= 0
                && dotIndex < fileName.length() - 1
                ? fileName.substring(dotIndex + 1)
                : "";
    }

    private void deleteProductImage(String imageName) {
        if (imageName == null
                || imageName.trim().isEmpty()) {
            return;
        }

        try {
            Path imageFile
                    = ProductImageStorage.resolveFile(
                            imageName
                    );

            Files.deleteIfExists(imageFile);
        } catch (Exception e) {
            System.err.println(
                    "Could not delete product image: "
                    + e.getMessage()
            );
        }
    }

    private String getMultipartParameter(
            HttpServletRequest request,
            String parameterName) {

        String value = request.getParameter(parameterName);

        if (value != null) {
            return value.trim();
        }

        try {
            Part part = request.getPart(parameterName);

            if (part == null) {
                return null;
            }

            byte[] content
                    = part.getInputStream()
                            .readAllBytes();

            return new String(
                    content,
                    StandardCharsets.UTF_8
            ).trim();
        } catch (Exception e) {
            return null;
        }
    }

    private void redirectToEdit(
            HttpServletResponse response,
            int productId,
            String status)
            throws IOException {

        response.sendRedirect(
                getServletContext().getContextPath()
                + "/admin/manage-product?action=edit&id="
                + productId
                + "&status="
                + status
        );
    }

    private void listProducts(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute(
                "products",
                productService.getAllProducts()
        );

        // Form Create chỉ nhận Category active.
        request.setAttribute(
                "categories",
                productService.getActiveCategories()
        );

        request.setAttribute(
                "brands",
                productService.getAllBrands()
        );

        request.getRequestDispatcher(
                "/view/admin/admin_product.jsp"
        ).forward(request, response);
    }

    private void showProductDetails(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int productId = Integer.parseInt(
                    request.getParameter("id")
            );

            Product product
                    = productService.getProductById(productId);

            if (product == null) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/manage-product?status=product-not-found"
                );
                return;
            }

            request.setAttribute("product", product);

            request.setAttribute(
                    "variants",
                    productService.getVariantsByProductId(
                            productId
                    )
            );

            request.getRequestDispatcher(
                    "/view/admin/product_detail.jsp"
            ).forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
        }
    }

    private void showEditForm(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int productId = Integer.parseInt(
                    request.getParameter("id")
            );

            Product product
                    = productService.getProductById(productId);

            if (product == null) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/manage-product?status=product-not-found"
                );
                return;
            }

            request.setAttribute("product", product);

            // Trang Edit phải nhận cả Category inactive.
            request.setAttribute(
                    "categories",
                    productService.getAllCategories()
            );

            request.setAttribute(
                    "brands",
                    productService.getAllBrands()
            );

            request.getRequestDispatcher(
                    "/view/admin/admin_edit_product.jsp"
            ).forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-product?status=invalid-request"
            );
        }
    }

    private String saveVariantImage(
            Part filePart,
            int productId,
            int variantId,
            String size,
            String color) throws IOException {

        if (!hasUploadedFile(filePart)) {
            return null;
        }

        String originalName = Paths.get(
                filePart.getSubmittedFileName()
        ).getFileName().toString();

        String extension = ProductImageStorage.normalizeExtension(
                getFileExtension(originalName)
        );

        String contentType = filePart.getContentType();

        boolean validContentType = contentType != null
                && ("image/jpeg".equals(contentType)
                || "image/png".equals(contentType)
                || "image/webp".equals(contentType));

        if (!validContentType) {
            throw new IllegalArgumentException(
                    "Unsupported image format"
            );
        }

        String savedName
                = ProductImageStorage.buildVariantImageName(
                        productId,
                        variantId,
                        size,
                        color,
                        extension
                );

        Path targetFile
                = ProductImageStorage.resolveFile(savedName);

        Path temporaryFile = Files.createTempFile(
                ProductImageStorage.getUploadDirectory(),
                "variant-upload-",
                ".tmp"
        );

        try {
            try (InputStream inputStream
                    = filePart.getInputStream()) {

                Files.copy(
                        inputStream,
                        temporaryFile,
                        StandardCopyOption.REPLACE_EXISTING
                );
            }

            try {
                Files.move(
                        temporaryFile,
                        targetFile,
                        StandardCopyOption.REPLACE_EXISTING,
                        StandardCopyOption.ATOMIC_MOVE
                );
            } catch (java.nio.file.AtomicMoveNotSupportedException e) {
                Files.move(
                        temporaryFile,
                        targetFile,
                        StandardCopyOption.REPLACE_EXISTING
                );
            }

            return savedName;

        } finally {
            Files.deleteIfExists(temporaryFile);
        }
    }
}
