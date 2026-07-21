<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Returns & Refunds</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        body { background:#f7f7f8; color:#292524; }
        .returns-page { width:100%; max-width:1100px; margin:30px auto 60px; padding:0 16px; }
        .returns-card { border:0; border-radius:16px; box-shadow:0 8px 24px rgba(0,0,0,.06); }
        .status { border-radius:20px; padding:6px 11px; font-size:12px; font-weight:700; }
        .status-PENDING,.status-INFO_REQUIRED { background:#fff3cd; color:#856404; }
        .status-APPROVED,.status-RECEIVED { background:#dbeafe; color:#1d4ed8; }
        .status-REFUND_PENDING { background:#ede9fe; color:#6d28d9; }
        .status-COMPLETED { background:#dcfce7; color:#166534; }
        .status-REJECTED { background:#fee2e2; color:#b91c1c; }
    </style>
</head>
<body>
    <jsp:include page="/view/customer/common/header.jsp"/>
    <main class="returns-page">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
            <div><h1 class="h3 fw-bold mb-1"><i class="fa-solid fa-rotate-left text-primary me-2"></i>Returns & Refunds</h1><p class="text-muted mb-0">Submit and track your return or exchange requests.</p></div>
            <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-outline-secondary">Back to My Orders</a>
        </div>

        <c:if test="${not empty successMsg}"><div class="alert alert-success">${successMsg}</div></c:if>
        <c:if test="${not empty errorMsg}"><div class="alert alert-danger">${errorMsg}</div></c:if>

        <c:if test="${param.action eq 'create'}">
            <div class="card returns-card mb-4">
                <div class="card-body p-4">
                    <c:choose>
                        <c:when test="${not empty selectedOrder}">
                            <h2 class="h5 fw-bold mb-1">Create a return request</h2>
                            <p class="text-muted">Order <strong>${selectedOrder.orderCode}</strong> · Return window: 14 days</p>
                            <form method="post" action="${pageContext.request.contextPath}/customer/returns">
                                <input type="hidden" name="orderId" value="${selectedOrder.id}">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6"><label class="form-label fw-semibold">Request type</label><select name="type" class="form-select" required><option value="RETURN">Return & refund</option><option value="EXCHANGE">Exchange product</option></select></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold">Reason</label><select name="reason" class="form-select" required><option value="">Select a reason</option><option value="WRONG_ITEM">Wrong item received</option><option value="DAMAGED">Product is damaged</option><option value="WRONG_SIZE">Wrong size or fit</option><option value="NOT_AS_DESCRIBED">Not as described</option><option value="CHANGE_OF_MIND">Changed my mind</option></select></div>
                                </div>
                                <label class="form-label fw-semibold">Products and quantities</label>
                                <div class="table-responsive border rounded mb-3"><table class="table align-middle mb-0"><thead><tr><th>Product</th><th>Variant</th><th>Ordered</th><th style="width:130px">Return qty</th></tr></thead><tbody>
                                    <c:forEach var="item" items="${returnItems}"><tr><td>${item.productNameSnapshot}</td><td>${item.variantAttributesSnapshot}</td><td>${item.orderedQuantity}</td><td><input type="hidden" name="detailId" value="${item.orderDetailId}"><input type="number" name="quantity_${item.orderDetailId}" class="form-control" min="0" max="${item.orderedQuantity}" value="0"></td></tr></c:forEach>
                                </tbody></table></div>
                                <label class="form-label fw-semibold">Additional information</label><textarea name="customerNote" class="form-control mb-3" rows="3" maxlength="1000" placeholder="Tell us what happened..."></textarea>
                                <button class="btn btn-primary" type="submit"><i class="fa-solid fa-paper-plane me-1"></i>Submit request</button>
                            </form>
                        </c:when>
                        <c:otherwise><div class="alert alert-warning mb-0">This order is not eligible for a new return request.</div></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <div class="card returns-card"><div class="card-body p-0">
            <div class="p-4 border-bottom"><h2 class="h5 fw-bold mb-0">My requests</h2></div>
            <c:choose><c:when test="${empty returnRequests}"><div class="p-5 text-center text-muted">You have no return requests yet.</div></c:when><c:otherwise>
                <div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr><th class="ps-4">Request</th><th>Order</th><th>Type / Reason</th><th>Refund amount</th><th>Status</th><th>Requested</th></tr></thead><tbody>
                    <c:forEach var="item" items="${returnRequests}"><tr><td class="ps-4"><strong>${item.requestCode}</strong><div class="small text-muted">${item.customerNote}</div><c:if test="${item.status eq 'INFO_REQUIRED'}"><form method="post" action="${pageContext.request.contextPath}/customer/returns" class="mt-2"><input type="hidden" name="action" value="supplement"><input type="hidden" name="requestId" value="${item.id}"><div class="input-group input-group-sm"><input name="additionalNote" class="form-control" placeholder="Add requested information" required><button class="btn btn-outline-primary" type="submit">Send</button></div></form></c:if></td><td>${item.orderCode}</td><td>${item.requestType}<div class="small text-muted">${item.reason}</div></td><td><fmt:formatNumber value="${item.refundAmount}" pattern="#,##0"/> VND</td><td><span class="status status-${item.status}">${item.status}</span></td><td><fmt:formatDate value="${item.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></td></tr></c:forEach>
                </tbody></table></div>
            </c:otherwise></c:choose>
        </div></div>
    </main>
    <jsp:include page="/view/customer/common/footer.jsp"/>
</body>
</html>
