<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Product Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f3f4f6;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            .wrapper {
                display: flex;
                width: 100%;
                align-items: stretch;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                min-height: 100vh;
                background-color: #f3f4f6;
            }
            .detail-card {
                background: #fff;
                border-radius: 12px;
                border: none;
            }
            .variant-table th {
                background-color: #1f2937 !important;
                color: #fff !important;
            }
            .product-image-box {
                width: 54px;
                height: 54px;
                margin: 0 auto;
                border-radius: 6px;
                overflow: hidden;
                border: 1px solid #e5e7eb;
                background-color: #f8f9fa;
            }
            .product-img {
                width: 100%;
                height: 100%;
                display: block;
                object-fit: cover;
            }
            .product-image-placeholder {
                width: 100%;
                height: 100%;
                align-items: center;
                justify-content: center;
                color: #9ca3af;
                background-color: #f8f9fa;
                font-size: 1.2rem;
            }
            .product-filter-panel {
                padding: 16px;
                border: 1px solid #e5e7eb;
                border-radius: 12px;
                background: #f8fafc;
            }
            .product-filter-panel .form-control,
            .product-filter-panel .form-select,
            .product-filter-panel .input-group-text {
                min-height: 42px;
                border-color: #dbe2ea;
            }
            .product-filter-panel .input-group-text {
                background: #fff;
                color: #64748b;
            }
            .product-filter-panel .form-control:focus,
            .product-filter-panel .form-select:focus {
                border-color: #86b7fe;
                box-shadow: 0 0 0 .2rem rgba(13, 110, 253, .12);
            }
            .product-result-summary {
                color: #64748b;
                font-size: .9rem;
            }
            .product-filter-label {
                margin-bottom: 6px;
                color: #475569;
                font-size: .82rem;
                font-weight: 700;
            }

            .admin-product-table {
                min-width: 1160px;
                table-layout: fixed;
                border-color: #dfe5ec;
            }
            .admin-product-table thead th {
                padding: 13px 14px;
                border-color: #334155;
                font-size: .8rem;
                font-weight: 700;
                letter-spacing: .01em;
                line-height: 1.25;
                vertical-align: middle;
                white-space: nowrap;
            }
            .admin-product-table tbody td {
                padding: 13px 14px;
                border-color: #e2e8f0;
                color: #334155;
                font-size: .9rem;
                vertical-align: middle;
            }
            .admin-product-table tbody tr {
                height: 88px;
            }
            .admin-product-table tbody tr:hover {
                background-color: #f8fbff;
            }
            .product-summary {
                display: flex;
                align-items: center;
                gap: 13px;
                min-width: 0;
            }
            .product-summary .product-image-box {
                flex: 0 0 62px;
                width: 62px;
                height: 62px;
                margin: 0;
                border-radius: 10px;
                box-shadow: 0 3px 10px rgba(15, 23, 42, .08);
            }
            .product-summary-content {
                min-width: 0;
            }
            .product-summary-name {
                display: block;
                overflow: hidden;
                color: #111827;
                font-size: .98rem;
                font-weight: 650;
                line-height: 1.4;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            .product-meta-text {
                display: inline-block;
                max-width: 100%;
                overflow: hidden;
                color: #334155;
                font-size: .88rem;
                font-weight: 600;
                line-height: 1.4;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            .featured-control-form {
                display: flex;
                align-items: center;
                justify-content: flex-start;
                margin: 0;
            }
            .featured-switch-wrap {
                display: inline-flex;
                align-items: center;
                min-width: 132px;
                min-height: 38px;
                padding: 7px 11px;
                border: 1px solid #d9e1ea;
                border-radius: 10px;
                background: #f8fafc;
                transition: border-color .2s ease, background-color .2s ease, box-shadow .2s ease;
            }
            .featured-switch-wrap.is-active {
                border-color: #f4c95d;
                background: #fff9e8;
            }
            .featured-switch-wrap.is-saving {
                border-color: #86b7fe;
                background: #eef6ff;
                box-shadow: 0 0 0 .15rem rgba(13, 110, 253, .08);
            }
            .featured-switch-wrap .form-check {
                display: flex;
                align-items: center;
                gap: 8px;
                min-height: 0;
                margin: 0;
                padding-left: 0;
            }
            .featured-switch-wrap .form-check-input {
                float: none;
                flex: 0 0 auto;
                width: 2rem;
                height: 1.08rem;
                margin: 0;
                cursor: pointer;
            }
            .featured-switch-wrap .form-check-input:disabled {
                cursor: not-allowed;
                opacity: .55;
            }
            .featured-switch-wrap .form-check-label {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                margin: 0;
                color: #64748b;
                font-size: .78rem;
                font-weight: 700;
                line-height: 1;
                cursor: pointer;
                white-space: nowrap;
            }
            .featured-switch-wrap.is-active .form-check-label {
                color: #9a6700;
            }
            .featured-switch-wrap.is-saving .form-check-label {
                color: #0d6efd;
            }
            .featured-saving-icon {
                display: none;
                font-size: .75rem;
            }
            .featured-switch-wrap.is-saving .featured-saving-icon {
                display: inline-block;
            }
            .product-status-badge {
                min-width: 82px;
                padding: 7px 11px;
                border-radius: 8px;
                font-size: .75rem;
                font-weight: 700;
                letter-spacing: .02em;
            }
            .product-action-group {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                white-space: nowrap;
            }
            .product-action-group .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex: 0 0 38px;
                width: 38px;
                height: 36px;
                min-width: 38px;
                padding: 0;
                border-radius: 8px;
                font-size: .84rem;
            }
            @media (max-width: 1399.98px) {
                .admin-product-table {
                    min-width: 1120px;
                }
                .admin-product-table thead th,
                .admin-product-table tbody td {
                    padding-left: 11px;
                    padding-right: 11px;
                }
                .product-action-group .btn {
                    min-width: 38px;
                    padding: 0;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="admin-page product-page">
            <div class="container-fluid">

                <div class="page-header">
                    <jsp:include page="/view/admin/common/page_heading.jsp">
                        <jsp:param name="icon" value="fa-solid fa-box-open"/>
                        <jsp:param name="title" value="Product Management"/>
                    </jsp:include>
                    <button class="btn btn-primary px-4 py-2 rounded-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#createProductModal">
                        <i class="fa-solid fa-plus me-1"></i> Add New Product
                    </button>
                </div>

                <div class="card card-main admin-card p-4">
                   
                    <div class="product-filter-panel mb-3">
                        <div class="product-filter-grid">
                            <!-- Search is wider so the placeholder and entered text remain readable. -->
                            <div class="product-filter-field product-filter-search">
                                <label for="productSearchInput" class="product-filter-label">
                                    Search products
                                </label>
                                <div class="input-group"> 
                                    <input type="search"
                                           id="productSearchInput"
                                           class="form-control"
                                           placeholder="Search by product name, category or brand..."
                                           autocomplete="off">
                                    <button type="button"
                                            id="productSearchClear"
                                            class="btn btn-outline-secondary"
                                            title="Clear search"
                                            aria-label="Clear search"
                                            disabled>
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="product-filter-field">
                                <label for="productCategoryFilter" class="product-filter-label">
                                    Category
                                </label>
                                <select id="productCategoryFilter" class="form-select">
                                    <option value="">All categories</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <c:if test="${cat.parentId ne null}">
                                            <option value="${cat.id}">
                                                ${cat.categoryName}
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </select>

                            </div>
                            <div class="product-filter-field">
                                <label for="productBrandFilter" class="product-filter-label">
                                    Brand
                                </label>
                                <select id="productBrandFilter" class="form-select">
                                    <option value="">All brands</option>
                                    <c:forEach var="br" items="${brands}">
                                        <option value="${br.id}">${br.brandName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="product-filter-field">
                                <label for="productStatusFilter" class="product-filter-label">
                                    Status
                                </label>
                                <select id="productStatusFilter" class="form-select">
                                    <option value="">All statuses</option>
                                    <option value="ACTIVE">Active</option>
                                    <option value="INACTIVE">Inactive</option>
                                </select>
                            </div>
                            <div class="product-filter-actions">
                                <button type="button"
                                        id="resetProductFilters"
                                        class="btn btn-outline-secondary w-100">
                                    <i class="fa-solid fa-rotate-left me-1"></i>
                                    Reset filters
                                </button>
                            </div>

                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <small id="productResultSummary" class="text-muted"></small>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-striped table-hover align-middle border variant-table admin-table admin-product-table mb-0"
                               data-client-pagination data-pagination-label="products">
                            <colgroup>
                                <col style="width: 25%;">
                                <col style="width: 10%;">
                                <col style="width: 10%;">
                                <col style="width: 15%;">
                                <col style="width: 5%;">
                                <col style="width: 15%;">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th class="text-start">Product</th>
                                    <th class="text-start">Category</th>
                                    <th class="text-start">Brand</th>
                                    <th class="text-start">Featured on Home</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="productTableBody">
                                <c:forEach var="prod" items="${products}">
                                    <c:set var="productCategoryName" value="Category ${prod.categoryId}" />
                                    <c:forEach var="cat" items="${categories}">
                                        <c:if test="${cat.id == prod.categoryId}">
                                            <c:set var="productCategoryName" value="${cat.categoryName}" />
                                        </c:if>
                                    </c:forEach>

                                    <c:set var="productBrandName" value="Brand ${prod.brandId}" />
                                    <c:forEach var="br" items="${brands}">
                                        <c:if test="${br.id == prod.brandId}">
                                            <c:set var="productBrandName" value="${br.brandName}" />
                                        </c:if>
                                    </c:forEach>

                                    <tr class="product-row"
                                        data-product-id="${prod.id}"
                                        data-category-id="${prod.categoryId}"
                                        data-brand-id="${prod.brandId}"
                                        data-status="${prod.status}"
                                        data-featured="${prod.featured}">
                                        <td>
                                            <div class="product-summary">
                                                <div class="product-image-box">
                                                    <c:choose>
                                                        <c:when test="${not empty prod.mainImageUrl}">
                                                            <c:url var="productImageUrl"
                                                                   value="/media/product/${prod.mainImageUrl}" />
                                                            <img src="${productImageUrl}"
                                                                 class="product-img"
                                                                 alt="${prod.productName}"
                                                                 loading="lazy"
                                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                            <div class="product-image-placeholder"
                                                                 style="display: none;"
                                                                 title="Image file not found">
                                                                <i class="fa-regular fa-image"></i>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="product-image-placeholder"
                                                                 style="display: flex;"
                                                                 title="No product image">
                                                                <i class="fa-regular fa-image"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="product-summary-content">
                                                    <span class="product-summary-name product-name-cell"
                                                          title="${prod.productName}">
                                                        ${prod.productName}
                                                    </span>
                                                </div>
                                            </div>
                                        </td>

                                        <td class="text-start">
                                            <span class="product-meta-text" title="${productCategoryName}">
                                                ${productCategoryName}
                                            </span>
                                        </td>

                                        <td class="text-start">
                                            <span class="product-meta-text" title="${productBrandName}">
                                                ${productBrandName}
                                            </span>
                                        </td>

                                        <td>
                                            <form class="featured-control-form"
                                                  action="${pageContext.request.contextPath}/admin/manage-product"
                                                  data-submit-url="${pageContext.request.contextPath}/admin/manage-product"
                                                  method="POST">
                                                <input type="hidden" name="action" value="UPDATE_FEATURED">
                                                <input type="hidden" name="productId" value="${prod.id}">
                                                <input type="hidden"
                                                       name="featured"
                                                       class="featured-hidden-value"
                                                       value="${prod.featured ? 'true' : 'false'}">

                                                <div class="featured-switch-wrap ${prod.featured ? 'is-active' : ''}"
                                                     title="${prod.status != 'ACTIVE'
                                                              ? 'Activate the product before changing Homepage Featured'
                                                              : 'Turn on or off. Changes are saved automatically.'}">
                                                    <div class="form-check form-switch">
                                                        <input class="form-check-input featured-toggle"
                                                               type="checkbox"
                                                               role="switch"
                                                               id="featured-${prod.id}"
                                                               ${prod.featured ? 'checked' : ''}
                                                               ${prod.status != 'ACTIVE' ? 'disabled' : ''}>
                                                        <label class="form-check-label"
                                                               for="featured-${prod.id}">
                                                            <i class="fa-solid fa-spinner fa-spin featured-saving-icon"></i>
                                                            <span class="featured-toggle-text">
                                                                ${prod.featured ? 'Featured' : 'Not featured'}
                                                            </span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </form>
                                        </td>

                                        <td class="text-center">
                                            <span class="badge product-status-badge ${prod.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                                ${prod.status}
                                            </span>
                                        </td>

                                        <td>
                                            <div class="product-action-group">
                                                <a href="${pageContext.request.contextPath}/AdminManageProduct?action=view&id=${prod.id}"
                                                   class="btn btn-outline-info"
                                                   title="View product">
                                                    <i class="fa-solid fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${prod.id}"
                                                   class="btn btn-outline-warning"
                                                   title="Edit product">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </a>
                                                <button type="button"
                                                        class="btn btn-outline-danger"
                                                        onclick="deleteProduct(${prod.id})"
                                                        title="Delete product">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <tr id="productNoResultsRow" class="d-none">
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-magnifying-glass mb-2 d-block fs-4"></i>
                                        No products match the current search and filters.
                                    </td>
                                </tr>

                                <c:if test="${empty products}">
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">
                                            No products found. Click "Add New Product" to start.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <div class="modal fade" id="createProductModal" tabindex="-1" aria-labelledby="createProductModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content" style="border-radius: 12px; border: none;">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold" id="createProductModalLabel"><i class="fa-solid fa-square-plus text-primary me-2"></i>Create New Product</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="createProductForm" action="${pageContext.request.contextPath}/AdminManageProduct?action=ADD" method="POST" enctype="multipart/form-data" class="h-100">
                        <div class="modal-body p-0" style="max-height: 70vh; overflow-y: auto;">
                            <div class="p-4 bg-light">
                                <div class="accordion" id="productFormAccordion">
                                    <div class="accordion-item shadow-sm mb-3 border-0 rounded">
                                        <h2 class="accordion-header" id="headingProductInfo">
                                            <button class="accordion-button bg-white text-dark fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseProductInfo" aria-expanded="true" aria-controls="collapseProductInfo">
                                                <i class="fa-solid fa-info-circle me-2 text-info"></i>1. Core Product Information
                                            </button>
                                        </h2>
                                        <div id="collapseProductInfo" class="accordion-collapse collapse show" aria-labelledby="headingProductInfo" data-bs-parent="#productFormAccordion">
                                            <div class="accordion-body bg-white border-top">
                                                <div class="row g-3">
                                                    <div class="col-md-12">
                                                        <label class="form-label fw-semibold">Product Name <span class="text-danger">*</span></label>
                                                        <input type="text" id="adminProductName" name="productName" class="form-control" placeholder="e.g. Premium Cotton T-Shirt" required>
                                                        <input type="hidden" name="slug" value="default-slug">
                                                        <input type="hidden" name="status" value="ACTIVE">
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                                                        <select name="categoryId" class="form-select" required>
                                                            <option value="">-- Select Sub Category --</option>
                                                            <c:forEach var="cat" items="${categories}">
                                                                <c:if test="${cat.parentId ne null}">
                                                                    <option value="${cat.id}">
                                                                        ${cat.categoryName}
                                                                    </option>
                                                                </c:if>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Brand <span class="text-danger">*</span></label>
                                                        <select name="brandId" class="form-select" required>
                                                            <option value="">-- Select Brand --</option>
                                                            <c:forEach var="br" items="${brands}">
                                                                <option value="${br.id}">${br.brandName}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label fw-semibold">Product Image <span class="text-danger">*</span></label>
                                                        <input type="file" name="productImage" class="form-control" required>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label fw-semibold">Description</label>
                                                        <textarea name="longDescription" class="form-control" rows="3" placeholder="Write product highlights here..."></textarea>
                                                        <input type="hidden" name="shortDescription" value="">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="accordion-item shadow-sm mb-2 border-0 rounded">
                                        <h2 class="accordion-header" id="headingVariants">
                                            <button class="accordion-button bg-white text-dark fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseVariants" aria-expanded="true" aria-controls="collapseVariants">
                                                <i class="fa-solid fa-boxes-stacked me-2 text-primary"></i>2. Product Variants Configuration
                                            </button>
                                        </h2>
                                        <div id="collapseVariants" class="accordion-collapse collapse show" aria-labelledby="headingVariants" data-bs-parent="#productFormAccordion">
                                            <div class="accordion-body bg-white border-top">
                                                <div class="alert alert-light border d-flex align-items-start gap-2 mb-3">
                                                    <i class="fa-solid fa-circle-info text-primary mt-1"></i>
                                                    <div>
                                                        <strong>Each size-color pair is one variant.</strong>
                                                        New variants are saved as <strong>INACTIVE</strong> automatically until a valid selling price is configured.
                                                    </div>
                                                </div>

                                                <div class="row g-3 align-items-end">
                                                    <div class="col-md-4">
                                                        <label for="adminVariantSize" class="form-label fw-semibold">
                                                            Size <span class="text-danger">*</span>
                                                        </label>
                                                        <select id="adminVariantSize" class="form-select">
                                                            <option value="">-- Select Size --</option>
                                                            <option value="S">S</option>
                                                            <option value="M">M</option>
                                                            <option value="L">L</option>
                                                            <option value="XL">XL</option>
                                                            <option value="XXL">XXL</option>
                                                            <option value="FREE SIZE">Free Size</option>
                                                        </select>
                                                    </div>

                                                    <div class="col-md-5">
                                                        <label for="adminVariantColor" class="form-label fw-semibold">
                                                            Color <span class="text-danger">*</span>
                                                        </label>
                                                        <input type="text"
                                                               id="adminVariantColor"
                                                               class="form-control"
                                                               maxlength="50"
                                                               placeholder="e.g. White, Navy Blue">
                                                    </div>

                                                    <div class="col-md-3">
                                                        <button type="button"
                                                                id="adminAddVariantButton"
                                                                class="btn btn-outline-primary w-100">
                                                            <i class="fa-solid fa-plus me-1"></i>Add Variant
                                                        </button>
                                                    </div>
                                                </div>

                                                <div class="mt-4">
                                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                                        <div>
                                                            <h6 class="fw-bold mb-1">Temporary Variant List</h6>
                                                            <div class="text-muted small">Add only the combinations that the product actually has.</div>
                                                        </div>
                                                        <span id="adminVariantCount" class="badge bg-primary">0 variants</span>
                                                    </div>

                                                    <div class="table-responsive border rounded shadow-sm">
                                                        <table class="table table-hover align-middle mb-0" id="adminVariantTable">
                                                            <thead class="table-dark">
                                                                <tr>
                                                                    <th>Combination</th>
                                                                    <th>Generated SKU</th>
                                                                    <th class="text-center" style="width: 90px;">Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody id="adminVariantListBody">
                                                                <tr>
                                                                    <td colspan="3" class="text-center py-4 text-muted">
                                                                        <i class="fa-solid fa-circle-info me-1"></i>No variants added yet.
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-top bg-white sticky-bottom m-0 p-3" style="z-index: 20;">
                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary px-4"><i class="fa-solid fa-floppy-disk me-1"></i> Save Product</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>



        <form id="hiddenDeleteForm" action="${pageContext.request.contextPath}/AdminManageProduct?action=DELETE" method="POST" style="display:none;">
            <input type="hidden" name="productId" id="hiddenDeleteProductId">
        </form>

        <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            (function () {
                "use strict";

                const statusMessages = {
                    "product-name-exists": ["Duplicate product name", "A product with this name already exists.", "warning"],
                    "product-not-eligible-for-featured": ["Cannot feature product", "The product must be active and have at least one active variant with a valid price.", "warning"],
                    "featured-update-failed": ["Update failed", "The Featured Products setting could not be saved.", "error"],
                    "product-not-found": ["Product not found", "The selected product no longer exists.", "error"],
                    "invalid-product-id": ["Invalid product", "The selected product ID is invalid.", "warning"],
                    "invalid-request": ["Invalid request", "The submitted product data is invalid.", "warning"],
                    "invalid-action": ["Invalid action", "The requested Product action is not supported.", "warning"],
                    "session-expired": ["Session expired", "Please sign in again before changing Featured Products.", "warning"],
                    "server-error": ["Server error", "The server could not process the Featured Product request.", "error"]
                };

                function showToast(message, type, title) {
                    if (typeof window.showAppToast === "function") {
                        window.showAppToast(message, type, {title: title});
                        return;
                    }
                    window.alert(title + ": " + message);
                }

                function showStatusMessage(errorCode) {
                    const message = statusMessages[errorCode] || statusMessages["featured-update-failed"];
                    showToast(message[1], message[2], message[0]);
                }

                function initProductFilters() {
                    const searchInput = document.getElementById("productSearchInput");
                    const clearSearchButton = document.getElementById("productSearchClear");
                    const categoryFilter = document.getElementById("productCategoryFilter");
                    const brandFilter = document.getElementById("productBrandFilter");
                    const statusFilter = document.getElementById("productStatusFilter");
                    const resetFiltersButton = document.getElementById("resetProductFilters");
                    const resultSummary = document.getElementById("productResultSummary");
                    const noResultsRow = document.getElementById("productNoResultsRow");
                    const productRows = Array.from(document.querySelectorAll("#productTableBody .product-row"));

                    if (!searchInput || !categoryFilter || !brandFilter || !statusFilter || !resetFiltersButton) {
                        console.warn("Product filters were not initialized because one or more controls are missing.");
                        return;
                    }

                    function normalizeSearchValue(value) {
                        return String(value == null ? "" : value)
                                .normalize("NFD")
                                .replace(/[\u0300-\u036f]/g, "")
                                .replace(/đ/g, "d")
                                .replace(/Đ/g, "D")
                                .toLowerCase()
                                .replace(/\s+/g, " ")
                                .trim();
                    }

                    function getOptionLabel(select, value) {
                        if (!select || !value) {
                            return "";
                        }
                        const option = Array.from(select.options).find(function (item) {
                            return item.value === String(value);
                        });
                        return option ? option.textContent : "";
                    }

                    function applyProductFilters() {
                        const keyword = normalizeSearchValue(searchInput.value);
                        const selectedCategory = categoryFilter.value;
                        const selectedBrand = brandFilter.value;
                        const selectedStatus = statusFilter.value.toUpperCase();
                        let visibleCount = 0;

                        productRows.forEach(function (row) {
                            const productId = row.dataset.productId || "";
                            const categoryId = row.dataset.categoryId || "";
                            const brandId = row.dataset.brandId || "";
                            const status = (row.dataset.status || "").toUpperCase();
                            const productNameCell = row.querySelector(".product-name-cell");
                            const productName = productNameCell ? productNameCell.textContent : "";
                            const categoryName = getOptionLabel(categoryFilter, categoryId);
                            const brandName = getOptionLabel(brandFilter, brandId);
                            const searchableText = normalizeSearchValue([
                                productId,
                                "#PROD-" + productId,
                                productName,
                                categoryId,
                                categoryName,
                                brandId,
                                brandName,
                                status
                            ].join(" "));

                            const visible = (!keyword || searchableText.includes(keyword))
                                    && (!selectedCategory || categoryId === selectedCategory)
                                    && (!selectedBrand || brandId === selectedBrand)
                                    && (!selectedStatus || status === selectedStatus);

                            row.classList.toggle("d-none", !visible);
                            if (visible) {
                                visibleCount++;
                            }
                        });

                        if (resultSummary) {
                            resultSummary.textContent = "Showing " + visibleCount + " of " + productRows.length
                                    + (productRows.length === 1 ? " product" : " products");
                        }

                        if (noResultsRow) {
                            noResultsRow.classList.toggle("d-none", visibleCount > 0 || productRows.length === 0);
                        }

                        if (clearSearchButton) {
                            clearSearchButton.disabled = searchInput.value.length === 0;
                        }
                    }

                    function resetProductFilters() {
                        searchInput.value = "";
                        categoryFilter.value = "";
                        brandFilter.value = "";
                        statusFilter.value = "";
                        applyProductFilters();
                        searchInput.focus();
                    }

                    searchInput.addEventListener("input", applyProductFilters);
                    categoryFilter.addEventListener("change", applyProductFilters);
                    brandFilter.addEventListener("change", applyProductFilters);
                    statusFilter.addEventListener("change", applyProductFilters);
                    resetFiltersButton.addEventListener("click", resetProductFilters);

                    if (clearSearchButton) {
                        clearSearchButton.addEventListener("click", function () {
                            searchInput.value = "";
                            applyProductFilters();
                            searchInput.focus();
                        });
                    }

                    applyProductFilters();
                }

                function initCreateProductForm() {
                    const form = document.getElementById("createProductForm");
                    const productNameInput = document.getElementById("adminProductName");
                    const sizeInput = document.getElementById("adminVariantSize");
                    const colorInput = document.getElementById("adminVariantColor");
                    const addButton = document.getElementById("adminAddVariantButton");
                    const tableBody = document.getElementById("adminVariantListBody");
                    const countLabel = document.getElementById("adminVariantCount");
                    const createModal = document.getElementById("createProductModal");

                    if (!form || !productNameInput || !sizeInput || !colorInput
                            || !addButton || !tableBody || !countLabel || !createModal) {
                        console.warn("Create Product form was not initialized because one or more controls are missing.");
                        return;
                    }

                    const variants = [];

                    function cleanText(value) {
                        return value == null ? "" : value.trim().replace(/\s+/g, " ");
                    }

                    function removeVietnameseTones(value) {
                        return value
                                .normalize("NFD")
                                .replace(/[\u0300-\u036f]/g, "")
                                .replace(/đ/g, "d")
                                .replace(/Đ/g, "D");
                    }

                    function normalizeSku(value) {
                        const normalized = removeVietnameseTones(cleanText(value))
                                .toLowerCase()
                                .replace(/[^a-z0-9]+/g, "-")
                                .replace(/^-+|-+$/g, "");
                        return normalized || "na";
                    }

                    function normalizeCombinationValue(value) {
                        return removeVietnameseTones(cleanText(value)).toLowerCase();
                    }

                    function getCombinationKey(size, color) {
                        return normalizeCombinationValue(size) + "|" + normalizeCombinationValue(color);
                    }

                    function getVariantSku(variant) {
                        return normalizeSku(productNameInput.value)
                                + "-" + normalizeSku(variant.size)
                                + "-" + normalizeSku(variant.color);
                    }

                    function escapeHtml(value) {
                        return String(value)
                                .replace(/&/g, "&amp;")
                                .replace(/</g, "&lt;")
                                .replace(/>/g, "&gt;")
                                .replace(/"/g, "&quot;")
                                .replace(/'/g, "&#039;");
                    }

                    function renderVariants() {
                        countLabel.textContent = variants.length
                                + (variants.length === 1 ? " variant" : " variants");

                        if (variants.length === 0) {
                            tableBody.innerHTML = "<tr>"
                                    + "<td colspan='3' class='text-center py-4 text-muted'>"
                                    + "<i class='fa-solid fa-circle-info me-1'></i>No variants added yet."
                                    + "</td></tr>";
                            return;
                        }

                        let rows = "";
                        variants.forEach(function (variant, index) {
                            rows += "<tr>"
                                    + "<td>"
                                    + "<span class='badge bg-dark me-1'>Size: " + escapeHtml(variant.size) + "</span> "
                                    + "<span class='badge bg-primary'>Color: " + escapeHtml(variant.color) + "</span>"
                                    + "<input type='hidden' name='variants[" + index + "].size' value='" + escapeHtml(variant.size) + "'>"
                                    + "<input type='hidden' name='variants[" + index + "].color' value='" + escapeHtml(variant.color) + "'>"
                                    + "</td>"
                                    + "<td><input type='text' class='form-control form-control-sm bg-light fw-semibold' value='"
                                    + escapeHtml(getVariantSku(variant)) + "' readonly></td>"
                                    + "<td class='text-center'>"
                                    + "<button type='button' class='btn btn-sm btn-outline-danger' data-remove-index='" + index + "' title='Remove variant'>"
                                    + "<i class='fa-solid fa-trash'></i></button>"
                                    + "</td></tr>";
                        });
                        tableBody.innerHTML = rows;
                    }

                    function addVariant() {
                        const productName = cleanText(productNameInput.value);
                        const size = cleanText(sizeInput.value);
                        const color = cleanText(colorInput.value);

                        if (!productName) {
                            showToast("Please enter the product name before adding variants.", "warning", "Product name required");
                            productNameInput.focus();
                            return;
                        }

                        if (!size || !color) {
                            showToast("Please select a size and enter a color.", "warning", "Incomplete variant");
                            return;
                        }

                        const combinationKey = getCombinationKey(size, color);
                        const duplicated = variants.some(function (variant) {
                            return getCombinationKey(variant.size, variant.color) === combinationKey;
                        });

                        if (duplicated) {
                            showToast("This size and color combination is already in the list.", "warning", "Duplicate variant");
                            return;
                        }

                        variants.push({size: size, color: color});
                        sizeInput.value = "";
                        colorInput.value = "";
                        colorInput.focus();
                        renderVariants();
                    }

                    addButton.addEventListener("click", addVariant);
                    colorInput.addEventListener("keydown", function (event) {
                        if (event.key === "Enter") {
                            event.preventDefault();
                            addVariant();
                        }
                    });
                    productNameInput.addEventListener("input", renderVariants);
                    tableBody.addEventListener("click", function (event) {
                        const removeButton = event.target.closest("[data-remove-index]");
                        if (!removeButton) {
                            return;
                        }
                        variants.splice(Number(removeButton.dataset.removeIndex), 1);
                        renderVariants();
                    });

                    form.addEventListener("submit", function (event) {
                        event.preventDefault();

                        const normalizedName = cleanText(productNameInput.value).toLowerCase();
                        const duplicatedName = Array.from(document.querySelectorAll(".product-name-cell")).some(function (cell) {
                            return cleanText(cell.textContent).toLowerCase() === normalizedName;
                        });

                        if (duplicatedName) {
                            showToast("A product with this name already exists.", "warning", "Duplicate product name");
                            productNameInput.focus();
                            return;
                        }

                        if (variants.length === 0) {
                            showToast("Please add at least one size-color variant.", "warning", "Variant required");
                            return;
                        }

                        if (typeof window.confirmAppAction !== "function") {
                            if (window.confirm("Do you want to save this new product information?")) {
                                form.submit();
                            }
                            return;
                        }

                        window.confirmAppAction("Do you want to save this new product information?", {
                            title: "Save product",
                            confirmLabel: "Save product"
                        }).then(function (confirmed) {
                            if (confirmed) {
                                form.submit();
                            }
                        });
                    });

                    createModal.addEventListener("hidden.bs.modal", function () {
                        form.reset();
                        variants.splice(0, variants.length);
                        renderVariants();
                    });

                    renderVariants();
                }

                function renderFeaturedState(toggle, hiddenValue, switchWrap, toggleText, productRow, featured) {
                    toggle.checked = featured;
                    hiddenValue.value = featured ? "true" : "false";
                    switchWrap.classList.toggle("is-active", featured);
                    toggleText.textContent = featured ? "Featured" : "Not featured";
                    if (productRow) {
                        productRow.dataset.featured = featured ? "true" : "false";
                    }
                }

                function initFeaturedControls() {
                    document.querySelectorAll(".featured-control-form").forEach(function (form) {
                        const toggle = form.querySelector(".featured-toggle");
                        const hiddenValue = form.querySelector(".featured-hidden-value");
                        const switchWrap = form.querySelector(".featured-switch-wrap");
                        const toggleText = form.querySelector(".featured-toggle-text");
                        const productIdInput = form.querySelector("input[name='productId']");
                        const productRow = form.closest(".product-row");
                        const submitUrl = form.dataset.submitUrl || form.getAttribute("action");
                        const permanentlyDisabled = toggle ? toggle.disabled : false;

                        if (!toggle || !hiddenValue || !switchWrap || !toggleText || !productIdInput || !submitUrl) {
                            console.warn("A Featured Product control was skipped because required data is missing.", form);
                            return;
                        }

                        form.addEventListener("submit", function (event) {
                            event.preventDefault();
                        });

                        toggle.addEventListener("change", async function () {
                            if (toggle.dataset.saving === "true") {
                                return;
                            }

                            const oldFeaturedState = hiddenValue.value === "true";
                            const requestedFeaturedState = toggle.checked;
                            const requestBody = new URLSearchParams();
                            requestBody.set("action", "UPDATE_FEATURED");
                            requestBody.set("productId", productIdInput.value);
                            requestBody.set("featured", requestedFeaturedState ? "true" : "false");

                            toggle.dataset.saving = "true";
                            hiddenValue.value = requestedFeaturedState ? "true" : "false";
                            switchWrap.classList.toggle("is-active", requestedFeaturedState);
                            switchWrap.classList.add("is-saving");
                            toggleText.textContent = "Saving...";
                            toggle.disabled = true;

                            try {
                                const response = await fetch(submitUrl, {
                                    method: "POST",
                                    headers: {
                                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                                        "X-Requested-With": "XMLHttpRequest",
                                        "Accept": "application/json"
                                    },
                                    body: requestBody.toString(),
                                    credentials: "same-origin",
                                    redirect: "follow"
                                });

                                const responseText = await response.text();
                                let result = null;

                                try {
                                    result = responseText ? JSON.parse(responseText) : null;
                                } catch (parseError) {
                                    if (response.redirected || /<html[\s>]/i.test(responseText)) {
                                        throw new Error("session-expired");
                                    }
                                    console.error("Featured Product returned a non-JSON response:", responseText);
                                    throw new Error("server-error");
                                }

                                if (!response.ok || !result || result.success !== true) {
                                    throw new Error(result && result.error ? result.error : "featured-update-failed");
                                }

                                renderFeaturedState(
                                        toggle,
                                        hiddenValue,
                                        switchWrap,
                                        toggleText,
                                        productRow,
                                        result.featured === true
                                        );
                            } catch (error) {
                                renderFeaturedState(toggle, hiddenValue, switchWrap, toggleText, productRow, oldFeaturedState);
                                const errorCode = error && error.message ? error.message : "featured-update-failed";
                                showStatusMessage(errorCode);
                                console.error("Could not update Featured Product:", error);
                            } finally {
                                switchWrap.classList.remove("is-saving");
                                toggle.dataset.saving = "false";
                                toggle.disabled = permanentlyDisabled;
                            }
                        });
                    });
                }

                function showMessageFromQueryString() {
                    const status = new URLSearchParams(window.location.search).get("status");
                    if (status && statusMessages[status]) {
                        showStatusMessage(status);
                    }
                }

                document.addEventListener("DOMContentLoaded", function () {
                    initProductFilters();
                    initCreateProductForm();
                    initFeaturedControls();
                    showMessageFromQueryString();
                });

                window.deleteProduct = function (id) {
                    const deleteProductId = document.getElementById("hiddenDeleteProductId");
                    const deleteForm = document.getElementById("hiddenDeleteForm");
                    if (!deleteProductId || !deleteForm) {
                        showToast("The delete form is unavailable.", "error", "Delete failed");
                        return;
                    }

                    function submitDelete() {
                        deleteProductId.value = id;
                        deleteForm.submit();
                    }

                    if (typeof window.confirmAppAction !== "function") {
                        if (window.confirm("Delete this product?")) {
                            submitDelete();
                        }
                        return;
                    }

                    window.confirmAppAction("The product will be soft-deleted and its variants will become inactive.", {
                        title: "Delete this product?",
                        confirmLabel: "Delete product",
                        danger: true
                    }).then(function (confirmed) {
                        if (confirmed) {
                            submitDelete();
                        }
                    });
                };
            })();
        </script>
    </body>
</html>
