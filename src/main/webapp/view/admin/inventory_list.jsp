<%@ page contentType="text/html;charset=UTF-8"
         language="java"
         pageEncoding="UTF-8" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Stock Receipts</title>

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <link
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
        rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            background: #f8f9fa;
            font-family: system-ui, -apple-system, sans-serif;
        }

        .main-content {
            width: 100%;
            min-height: 100vh;
            padding: 25px;
        }

        .page-heading {
            color: #1f2937;
            font-size: 1.55rem;
            font-weight: 750;
        }

        .content-card {
            border: 0;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(15, 23, 42, .06);
        }

        .table th {
            color: #4b5563;
            font-size: .82rem;
            white-space: nowrap;
        }

        .money {
            font-variant-numeric: tabular-nums;
        }

        .status-badge {
            min-width: 95px;
        }
    </style>
</head>

<body>

<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="inventory"/>
</jsp:include>

<div class="main-content admin-page">
    <div class="container-fluid">

        <c:if test="${not empty inventoryFlashMessage}">
            <div class="alert
                        ${inventoryFlashType eq 'success'
                          ? 'alert-success'
                          : 'alert-danger'}">

                <c:out value="${inventoryFlashMessage}"/>
            </div>
        </c:if>

        <div class="d-flex flex-wrap
                    justify-content-between
                    align-items-center
                    gap-3 mb-4">

            <div>
                <div class="small fw-semibold
                            text-primary text-uppercase mb-1">
                    Inventory
                </div>

                <h1 class="page-heading mb-1">
                    <i class="fa-solid
                              fa-file-invoice-dollar
                              me-2 text-primary"></i>
                    Stock Receipts
                </h1>

                <p class="text-muted mb-0">
                    Create, review, and confirm incoming stock.
                </p>
            </div>

            <a href="${pageContext.request.contextPath}/admin/inventory?action=IMPORT_PAGE"
               class="btn btn-success px-4">

                <i class="fa-solid fa-plus me-2"></i>
                New Stock Receipt
            </a>
        </div>

        <div class="card content-card">
            <div class="card-body p-0">

                <div class="table-responsive">
                    <table class="table
                                  table-hover
                                  align-middle mb-0">

                        <thead class="table-light">
                            <tr>
                                <th>Receipt Code</th>
                                <th>Supplier</th>
                                <th>Created By</th>
                                <th class="text-center">Items</th>
                                <th class="text-center">
                                    Total Qty
                                </th>
                                <th class="text-end">
                                    Total Cost
                                </th>
                                <th>Created At</th>
                                <th class="text-center">
                                    Status
                                </th>
                                <th class="text-end">
                                    Actions
                                </th>
                            </tr>
                        </thead>

                        <tbody>

                        <c:forEach var="receipt"
                                   items="${receipts}">

                            <tr>
                                <td>
                                    <a class="fw-bold
                                              text-decoration-none"
                                       href="${pageContext.request.contextPath}/admin/inventory?action=DETAIL&id=${receipt.id}">

                                        <c:out value="${receipt.receiptCode}"/>
                                    </a>

                                    <c:if test="${not empty receipt.vendorReference}">
                                        <div class="small text-muted">
                                            Vendor:
                                            <c:out value="${receipt.vendorReference}"/>
                                        </div>
                                    </c:if>
                                </td>

                                <td>
                                    <c:out value="${receipt.supplierName}"/>
                                </td>

                                <td>
                                    <c:out value="${receipt.createdByName}"/>
                                </td>

                                <td class="text-center">
                                    ${receipt.itemCount}
                                </td>

                                <td class="text-center fw-semibold">
                                    ${receipt.totalQuantity}
                                </td>

                                <td class="text-end fw-bold money">
                                    <fmt:formatNumber
                                        value="${receipt.totalAmount}"
                                        pattern="#,##0.00"/>
                                    VND
                                </td>

                                <td class="text-muted">
                                    <fmt:formatDate
                                        value="${receipt.createdAt}"
                                        pattern="yyyy-MM-dd HH:mm"/>
                                </td>

                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${receipt.status eq 'DRAFT'}">
                                            <span class="badge
                                                         text-bg-warning
                                                         status-badge">
                                                DRAFT
                                            </span>
                                        </c:when>

                                        <c:when test="${receipt.status eq 'COMPLETED'}">
                                            <span class="badge
                                                         text-bg-success
                                                         status-badge">
                                                COMPLETED
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="badge
                                                         text-bg-secondary
                                                         status-badge">
                                                <c:out value="${receipt.status}"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end text-nowrap">
                                    <a href="${pageContext.request.contextPath}/admin/inventory?action=DETAIL&id=${receipt.id}"
                                       class="btn btn-sm
                                              btn-outline-primary">

                                        <i class="fa-regular
                                                  fa-eye me-1"></i>
                                        View
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty receipts}">
                            <tr>
                                <td colspan="9"
                                    class="text-center
                                           text-muted py-5">

                                    <i class="fa-regular
                                              fa-folder-open
                                              fs-2 d-block mb-2"></i>

                                    No stock receipts found.
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

<jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">
</script>

</body>
</html>