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

        <div class="wrapper">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeTab" value="products" />
            </jsp:include>

            <div class="main-content">
                <div class="container-fluid">

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2 class="text-dark fw-bold mb-0">
                            <i class="fa-solid fa-box-open me-2 text-primary"></i>Product Management
                        </h2>
                        <button class="btn btn-primary px-4 py-2 rounded-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#createProductModal">
                            <i class="fa-solid fa-plus me-1"></i> Add New Product
                        </button>
                    </div>

                    <div class="card detail-card shadow-sm p-4">
                        <div class="mb-3">
                            <h3 class="h5 mb-0 fw-bold text-dark">
                                <i class="fa-solid fa-list me-2 text-secondary"></i>Product Catalog List
                            </h3>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-striped table-hover align-middle border text-center variant-table mb-0">
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
        </div>

        <div class="modal fade" id="createProductModal" tabindex="-1" aria-labelledby="createProductModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content" style="border-radius: 12px; border: none;">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold" id="createProductModalLabel"><i class="fa-solid fa-square-plus text-primary me-2"></i>Create New Product</h5>
                        <button type="button" class="btn-close" data-bs-toggle="modal" aria-label="Close"></button>
                    </div>
                    <form id="createProductForm" action="${pageContext.request.contextPath}/AdminManageProduct?action=ADD" method="POST" enctype="multipart/form-data">
                        <div class="modal-body bg-light">

                            <div class="card detail-card shadow-sm p-4">
                                <div class="fw-bold mb-3 text-dark"><i class="fa-solid fa-info-circle me-2 text-info"></i>Product Information</div>
                                <div class="row g-3">
                                    <div class="col-md-12">
                                        <label class="form-label fw-semibold">Product Name <span class="text-danger">*</span></label>
                                        <input type="text" name="productName" class="form-control" placeholder="e.g. Premium Cotton T-Shirt" required>
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
                                        <textarea name="longDescription" class="form-control" rows="4" placeholder="Write product highlights here..."></textarea>
                                        <input type="hidden" name="shortDescription" value="">
                                    </div>
                                </div>
                            </div>

                        </div>
                        <div class="modal-footer border-top bg-light">
                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary px-4"><i class="fa-solid fa-floppy-disk me-1"></i> Save Product</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
                                                    // Intercept form để tạo popup xác nhận bằng SweetAlert2
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
                                                                    didOpen: function () {
                                                                        Swal.showLoading();
                                                                    }
                                                                });
                                                                this.submit(); // Submit form lên Backend xử lý
                                                            }
                                                        });
                                                    });

                                                    function deleteProduct(id) {
                                                        Swal.fire({
                                                            title: 'Delete this product?',
                                                            text: "Warning: Product catalog item will be hidden from management tables!",
                                                            icon: 'warning',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#dc3545',
                                                            cancelButtonColor: '#6c757d',
                                                            confirmButtonText: 'Yes, delete it!'
                                                        }).then((result) => {
                                                            if (result.isConfirmed) {
                                                                window.location.href = '${pageContext.request.contextPath}/AdminManageProduct?action=DELETE&productId=' + id;
                                                            }
                                                        });
                                                    }
        </script>
    </body>
</html>