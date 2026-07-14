<%@ page contentType="text/html;charset=UTF-8"
         language="java"
         pageEncoding="UTF-8" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stock Receipt Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
          rel="stylesheet">
    <style>
        body { background: #f8f9fa; }
        .main-content { width: 100%; min-height: 100vh; padding: 25px; }
        .content-card { border: 0; border-radius: 14px; box-shadow: 0 4px 18px rgba(15, 23, 42, .06); }
        .label { color: #6b7280; font-size: .82rem; text-transform: uppercase; }
    </style>
</head>
<body>

<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="inventory"/>
</jsp:include>

<div class="main-content admin-page">
    <div class="container-fluid">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <div class="small fw-semibold text-primary text-uppercase mb-1">Inventory</div>
                <h1 class="h3 mb-1">Stock Receipt Details</h1>
                <p class="text-muted mb-0">
                    <c:out value="${receipt.receiptCode}"/>
                </p>
            </div>
            <a class="btn btn-outline-secondary"
               href="${pageContext.request.contextPath}/admin/inventory?action=list">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to receipts
            </a>
        </div>

        <c:if test="${not empty inventoryFlashMessage}">
            <div class="alert ${inventoryFlashType eq 'success' ? 'alert-success' : 'alert-danger'}">
                <c:out value="${inventoryFlashMessage}"/>
            </div>
        </c:if>

        <div class="card content-card mb-4">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-3"><div class="label">Supplier</div><div><c:out value="${receipt.supplierName}"/></div></div>
                    <div class="col-md-3"><div class="label">Created by</div><div><c:out value="${receipt.createdByName}"/></div></div>
                    <div class="col-md-2"><div class="label">Status</div><div><span class="badge text-bg-secondary"><c:out value="${receipt.status}"/></span></div></div>
                    <div class="col-md-2"><div class="label">Items</div><div><c:out value="${receipt.itemCount}"/></div></div>
                    <div class="col-md-2"><div class="label">Total quantity</div><div><c:out value="${receipt.totalQuantity}"/></div></div>
                    <div class="col-md-4"><div class="label">Created at</div><div><fmt:formatDate value="${receipt.createdAt}" pattern="yyyy-MM-dd HH:mm"/></div></div>
                    <div class="col-md-4"><div class="label">Vendor reference</div><div><c:out value="${receipt.vendorReference}" default="—"/></div></div>
                    <div class="col-md-4"><div class="label">Total cost</div><div class="fw-bold"><fmt:formatNumber value="${receipt.totalAmount}" pattern="#,##0.00"/> VND</div></div>
                </div>

                <c:if test="${not empty receipt.note}">
                    <hr>
                    <div class="label">Note</div>
                    <div><c:out value="${receipt.note}"/></div>
                </c:if>
            </div>
            <c:if test="${receipt.status eq 'DRAFT'}">
                <div class="card-footer d-flex gap-2 justify-content-end">
                    <form method="post" action="${pageContext.request.contextPath}/admin/inventory">
                        <input type="hidden" name="action" value="CANCEL_DRAFT">
                        <input type="hidden" name="receiptId" value="${receipt.id}">
                        <button type="submit" class="btn btn-outline-danger">Cancel draft</button>
                    </form>
                    <form method="post" action="${pageContext.request.contextPath}/admin/inventory">
                        <input type="hidden" name="action" value="CONFIRM_RECEIPT">
                        <input type="hidden" name="receiptId" value="${receipt.id}">
                        <button type="submit" class="btn btn-success">Confirm receipt</button>
                    </form>
                </div>
            </c:if>
        </div>

        <div class="card content-card">
            <div class="card-header fw-semibold">Receipt items</div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Product</th>
                            <th>SKU</th>
                            <th>Attributes</th>
                            <th class="text-end">Quantity</th>
                            <th class="text-end">Unit cost</th>
                            <th class="text-end">Line total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${receiptDetails}">
                            <tr>
                                <td><c:out value="${detail.productName}"/></td>
                                <td><c:out value="${detail.sku}"/></td>
                                <td><c:out value="${detail.attributeDetails}"/></td>
                                <td class="text-end"><c:out value="${detail.quantity}"/></td>
                                <td class="text-end"><fmt:formatNumber value="${detail.unitCost}" pattern="#,##0.00"/> VND</td>
                                <td class="text-end fw-semibold"><fmt:formatNumber value="${detail.lineTotal}" pattern="#,##0.00"/> VND</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty receiptDetails}">
                            <tr><td colspan="6" class="text-center text-muted py-4">No receipt items found.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/admin/common/admin_layout_end.jsp"/>
</body>
</html>
