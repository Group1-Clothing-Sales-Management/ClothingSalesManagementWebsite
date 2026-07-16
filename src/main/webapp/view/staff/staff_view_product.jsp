<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Product Details - Staff Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f3f4f6;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                min-height: 100vh;
                background-color: #f3f4f6;
            }
            .product-main-image {
                max-height: 220px;
                max-width: 100%;
                object-fit: contain;
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
                    <div>
                        <h1 class="page-title">Product Details</h1>
                        <p class="page-subtitle mb-0">Inspect the product master record and its current variants.</p>
                    </div>
                    <c:if test="${not empty variants}">
                        <a href="${pageContext.request.contextPath}/StaffManageProducts?action=edit&sku=${variants[0].sku}"
                           class="btn btn-primary">
                            <i class="fa-solid fa-pen-to-square me-1"></i>Edit Info
                        </a>
                    </c:if>
                </div>

                <div class="card card-main admin-card mb-4">
                    <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Product Core Profile</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 text-center border-end">
                                <c:choose>
                                    <c:when test="${not empty product.mainImageUrl}">
                                        <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                                             alt="Main Image" class="img-fluid rounded img-thumbnail product-main-image">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bg-light d-flex align-items-center justify-content-center rounded" style="height: 180px;">
                                            <span class="text-muted">No Image Available</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="col-md-9">
                                <h3>${product.productName}
                                    <span class="badge bg-secondary text-sm" style="font-size: 14px;">ID: #${product.id}</span>
                                </h3>
                                <p class="text-muted fst-italic mb-2">Slug URL: ${product.slug}</p>
                                <div class="row mb-3">
                                    <div class="col-sm-4">
                                        <strong>Status:</strong>
                                        <span class="badge ${product.status == 'ACTIVE' ? 'bg-success' : 'bg-warning text-dark'}">${product.status}</span>
                                    </div>
                                </div>
                                <p><strong>Short Description:</strong> ${product.shortDescription}</p>
                                <p><strong>Long Description:</strong> ${product.longDescription}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card card-main admin-card mb-4">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">Current Stock Variants</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped mb-0 admin-table">
                                <thead>
                                    <tr>
                                        <th>Variant ID</th>
                                        <th>SKU Code</th>
                                        <th>Combination Details</th>
                                        <th>Stock Qty</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="variant" items="${variants}">
                                        <tr>
                                            <td>#${variant.id}</td>
                                            <td><strong class="font-monospace text-primary">${variant.sku}</strong></td>
                                            <td>${variant.attributeDetails}</td>
                                            <td>
                                                <span class="badge ${variant.stockQuantity > 0 ? 'bg-success' : 'bg-secondary'}">
                                                    ${variant.stockQuantity} Available
                                                </span>
                                            </td>
                                            <td class="align-middle text-center" style="width: 180px;">
                                                <span class="badge ${variant.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'} px-3 py-2 rounded-pill">
                                                    ${variant.status == 'ACTIVE' ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty variants}">
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">No variants created for this product profile yet.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
