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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root{--primary:#c65b3d;--ink:#29231f;--muted:#786f68;--line:#eadfd9;--bg:#f7f4f2}
        *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--ink);font-family:"Segoe UI",sans-serif}
        .header{background:#fff;border-bottom:1px solid var(--line)}
        .header-inner{max-width:1120px;height:82px;margin:auto;padding:0 20px;display:flex;align-items:center;gap:18px}
        .brand{color:var(--primary);font-size:24px;font-weight:750;text-decoration:none}.brand i{margin-right:8px}
        .divider{height:30px;border-left:1px solid var(--line)}.title{font-size:20px;color:var(--primary)}
        .back{margin-left:auto;color:var(--muted);text-decoration:none}.back:hover{color:var(--primary)}
        main{max-width:1120px;margin:32px auto 60px;padding:0 20px}
        h1{margin:0 0 8px;font-size:30px}.lead{margin:0 0 24px;color:var(--muted)}
        .tabs{display:flex;gap:8px;margin-bottom:22px}.tab{border:1px solid var(--line);border-radius:999px;background:#fff;padding:9px 18px;color:var(--muted);cursor:pointer;font-weight:650}.tab.active{border-color:var(--primary);background:var(--primary);color:#fff}
        .grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}
        .voucher{position:relative;display:grid;grid-template-columns:150px 1fr;min-height:205px;background:#fff;border:1px solid var(--line);border-radius:16px;overflow:hidden;box-shadow:0 10px 26px rgba(73,50,39,.06)}
        .voucher-side{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:20px 12px;background:linear-gradient(145deg,#d66a49,var(--primary));color:#fff;text-align:center;border-right:2px dashed rgba(255,255,255,.7)}
        .voucher-side i{font-size:34px}.discount{margin-top:8px;font-size:22px;font-weight:800}.code{margin-top:8px;padding:4px 8px;border:1px dashed rgba(255,255,255,.8);font-size:12px;font-weight:700}
        .voucher-body{padding:20px;display:flex;flex-direction:column}.voucher h2{margin:0 0 10px;font-size:18px}.condition{margin:3px 0;color:var(--muted);font-size:14px}.condition i{width:20px;color:var(--primary)}
        .expiry{margin-top:10px;color:#d33c35;font-size:13px;font-weight:700}.actions{margin-top:auto;display:flex;align-items:center;justify-content:space-between;gap:12px}
        .status{padding:5px 10px;border-radius:999px;font-size:12px;font-weight:750}.AVAILABLE{background:#e7f6ec;color:#187743}.EXPIRED{background:#f0f0f0;color:#777}.USED{background:#e9edff;color:#4356a7}
        .use{padding:9px 16px;border-radius:9px;background:var(--primary);color:#fff;text-decoration:none;font-size:14px;font-weight:750}.use:hover{background:#a9472e}
        .voucher.inactive{filter:saturate(.45);opacity:.78}.empty{grid-column:1/-1;padding:60px;text-align:center;background:#fff;border-radius:16px;color:var(--muted)}
        @media(max-width:780px){.grid{grid-template-columns:1fr}}@media(max-width:480px){.voucher{grid-template-columns:112px 1fr}.voucher-side{padding:14px 8px}.discount{font-size:17px}.voucher-body{padding:16px}}
    </style>
</head>
<body>
<header class="header"><div class="header-inner">
    <a class="brand" href="${pageContext.request.contextPath}/home"><i class="bi bi-bag-fill"></i>Clothing Sale</a>
    <span class="divider"></span><span class="title">Kho voucher</span>
    <a class="back" href="${pageContext.request.contextPath}/customer/profile"><i class="bi bi-person-circle"></i> Tài khoản của tôi</a>
</div></header>
<main>
    <h1>Kho voucher của bạn</h1><p class="lead">Chọn ưu đãi phù hợp và sử dụng ngay cho đơn hàng tiếp theo.</p>
    <div class="tabs" role="tablist">
        <button class="tab active" data-filter="ALL">Tất cả</button><button class="tab" data-filter="AVAILABLE">Còn hạn</button><button class="tab" data-filter="EXPIRED">Hết hạn</button><button class="tab" data-filter="USED">Đã sử dụng</button>
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
        <c:if test="${empty vouchers}"><div class="empty"><i class="bi bi-ticket-perforated fs-1"></i><p>Chưa có voucher nào.</p></div></c:if>
    </div>
</main>
<script>
document.querySelectorAll('.tab').forEach(function(button){button.addEventListener('click',function(){document.querySelectorAll('.tab').forEach(function(x){x.classList.remove('active')});button.classList.add('active');var f=button.dataset.filter;document.querySelectorAll('.voucher').forEach(function(v){v.hidden=f!=='ALL'&&v.dataset.status!==f})})});
</script>
</body></html>
