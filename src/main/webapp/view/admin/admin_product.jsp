<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Product Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .sidebar {
                min-height: 100vh;
                background: #212529;
                color: #fff;
            }
            .sidebar a {
                color: #adb5bd;
                text-decoration: none;
                display: block;
                padding: 12px 20px;
                transition: 0.2s;
            }
            .sidebar a:hover, .sidebar a.active {
                background: #343a40;
                color: #fff;
                border-left: 4px solid #0d6efd;
            }
            .table-responsive {
                background: #fff;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>

        <div class="container-fluid">
            <div class="row">
                <div class="col-md-2 px-0 sidebar d-none d-md-block shadow">
                    <div class="p-3 text-center border-bottom border-secondary">
                        <h4 class="text-white mb-0 fw-bold"><i class="fa-solid fa-shirt me-2"></i>Clothing Sale</h4>
                    </div>
                    <div class="py-2">
                        <a href="${pageContext.request.contextPath}/AdminDashboard"><i class="fa-solid fa-chart-line me-2"></i>Dashboard</a>
                        <a href="${pageContext.request.contextPath}/AdminManageProduct" class="active"><i class="fa-solid fa-box me-2"></i>Manage Products</a>
                        <a href="#"><i class="fa-solid fa-receipt me-2"></i>Orders</a>
                        <a href="#"><i class="fa-solid fa-users me-2"></i>Customers</a>
                        <a href="#"><i class="fa-solid fa-ticket me-2"></i>Vouchers</a>
                    </div>
                </div>

                <div class="col-md-10 p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                        <h2 class="fw-bold text-dark mb-0">Product List Management</h2>
                        <button class="btn btn-primary fw-semibold" data-bs-toggle="modal" data-bs-target="#addProductModal">
                            <i class="fa-solid fa-plus me-2"></i>Add New Product
                        </button>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="ps-4" style="width: 80px;">ID</th>
                                            <th style="width: 90px;">Image</th> 
                                            <th>Product Name</th>
                                            <th>Slug URL</th>
                                            <th>Category</th>
                                            <th>Brand</th>
                                            <th>Status</th>
                                            <th class="text-end pe-4" style="width: 150px;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty products}">
                                                <c:forEach var="p" items="${products}">
                                                    <tr>
                                                        <td class="ps-4 fw-bold text-secondary">#${p.id}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty p.mainImageUrl}">
                                                                    <img src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}" 
                                                                         alt="${p.productName}" 
                                                                         class="img-thumbnail rounded shadow-sm" 
                                                                         style="width: 55px; height: 55px; object-fit: cover;">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="bg-light border text-muted d-flex align-items-center justify-content-center rounded" 
                                                                         style="width: 55px; height: 55px; font-size: 11px;">No Img</div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td><span class="fw-semibold text-dark">${p.productName}</span></td>
                                                        <td><code class="text-muted small">${p.slug}</code></td>
                                                        <td><span class="badge bg-secondary-subtle text-secondary border">Category ID: ${p.categoryId}</span></td>
                                                        <td><span class="badge bg-light text-dark border">Brand ID: ${p.brandId}</span></td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${p.status == 'ACTIVE'}">
                                                                    <span class="badge bg-success-subtle text-success border border-success-subtle">Active</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">${p.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-end pe-4">
                                                            <button class="btn btn-sm btn-outline-primary me-1 btn-edit" title="Update"
                                                                    data-bs-toggle="modal" data-bs-target="#editProductModal"
                                                                    data-id="${p.id}"
                                                                    data-name="${p.productName}"
                                                                    data-slug="${p.slug}"
                                                                    data-brand="${p.brandId}"
                                                                    data-category="${p.categoryId}"
                                                                    data-short="${p.shortDescription}"
                                                                    data-long="${p.longDescription}"
                                                                    data-status="${p.status}">
                                                                <i class="fa-solid fa-pen-to-square"></i>
                                                            </button>
                                                            <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="fa-solid fa-trash"></i></button>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center py-5 text-muted">
                                                        <i class="fa-regular fa-folder-open fa-2x mb-3 d-block text-secondary"></i>
                                                        No product data found.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="addProductModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-box-open me-2"></i>Add New Product</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/AdminManageProduct" method="POST" enctype="multipart/form-data">
                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" placeholder="e.g., Men's Linen Shirt" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Slug URL (SEO)</label>
                                    <input type="text" class="form-control" name="slug" placeholder="e.g., mens-linen-shirt" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Brand</label>
                                    <select class="form-select" name="brandId" required>
                                        <option value="1">Coolmate (ID: 1)</option>
                                        <option value="2">Routine (ID: 2)</option>
                                        <option value="3">Uniqlo (ID: 3)</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select" name="categoryId" required>
                                        <option value="3">T-Shirt (ID: 3)</option>
                                        <option value="4">Shirt (ID: 4)</option>
                                        <option value="5">Men's Jeans (ID: 5)</option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Main Thumbnail Image (.jpg/.png)</label>
                                    <input type="file" class="form-control" name="productImage" accept="image/*" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Short Description</label>
                                    <textarea class="form-control" name="shortDescription" rows="2" placeholder="Brief summarize the key product features..."></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Detailed Description</label>
                                    <textarea class="form-control" name="longDescription" rows="4" placeholder="Detailed specifications, maintenance guidelines..."></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Publish Status</label>
                                    <select class="form-select" name="status">
                                        <option value="ACTIVE">Active (Instant Sale)</option>
                                        <option value="DRAFT">Draft (Hidden)</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 fw-semibold">Save Product</button>
                </div>
                </form>
            </div>
        </div>

        <div class="modal fade" id="editProductModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Edit Product Details</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/AdminManageProduct" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="UPDATE">
                        <input type="hidden" name="productId" id="edit_productId">

                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" id="edit_productName" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Slug URL (SEO)</label>
                                    <input type="text" class="form-control" name="slug" id="edit_slug" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Brand</label>
                                    <select class="form-select" name="brandId" id="edit_brandId" required>
                                        <option value="1">Coolmate (ID: 1)</option>
                                        <option value="2">Routine (ID: 2)</option>
                                        <option value="3">Uniqlo (ID: 3)</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select" name="categoryId" id="edit_categoryId" required>
                                        <option value="3">T-Shirt (ID: 3)</option>
                                        <option value="4">Shirt (ID: 4)</option>
                                        <option value="5">Men's Jeans (ID: 5)</option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Main Thumbnail Image (Leave empty to keep current image)</label>
                                    <input type="file" class="form-control" name="productImage" accept="image/*">
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Short Description</label>
                                    <textarea class="form-control" name="shortDescription" id="edit_shortDescription" rows="2"></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Detailed Description</label>
                                    <textarea class="form-control" name="longDescription" id="edit_longDescription" rows="4"></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Publish Status</label>
                                    <select class="form-select" name="status" id="edit_status">
                                        <option value="ACTIVE">Active</option>
                                        <option value="DRAFT">Draft</option>
                                        <option value="OUT_OF_STOCK">Out of Stock</option>
                                        <option value="HIDDEN">Hidden</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary px-4 fw-semibold">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Select all elements holding the triggering edit event class
                const editButtons = document.querySelectorAll('.btn-edit');

                editButtons.forEach(button => {
                    button.addEventListener('click', function () {
                        // Extract meta properties injected within JSTL rows
                        const id = this.getAttribute('data-id');
                        const name = this.getAttribute('data-name');
                        const slug = this.getAttribute('data-slug');
                        const brandId = this.getAttribute('data-brand');
                        const categoryId = this.getAttribute('data-category');
                        const shortDesc = this.getAttribute('data-short');
                        const longDesc = this.getAttribute('data-long');
                        const status = this.getAttribute('data-status');

                        // Bind the metadata values asynchronously onto form targets
                        document.getElementById('edit_productId').value = id;
                        document.getElementById('edit_productName').value = name;
                        document.getElementById('edit_slug').value = slug;
                        document.getElementById('edit_brandId').value = brandId;
                        document.getElementById('edit_categoryId').value = categoryId;
                        document.getElementById('edit_shortDescription').value = shortDesc;
                        document.getElementById('edit_longDescription').value = longDesc;
                        document.getElementById('edit_status').value = status;
                    });
                });
            });
        </script>
    </body>
</html>