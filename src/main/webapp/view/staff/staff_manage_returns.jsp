<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Returns &amp; Refunds</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        body {
            margin: 0;
            background: #f5f7fb;
        }

        .return-status {
            display: inline-flex;
            align-items: center;
            white-space: nowrap;
            border: 1px solid transparent;
            border-radius: 999px;
            padding: .35rem .7rem;
            font-size: .78rem;
            font-weight: 700;
        }

        .return-status--pending,
        .return-status--info-required {
            background: #fff7ed;
            color: #9a3412;
            border-color: #fed7aa;
        }

        .return-status--approved,
        .return-status--received {
            background: #eff6ff;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .return-status--refund-pending {
            background: #f5f3ff;
            color: #6d28d9;
            border-color: #ddd6fe;
        }

        .return-status--completed {
            background: #ecfdf5;
            color: #047857;
            border-color: #a7f3d0;
        }

        .return-status--rejected {
            background: #fef2f2;
            color: #b91c1c;
            border-color: #fecaca;
        }

        .return-status--cancelled {
            background: #fff7ed;
            color: #9a3412;
            border-color: #fed7aa;
        }

        @media (max-width: 767.98px) {
            .return-actions .btn {
                width: 100%;
            }

            .return-detail-header {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp"><jsp:param name="activeTab" value="returns"/></jsp:include>
<div class="admin-page">
    <%-- Các thông báo được controller lấy từ session rồi xoá sau khi hiển thị một lần. --%>
    <c:if test="${not empty successMsg}"><div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMsg}"/></div></c:if>
    <c:if test="${not empty errorMsg}"><div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMsg}"/></div></c:if>

    <c:choose>
        <c:when test="${pageMode eq 'detail'}">
            <div class="page-header"><div><h1 class="page-title"><i class="fa-solid fa-rotate-left"></i>Return Request Details</h1><p class="subtext mt-1">Review the request, record returned products, and follow the refund workflow.</p></div></div>
            <c:choose><c:when test="${empty returnRequest}"><div class="alert alert-danger">Return request not found.</div></c:when><c:otherwise>
                <div class="row g-4">
                    <div class="col-lg-8"><div class="card card-main mb-4"><div class="card-body p-4">
                        <div class="return-detail-header d-flex justify-content-between align-items-start gap-3 mb-3"><div><div class="text-muted small">REQUEST CODE</div><h2 class="h4 fw-bold mb-1">${returnRequest.requestCode}</h2><div class="text-muted">Order ${returnRequest.orderCode}</div></div><span class="return-status return-status--${fn:toLowerCase(fn:replace(returnRequest.status, '_', '-'))}">${returnRequest.statusLabel}</span></div>
                        <div class="row g-3 mb-4"><div class="col-md-4"><div class="text-muted small">Customer</div><strong>${returnRequest.customerName}</strong></div><div class="col-md-4"><div class="text-muted small">Type</div><strong>${returnRequest.requestType}</strong></div><div class="col-md-4"><div class="text-muted small">Reason</div><strong>${returnRequest.reason}</strong></div></div>
                        <div class="table-responsive border rounded"><table class="table align-middle mb-0"><thead><tr><th>Product</th><th>Variant</th><th>Quantity</th><th>Unit price</th><th>Current stock</th></tr></thead><tbody><c:forEach var="item" items="${returnRequest.items}"><tr><td>${item.productNameSnapshot}</td><td>${item.variantAttributesSnapshot}</td><td>${item.quantity}</td><td><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> VND</td><td>${item.currentStock}</td></tr></c:forEach></tbody></table></div>
                        <div class="mt-4"><div class="text-muted small">CUSTOMER NOTE</div><div class="border rounded p-3 bg-light">${not empty returnRequest.customerNote ? returnRequest.customerNote : 'No additional information.'}</div></div>
                        <div class="mt-3"><div class="text-muted small">REFUND AMOUNT</div><div class="fs-4 fw-bold text-primary"><fmt:formatNumber value="${returnRequest.refundAmount}" pattern="#,##0"/> VND</div></div>
                        <%-- Thông tin này giúp người quản lý đối chiếu đúng tài khoản trước khi chuyển tiền. --%>
                        <c:if test="${not empty returnRequest.refundAccountNumber}">
                            <div class="mt-4 p-3 rounded border bg-light-subtle">
                                <div class="text-muted small mb-2">REFUND BANK ACCOUNT</div>
                                <div><strong>${returnRequest.refundBankName}</strong> · ${returnRequest.refundAccountNumber}</div>
                                <div class="small text-muted">Account holder: ${returnRequest.refundAccountName}</div>
                                <div class="small text-muted">Transfer description: ${returnRequest.refundTransferDescription}</div>
                                <c:if test="${not empty returnRequest.refundQrUrl}"><div class="small fw-semibold mt-3">Refund transfer QR code</div><img src="${returnRequest.refundQrUrl}" alt="QR code for the shop to transfer the refund" class="img-fluid mt-2" style="max-width:260px"></c:if>
                            </div>
                        </c:if>
                        <c:if test="${not empty returnRequest.refundProofPath}">
                            <div class="mt-4"><div class="text-muted small mb-2">REFUND PROOF</div>
                                <c:choose>
                                    <c:when test="${fn:startsWith(returnRequest.refundProofPath, 'http://') or fn:startsWith(returnRequest.refundProofPath, 'https://')}"><a href="${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img src="${returnRequest.refundProofPath}" alt="Refund transfer proof" class="img-fluid rounded border" style="max-height:280px"></a></c:when>
                                    <c:otherwise><a href="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img src="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" alt="Refund transfer proof" class="img-fluid rounded border" style="max-height:280px"></a></c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div></div></div>
                    <div class="col-lg-4"><div class="card card-main return-actions"><div class="card-body p-4"><h3 class="h5 fw-bold mb-3">Available actions</h3>
                        <%-- Staff duyệt hồ sơ hoặc yêu cầu khách bổ sung thông tin. --%>
                        <c:if test="${returnRequest.status eq 'PENDING' or returnRequest.status eq 'INFO_REQUIRED'}"><form method="post" action="${returnsBasePath}" class="mb-2"><input type="hidden" name="action" value="review"><input type="hidden" name="status" value="APPROVED"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><textarea name="note" class="form-control mb-2" rows="2" placeholder="Staff note (optional)"></textarea><button class="btn btn-success w-100" type="submit">Approve request</button></form><form method="post" action="${returnsBasePath}" class="mb-2"><input type="hidden" name="action" value="review"><input type="hidden" name="status" value="INFO_REQUIRED"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><input type="hidden" name="note" value="Please provide more information about the product condition."><button class="btn btn-outline-warning w-100" type="submit">Request more information</button></form><form method="post" action="${returnsBasePath}"><input type="hidden" name="action" value="review"><input type="hidden" name="status" value="REJECTED"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><input type="text" name="note" class="form-control mb-2" placeholder="Reason for rejection" required><button class="btn btn-outline-danger w-100" type="submit">Reject request</button></form></c:if>
                        <%-- Chỉ khi đã duyệt, Staff mới được xác nhận hàng đã nhận và cộng tồn kho. --%>
                        <c:if test="${returnRequest.status eq 'APPROVED'}"><form method="post" action="${returnsBasePath}"><input type="hidden" name="action" value="receive"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><textarea name="note" class="form-control mb-2" rows="2" placeholder="Condition on arrival (optional)"></textarea><button class="btn btn-primary w-100" type="submit">Confirm products received</button></form></c:if>
                        <%-- Xác nhận hoàn tiền mới yêu cầu ảnh chứng từ để khách hàng có thể kiểm tra lại. --%>
                        <c:if test="${returnRequest.status eq 'RECEIVED'}">
                            <hr class="my-4"><h4 class="h6 fw-bold">Confirm bank transfer</h4>
                            <p class="small text-muted">Upload the transfer proof after sending the refund, then confirm completion.</p>
                            <form method="post" action="${returnsBasePath}" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="confirmRefund"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail">
                                <label class="form-label small fw-semibold mb-1">Upload proof image</label>
                                <input type="file" name="proofImage" class="form-control mb-2" accept="image/jpeg,image/png,image/webp">
                                <div class="text-center text-muted small mb-2">or</div>
                                <label class="form-label small fw-semibold mb-1">Use an image URL</label>
                                <input type="url" name="proofUrl" class="form-control mb-2" maxlength="1000" placeholder="https://example.com/transfer-proof.jpg">
                                <div class="form-text mb-2">Provide one proof source only.</div>
                                <textarea name="note" class="form-control mb-2" rows="2" maxlength="1000" placeholder="Confirmation note (optional)"></textarea>
                                <button class="btn btn-success w-100" type="submit"><i class="fa-solid fa-check me-1"></i>Confirm refund completed</button>
                            </form>
                        </c:if>
                        <%-- Đây là quyền riêng của Admin, Staff không thấy nút duyệt tiền. --%>
                        <c:if test="${sessionScope.authRoleName eq 'ADMIN' and returnRequest.status eq 'REFUND_PENDING'}"><form method="post" action="${returnsBasePath}" class="mb-2"><input type="hidden" name="action" value="approveRefund"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><input type="text" name="note" class="form-control mb-2" placeholder="Approval note (optional)"><button class="btn btn-success w-100" type="submit">Approve refund</button></form><form method="post" action="${returnsBasePath}"><input type="hidden" name="action" value="rejectRefund"><input type="hidden" name="id" value="${returnRequest.id}"><input type="hidden" name="returnMode" value="detail"><input type="text" name="note" class="form-control mb-2" placeholder="Reason for rejection" required><button class="btn btn-outline-danger w-100" type="submit">Reject refund</button></form></c:if>
                        <c:if test="${returnRequest.status eq 'COMPLETED' or returnRequest.status eq 'REJECTED' or returnRequest.status eq 'CANCELLED'}"><div class="alert alert-light border mb-0">No more actions are available for this request.</div></c:if>
                    </div></div></div>
                </div>
            </c:otherwise></c:choose>
        </c:when>
        <c:otherwise>
            <div class="page-header"><div><h1 class="page-title"><i class="fa-solid fa-rotate-left"></i>Returns & Refunds</h1><p class="subtext mt-1">Manage customer return requests, refunds, and returned stock.</p></div></div>
            <c:if test="${sessionScope.authRoleName eq 'ADMIN'}"><div class="row g-3 mb-4"><c:forEach var="entry" items="${statusCounts}"><div class="col-sm-6 col-xl-2"><div class="card card-main"><div class="card-body"><div class="text-muted small">${entry.key}</div><div class="fs-3 fw-bold">${entry.value}</div></div></div></div></c:forEach><div class="col-sm-6 col-xl-2"><div class="card card-main"><div class="card-body"><div class="text-muted small">REFUNDED VALUE</div><div class="fs-5 fw-bold"><fmt:formatNumber value="${totalRefunded}" pattern="#,##0"/> VND</div></div></div></div></div></c:if>
            <div class="card card-main mb-4"><div class="card-body p-4"><form class="row g-3 align-items-end" method="get" action="${returnsBasePath}"><div class="col-md-5"><label class="form-label fw-semibold">Keyword</label><input name="keyword" class="form-control" value="${param.keyword}" placeholder="Request code, order code, customer..."></div><div class="col-md-4"><label class="form-label fw-semibold">Status</label><select name="status" class="form-select"><c:forEach var="option" items="${statusOptions}"><option value="${option.key}" ${param.status eq option.key ? 'selected' : ''}>${option.value}</option></c:forEach></select></div><div class="col-md-3"><button class="btn btn-primary me-2" type="submit">Search</button><a class="btn btn-outline-secondary" href="${returnsBasePath}">Reset</a></div></form></div></div>
            <div class="card card-main"><div class="card-body p-0"><c:choose><c:when test="${empty returnRequests}"><div class="empty-state">No return requests found.</div></c:when><c:otherwise><div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr><th class="ps-4">Request</th><th>Customer</th><th>Order</th><th>Type / Reason</th><th>Refund</th><th>Status</th><th>Requested</th><th class="text-end pe-4">Action</th></tr></thead><tbody><c:forEach var="item" items="${returnRequests}"><tr><td class="ps-4"><strong>${item.requestCode}</strong></td><td>${item.customerName}<div class="small text-muted">${item.customerEmail}</div></td><td>${item.orderCode}</td><td>${item.requestType}<div class="small text-muted">${item.reason}</div></td><td><fmt:formatNumber value="${item.refundAmount}" pattern="#,##0"/> VND</td><td><span class="return-status return-status--${fn:toLowerCase(fn:replace(item.status, '_', '-'))}">${item.statusLabel}</span></td><td><fmt:formatDate value="${item.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></td><td class="text-end pe-4"><a class="btn btn-sm btn-outline-primary" href="${returnsBasePath}?action=view&amp;id=${item.id}">View</a></td></tr></c:forEach></tbody></table></div></c:otherwise></c:choose></div></div>
            <c:if test="${sessionScope.authRoleName eq 'ADMIN' and not empty reportRows}"><div class="card card-main mt-4"><div class="card-header"><h2 class="h5 fw-bold mb-0">Returned inventory report</h2></div><div class="table-responsive"><table class="table align-middle mb-0"><thead><tr><th>Product</th><th>SKU</th><th>Returned quantity</th><th>Current stock</th><th>Refund value</th></tr></thead><tbody><c:forEach var="row" items="${reportRows}"><tr><td>${row.productName}</td><td>${row.sku}</td><td>${row.quantityReturned}</td><td>${row.currentStock}</td><td><fmt:formatNumber value="${row.refundAmount}" pattern="#,##0"/> VND</td></tr></c:forEach></tbody></table></div></div></c:if>
        </c:otherwise>
    </c:choose>
</div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp"/>
</body>
</html>
