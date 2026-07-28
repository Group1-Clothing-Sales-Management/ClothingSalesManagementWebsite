package com.clothingsale.service;

import com.clothingsale.dao.AdminManageCategoryDAO;
import com.clothingsale.model.Category;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;

public class AdminManageCategoryService {

    private static final int MAX_CATEGORY_NAME_LENGTH = 100;
    private static final int MAX_DESCRIPTION_LENGTH = 500;

    private final AdminManageCategoryDAO categoryDAO
            = new AdminManageCategoryDAO();

    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    public List<Category> getRootCategories() {
        return categoryDAO.getRootCategories();
    }

    public String addCategory(
            String rawName,
            Integer rawParentId,
            String rawDescription
    ) {
        String name = normalizeText(rawName);
        String description = normalizeDescription(rawDescription);
        Integer parentId = normalizeParentId(rawParentId);

        if (!isValidName(name)
                || description.length() > MAX_DESCRIPTION_LENGTH) {
            return "invalid";
        }

        String parentValidation = validateParent(parentId, null);
        if (parentValidation != null) {
            return parentValidation;
        }

        String slug = generateSlug(name);
        if (slug.isEmpty()) {
            return "invalid";
        }

        if (isDuplicateCategoryName(name, 0)) {
            return "duplicate-name";
        }

        if (categoryDAO.existsBySlug(slug, 0)) {
            return "duplicate-slug";
        }

        Category category = new Category();
        category.setCategoryName(name);
        category.setSlug(slug);
        category.setParentId(parentId);
        category.setDescription(emptyToNull(description));
        category.setStatus(1);

        return categoryDAO.insertCategory(category)
                ? "created"
                : "error";
    }

    public String updateCategory(
            int id,
            String rawName,
            Integer rawParentId,
            String rawDescription
    ) {
        if (id <= 0) {
            return "invalid";
        }

        Category currentCategory = categoryDAO.getCategoryById(id);
        if (currentCategory == null) {
            return "not-found";
        }

        String name = normalizeText(rawName);
        String description = normalizeDescription(rawDescription);
        Integer parentId = normalizeParentId(rawParentId);

        if (!isValidName(name)
                || description.length() > MAX_DESCRIPTION_LENGTH) {
            return "invalid";
        }

        if (parentId != null && parentId == id) {
            return "self-parent";
        }

        /*
         * Category đang có con phải tiếp tục là Category cấp gốc.
         * Nếu cho nó trở thành Subcategory, cây Category sẽ có ba cấp
         * hoặc làm mất cấu trúc hiển thị hiện tại.
         */
        if (parentId != null) {
            int childCount = categoryDAO.countChildren(id);

            if (childCount < 0) {
                return "error";
            }

            if (childCount > 0) {
                return "has-children";
            }
        }

        String parentValidation = validateParent(parentId, id);
        if (parentValidation != null) {
            return parentValidation;
        }

        String slug = generateSlug(name);
        if (slug.isEmpty()) {
            return "invalid";
        }

        if (isDuplicateCategoryName(name, id)) {
            return "duplicate-name";
        }

        if (categoryDAO.existsBySlug(slug, id)) {
            return "duplicate-slug";
        }

        currentCategory.setCategoryName(name);
        currentCategory.setSlug(slug);
        currentCategory.setParentId(parentId);
        currentCategory.setDescription(emptyToNull(description));

        return categoryDAO.updateCategory(currentCategory)
                ? "updated"
                : "error";
    }

    public String deactivateCategory(int id) {
        if (id <= 0) {
            return "invalid";
        }

        Category category = categoryDAO.getCategoryById(id);

        if (category == null) {
            return "not-found";
        }

        if (category.getStatus() == 0) {
            return "deactivated";
        }

        int activeProductCount
                = categoryDAO.countActiveProductsByCategory(id);

        if (activeProductCount < 0) {
            return "error";
        }

        if (activeProductCount > 0) {
            return "in-use";
        }

        int activeChildCount = categoryDAO.countActiveChildren(id);

        if (activeChildCount < 0) {
            return "error";
        }

        if (activeChildCount > 0) {
            return "has-active-children";
        }

        return categoryDAO.updateCategoryStatus(id, 0)
                ? "deactivated"
                : "error";
    }

