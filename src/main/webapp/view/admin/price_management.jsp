<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Price Management</title>

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
                min-height: 100vh;
                padding: 25px;
                background-color: #f3f4f6;
            }

            .summary-card {
                border: none;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            }

            .summary-icon {
                width: 44px;
                height: 44px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 10px;
                font-size: 18px;
            }

            .filter-card, .table-card {
                border: none;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            }

            .price-table th {
                background-color: #1f2937;
                color: white;
                white-space: nowrap;
                font-size: 14px;
            }

            .price-table td {
                vertical-align: middle;
                font-size: 14px;
            }

            .variant-name {
                min-width: 220px;
            }

            .money {
                white-space: nowrap;
                font-weight: 600;
            }

            .status-badge {
                min-width: 95px;
                padding: 7px 10px;
            }

            .filter-label {
                font-size: 13px;
                font-weight: 600;
                color: #4b5563;
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="prices"/>
        </jsp:include>

        <div class="main-content admin-page">
            <div class="container-fluid">

                <c:set var="totalCount" value="0"/>
                <c:set var="unpricedCount" value="0"/>
                <c:set var="belowCostCount" value="0"/>
                <c:set var="discountedCount" value="0"/>

                <c:forEach var="item" items="${priceItems}">
                    <c:set var="totalCount" value="${totalCount + 1}"/>

                    <c:if test="${item.unpriced}">
                        <c:set var="unpricedCount" value="${unpricedCount + 1}"/>
                    </c:if>

                    <c:if test="${item.belowCost}">
                        <c:set var="belowCostCount" value="${belowCostCount + 1}"/>
                    </c:if>

                    <c:if test="${item.discounted}">
                        <c:set var="discountedCount" value="${discountedCount + 1}"/>
                    </c:if>
                </c:forEach>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="fa-solid fa-tags me-2 text-primary"></i>Price Management
                        </h2>
                        <p class="text-muted mb-0">Manage list prices and current sale prices for product variants.</p>
                    </div>
                </div>

                <c:if test="${not empty priceFlashMessage}">
                    <div class="alert ${priceFlashType eq 'success' ? 'alert-success' : 'alert-danger'} alert-dismissible fade show" role="alert">
                        <i class="fa-solid ${priceFlashType eq 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'} me-2"></i>
                        <c:out value="${priceFlashMessage}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="row g-3 mb-4">
                    <div class="col-xl-3 col-md-6">
                        <div class="card summary-card h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="summary-icon bg-primary-subtle text-primary me-3">
                                    <i class="fa-solid fa-boxes-stacked"></i>
                                </div>
                                <div>
                                    <div class="text-muted small">Total Variants</div>
                                    <div class="fs-4 fw-bold">${totalCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card summary-card h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="summary-icon bg-secondary-subtle text-secondary me-3">
                                    <i class="fa-solid fa-circle-question"></i>
                                </div>
                                <div>
                                    <div class="text-muted small">Unpriced</div>
                                    <div class="fs-4 fw-bold">${unpricedCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card summary-card h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="summary-icon bg-danger-subtle text-danger me-3">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                                <div>
                                    <div class="text-muted small">Below Cost</div>
                                    <div class="fs-4 fw-bold">${belowCostCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card summary-card h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="summary-icon bg-success-subtle text-success me-3">
                                    <i class="fa-solid fa-percent"></i>
                                </div>
                                <div>
                                    <div class="text-muted small">Discounted</div>
                                    <div class="fs-4 fw-bold">${discountedCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card filter-card mb-4">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/prices" method="GET">
                            <div class="row g-3 align-items-end">
                                <div class="col-lg-7">
                                    <label for="keyword" class="filter-label mb-1">Search product variant</label>

                                    <div class="input-group">
                                        <span class="input-group-text bg-white">
                                            <i class="fa-solid fa-magnifying-glass text-muted"></i>
                                        </span>

                                        <input type="text"
                                               id="keyword"
                                               name="keyword"
                                               class="form-control"
                                               value="<c:out value='${keyword}'/>"
                                               maxlength="200"
                                               placeholder="Product name, SKU, size or color">
                                    </div>
                                </div>

                                <div class="col-lg-3">
                                    <label for="priceStatus" class="filter-label mb-1">Price status</label>

                                    <select id="priceStatus" name="priceStatus" class="form-select">
                                        <option value="ALL" ${selectedPriceStatus eq 'ALL' ? 'selected' : ''}>All statuses</option>
                                        <option value="UNPRICED" ${selectedPriceStatus eq 'UNPRICED' ? 'selected' : ''}>Unpriced</option>
                                        <option value="BELOW_COST" ${selectedPriceStatus eq 'BELOW_COST' ? 'selected' : ''}>Below cost</option>
                                        <option value="DISCOUNTED" ${selectedPriceStatus eq 'DISCOUNTED' ? 'selected' : ''}>Discounted</option>
                                        <option value="REGULAR" ${selectedPriceStatus eq 'REGULAR' ? 'selected' : ''}>Regular price</option>
                                    </select>
                                </div>

                                <div class="col-lg-2">
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa-solid fa-filter me-1"></i>Apply
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <c:if test="${not empty keyword or selectedPriceStatus ne 'ALL'}">
                                <div class="mt-3">
                                    <a href="${pageContext.request.contextPath}/admin/prices" class="text-decoration-none">
                                        <i class="fa-solid fa-rotate-left me-1"></i>Clear filters
                                    </a>
                                </div>
                            </c:if>
                        </form>
                    </div>
                </div>

                <div class="card table-card">
                    <div class="card-header bg-white border-0 py-3">
                        <h5 class="fw-bold mb-0">
                            <i class="fa-solid fa-list me-2 text-secondary"></i>Variant Price List
                        </h5>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 price-table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Size - Color</th>
                                    <th class="text-end">Cost Price</th>
                                    <th class="text-end">List Price</th>
                                    <th class="text-end">Sale Price</th>
                                    <th class="text-center">Margin</th>
                                    <th class="text-center">Stock</th>
                                    <th class="text-center">Price Status</th>
                                    <th>Last Updated</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="item" items="${priceItems}">
                                    <tr>
                                        <td class="variant-name">
                                            <div class="fw-semibold text-dark">
                                                <c:out value="${item.productName}"/>
                                            </div>

                                            <div class="small text-muted">
                                                Variant ID: ${item.variantId}
                                            </div>
                                        </td>

                                        <td>
                                            <div class="d-flex flex-wrap gap-2">
                                                <span class="badge bg-primary-subtle text-primary border">
                                                    Size: <c:out value="${empty item.size ? 'N/A' : item.size}"/>
                                                </span>

                                                <span class="badge bg-secondary-subtle text-secondary border">
                                                    Color: <c:out value="${empty item.color ? 'N/A' : item.color}"/>
                                                </span>
                                            </div>
                                        </td>

                                        <td class="text-end money">
                                            <fmt:formatNumber value="${item.costPrice}" pattern="#,##0.00"/>VND
                                        </td>

                                        <td class="text-end money">
                                            <c:choose>
                                                <c:when test="${item.listPrice gt 0}">
                                                    $<fmt:formatNumber value="${item.listPrice}" pattern="#,##0.00"/>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">Not set</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-end money">
                                            <c:choose>
                                                <c:when test="${item.salePrice gt 0}">
                                                    $<fmt:formatNumber value="${item.salePrice}" pattern="#,##0.00"/>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">Not set</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.unpriced}">
                                                    <span class="text-muted">—</span>
                                                </c:when>

                                                <c:when test="${item.belowCost}">
                                                    <span class="fw-semibold text-danger">
                                                        <fmt:formatNumber value="${item.marginPercentage}" pattern="#,##0.00"/>%
                                                    </span>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="fw-semibold text-success">
                                                        <fmt:formatNumber value="${item.marginPercentage}" pattern="#,##0.00"/>%
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center">
                                            <span class="badge ${item.stockQuantity gt 0 ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'} border">
                                                ${item.stockQuantity}
                                            </span>
                                        </td>

                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.priceStatus eq 'UNPRICED'}">
                                                    <span class="badge bg-secondary status-badge">Unpriced</span>
                                                </c:when>

                                                <c:when test="${item.priceStatus eq 'BELOW_COST'}">
                                                    <span class="badge bg-danger status-badge">Below Cost</span>
                                                </c:when>

                                                <c:when test="${item.priceStatus eq 'DISCOUNTED'}">
                                                    <span class="badge bg-success status-badge">Discounted</span>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="badge bg-primary status-badge">Regular</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.priceUpdatedAt}">
                                                    <div>
                                                        <fmt:formatDate value="${item.priceUpdatedAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                    </div>

                                                    <div class="small text-muted">
                                                        <c:out value="${empty item.priceUpdatedByName ? 'Unknown admin' : item.priceUpdatedByName}"/>
                                                    </div>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">Not updated yet</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/admin/prices?action=edit&id=${item.variantId}"
                                               class="btn btn-sm btn-outline-primary">
                                                <i class="fa-solid fa-pen-to-square me-1"></i>Edit
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty priceItems}">
                                    <tr>
                                        <td colspan="10" class="text-center py-5 text-muted">
                                            <i class="fa-solid fa-tags fs-2 d-block mb-3"></i>
                                            No product variants match the selected filters.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>