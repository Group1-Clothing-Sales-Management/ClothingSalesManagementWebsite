<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Category Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        .category-page {
            font-size: 0.95rem;
        }

        .category-page .page-subtitle {
            margin-top: 6px;
            margin-bottom: 0;
        }

        .category-summary-card {
            height: 100%;
            padding: 18px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            box-shadow: 0 2px 12px rgba(15, 23, 42, 0.05);
        }

        .category-summary-label {
            margin-bottom: 6px;
            color: #6b7280;
            font-size: 0.78rem;
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
            font-size: 1.05rem;
        }

        .category-toolbar {
            padding: 18px 20px;
            border-bottom: 1px solid #eef2f7;
            background: #ffffff;
        }

        .category-toolbar .input-group-text {
            background: #ffffff;
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
            padding: 14px 16px;
            font-size: 0.9rem;
        }

        .category-name {
            color: #111827;
            font-weight: 700;
        }

        .category-slug {
            display: inline-block;
            max-width: 320px;
            padding: 5px 9px;
            overflow: hidden;
            color: #1d4ed8;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            font-size: 0.82rem;
            text-overflow: ellipsis;
            vertical-align: middle;
            white-space: nowrap;
        }

        .category-row-inactive td {
            background: #fafafa;
            color: #6b7280;
        }

        .category-row-inactive .category-name {
            color: #6b7280;
        }

        .category-count {
            min-width: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 5px 9px;
            color: #374151;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .category-actions {
            display: inline-flex;
            justify-content: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .category-actions .btn {
            min-width: 92px;
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

        @media (max-width: 767.98px) {
            .category-actions .btn {
                min-width: auto;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="categories" />
</jsp:include>

<div class="container-fluid admin-page category-page">
    <div class="page-header">
        <div>
            <h1 class="page-title">
                <i class="fa-solid fa-tags"></i>Category Management
            </h1>
            <p class="page-subtitle">
                Create, update, deactivate and restore product categories.
            </p>
        </div>

        <button type="button" class="btn btn-primary" data-bs-toggle="modal"
                data-bs-target="#categoryModal" onclick="prepareAddCategory()">
            <i class="fa-solid fa-plus me-2"></i>Add Category
        </button>
    </div>

    <c:choose>
        <c:when test="${param.status == 'created'}">
            <div class="d-none" data-admin-toast data-admin-toast-type="success">
                Category created successfully.
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
                This category name already exists. Restore the inactive category instead of creating a duplicate.
            </div>
        </c:when>
        <c:when test="${param.status == 'duplicate-slug'}">
            <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                The generated slug is already used by another category.
            </div>
        </c:when>
        <c:when test="${param.status == 'in-use'}">
            <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                This category cannot be deactivated because it still contains active products.
            </div>
        </c:when>
        <c:when test="${param.status == 'invalid'}">
            <div class="d-none" data-admin-toast data-admin-toast-type="warning">
                Category name is required and must not exceed 100 characters.
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
        <div class="col-md-4">
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

        <div class="col-md-4">
            <div class="category-summary-card d-flex align-items-center justify-content-between">
                <div>
                    <div class="category-summary-label">Active Categories</div>
                    <p class="category-summary-value">${activeCategoryCount}</p>
                </div>
                <span class="category-summary-icon">
                    <i class="fa-solid fa-circle-check"></i>
                </span>
            </div>
        </div>

        <div class="col-md-4">
            <div class="category-summary-card d-flex align-items-center justify-content-between">
                <div>
                    <div class="category-summary-label">Inactive Categories</div>
                    <p class="category-summary-value">${inactiveCategoryCount}</p>
                </div>
                <span class="category-summary-icon">
                    <i class="fa-solid fa-circle-pause"></i>
                </span>
            </div>
        </div>
    </div>

    <div class="card card-main admin-card">
        <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div>
                <h2 class="h6 fw-bold mb-1">Category List</h2>
                <p class="text-muted small mb-0">
                    Inactive categories remain available for restoration and data consistency.
                </p>
            </div>
            <span class="text-muted small" id="visibleCategoryCount">
                ${totalCategoryCount} categories
            </span>
        </div>

        <div class="category-toolbar">
            <div class="row g-3">
                <div class="col-lg-8">
                    <div class="input-group">
                        <span class="input-group-text">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </span>
                        <input type="search" id="categorySearch" class="form-control"
                               placeholder="Search by category name or slug">
                    </div>
                </div>

                <div class="col-lg-4">
                    <select id="categoryStatusFilter" class="form-select">
                        <option value="all">All Statuses</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 admin-table">
                    <thead>
                        <tr>
                            <th class="text-center" style="width: 8%;">ID</th>
                            <th style="width: 28%;">Category</th>
                            <th style="width: 27%;">Slug</th>
                            <th class="text-center" style="width: 13%;">Active Products</th>
                            <th class="text-center" style="width: 10%;">Status</th>
                            <th class="text-center" style="width: 14%;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="categoryTableBody">
                        <c:forEach var="cat" items="${categories}">
                            <tr class="category-data-row ${cat.status == 0 ? 'category-row-inactive' : ''}"
                                data-name="<c:out value='${fn:toLowerCase(cat.categoryName)}' />"
                                data-slug="<c:out value='${fn:toLowerCase(cat.slug)}' />"
                                data-status="${cat.status == 1 ? 'active' : 'inactive'}">
                                <td class="text-center text-muted fw-semibold">${cat.id}</td>
                                <td>
                                    <span class="category-name">
                                        <c:out value="${cat.categoryName}" />
                                    </span>
                                </td>
                                <td>
                                    <span class="category-slug" title="<c:out value='${cat.slug}' />">
                                        <c:out value="${cat.slug}" />
                                    </span>
                                </td>
                                <td class="text-center">
                                    <span class="category-count">${cat.productCount}</span>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${cat.status == 1}">
                                            <span class="admin-pill admin-pill--success">
                                                <i class="fa-solid fa-circle-check"></i>Active
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="admin-pill admin-pill--danger">
                                                <i class="fa-solid fa-circle-pause"></i>Inactive
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <div class="category-actions">
                                        <button type="button" class="btn btn-sm btn-outline-primary"
                                                data-bs-toggle="modal" data-bs-target="#categoryModal"
                                                data-id="${cat.id}"
                                                data-name="<c:out value='${cat.categoryName}' />"
                                                data-slug="<c:out value='${cat.slug}' />"
                                                onclick="prepareEditCategory(this)">
                                            <i class="fa-solid fa-pen me-1"></i>Edit
                                        </button>

                                        <c:choose>
                                            <c:when test="${cat.status == 1}">
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-danger"
                                                        ${cat.productCount > 0 ? 'disabled' : ''}
                                                        title="${cat.productCount > 0 ? 'Move or deactivate active products before deactivating this category.' : 'Deactivate category'}"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#statusConfirmModal"
                                                        data-action="DEACTIVATE"
                                                        data-id="${cat.id}"
                                                        data-name="<c:out value='${cat.categoryName}' />"
                                                        onclick="prepareStatusAction(this)">
                                                    <i class="fa-solid fa-ban me-1"></i>Deactivate
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn btn-sm btn-outline-success"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#statusConfirmModal"
                                                        data-action="RESTORE"
                                                        data-id="${cat.id}"
                                                        data-name="<c:out value='${cat.categoryName}' />"
                                                        onclick="prepareStatusAction(this)">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Restore
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <tr id="noCategoryResultRow" class="d-none">
                            <td colspan="6">
                                <div class="admin-empty-state">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <div class="fw-semibold text-dark mb-1">No categories found</div>
                                    <div>Try another keyword or status filter.</div>
                                </div>
                            </td>
                        </tr>

                        <c:if test="${empty categories}">
                            <tr>
                                <td colspan="6">
                                    <div class="admin-empty-state">
                                        <i class="fa-solid fa-tags"></i>
                                        <div class="fw-semibold text-dark mb-1">No categories available</div>
                                        <div>Create the first category to start organizing products.</div>
                                    </div>
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

<div class="modal fade category-page" id="categoryModal" tabindex="-1"
     aria-labelledby="categoryModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form action="${pageContext.request.contextPath}/admin/manage-category" method="post"
                  id="categoryForm">
                <input type="hidden" name="action" id="categoryAction" value="ADD">
                <input type="hidden" name="categoryId" id="categoryId">

                <div class="modal-header">
                    <h2 class="modal-title" id="categoryModalLabel">
                        <i class="fa-solid fa-tag me-2 text-primary"></i>
                        <span id="categoryModalTitle">Add Category</span>
                    </h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="categoryName" class="form-label">
                            Category Name <span class="text-danger">*</span>
                        </label>
                        <input type="text" name="categoryName" id="categoryName"
                               class="form-control" maxlength="100" required
                               placeholder="e.g. Sports Pants">
                        <div class="form-text">
                            Use a clear and unique name that customers can understand.
                        </div>
                    </div>

                    <div>
                        <label for="categorySlug" class="form-label">Generated Slug</label>
                        <input type="text" id="categorySlug" class="form-control bg-light" readonly
                               placeholder="sports-pants">
                        <div class="form-text">
                            The slug is generated automatically and validated again by the server.
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary" id="categorySubmitButton">
                        <i class="fa-solid fa-floppy-disk me-2"></i>Save Category
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade category-page" id="statusConfirmModal" tabindex="-1"
     aria-labelledby="statusConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow">
            <form action="${pageContext.request.contextPath}/admin/manage-category" method="post">
                <input type="hidden" name="action" id="statusAction">
                <input type="hidden" name="categoryId" id="statusCategoryId">

                <div class="modal-header">
                    <h2 class="modal-title" id="statusConfirmModalLabel">Confirm Action</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <p class="mb-0" id="statusConfirmMessage"></p>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="submit" class="btn" id="statusConfirmButton">
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
    const categoryModalTitle = document.getElementById('categoryModalTitle');
    const categorySubmitButton = document.getElementById('categorySubmitButton');

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

    function prepareAddCategory() {
        categoryAction.value = 'ADD';
        categoryId.value = '';
        categoryName.value = '';
        categorySlug.value = '';
        categoryModalTitle.textContent = 'Add Category';
        categorySubmitButton.innerHTML = '<i class="fa-solid fa-floppy-disk me-2"></i>Save Category';
    }

    function prepareEditCategory(button) {
        categoryAction.value = 'UPDATE';
        categoryId.value = button.dataset.id;
        categoryName.value = button.dataset.name;
        categorySlug.value = button.dataset.slug;
        categoryModalTitle.textContent = 'Edit Category';
        categorySubmitButton.innerHTML = '<i class="fa-solid fa-floppy-disk me-2"></i>Update Category';
    }

    categoryName.addEventListener('input', function () {
        categorySlug.value = generateSlug(this.value);
    });

    const statusAction = document.getElementById('statusAction');
    const statusCategoryId = document.getElementById('statusCategoryId');
    const statusConfirmModalLabel = document.getElementById('statusConfirmModalLabel');
    const statusConfirmMessage = document.getElementById('statusConfirmMessage');
    const statusConfirmButton = document.getElementById('statusConfirmButton');

    function prepareStatusAction(button) {
        const action = button.dataset.action;
        const name = button.dataset.name;

        statusAction.value = action;
        statusCategoryId.value = button.dataset.id;

        if (action === 'DEACTIVATE') {
            statusConfirmModalLabel.textContent = 'Deactivate Category';
            statusConfirmMessage.textContent = 'Deactivate "' + name + '"? The category will be hidden from active category selections.';
            statusConfirmButton.className = 'btn btn-danger';
            statusConfirmButton.innerHTML = '<i class="fa-solid fa-ban me-2"></i>Deactivate';
        } else {
            statusConfirmModalLabel.textContent = 'Restore Category';
            statusConfirmMessage.textContent = 'Restore "' + name + '" and make it available again?';
            statusConfirmButton.className = 'btn btn-success';
            statusConfirmButton.innerHTML = '<i class="fa-solid fa-rotate-left me-2"></i>Restore';
        }
    }

    const categorySearch = document.getElementById('categorySearch');
    const categoryStatusFilter = document.getElementById('categoryStatusFilter');
    const categoryRows = Array.from(document.querySelectorAll('.category-data-row'));
    const noCategoryResultRow = document.getElementById('noCategoryResultRow');
    const visibleCategoryCount = document.getElementById('visibleCategoryCount');

    function filterCategories() {
        const keyword = categorySearch.value.trim().toLowerCase();
        const selectedStatus = categoryStatusFilter.value;
        let visibleCount = 0;

        categoryRows.forEach(function (row) {
            const matchesKeyword = row.dataset.name.includes(keyword)
                    || row.dataset.slug.includes(keyword);
            const matchesStatus = selectedStatus === 'all'
                    || row.dataset.status === selectedStatus;
            const visible = matchesKeyword && matchesStatus;

            row.classList.toggle('d-none', !visible);
            if (visible) {
                visibleCount++;
            }
        });

        if (noCategoryResultRow) {
            noCategoryResultRow.classList.toggle('d-none', visibleCount > 0 || categoryRows.length === 0);
        }

        visibleCategoryCount.textContent = visibleCount
                + (visibleCount === 1 ? ' category' : ' categories');
    }

    categorySearch.addEventListener('input', filterCategories);
    categoryStatusFilter.addEventListener('change', filterCategories);
</script>

</body>
</html>