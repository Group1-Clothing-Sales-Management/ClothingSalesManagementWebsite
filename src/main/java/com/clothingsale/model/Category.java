package com.clothingsale.model;

import java.util.ArrayList;
import java.util.List;

public class Category {

    private int id;
    private String categoryName;
    private String slug;
    private Integer parentId;
    private String description;
    private int status;
    private int productCount;
    private List<Category> children = new ArrayList<>();

    public Category() {
    }

    public Category(int id, String categoryName, String slug,
            int status, int productCount) {
        this.id = id;
        this.categoryName = categoryName;
        this.slug = slug;
        this.status = status;
        this.productCount = productCount;
    }

    public Category(int id, String categoryName, String slug,
            Integer parentId, String description, int status,
            int productCount) {
        this.id = id;
        this.categoryName = categoryName;
        this.slug = slug;
        this.parentId = parentId;
        this.description = description;
        this.status = status;
        this.productCount = productCount;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getProductCount() {
        return productCount;
    }

    public void setProductCount(int productCount) {
        this.productCount = productCount;
    }

    public List<Category> getChildren() {
        return children;
    }

    public void setChildren(List<Category> children) {
        this.children = children == null ? new ArrayList<>() : children;
    }

    public void addChild(Category child) {
        if (child != null) {
            children.add(child);
        }
    }

    public boolean isRootCategory() {
        return parentId == null;
    }

    public boolean isHasChildren() {
        return children != null && !children.isEmpty();
    }
}