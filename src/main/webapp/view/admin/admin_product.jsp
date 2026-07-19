<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Product Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
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
            .product-img {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #e5e7eb;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="main-content admin-page">
            <div class="container-fluid">

                <div class="page-header">
                    <h2 class="page-title">
                        <i class="fa-solid fa-box-open me-2 text-primary"></i>Product Management
                    </h2>
                    <button class="btn btn-primary px-4 py-2 rounded-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#createProductModal">
                        <i class="fa-solid fa-plus me-1"></i> Add New Product
                    </button>
                </div>

                <div class="card card-main admin-card p-4">
                    <div class="mb-3">
                        <h3 class="h5 mb-0 fw-bold text-dark">
                            <i class="fa-solid fa-list me-2 text-secondary"></i>Product Catalog List
                        </h3>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-striped table-hover align-middle border text-center variant-table admin-table mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 100px;">ID</th>
                                    <th style="width: 100px;">Image</th>
                                    <th>Product Name</th>
                                    <th>Category ID</th>
                                    <th>Brand ID</th>
                                    <th>Status</th>
                                    <th style="width: 300px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="prod" items="${products}">
                                    <tr>
                                        <td class="fw-bold text-secondary">#PROD-${prod.id}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty prod.mainImageUrl}">
                                                    <img src="${pageContext.request.contextPath}/media/product/${prod.mainImageUrl}"
                                                         class="product-img shadow-sm"
                                                         alt="Product Image"
                                                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/default-product.png';">  
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/assets/images/default-product.png"   
                                                    </c:otherwise>
                                                </c:choose>
                                        </td>
                                        <td class="text-start"><span class="fw-semibold text-dark">${prod.productName}</span></td>
                                        <td><span class="badge bg-light text-dark border px-2.5 py-1.5">${prod.categoryId}</span></td>
                                        <td><span class="badge bg-light text-dark border px-2.5 py-1.5">${prod.brandId}</span></td>
                                        <td>
                                            <span class="badge ${prod.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'} px-3 py-1.5">
                                                ${prod.status}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/AdminManageProduct?action=view&id=${prod.id}" class="btn btn-sm btn-outline-info me-1 px-3">
                                                <i class="fa-solid fa-eye"></i> View
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${prod.id}"
                                               class="btn btn-sm btn-outline-warning me-1 px-3">
                                                <i class="fa-solid fa-pen-to-square"></i> Edit
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger px-3" onclick="deleteProduct(${prod.id})">
                                                <i class="fa-solid fa-trash"></i> Delete
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty products}">
                                    <tr>
                                        <td colspan="7" class="text-center py-4 text-muted">No products found. Click "Add New Product" to start.</td>
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
                                                            <option value="">-- Select Category --</option>
                                                            <c:forEach var="cat" items="${categories}">
                                                                <option value="${cat.id}">${cat.categoryName}</option>
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
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
                                                document.addEventListener("DOMContentLoaded", function () {
                                                    const form = document.getElementById("createProductForm");
                                                    const productNameInput = document.getElementById("adminProductName");
                                                    const sizeInput = document.getElementById("adminVariantSize");
                                                    const colorInput = document.getElementById("adminVariantColor");
                                                    const addButton = document.getElementById("adminAddVariantButton");
                                                    const tableBody = document.getElementById("adminVariantListBody");
                                                    const countLabel = document.getElementById("adminVariantCount");
                                                    const createModal = document.getElementById("createProductModal");
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
                                                        return removeVietnameseTones(cleanText(value))
                                                                .toLowerCase();
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
                                                            tableBody.innerHTML = `
                            <tr>
                                <td colspan="3" class="text-center py-4 text-muted">
                                    <i class="fa-solid fa-circle-info me-1"></i>No variants added yet.
                                </td>
                            </tr>`;
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
                                                                    + "<td>"
                                                                    + "<input type='text' class='form-control form-control-sm bg-light fw-semibold' value='" + escapeHtml(getVariantSku(variant)) + "' readonly>"
                                                                    + "</td>"
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
                                                        const productName = cleanText(productNameInput.value);
                                                        const size = cleanText(sizeInput.value);
                                                        const color = cleanText(colorInput.value);

                                                        if (!productName) {
                                                            Swal.fire("Product Name Required", "Please enter the product name before adding variants.", "warning");
                                                            productNameInput.focus();
                                                            return;
                                                        }

                                                        if (!size || !color) {
                                                            Swal.fire("Incomplete Variant", "Please select a size and enter a color.", "warning");
                                                            return;
                                                        }

                                                        const combinationKey = getCombinationKey(size, color);
                                                        const duplicated = variants.some(function (variant) {
                                                            return getCombinationKey(variant.size, variant.color) === combinationKey;
                                                        });

                                                        if (duplicated) {
                                                            Swal.fire("Duplicate Variant", "This size and color combination is already in the list.", "warning");
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

                                                        if (variants.length === 0) {
                                                            Swal.fire("Variant Required", "Please add at least one size-color variant.", "warning");
                                                            return;
                                                        }

                                                        Swal.fire({
                                                            title: "Are you sure?",
                                                            text: "Do you want to save this new product information?",
                                                            icon: "question",
                                                            showCancelButton: true,
                                                            confirmButtonColor: "#3085d6",
                                                            cancelButtonColor: "#6c757d",
                                                            confirmButtonText: "Yes, save product!"
                                                        }).then(function (result) {
                                                            if (!result.isConfirmed) {
                                                                return;
                                                            }

                                                            Swal.fire({
                                                                title: "Processing...",
                                                                text: "Saving product and variants.",
                                                                allowOutsideClick: false,
                                                                didOpen: function () {
                                                                    Swal.showLoading();
                                                                }
                                                            });

                                                            form.submit();
                                                        });
                                                    });

                                                    createModal.addEventListener("hidden.bs.modal", function () {
                                                        form.reset();
                                                        variants.splice(0, variants.length);
                                                        renderVariants();
                                                    });

                                                    renderVariants();
                                                });

                                                function deleteProduct(id) {
                                                    Swal.fire({
                                                        title: "Delete this product?",
                                                        text: "The product will be soft-deleted and its variants will become inactive.",
                                                        icon: "warning",
                                                        showCancelButton: true,
                                                        confirmButtonColor: "#dc3545",
                                                        cancelButtonColor: "#6c757d",
                                                        confirmButtonText: "Yes, delete it!"
                                                    }).then(function (result) {
                                                        if (result.isConfirmed) {
                                                            document.getElementById("hiddenDeleteProductId").value = id;
                                                            document.getElementById("hiddenDeleteForm").submit();
                                                        }
                                                    });
                                                }
        </script>
    </body>
</html>