package com.clothingsale.service;

import com.clothingsale.dao.AdminManageCategoryDAO;
import com.clothingsale.model.Category;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;

public class AdminManageCategoryService {

    private final AdminManageCategoryDAO categoryDAO
            = new AdminManageCategoryDAO();

    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    public String addCategory(String rawName) {
        String name = normalizeName(rawName);

        if (!isValidName(name)) {
            return "invalid";
        }

        String slug = generateSlug(name);

        if (slug.isEmpty()) {
            return "invalid";
        }

        if (categoryDAO.existsByName(name, 0)) {
            return "duplicate-name";
        }

        if (categoryDAO.existsBySlug(slug, 0)) {
            return "duplicate-slug";
        }

        Category category = new Category();
        category.setCategoryName(name);
        category.setSlug(slug);
        category.setStatus(1);

        return categoryDAO.insertCategory(category)
                ? "created"
                : "error";
    }

    public String updateCategory(int id, String rawName) {
        if (id <= 0) {
            return "invalid";
        }

        Category currentCategory = categoryDAO.getCategoryById(id);

        if (currentCategory == null) {
            return "not-found";
        }

        String name = normalizeName(rawName);

        if (!isValidName(name)) {
            return "invalid";
        }

        String slug = generateSlug(name);

        if (slug.isEmpty()) {
            return "invalid";
        }

        if (categoryDAO.existsByName(name, id)) {
            return "duplicate-name";
        }

        if (categoryDAO.existsBySlug(slug, id)) {
            return "duplicate-slug";
        }

        currentCategory.setCategoryName(name);
        currentCategory.setSlug(slug);

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
         * Kiểm tra dữ liệu cũ trong trường hợp database
         * đã tồn tại category trùng tên hoặc slug.
         */
        if (categoryDAO.existsByName(
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

    private String normalizeName(String value) {
        if (value == null) {
            return "";
        }

        return value
                .trim()
                .replaceAll("\\s+", " ");
    }

    private boolean isValidName(String name) {
        return !name.isEmpty()
                && name.length() <= 100;
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