package com.clothingsale.service;

import com.clothingsale.dao.AdminManageProductDAO;
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

    private final AdminManageProductDAO productDAO
            = new AdminManageProductDAO();

    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    public Product getProductById(int productId) {
        if (productId <= 0) {
            return null;
        }

        return productDAO.getProductById(productId);
    }

    public boolean addProduct(Product product, String imageName) {
        return productDAO.insertProductWithImage(product, imageName);
    }

    public boolean updateProduct(Product product, String newImageName) {
        if (product == null || product.getId() <= 0) {
            return false;
        }

        return productDAO.updateProduct(product, newImageName);
    }

    /**
     * Luôn dùng xóa mềm để giữ lịch sử giá, tồn kho và Order Detail.
     */
    public boolean deleteProductSmartly(int productId) {
        return productId > 0
                && productDAO.softDeleteProduct(productId);
    }

    public List<Brand> getAllBrands() {
        return productDAO.getAllBrands();
    }

    /**
     * Danh sách đầy đủ, bao gồm Category inactive. Dùng cho trang Edit để
     * Category hiện tại không bị mất khỏi select.
     */
    public List<Category> getAllCategories() {
        return productDAO.getAllCategories();
    }

    /**
     * Chỉ Category active, dùng cho form tạo Product.
     */
    public List<Category> getActiveCategories() {
        return productDAO.getActiveCategories();
    }

    public List<ProductVariant> getVariantsByProductId(int productId) {
        return productDAO.getVariantsByProductId(productId);
    }

    /**
     * Lấy vị trí tiếp theo cho Product mới được đưa vào khu vực Featured
     * Products của Homepage.
     */
    public int getNextFeaturedDisplayOrder() {
        return productDAO.getNextFeaturedDisplayOrder();
    }

    /**
     * Dùng để khóa công tắc Featured trên giao diện khi Product chưa đủ điều
     * kiện hiển thị cho Customer.
     */
    public boolean isProductEligibleForFeatured(int productId) {
        return productId > 0
                && productDAO.isProductEligibleForFeatured(productId);
    }

    /**
     * Bật hoặc tắt Product trong khu vực Featured Products của Homepage.
     *
     * Khi bật mà giao diện không truyền displayOrder, hệ thống giữ vị trí cũ
     * nếu Product đã Featured; nếu chưa có vị trí thì tự đưa xuống cuối danh
     * sách. Khi tắt, DAO sẽ đặt featured_display_order về NULL.
     *
     * @return null khi thành công; ngược lại trả về mã lỗi để Controller hiển
     * thị thông báo phù hợp.
     */
    public String updateFeaturedStatus(
            int productId,
            boolean featured,
            Integer displayOrder) {

        if (productId <= 0) {
            return "invalid-product-id";
        }

        Product product = productDAO.getProductById(productId);

        if (product == null
                || "DELETED".equalsIgnoreCase(product.getStatus())) {
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
            } else {
                normalizedDisplayOrder
                        = productDAO.getNextFeaturedDisplayOrder();
            }
        }

        boolean updated = productDAO.updateFeaturedStatus(
                productId,
                featured,
                normalizedDisplayOrder
        );

        return updated ? null : "featured-update-failed";
    }

    /**
     * Validation dữ liệu chung, không kiểm tra trạng thái Category.
     *
     * Lý do: admin vẫn phải sửa được ảnh, tên và mô tả của Product đang thuộc
     * Category inactive.
     */
    public String validateProduct(Product product) {
        if (product == null) {
            return "invalid-product";
        }

        String productName = product.getProductName();

        if (productName == null || productName.trim().isEmpty()) {
            return "name-required";
        }

        productName = productName.trim();

        if (productName.length() > 150) {
            return "name-too-long";
        }

        if (product.getCategoryId() <= 0) {
            return "category-required";
        }

        String status = normalizeStatus(product.getStatus());

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {
            return "invalid-status";
        }

        product.setProductName(productName);
        product.setStatus(status);

        if (product.getShortDescription() != null) {
            product.setShortDescription(
                    product.getShortDescription().trim()
            );
        }

        if (product.getLongDescription() != null) {
            product.setLongDescription(
                    product.getLongDescription().trim()
            );
        }

        return null;
    }

    /**
     * Product mới chỉ được tạo trong Category active.
     */
    public String validateProductForCreate(Product product) {
        String validationError = validateProduct(product);

        if (validationError != null) {
            return validationError;
        }

        if (!productDAO.isCategoryActive(
                product.getCategoryId())) {
            return "category-inactive";
        }

        return null;
    }

    /**
     * Cho phép sửa ảnh/thông tin khi Category hiện tại inactive.
     *
     * Chỉ chặn khi: 1. Chuyển Product sang một Category inactive khác. 2.
     * Chuyển Product từ INACTIVE sang ACTIVE trong Category inactive.
     */
    public String validateProductForUpdate(
            Product oldProduct,
            Product newProduct) {

        String validationError = validateProduct(newProduct);

        if (validationError != null) {
            return validationError;
        }

        if (oldProduct == null
                || oldProduct.getId() <= 0
                || "DELETED".equals(oldProduct.getStatus())) {
            return "product-not-found";
        }

        boolean categoryChanged
                = oldProduct.getCategoryId()
                != newProduct.getCategoryId();

        boolean activatingProduct
                = !"ACTIVE".equals(oldProduct.getStatus())
                && "ACTIVE".equals(newProduct.getStatus());

        if ((categoryChanged || activatingProduct)
                && !productDAO.isCategoryActive(
                        newProduct.getCategoryId())) {
            return "category-inactive";
        }

        return null;
    }

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

    public boolean updateVariantStatus(
            int productId,
            int variantId,
            String status) {

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

    public boolean createProductWithVariants(
            Product product,
            String imageName,
            List<ProductVariant> variants) {

        if (product == null) {
            return false;
        }

        // Product mới chưa được phép bán ngay.
        product.setStatus("INACTIVE");

        if (validateProductForCreate(product) != null
                || !validateVariants(variants)) {
            return false;
        }

        for (ProductVariant variant : variants) {
            prepareNewVariant(variant);
        }

        return productDAO.insertProductWithMatrixVariants(
                product,
                imageName,
                variants
        );
    }

    public boolean addVariants(
            int productId,
            List<ProductVariant> variants) {

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

    /**
     * Giữ để tương thích với code cũ.
     */
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

    public String generateBaseSku(String productName) {
        String value = normalizeSkuPart(productName);
        return "na".equals(value)
                ? "PRODUCT"
                : value.toUpperCase(Locale.ROOT);
    }

    public String generateVariantSku(
            String productName,
            String size,
            String color) {

        return normalizeSkuPart(productName)
                + "-"
                + normalizeSkuPart(size)
                + "-"
                + normalizeSkuPart(color);
    }

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

            String combinationKey
                    = normalizeVariantValue(variant.getSize())
                    + "|"
                    + normalizeVariantValue(variant.getColor());

            String skuKey = variant.getSku()
                    .trim()
                    .toLowerCase(Locale.ROOT);

            if (!combinations.add(combinationKey)
                    || !skuCodes.add(skuKey)) {
                return false;
            }

            variant.setSize(variant.getSize().trim());
            variant.setColor(variant.getColor().trim());
            variant.setSku(variant.getSku().trim());
        }

        return true;
    }

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

    private String normalizeStatus(String status) {
        return status == null
                ? null
                : status.trim().toUpperCase(Locale.ROOT);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

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

    public String updateVariantInfo(
            int productId,
            int variantId,
            String size,
            String color,
            String status) {

        if (productId <= 0 || variantId <= 0) {
            return "invalid-id";
        }

        if (isBlank(size)) {
            return "size-required";
        }

        if (isBlank(color)) {
            return "color-required";
        }

        size = size.trim();
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

    public String saveProductMainImage(
            int productId,
            String imageUrl) {

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

    public String saveVariantMainImage(
            int productId,
            int variantId,
            String imageUrl) {

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
     * Database chỉ được lưu đường dẫn tương đối.
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
}