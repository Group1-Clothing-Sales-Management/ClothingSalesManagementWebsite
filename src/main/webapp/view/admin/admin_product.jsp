<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Kiểm tra an toàn phân quyền đồng bộ hệ thống --%>
<c:if test="${empty sessionScope.authUserId || (sessionScope.authRoleName != 'ADMIN' && sessionScope.authRoleName != 'STAFF')}">
    <%
        response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
    %>
</c:if>
<%-- Hỗ trợ cả hai kiểu dữ liệu từ AdminDashboard --%>
<c:if test="${empty products && not empty productList}">
    <c:set var="products" value="${productList}" scope="request"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - Advanced Workspace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .main-content-wrapper {
            margin-bottom: 60px;
        }
        .clickable-product-row {
            cursor: pointer;
            transition: background-color 0.15s ease;
        }
        .clickable-product-row:hover {
            background-color: rgba(13, 110, 253, 0.04) !important;
        }
        .variant-nested-box {
            background-color: #f8f9fa;
            border-left: 4px solid #0d6efd;
            border-radius: 0 6px 6px 0;
        }
        .img-preview-sm {
            width: 48px;
            height: 48px;
            object-fit: cover;
            border-radius: 6px;
        }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">
        
        <%-- Khối Sidebar dùng chung được nhúng tự động từ hệ thống --%>
        <jsp:include page="sidebar.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="col-md-10 p-4 main-content-wrapper">
            
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                <div>
                    <h2 class="fw-bold text-dark mb-1">Product Hub</h2>
                    <p class="text-muted small mb-0">Bấm trực tiếp vào hàng sản phẩm để mở rộng/thu gọn danh sách biến thể chi tiết.</p>
                </div>
                <c:if test="${sessionScope.authRoleName == 'ADMIN'}">
                    <button class="btn btn-primary fw-semibold px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#addProductModal">
                        <i class="fa-solid fa-plus me-2"></i>Add Master Product123
                    </button>
                </c:if>
            </div>

            <c:if test="${param.status == 'success'}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i> <strong>Thành công!</strong> Đã thực hiện nhập kho lô hàng mới (FIFO) và cập nhật số lượng tổng.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${param.status == 'error'}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i> <strong>Thất bại!</strong> Đã xảy ra lỗi hệ thống hoặc sai định dạng số liệu đầu vào.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <div class="card shadow-sm border-0 overflow-hidden">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light text-uppercase fs-7 tracking-wider text-secondary">
                                <tr>
                                    <th class="ps-4" style="width: 100px;">ID</th>
                                    <th style="width: 80px;">Ảnh</th>
                                    <th>Tên Sản Phẩm</th>
                                    <th>Đường Dẫn (Slug)</th>
                                    <th class="text-center">Trạng Thái</th>
                                    <th class="text-end pe-4" style="width: 160px;">Thao Tác gốc</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty products}">
                                        <c:forEach var="p" items="${products}">
                                            
                                            <tr data-bs-toggle="collapse" data-bs-target="#variants-collapse-${p.id}" class="clickable-product-row">
                                                <td class="ps-4 fw-bold text-primary">
                                                    <i class="fa-solid fa-chevron-right me-2 small text-muted text-transition"></i>#${p.id}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty p.mainImageUrl}">
                                                            <img src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}" class="img-preview-sm border shadow-xs">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="bg-light border text-muted d-flex align-items-center justify-content-center text-xs" style="width: 48px; height: 48px; border-radius: 6px;">No Img</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="fw-bold text-dark mb-0">${p.productName}</div>
                                                    <span class="text-xs text-muted">Danh mục: ID ${p.categoryId} | Thương hiệu: ID ${p.brandId}</span>
                                                </td>
                                                <td><code class="text-muted small">${p.slug}</code></td>
                                                <td class="text-center">
                                                    <span class="badge ${p.status == 'ACTIVE' ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning'} border px-2 py-1">${p.status}</span>
                                                </td>
                                                <td class="text-end pe-4" onclick="event.stopPropagation();">
                                                    <div class="d-flex justify-content-end align-items-center gap-1">
                                                        <c:if test="${sessionScope.authRoleName == 'ADMIN'}">
                                                            <button class="btn btn-sm btn-outline-primary btn-edit" title="Sửa sản phẩm mẹ"
                                                                    data-bs-toggle="modal" data-bs-target="#editProductModal"
                                                                    data-id="${p.id}" data-name="${p.productName}" data-slug="${p.slug}"
                                                                    data-brand="${p.brandId}" data-category="${p.categoryId}"
                                                                    data-short="${p.shortDescription}" data-long="${p.longDescription}" data-status="${p.status}">
                                                                <i class="fa-solid fa-pen-to-square"></i>
                                                            </button>
                                                            <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" onsubmit="return confirm('Xác nhận xóa cứng/mềm sản phẩm này kèm toàn bộ biến thể liên quan?');" style="margin: 0;">
                                                                <input type="hidden" name="action" value="DELETE">
                                                                <input type="hidden" name="productId" value="${p.id}">
                                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa thông minh">
                                                                    <i class="fa-solid fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${sessionScope.authRoleName != 'ADMIN'}">
                                                            <span class="text-muted text-xs"><i class="fa-solid fa-lock"></i> Chỉ xem</span>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>

                                            <tr id="variants-collapse-${p.id}" class="collapse bg-light-subtle">
                                                <td colspan="6" class="p-3">
                                                    <div class="variant-nested-box p-3 bg-white border shadow-sm ms-4">
                                                        <div class="d-flex justify-content-between align-items-center mb-2 border-bottom pb-2">
                                                            <span class="fw-bold text-secondary text-sm"><i class="fa-solid fa-tags me-2 text-primary"></i>Danh Sách Biến Thể Quản Lý Kho (SKU)</span>
                                                            <span class="badge bg-dark text-xs">${not empty p.variants ? p.variants.size() : 0} Biến thể</span>
                                                        </div>
                                                        
                                                        <table class="table table-sm table-bordered align-middle mb-0 text-sm">
                                                            <thead class="table-light text-muted font-weight-normal text-xs">
                                                                <tr>
                                                                    <th>Variant ID</th>
                                                                    <th>Mã Định Danh (SKU)</th>
                                                                    <th>Thuộc Tính Cấu Hình</th>
                                                                    <th class="text-center">Tồn Kho hiện tại</th>
                                                                    <th class="text-end">Giá Vốn Lô Mới</th>
                                                                    <th class="text-end">Giá Bán Niêm Yết</th>
                                                                    <th class="text-center" style="width: 160px;">Hành Động Kho</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty p.variants}">
                                                                        <c:forEach var="v" items="${p.variants}">
                                                                            <tr>
                                                                                <td class="fw-bold text-secondary">#${v.id}</td>
                                                                                <td><span class="badge bg-dark font-monospace">${v.sku}</span></td>
                                                                                <td class="text-muted"><c:out value="${v.attributeDetails}" default="Mẫu Tiêu Chuẩn (Standard)"/></td>
                                                                                <td class="text-center">
                                                                                    <span class="badge ${v.stockQuantity > 0 ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'} px-2">
                                                                                        ${v.stockQuantity} sản phẩm
                                                                                    </span>
                                                                                </td>
                                                                                <td class="text-end text-muted">$${v.costPrice}</td>
                                                                                <td class="text-end fw-bold text-dark">$${v.salePrice}</td>
                                                                                <td class="text-center">
                                                                                    <%-- HIỂN THỊ NÚT IMPORT HOÀN CHỈNH CHO ADMIN --%>
                                                                                    <c:choose>
                                                                                        <c:when test="${sessionScope.authRoleName == 'ADMIN'}">
                                                                                            <button class="btn btn-xs btn-success btn-sm fw-semibold text-white btn-import" 
                                                                                                    data-bs-toggle="modal" 
                                                                                                    data-bs-target="#importGoodsModal"
                                                                                                    data-variant-id="${v.id}"
                                                                                                    data-sku="${v.sku}"
                                                                                                    data-product-name="${p.productName}">
                                                                                                <i class="fa-solid fa-file-import me-1"></i>Import Goods
                                                                                            </button>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="text-muted text-xs"><i class="fa-solid fa-lock me-1"></i>View Only</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="7" class="text-center text-muted small py-2">Sản phẩm này chưa được tạo mã biến thể SKU độc lập.</td>
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
                                        <tr><td colspan="6" class="text-center py-5 text-muted">Hệ thống trống. Không tìm thấy dữ liệu sản phẩm nào hợp lệ.</td></tr>
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

