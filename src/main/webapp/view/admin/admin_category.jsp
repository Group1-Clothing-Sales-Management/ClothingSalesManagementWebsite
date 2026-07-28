
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Category Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
          rel="stylesheet">

    <style>
        .category-page {
            font-size: 0.95rem;
        }

        .category-summary-card {
            height: 100%;
            padding: 18px;
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            box-shadow: 0 2px 12px rgba(15, 23, 42, 0.05);
        }

        .category-summary-label {
            margin-bottom: 6px;
            color: #6b7280;
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .category-summary-value {
            margin: 0;
            color: #111827;
            font-size: 1.5rem;
            font-weight: 800;
            line-height: 1;
        }

        .category-summary-icon {
            width: 42px;
            height: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            background: #eff6ff;
            color: #2563eb;
        }

        .category-toolbar {
            padding: 18px 20px;
            border-bottom: 1px solid #eef2f7;
            background: #fff;
        }

        .category-filter-grid {
            display: grid;
            grid-template-columns: minmax(280px, 1fr) 220px;
            gap: 12px;
        }

        .category-toolbar .input-group-text {
            background: #fff;
            border-right: 0;
            color: #6b7280;
        }

        .category-toolbar .form-control {
            border-left: 0;
        }

        .category-toolbar .form-control:focus {
            box-shadow: none;
            border-color: #dee2e6;
        }

        .category-page .table th,
        .category-page .table td {
            padding: 14px 18px;
            font-size: 0.88rem;
            vertical-align: middle;
        }

        .category-parent-row {
            background: #f8fafc;
        }

        .category-parent-row[data-has-children="true"] {
            cursor: pointer;
        }

        .category-parent-row[data-has-children="true"]:hover td {
            background: #f1f5f9;
        }

        .category-parent-row.is-expanded td {
            background: #eff6ff;
            border-bottom-color: #dbeafe;
        }

        .category-child-row td {
            background: #fff;
        }

        .category-child-row:hover td {
            background: #fafcff;
        }

        .category-row-inactive td {
            color: #6b7280;
            background: #fafafa;
        }

        .category-row-inactive .category-name {
            color: #6b7280;
        }

        .category-entry {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 260px;
        }

        .category-toggle,
        .category-toggle-spacer {
            width: 34px;
            min-width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 9px;
        }

        .category-toggle {
            color: #2563eb;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            transition: transform 0.18s ease,
                        background 0.18s ease;
        }

        .category-toggle:hover {
            background: #dbeafe;
        }

        .category-toggle i {
            transition: transform 0.18s ease;
        }

        .category-parent-row.is-expanded .category-toggle i {
            transform: rotate(90deg);
        }

        .category-root-icon {
            width: 34px;
            min-width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #7c3aed;
            background: #f5f3ff;
            border: 1px solid #ddd6fe;
            border-radius: 9px;
        }

        .category-name {
            display: block;
            color: #111827;
            font-weight: 750;
            line-height: 1.3;
        }

        .category-meta {
            margin-top: 3px;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 500;
        }

        .category-child-entry {
            display: flex;
            align-items: center;
            gap: 10px;
            padding-left: 46px;
            min-width: 260px;
        }

        .category-child-connector {
            width: 18px;
            color: #94a3b8;
            font-size: 1rem;
            text-align: center;
        }

        .category-child-icon {
            width: 30px;
            min-width: 30px;
            height: 30px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #0284c7;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 8px;
        }

        .category-slug {
            display: inline-block;
            max-width: 260px;
            padding: 6px 10px;
            overflow: hidden;
            color: #1d4ed8;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            font-size: 0.8rem;
            text-overflow: ellipsis;
            vertical-align: middle;
            white-space: nowrap;
        }

        .category-count {
            min-width: 46px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 11px;
            color: #334155;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 999px;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .category-parent-row .category-count {
            color: #1d4ed8;
            background: #eff6ff;
            border-color: #bfdbfe;
        }

        .category-status-badge {
            width: 112px;
            min-width: 112px;
            height: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 0 12px;
        }

        .category-actions {
            display: inline-grid;
            grid-template-columns: repeat(2, 118px);
            justify-content: center;
            gap: 8px;
        }

        .category-actions .btn {
            width: 118px;
            min-width: 118px;
            height: 40px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            white-space: nowrap;
        }

        .category-page .modal-title {
            font-size: 1rem;
            font-weight: 700;
        }

        .category-page .form-label {
            margin-bottom: 7px;
            color: #374151;
            font-size: 0.88rem;
            font-weight: 700;
        }

        .category-page .form-text {
            font-size: 0.8rem;
        }

        .category-page .modal-footer .btn {
            min-width: 110px;
        }

        @media (max-width: 991.98px) {
            .category-filter-grid {
                grid-template-columns: 1fr;
            }

            .category-child-entry {
                padding-left: 28px;
            }
        }

        @media (max-width: 767.98px) {
            .category-actions {
                grid-template-columns: 112px;
            }

            .category-actions .btn {
                width: 112px;
                min-width: 112px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="categories"/>
</jsp:include>

<div class="admin-page category-page">
    <div class="container-fluid">

        <div class="page-header">
            <jsp:include page="/view/admin/common/page_heading.jsp">
                <jsp:param name="icon" value="fa-solid fa-tags"/>
                <jsp:param name="title" value="Category Management"/>
                <jsp:param name="subtitle"
                           value="Manage parent categories and subcategories used by the customer navigation."/>
            </jsp:include>

            <button type="button"
                    class="btn btn-primary"
                    data-bs-toggle="modal"
                    data-bs-target="#categoryModal"
                    onclick="prepareAddCategory()">
                <i class="fa-solid fa-plus me-2"></i>Add Category
            </button>
        </div>

        <c:choose>
            <c:when test="${param.status == 'created'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success">
                    Category created successfully. It is now available on the customer header.
                </div>
            </c:when>
            <c:when test="${param.status == 'updated'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success">
                    Category updated successfully.
                </div>
            </c:when>
            <c:when test="${param.status == 'deactivated'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success">
                    Category deactivated successfully.
                </div>
            </c:when>
            <c:when test="${param.status == 'restored'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success">
                    Category restored successfully.
                </div>
            </c:when>
            <c:when test="${param.status == 'duplicate-name'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    This category name already exists.
                </div>
            </c:when>
            <c:when test="${param.status == 'duplicate-slug'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    The generated slug is already used by another category.
                </div>
            </c:when>
            <c:when test="${param.status == 'in-use'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    This category still contains active products and cannot be deactivated.
                </div>
            </c:when>
            <c:when test="${param.status == 'has-active-children'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    Deactivate all active subcategories before deactivating this parent category.
                </div>
            </c:when>
            <c:when test="${param.status == 'has-children'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    A category that already has subcategories cannot become a subcategory.
                </div>
            </c:when>
            <c:when test="${param.status == 'self-parent'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    A category cannot be its own parent.
                </div>
            </c:when>
            <c:when test="${param.status == 'invalid-parent'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    Only a root category can be selected as the parent.
                </div>
            </c:when>
            <c:when test="${param.status == 'parent-inactive'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    The selected parent category is inactive. Restore it first.
                </div>
            </c:when>
            <c:when test="${param.status == 'parent-not-found'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error">
                    The selected parent category no longer exists.
                </div>
            </c:when>
            <c:when test="${param.status == 'invalid'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                    Check the category name, parent category and description.
                </div>
            </c:when>
            <c:when test="${param.status == 'not-found'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error">
                    Category not found.
                </div>
            </c:when>
            <c:when test="${param.status == 'invalid-action'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error">
                    Invalid category action.
                </div>
            </c:when>
            <c:when test="${param.status == 'error'}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error">
                    The category action could not be completed. Please try again.
                </div>
            </c:when>
        </c:choose>

        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3">
                <div class="category-summary-card d-flex align-items-center justify-content-between">
                    <div>
                        <div class="category-summary-label">Total Categories</div>
                        <p class="category-summary-value">${totalCategoryCount}</p>
                    </div>
                    <span class="category-summary-icon">
                        <i class="fa-solid fa-layer-group"></i>
                    </span>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="category-summary-card d-flex align-items-center justify-content-between">
                    <div>
                        <div class="category-summary-label">Root Categories</div>
                        <p class="category-summary-value">${rootCategoryCount}</p>
                    </div>
                    <span class="category-summary-icon">
                        <i class="fa-solid fa-folder-tree"></i>
                    </span>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="category-summary-card d-flex align-items-center justify-content-between">
                    <div>
                        <div class="category-summary-label">Subcategories</div>
                        <p class="category-summary-value">${subcategoryCount}</p>
                    </div>
                    <span class="category-summary-icon">
                        <i class="fa-solid fa-code-branch"></i>
                    </span>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="category-summary-card d-flex align-items-center justify-content-between">
                    <div>
                        <div class="category-summary-label">Active / Inactive</div>
                        <p class="category-summary-value">
                            ${activeCategoryCount} / ${inactiveCategoryCount}
                        </p>
                    </div>
                    <span class="category-summary-icon">
                        <i class="fa-solid fa-toggle-on"></i>
                    </span>
                </div>
            </div>
        </div>

        <div class="card card-main admin-card">
            <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                <div>
                    <h2 class="h6 fw-bold mb-1">Category List</h2>
                    <p class="text-muted small mb-0">
                        The customer header displays active root categories and their active subcategories.
                    </p>
                </div>
                <span class="text-muted small" id="visibleCategoryCount">
                    ${totalCategoryCount} categories
                </span>
            </div>

            <div class="category-toolbar">
                <div class="category-filter-grid">
                    <div class="input-group">
                        <span class="input-group-text">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </span>
                        <input type="search"
                               id="categorySearch"
                               class="form-control"
                               placeholder="Search category or slug">
                    </div>

                    <select id="categoryStatusFilter" class="form-select">
                        <option value="all">All Statuses</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 admin-table">
                        <thead>
                            <tr>
                                <th style="min-width: 320px;">Category</th>
                                <th style="min-width: 210px;">Slug</th>
                                <th class="text-center" style="min-width: 150px;">
                                    Active Products
                                </th>
                                <th class="text-center" style="min-width: 130px;">
                                    Status
                                </th>
                                <th class="text-center" style="min-width: 270px;">
                                    Actions
                                </th>
                            </tr>
                        </thead>

                        <tbody id="categoryTableBody">
                            <c:forEach var="cat" items="${categories}">
                                <c:set var="parentName" value=""/>
                                <c:set var="childCount" value="0"/>

                                <c:forEach var="candidate" items="${categories}">
                                    <c:if test="${not empty cat.parentId
                                                  and candidate.id == cat.parentId}">
                                        <c:set var="parentName"
                                               value="${candidate.categoryName}"/>
                                    </c:if>

                                    <c:if test="${empty cat.parentId
                                                  and candidate.parentId == cat.id}">
                                        <c:set var="childCount"
                                               value="${childCount + 1}"/>
                                    </c:if>
                                </c:forEach>

                                <tr class="category-data-row
                                           ${empty cat.parentId
                                                ? 'category-parent-row'
                                                : 'category-child-row d-none'}
                                           ${cat.status == 0
                                                ? 'category-row-inactive'
                                                : ''}"
                                    data-category-id="${cat.id}"
                                    data-parent-id="${empty cat.parentId ? '' : cat.parentId}"
                                    data-has-children="${empty cat.parentId and childCount > 0}"
                                    data-name="<c:out value='${fn:toLowerCase(cat.categoryName)}'/>"
                                    data-duplicate-name="<c:out value='${cat.categoryName}'/>"
                                    data-parent-name="<c:out value='${fn:toLowerCase(parentName)}'/>"
                                    data-slug="<c:out value='${fn:toLowerCase(cat.slug)}'/>"
                                    data-status="${cat.status == 1 ? 'active' : 'inactive'}"
                                    role="${empty cat.parentId and childCount > 0
                                            ? 'button'
                                            : 'row'}"
                                    tabindex="${empty cat.parentId and childCount > 0
                                                ? '0'
                                                : '-1'}"
                                    aria-expanded="${empty cat.parentId and childCount > 0
                                                    ? 'false'
                                                    : ''}">

                                    <td>
                                        <c:choose>
                                            <c:when test="${empty cat.parentId}">
                                                <div class="category-entry">
                                                    <c:choose>
                                                        <c:when test="${childCount > 0}">
                                                            <button type="button"
                                                                    class="category-toggle"
                                                                    aria-label="Show subcategories"
                                                                    tabindex="-1">
                                                                <i class="fa-solid fa-chevron-right"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="category-toggle-spacer"></span>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <span class="category-root-icon">
                                                        <i class="fa-solid fa-folder"></i>
                                                    </span>

                                                    <span>
                                                        <span class="category-name">
                                                            <c:out value="${cat.categoryName}"/>
                                                        </span>

                                                        <c:choose>
                                                            <c:when test="${childCount > 0}">
                                                                <span class="category-meta">
                                                                    ${childCount}
                                                                    ${childCount == 1
                                                                        ? 'subcategory'
                                                                        : 'subcategories'}
                                                                    · Click to expand
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="category-meta">
                                                                    No subcategories
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </c:when>

                                            <c:otherwise>
                                                <div class="category-child-entry">
                                                    <span class="category-child-connector">└</span>
                                                    <span class="category-child-icon">
                                                        <i class="fa-solid fa-code-branch"></i>
                                                    </span>
                                                    <span>
                                                        <span class="category-name">
                                                            <c:out value="${cat.categoryName}"/>
                                                        </span>
                                                        <span class="category-meta">
                                                            Under
                                                            <c:out value="${parentName}"/>
                                                        </span>
                                                    </span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <span class="category-slug"
                                              title="<c:out value='${cat.slug}'/>">
                                            <c:out value="${cat.slug}"/>
                                        </span>
                                    </td>

                                    <td class="text-center">
                                        <span class="category-count"
                                              title="${empty cat.parentId
                                                        ? 'Total active products in this category and all direct subcategories'
                                                        : 'Active products in this subcategory'}">
                                            ${cat.productCount}
                                        </span>
                                    </td>

                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${cat.status == 1}">
                                                <span class="admin-pill admin-pill--success category-status-badge">
                                                    <i class="fa-solid fa-circle-check"></i>
                                                    Active
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="admin-pill admin-pill--danger category-status-badge">
                                                    <i class="fa-solid fa-circle-pause"></i>
                                                    Inactive
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="text-center">
                                        <div class="category-actions">
                                            <button type="button"
                                                    class="btn btn-sm btn-outline-primary"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#categoryModal"
                                                    data-id="${cat.id}"
                                                    data-name="<c:out value='${cat.categoryName}'/>"
                                                    data-slug="<c:out value='${cat.slug}'/>"
                                                    data-parent-id="${empty cat.parentId ? '' : cat.parentId}"
                                                    data-description="<c:out value='${cat.description}'/>"
                                                    onclick="prepareEditCategory(this)">
                                                <i class="fa-solid fa-pen me-1"></i>
                                                Edit
                                            </button>

                                            <c:choose>
                                                <c:when test="${cat.status == 1}">
                                                    <button type="button"
                                                            class="btn btn-sm btn-outline-danger"
                                                            ${cat.productCount > 0 ? 'disabled' : ''}
                                                            title="${cat.productCount > 0
                                                                    ? 'Move or deactivate active products first.'
                                                                    : 'Deactivate category'}"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#statusConfirmModal"
                                                            data-action="DEACTIVATE"
                                                            data-id="${cat.id}"
                                                            data-name="<c:out value='${cat.categoryName}'/>"
                                                            onclick="prepareStatusAction(this)">
                                                        <i class="fa-solid fa-ban me-1"></i>
                                                        Deactivate
                                                    </button>
                                                </c:when>

                                                <c:otherwise>
                                                    <button type="button"
                                                            class="btn btn-sm btn-outline-success"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#statusConfirmModal"
                                                            data-action="RESTORE"
                                                            data-id="${cat.id}"
                                                            data-name="<c:out value='${cat.categoryName}'/>"
                                                            onclick="prepareStatusAction(this)">
                                                        <i class="fa-solid fa-rotate-left me-1"></i>
                                                        Restore
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <tr id="noCategoryResultRow" class="d-none">
                                <td colspan="5">
                                    <div class="admin-empty-state">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <div class="fw-semibold text-dark mb-1">
                                            No categories found
                                        </div>
                                        <div>Try another keyword or status.</div>
                                    </div>
                                </td>
                            </tr>

                            <c:if test="${empty categories}">
                                <tr>
                                    <td colspan="5">
                                        <div class="admin-empty-state">
                                            <i class="fa-solid fa-tags"></i>
                                            <div class="fw-semibold text-dark mb-1">
                                                No categories available
                                            </div>
                                            <div>Create the first root category.</div>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

