<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kho voucher</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root{--primary:#c65b3d;--ink:#29231f;--muted:#786f68;--line:#eadfd9;--bg:#f7f4f2}
        *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--ink);font-family:"Segoe UI",sans-serif}
        main{max-width:1120px;margin:32px auto 60px;padding:0 20px}
        h1{margin:0 0 8px;font-size:30px}.lead{margin:0 0 24px;color:var(--muted)}
        .tabs{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px}.tab{display:inline-flex;align-items:center;gap:7px;border:1px solid var(--line);border-radius:999px;background:#fff;padding:9px 18px;color:var(--muted);text-decoration:none;font-weight:650}.tab:hover{border-color:var(--primary);color:var(--primary)}.tab.active{border-color:var(--primary);background:var(--primary);color:#fff}.tab-count{display:inline-flex;align-items:center;justify-content:center;min-width:22px;height:22px;padding:0 7px;border-radius:999px;background:#f1ebe7;color:var(--muted);font-size:12px}.tab.active .tab-count{background:rgba(255,255,255,.2);color:#fff}
        .grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}
        .voucher{position:relative;display:grid;grid-template-columns:150px 1fr;min-height:205px;background:#fff;border:1px solid var(--line);border-radius:16px;overflow:hidden;box-shadow:0 10px 26px rgba(73,50,39,.06)}
        .voucher-side{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:20px 12px;background:linear-gradient(145deg,#d66a49,var(--primary));color:#fff;text-align:center;border-right:2px dashed rgba(255,255,255,.7)}
        .voucher-side i{font-size:34px}.discount{margin-top:8px;font-size:22px;font-weight:800}.code{margin-top:8px;padding:4px 8px;border:1px dashed rgba(255,255,255,.8);font-size:12px;font-weight:700}
        .voucher-body{padding:20px;display:flex;flex-direction:column}.voucher h2{margin:0 0 10px;font-size:18px}.condition{margin:3px 0;color:var(--muted);font-size:14px}.condition i{width:20px;color:var(--primary)}
        .expiry{margin-top:10px;color:#d33c35;font-size:13px;font-weight:700}.actions{margin-top:auto;display:flex;align-items:center;justify-content:space-between;gap:12px}
        .status{padding:5px 10px;border-radius:999px;font-size:12px;font-weight:750}.AVAILABLE{background:#e7f6ec;color:#187743}.EXPIRED{background:#f0f0f0;color:#777}.USED{background:#e9edff;color:#4356a7}
        .use{padding:9px 16px;border-radius:9px;background:var(--primary);color:#fff;text-decoration:none;font-size:14px;font-weight:750}.use:hover{background:#a9472e}
        .voucher.inactive{filter:saturate(.45);opacity:.78}.empty{grid-column:1/-1;padding:60px;text-align:center;background:#fff;border-radius:16px;color:var(--muted)}.empty strong{display:block;margin-top:12px;color:var(--ink);font-size:18px}
        @media(max-width:780px){.grid{grid-template-columns:1fr}}@media(max-width:480px){.voucher{grid-template-columns:112px 1fr}.voucher-side{padding:14px 8px}.discount{font-size:17px}.voucher-body{padding:16px}}
    </style>
</head>
<body>
<jsp:include page="/view/customer/common/header.jsp"/>
<main>
    <h1>Kho voucher của bạn</h1><p class="lead">Chọn ưu đãi phù hợp và sử dụng ngay cho đơn hàng tiếp theo.</p>
    <div class="tabs" aria-label="Lọc voucher theo trạng thái">
        <a class="tab ${statusFilter eq 'ALL' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers">
            Tất cả <span class="tab-count">${allCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'AVAILABLE' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=AVAILABLE">
            Còn hạn <span class="tab-count">${availableCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'EXPIRED' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=EXPIRED">
            Hết hạn <span class="tab-count">${expiredCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'USED' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=USED">
            Đã sử dụng <span class="tab-count">${usedCount}</span>
        </a>
    </div>
    <div class="grid" id="voucherGrid">
        <c:forEach items="${vouchers}" var="v">
            <article class="voucher ${v.customerStatus ne 'AVAILABLE' ? 'inactive' : ''}" data-status="${v.customerStatus}">
                <div class="voucher-side"><i class="bi bi-ticket-perforated-fill"></i>
                    <div class="discount"><c:choose><c:when test="${v.discountType eq 'PERCENTAGE'}">Giảm <fmt:formatNumber value="${v.discountValue}" pattern="#0"/>%</c:when><c:otherwise>Giảm <fmt:formatNumber value="${v.discountValue}" pattern="#,##0"/>đ</c:otherwise></c:choose></div>
                    <div class="code"><c:out value="${v.code}"/></div>
                </div>
                <div class="voucher-body"><h2><c:out value="${v.title}"/></h2>
                    <p class="condition"><i class="bi bi-bag-check"></i>Đơn tối thiểu <fmt:formatNumber value="${v.minOrderValue}" pattern="#,##0"/>đ</p>
                    <c:if test="${v.discountType eq 'PERCENTAGE' && v.maxDiscountAmount != null}"><p class="condition"><i class="bi bi-arrow-down-circle"></i>Giảm tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" pattern="#,##0"/>đ</p></c:if>
                    <p class="expiry"><i class="bi bi-clock"></i> <c:choose><c:when test="${v.customerStatus eq 'EXPIRED'}">Đã hết hạn</c:when><c:when test="${v.daysRemaining <= 2}">Hết hạn sau ${v.daysRemaining} ngày nữa</c:when><c:otherwise>Hạn dùng: <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/></c:otherwise></c:choose></p>
                    <div class="actions"><span class="status ${v.customerStatus}"><c:choose><c:when test="${v.customerStatus eq 'AVAILABLE'}">Còn hạn</c:when><c:when test="${v.customerStatus eq 'USED'}">Đã sử dụng</c:when><c:otherwise>Hết hạn</c:otherwise></c:choose></span>
                    <c:if test="${v.customerStatus eq 'AVAILABLE'}"><a class="use" href="${pageContext.request.contextPath}/products?voucherCode=${v.code}">Dùng ngay</a></c:if></div>
                </div>
            </article>
        </c:forEach>
        <c:if test="${empty vouchers}">
            <div class="empty">
                <i class="bi bi-ticket-perforated fs-1"></i>
                <strong>Không có voucher phù hợp</strong>
                <p>Hãy chọn bộ lọc khác để xem các voucher còn lại.</p>
            </div>
        </c:if>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body></html>