<div class="modal fade" id="importGoodsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-boxes-stacked me-2"></i>Nhập Hàng Vào Kho (New FIFO Batch)</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/inventory" method="POST">
                <input type="hidden" name="action" value="import">
                <input type="hidden" name="variantId" id="import_variantId">

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-muted small d-block">Mục tiêu xử lý / SKU</label>
                        <div class="p-2 bg-light border rounded fw-bold text-dark" id="import_productDetailsDisplay"></div>
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Giá Nhập Gốc (Cost Price)</label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" step="0.01" class="form-control" name="costPrice" required min="0">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Giá Bán Mới (Sale Price)</label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" step="0.01" class="form-control" name="salePrice" required min="0">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Số Lượng Thực Nhập (Quantity)</label>
                        <input type="number" class="form-control" name="quantity" required min="1">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Ghi Chú Đợt Nhập (Note)</label>
                        <input type="text" class="form-control" name="note" placeholder="Ví dụ: Nhập bổ sung kho tháng 6">
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-success px-4 fw-semibold">Xác Nhận Nhập Lô</button>
                </div>
            </form>
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
                                    <option value="${b.id}">${b.brandName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Category</label>
                            <select class="form-select" name="categoryId" required>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.id}">${c.categoryName}</option>
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
                                    <option value="${b.id}">${b.brandName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Category</label>
                            <select class="form-select" name="categoryId" id="edit_categoryId" required>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.id}">${c.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Product Image (leave blank to keep current)</label>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // VỊ TRÍ 2: BẮT SỰ KIỆN ĐỔ DỮ LIỆU ĐỘNG CHO MODAL NHẬP HÀNG FIFO
        document.querySelectorAll('.btn-import').forEach(button => {
            button.addEventListener('click', function (e) {
                // Ngăn hiện tượng đóng/mở hàng cha khi click nút con trong bảng ẩn
                e.stopPropagation();

                const variantId = this.getAttribute('data-variant-id');
                const sku = this.getAttribute('data-sku');
                const productName = this.getAttribute('data-product-name');

                document.getElementById('import_variantId').value = variantId;
                document.getElementById('import_productDetailsDisplay').innerText = productName + " (SKU: " + sku + ")";
            });
        });

        // Đổ dữ liệu cho Form Edit thông tin sản phẩm gốc
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

        // Xử lý xoay icon góc khi đóng mở Collapse để tăng trải nghiệm UI
        document.querySelectorAll('.bg-light-subtle').forEach(collapseRow => {
            collapseRow.addEventListener('show.bs.collapse', function () {
                let rowHead = this.previousElementSibling;
                let icon = rowHead.querySelector('.fa-chevron-right');
                if(icon) icon.style.transform = 'rotate(90deg)';
            });
            collapseRow.addEventListener('hide.bs.collapse', function () {
                let rowHead = this.previousElementSibling;
                let icon = rowHead.querySelector('.fa-chevron-right');
                if(icon) icon.style.transform = 'rotate(0deg)';
            });
        });
    });
</script>
</body>
</html>