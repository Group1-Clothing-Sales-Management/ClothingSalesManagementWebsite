<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Quản Lý Sản Phẩm</title>
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
                        <a href="${pageContext.request.contextPath}/AdminDashboard"><i class="fa-solid fa-chart-line me-2"></i>Tổng quan</a>
                        <a href="${pageContext.request.contextPath}/AdminManageProduct" class="active"><i class="fa-solid fa-box me-2"></i>Quản lý sản phẩm</a>
                        <a href="#"><i class="fa-solid fa-receipt me-2"></i>Đơn hàng</a>
                        <a href="#"><i class="fa-solid fa-users me-2"></i>Khách hàng</a>
                        <a href="#"><i class="fa-solid fa-ticket me-2"></i>Mã giảm giá</a>
                    </div>
                </div>

                <div class="col-md-10 p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                        <h2 class="fw-bold text-dark mb-0">Quản Lý Danh Sách Sản Phẩm</h2>
                        <button class="btn btn-primary fw-semibold" data-bs-toggle="modal" data-bs-target="#addProductModal">
                            <i class="fa-solid fa-plus me-2"></i>Thêm sản phẩm mới
                        </button>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="ps-4" style="width: 80px;">ID</th>
                                            <th style="width: 90px;">Hình ảnh</th> <th>Tên sản phẩm</th>
                                            <th>Đường dẫn mẫu (Slug)</th>
                                            <th>Danh mục</th>
                                            <th>Thương hiệu</th>
                                            <th>Trạng thái</th>
                                            <th class="text-end pe-4" style="width: 150px;">Hành động</th>
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
                                                        <td><span class="badge bg-secondary-subtle text-secondary border">Mã danh mục: ${p.categoryId}</span></td>
                                                        <td><span class="badge bg-light text-dark border">Mã hãng: ${p.brandId}</span></td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${p.status == 'ACTIVE'}">
                                                                    <span class="badge bg-success-subtle text-success border border-success-subtle">Đang bán</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">${p.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-end pe-4">
                                                            <button class="btn btn-sm btn-outline-primary me-1" title="Sửa"><i class="fa-solid fa-pen-to-square"></i></button>
                                                            <button class="btn btn-sm btn-outline-danger" title="Xóa"><i class="fa-solid fa-trash"></i></button>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center py-5 text-muted">
                                                        <i class="fa-regular fa-folder-open fa-2x mb-3 d-block text-secondary"></i>
                                                        Chưa có dữ liệu sản phẩm nào được tìm thấy.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    <div class="modal fade" id="addProductModal" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered modal-lg">
                                            <div class="modal-content border-0 shadow">
                                                <div class="modal-header bg-dark text-white">
                                                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-box-open me-2"></i>Thêm sản phẩm mới</h5>
                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/AdminManageProduct" method="POST" enctype="multipart/form-data">
                                                    <div class="modal-body p-4">
                                                        <div class="row g-3">
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Tên sản phẩm</label>
                                                                <input type="text" class="form-control" name="productName" placeholder="Ví dụ: Áo sơ mi nam Linen" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Đường dẫn mẫu (Slug - SEO)</label>
                                                                <input type="text" class="form-control" name="slug" placeholder="Ví dụ: ao-so-mi-nam-linen" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Thương hiệu</label>
                                                                <select class="form-select" name="brandId" required>
                                                                    <option value="1">Coolmate (ID: 1)</option>
                                                                    <option value="2">Routine (ID: 2)</option>
                                                                    <option value="3">Uniqlo (ID: 3)</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Danh mục phân loại</label>
                                                                <select class="form-select" name="categoryId" required>
                                                                    <option value="3">Áo Thun T-Shirt (ID: 3)</option>
                                                                    <option value="4">Áo Sơ Mi (ID: 4)</option>
                                                                    <option value="5">Quần Jean Nam (ID: 5)</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Ảnh đại diện chính (.jpg/.png)</label>
                                                                <input type="file" class="form-control" name="productImage" accept="image/*" required>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Mô tả ngắn</label>
                                                                <textarea class="form-control" name="shortDescription" rows="2" placeholder="Tóm tắt đặc tính nổi bật của sản phẩm..."></textarea>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Mô tả chi tiết</label>
                                                                <textarea class="form-control" name="longDescription" rows="4" placeholder="Thông số chi tiết, hướng dẫn bảo quản..."></textarea>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Trạng thái phát hành</label>
                                                                <select class="form-select" name="status">
                                                                    <option value="ACTIVE">Kinh doanh tức thì (ACTIVE)</option>
                                                                    <option value="DRAFT">Lưu bản nháp ẩn (DRAFT)</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer bg-light">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                                                        <button type="submit" class="btn btn-primary px-4 fw-semibold">Lưu sản phẩm</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>