<div class="modal fade category-page"
     id="categoryModal"
     tabindex="-1"
     aria-labelledby="categoryModalLabel"
     aria-hidden="true"
     data-bs-backdrop="static">

    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow">
            <form action="${pageContext.request.contextPath}/admin/manage-category"
                  method="post"
                  id="categoryForm">

                <input type="hidden" name="action" id="categoryAction" value="ADD">
                <input type="hidden" name="categoryId" id="categoryId">

                <div class="modal-header">
                    <h2 class="modal-title" id="categoryModalLabel">
                        <i class="fa-solid fa-tag me-2 text-primary"></i>
                        <span id="categoryModalTitle">Add Category</span>
                    </h2>
                    <button type="button"
                            class="btn-close"
                            data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-7">
                            <label for="categoryName" class="form-label">
                                Category Name <span class="text-danger">*</span>
                            </label>
                            <input type="text"
                                   name="categoryName"
                                   id="categoryName"
                                   class="form-control"
                                   maxlength="100"
                                   required
                                   placeholder="e.g. Men's Jackets">
                            <div class="form-text">
                                Use a clear and unique customer-facing name.
                            </div>
                            <div id="categoryDuplicateFeedback"
                                 class="invalid-feedback">
                                A duplicate or equivalent category name already exists.
                            </div>
                        </div>

                        <div class="col-md-5">
                            <label for="parentCategoryId" class="form-label">
                                Parent Category
                            </label>
                            <select name="parentCategoryId"
                                    id="parentCategoryId"
                                    class="form-select">
                                <option value="">No Parent — Root Category</option>

                                <c:forEach var="parent" items="${parentCategories}">
                                    <option value="${parent.id}"
                                            data-status="${parent.status}"
                                            ${parent.status == 0 ? 'disabled' : ''}>
                                        <c:out value="${parent.categoryName}"/>
                                        ${parent.status == 0 ? ' (Inactive)' : ''}
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text">
                                Select a root category to create a subcategory.
                            </div>
                        </div>

                        <div class="col-12">
                            <label for="categorySlug" class="form-label">
                                Generated Slug
                            </label>
                            <input type="text"
                                   id="categorySlug"
                                   class="form-control bg-light"
                                   readonly
                                   placeholder="mens-jackets">
                        </div>

                        <div class="col-12">
                            <label for="categoryDescription" class="form-label">
                                Description
                            </label>
                            <textarea name="description"
                                      id="categoryDescription"
                                      class="form-control"
                                      rows="3"
                                      maxlength="500"
                                      placeholder="Optional category description"></textarea>
                            <div class="form-text">
                                Maximum 500 characters.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button"
                            class="btn btn-outline-secondary"
                            data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="submit"
                            class="btn btn-primary"
                            id="categorySubmitButton">
                        <i class="fa-solid fa-floppy-disk me-2"></i>Save Category
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade category-page"
     id="statusConfirmModal"
     tabindex="-1"
     aria-labelledby="statusConfirmModalLabel"
     aria-hidden="true">

    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow">
            <form action="${pageContext.request.contextPath}/admin/manage-category"
                  method="post">

                <input type="hidden" name="action" id="statusAction">
                <input type="hidden" name="categoryId" id="statusCategoryId">

                <div class="modal-header">
                    <h2 class="modal-title" id="statusConfirmModalLabel">
                        Confirm Action
                    </h2>
                    <button type="button"
                            class="btn-close"
                            data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <p class="mb-0" id="statusConfirmMessage"></p>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button"
                            class="btn btn-outline-secondary"
                            data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="submit"
                            class="btn"
                            id="statusConfirmButton">
                        Confirm
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const categoryAction = document.getElementById('categoryAction');
    const categoryId = document.getElementById('categoryId');
    const categoryName = document.getElementById('categoryName');
    const categorySlug = document.getElementById('categorySlug');
    const parentCategoryId = document.getElementById('parentCategoryId');
    const categoryDescription = document.getElementById('categoryDescription');
    const categoryModalTitle = document.getElementById('categoryModalTitle');
    const categorySubmitButton = document.getElementById('categorySubmitButton');
    const categoryForm = document.getElementById('categoryForm');

    function generateSlug(value) {
        return value
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '')
                .replace(/[đĐ]/g, 'd')
                .toLowerCase()
                .replace(/[^a-z0-9]+/g, '-')
                .replace(/^-+|-+$/g, '')
                .replace(/-+/g, '-');
    }

    function resetParentOptions(currentCategoryId) {
        Array.from(parentCategoryId.options).forEach(function (option) {
            if (!option.value) {
                option.disabled = false;
                return;
            }

            const isInactive = option.dataset.status === '0';
            const isCurrentCategory
                    = currentCategoryId
                    && option.value === String(currentCategoryId);

            option.disabled = isInactive || isCurrentCategory;
        });
    }

    function prepareAddCategory() {
        categoryAction.value = 'ADD';
        categoryId.value = '';
        categoryName.value = '';
        categoryName.classList.remove('is-invalid');
        categorySlug.value = '';
        categoryDescription.value = '';
        parentCategoryId.value = '';

        resetParentOptions(null);

        categoryModalTitle.textContent = 'Add Category';
        categorySubmitButton.innerHTML
                = '<i class="fa-solid fa-floppy-disk me-2"></i>Save Category';
    }

    function prepareEditCategory(button) {
        categoryAction.value = 'UPDATE';
        categoryId.value = button.dataset.id;
        categoryName.value = button.dataset.name || '';
        categoryName.classList.remove('is-invalid');
        categorySlug.value = button.dataset.slug || '';
        categoryDescription.value = button.dataset.description || '';

        resetParentOptions(button.dataset.id);
        parentCategoryId.value = button.dataset.parentId || '';

        categoryModalTitle.textContent = 'Edit Category';
        categorySubmitButton.innerHTML
                = '<i class="fa-solid fa-floppy-disk me-2"></i>Update Category';
    }

    categoryName.addEventListener('input', function () {
        categorySlug.value = generateSlug(this.value);
    });

    const categoryDuplicateFeedback
            = document.getElementById('categoryDuplicateFeedback');

    function generateDuplicateKey(value) {
        let key = (value || '')
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '')
                .replace(/[đĐ]/g, 'd')
                .toLowerCase()
                .replace(/['’`]/g, '')
                .replace(/[^a-z0-9]+/g, ' ')
                .trim()
                .replace(/\s+/g, ' ');

        key = key
                .replace(/\bmens\b/g, 'men')
                .replace(/\bwomens\b/g, 'women')
                .replace(/\bboys\b/g, 'boy')
                .replace(/\bgirls\b/g, 'girl');

        return key;
    }

    function findDuplicateCategoryName() {
        const candidateKey
                = generateDuplicateKey(categoryName.value);

        if (!candidateKey) {
            return null;
        }

        const currentId = categoryId.value;

        return Array.from(
                document.querySelectorAll('.category-data-row')
        ).find(function (row) {
            if (currentId
                    && row.dataset.categoryId === currentId) {
                return false;
            }

            return generateDuplicateKey(
                    row.dataset.duplicateName
            ) === candidateKey;
        }) || null;
    }

    function validateCategoryDuplicate() {
        const duplicateRow = findDuplicateCategoryName();
        const duplicated = duplicateRow !== null;

        categoryName.classList.toggle(
                'is-invalid',
                duplicated
        );

        if (duplicated) {
            const duplicateName
                    = duplicateRow.dataset.duplicateName;

            categoryDuplicateFeedback.textContent
                    = 'Duplicate category: "'
                    + duplicateName
                    + '" already exists.';
        } else {
            categoryDuplicateFeedback.textContent
                    = 'A duplicate or equivalent category name already exists.';
        }

        return !duplicated;
    }

    categoryName.addEventListener(
            'input',
            validateCategoryDuplicate
    );

    categoryForm.addEventListener('submit', function (event) {
        if (categoryId.value
                && parentCategoryId.value === categoryId.value) {
            event.preventDefault();
            window.alert('A category cannot be its own parent.');
            return;
        }

        if (!validateCategoryDuplicate()) {
            event.preventDefault();
            categoryName.focus();
        }
    });

    const statusAction = document.getElementById('statusAction');
    const statusCategoryId = document.getElementById('statusCategoryId');
    const statusConfirmModalLabel
            = document.getElementById('statusConfirmModalLabel');
    const statusConfirmMessage
            = document.getElementById('statusConfirmMessage');
    const statusConfirmButton
            = document.getElementById('statusConfirmButton');

    function prepareStatusAction(button) {
        const action = button.dataset.action;
        const name = button.dataset.name;

        statusAction.value = action;
        statusCategoryId.value = button.dataset.id;

        if (action === 'DEACTIVATE') {
            statusConfirmModalLabel.textContent = 'Deactivate Category';
            statusConfirmMessage.textContent
                    = 'Deactivate "' + name
                    + '"? It will be hidden from customer navigation.';
            statusConfirmButton.className = 'btn btn-danger';
            statusConfirmButton.innerHTML
                    = '<i class="fa-solid fa-ban me-2"></i>Deactivate';
        } else {
            statusConfirmModalLabel.textContent = 'Restore Category';
            statusConfirmMessage.textContent
                    = 'Restore "' + name
                    + '" and show it in active category selections?';
            statusConfirmButton.className = 'btn btn-success';
            statusConfirmButton.innerHTML
                    = '<i class="fa-solid fa-rotate-left me-2"></i>Restore';
        }
    }

    const categorySearch = document.getElementById('categorySearch');
    const categoryStatusFilter
            = document.getElementById('categoryStatusFilter');
    const categoryRows
            = Array.from(document.querySelectorAll('.category-data-row'));
    const parentRows
            = categoryRows.filter(function (row) {
                return !row.dataset.parentId;
            });
    const childRows
            = categoryRows.filter(function (row) {
                return Boolean(row.dataset.parentId);
            });
    const noCategoryResultRow
            = document.getElementById('noCategoryResultRow');
    const visibleCategoryCount
            = document.getElementById('visibleCategoryCount');

    const expandedParentIds = new Set();

    function isFilterActive() {
        return categorySearch.value.trim() !== ''
                || categoryStatusFilter.value !== 'all';
    }

    function matchesKeyword(row, keyword) {
        if (!keyword) {
            return true;
        }

        return row.dataset.name.includes(keyword)
                || row.dataset.slug.includes(keyword)
                || row.dataset.parentName.includes(keyword);
    }

    function matchesStatus(row, status) {
        return status === 'all'
                || row.dataset.status === status;
    }

    function childrenOf(parentId) {
        return childRows.filter(function (row) {
            return row.dataset.parentId === String(parentId);
        });
    }

    function updateParentVisualState(parentRow, expanded) {
        parentRow.classList.toggle('is-expanded', expanded);
        parentRow.setAttribute(
                'aria-expanded',
                expanded ? 'true' : 'false'
        );

        const toggleButton
                = parentRow.querySelector('.category-toggle');

        if (toggleButton) {
            toggleButton.setAttribute(
                    'aria-label',
                    expanded
                            ? 'Hide subcategories'
                            : 'Show subcategories'
            );
        }

        const meta = parentRow.querySelector('.category-meta');
        if (meta && parentRow.dataset.hasChildren === 'true') {
            const numberText = meta.textContent
                    .trim()
                    .split('·')[0]
                    .trim();

            meta.textContent = numberText
                    + (expanded
                            ? ' · Click to collapse'
                            : ' · Click to expand');
        }
    }

    function toggleParent(parentRow) {
        if (parentRow.dataset.hasChildren !== 'true') {
            return;
        }

        const parentId = parentRow.dataset.categoryId;

        if (expandedParentIds.has(parentId)) {
            expandedParentIds.delete(parentId);
        } else {
            expandedParentIds.add(parentId);
        }

        applyCategoryView();
    }

    function applyCategoryView() {
        const keyword = categorySearch.value
                .trim()
                .toLowerCase();

        const selectedStatus = categoryStatusFilter.value;
        const filterActive = isFilterActive();
        let visibleCount = 0;

        parentRows.forEach(function (parentRow) {
            const parentId = parentRow.dataset.categoryId;
            const relatedChildren = childrenOf(parentId);

            const parentKeywordMatch
                    = matchesKeyword(parentRow, keyword);
            const parentStatusMatch
                    = matchesStatus(parentRow, selectedStatus);

            const matchingChildren
                    = relatedChildren.filter(function (childRow) {
                        return matchesKeyword(childRow, keyword)
                                && matchesStatus(
                                        childRow,
                                        selectedStatus
                                );
                    });

            let showParent;
            let showChildren;

            if (filterActive) {
                showParent = (parentKeywordMatch
                                && parentStatusMatch)
                        || matchingChildren.length > 0;

                showChildren = showParent;
            } else {
                showParent = true;
                showChildren = expandedParentIds.has(parentId);
            }

            parentRow.classList.toggle('d-none', !showParent);

            if (showParent) {
                visibleCount++;
            }

            relatedChildren.forEach(function (childRow) {
                let showChild = false;

                if (filterActive) {
                    /*
                     * Nếu từ khóa khớp Category cha, hiển thị toàn bộ
                     * Subcategory phù hợp với bộ lọc trạng thái.
                     * Nếu từ khóa chỉ khớp Subcategory, chỉ hiển thị
                     * Subcategory tương ứng.
                     */
                    const childKeywordMatch
                            = matchesKeyword(childRow, keyword);

                    showChild = showChildren
                            && matchesStatus(
                                    childRow,
                                    selectedStatus
                            )
                            && (parentKeywordMatch
                                || childKeywordMatch);
                } else {
                    showChild = showChildren;
                }

                childRow.classList.toggle('d-none', !showChild);

                if (showChild) {
                    visibleCount++;
                }
            });

            updateParentVisualState(
                    parentRow,
                    filterActive
                            ? showParent
                              && relatedChildren.some(function (childRow) {
                                  return !childRow.classList
                                          .contains('d-none');
                              })
                            : expandedParentIds.has(parentId)
            );
        });

        /*
         * Phòng trường hợp dữ liệu cũ có Subcategory bị mất Parent.
         */
        childRows.forEach(function (childRow) {
            const parentExists = parentRows.some(function (parentRow) {
                return parentRow.dataset.categoryId
                        === childRow.dataset.parentId;
            });

            if (!parentExists) {
                const visible = matchesKeyword(childRow, keyword)
                        && matchesStatus(
                                childRow,
                                selectedStatus
                        );

                childRow.classList.toggle('d-none', !visible);

                if (visible) {
                    visibleCount++;
                }
            }
        });

        if (noCategoryResultRow) {
            noCategoryResultRow.classList.toggle(
                    'd-none',
                    visibleCount > 0 || categoryRows.length === 0
            );
        }

        visibleCategoryCount.textContent
                = visibleCount
                + (visibleCount === 1
                        ? ' category shown'
                        : ' categories shown');
    }

    parentRows.forEach(function (parentRow) {
        if (parentRow.dataset.hasChildren !== 'true') {
            return;
        }

        parentRow.addEventListener('click', function (event) {
            if (event.target.closest(
                    'button, a, form, input, select, textarea'
            )) {
                if (event.target.closest('.category-toggle')) {
                    toggleParent(parentRow);
                }
                return;
            }

            toggleParent(parentRow);
        });

        parentRow.addEventListener('keydown', function (event) {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                toggleParent(parentRow);
            }
        });
    });

    categorySearch.addEventListener('input', applyCategoryView);
    categoryStatusFilter.addEventListener('change', applyCategoryView);

    /*
     * Trạng thái ban đầu: chỉ hiển thị Category cha.
     */
    applyCategoryView();
</script>

</body>
</html>