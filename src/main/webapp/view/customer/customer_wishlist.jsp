<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>My Wishlist</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

        <style>
            :root {
                --wishlist-primary:#8AAAE5;
                --wishlist-primary-dark:#5f84d6;
                --wishlist-primary-soft:#eef4ff;
                --wishlist-ink:#1f2937;
                --wishlist-muted:#61708a;
                --wishlist-line:#d7e1f5;
                --wishlist-danger:#9f3a38;
            }

            * { box-sizing:border-box; }

            body {
                min-height:100vh;
                margin:0;
                background:
                    linear-gradient(135deg, rgba(138,170,229,.14) 0 24%, transparent 24% 100%),
                    radial-gradient(circle at 88% 14%, rgba(95,132,214,.12), transparent 24%),
                    linear-gradient(180deg, #ffffff 0%, var(--wishlist-primary-soft) 100%);
                color:var(--wishlist-ink);
                font-family:"Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
                font-size:14px;
            }

            .wishlist-page {
                width:min(1180px, calc(100% - 32px));
                max-width:none;
                padding-top:30px;
                padding-bottom:56px;
            }

            .wishlist-header,
            .empty-state {
                border:1px solid rgba(138,170,229,.38);
                border-radius:8px;
                background:rgba(255,255,255,.96);
                box-shadow:0 18px 42px rgba(95,132,214,.14);
            }

            .wishlist-header {
                min-height:104px;
                padding:24px 28px;
            }

            .wishlist-header h2 {
                margin:0;
                color:var(--wishlist-ink);
                font-size:clamp(1.7rem, 3vw, 2.25rem);
                font-weight:900;
                letter-spacing:0;
            }

            .wishlist-header h2 i {
                color:var(--wishlist-primary-dark) !important;
            }

            .wishlist-header p {
                color:var(--wishlist-muted) !important;
                font-size:1rem;
            }

            .wishlist-count {
                display:inline-flex;
                align-items:center;
                gap:8px;
                min-height:42px;
                padding:0 14px;
                border:1px solid rgba(138,170,229,.48);
                border-radius:999px;
                background:var(--wishlist-primary-soft);
                color:var(--wishlist-primary-dark);
                font-weight:800;
                white-space:nowrap;
            }

            .wishlist-card {
                border:1px solid rgba(138,170,229,.30);
                border-radius:8px;
                overflow:hidden;
                background:#fff;
                box-shadow:0 8px 26px rgba(31,41,55,.08);
                transition:transform .2s ease, border-color .2s ease, box-shadow .2s ease;
            }

            .wishlist-card:hover {
                transform:translateY(-4px);
                border-color:rgba(138,170,229,.78);
                box-shadow:0 20px 38px rgba(95,132,214,.20);
            }

            .wishlist-grid {
                display:grid;
                grid-template-columns:repeat(5, minmax(0, 1fr));
                gap:18px;
            }

            .wishlist-card-body {
                padding:16px;
            }

            .wishlist-image {
                display:block;
                width:100%;
                aspect-ratio:1 / 1;
                object-fit:cover;
                object-position:center;
                background:var(--wishlist-primary-soft);
            }

            .wishlist-image-fallback {
                align-items:center;
                justify-content:center;
            }

            .wishlist-image-fallback:not(.d-none) {
                display:flex;
            }

            .wishlist-toast {
                position:fixed;
                z-index:1080;
                top:50%;
                left:50%;
                transform:translate(-50%, -50%);
                width:min(360px, calc(100vw - 40px));
                min-height:180px;
                display:flex;
                flex-direction:column;
                align-items:center;
                justify-content:center;
                gap:18px;
                padding:28px 30px;
                border:0;
                border-radius:8px;
                background:rgba(31, 41, 55, .88);
                color:#fff;
                text-align:center;
                box-shadow:0 18px 48px rgba(31,41,55,.24);
                animation:wishlist-toast-in .25s ease-out both;
            }

            .wishlist-toast.is-danger {
                background:rgba(31, 41, 55, .9);
            }
            .wishlist-toast > i {
                width:72px;
                height:72px;
                display:inline-flex;
                flex:0 0 72px;
                align-items:center;
                justify-content:center;
                border-radius:50%;
                background:#10b981;
                color:#fff;
                font-size:36px;
                box-shadow:0 8px 18px rgba(0,0,0,.18);
            }
            .wishlist-toast.is-danger > i {
                background:var(--wishlist-danger);
                color:#fff;
            }
            .wishlist-toast-message {
                max-width:100%;
                line-height:1.45;
                font-size:18px;
                font-weight:500;
                color:#fff;
            }
            .wishlist-toast-close {
                border:0;
                width:1px;
                height:1px;
                position:absolute;
                overflow:hidden;
                clip:rect(0 0 0 0);
                background:transparent;
            }
            .wishlist-toast.is-hiding { animation:wishlist-toast-out .2s ease-in both; }

            @keyframes wishlist-toast-in {
                from { opacity:0; transform:translate(-50%, -50%) scale(.94); }
                to { opacity:1; transform:translate(-50%, -50%) scale(1); }
            }
            @keyframes wishlist-toast-out {
                to { opacity:0; transform:translate(-50%, -50%) scale(.94); }
            }

            .wishlist-title {
                display:block;
                color:var(--wishlist-ink);
                font-size:.88rem;
                font-weight:900;
                text-decoration:none;
            }

            .wishlist-title:hover,
            .wishlist-title:focus-visible {
                color:var(--wishlist-primary-dark);
            }

            .wishlist-price {
                color:#365b9f;
                font-size:1.05rem;
                font-weight:800;
            }

            .btn-main {
                border:1px solid var(--wishlist-primary);
                border-radius:8px;
                background:var(--wishlist-primary);
                color:#fff;
                font-weight:800;
                box-shadow:0 12px 26px rgba(95,132,214,.22);
            }

            .btn-main:hover {
                border-color:var(--wishlist-primary-dark);
                background:var(--wishlist-primary-dark);
                color:#fff;
            }

            .wishlist-toggle-btn {
                width:34px;
                height:34px;
                border:0;
                border-radius:50%;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                background:var(--wishlist-primary);
                text-decoration:none;
                box-shadow:0 10px 22px rgba(95,132,214,.24);
                transition:background .2s ease, transform .2s ease, box-shadow .2s ease;
            }

            .wishlist-toggle-btn:hover,
            .wishlist-toggle-btn:focus-visible {
                color:#fff;
                background:var(--wishlist-primary-dark);
                transform:translateY(-1px);
                box-shadow:0 14px 28px rgba(95,132,214,.30);
            }

            .wishlist-toggle-btn i {
                font-size:14px;
            }

            .empty-state {
                padding:58px 24px;
                text-align:center;
            }

            .empty-icon {
                width:64px;
                height:64px;
                border-radius:16px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                background:var(--wishlist-primary-soft);
                color:var(--wishlist-primary);
                font-size:24px;
            }

            @media (max-width:768px) {
                .wishlist-page { width:100%; padding:18px 14px 48px; }
                .wishlist-header { padding:18px 16px; }
                .wishlist-header h2 { font-size:21px; }
                .wishlist-grid { grid-template-columns:repeat(2, minmax(0, 1fr)); gap:14px; }
                .wishlist-card-body { padding:12px; }
                .wishlist-toast {
                    width:min(320px, calc(100vw - 32px));
                    min-height:160px;
                    padding:24px 22px;
                }
            }

            @media (min-width:769px) and (max-width:1199px) {
                .wishlist-grid { grid-template-columns:repeat(3, minmax(0, 1fr)); }
            }

            @media (max-width:480px) {
                .wishlist-grid { grid-template-columns:1fr; }
            }

        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="container wishlist-page">
            <div class="wishlist-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2>
                        <i class="fa-solid fa-heart me-2"></i>
                        My Wishlist
                    </h2>
                    <p class="text-muted mb-0 mt-2">
                        Save products you like and revisit them anytime.
                    </p>
                </div>

                <span class="wishlist-count">
                    <i class="fa-solid fa-heart"></i>
                    ${fn:length(wishlistItems)} item(s)
                </span>
            </div>

            <c:if test="${not empty wishlistMessage}">
                <div id="wishlistFlashMessage"
                     class="wishlist-toast ${wishlistMessageType eq 'danger' ? 'is-danger' : ''}"
                     role="status" aria-live="polite">
                    <i class="fa-solid ${wishlistMessageType eq 'danger' ? 'fa-exclamation' : 'fa-check'}"></i>
                    <span class="wishlist-toast-message"><c:out value="${wishlistMessage}"/></span>
                    <button type="button" class="wishlist-toast-close" aria-label="Close notification">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty wishlistItems}">
                    <div class="empty-state">
                        <div class="empty-icon mb-3">
                            <i class="fa-regular fa-heart"></i>
                        </div>
                        <h4 class="fw-bold">Your wishlist is empty</h4>
                        <p class="text-muted mb-4">
                            Browse products and tap the heart button to save your favorites.
                        </p>
                        <a href="${pageContext.request.contextPath}/products"
                           class="btn btn-main px-4 py-2">
                            <i class="fa-solid fa-store me-2"></i>
                            Shop Products
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="wishlist-grid">
                        <c:forEach items="${wishlistItems}" var="item">
                            <div class="wishlist-card">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}">
                                    <c:choose>
                                        <c:when test="${not empty item.mainImageUrl}">
                                            <img src="${pageContext.request.contextPath}/media/product/${item.mainImageUrl}"
                                                 class="wishlist-image wishlist-image-element"
                                                 data-context-path="${pageContext.request.contextPath}"
                                                 alt="${fn:escapeXml(item.productName)}"
                                                 onerror="this.classList.add('d-none'); this.nextElementSibling.classList.remove('d-none');">
                                            <div class="wishlist-image wishlist-image-fallback d-none align-items-center justify-content-center">
                                                <i class="fa-solid fa-shirt fs-1 text-secondary"></i>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="wishlist-image wishlist-image-fallback d-flex align-items-center justify-content-center">
                                                <i class="fa-solid fa-shirt fs-1 text-secondary"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </a>

                                <div class="wishlist-card-body">
                                    <div class="d-flex justify-content-between gap-3 mb-2">
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}"
                                           class="wishlist-title text-truncate">
                                            <c:out value="${item.productName}"/>
                                        </a>
                                        <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                              method="post"
                                              class="m-0">
                                            <input type="hidden" name="productId" value="${item.productId}">
                                            <input type="hidden" name="wishlisted" value="true">
                                            <button type="submit"
                                                    class="wishlist-toggle-btn"
                                                    title="Remove from wishlist">
                                                <i class="fa-solid fa-heart"></i>
                                            </button>
                                        </form>
                                    </div>

                                    <div class="wishlist-price mb-1">
                                        <c:choose>
                                            <c:when test="${not empty item.salePrice}">
                                                <fmt:formatNumber value="${item.salePrice}" pattern="#,##0"/> &#8363;
                                            </c:when>
                                            <c:otherwise>
                                                Contact
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                var toast = document.getElementById('wishlistFlashMessage');
                if (!toast) return;

                var timer;
                function closeToast() {
                    clearTimeout(timer);
                    toast.classList.add('is-hiding');
                    setTimeout(function () { toast.remove(); }, 220);
                }

                toast.querySelector('.wishlist-toast-close').addEventListener('click', closeToast);
                timer = setTimeout(closeToast, 3000);
            }());
        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>
</html>
