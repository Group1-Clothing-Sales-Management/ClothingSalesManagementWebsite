<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Management</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <style>
            body {
                background-color: #f8f9fa;
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
                background-color: #f8f9fa;
            }
            .product-img {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 6px;
            }
            .table th {
                background-color: #f1f3f5;
                color: #374151;
                font-weight: 700;
            }
            .action-btns .btn, .action-btns form {
                display: inline-block;
                vertical-align: middle;
            }
            .action-btns .btn {
                padding: .35rem .65rem;
                font-size: .875rem;
            }
        </style>
    </head>
    <body>

        <div class="wrapper">
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <div class="container-fluid">
                    
                    <c:if test="${param.status == 'success'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <strong>Thành công!</strong> Thao tác xử lý dữ liệu sản phẩm hoàn tất.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${param.status == 'error'}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <strong>Thất bại!</strong> Hệ thống hoặc tệp tin hình ảnh tải lên gặp lỗi ngầm.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2 class="h4 mb-0 fw-bold text-dark"><i class="fa-solid fa-box me-2 text-primary"></i>Product Catalog</h2>
                        <div>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                                <i class="fa-solid fa-plus me-2"></i>Add New Product
                            </button>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 rounded-3">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-center" style="width: 80px;">Image</th>
                                        <th>Product Name</th>
                                        <th>Category ID</th>
                                        <th>Brand ID</th>
                                        <th class="text-center">Status</th>
                                        <th class="text-center" style="width: 220px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="p" items="${products}">
                                        <tr>
                                            <td class="text-center">
                                                <img src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl != null ? p.mainImageUrl : 'default-product.png'}" class="product-img border" alt="product">
                                            </td>
                                            <td>
                                                <div class="fw-bold text-dark">${p.productName}</div>
                                                <small class="text-muted">Slug: <code>${p.slug}</code></small>
                                            </td>
                                            <td><span class="badge bg-light text-dark border">ID: ${p.categoryId}</span></td>
                                            <td><span class="badge bg-light text-dark border">ID: ${p.brandId}</span></td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${p.status == 'ACTIVE'}">
                                                        <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1.5 rounded-pill">Active</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2.5 py-1.5 rounded-pill">${p.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center action-btns">
                                                <button class="btn btn-outline-primary me-1" data-bs-toggle="modal" data-bs-target="#editProductModal${p.id}" title="Edit">
                                                    <i class="fa-solid fa-pen"></i>
                                                </button>

                                                <form action="${pageContext.request.contextPath}/admin/manage-product?action=DELETE" method="POST" onsubmit="return confirm('Are you sure you want to delete this product?');" style="margin:0;">
                                                    <input type="hidden" name="productId" value="${p.id}">
                                                    <button type="submit" class="btn btn-outline-danger" title="Delete">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <c:forEach var="p" items="${products}">
            <div class="modal fade" id="editProductModal${p.id}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content border-0 shadow">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Edit Product #${p.id}</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/admin/manage-product?action=UPDATE" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="productId" value="${p.id}">
                            <div class="modal-body text-start p-4">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Product Name</label>
                                        <input type="text" class="form-control" name="productName" value="${p.productName}" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Slug URL</label>
                                        <input type="text" class="form-control" name="slug" value="${p.slug}" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Brand ID</label>
                                        <input type="number" class="form-control" name="brandId" value="${p.brandId}" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Category ID</label>
                                        <input type="number" class="form-control" name="categoryId" value="${p.categoryId}" required>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Product Image (Leave blank to keep current)</label>
                                        <input type="file" class="form-control" name="productImage" accept="image/*">
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Short Description</label>
                                        <textarea class="form-control" name="shortDescription" rows="2">${p.shortDescription}</textarea>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Detailed Description</label>
                                        <textarea class="form-control" name="longDescription" rows="4">${p.longDescription}</textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Status</label>
                                        <select class="form-select" name="status">
                                            <option value="ACTIVE" ${p.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                            <option value="DRAFT" ${p.status == 'DRAFT' ? 'selected' : ''}>DRAFT</option>
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
        </c:forEach>

        <div class="modal fade" id="addProductModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-box-open me-2"></i>Add New Master Product</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/manage-product?action=ADD" method="POST" enctype="multipart/form-data">
                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" placeholder="E.g. Premium T-Shirt" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Slug URL</label>
                                    <input type="text" class="form-control" name="slug" placeholder="premium-t-shirt" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Brand ID</label>
                                    <input type="number" class="form-control" name="brandId" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category ID</label>
                                    <input type="number" class="form-control" name="categoryId" required>
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>