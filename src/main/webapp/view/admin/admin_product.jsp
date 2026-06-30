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
                                        <th style="width: 200px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="prod" items="${products}">
                                    <tr>
                                        <td class="fw-bold text-secondary">#PROD-${prod.id}</td>
                                        <td>
                                    <c:choose>
                                        <c:when test="${not empty prod.mainImageUrl}">
                                            <img src="${pageContext.request.contextPath}/uploads/product/${prod.mainImageUrl}" class="product-img shadow-sm" alt="Product Image">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/uploads/product/default.jpg" class="product-img shadow-sm" alt="No Image">
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
                                        <button type="button" class="btn btn-sm btn-outline-warning me-1 px-3" 
                                                onclick="openUpdateProductModal({
                                                            id: '${prod.id}',
                                                                    name: '<c:out value="${prod.productName}"/>',
                                        catId: '${prod.categoryId}',
                                        brandId: '${prod.brandId}',
                                        status: '${prod.status}',
                                        desc: '<c:out value="${prod.longDescription}"/>'
                                    })">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit
                                    </button>   
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
                        <button type="button" class="btn-close" data-bs-toggle="modal" aria-label="Close"></button>
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
                                                <div class="row g-3">
                                                    <div class="col-md-6 border-end">
                                                        <label class="form-label fw-semibold text-secondary">Select Sizes <span class="text-danger">*</span></label>
                                                        <div class="d-flex flex-wrap gap-2 p-3 bg-light rounded border">
                                                            <div class="form-check form-check-inline m-0">
                                                                <input class="form-check-input admin-size-cb" type="checkbox" value="S" id="sizeS">
                                                                <label class="form-check-label fw-medium" for="sizeS">S</label>
                                                            </div>
                                                            <div class="form-check form-check-inline m-0">
                                                                <input class="form-check-input admin-size-cb" type="checkbox" value="M" id="sizeM">
                                                                <label class="form-check-label fw-medium" for="sizeM">M</label>
                                                            </div>
                                                            <div class="form-check form-check-inline m-0">
                                                                <input class="form-check-input admin-size-cb" type="checkbox" value="L" id="sizeL">
                                                                <label class="form-check-label fw-medium" for="sizeL">L</label>
                                                            </div>
                                                            <div class="form-check form-check-inline m-0">
                                                                <input class="form-check-input admin-size-cb" type="checkbox" value="XL" id="sizeXL">
                                                                <label class="form-check-label fw-medium" for="sizeXL">XL</label>
                                                            </div>
                                                            <div class="form-check form-check-inline m-0">
                                                                <input class="form-check-input admin-size-cb" type="checkbox" value="XXL" id="sizeXXL">
                                                                <label class="form-check-label fw-medium" for="sizeXXL">XXL</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label for="adminColorInput" class="form-label fw-semibold text-secondary">Input Colors <span class="text-danger">*</span></label>
                                                        <div class="p-2 bg-light rounded border">
                                                            <input type="text" class="form-control bg-white" id="adminColorInput" placeholder="e.g., Red, Navy Blue, Black (Use comma)">
                                                        </div>
                                                    </div>
                                                    <div class="col-12 mt-3">
                                                        <label class="form-label fw-semibold text-dark">Generated Variants Matrix Result:</label>
                                                        <div class="table-responsive border rounded shadow-sm" style="max-height: 250px; overflow-y: auto;">
                                                            <table class="table table-hover align-middle mb-0" id="adminVariantTable">
                                                                <thead class="table-dark text-uppercase sticky-top" style="font-size: 0.8rem; z-index: 10;">
                                                                    <tr>
                                                                        <th style="width: 40%">Combination</th>
                                                                        <th style="width: 60%">SKU Code</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="adminVariantMatrixBody">
                                                                    <tr>
                                                                        <td colspan="2" class="text-center py-4 text-muted">
                                                                            <i class="fa-solid fa-circle-info me-1"></i>Please select sizes and type colors above to generate variants.
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
                        </div>
                        <div class="modal-footer border-top bg-white sticky-bottom m-0 p-3" style="z-index: 20;">
                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary px-4"><i class="fa-solid fa-floppy-disk me-1"></i> Save Product</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="updateProductModal" tabindex="-1" aria-labelledby="updateProductModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content" style="border-radius: 12px; border: none;">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold" id="updateProductModalLabel">
                            <i class="fa-solid fa-pen-to-square text-warning me-2"></i>Update Product Information
                        </h5>
                        <button type="button" class="btn-close" data-bs-toggle="modal" aria-label="Close"></button>
                    </div>
                    <form id="updateProductForm" action="${pageContext.request.contextPath}/AdminManageProduct" method="POST" enctype="multipart/form-data" class="h-100">
                        <input type="hidden" name="action" value="UPDATE">
                        <input type="hidden" name="productId" id="updateProductId">

                        <div class="modal-body p-0" style="max-height: 70vh; overflow-y: auto;">
                            <div class="p-4 bg-light">
                                <div class="card shadow-sm border-0 rounded p-4 bg-white">
                                    <div class="row g-3">
                                        <div class="col-md-12">
                                            <label class="form-label fw-semibold">Product Name <span class="text-danger">*</span></label>
                                            <input type="text" id="updateProductName" name="productName" class="form-control" placeholder="e.g. Premium Cotton T-Shirt" required>
                                            <input type="hidden" name="slug" value="default-slug">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                                            <select id="updateProductCategory" name="categoryId" class="form-select" required>
                                                <option value="">-- Select Category --</option>
                                                <c:forEach var="cat" items="${categories}">
                                                    <option value="${cat.id}">${cat.categoryName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Brand <span class="text-danger">*</span></label>
                                            <select id="updateProductBrand" name="brandId" class="form-select" required>
                                                <option value="">-- Select Brand --</option>
                                                <c:forEach var="br" items="${brands}">
                                                    <option value="${br.id}">${br.brandName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-12">
                                            <label class="form-label fw-semibold">Product Status <span class="text-danger">*</span></label>
                                            <select id="updateProductStatus" name="status" class="form-select" required>
                                                <option value="ACTIVE">ACTIVE</option>
                                                <option value="INACTIVE">INACTIVE</option>
                                            </select>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Product Image</label>
                                            <input type="file" name="productImage" class="form-control">
                                            <small class="text-muted d-block mt-1">
                                                <i class="fa-solid fa-circle-info me-1"></i>Leave blank to keep the current product image.
                                            </small>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Description</label>
                                            <textarea id="updateProductDesc" name="longDescription" class="form-control" rows="4" placeholder="Write product details here..."></textarea>
                                            <input type="hidden" name="shortDescription" value="">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-top bg-white sticky-bottom m-0 p-3" style="z-index: 20;">
                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-warning text-white px-4">
                                <i class="fa-solid fa-floppy-disk me-1"></i> Save Changes
                            </button>
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
                                                    const sizeCheckboxes = document.querySelectorAll(".admin-size-cb");
                                                    const colorInput = document.getElementById("adminColorInput");
                                                    const matrixBody = document.getElementById("adminVariantMatrixBody");
                                                    const productNameInput = document.getElementById("adminProductName");
                                                    if (sizeCheckboxes.length > 0) {
                                                    sizeCheckboxes.forEach(cb => cb.addEventListener("change", renderAdminMatrix));
                                                    }
                                                    if (colorInput) {
                                                    colorInput.addEventListener("input", renderAdminMatrix);
                                                    }
                                                    if (productNameInput) {
                                                    productNameInput.addEventListener("input", renderAdminMatrix);
                                                    }

                                                    function renderAdminMatrix() {
                                                    let sizes = [];
                                                    sizeCheckboxes.forEach(cb => {
                                                    if (cb.checked) sizes.push(cb.value);
                                                    });
                                                    let colors = colorInput.value.split(",").map(c => c.trim()).filter(c => c.length > 0);
                                                    if (sizes.length === 0 || colors.length === 0) {
                                                    matrixBody.innerHTML = `<tr><td colspan="2" class="text-center py-4 text-muted"><i class="fa-solid fa-circle-info me-1"></i>Please select sizes and type colors above to generate variants.</td></tr>`;
                                                    return;
                                                    }

                                                    let htmlRows = "";
                                                    let index = 0;
                                                    let rawPrefix = productNameInput ? productNameInput.value.trim() : "PROD";
                                                    let prefix = rawPrefix.toUpperCase().replace(/[^A-Z0-9]/g, "-").substring(0, 8);
                                                    if (!prefix) prefix = "PROD";
                                                    colors.forEach(color => {
                                                    sizes.forEach(size => {
                                                    let sanitizedColor = color.toUpperCase().replace(/[^A-Z0-9]/g, "");
                                                    let suggestedSku = prefix + "-" + sanitizedColor + "-" + size;
                                                    htmlRows += "<tr>" +
                                                            "<td>" +
                                                            "<span class='badge bg-primary text-white me-1'>Color: " + color + "</span> " +
                                                            "<span class='badge bg-dark text-white'>Size: " + size + "</span>" +
                                                            "<input type='hidden' name='variants[" + index + "].color' value='" + color + "'>" +
                                                            "<input type='hidden' name='variants[" + index + "].size' value='" + size + "'>" +
                                                            "<input type='hidden' name='variants[" + index + "].status' value='ACTIVE'>" +
                                                            "</td>" +
                                                            "<td>" +
                                                            "<input type='text' class='form-control form-control-sm text-uppercase fw-bold' name='variants[" + index + "].skuCode' value='" + suggestedSku + "' required>" +
                                                            "</td>" +
                                                            "</tr>";
                                                    index++;
                                                    });
                                                    });
                                                    matrixBody.innerHTML = htmlRows;
                                                    }
                                                    });
                                                    $('#createProductForm').on('submit', function (e) {
                                                    e.preventDefault();
                                                    Swal.fire({
                                                    title: 'Are you sure?',
                                                            text: "Do you want to save this new product information?",
                                                            icon: 'question',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#3085d6',
                                                            cancelButtonColor: '#6c757d',
                                                            confirmButtonText: 'Yes, save product!'
                                                    }).then((result) => {
                                                    if (result.isConfirmed) {
                                                    Swal.fire({
                                                    title: 'Processing...',
                                                            text: 'Saving data to system registries.',
                                                            allowOutsideClick: false,
                                                            didOpen: function () { Swal.showLoading(); }
                                                    });
                                                    this.submit();
                                                    }
                                                    });
                                                    });
                                                    function deleteProduct(id) {
                                                    Swal.fire({
                                                    title: 'Delete this product?',
                                                            text: "Warning: Product catalog item will be soft-deleted from management tables!",
                                                            icon: 'warning',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#dc3545',
                                                            cancelButtonColor: '#6c757d',
                                                            confirmButtonText: 'Yes, delete it!'
                                                    }).then((result) => {
                                                    if (result.isConfirmed) {
                                                    document.getElementById('hiddenDeleteProductId').value = id;
                                                    document.getElementById('hiddenDeleteForm').submit();
                                                    }
                                                    });
                                                    }

                                                    function openUpdateProductModal(prod) {
                                                    document.getElementById("updateProductId").value = prod.id;
                                                    document.getElementById("updateProductName").value = prod.name;
                                                    document.getElementById("updateProductCategory").value = prod.catId;
                                                    document.getElementById("updateProductBrand").value = prod.brandId;
                                                    document.getElementById("updateProductStatus").value = prod.status;
                                                    document.getElementById("updateProductDesc").value = prod.desc;
                                                    var updateModal = new bootstrap.Modal(document.getElementById('updateProductModal'));
                                                    updateModal.show();
                                                    }

                                                    $('#updateProductForm').on('submit', function (e) {
                                                    e.preventDefault();
                                                    Swal.fire({
                                                    title: 'Confirm Changes?',
                                                            text: 'Are you sure you want to update the information for this product?',
                                                            icon: 'warning',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#ffc107',
                                                            cancelButtonColor: '#6c757d',
                                                            confirmButtonText: 'Yes, save changes!',
                                                            cancelButtonText: 'Cancel'
                                                    }).then((result) => {
                                                    if (result.isConfirmed) {
                                                    Swal.fire({
                                                    title: 'Processing...',
                                                            text: 'Updating product details in the system registry.',
                                                            allowOutsideClick: false,
                                                            didOpen: function () { Swal.showLoading(); }
                                                    });
                                                    this.submit();
                                                    }
                                                    });
                                                    });
        </script>
    </body>
</html>
