package com.clothingsale.model;

public class Category {

    private int id;
    private String categoryName;
    private String slug;
    private int status;
    private int productCount;
    public Category() {
    }

    public Category(int id, String categoryName, String slug, int status, int productCount) {
        this.id = id;
        this.categoryName = categoryName;
        this.slug = slug;
        this.status = status;
        this.productCount = productCount;
    }

    public int getProductCount() {
        return productCount;
    }

    public void setProductCount(int productCount) {
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

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }
}
