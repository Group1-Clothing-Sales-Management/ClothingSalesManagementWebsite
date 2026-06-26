<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%-- ĐÃ SỬA CHÍNH: Bổ sung thư viện taglib chức năng hàm fn để hết lỗi 500 --%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Stock Inflow Management - Admin Area</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet"/>
        <style>
            body {
                background-color: #f8f9fa;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            /* Layout đồng bộ với Dashboard và Product */
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
            .table th {
                background-color: #f1f3f5;
                color: #374151;
                font-weight: 700;
            }
            .badge-qty {
                padding: 0.5rem 0.75rem;
                font-size: 0.85rem;
                border-radius: 6px;
            }
        </style>
    </head>
    <body>
        <div class="wrapper">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeTab" value="inventory" />
            </jsp:include>

            <div class="main-content">
                <div class="container-fluid">

                    <c:if test="${param.status eq 'success'}">
                        <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i><strong>Success!</strong> Stock inflow transaction has been processed correctly.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h2 class="h4 mb-1 fw-bold text-dark"><i class="fa-solid fa-download me-2 text-primary"></i>Stock Inflow Logs</h2>
                            <p class="text-muted small mb-0">Historical lists of physical inventory item batches imported to store variants</p>
                        </div>


                   
                        <a href="${pageContext.request.contextPath}/AdminInventory?action=IMPORT_PAGE" class="btn btn-success fw-bold px-4 py-2 shadow-sm">
                            <i class="fa-solid fa-square-plus me-2"></i>Import New Stock Batch
                        </a>
                    </div>

                    <div class="card shadow-sm border-0 rounded-3">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th class="text-center" style="width: 80px;">ID</th>
                                        <th>Batch Code</th>
                                        <th>Product Details (SKU Reference)</th>
                                        <th class="text-center">Initial Qty</th>
                                        <th class="text-center">Current Qty</th>
                                        <th>Cost Price</th>
                                        <th>Sale Price</th>
                                        <th>Imported At</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="batch" items="${importHistory}">
                                        <%-- Tách chuỗi dữ liệu bổ trợ an toàn qua fn:split --%>
                                        <c:set var="parts" value="${fn:split(batch.batchCode, '|')}" />
                                        <tr>
                                            <td class="text-center fw-bold text-secondary">${batch.id}</td>
                                            <td><strong class="text-primary">${parts[0]}</strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:length(parts) > 1}">
                                                        <c:out value="${parts[1]}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Direct Variant Reference (#ID: ${batch.variantId})</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-success-subtle text-success badge-qty border border-success-subtle">${batch.initialQuantity} pcs</span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-warning-subtle text-warning badge-qty border border-warning-subtle">${batch.currentQuantity} pcs</span>
                                            </td>
                                            <td class="fw-bold text-dark">$<fmt:formatNumber value="${batch.costPrice}" type="number" maxFractionDigits="2"/></td>
                                            <td class="fw-bold text-primary">$<fmt:formatNumber value="${batch.salePrice}" type="number" maxFractionDigits="2"/></td>
                                            <td class="text-muted"><fmt:formatDate value="${batch.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty importHistory}">
                                        <tr>
                                            <td colspan="8" class="text-center py-5 text-muted">
                                                <i class="fa-solid fa-inbox fs-2 mb-2 d-block text-secondary"></i>
                                                No stock import batches found in the inventory logs.
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
