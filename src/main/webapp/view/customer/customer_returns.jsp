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
        .status-CANCELLED { background:#fff3cd; color:#856404; }
    </style>
</head>
<body>
    <jsp:include page="/view/customer/common/header.jsp"/>
    <main class="returns-page">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
            <div><h1 class="h3 fw-bold mb-1"><i class="fa-solid fa-rotate-left text-primary me-2"></i>Returns & Refunds</h1><p class="text-muted mb-0">Submit and track your return or exchange requests.</p></div>
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
                            <form id="returnRequestForm" method="post" action="${pageContext.request.contextPath}/customer/returns">
                                <input type="hidden" name="orderId" value="${selectedOrder.id}">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6"><label class="form-label fw-semibold">Request type</label><select name="type" class="form-select" required><option value="RETURN">Return & refund</option><option value="EXCHANGE">Exchange product</option></select></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold">Reason</label><select name="reason" class="form-select" required><option value="">Select a reason</option><option value="WRONG_ITEM">Wrong item received</option><option value="DAMAGED">Product is damaged</option><option value="WRONG_SIZE">Wrong size or fit</option><option value="NOT_AS_DESCRIBED">Not as described</option><option value="CHANGE_OF_MIND">Changed my mind</option></select></div>
                                </div>
                                <label class="form-label fw-semibold">Products and quantities</label>
                                <div class="table-responsive border rounded mb-3"><table class="table align-middle mb-0"><thead><tr><th style="width:70px">Select</th><th>Product</th><th>Variant</th><th>Ordered</th><th style="width:130px">Return qty</th></tr></thead><tbody>
                                    <c:forEach var="item" items="${returnItems}"><tr><td><input type="checkbox" class="form-check-input js-return-item" aria-label="Select ${item.productNameSnapshot}" data-quantity-input="quantity_${item.orderDetailId}"></td><td>${item.productNameSnapshot}</td><td>${item.variantAttributesSnapshot}</td><td>${item.orderedQuantity}</td><td><input type="hidden" name="detailId" value="${item.orderDetailId}"><input type="number" name="quantity_${item.orderDetailId}" class="form-control js-return-quantity" min="0" max="${item.orderedQuantity}" value="0"></td></tr></c:forEach>
                                </tbody></table></div>
                                <div id="returnSelectionError" class="alert alert-warning d-none py-2">Select at least one product and enter a return quantity.</div>
                                <%-- Khách cung cấp tài khoản nhận tiền; hệ thống chỉ dùng dữ liệu này để tạo VietQR sau khi duyệt. --%>
                                <div class="border rounded p-3 mb-3 bg-light-subtle">
                                    <h3 class="h6 fw-bold mb-3"><i class="fa-solid fa-building-columns text-primary me-2"></i>Refund bank account</h3>
                                    <div class="row g-3">
                                        <div class="col-md-4"><label class="form-label fw-semibold">Account holder name</label><input type="text" name="accountName" class="form-control" maxlength="120" required placeholder="As shown by your bank"></div>
                                        <div class="col-md-4"><label class="form-label fw-semibold">Account number</label><input type="text" name="accountNumber" class="form-control" inputmode="numeric" pattern="[0-9]{4,25}" maxlength="25" required placeholder="Bank account number"></div>
                                        <div class="col-md-4"><label class="form-label fw-semibold">Bank</label><select name="bankId" class="form-select" required><option value="">Select a bank</option><c:forEach var="bank" items="${refundBanks}"><option value="${bank.bankId}">${bank.bankName}</option></c:forEach></select></div>
                                    </div>
                                    <div class="small text-muted mt-2">The store will use these bank details to process your refund after the returned package is received.</div>
                                </div>
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
                <div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr><th class="ps-4">Request</th><th>Order</th><th>Type / Reason</th><th>Refund amount</th><th>Status</th><th>Requested</th><th class="text-end pe-4">Action</th></tr></thead><tbody>
                    <c:forEach var="item" items="${returnRequests}"><tr><td class="ps-4"><strong>${item.requestCode}</strong><div class="small text-muted">${item.customerNote}</div><c:if test="${item.status eq 'INFO_REQUIRED'}"><form method="post" action="${pageContext.request.contextPath}/customer/returns" class="mt-2"><input type="hidden" name="action" value="supplement"><input type="hidden" name="requestId" value="${item.id}"><div class="input-group input-group-sm"><input name="additionalNote" class="form-control" placeholder="Add requested information" required><button class="btn btn-outline-primary" type="submit">Send</button></div></form></c:if></td><td>${item.orderCode}</td><td>${item.requestType}<div class="small text-muted">${item.reason}</div></td><td><fmt:formatNumber value="${item.refundAmount}" pattern="#,##0"/> VND</td><td><span class="status status-${item.status}">${item.statusLabel}</span></td><td><fmt:formatDate value="${item.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></td><td class="text-end pe-4"><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/customer/returns?action=view&amp;id=${item.id}">View details</a></td></tr></c:forEach>
                </tbody></table></div>
            </c:otherwise></c:choose>
        </div></div>
    </main>
    <jsp:include page="/view/customer/common/footer.jsp"/>
    <script>
        // Kiểm tra ở client để khách biết ngay phải chọn sản phẩm nào trước khi gửi request.
        (function () {
            var form = document.getElementById('returnRequestForm');
            if (!form) return;
            form.addEventListener('submit', function (event) {
                var selected = false;
                form.querySelectorAll('.js-return-item').forEach(function (checkbox) {
                    var input = form.querySelector('input[name="' + checkbox.dataset.quantityInput + '"]');
                    var quantity = input ? parseInt(input.value || '0', 10) : 0;
                    if (checkbox.checked && quantity <= 0 && input) {
                        input.value = '1';
                        quantity = 1;
                    }
                    if (quantity > 0) selected = true;
                });
                var error = document.getElementById('returnSelectionError');
                if (!selected) {
                    event.preventDefault();
                    if (error) error.classList.remove('d-none');
                } else if (error) {
                    error.classList.add('d-none');
                }
            });
        })();
    </script>
</body>
</html>
