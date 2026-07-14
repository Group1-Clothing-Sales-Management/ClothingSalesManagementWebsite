<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product Price</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

    <style>
        body { background: #f5f7fb; font-family: system-ui, -apple-system, sans-serif; }
        .main-content { width: 100%; min-height: 100vh; padding: 28px; }
        .page-card { border: 0; border-radius: 16px; box-shadow: 0 8px 25px rgba(15, 23, 42, .06); }
        .info-box { background: #f8fafc; border: 1px solid #e5e7eb; border-radius: 12px; padding: 14px; }
        .info-label { color: #6b7280; font-size: .78rem; font-weight: 700; text-transform: uppercase; }
        .info-value { color: #111827; font-size: 1rem; font-weight: 700; margin-top: 4px; }
        .money { font-variant-numeric: tabular-nums; }
        .history-table th { white-space: nowrap; font-size: .82rem; }
        .history-table td { vertical-align: middle; font-size: .88rem; }
        .price-preview { background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 16px; }
        .warning-box { display: none; background: #fff7ed; border: 1px solid #fdba74; border-radius: 10px; padding: 12px; }
    </style>
</head>

<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="prices"/>
</jsp:include>

<div class="main-content admin-page">
    <div class="container-fluid">

        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <div class="small fw-semibold text-primary text-uppercase mb-1">Price Management</div>
                <h1 class="h3 fw-bold mb-1">
                    <i class="fa-solid fa-pen-to-square me-2 text-primary"></i>Edit Product Price
                </h1>
                <p class="text-muted mb-0">
                    Update the list price and current sale price of this variant.
                </p>
            </div>

            <a href="${pageContext.request.contextPath}/admin/prices" class="btn btn-outline-secondary">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to Price List
            </a>
        </div>

        <c:if test="${not empty priceFlashMessage}">
            <div class="alert ${priceFlashType eq 'success' ? 'alert-success' : 'alert-danger'} alert-dismissible fade show">
                <i class="fa-solid ${priceFlashType eq 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'} me-2"></i>
                <c:out value="${priceFlashMessage}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card page-card mb-4">
            <div class="card-header bg-white py-3">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-shirt me-2 text-primary"></i>Variant Information
                </h5>
            </div>

            <div class="card-body">
                <div class="mb-4">
                    <h4 class="fw-bold mb-1">
                        <c:out value="${priceItem.displayName}"/>
                    </h4>
                    <span class="badge bg-light text-dark border">
                        SKU: <c:out value="${priceItem.sku}"/>
                    </span>
                </div>

                <div class="row g-3">
                    <div class="col-xl-3 col-md-6">
                        <div class="info-box h-100">
                            <div class="info-label">Cost Price</div>
                            <div class="info-value money">
                                <fmt:formatNumber value="${priceItem.costPrice}" pattern="#,##0.00"/> VND
                            </div>
                            <div class="small text-muted mt-1">Updated by Inventory</div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="info-box h-100">
                            <div class="info-label">Current List Price</div>
                            <div class="info-value money">
                                <fmt:formatNumber value="${priceItem.listPrice}" pattern="#,##0.00"/> VND
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="info-box h-100">
                            <div class="info-label">Current Sale Price</div>
                            <div class="info-value money">
                                <fmt:formatNumber value="${priceItem.salePrice}" pattern="#,##0.00"/> VND
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="info-box h-100">
                            <div class="info-label">Current Margin</div>
                            <div class="info-value ${priceItem.belowCost ? 'text-danger' : 'text-success'}">
                                <fmt:formatNumber value="${priceItem.marginPercentage}" pattern="#,##0.00"/>%
                            </div>
                            <div class="small text-muted mt-1">Stock: ${priceItem.stockQuantity}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty priceItem.priceUpdatedAt}">
                    <div class="small text-muted mt-3">
                        Last updated:
                        <fmt:formatDate value="${priceItem.priceUpdatedAt}" pattern="yyyy-MM-dd HH:mm"/>
                        by
                        <c:out value="${empty priceItem.priceUpdatedByName ? 'Unknown admin' : priceItem.priceUpdatedByName}"/>
                    </div>
                </c:if>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-xl-7">
                <div class="card page-card h-100">
                    <div class="card-header bg-white py-3">
                        <h5 class="fw-bold mb-0">
                            <i class="fa-solid fa-tags me-2 text-primary"></i>Update Price
                        </h5>
                    </div>

                    <div class="card-body">
                        <form id="priceForm" action="${pageContext.request.contextPath}/admin/prices?action=update" method="POST">
                            <input type="hidden" name="variantId" value="${priceItem.variantId}">
                            <input type="hidden" id="costPrice" value="${priceItem.costPrice}">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="listPrice" class="form-label fw-semibold">List Price</label>
                                    <div class="input-group">
                                        <input type="number" id="listPrice" name="listPrice" class="form-control"
                                               value="${priceItem.listPrice}" min="0.01" step="0.01" required>
                                        <span class="input-group-text">VND</span>
                                    </div>
                                    <div class="form-text">Original price displayed before discount.</div>
                                </div>

                                <div class="col-md-6">
                                    <label for="salePrice" class="form-label fw-semibold">Sale Price</label>
                                    <div class="input-group">
                                        <input type="number" id="salePrice" name="salePrice" class="form-control"
                                               value="${priceItem.salePrice}" min="0.01" step="0.01" required>
                                        <span class="input-group-text">VND</span>
                                    </div>
                                    <div class="form-text">Current price charged to customers.</div>
                                </div>

                                <div class="col-12">
                                    <div id="belowCostWarning" class="warning-box">
                                        <i class="fa-solid fa-triangle-exclamation text-warning me-2"></i>
                                        The sale price is below cost. A change reason is required.
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label for="reason" class="form-label fw-semibold">Change Reason</label>
                                    <textarea id="reason" name="reason" class="form-control" rows="3" maxlength="500"
                                              placeholder="Example: Seasonal discount, market price adjustment..."></textarea>
                                    <div class="form-text">Required when selling below cost.</div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <a href="${pageContext.request.contextPath}/admin/prices" class="btn btn-light border">
                                    Cancel
                                </a>

                                <button type="submit" class="btn btn-primary px-4">
                                    <i class="fa-solid fa-floppy-disk me-2"></i>Save Price
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-xl-5">
                <div class="card page-card h-100">
                    <div class="card-header bg-white py-3">
                        <h5 class="fw-bold mb-0">
                            <i class="fa-solid fa-chart-simple me-2 text-primary"></i>Price Preview
                        </h5>
                    </div>

                    <div class="card-body">
                        <div class="price-preview">
                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Estimated profit</span>
                                <strong id="profitPreview">0 VND</strong>
                            </div>

                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Gross margin</span>
                                <strong id="marginPreview">0%</strong>
                            </div>

                            <div class="d-flex justify-content-between">
                                <span class="text-muted">Discount from list price</span>
                                <strong id="discountPreview">0%</strong>
                            </div>
                        </div>

                        <div class="alert alert-info mt-3 mb-0">
                            <i class="fa-solid fa-circle-info me-2"></i>
                            Cost price cannot be edited here. It is calculated by the inventory process.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card page-card">
            <div class="card-header bg-white py-3">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-clock-rotate-left me-2 text-primary"></i>Price History
                </h5>
            </div>

            <div class="table-responsive">
                <table class="table table-hover mb-0 history-table">
                    <thead>
                        <tr>
                            <th>Changed At</th>
                            <th>Changed By</th>
                            <th>Type</th>
                            <th class="text-end">Old List Price</th>
                            <th class="text-end">New List Price</th>
                            <th class="text-end">Old Sale Price</th>
                            <th class="text-end">New Sale Price</th>
                            <th>Reason</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach var="history" items="${priceHistory}">
                            <tr>
                                <td class="text-nowrap">
                                    <fmt:formatDate value="${history.changedAt}" pattern="yyyy-MM-dd HH:mm"/>
                                </td>

                                <td>
                                    <c:out value="${history.changedByNameSnapshot}"/>
                                </td>

                                <td>
                                    <span class="badge bg-light text-dark border">
                                        <c:out value="${history.changeType}"/>
                                    </span>
                                </td>

                                <td class="text-end money">
                                    <c:choose>
                                        <c:when test="${not empty history.oldListPrice}">
                                            <fmt:formatNumber value="${history.oldListPrice}" pattern="#,##0.00"/>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end money">
                                    <fmt:formatNumber value="${history.newListPrice}" pattern="#,##0.00"/>
                                </td>

                                <td class="text-end money">
                                    <c:choose>
                                        <c:when test="${not empty history.oldSalePrice}">
                                            <fmt:formatNumber value="${history.oldSalePrice}" pattern="#,##0.00"/>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end money">
                                    <fmt:formatNumber value="${history.newSalePrice}" pattern="#,##0.00"/>
                                </td>

                                <td style="min-width: 190px;">
                                    <c:out value="${empty history.changeReason ? 'No reason provided' : history.changeReason}"/>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty priceHistory}">
                            <tr>
                                <td colspan="8" class="text-center text-muted py-5">
                                    <i class="fa-regular fa-folder-open fs-2 d-block mb-2"></i>
                                    No price history found.
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

<script>
    const costInput = document.getElementById("costPrice");
    const listInput = document.getElementById("listPrice");
    const saleInput = document.getElementById("salePrice");
    const reasonInput = document.getElementById("reason");
    const warningBox = document.getElementById("belowCostWarning");

    function formatMoney(value) {
        return new Intl.NumberFormat("vi-VN", {maximumFractionDigits: 2}).format(value) + " VND";
    }

    function updatePreview() {
        const cost = Number(costInput.value) || 0;
        const listPrice = Number(listInput.value) || 0;
        const salePrice = Number(saleInput.value) || 0;

        const profit = salePrice - cost;
        const margin = salePrice > 0 ? profit / salePrice * 100 : 0;
        const discount = listPrice > 0 && salePrice < listPrice ? (listPrice - salePrice) / listPrice * 100 : 0;
        const belowCost = salePrice > 0 && salePrice < cost;

        document.getElementById("profitPreview").textContent = formatMoney(profit);
        document.getElementById("marginPreview").textContent = margin.toFixed(2) + "%";
        document.getElementById("discountPreview").textContent = discount.toFixed(2) + "%";

        warningBox.style.display = belowCost ? "block" : "none";
        reasonInput.required = belowCost;
    }

    document.getElementById("priceForm").addEventListener("submit", function (event) {
        const listPrice = Number(listInput.value);
        const salePrice = Number(saleInput.value);

        if (salePrice > listPrice) {
            event.preventDefault();
            alert("Sale price cannot be greater than list price.");
        }
    });

    listInput.addEventListener("input", updatePreview);
    saleInput.addEventListener("input", updatePreview);
    updatePreview();
</script>
</body>
</html>