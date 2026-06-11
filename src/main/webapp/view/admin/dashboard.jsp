<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.core" %>
<%
    // Nhận diện quyền hiện tại từ Session để làm điều kiện ẩn/hiện giao diện
    String userRole = (session != null) ? (String) session.getAttribute("authRoleName") : null;
    boolean isAdmin = "ADMIN".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard Tổng Hợp - Hệ Thống Quản Lý</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .stat-card {
                border: none;
                border-radius: 10px;
                transition: transform 0.2s;
            }
            .stat-card:hover {
                transform: translateY(-5px);
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

                <jsp:include page="sidebar.jsp">
                    <jsp:param name="activeTab" value="${param.tab == 'products' ? 'products' : 'dashboard'}" />
                </jsp:include>

                <div class="col-md-10 p-4" style="margin-bottom: 80px;">

                    <c:choose>
                        <%-- TÌNH HUỐNG 1: HIỂN THỊ TAB QUẢN LÝ SẢN PHẨM (?tab=products) --%>
                        <c:when test="${param.tab == 'products'}">
                            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                                <h2 class="fw-bold text-dark mb-0">Product Management (<%= userRole%>)</h2>
                                <c:if test="<%= isAdmin%>">
                                    <button class="btn btn-primary fw-semibold" data-bs-toggle="modal" data-bs-target="#addProductModal">
                                        <i class="fa-solid fa-plus me-2"></i>Add New Product
                                    </button>
                                </c:if>
                            </div>

                            <div class="card shadow-sm border-0">
                                <div class="card-body p-0">
                                    <div class="table-responsive">

                                        <%-- BẢNG 1: DÀNH RIÊNG CHO QUYỀN ADMIN --%>
                                        <c:if test="<%= isAdmin%>">
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
                                                            <c:forEach var="p" items="${products}">
                                                                <tr>
                                                                    <td class="ps-4 fw-bold text-secondary">#${p.id}</td>
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
                                                                    <td class="text-end pe-4">
                                                                        <div class="d-flex justify-content-end align-items-center">
                                                                            <button class="btn btn-sm btn-outline-primary me-1 btn-edit" title="Edit"
                                                                                    data-bs-toggle="modal" data-bs-target="#editProductModal"
                                                                                    data-id="${p.id}" data-name="${p.productName}" data-slug="${p.slug}"
                                                                                    data-brand="${p.brandId}" data-category="${p.categoryId}"
                                                                                    data-short="${p.shortDescription}" data-long="${p.longDescription}" data-status="${p.status}"
                                                                                    data-saleprice="0" data-sku="" data-variantid="0">
                                                                                <i class="fa-solid fa-pen-to-square"></i>
                                                                            </button>
                                                                            <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" onsubmit="return confirm('Are you sure?');" style="margin: 0;">
                                                                                <input type="hidden" name="action" value="DELETE">
                                                                                <input type="hidden" name="productId" value="${p.id}">
                                                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete"><i class="fa-solid fa-trash"></i></button>
                                                                            </form>
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
                                        </c:if>

                                        <%-- BẢNG 2: DÀNH RIÊNG CHO QUYỀN STAFF (HIỂN THỊ BIẾN THỂ SKU, MÀU, SIZE) --%>
                                        <c:if test="<%= !isAdmin%>">
                                            <table class="table table-hover align-middle mb-0">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th class="ps-4">Product & Brand</th>
                                                        <th>SKU</th>
                                                        <th class="text-end">Cost Price</th>
                                                        <th class="text-end">Sale Price</th>
                                                        <th class="text-center">Stock</th>
                                                        <th class="text-center">Status</th>
                                                        <th class="text-center" style="width: 120px;">Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${not empty productList}">
                                                            <c:forEach var="item" items="${productList}">
                                                                <tr>
                                                                    <td class="ps-4">
                                                                        <div class="fw-bold text-dark">${item.productName}</div>
                                                                        <span class="badge bg-info text-dark border mt-1">${item.brandName} | ${item.color} - ${item.size}</span>
                                                                    </td>
                                                                    <td class="font-mono small fw-bold text-secondary">${item.sku}</td>
                                                                    <td class="text-end text-muted">${item.costPrice} USD</td>
                                                                    <td class="text-end fw-bold text-dark">${item.salePrice} USD</td>
                                                                    <td class="text-center">
                                                                        <span class="badge ${item.stockQuantity > 0 ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'} border">
                                                                            ${item.stockQuantity} units
                                                                        </span>
                                                                    </td>
                                                                    <td><span class="badge bg-light text-dark border">${item.status}</span></td>
                                                                    <td class="text-center">
                                                                        <button class="btn btn-sm btn-outline-warning btn-edit" title="Update Details"
                                                                                data-bs-toggle="modal" data-bs-target="#editProductModal"
                                                                                data-id="${item.id}" data-name="${item.productName}" data-sku="${item.sku}"
                                                                                data-brand="0" data-category="0" data-short="" data-long="" data-status="${item.status}"
                                                                                data-saleprice="${item.salePrice}" data-variantid="${item.variantId}">
                                                                            <i class="fa-regular fa-pen-to-square"></i>
                                                                        </button>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr><td colspan="7" class="text-center py-5 text-muted">No warehouse data recorded.</td></tr>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </c:if>

                                    </div>
                                </div>
                            </div>
                        </c:when>

                        <%-- TÌNH HUỐNG 2: MẶC ĐỊNH HIỂN THỊ TAB TỔNG QUAN (OVERVIEW DASHBOARD) --%>
                        <c:otherwise>
                            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                                <h2 class="fw-bold text-dark mb-0">Overview Dashboard</h2>
                                <div class="text-muted fw-semibold">
                                    <i class="fa-regular fa-calendar-days me-2"></i>Today: <span id="currentDate"></span>
                                </div>
                            </div>

                            <div class="row g-4 mb-4">
                                <div class="col-md-3">
                                    <div class="card stat-card shadow-sm bg-primary text-white p-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="text-white-50 text-uppercase fw-bold small">Monthly Revenue</h6>
                                                <h3 class="mb-0 fw-bold">45,240,000 VND</h3>
                                            </div>
                                            <div class="bg-white bg-opacity-25 p-3 rounded-circle"><i class="fa-solid fa-money-bill-wave fa-2x"></i></div>
                                        </div>
                                        <div class="mt-3 text-white-50 small"><i class="fa-solid fa-arrow-up me-1"></i> 12% vs. last month</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card stat-card shadow-sm bg-success text-white p-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="text-white-50 text-uppercase fw-bold small">New Orders</h6>
                                                <h3 class="mb-0 fw-bold">128</h3>
                                            </div>
                                            <div class="bg-white bg-opacity-25 p-3 rounded-circle"><i class="fa-solid fa-cart-shopping fa-2x"></i></div>
                                        </div>
                                        <div class="mt-3 text-white-50 small"><i class="fa-solid fa-arrow-up me-1"></i> 5% vs. yesterday</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card stat-card shadow-sm bg-warning text-white p-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="text-white-50 text-uppercase fw-bold small">Total Products</h6>
                                                <h3 class="mb-0 fw-bold">1,420</h3>
                                            </div>
                                            <div class="bg-white bg-opacity-25 p-3 rounded-circle"><i class="fa-solid fa-box fa-2x"></i></div>
                                        </div>
                                        <div class="mt-3 text-white-50 small"><span>Business is active</span></div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card stat-card shadow-sm bg-danger text-white p-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="text-white-50 text-uppercase fw-bold small">Customers</h6>
                                                <h3 class="mb-0 fw-bold">856</h3>
                                            </div>
                                            <div class="bg-white bg-opacity-25 p-3 rounded-circle"><i class="fa-solid fa-users fa-2x"></i></div>
                                        </div>
                                        <div class="mt-3 text-white-50 small"><i class="fa-solid fa-arrow-up me-1"></i> 24 new accounts this week</div>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-4">
                                <div class="col-md-8">
                                    <div class="card border-0 shadow-sm p-4">
                                        <h5 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-chart-area me-2 text-primary"></i>Revenue trend</h5>
                                        <canvas id="revenueChart" style="max-height: 320px;"></canvas>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="card border-0 shadow-sm p-4">
                                        <h5 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-chart-pie me-2 text-success"></i>Category share</h5>
                                        <canvas id="categoryChart" style="max-height: 320px;"></canvas>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </div>
            </div>
        </div>

        <%-- MODAL ADD NEW PRODUCT (Chỉ dành cho Admin) --%>
        <c:if test="<%= isAdmin%>">
            <div class="modal fade" id="addProductModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content border-0 shadow">
                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title fw-bold"><i class="fa-solid fa-box-open me-2"></i>Add New Product</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="INSERT">
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
        </c:if>

        <%-- FORM EDIT DÙNG CHUNG (Mục 4) --%>
        <div class="modal fade" id="editProductModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Edit Product Information</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="UPDATE">
                        <input type="hidden" name="productId" id="edit_productId">
                        <input type="hidden" name="variantId" id="edit_variantId">
                        <input type="hidden" name="sku" id="edit_sku_hidden">

                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label fw-semibold">Product Name</label>
                                    <input type="text" class="form-control" name="productName" id="edit_productName" required>
                                </div>

                                <c:choose>
                                    <c:when test="<%= isAdmin%>">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Slug URL</label>
                                            <input type="text" class="form-control" name="slug" id="edit_slug">
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Mã Quản Lý (SKU)</label>
                                            <input type="text" class="form-control bg-light" id="edit_sku_display" readonly>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold text-danger">Listed Sale Price (USD) *</label>
                                    <input type="number" step="0.01" class="form-control fw-bold" name="salePrice" id="edit_salePrice" min="0" required
                                           <%= !isAdmin ? "readonly style='background-color: #e9ecef;'" : ""%>>
                                    <c:if test="<%= !isAdmin%>">
                                        <small class="text-muted d-block mt-1">(*) Nhân viên Staff không có quyền sửa giá bán lẻ biến thể.</small>
                                    </c:if>
                                </div>

                                <c:if test="<%= isAdmin%>">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Status</label>
                                        <select class="form-select" name="status" id="edit_status">
                                            <option value="ACTIVE">ACTIVE</option>
                                            <option value="DRAFT">DRAFT</option>
                                        </select>
                                    </div>
                                </c:if>
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
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <script>
                                                                                document.addEventListener("DOMContentLoaded", function () {
                                                                                    // Đổ dữ liệu động vào Form Sửa dùng chung khi click nút Edit
                                                                                    document.querySelectorAll('.btn-edit').forEach(button => {
                                                                                        button.addEventListener('click', function () {
                                                                                            document.getElementById('edit_productId').value = this.getAttribute('data-id') || "0";
                                                                                            document.getElementById('edit_productName').value = this.getAttribute('data-name') || "";

                                                                                            const slugInput = document.getElementById('edit_slug');
                                                                                            if (slugInput)
                                                                                                slugInput.value = this.getAttribute('data-slug') || "";

                                                                                            const statusInput = document.getElementById('edit_status');
                                                                                            if (statusInput)
                                                                                                statusInput.value = this.getAttribute('data-status') || "ACTIVE";

                                                                                            const sku = this.getAttribute('data-sku') || "";
                                                                                            document.getElementById('edit_sku_hidden').value = sku;

                                                                                            const skuDisplay = document.getElementById('edit_sku_display');
                                                                                            if (skuDisplay)
                                                                                                skuDisplay.value = sku || "N/A";

                                                                                            document.getElementById('edit_salePrice').value = parseFloat(this.getAttribute('data-saleprice')) || 0;
                                                                                            document.getElementById('edit_variantId').value = this.getAttribute('data-variantid') || "0";
                                                                                        });
                                                                                    });
                                                                                });

                                                                                const now = new Date();
                                                                                if (document.getElementById('currentDate')) {
                                                                                    document.getElementById('currentDate').innerText = now.toLocaleDateString('en-US');
                                                                                }
                                                                                const ctxRevenue = document.getElementById('revenueChart');
                                                                                if (ctxRevenue) {
                                                                                    new Chart(ctxRevenue.getContext('2d'), {
                                                                                        type: 'line',
                                                                                        data: {
                                                                                            labels: ['Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5', 'Month 6'],
                                                                                            datasets: [{
                                                                                                    label: 'Revenue (VND)',
                                                                                                    data: [15000000, 22000000, 18000000, 29000000, 35000000, 45240000],
                                                                                                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                                                                                                    borderColor: '#0d6efd',
                                                                                                    borderWidth: 3,
                                                                                                    tension: 0.3,
                                                                                                    fill: true
                                                                                                }]
                                                                                        },
                                                                                        options: {responsive: true, plugins: {legend: {display: false}}}
                                                                                    });
                                                                                }
                                                                                const ctxCategory = document.getElementById('categoryChart');
                                                                                if (ctxCategory) {
                                                                                    new Chart(ctxCategory.getContext('2d'), {
                                                                                        type: 'doughnut',
                                                                                        data: {
                                                                                            labels: ['T-shirts', 'Shirts', 'Jeans', 'Dresses'],
                                                                                            datasets: [{
                                                                                                    data: [40, 25, 20, 15],
                                                                                                    backgroundColor: ['#0d6efd', '#198754', '#ffc107', '#dc3545']
                                                                                                }]
                                                                                        },
                                                                                        options: {responsive: true}
                                                                                    });
                                                                                }
        </script>
    </body>
</html>