    public String restoreCategory(int id) {
        if (id <= 0) {
            return "invalid";
        }

        Category category = categoryDAO.getCategoryById(id);

        if (category == null) {
            return "not-found";
        }

        if (category.getStatus() == 1) {
            return "restored";
        }

        /*
         * Subcategory chỉ được ACTIVE khi Parent Category còn ACTIVE.
         */
        String parentValidation
                = validateParent(category.getParentId(), id);

        if (parentValidation != null) {
            return parentValidation;
        }

        if (isDuplicateCategoryName(
                category.getCategoryName(),
                id
        )) {
            return "duplicate-name";
        }

        if (categoryDAO.existsBySlug(
                category.getSlug(),
                id
        )) {
            return "duplicate-slug";
        }

        return categoryDAO.updateCategoryStatus(id, 1)
                ? "restored"
                : "error";
    }

    /**
     * Trả về null khi hợp lệ; ngược lại trả về mã lỗi.
     */
    private String validateParent(
            Integer parentId,
            Integer currentCategoryId
    ) {
        if (parentId == null) {
            return null;
        }

        if (parentId <= 0) {
            return "invalid-parent";
        }

        if (currentCategoryId != null
                && parentId.equals(currentCategoryId)) {
            return "self-parent";
        }

        Category parent = categoryDAO.getCategoryById(parentId);

        if (parent == null) {
            return "parent-not-found";
        }

        if (parent.getParentId() != null) {
            return "invalid-parent";
        }

        if (parent.getStatus() != 1) {
            return "parent-inactive";
        }

        return null;
    }

    /**
     * Kiểm tra tên trùng theo dạng chuẩn hóa nghiệp vụ.
     *
     * Ngoài chữ hoa/thường, dấu tiếng Việt và ký tự đặc biệt,
     * hàm còn chuẩn hóa các biến thể sở hữu phổ biến:
     *
     * Men's Jeans -> men jeans
     * Mens Jeans  -> men jeans
     * Men jeans   -> men jeans
     */
    private boolean isDuplicateCategoryName(
            String categoryName,
            int excludedId
    ) {
        /*
         * Giữ kiểm tra SQL chính xác trước để tận dụng truy vấn nhanh.
         */
        if (categoryDAO.existsByName(categoryName, excludedId)) {
            return true;
        }

        List<String> existingNames
                = categoryDAO.getCategoryNamesForDuplicateCheck(
                        excludedId
                );

        /*
         * Không tiếp tục ghi dữ liệu nếu không đọc được danh sách kiểm tra.
         */
        if (existingNames == null) {
            return true;
        }

        String candidateKey
                = generateDuplicateKey(categoryName);

        if (candidateKey.isEmpty()) {
            return true;
        }

        for (String existingName : existingNames) {
            if (candidateKey.equals(
                    generateDuplicateKey(existingName)
            )) {
                return true;
            }
        }

        return false;
    }

    private String generateDuplicateKey(String value) {
        if (value == null) {
            return "";
        }

        String key = Normalizer
                .normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                /*
                 * Bỏ dấu sở hữu trước khi chuẩn hóa dấu câu:
                 * men's -> mens, women's -> womens.
                 */
                .replaceAll("['’`]", "")
                .replaceAll("[^a-z0-9]+", " ")
                .trim()
                .replaceAll("\\s+", " ");

        /*
         * Chuẩn hóa các cách viết thường gặp trong Category quần áo.
         * Không áp dụng singularization chung để tránh đổi sai jeans,
         * shorts hoặc các danh từ hợp lệ khác.
         */
        key = key
                .replaceAll("\\bmens\\b", "men")
                .replaceAll("\\bwomens\\b", "women")
                .replaceAll("\\bboys\\b", "boy")
                .replaceAll("\\bgirls\\b", "girl");

        return key;
    }

    private Integer normalizeParentId(Integer parentId) {
        return parentId == null || parentId <= 0
                ? null
                : parentId;
    }

    private String normalizeText(String value) {
        if (value == null) {
            return "";
        }

        return value
                .trim()
                .replaceAll("\\s+", " ");
    }

    private String normalizeDescription(String value) {
        return normalizeText(value);
    }

    private boolean isValidName(String name) {
        return !name.isEmpty()
                && name.length() <= MAX_CATEGORY_NAME_LENGTH;
    }

    private String emptyToNull(String value) {
        return value == null || value.isEmpty()
                ? null
                : value;
    }

    private String generateSlug(String value) {
        return Normalizer
                .normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "")
                .replaceAll("-+", "-");
    }
}