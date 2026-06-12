<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Specification Details</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <style>
            body {
                background-color: #f3f4f6;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            /* Đồng bộ Layout với Dashboard */
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
            .hero-img {
                width: 100%;
                max-height: 250px;
                object-fit: contain;
                background: #f9fafb;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>

        <div class="wrapper">
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <div class="container-fluid">
                    <div class="mb-4">
                        <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-arrow-left me-2"></i>Back to Product Catalog
                        </a>
                    </div>

                    <div class="card detail-card shadow-sm p-4 mb-4">
                        <div class="row g-4">
                            <div class="col-md-3 text-center">
                                <img src="${pageContext.request.contextPath}/${product.mainImageUrl != null ? product.mainImageUrl : 'assets/img/default-product.png'}" class="hero-img border p-2" alt="product-image">
                            </div>
                            <div class="col-md-9 d-flex flex-column justify-content-center">
                                <span class="badge bg-primary mb-2 align-self-start py-2 px-3 fs-6 rounded-3">ID: PROD-${product.id}</span>
                                <h1 class="h3 fw-bold text-dark mb-2">${product.productName}</h1>
                                <p class="text-muted mb-3">${product.longDescription != null ? product.longDescription : 'No description provided for this catalog item.'}</p>

                                <div class="row text-sm">
                                    <div class="col-sm-4">
                                        <div class="text-secondary small mb-1">CATEGORY ID</div>
                                        <div class="fw-bold text-dark fs-5">${product.categoryId}</div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="text-secondary small mb-1">BRAND ID</div>
                                        <div class="fw-bold text-dark fs-5">${product.brandId}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card detail-card shadow-sm p-4">
                        <div class="mb-3">
                            <h3 class="h5 mb-0 fw-bold text-dark"><i class="fa-solid fa-layer-group me-2 text-info"></i>Available Product Variants & Inventory</h3>
                        </div>

                        <c:choose>
                            <c:when test="${not empty variants}">
                                <div class="table-responsive">
                                    <table class="table table-striped table-hover align-middle border text-center variant-table mb-0">
                                        <thead>
                                            <tr>
                                                <th style="width: 120px;">Variant ID</th>
                                                <th>SKU Code</th>
                                                <th>Stock Quantity</th>
                                                <th>Cost Price</th>
                                                <th>Sale Price</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="v" items="${variants}">
                                                <tr>
                                                    <td class="fw-bold text-secondary">#VAR-${v.id}</td>
                                                    <td><span class="badge bg-dark px-3 py-1.5">${v.sku}</span></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.stockQuantity > 10}">
                                                                <span class="text-success fw-bold fs-5">${v.stockQuantity}</span>
                                                            </c:when>
                                                            <c:when test="${v.stockQuantity > 0}">
                                                                <span class="text-warning fw-bold fs-5">${v.stockQuantity} (Low Stock)</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-danger fw-bold">Out of Stock</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="fw-bold text-secondary">$${v.costPrice}</td>
                                                    <td class="fw-bold text-primary">$${v.salePrice}</td>
                                                    <td>
                                                        <span class="badge ${v.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">${v.status}</span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-warning mb-0 text-center py-4" role="alert">
                                    <i class="fa-solid fa-triangle-exclamation fs-3 mb-2 d-block"></i>
                                    No product variants found for this product catalog.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>