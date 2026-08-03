package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
import com.clothingsale.dao.AdminManageProductDAO.DuplicateProductNameException;
import com.clothingsale.model.Brand;
import com.clothingsale.model.Category;
import com.clothingsale.model.Product;
import com.clothingsale.model.ProductVariant;
import java.math.BigDecimal;
import java.text.Normalizer;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class AdminManageProductService {

    private static final Set<String> TEXTUAL_SIZES = Set.of("XS", "S", "M", "L", "XL", "XXL", "XXXL", "3XL", "4XL", "FREE SIZE");

    private final AdminManageProductDAO productDAO
            = new AdminManageProductDAO();

    /** Lấy toàn bộ Product chưa bị xóa. */
    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    /** Lấy Product theo ID. */
    public Product getProductById(int productId) {
        if (productId <= 0) {
            return null;
        }

        return productDAO.getProductById(productId);
    }

    /** Tạo Product theo luồng tương thích cũ. */
    public boolean addProduct(Product product, String imageName) {
        try {
            return validateProductForCreate(product) == null && productDAO.insertProductWithImage(product, imageName);
        } catch (DuplicateProductNameException e) {
            return false;
        }
    }

    /** Cập nhật thông tin Product. */
    public boolean updateProduct(Product product, String newImageName) {
        return updateProductWithResult(product, newImageName) == null;
    }

    /** Cập nhật Product và trả mã lỗi. */
    public String updateProductWithResult(Product product, String newImageName) {
        if (product == null || product.getId() <= 0) {
            return "update-failed";
        }
        String validationError = validateProduct(product);
        if (validationError != null) {
            return validationError;
        }
        if (productDAO.productNameExists(product.getProductName(), product.getId())) {
            return "product-name-exists";
        }
        try {
            return productDAO.updateProduct(product, newImageName) ? null : "update-failed";
        } catch (DuplicateProductNameException e) {
            return "product-name-exists";
        }
    }

    /** Xóa mềm Product an toàn. */
    public boolean deleteProductSmartly(int productId) {
        return productId > 0
                && productDAO.softDeleteProduct(productId);
    }

    /** Lấy toàn bộ Brand. */
    public List<Brand> getAllBrands() {
        return productDAO.getAllBrands();
    }

    /** Lấy toàn bộ Category. */
    public List<Category> getAllCategories() {
        return productDAO.getAllCategories();
    }

    /** Lấy Category đang hoạt động. */
    public List<Category> getActiveCategories() {
        return productDAO.getActiveCategories();
    }

    /** Lấy danh sách Variant của Product. */
    public List<ProductVariant> getVariantsByProductId(int productId) {
        return productDAO.getVariantsByProductId(productId);
    }

    /** Lấy thứ tự Featured tiếp theo. */
    public int getNextFeaturedDisplayOrder() {
        return productDAO.getNextFeaturedDisplayOrder();
    }

    /** Kiểm tra Product đủ điều kiện Featured. */
    public boolean isProductEligibleForFeatured(int productId) {
        return productId > 0
                && productDAO.isProductEligibleForFeatured(productId);
    }

    /** Cập nhật và xác nhận trạng thái Featured. */
    public String updateFeaturedStatus(int productId, boolean featured, Integer displayOrder) {
        if (productId <= 0) {
            return "invalid-product-id";
        }

        Product product = productDAO.getProductById(productId);
        if (product == null || "DELETED".equalsIgnoreCase(product.getStatus())) {
            return "product-not-found";
        }

        Integer normalizedDisplayOrder = null;
        if (featured) {
            if (!productDAO.isProductEligibleForFeatured(productId)) {
                return "product-not-eligible-for-featured";
            }
            if (displayOrder != null && displayOrder > 0) {
                normalizedDisplayOrder = displayOrder;
            } else if (product.isFeatured()
                    && product.getFeaturedDisplayOrder() != null
                    && product.getFeaturedDisplayOrder() > 0) {
                normalizedDisplayOrder = product.getFeaturedDisplayOrder();
            }
            // Khi bật lần đầu, để DAO tự lấy MAX + 1 trong cùng transaction.
        }

        if (!productDAO.updateFeaturedStatus(productId, featured, normalizedDisplayOrder)) {
            return "featured-update-failed";
        }

        Product savedProduct = productDAO.getProductById(productId);
        if (savedProduct == null || savedProduct.isFeatured() != featured) {
            return "featured-update-failed";
        }
        if (featured && (savedProduct.getFeaturedDisplayOrder() == null || savedProduct.getFeaturedDisplayOrder() < 1)) {
            return "featured-update-failed";
        }
        return null;
    }

    /** Chuẩn hóa và kiểm tra Product. */
    public String validateProduct(Product product) {
        if (product == null) {
            return "invalid-product";
        }
        String productName = normalizeProductName(product.getProductName());
        if (productName == null || productName.isEmpty()) {
            return "name-required";
        }
        if (productName.length() > 150) {
            return "name-too-long";
        }
        if (product.getCategoryId() <= 0) {
            return "category-required";
        }
        String status = normalizeStatus(product.getStatus());
        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            return "invalid-status";
        }
        product.setProductName(productName);
        product.setStatus(status);
        if (product.getShortDescription() != null) {
            product.setShortDescription(product.getShortDescription().trim());
        }
        if (product.getLongDescription() != null) {
            product.setLongDescription(product.getLongDescription().trim());
        }
        return null;
    }

    /** Kiểm tra Product trước khi tạo. */
    public String validateProductForCreate(Product product) {
        String validationError = validateProduct(product);
        if (validationError != null) {
            return validationError;
        }
        if (productDAO.productNameExists(product.getProductName(), null)) {
            return "product-name-exists";
        }
        if (!productDAO.isCategoryActive(product.getCategoryId())) {
            return "category-inactive";
        }
        return null;
    }

    /** Kiểm tra Product trước khi edit. */
    public String validateProductForUpdate(Product oldProduct, Product newProduct) {
        String validationError = validateProduct(newProduct);
        if (validationError != null) {
            return validationError;
        }
        if (oldProduct == null || oldProduct.getId() <= 0 || "DELETED".equals(oldProduct.getStatus())) {
            return "product-not-found";
        }
        if (productDAO.productNameExists(newProduct.getProductName(), oldProduct.getId())) {
            return "product-name-exists";
        }
        boolean categoryChanged = oldProduct.getCategoryId() != newProduct.getCategoryId();
        boolean activatingProduct = !"ACTIVE".equals(oldProduct.getStatus()) && "ACTIVE".equals(newProduct.getStatus());
        if ((categoryChanged || activatingProduct) && !productDAO.isCategoryActive(newProduct.getCategoryId())) {
            return "category-inactive";
        }
        return null;
    }

    /** Tạo slug duy nhất cho Product. */
    public String generateSlug(String productName, int productId) {
        if (productName == null) {
            return "product-" + productId;
        }

        String slug = Normalizer.normalize(
                productName.trim(),
                Normalizer.Form.NFD
        );

        slug = slug.replaceAll("\\p{M}", "");
        slug = slug.replace('đ', 'd')
                .replace('Đ', 'D');
        slug = slug.toLowerCase(Locale.ROOT);
        slug = slug.replaceAll("[^a-z0-9]+", "-");
        slug = slug.replaceAll("^-+|-+$", "");

        if (slug.isEmpty()) {
            slug = "product";
        }

        return slug + "-" + productId;
    }

    /** Cập nhật trạng thái Variant. */
    public boolean updateVariantStatus(int productId, int variantId, String status) {

        if (productId <= 0 || variantId <= 0) {
            return false;
        }

        status = normalizeStatus(status);

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {
            return false;
        }

        Product product = productDAO.getProductById(productId);

        if (product == null
                || "DELETED".equals(product.getStatus())) {
            return false;
        }

        if ("ACTIVE".equals(status)
                && !"ACTIVE".equals(product.getStatus())) {
            return false;
        }

        return productDAO.updateVariantStatus(
                productId,
                variantId,
                status
        );
    }

    /** Tạo Product cùng Variant. */
    public boolean createProductWithVariants(Product product, String imageName, List<ProductVariant> variants) {
        return createProductWithVariantsResult(product, imageName, variants) == null;
    }

    /** Tạo Product và trả mã lỗi. */
    public String createProductWithVariantsResult(Product product, String imageName, List<ProductVariant> variants) {
        if (product == null) {
            return "invalid-product";
        }
        product.setStatus("INACTIVE");
        String validationError = validateProductForCreate(product);
        if (validationError != null) {
            return validationError;
        }
        if (!validateVariants(variants)) {
            return "variant-invalid";
        }
        for (ProductVariant variant : variants) {
            prepareNewVariant(variant);
        }
        try {
            return productDAO.insertProductWithMatrixVariants(product, imageName, variants) ? null : "error";
        } catch (DuplicateProductNameException e) {
            return "product-name-exists";
        }
    }

    /** Thêm danh sách Variant. */
    public boolean addVariants(int productId, List<ProductVariant> variants) {

        Product product = productDAO.getProductById(productId);

        if (productId <= 0
                || product == null
                || "DELETED".equals(product.getStatus())
                || !validateVariants(variants)) {
            return false;
        }

        for (ProductVariant variant : variants) {
            prepareNewVariant(variant);
            variant.setProductId(productId);

            if (productDAO.variantCombinationExists(
                    productId,
                    variant.getSize(),
                    variant.getColor())) {
                return false;
            }
        }

        return productDAO.insertVariants(variants);
    }

    /** Thêm một Variant. */
    public boolean addSingleVariant(ProductVariant variant) {
        if (variant == null
                || variant.getProductId() <= 0
                || !validateVariants(
                        java.util.Collections.singletonList(variant))) {
            return false;
        }

        prepareNewVariant(variant);

        return productDAO.insertSingleVariant(variant);
    }

    /** Tạo mã SKU cơ sở. */
    public String generateBaseSku(String productName) {
        String value = normalizeSkuPart(productName);
        return "na".equals(value)
                ? "PRODUCT"
                : value.toUpperCase(Locale.ROOT);
    }

    /** Tạo SKU theo Product, Size và Color. */
    public String generateVariantSku(String productName, String size, String color) {

        return normalizeSkuPart(productName)
                + "-"
                + normalizeSkuPart(size)
                + "-"
                + normalizeSkuPart(color);
    }

    /** Kiểm tra danh sách Variant. */
    private boolean validateVariants(List<ProductVariant> variants) {
        if (variants == null || variants.isEmpty()) {
            return false;
        }

        Set<String> combinations = new HashSet<>();
        Set<String> skuCodes = new HashSet<>();

        for (ProductVariant variant : variants) {
            if (variant == null
                    || isBlank(variant.getSize())
                    || isBlank(variant.getColor())
                    || isBlank(variant.getSku())) {
                return false;
            }

            String normalizedSize = normalizeSize(variant.getSize());
            if (normalizedSize == null) {
                return false;
            }

            String combinationKey
                    = normalizeVariantValue(normalizedSize)
                    + "|"
                    + normalizeVariantValue(variant.getColor());

            String skuKey = variant.getSku()
                    .trim()
                    .toLowerCase(Locale.ROOT);

            if (!combinations.add(combinationKey)
                    || !skuCodes.add(skuKey)) {
                return false;
            }

            variant.setSize(normalizedSize);
            variant.setColor(variant.getColor().trim());
            variant.setSku(variant.getSku().trim());
        }

        return true;
    }

    /** Chuẩn hóa Variant mới. */
    private void prepareNewVariant(ProductVariant variant) {
        variant.setCostPrice(BigDecimal.ZERO);
        variant.setListPrice(BigDecimal.ZERO);
        variant.setSalePrice(BigDecimal.ZERO);
        variant.setStockQuantity(0);
        variant.setStatus("INACTIVE");
        variant.setSize(variant.getSize().trim());
        variant.setColor(variant.getColor().trim());
        variant.setAttributeDetails(
                variant.getColor() + "|" + variant.getSize()
        );
    }

    /** Chuẩn hóa giá trị Variant. */
    private String normalizeVariantValue(String value) {
        String normalized = Normalizer.normalize(
                value.trim(),
                Normalizer.Form.NFD
        );

        return normalized
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ");
    }

    /** Chuẩn hóa thành phần SKU. */
    private String normalizeSkuPart(String value) {
        if (isBlank(value)) {
            return "na";
        }

        String normalized = Normalizer.normalize(
                value.trim(),
                Normalizer.Form.NFD
        );

        normalized = normalized
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");

        return normalized.isEmpty() ? "na" : normalized;
    }

    /** Chuẩn hóa khoảng trắng tên Product. */
    private String normalizeProductName(String value) {
        return value == null ? null : value.trim().replaceAll("\\s+", " ");
    }

    /** Chuẩn hóa trạng thái. */
    private String normalizeStatus(String status) {
        return status == null
                ? null
                : status.trim().toUpperCase(Locale.ROOT);
    }

    /** Kiểm tra chuỗi rỗng. */
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Lấy Variant theo ID. */
    public ProductVariant getVariantById(int productId, int variantId) {
        if (productId <= 0 || variantId <= 0) {
            return null;
        }

        ProductVariant variant = productDAO.getVariantById(
                productId,
                variantId
        );

        if (variant == null || variant.getProductId() != productId) {
            return null;
        }

        return variant;
    }

    /** Cập nhật Size, Color và trạng thái Variant. */
    public String updateVariantInfo(int productId, int variantId, String size, String color, String status) {

        if (productId <= 0 || variantId <= 0) {
            return "invalid-id";
        }

        if (isBlank(size)) {
            return "size-required";
        }

        if (isBlank(color)) {
            return "color-required";
        }

        size = normalizeSize(size);
        if (size == null) {
            return "size-invalid";
        }
        color = color.trim();
        status = normalizeStatus(status);

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {
            return "invalid-status";
        }

        Product product = productDAO.getProductById(productId);

        if (product == null
                || "DELETED".equals(product.getStatus())) {
            return "product-not-found";
        }

        ProductVariant currentVariant
                = productDAO.getVariantById(productId, variantId);

        if (currentVariant == null) {
            return "variant-not-found";
        }

        /*
     * Không cho Variant ACTIVE nếu Product đang INACTIVE.
         */
        if ("ACTIVE".equals(status)
                && !"ACTIVE".equals(product.getStatus())) {
            return "product-inactive";
        }

        /*
     * Không cho trùng Size + Color với Variant khác
     * thuộc cùng Product.
         */
        boolean combinationExists
                = productDAO.variantCombinationExistsForUpdate(
                        productId,
                        variantId,
                        size,
                        color
                );

        if (combinationExists) {
            return "variant-combination-exists";
        }

        boolean updated = productDAO.updateVariantInfo(
                productId,
                variantId,
                size,
                color,
                status
        );

        return updated ? null : "update-failed";
    }

    /** Lưu ảnh chính Product. */
    public String saveProductMainImage(int productId, String imageUrl) {

        if (productId <= 0) {
            return "invalid-id";
        }

        if (isBlank(imageUrl)) {
            return "image-required";
        }

        Product product = productDAO.getProductById(productId);

        if (product == null
                || "DELETED".equals(product.getStatus())) {
            return "product-not-found";
        }

        String normalizedImageUrl = imageUrl
                .trim()
                .replace("\\", "/");

        /*
         * DB chỉ lưu tên file hoặc đường dẫn tương đối.
         * Không chấp nhận path tuyệt đối và path traversal.
         */
        if (normalizedImageUrl.startsWith("/")
                || normalizedImageUrl.contains("..")
                || normalizedImageUrl.contains(":")
                || normalizedImageUrl.length() > 500) {
            return "invalid-image-path";
        }

        boolean saved = productDAO.saveProductMainImage(
                productId,
                normalizedImageUrl
        );

        return saved ? null : "image-save-failed";
    }

    /** Lấy ảnh chính của Variant. */
    public String getVariantMainImageUrl(int productId, int variantId) {

        if (productId <= 0 || variantId <= 0) {
            return null;
        }

        return productDAO.getVariantMainImageUrl(
                productId,
                variantId
        );
    }

    /** Lưu ảnh chính Variant. */
    public String saveVariantMainImage(int productId, int variantId, String imageUrl) {

        if (productId <= 0 || variantId <= 0) {
            return "invalid-id";
        }

        if (isBlank(imageUrl)) {
            return "image-required";
        }

        ProductVariant variant = productDAO.getVariantById(
                productId,
                variantId
        );

        if (variant == null) {
            return "variant-not-found";
        }

        String normalizedImageUrl = imageUrl
                .trim()
                .replace("\\", "/");

        /*
         * Database chỉ lưu tên file hoặc đường dẫn tương đối.
         * Không chấp nhận đường dẫn ổ đĩa hoặc path traversal.
         */
        if (normalizedImageUrl.startsWith("/")
                || normalizedImageUrl.contains("..")
                || normalizedImageUrl.contains(":")
                || normalizedImageUrl.length() > 500) {
            return "invalid-image-path";
        }

        boolean saved = productDAO.saveVariantMainImage(
                productId,
                variantId,
                normalizedImageUrl
        );

        return saved ? null : "image-save-failed";
    }

    /** Chuẩn hóa Size hợp lệ. */
    private String normalizeSize(String value) {
        if (isBlank(value)) {
            return null;
        }

        String normalized = value.trim().replaceAll("\\s+", " ").toUpperCase(Locale.ROOT);
        // Normalize legacy numeric apparel sizes when old records are edited.
        switch (normalized) {
            case "28": return "S";
            case "30": return "M";
            case "32": return "L";
            case "34": return "XL";
            case "36": return "XXL";
            default: break;
        }
        return TEXTUAL_SIZES.contains(normalized) ? normalized : null;
    }
}