<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Request Details</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <!-- Header dùng các icon Font Awesome nên trang chi tiết cũng phải nạp stylesheet này. -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        body { background: #f7f7f8; color: #292524; }
        .detail-page { max-width: 1120px; margin: 32px auto 60px; padding: 0 16px; }
        .detail-card { border: 0; border-radius: 18px; box-shadow: 0 8px 24px rgba(0,0,0,.06); }
        .status-pill { display:inline-flex; border-radius:999px; padding:7px 12px; font-size:12px; font-weight:700; background:#eff6ff; color:#1d4ed8; }
        .status-pill.completed { background:#dcfce7; color:#166534; }
        .status-pill.rejected { background:#fee2e2; color:#b91c1c; }
        .status-pill.cancelled { background:#fff7ed; color:#9a3412; }
        .qr-box { background:linear-gradient(135deg,#eff6ff,#f8fafc); border:1px solid #dbeafe; border-radius:16px; }
        .qr-box img { width: min(100%, 310px); background:#fff; border-radius:12px; padding:10px; }
        .info-label { color:#78716c; font-size:.76rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; }
        .proof-image { max-height:360px; max-width:100%; object-fit:contain; }
    </style>
</head>
<body>
<jsp:include page="/view/customer/common/header.jsp"/>
<main class="detail-page">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div><h1 class="h3 fw-bold mb-1">Return Request Details</h1><p class="text-muted mb-0">Review the request status, refund instructions, and completion proof.</p></div>
    </div>

    <c:choose>
        <c:when test="${empty returnRequest}"><div class="alert alert-danger">Return request not found.</div></c:when>
        <c:otherwise>
            <div class="card detail-card mb-4"><div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4">
                    <div><div class="info-label">Request code</div><h2 class="h4 fw-bold mb-1">${returnRequest.requestCode}</h2><div class="text-muted">Order ${returnRequest.orderCode}</div></div>
                    <span class="status-pill ${returnRequest.status eq 'COMPLETED' ? 'completed' : (returnRequest.status eq 'REJECTED' ? 'rejected' : (returnRequest.status eq 'CANCELLED' ? 'cancelled' : ''))}">${returnRequest.statusLabel}</span>
                </div>
                <div class="row g-3 mb-4">
                    <div class="col-sm-4"><div class="info-label">Request type</div><strong>${returnRequest.requestType}</strong></div>
                    <div class="col-sm-4"><div class="info-label">Reason</div><strong>${returnRequest.reason}</strong></div>
                    <div class="col-sm-4"><div class="info-label">Refund amount</div><strong class="text-primary"><fmt:formatNumber value="${returnRequest.refundAmount}" pattern="#,##0"/> VND</strong></div>
                </div>
                <div class="table-responsive border rounded"><table class="table align-middle mb-0"><thead><tr><th>Product</th><th>Variant</th><th>Quantity</th><th>Unit price</th><th>Total</th></tr></thead><tbody>
                    <c:forEach var="item" items="${returnRequest.items}"><tr><td>${item.productNameSnapshot}</td><td>${item.variantAttributesSnapshot}</td><td>${item.quantity}</td><td><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> VND</td><td><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> VND</td></tr></c:forEach>
                </tbody></table></div>
                <div class="row g-3 mt-3">
                    <div class="col-md-6"><div class="info-label">Submitted</div><fmt:formatDate value="${returnRequest.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                    <div class="col-md-6"><div class="info-label">Refund confirmed</div><c:choose><c:when test="${not empty returnRequest.refundConfirmedAt}"><fmt:formatDate value="${returnRequest.refundConfirmedAt}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise>Not completed yet</c:otherwise></c:choose></div>
                </div>
                <c:if test="${not empty returnRequest.customerNote}"><div class="mt-4"><div class="info-label mb-1">Your note</div><div class="p-3 bg-light rounded border">${returnRequest.customerNote}</div></div></c:if>
                <c:if test="${not empty returnRequest.staffNote}"><div class="mt-3"><div class="info-label mb-1">Management note</div><div class="p-3 bg-light rounded border">${returnRequest.staffNote}</div></div></c:if>
            </div></div>

            <%-- QR và thông tin tài khoản nhận tiền chỉ dành cho Staff/Admin thực hiện chuyển khoản. --%>
            <c:if test="${returnRequest.status eq 'APPROVED'}">
                <div class="alert alert-info detail-card border-0 mb-4">
                    <h2 class="h6 fw-bold"><i class="fa-solid fa-truck-fast me-2"></i>Package collection is scheduled</h2>
                    <p class="mb-1">A shipper will come to collect the returned products within 1–2 days.</p>
                    <p class="mb-0">This status remains active for 3 days. If the store does not receive the package within 3 days, this refund request will be automatically cancelled.</p>
                </div>
            </c:if>
            <c:if test="${returnRequest.status eq 'RECEIVED'}">
                <div class="alert alert-success detail-card border-0 mb-4">
                    <h2 class="h6 fw-bold"><i class="fa-solid fa-box-open me-2"></i>Package received by the store</h2>
                    <p class="mb-0">The store has received your returned products. Your refund is being processed.</p>
                </div>
            </c:if>
            <c:if test="${returnRequest.status eq 'CANCELLED'}">
                <div class="alert alert-warning detail-card border-0 mb-4">
                    <h2 class="h6 fw-bold"><i class="fa-solid fa-circle-xmark me-2"></i>Request cancelled</h2>
                    <p class="mb-0">The store did not receive the returned package within 3 days, so this refund request was automatically cancelled.</p>
                </div>
            </c:if>

            <c:if test="${not empty returnRequest.refundProofPath}">
                <div class="card detail-card"><div class="card-body p-4"><h2 class="h5 fw-bold mb-3">Refund completion proof</h2><p class="text-muted">The refund was confirmed by the store. You can view the transfer proof below.</p>
                    <c:choose>
                        <c:when test="${fn:startsWith(returnRequest.refundProofPath, 'http://') or fn:startsWith(returnRequest.refundProofPath, 'https://')}"><a href="${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img class="proof-image rounded border" src="${returnRequest.refundProofPath}" alt="Refund transfer proof"></a></c:when>
                        <c:otherwise><a href="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img class="proof-image rounded border" src="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" alt="Refund transfer proof"></a></c:otherwise>
                    </c:choose>
                </div></div>
            </c:if>
        </c:otherwise>
    </c:choose>
</main>
<jsp:include page="/view/customer/common/footer.jsp"/>
</body>
</html>
