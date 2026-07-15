<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>My Orders</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <style>
            :root {
                --order-primary:#c65b3d;
                --order-primary-dark:#a9462d;
                --order-primary-soft:#fff3ed;
                --order-primary-pale:#fffaf7;
                --order-ink:#222222;
                --order-muted:#6b7280;
                --order-line:#e7e7e7;
                --order-teal:#16a6a0;
                --order-danger:#c65b3d;
            }

            * { box-sizing:border-box; }

            body {
                min-height:100vh;
                margin:0;
                background:#f5f5f5;
                color:var(--order-ink);
                font-family:Arial, Helvetica, sans-serif;
                font-size:14px;
            }

            .orders-page {
                width:min(1200px, calc(100% - 32px));
                max-width:none;
                padding-top:24px;
                padding-bottom:48px;
            }

            .orders-tabs {
                display:flex;
                min-height:58px;
                margin-bottom:14px;
                overflow-x:auto;
                background:#fff;
                border-bottom:1px solid var(--order-line);
                scrollbar-width:thin;
            }

            .orders-tab {
                flex:1 0 132px;
                display:flex;
                align-items:center;
                justify-content:center;
                min-height:58px;
                padding:0 16px;
                border-bottom:2px solid transparent;
                color:#333;
                text-decoration:none;
                font-size:15px;
                white-space:nowrap;
            }

            .orders-tab:hover,
            .orders-tab.active {
                color:var(--order-danger);
            }

            .orders-tab.active {
                border-bottom-color:var(--order-danger);
            }

            .order-search {
                position:relative;
                margin-bottom:12px;
            }

            .order-search i {
                position:absolute;
                top:50%;
                left:17px;
                z-index:1;
                color:#a7a7a7;
                font-size:18px;
                transform:translateY(-50%);
            }

            .order-search input {
                width:100%;
                height:44px;
                padding:0 16px 0 50px;
                border:0;
                border-radius:0;
                outline:0;
                background:#ededed;
                color:#444;
                font-size:14px;
            }

            .order-search input:focus {
                box-shadow:inset 0 0 0 1px rgba(198,91,61,.3);
            }

            .flash {
                margin-bottom:12px;
                padding:11px 14px;
                border:1px solid #cce8d4;
                background:#f1fbf3;
                color:#23733c;
            }

            .flash.error {
                border-color:#f5c9c1;
                background:#fff4f2;
                color:#b42318;
            }

            .orders-list {
                display:grid;
                gap:12px;
            }

            .order-card {
                overflow:hidden;
                background:#fff;
                border:0;
                box-shadow:0 1px 2px rgba(0,0,0,.05);
            }

            .shop-header {
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:16px;
                min-height:60px;
                margin:0 24px;
                border-bottom:1px solid var(--order-line);
            }

            .shop-header-left,
            .shop-header-right,
            .shop-actions,
            .shop-status {
                display:flex;
                align-items:center;
            }

            .shop-header-left,
            .shop-header-right {
                gap:9px;
            }

            .shop-name {
                font-weight:700;
                white-space:nowrap;
            }

            .mall-badge {
                display:inline-flex;
                align-items:center;
                height:16px;
                padding:0 4px;
                background:var(--order-danger);
                color:#fff;
                font-size:10px;
                font-weight:700;
                line-height:16px;
            }

            .shop-actions { gap:6px; }

            .shop-action {
                display:inline-flex;
                align-items:center;
                gap:5px;
                min-height:26px;
                padding:3px 9px;
                border:1px solid #ddd;
                border-radius:2px;
                background:#fff;
                color:#555;
                font-size:12px;
                text-decoration:none;
                white-space:nowrap;
            }

            .shop-action:hover { color:var(--order-primary-dark); }

            .shop-status {
                gap:8px;
                color:var(--order-danger);
                font-size:13px;
                white-space:nowrap;
            }

            .shop-status.delivery-success { color:var(--order-teal); }

            .shop-status .status-divider {
                color:#888;
                font-size:13px;
            }

            .shop-status .status-value {
                color:var(--order-danger);
                text-transform:uppercase;
            }

            .order-number {
                color:#8a8a8a;
                font-size:12px;
            }

            .order-items {
                padding:0 24px;
            }

            .order-item {
                display:grid;
                grid-template-columns:80px minmax(0, 1fr) 180px;
                gap:12px;
                align-items:start;
                padding:13px 0;
                border-bottom:1px solid #f0f0f0;
            }

            .order-item:last-child { border-bottom:0; }

            .order-item-img {
                width:80px;
                height:80px;
                object-fit:cover;
                border:1px solid #eee;
                background:#fafafa;
            }

            .item-name {
                margin:0 0 5px;
                color:#222;
                font-size:16px;
                line-height:1.35;
            }

            .item-meta {
                margin-top:4px;
                color:#888;
                font-size:13px;
                line-height:1.35;
            }

            .item-meta.quantity { color:#333; }

            .item-note {
                display:inline-block;
                margin-top:7px;
                color:#b45309;
                font-size:12px;
            }

            .item-price {
                padding-top:3px;
                text-align:right;
                white-space:nowrap;
            }

            .item-price .old-price {
                margin-right:5px;
                color:#aaa;
                font-size:13px;
                text-decoration:line-through;
            }

            .item-price .unit-price,
            .item-price .line-total {
                color:var(--order-danger);
                font-size:14px;
            }

            .item-price .line-total {
                display:block;
                margin-top:6px;
                color:#999;
                font-size:12px;
            }

            .order-footer {
                padding:15px 24px 18px;
                border-top:1px dotted #ddd;
                background:var(--order-primary-pale);
            }

            .order-used-voucher {
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:12px;
                margin-bottom:10px;
                color:#6b7280;
                font-size:13px;
            }

            .order-used-voucher-label {
                display:inline-flex;
                align-items:center;
                gap:6px;
                color:#444;
                font-weight:700;
            }

            .order-used-voucher-label i { color:var(--order-danger); }

            .order-used-voucher-code {
                color:var(--order-danger);
                font-weight:800;
            }

            .order-used-voucher-discount {
                color:#15803d;
                font-weight:800;
                white-space:nowrap;
            }

            .order-total-row {
                display:flex;
                align-items:baseline;
                justify-content:flex-end;
                gap:10px;
                margin-bottom:15px;
            }

            .order-total-label { color:#333; }

            .order-total-value {
                color:var(--order-danger);
                font-size:21px;
                font-weight:400;
            }

            .order-actions {
                display:flex;
                justify-content:flex-end;
                gap:10px;
                flex-wrap:wrap;
            }

            .order-action {
                display:inline-flex;
                align-items:center;
                justify-content:center;
                min-width:150px;
                min-height:40px;
                padding:8px 18px;
                border:1px solid #ddd;
                border-radius:2px;
                background:#fff;
                color:#555;
                font-size:14px;
                text-decoration:none;
                cursor:pointer;
            }

            .order-action:hover {
                border-color:var(--order-primary);
                color:var(--order-primary-dark);
            }

            .order-action.primary {
                border-color:var(--order-danger);
                background:var(--order-danger);
                color:#fff;
            }

            .order-action.primary:hover {
                border-color:#a9462d;
                background:#a9462d;
                color:#fff;
            }

            .order-action.danger {
                border-color:#f2b8ac;
                color:var(--order-danger);
            }

            .empty-state {
                max-width:560px;
                margin:24px auto;
                padding:48px 24px;
                text-align:center;
                background:#fff;
                color:#555;
            }

            .empty-mark {
                display:flex;
                align-items:center;
                justify-content:center;
                width:64px;
                height:64px;
                margin:0 auto 16px;
                border-radius:50%;
                background:var(--order-primary-soft);
                color:var(--order-primary);
                font-size:24px;
            }

            .empty-state h4 { color:#333; }

            .empty-state .btn {
                border:0;
                border-radius:2px;
                background:var(--order-danger);
            }

            .search-empty { display:none; }

            @media (max-width: 768px) {
                .orders-page { width:100%; padding-top:12px; }

                .orders-tabs { margin-bottom:10px; }
                .orders-tab { flex-basis:116px; font-size:13px; }

                .shop-header {
                    align-items:flex-start;
                    flex-direction:column;
                    gap:8px;
                    padding:12px 0;
                }

                .shop-header-right { width:100%; justify-content:space-between; }
                .shop-header-left { flex-wrap:wrap; }
                .shop-status { font-size:12px; }

                .order-items { padding:0 16px; }
                .shop-header { margin:0 16px; }

                .order-item {
                    grid-template-columns:64px minmax(0, 1fr);
                    gap:10px;
                }

                .order-item-img { width:64px; height:64px; }
                .item-name { font-size:14px; }

                .item-price {
                    grid-column:2;
                    padding-top:0;
                    text-align:left;
                }

                .order-footer { padding:14px 16px 16px; }
                .order-used-voucher {
                    align-items:flex-start;
                    flex-direction:column;
                    gap:4px;
                }
                .order-total-row { justify-content:flex-end; }
                .order-actions { justify-content:stretch; }
                .order-action { flex:1 1 140px; min-width:0; }
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="container orders-page">
            <nav class="orders-tabs" aria-label="Order status filter">
                <a href="${pageContext.request.contextPath}/customer/orders"
                   class="orders-tab ${empty statusFilter ? 'active' : ''}">All</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=WAIT_PAYMENT"
                   class="orders-tab ${statusFilter eq 'WAIT_PAYMENT' ? 'active' : ''}">To Pay</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=SHIPPING"
                   class="orders-tab ${statusFilter eq 'SHIPPING' ? 'active' : ''}">To Ship</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=WAIT_DELIVERY"
                   class="orders-tab ${statusFilter eq 'WAIT_DELIVERY' ? 'active' : ''}">To Receive</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=COMPLETED"
                   class="orders-tab ${statusFilter eq 'COMPLETED' ? 'active' : ''}">Completed</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=CANCELLED"
                   class="orders-tab ${statusFilter eq 'CANCELLED' ? 'active' : ''}">Cancelled</a>
                <a href="${pageContext.request.contextPath}/customer/orders?status=RETURNED"
                   class="orders-tab ${statusFilter eq 'RETURNED' ? 'active' : ''}">Return Refund</a>
            </nav>

            <div class="order-search">
                <i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i>
                <input id="orderSearch" type="search"
                       placeholder="You can search by Seller Name, Order ID or Product name"
                       aria-label="Search orders by seller name, order ID or product name"
                       autocomplete="off">
            </div>

            <c:if test="${not empty orderMessage}">
                <div class="flash">
                    <i class="fa-solid fa-circle-check me-2"></i>
                    ${orderMessage}
                </div>
            </c:if>

            <c:if test="${not empty orderError}">
                <div class="flash error">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>
                    ${orderError}
                </div>
            </c:if>

            <c:set var="hasVisibleOrder" value="false"/>
            <section class="orders-list" id="ordersList">
                <c:forEach items="${orders}" var="o">
                    <c:set var="hasVisibleOrder" value="true"/>
                    <c:set var="statusClass" value="${not empty o.displayStatusBadgeClass ? o.displayStatusBadgeClass : 'status-default'}"/>
                    <c:if test="${o.orderStatus eq 'PENDING' or o.displayStatus eq 'PENDING' or o.displayStatus eq 'PENDING_APPROVAL'}">
                        <c:set var="statusClass" value="status-pending"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'CONFIRMED' or o.displayStatus eq 'CONFIRMED' or o.displayStatus eq 'APPROVED'}">
                        <c:set var="statusClass" value="status-confirmed"/>
                    </c:if>
                    <c:if test="${o.displayStatus eq 'PREPARING'}">
                        <c:set var="statusClass" value="status-preparing"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'SHIPPING' or o.displayStatus eq 'SHIPPING'}">
                        <c:set var="statusClass" value="status-shipping"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'DELIVERED' or o.orderStatus eq 'SUCCESS' or o.displayStatus eq 'DELIVERED' or o.displayStatus eq 'SUCCESS' or o.displayStatus eq 'RECEIVED' or o.shippingStatus eq 'DELIVERED' or o.shippingStatus eq 'SUCCESS'}">
                        <c:set var="statusClass" value="status-delivered"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'COMPLETED' or o.orderStatus eq 'SUCCESS' or o.displayStatus eq 'COMPLETED'}">
                        <c:set var="statusClass" value="status-completed"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'PAID' or o.displayStatus eq 'PAID'}">
                        <c:set var="statusClass" value="status-paid"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'CANCELLED' or o.displayStatus eq 'CANCELLED' or o.shippingStatus eq 'CANCELLED'}">
                        <c:set var="statusClass" value="status-cancelled"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'RETURNED' or o.displayStatus eq 'RETURNED' or o.shippingStatus eq 'RETURNED'}">
                        <c:set var="statusClass" value="status-returned"/>
                    </c:if>
                    <c:set var="canBuyAgain" value="${o.displayStatus eq 'COMPLETED' or o.displayStatus eq 'CANCELLED' or o.orderStatus eq 'COMPLETED' or o.orderStatus eq 'SUCCESS' or o.orderStatus eq 'CANCELLED' or o.orderStatus eq 'FAILED' or o.shippingStatus eq 'CANCELLED' or o.shippingStatus eq 'FAILED'}"/>

                    <article class="order-card" data-order-search>
                        <header class="shop-header">
                            <div class="shop-header-left">
                                <span class="mall-badge">Mall</span>
                                <span class="shop-name">Clothing Sale Official</span>
                                <div class="shop-actions">
                                    <a class="shop-action" href="${pageContext.request.contextPath}/home">
                                        <i class="fa-solid fa-store"></i> View Shop
                                    </a>
                                </div>
                            </div>

                            <div class="shop-header-right">
                                <span class="shop-status ${statusClass eq 'status-completed' or statusClass eq 'status-delivered' or statusClass eq 'status-paid' ? 'delivery-success' : ''}">
                                    <c:choose>
                                        <c:when test="${statusClass eq 'status-completed' or statusClass eq 'status-delivered' or statusClass eq 'status-paid'}">
                                            <i class="fa-solid fa-truck"></i> Delivery successful
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-solid fa-truck"></i>
                                            <c:out value="${not empty o.shippingStatusLabel ? o.shippingStatusLabel : 'Order status'}"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="status-divider">|</span>
                                    <span class="status-value ${statusClass}">
                                        <c:out value="${not empty o.displayStatusLabel ? o.displayStatusLabel : o.orderStatus}"/>
                                    </span>
                                </span>
                                <span class="order-number">#${o.orderCode}</span>
                            </div>
                        </header>

                        <div class="order-items">
                            <c:forEach items="${o.details}" var="d">
                                <div class="order-item">
                                    <c:choose>
                                        <c:when test="${not empty d.currentImageUrl}">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(d.currentImageUrl, 'http://') or fn:startsWith(d.currentImageUrl, 'https://')}">
                                                    <img class="order-item-img" src="${d.currentImageUrl}" alt="${d.productNameSnapshot}">
                                                </c:when>
                                                <c:when test="${fn:startsWith(d.currentImageUrl, '/')}">
                                                    <img class="order-item-img" src="${pageContext.request.contextPath}${d.currentImageUrl}" alt="${d.productNameSnapshot}">
                                                </c:when>
                                                <c:otherwise>
                                                    <img class="order-item-img" src="${pageContext.request.contextPath}/${d.currentImageUrl}" alt="${d.productNameSnapshot}">
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <img class="order-item-img" src="${pageContext.request.contextPath}/uploads/product/placeholder.png" alt="${d.productNameSnapshot}">
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="item-information">
                                        <div class="item-name">${d.productNameSnapshot}</div>
                                        <div class="item-meta">
                                            Variation: ${empty d.variantAttributesSnapshot ? 'Standard' : d.variantAttributesSnapshot}
                                        </div>
                                        <div class="item-meta quantity">x${d.quantity}</div>
                                        <c:if test="${not d.reorderable}">
                                            <span class="item-note">Currently unavailable for reorder</span>
                                        </c:if>
                                    </div>

                                    <div class="item-price">
                                        <c:choose>
                                            <c:when test="${not empty d.currentPrice and d.currentPrice ne d.price}">
                                                <span class="old-price"><fmt:formatNumber value="${d.currentPrice}" pattern="#,##0"/> &#8363;</span>
                                                <span class="unit-price"><fmt:formatNumber value="${d.price}" pattern="#,##0"/> &#8363;</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="unit-price"><fmt:formatNumber value="${d.price}" pattern="#,##0"/> &#8363;</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="line-total">Line total: <fmt:formatNumber value="${d.lineTotal}" pattern="#,##0"/> &#8363;</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <footer class="order-footer">
                            <c:if test="${o.voucherId > 0 and o.discountAmount != null and o.discountAmount > 0}">
                                <div class="order-used-voucher">
                                    <span class="order-used-voucher-label">
                                        <i class="fa-solid fa-ticket"></i>
                                        Voucher đã dùng:
                                        <span class="order-used-voucher-code">
                                            <c:out value="${not empty o.voucherCode ? o.voucherCode : 'Voucher'}"/>
                                        </span>
                                    </span>
                                    <c:if test="${not empty o.voucherTitle}">
                                        <span><c:out value="${o.voucherTitle}"/></span>
                                    </c:if>
                                    <span class="order-used-voucher-discount">
                                        -<fmt:formatNumber value="${o.discountAmount}" pattern="#,##0"/> &#8363;
                                    </span>
                                </div>
                            </c:if>

                            <div class="order-total-row">
                                <span class="order-total-label">Order Total:</span>
                                <span class="order-total-value"><fmt:formatNumber value="${o.totalPayment}" pattern="#,##0"/> &#8363;</span>
                            </div>

                            <div class="order-actions">
                                <c:if test="${o.orderStatus eq 'PENDING'}">
                                    <form method="post" action="${pageContext.request.contextPath}/customer/cancel-order">
                                        <input type="hidden" name="orderId" value="${o.id}">
                                        <button class="order-action danger" type="submit">Cancel Order</button>
                                    </form>
                                </c:if>

                                <c:if test="${canBuyAgain}">
                                    <form method="post" action="${pageContext.request.contextPath}/customer/orders">
                                        <input type="hidden" name="action" value="reorder">
                                        <c:if test="${not empty param.status}">
                                            <input type="hidden" name="status" value="${param.status}">
                                        </c:if>
                                        <input type="hidden" name="orderId" value="${o.id}">
                                        <button class="order-action primary" type="submit">Buy Again</button>
                                    </form>
                                </c:if>
                            </div>
                        </footer>
                    </article>
                </c:forEach>
            </section>

            <c:if test="${not hasVisibleOrder}">
                <div class="empty-state">
                    <div class="empty-mark"><i class="fa-solid fa-receipt"></i></div>
                    <h4>No orders found</h4>
                    <p class="text-muted mb-3">Orders matching this status will appear here.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">Browse Products</a>
                </div>
            </c:if>

            <div id="searchEmpty" class="empty-state search-empty">
                <div class="empty-mark"><i class="fa-solid fa-magnifying-glass"></i></div>
                <h4>No matching orders</h4>
                <p class="text-muted mb-0">Try another seller name, order ID or product name.</p>
            </div>
        </main>

        <script>
            (() => {
                const input = document.getElementById('orderSearch');
                const cards = Array.from(document.querySelectorAll('[data-order-search]'));
                const empty = document.getElementById('searchEmpty');

                document.querySelectorAll('[data-copy-voucher]').forEach((button) => {
                    button.addEventListener('click', () => {
                        const code = button.getAttribute('data-copy-voucher');
                        if (!code) return;

                        if (!navigator.clipboard) {
                            button.textContent = code;
                            return;
                        }

                        navigator.clipboard.writeText(code).then(() => {
                            button.textContent = 'Đã copy';
                        }).catch(() => {
                            button.textContent = code;
                        });
                    });
                });

                if (!input || !cards.length) return;

                input.addEventListener('input', () => {
                    const query = input.value.trim().toLowerCase();
                    let visible = 0;

                    cards.forEach((card) => {
                        const matches = !query || card.textContent.toLowerCase().includes(query);
                        card.style.display = matches ? '' : 'none';
                        if (matches) visible += 1;
                    });

                    if (empty) empty.style.display = query && visible === 0 ? 'block' : 'none';
                });
            })();
        </script>
    </body>
</html>
