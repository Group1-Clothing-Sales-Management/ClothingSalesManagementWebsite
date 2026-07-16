<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Product Management</title>
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
            .product-img {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #e5e7eb;
            }
            .variant-table th {
                background-color: #1f2937 !important;
                color: #fff !important;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="main-content admin-page">
            <div class="container-fluid">
                <c:if test="${not empty successMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMessage}"/></div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                </c:if>

                <div class="page-header">
                    <h2 class="page-title">
                        <i class="fa-solid fa-box-open me-2 text-primary"></i>Product Management
                    </h2>
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
                                    <th style="width: 230px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="prod" items="${products}">
                                    <tr>
                                        <td class="fw-bold text-secondary">#PROD-${prod.id}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty prod.mainImageUrl}">
                                                    <img src="${pageContext.request.contextPath}/uploads/product/${prod.mainImageUrl}"
                                                         class="product-img shadow-sm" alt="Product Image">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/uploads/product/default.jpg"
                                                         class="product-img shadow-sm" alt="No Image">
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-start"><span class="fw-semibold text-dark">${prod.productName}</span></td>
                                        <td><span class="badge bg-light text-dark border px-2 py-1">${prod.categoryId}</span></td>
                                        <td><span class="badge bg-light text-dark border px-2 py-1">${prod.brandId}</span></td>
                                        <td>
                                            <span class="badge ${prod.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'} px-3 py-1">
                                                ${prod.status}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/StaffManageProducts?action=view&id=${prod.id}"
                                               class="btn btn-sm btn-outline-info me-1 px-3">
                                                <i class="fa-solid fa-eye"></i> View
                                            </a>
                                            <c:if test="${not empty prod.variants}">
                                                <a href="${pageContext.request.contextPath}/StaffManageProducts?action=edit&sku=${prod.variants[0].sku}"
                                                   class="btn btn-sm btn-outline-warning px-3">
                                                    <i class="fa-solid fa-pen-to-square"></i> Edit
                                                </a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty products}">
                                    <tr>
                                        <td colspan="7" class="text-center py-4 text-muted">No products found.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
