<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Security Access Control Check --%>
<c:if test="${empty sessionScope.user || (sessionScope.user.role != 1 && sessionScope.user.role != 2)}">
    <%
        request.setAttribute("errorMessage", "Unauthorized access. Please login with a valid account.");
        response.sendRedirect(request.getContextPath() + "/login");
    %>
</c:if>
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
                        <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line me-2"></i>Dashboard</a>
                        <a href="${pageContext.request.contextPath}/admin/manage-product" class="active"><i class="fa-solid fa-box me-2"></i>Manage Products</a>
                        <a href="${pageContext.request.contextPath}/staff/orders"><i class="fa-solid fa-receipt me-2"></i>Orders</a>
                        <a href="#"><i class="fa-solid fa-users me-2"></i>Customers</a>
                    </div>
                </div>

                <div class="col-md-10 p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                        <h2 class="fw-bold text-dark mb-0">Product Management</h2>
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
                                            <th class="ps-4">ID</th>
                                            <th>Image</th>
                                            <th>Product Name</th>
                                            <th>Slug</th>
                                            <th>Category ID</th>
                                            <th>Brand ID</th>
                                            <th>Status</th>
                                            <th class="text-end pe-4" style="width: 150px;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty products}">
                                                <c:forEach var="p" items="${products}" varStatus="loop">
                                                    <tr data-bs-toggle="collapse" data-bs-target="#variants-row-${p.id}" class="clickable-row" style="cursor: pointer;" title="Click to view variants">
                                                        <td class="ps-4 fw-bold text-secondary">
                                                            <i class="fa-solid fa-chevron-right me-2 small text-muted"></i>#${p.id}
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty p.mainImageUrl}">
                                                                    <img src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}" class="img-thumbnail rounded shadow-sm" style="width: 50px; height: 50px; object-fit: cover;">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="bg-light border text-muted d-flex align-items-center justify-content-center rounded" style="width: 50px; height: 50px; font-size: 11px;">No Img</div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td><span class="fw-semibold text-dark">${p.productName}</span></td>
                                                        <td><code class="text-muted small">${p.slug}</code></td>
                                                        <td><span class="badge bg-secondary-subtle text-secondary border">ID: ${p.categoryId}</span></td>
                                                        <td><span class="badge bg-light text-dark border">ID: ${p.brandId}</span></td>
                                                        <td><span class="badge ${p.status == 'ACTIVE' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'} border">${p.status}</span></td>
                                                        <td class="text-end pe-4" onclick="event.stopPropagation();">
                                                            <div class="d-flex justify-content-end align-items-center">
                                                                <button class="btn btn-sm btn-outline-primary me-1 btn-edit" title="Edit"
                                                                        data-bs-toggle="modal" data-bs-target="#editProductModal"
                                                                        data-id="${p.id}" data-name="${p.productName}" data-slug="${p.slug}"
                                                                        data-brand="${p.brandId}" data-category="${p.categoryId}"
                                                                        data-short="${p.shortDescription}" data-long="${p.longDescription}" data-status="${p.status}">
                                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                                </button>
                                                                <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" onsubmit="return confirm('Are you sure you want to delete this product?');" style="margin: 0;">
                                                                    <input type="hidden" name="action" value="DELETE">
                                                                    <input type="hidden" name="productId" value="${p.id}">
                                                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                                                        <i class="fa-solid fa-trash"></i>
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </td>
                                                    </tr>

                                                    <tr id="variants-row-${p.id}" class="collapse bg-light-subtle">
                                                        <td colspan="8" class="p-3">
                                                            <div class="px-4 py-2 border rounded bg-white shadow-sm">
                                                                <h6 class="fw-bold text-primary mb-3"><i class="fa-solid fa-tags me-2"></i>SKU Variants for ${p.productName}</h6>
                                                                <table class="table table-sm table-bordered align-middle mb-0">
                                                                    <thead class="table-secondary small">
                                                                        <tr>
                                                                            <th>Variant ID</th>
                                                                            <th>SKU Code</th>
                                                                            <th>Size / Color / Attribute</th>
                                                                            <th>Total Stock</th>
                                                                            <th>Cost Price (Latest)</th>
                                                                            <th>Sale Price</th>
                                                                            <th class="text-center" style="width: 180px;">Inventory Actions</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <%-- Giả định kiến trúc BE đã map danh sách variants vào đối tượng product 'p.variants' --%>
                                                                        <c:choose>
                                                                            <c:when test="${not empty p.variants}">
                                                                                <c:forEach var="v" items="${p.variants}">
                                                                                    <tr>
                                                                                        <td class="fw-bold text-secondary">#${v.id}</td>
                                                                                        <td><span class="badge bg-dark">${v.sku}</span></td>
                                                                                        <td>${v.attributeDetails}</td>
                                                                                        <td>
                                                                                            <span class="badge ${v.stockQuantity > 0 ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}">
                                                                                                ${v.stockQuantity} pcs
                                                                                            </span>
                                                                                        </td>
                                                                                        <td>$${v.costPrice}</td>
                                                                                        <td>$${v.salePrice}</td>
                                                                                        <td class="text-center">
                                                                                            <%-- Strict Role Filter: Chỉ Admin (role == 1) mới thấy nút Import Goods --%>
                                                                                            <c:if test="${sessionScope.user.role == 1}">
                                                                                                <button class="btn btn-xs btn-success btn-sm fw-semibold text-white btn-import" 
                                                                                                        data-bs-toggle="modal" 
                                                                                                        data-bs-target="#importGoodsModal"
                                                                                                        data-variant-id="${v.id}"
                                                                                                        data-sku="${v.sku}"
                                                                                                        data-product-name="${p.productName}">
                                                                                                    <i class="fa-solid fa-file-import me-1"></i>Import Goods
                                                                                                </button>
                                                                                            </c:if>
                                                                                            <c:if test="${sessionScope.user.role != 1}">
                                                                                                <span class="text-muted small"><i class="fa-solid fa-lock me-1"></i>View Only</span>
                                                                                            </c:if>
                                                                                        </td>
                                                                                    </tr>
                                                                                </c:forEach>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <tr>
                                                                                    <td colspan="7" class="text-center text-muted small py-2">No SKU variants generated for this product yet.</td>
                                                                                </tr>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr><td colspan="8" class="text-center py-5 text-muted">No product data found.</td></tr>
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
                    <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Slug URL</label>
                                    <input type="text" class="form-control" name="slug" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Brand</label>
                                    <select class="form-select" name="brandId" required>
                                        <c:forEach var="b" items="${brands}">
                                            <option value="${b.id}">${b.brandName} (ID: ${b.id})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select" name="categoryId" required>
                                        <c:forEach var="c" items="${categories}">
                                            <option value="${c.id}">${c.categoryName} (ID: ${c.id})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Product Image</label>
                                    <input type="file" class="form-control" name="productImage" accept="image/*" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Short Description</label>
                                    <textarea class="form-control" name="shortDescription" rows="2"></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Detailed Description</label>
                                    <textarea class="form-control" name="longDescription" rows="4"></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Status</label>
                                    <select class="form-select" name="status">
                                        <option value="ACTIVE">ACTIVE</option>
                                        <option value="DRAFT">DRAFT</option>
                                    </select>
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
        </div>

        <div class="modal fade" id="editProductModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Edit Product</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="UPDATE">
                        <input type="hidden" name="productId" id="edit_productId">
                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" id="edit_productName" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Slug URL</label>
                                    <input type="text" class="form-control" name="slug" id="edit_slug" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Brand</label>
                                    <select class="form-select" name="brandId" id="edit_brandId" required>
                                        <c:forEach var="b" items="${brands}">
                                            <option value="${b.id}">${b.brandName} (ID: ${b.id})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select" name="categoryId" id="edit_categoryId" required>
                                        <c:forEach var="c" items="${categories}">
                                            <option value="${c.id}">${c.categoryName} (ID: ${c.id})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Product Image (leave blank to keep the current image)</label>
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
                                    <label class="form-label fw-semibold">Status</label>
                                    <select class="form-select" name="status" id="edit_status">
                                        <option value="ACTIVE">ACTIVE</option>
                                        <option value="DRAFT">DRAFT</option>
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
        <div class="modal fade" id="importGoodsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-boxes-stacked me-2"></i>Import Goods (New FIFO Batch)</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/inventory" method="POST">
                        <input type="hidden" name="action" value="import">
                        <input type="hidden" name="variantId" id="import_variantId">

                        <div class="modal-body p-4">
                            <div class="mb-3">
                                <label class="form-label fw-semibold text-muted small d-block">Target Product / SKU</label>
                                <div class="p-2 bg-light border rounded fw-bold text-dark" id="import_productDetailsDisplay"></div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Batch Code</label>
                                <input type="text" class="form-control" name="batchCode" placeholder="e.g., BATCH-2026-06-A" required>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Cost Price (Input)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">$</span>
                                        <input type="number" step="0.01" class="form-control" name="costPrice" required min="0">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Sale Price (New Update)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">$</span>
                                        <input type="number" step="0.01" class="form-control" name="salePrice" required min="0">
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Quantity to Import</label>
                                <input type="number" class="form-control" name="initialQuantity" required min="1">
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success px-4 fw-semibold">Execute Import</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>             

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                document.addEventListener("DOMContentLoaded", function () {
                                    document.querySelectorAll('.btn-edit').forEach(button => {
                                        button.addEventListener('click', function () {
                                            document.getElementById('edit_productId').value = this.getAttribute('data-id');
                                            document.getElementById('edit_productName').value = this.getAttribute('data-name');
                                            document.getElementById('edit_slug').value = this.getAttribute('data-slug');
                                            document.getElementById('edit_brandId').value = this.getAttribute('data-brand');
                                            document.getElementById('edit_categoryId').value = this.getAttribute('data-category');
                                            document.getElementById('edit_shortDescription').value = this.getAttribute('data-short');
                                            document.getElementById('edit_longDescription').value = this.getAttribute('data-long');
                                            document.getElementById('edit_status').value = this.getAttribute('data-status');
                                        });
                                    });
                                });
                                // JavaScript binding dữ liệu động cho Form Nhập kho FIFO
                                document.querySelectorAll('.btn-import').forEach(button => {
                                    button.addEventListener('click', function () {
                                        const variantId = this.getAttribute('data-variant-id');
                                        const sku = this.getAttribute('data-sku');
                                        const productName = this.getAttribute('data-product-name');

                                        document.getElementById('edit_productId').value = this.getAttribute('data-id'); // Gán ID variant vào hidden field
                                        document.getElementById('import_variantId').value = variantId;
                                        document.getElementById('import_productDetailsDisplay').innerText = productName + " (SKU: " + sku + ")";
                                    });
                                });
        </script>
    </body>
</html>
