<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Details - Admin Panel</title>

        <link rel="stylesheet"
              href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

        <style>
            #variantCard,
            #variantCard .card-body {
                overflow: visible !important;
                max-height: none !important;
            }

            .variant-table-wrapper {
                width: 100%;
                overflow-x: auto;
                overflow-y: visible;
            }

            .variant-status-control {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 8px;
                white-space: nowrap;
            }

            .variant-status-badge {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 82px;
                padding: 6px 12px;
                border-radius: 20px;
                color: #fff;
                font-size: 0.82rem;
                font-weight: 600;
            }

            .variant-status-active {
                background-color: #198754;
            }

            .variant-status-inactive {
                background-color: #dc3545;
            }

            .variant-status-action {
                min-width: 96px;
                border-radius: 20px;
                font-size: 0.82rem;
                font-weight: 600;
            }

            .variant-sku {
                color: #0d6efd;
                font-family: Consolas, Monaco, monospace;
                font-weight: 600;
            }

            .variant-note {
                padding: 10px 14px;
                border-left: 4px solid #0d6efd;
                background: #eef5ff;
                border-radius: 6px;
                color: #334155;
                font-size: 0.92rem;
            }

            .product-main-image-box {
                width: 100%;
                min-height: 220px;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                background-color: #f8f9fa;
            }

            .product-main-image {
                width: 100%;
                max-height: 320px;
                display: block;
                object-fit: contain;
            }

            .product-main-image-placeholder {
                width: 100%;
                min-height: 220px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: #6c757d;
                background-color: #f8f9fa;
            }

            .product-main-image-placeholder i {
                margin-bottom: 8px;
                font-size: 2.2rem;
            }

            .variant-image-box {
                width: 72px;
                height: 72px;
                margin: 0 auto;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                background: #f8f9fa;
            }

            .variant-image-box img {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }

            .variant-image-placeholder {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: #6c757d;
                font-size: 0.7rem;
                text-align: center;
            }

            .variant-image-placeholder i {
                margin-bottom: 4px;
                font-size: 1.35rem;
            }

            .variant-image-source {
                display: block;
                margin-top: 5px;
                color: #6c757d;
                font-size: 0.7rem;
                text-align: center;
                white-space: nowrap;
            }

            .variant-edit-row > td {
                padding: 0 !important;
                border-top: 0 !important;
                background: #f8fafc !important;
            }

            .variant-edit-panel {
                padding: 20px;
                border-top: 3px solid #0d6efd;
                border-bottom: 1px solid #dee2e6;
            }

            .variant-edit-title {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 16px;
            }

            .variant-edit-preview {
                width: 120px;
                height: 120px;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                background: #fff;
            }

            .variant-edit-preview img {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }

            .variant-edit-actions {
                display: flex;
                justify-content: flex-end;
                gap: 8px;
                margin-top: 8px;
            }

            @media (max-width: 768px) {
                .variant-status-control {
                    flex-direction: column;
                    align-items: stretch;
                }

                .variant-status-badge,
                .variant-status-action {
                    width: 100%;
                }

                .variant-edit-actions {
                    flex-direction: column;
                }
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="container admin-page">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Product Details</h1>
                    <p class="page-subtitle mb-0">
                        Inspect the product master record and manage its variants.
                    </p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${product.id}"
                   class="btn btn-primary">
                    <i class="fa-solid fa-pen-to-square mr-1"></i>Edit Product Info
                </a>
            </div>

            <div class="card card-main admin-card mb-4">
                <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">Product Core Profile</h4>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 text-center border-right">
                            <div class="product-main-image-box">
                                <c:choose>
                                    <c:when test="${not empty product.mainImageUrl}">
                                        <c:url var="mainProductImageUrl"
                                               value="/media/product/${product.mainImageUrl}" />
                                        <img src="${mainProductImageUrl}"
                                             alt="${fn:escapeXml(product.productName)}"
                                             class="product-main-image"
                                             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                        <div class="product-main-image-placeholder"
                                             style="display: none;">
                                            <i class="fa-regular fa-image"></i>
                                            <span>Image file not found</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="product-main-image-placeholder">
                                            <i class="fa-regular fa-image"></i>
                                            <span>No Image Available</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="col-md-9">
                            <h3>
                                <c:out value="${product.productName}" />
                                <span class="badge badge-secondary"
                                      style="font-size: 14px;">
                                    ID: #${product.id}
                                </span>
                            </h3>

                            <p class="text-muted font-italic mb-2">
                                Slug URL: <c:out value="${product.slug}" />
                            </p>

                            <div class="row mb-3">
                                <div class="col-sm-4">
                                    <strong>Status:</strong>

                                    <span class="badge ${product.status == 'ACTIVE'
                                                         ? 'badge-success'
                                                         : 'badge-warning'}">
                                              ${product.status}
                                          </span>
                                    </div>
                                </div>

                                <p>
                                    <strong>Short Description:</strong>
                                    <c:out value="${product.shortDescription}" />
                                </p>

                                <p>
                                    <strong>Long Description:</strong>
                                    <c:out value="${product.longDescription}" />
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <div id="variantCard"
                     class="card card-main admin-card mb-4">

                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">
                            <i class="fa-solid fa-layer-group mr-2"></i>
                            Current Product Variants
                        </h5>
                    </div>

                    <div class="card-body p-0">
                        <div class="variant-table-wrapper">
                            <table class="table table-hover table-striped mb-0 admin-table">
                                <thead class="thead-dark">
                                    <tr>
                                        <th class="text-center">Image</th>
                                        <th>Variant ID</th>
                                        <th>SKU Code</th>
                                        <th>Size</th>
                                        <th>Color</th>
                                        <th>Stock Qty</th>
                                        <th class="text-center" style="min-width: 235px;">
                                            Status
                                        </th>
                                        <th class="text-center">Action</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="variant" items="${variants}">
                                        <tr>
                                            <td class="align-middle text-center">
                                                <div class="variant-image-box">
                                                    <c:choose>
                                                        <c:when test="${not empty variant.imageUrl}">
                                                            <c:url var="variantImageUrl"
                                                                   value="/media/product/${variant.imageUrl}">
                                                                <c:if test="${not empty variant.imageUpdatedAt}">
                                                                    <c:param name="v"
                                                                             value="${variant.imageUpdatedAt.time}" />
                                                                </c:if>
                                                            </c:url>
                                                            <img src="${variantImageUrl}"
                                                                 alt="${fn:escapeXml(variant.size)} - ${fn:escapeXml(variant.color)}"
                                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                            <div class="variant-image-placeholder"
                                                                 style="display: none;">
                                                                <i class="fa-regular fa-image"></i>
                                                                <span>Missing</span>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${not empty product.mainImageUrl}">
                                                            <c:url var="fallbackProductImageUrl"
                                                                   value="/media/product/${product.mainImageUrl}" />
                                                            <img src="${fallbackProductImageUrl}"
                                                                 alt="Product fallback image"
                                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                            <div class="variant-image-placeholder"
                                                                 style="display: none;">
                                                                <i class="fa-regular fa-image"></i>
                                                                <span>Missing</span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="variant-image-placeholder">
                                                                <i class="fa-regular fa-image"></i>
                                                                <span>No image</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <span class="variant-image-source">
                                                    ${not empty variant.imageUrl ? 'Variant image' : 'Product fallback'}
                                                </span>
                                            </td>

                                            <td class="align-middle">#${variant.id}</td>

                                            <td class="align-middle">
                                                <span class="variant-sku">
                                                    <c:out value="${variant.sku}" />
                                                </span>
                                            </td>

                                            <td class="align-middle">
                                                <c:out value="${variant.size}"
                                                       default="-" />
                                            </td>

                                            <td class="align-middle">
                                                <c:out value="${variant.color}"
                                                       default="-" />
                                            </td>

                                            <td class="align-middle">
                                                <span class="badge ${variant.stockQuantity > 0
                                                                     ? 'badge-success'
                                                                     : 'badge-secondary'}">
                                                          ${variant.stockQuantity} Available
                                                      </span>
                                                </td>

                                                <td class="align-middle text-center">
                                                    <div class="variant-status-control">
                                                        <span class="variant-status-badge
                                                              ${variant.status == 'ACTIVE'
                                                                ? 'variant-status-active'
                                                                : 'variant-status-inactive'}">

                                                            ${variant.status == 'ACTIVE'
                                                              ? 'Active'
                                                              : 'Inactive'}
                                                        </span>

                                                        <c:choose>
                                                            <c:when test="${variant.status == 'ACTIVE'}">
                                                                <button type="button"
                                                                        class="btn btn-sm btn-outline-danger variant-status-action"
                                                                        onclick="changeVariantStatus(
                                                                        ${variant.id},
                                                                                        'INACTIVE',
                                                                        ${product.id},
                                                                        ${variant.priced},
                                                                                        '${product.status}'
                                                                                        )">
                                                                    Deactivate
                                                                </button>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <button type="button"
                                                                        class="btn btn-sm btn-outline-success variant-status-action"
                                                                        onclick="changeVariantStatus(
                                                                        ${variant.id},
                                                                                        'ACTIVE',
                                                                        ${product.id},
                                                                        ${variant.priced},
                                                                                        '${product.status}'
                                                                                        )">
                                                                    Activate
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>

                                                <td class="align-middle text-center">
                                                    <button type="button"
                                                            class="btn btn-sm btn-primary"
                                                            onclick="toggleVariantEdit(${variant.id})">
                                                        <i class="fa-solid fa-pen-to-square mr-1"></i>
                                                        Edit
                                                    </button>
                                                </td>
                                            </tr>

                                            <tr id="variantEditRow-${variant.id}"
                                                class="variant-edit-row d-none">
                                                <td colspan="8">
                                                    <div class="variant-edit-panel">
                                                        <div class="variant-edit-title">
                                                            <div>
                                                                <h5 class="mb-1">
                                                                    Edit Variant #${variant.id}
                                                                </h5>
                                                                <small class="text-muted">
                                                                    SKU <c:out value="${variant.sku}" /> is managed automatically.
                                                                </small>
                                                            </div>

                                                            <button type="button"
                                                                    class="btn btn-sm btn-outline-secondary"
                                                                    onclick="toggleVariantEdit(${variant.id})">
                                                                <i class="fa-solid fa-xmark mr-1"></i>Close
                                                            </button>
                                                        </div>

                                                        <form action="${pageContext.request.contextPath}/admin/manage-product"
                                                              method="POST"
                                                              enctype="multipart/form-data">

                                                            <input type="hidden"
                                                                   name="action"
                                                                   value="UPDATE_VARIANT">

                                                            <input type="hidden"
                                                                   name="productId"
                                                                   value="${product.id}">

                                                            <input type="hidden"
                                                                   name="variantId"
                                                                   value="${variant.id}">

                                                            <div class="row">
                                                                <div class="col-lg-2 col-md-3 mb-3">
                                                                    <label>Current Image</label>
                                                                    <div class="variant-edit-preview">
                                                                        <c:choose>
                                                                            <c:when test="${not empty variant.imageUrl}">
                                                                                <img src="${variantImageUrl}"
                                                                                     alt="Current variant image">
                                                                            </c:when>
                                                                            <c:when test="${not empty product.mainImageUrl}">
                                                                                <img src="${fallbackProductImageUrl}"
                                                                                     alt="Product fallback image">
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <div class="variant-image-placeholder">
                                                                                    <i class="fa-regular fa-image"></i>
                                                                                    <span>No image</span>
                                                                                </div>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </div>

                                                                <div class="col-lg-2 col-md-3 form-group">
                                                                    <label for="variantSize-${variant.id}">
                                                                        Size <span class="text-danger">*</span>
                                                                    </label>

                                                                    <select id="variantSize-${variant.id}"
                                                                            name="size"
                                                                            class="form-control"
                                                                            required>
                                                                        <option value="S" ${variant.size == 'S' ? 'selected' : ''}>S</option>
                                                                        <option value="M" ${variant.size == 'M' ? 'selected' : ''}>M</option>
                                                                        <option value="L" ${variant.size == 'L' ? 'selected' : ''}>L</option>
                                                                        <option value="XL" ${variant.size == 'XL' ? 'selected' : ''}>XL</option>
                                                                        <option value="XXL" ${variant.size == 'XXL' ? 'selected' : ''}>XXL</option>
                                                                        <option value="FREE SIZE" ${variant.size == 'FREE SIZE' ? 'selected' : ''}>Free Size</option>
                                                                    </select>
                                                                </div>

                                                                <div class="col-lg-3 col-md-6 form-group">
                                                                    <label for="variantColor-${variant.id}">
                                                                        Color <span class="text-danger">*</span>
                                                                    </label>

                                                                    <input type="text"
                                                                           id="variantColor-${variant.id}"
                                                                           name="color"
                                                                           value="${fn:escapeXml(variant.color)}"
                                                                           class="form-control"
                                                                           maxlength="50"
                                                                           required>
                                                                </div>

                                                                <div class="col-lg-2 col-md-4 form-group">
                                                                    <label for="variantStatus-${variant.id}">
                                                                        Status <span class="text-danger">*</span>
                                                                    </label>

                                                                    <select id="variantStatus-${variant.id}"
                                                                            name="status"
                                                                            class="form-control"
                                                                            required>
                                                                        <option value="INACTIVE"
                                                                                ${variant.status == 'INACTIVE' ? 'selected' : ''}>
                                                                            Inactive
                                                                        </option>
                                                                        <option value="ACTIVE"
                                                                                ${variant.status == 'ACTIVE' ? 'selected' : ''}
                                                                                ${variant.status != 'ACTIVE' && (product.status != 'ACTIVE' || not variant.priced) ? 'disabled' : ''}>
                                                                            Active
                                                                        </option>
                                                                    </select>

                                                                    <c:if test="${product.status != 'ACTIVE'}">
                                                                        <small class="form-text text-danger">
                                                                            Activate the Product first.
                                                                        </small>
                                                                    </c:if>

                                                                    <c:if test="${product.status == 'ACTIVE' && not variant.priced}">
                                                                        <small class="form-text text-danger">
                                                                            Configure valid prices first.
                                                                        </small>
                                                                    </c:if>
                                                                </div>

                                                                <div class="col-lg-3 col-md-8 form-group">
                                                                    <label for="variantImage-${variant.id}">
                                                                        Replace Variant Image
                                                                    </label>

                                                                    <input type="file"
                                                                           id="variantImage-${variant.id}"
                                                                           name="variantImage"
                                                                           class="form-control-file"
                                                                           accept="image/jpeg,image/png,image/webp">

                                                                    <small class="form-text text-muted">
                                                                        Leave empty to keep the current image. JPG, PNG or WEBP only.
                                                                    </small>
                                                                </div>
                                                            </div>

                                                            <div class="variant-edit-actions">
                                                                <button type="button"
                                                                        class="btn btn-outline-secondary"
                                                                        onclick="toggleVariantEdit(${variant.id})">
                                                                    Cancel
                                                                </button>

                                                                <button type="submit"
                                                                        class="btn btn-primary">
                                                                    <i class="fa-solid fa-floppy-disk mr-1"></i>
                                                                    Save Variant
                                                                </button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                        <c:if test="${empty variants}">
                                            <tr>
                                                <td colspan="8"
                                                    class="text-center py-4 text-muted">
                                                    No variants created for this product profile yet.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="card card-main admin-card">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">Add New Configuration Variant</h5>
                        </div>

                        <div class="card-body">
                            <div class="variant-note mb-3">
                                SKU is generated automatically. A new variant is always
                                created as <strong>Inactive</strong> until valid prices are configured.
                            </div>

                            <form action="${pageContext.request.contextPath}/admin/manage-product"
                                  method="POST">

                                <input type="hidden"
                                       name="action"
                                       value="ADD_VARIANTS">

                                <input type="hidden"
                                       name="productId"
                                       value="${product.id}">

                                <div class="row">
                                    <div class="col-md-4 form-group">
                                        <label for="variantSize">
                                            Size <span class="text-danger">*</span>
                                        </label>

                                        <select id="variantSize"
                                                name="variants[0].size"
                                                class="form-control"
                                                required>

                                            <option value="">-- Select Size --</option>
                                            <option value="S">S</option>
                                            <option value="M">M</option>
                                            <option value="L">L</option>
                                            <option value="XL">XL</option>
                                            <option value="XXL">XXL</option>
                                            <option value="FREE SIZE">Free Size</option>
                                        </select>
                                    </div>

                                    <div class="col-md-5 form-group">
                                        <label for="variantColor">
                                            Color <span class="text-danger">*</span>
                                        </label>

                                        <input type="text"
                                               id="variantColor"
                                               name="variants[0].color"
                                               class="form-control"
                                               maxlength="50"
                                               placeholder="e.g. White, Black, Navy Blue"
                                               required>
                                    </div>

                                    <div class="col-md-3 form-group d-flex align-items-end">
                                        <button type="submit"
                                                class="btn btn-success btn-block">
                                            <i class="fa-solid fa-plus mr-1"></i>
                                            Add Variant
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <form id="masterStatusForm"
                      action="${pageContext.request.contextPath}/admin/manage-product"
                      method="POST"
                      class="d-none">

                    <input type="hidden"
                           name="action"
                           value="UPDATE_VARIANT_STATUS">

                    <input type="hidden"
                           name="productId"
                           id="submitProductId">

                    <input type="hidden"
                           name="variantId"
                           id="submitVariantId">

                    <input type="hidden"
                           name="status"
                           id="submitVariantStatus">
                </form>

                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

                <script>
                    function toggleVariantEdit(variantId) {
                        const editRow = document.getElementById(
                                "variantEditRow-" + variantId
                                );

                        if (!editRow) {
                            return;
                        }

                        const isHidden = editRow.classList.contains("d-none");

                        document.querySelectorAll(".variant-edit-row").forEach(function (row) {
                            row.classList.add("d-none");
                        });

                        if (isHidden) {
                            editRow.classList.remove("d-none");
                            editRow.scrollIntoView({
                                behavior: "smooth",
                                block: "nearest"
                            });
                        }
                    }

                    function changeVariantStatus(
                            variantId,
                            nextStatus,
                            productId,
                            isPriced,
                            productStatus) {

                        const isActivating = nextStatus === "ACTIVE";

                        if (isActivating && productStatus !== "ACTIVE") {
                            Swal.fire({
                                icon: "error",
                                title: "Cannot activate variant",
                                text: "The product must be Active before any variant can be activated.",
                                confirmButtonColor: "#dc3545"
                            });
                            return;
                        }

                        if (isActivating && !isPriced) {
                            Swal.fire({
                                icon: "error",
                                title: "Invalid variant price",
                                text: "Please configure a list price and sale price greater than 0 in Manage Price before activating this variant.",
                                confirmButtonColor: "#dc3545"
                            });
                            return;
                        }

                        const actionText = isActivating ? "activate" : "deactivate";

                        Swal.fire({
                            title: isActivating
                                    ? "Activate Variant?"
                                    : "Deactivate Variant?",

                            text: "Are you sure you want to "
                                    + actionText
                                    + " this variant?",

                            icon: "question",
                            showCancelButton: true,
                            confirmButtonColor: isActivating
                                    ? "#198754"
                                    : "#dc3545",

                            cancelButtonColor: "#6c757d",
                            confirmButtonText: isActivating
                                    ? "Yes, activate"
                                    : "Yes, deactivate",

                            cancelButtonText: "Cancel"
                        }).then(function (result) {
                            if (!result.isConfirmed) {
                                return;
                            }

                            document.getElementById("submitProductId").value =
                                    productId;

                            document.getElementById("submitVariantId").value =
                                    variantId;

                            document.getElementById("submitVariantStatus").value =
                                    nextStatus;

                            document.getElementById("masterStatusForm").submit();
                        });
                    }

                    document.addEventListener("DOMContentLoaded", function () {
                        const params = new URLSearchParams(window.location.search);
                        const status = params.get("status");

                        const successMessages = {
                            "variant-updated": "Variant information and image updated successfully.",
                            "variants-added": "New variant added successfully."
                        };

                        const errorMessages = {
                            "invalid-request": "The submitted variant request is invalid.",
                            "invalid-id": "The Product ID or Variant ID is invalid.",
                            "variant-not-found": "The selected variant could not be found.",
                            "size-required": "Variant size is required.",
                            "color-required": "Variant color is required.",
                            "invalid-status": "The selected variant status is invalid.",
                            "product-not-found": "The product could not be found.",
                            "product-inactive": "The product must be Active before this variant can be activated.",
                            "variant-combination-exists": "This size and color combination already exists for the product.",
                            "update-failed": "The variant information could not be updated.",
                            "invalid-image": "The selected image is invalid. Use JPG, PNG or WEBP.",
                            "image-upload-failed": "The image could not be saved to the upload folder.",
                            "image-required": "Please select an image.",
                            "invalid-image-path": "The generated image path is invalid.",
                            "image-save-failed": "The variant image could not be saved in the database.",
                            "variant-update-failed":
                                    "The variant could not be activated. Check that the product is Active and that list price and sale price are greater than 0.",
                            "variant-duplicate":
                                    "This size and color combination already exists.",
                            "variant-invalid":
                                    "Size and color are required.",
                            "variant-required":
                                    "Please provide at least one variant."
                        };

                        if (successMessages[status]) {
                            Swal.fire({
                                toast: true,
                                position: "top-end",
                                icon: "success",
                                title: successMessages[status],
                                showConfirmButton: false,
                                timer: 2500,
                                timerProgressBar: true
                            });
                        }

                        if (errorMessages[status]) {
                            Swal.fire({
                                icon: "error",
                                title: "Action failed",
                                text: errorMessages[status],
                                confirmButtonColor: "#dc3545"
                            });
                        }

                        if (status) {
                            params.delete("status");

                            const cleanQuery = params.toString();
                            const cleanUrl = window.location.pathname
                                    + (cleanQuery ? "?" + cleanQuery : "");

                            window.history.replaceState(
                                    {},
                                    document.title,
                                    cleanUrl
                                    );
                        }
                    });
                </script>
            </body>
        </html>