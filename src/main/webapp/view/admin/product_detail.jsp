<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Product Details - Admin Panel</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">

        <style>
            body {
                background-color: #f3f4f6;
            }

            .product-image {
                width: 100%;
                max-height: 260px;
                object-fit: cover;
                border-radius: 10px;
            }

            .sku-text {
                font-family: Consolas, monospace;
                font-weight: 600;
            }

            .variant-builder {
                padding: 18px;
                background: #f8fafc;
                border: 1px solid #e5e7eb;
                border-radius: 10px;
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="container-fluid admin-page px-4 py-4">
            <div class="mb-3">
                
            </div>

            <c:if test="${param.status == 'success'}">
                <div class="d-none" data-product-toast data-product-toast-type="success">Action completed successfully.</div>
            </c:if>
            <c:if test="${param.status == 'error'}">
                <div class="d-none" data-product-toast data-product-toast-type="error">An error occurred while processing the request.</div>
            </c:if>
            <c:if test="${param.status == 'variants-added'}">
                <div class="d-none" data-product-toast data-product-toast-type="success">New variants were added successfully.</div>
            </c:if>
            <c:if test="${param.status == 'variant-duplicate'}">
                <div class="d-none" data-product-toast data-product-toast-type="warning">A size and color combination already exists.</div>
            </c:if>
            <c:if test="${param.status == 'variant-invalid'}">
                <div class="d-none" data-product-toast data-product-toast-type="warning">Variant information is incomplete or invalid.</div>
            </c:if>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Product Details</h1>
                    <p class="page-subtitle mb-0">Review product information and manage its variants.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${product.id}"
                   class="btn btn-primary">
                    <i class="fa-solid fa-pen-to-square me-1"></i>Edit Product
                </a>
            </div>

            <div class="card card-main admin-card mb-4">
                <div class="card-header bg-info text-white">
                    <h4 class="mb-0">Product Core Profile</h4>
                </div>

                <div class="card-body">
                    <div class="row g-4 align-items-start">
                        <div class="col-md-3 text-center">
                            <c:choose>
                                <c:when test="${not empty product.mainImageUrl}">
                                    <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                                         alt="Main Product Image"
                                         class="product-image img-thumbnail">
                                </c:when>
                                <c:otherwise>
                                    <div class="bg-light d-flex align-items-center justify-content-center rounded border" style="height: 220px;">
                                        <span class="text-muted">No Image Available</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="col-md-9">
                            <div class="d-flex flex-wrap align-items-center gap-2 mb-2">
                                <h3 class="mb-0">${product.productName}</h3>
                                <span class="badge bg-secondary">ID: #${product.id}</span>
                            </div>

                            <p class="text-muted fst-italic mb-3">Slug URL: ${product.slug}</p>

                            <p>
                                <strong>Status:</strong>
                                <span class="badge ${product.status == 'ACTIVE' ? 'bg-success' : 'bg-warning text-dark'}">
                                    ${product.status}
                                </span>
                            </p>

                            <p><strong>Short Description:</strong> ${product.shortDescription}</p>
                            <p class="mb-0"><strong>Long Description:</strong> ${product.longDescription}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card card-main admin-card mb-4">
                <div class="card-header bg-dark text-white">
                    <h5 class="mb-0">
                        <i class="fa-solid fa-layer-group me-2"></i>Current Product Variants
                    </h5>
                </div>

                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped align-middle mb-0 admin-table">
                            <thead class="table-light">
                                <tr>
                                    <th>Variant ID</th>
                                    <th>SKU Code</th>
                                    <th>Size</th>
                                    <th>Color</th>
                                    <th>Stock Qty</th>
                                    <th class="text-center">Status</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="variant" items="${variants}">
                                    <tr class="existing-variant-row"
                                        data-size="<c:out value='${variant.size}'/>"
                                        data-color="<c:out value='${variant.color}'/>">
                                        <td>#${variant.id}</td>
                                        <td><strong class="sku-text text-primary">${variant.sku}</strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty variant.size}">${variant.size}</c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty variant.color}">${variant.color}</c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge ${variant.stockQuantity > 0 ? 'bg-success' : 'bg-secondary'}">
                                                ${variant.stockQuantity} Available
                                            </span>
                                        </td>
                                        <td class="text-center" style="width: 180px;">
                                            <div class="dropdown d-inline-block">
                                                <button class="btn btn-sm dropdown-toggle ${variant.status == 'ACTIVE' ? 'btn-success' : 'btn-danger'}"
                                                        type="button"
                                                        id="dropdownStatus-${variant.id}"
                                                        data-bs-toggle="dropdown"
                                                        aria-expanded="false"
                                                        style="min-width: 105px; border-radius: 20px;">
                                                    ${variant.status == 'ACTIVE' ? 'Active' : 'Inactive'}
                                                </button>

                                                <ul class="dropdown-menu dropdown-menu-end shadow-sm"
                                                    aria-labelledby="dropdownStatus-${variant.id}">
                                                    <li>
                                                        <button type="button"
                                                                class="dropdown-item d-flex align-items-center py-2 ${variant.status == 'ACTIVE' ? 'disabled bg-light' : ''}"
                                                                onclick="changeVariantStatus('${variant.id}', 'ACTIVE', '${product.id}')">
                                                            <span class="badge bg-success me-2 rounded-circle" style="width: 10px; height: 10px;"></span>
                                                            Active
                                                        </button>
                                                    </li>
                                                    <li>
                                                        <button type="button"
                                                                class="dropdown-item d-flex align-items-center py-2 ${variant.status != 'ACTIVE' ? 'disabled bg-light' : ''}"
                                                                onclick="changeVariantStatus('${variant.id}', 'INACTIVE', '${product.id}')">
                                                            <span class="badge bg-danger me-2 rounded-circle" style="width: 10px; height: 10px;"></span>
                                                            Inactive
                                                        </button>
                                                    </li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty variants}">
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">
                                            No variants have been created for this product.
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
                    <h5 class="mb-0">
                        <i class="fa-solid fa-square-plus me-2"></i>Add New Variants
                    </h5>
                </div>

                <div class="card-body">
                    <form id="detailVariantForm"
                          action="${pageContext.request.contextPath}/admin/manage-product"
                          method="POST"
                          enctype="multipart/form-data"
                          data-product-name="<c:out value='${product.productName}'/>">
                        <input type="hidden" name="action" value="ADD_VARIANTS">
                        <input type="hidden" name="productId" value="${product.id}">

                        <div class="variant-builder">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="detailVariantSize" class="form-label fw-semibold">
                                        Size <span class="text-danger">*</span>
                                    </label>

                                    <select id="detailVariantSize" class="form-select">
                                        <option value="">-- Select Size --</option>
                                        <option value="S">S</option>
                                        <option value="M">M</option>
                                        <option value="L">L</option>
                                        <option value="XL">XL</option>
                                        <option value="XXL">XXL</option>
                                        <option value="FREE SIZE">Free Size</option>
                                    </select>
                                </div>

                                <div class="col-md-3">
                                    <label for="detailVariantColor" class="form-label fw-semibold">
                                        Color <span class="text-danger">*</span>
                                    </label>

                                    <input type="text"
                                           id="detailVariantColor"
                                           class="form-control"
                                           placeholder="e.g. Red or Navy Blue">
                                </div>

                                <div class="col-md-3">
                                    <label for="detailVariantStatus" class="form-label fw-semibold">Initial Status</label>

                                    <select id="detailVariantStatus" class="form-select">
                                        <option value="ACTIVE">Active</option>
                                        <option value="INACTIVE">Inactive</option>
                                    </select>
                                </div>

                                <div class="col-md-3 d-flex align-items-end">
                                    <button type="button"
                                            id="detailAddVariantButton"
                                            class="btn btn-outline-success w-100">
                                        <i class="fa-solid fa-plus me-1"></i>Add Variant
                                    </button>
                                </div>

                                <div class="col-12">
                                    <label for="detailBaseSku" class="form-label fw-semibold">Base SKU</label>

                                    <input type="text"
                                           id="detailBaseSku"
                                           class="form-control sku-text bg-white"
                                           readonly>

                                    <div class="form-text">
                                        SKU is generated automatically from the complete product name, size, and color.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-4 mb-2">
                            <div>
                                <h6 class="fw-bold mb-1">Variants to Add</h6>
                                <small class="text-muted">Review the list before saving all variants.</small>
                            </div>

                            <span id="detailVariantCount" class="badge bg-success">0 variants</span>
                        </div>

                        <div class="table-responsive border rounded">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Combination</th>
                                        <th>Generated SKU</th>
                                        <th>Status</th>
                                        <th class="text-center" style="width: 90px;">Action</th>
                                    </tr>
                                </thead>

                                <tbody id="detailVariantListBody">
                                    <tr>
                                        <td colspan="4" class="text-center py-4 text-muted">
                                            <i class="fa-solid fa-circle-info me-1"></i>No variants added yet.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="text-end mt-3">
                            <button type="submit" class="btn btn-success px-4">
                                <i class="fa-solid fa-floppy-disk me-1"></i>Save All Variants
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <form id="masterStatusForm"
              action="${pageContext.request.contextPath}/admin/manage-product"
              method="POST"
              class="d-none">
            <input type="hidden" name="action" value="UPDATE_VARIANT_STATUS">
            <input type="hidden" name="productId" id="submitProductId">
            <input type="hidden" name="variantId" id="submitVariantId">
            <input type="hidden" name="status" id="submitVariantStatus">
        </form>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                initializeVariantBuilder();
                showProductToasts();
            });

            function initializeVariantBuilder() {
                const form = document.getElementById("detailVariantForm");
                if (!form) {
                    return;
                }

                const productName = form.dataset.productName || "";
                const sizeInput = document.getElementById("detailVariantSize");
                const colorInput = document.getElementById("detailVariantColor");
                const statusInput = document.getElementById("detailVariantStatus");
                const baseSkuInput = document.getElementById("detailBaseSku");
                const addButton = document.getElementById("detailAddVariantButton");
                const tableBody = document.getElementById("detailVariantListBody");
                const countLabel = document.getElementById("detailVariantCount");
                const variants = [];
                const existingCombinations = new Set();

                document.querySelectorAll(".existing-variant-row").forEach(function (row) {
                    const size = cleanText(row.dataset.size).toLowerCase();
                    const color = cleanText(row.dataset.color).toLowerCase();
                    if (size && color) {
                        existingCombinations.add(size + "|" + color);
                    }
                });

                function normalizeSku(value) {
                    return (value || "")
                            .normalize("NFD")
                            .replace(/[\u0300-\u036f]/g, "")
                            .replace(/đ/g, "d")
                            .replace(/Đ/g, "D")
                            .toLowerCase()
                            .replace(/[^a-z0-9]+/g, "-")
                            .replace(/^-+|-+$/g, "");
                }

                function escapeHtml(value) {
                    return String(value || "").replace(/[&<>"']/g, function (character) {
                        const map = {
                            "&": "&amp;",
                            "<": "&lt;",
                            ">": "&gt;",
                            '"': "&quot;",
                            "'": "&#039;"
                        };
                        return map[character];
                    });
                }

                function getVariantSku(variant) {
                    return normalizeSku(productName) + "-" + normalizeSku(variant.size) + "-" + normalizeSku(variant.color);
                }

                function renderVariants() {
                    countLabel.textContent = variants.length + (variants.length === 1 ? " variant" : " variants");

                    if (variants.length === 0) {
                        tableBody.innerHTML = `
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    <i class="fa-solid fa-circle-info me-1"></i>No variants added yet.
                                </td>
                            </tr>`;
                        return;
                    }

                    let rows = "";

                    variants.forEach(function (variant, index) {
                        const sku = getVariantSku(variant);
                        const statusClass = variant.status === "ACTIVE" ? "bg-success" : "bg-secondary";
                        const statusText = variant.status === "ACTIVE" ? "Active" : "Inactive";

                        rows += "<tr>"
                                + "<td>"
                                + "<span class='badge bg-dark me-1'>Size: " + escapeHtml(variant.size) + "</span> "
                                + "<span class='badge bg-primary'>Color: " + escapeHtml(variant.color) + "</span>"
                                + "<input type='hidden' name='variants[" + index + "].size' value='" + escapeHtml(variant.size) + "'>"
                                + "<input type='hidden' name='variants[" + index + "].color' value='" + escapeHtml(variant.color) + "'>"
                                + "<input type='hidden' name='variants[" + index + "].status' value='" + escapeHtml(variant.status) + "'>"
                                + "<input type='hidden' name='variants[" + index + "].skuCode' value='" + escapeHtml(sku) + "'>"
                                + "</td>"
                                + "<td><input type='text' class='form-control form-control-sm sku-text bg-light' value='" + escapeHtml(sku) + "' readonly></td>"
                                + "<td><span class='badge " + statusClass + "'>" + statusText + "</span></td>"
                                + "<td class='text-center'>"
                                + "<button type='button' class='btn btn-sm btn-outline-danger' data-remove-index='" + index + "' title='Remove variant'>"
                                + "<i class='fa-solid fa-trash'></i>"
                                + "</button>"
                                + "</td>"
                                + "</tr>";
                    });

                    tableBody.innerHTML = rows;
                }

                function addVariant() {
                    const size = cleanText(sizeInput.value);
                    const color = cleanText(colorInput.value);
                    const status = statusInput.value;

                    if (!size || !color) {
                        Swal.fire("Incomplete Variant", "Please select a size and enter a color.", "warning");
                        return;
                    }

                    const combinationKey = size.toLowerCase() + "|" + color.toLowerCase();

                    if (existingCombinations.has(combinationKey)) {
                        Swal.fire("Variant Already Exists", "This size and color combination already exists for the product.", "warning");
                        return;
                    }

                    const duplicated = variants.some(function (variant) {
                        return variant.size.toLowerCase() === size.toLowerCase()
                                && variant.color.toLowerCase() === color.toLowerCase();
                    });

                    if (duplicated) {
                        Swal.fire("Duplicate Variant", "This size and color combination is already in the temporary list.", "warning");
                        return;
                    }

                    variants.push({size: size, color: color, status: status});
                    sizeInput.value = "";
                    colorInput.value = "";
                    statusInput.value = "ACTIVE";
                    colorInput.focus();
                    renderVariants();
                }

                baseSkuInput.value = normalizeSku(productName);
                addButton.addEventListener("click", addVariant);

                colorInput.addEventListener("keydown", function (event) {
                    if (event.key === "Enter") {
                        event.preventDefault();
                        addVariant();
                    }
                });

                tableBody.addEventListener("click", function (event) {
                    const button = event.target.closest("[data-remove-index]");
                    if (!button) {
                        return;
                    }

                    variants.splice(Number(button.dataset.removeIndex), 1);
                    renderVariants();
                });

                form.addEventListener("submit", function (event) {
                    event.preventDefault();

                    if (variants.length === 0) {
                        Swal.fire("Variant Required", "Please add at least one variant before saving.", "warning");
                        return;
                    }

                    Swal.fire({
                        title: "Save all variants?",
                        text: "All variants in the temporary list will be added to this product.",
                        icon: "question",
                        showCancelButton: true,
                        confirmButtonColor: "#198754",
                        cancelButtonColor: "#6c757d",
                        confirmButtonText: "Yes, save variants"
                    }).then(function (result) {
                        if (result.isConfirmed) {
                            HTMLFormElement.prototype.submit.call(form);
                        }
                    });
                });
            }

            function cleanText(value) {
                return (value || "").trim().replace(/\s+/g, " ");
            }

            function changeVariantStatus(variantId, nextStatus, productId) {
                const isActivating = nextStatus === "ACTIVE";

                Swal.fire({
                    title: isActivating ? "Activate Variant?" : "Deactivate Variant?",
                    text: isActivating
                            ? "This variant will become available for management and sales."
                            : "This variant will become unavailable for new sales.",
                    icon: "question",
                    showCancelButton: true,
                    confirmButtonColor: isActivating ? "#198754" : "#dc3545",
                    cancelButtonColor: "#6c757d",
                    confirmButtonText: isActivating ? "Yes, activate it" : "Yes, deactivate it"
                }).then(function (result) {
                    if (!result.isConfirmed) {
                        return;
                    }

                    document.getElementById("submitProductId").value = productId;
                    document.getElementById("submitVariantId").value = variantId;
                    document.getElementById("submitVariantStatus").value = nextStatus;
                    document.getElementById("masterStatusForm").submit();
                });
            }

            function showProductToasts() {
                const Toast = Swal.mixin({
                    toast: true,
                    position: "top-end",
                    showConfirmButton: false,
                    timer: 3000,
                    timerProgressBar: true,
                    didOpen: function (toast) {
                        toast.addEventListener("mouseenter", Swal.stopTimer);
                        toast.addEventListener("mouseleave", Swal.resumeTimer);
                    }
                });

                document.querySelectorAll("[data-product-toast]").forEach(function (node) {
                    const type = node.dataset.productToastType || "info";
                    const message = (node.textContent || "").trim();

                    if (message) {
                        Toast.fire({icon: type, title: message});
                    }

                    node.remove();
                });

                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get("success") === "StatusUpdated") {
                    Toast.fire({icon: "success", title: "Variant status updated successfully."});
                }
            }
        </script>
    </body>
</html>