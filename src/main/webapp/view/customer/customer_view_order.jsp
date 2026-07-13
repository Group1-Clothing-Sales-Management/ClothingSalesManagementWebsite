<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Orders</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <style>
            :root {
                --order-ink:#111827;
                --order-muted:#64748b;
                --order-line:#e2e8f0;
                --order-blue:#2563eb;
                --order-teal:#0f9b8e;
                --order-primary:#c65b3d;
                --order-red:#dc2626;
                --order-green:#047857;
            }

            * { box-sizing:border-box; }

            body {
                min-height:100vh;
                margin:0;
                background:linear-gradient(180deg, #f6f8fb 0%, #ffffff 45%, #f8fafc 100%);
                color:var(--order-ink);
                font-family:system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            }

            .orders-page {
                max-width:1180px;
            }

            .page-heading {
                margin-bottom:1.25rem;
            }

            .page-kicker {
                color:var(--order-teal);
                font-size:.9rem;
                font-weight:800;
                margin-bottom:.25rem;
            }

            .page-title {
                margin:0;
                font-size:2rem;
                line-height:1.15;
                font-weight:850;
                letter-spacing:0;
            }

            .page-subtitle {
                color:var(--order-muted);
                margin:.45rem 0 0;
            }

            .order-action {
                border-radius:8px;
                font-weight:750;
            }

            .filter-bar {
                display:flex;
                align-items:stretch;
                margin-bottom:1.35rem;
                background:#fff;
                border-bottom:1px solid var(--order-line);
                box-shadow:0 10px 24px rgba(15, 23, 42, .04);
                overflow-x:auto;
                scrollbar-width:thin;
            }

            .filter-link {
                min-height:58px;
                flex:1 0 150px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                padding:.85rem 1.1rem;
                border:0;
                border-bottom:2px solid transparent;
                color:#111827;
                background:#fff;
                text-decoration:none;
                font-size:1rem;
                font-weight:650;
                white-space:nowrap;
            }

            .filter-link:hover {
                color:var(--order-primary);
                background:#fff;
            }

            .filter-link.active {
                color:var(--order-primary);
                border-bottom-color:var(--order-primary);
                background:#fff;
            }

            .flash {
                border-radius:8px;
                border:1px solid #bbf7d0;
                background:#f0fdf4;
                color:#166534;
                padding:.85rem 1rem;
                margin-bottom:1rem;
                font-weight:650;
            }

            .flash.error {
                border-color:#fecaca;
                background:#fef2f2;
                color:#991b1b;
            }

            .orders-list {
                display:grid;
                gap:1rem;
            }

            .order-card {
                background:#fff;
                border:1px solid var(--order-line);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15, 23, 42, .07);
                overflow:hidden;
            }

            .order-card-header {
                display:flex;
                align-items:flex-start;
                justify-content:space-between;
                gap:1rem;
                padding:1.15rem 1.25rem;
                border-bottom:1px solid #edf2f7;
                background:#fff;
            }

            .order-code {
                display:flex;
                align-items:center;
                gap:.55rem;
                font-size:1.05rem;
                font-weight:850;
            }

            .order-code i {
                color:var(--order-teal);
            }

            .order-date {
                margin-top:.25rem;
                color:var(--order-muted);
                font-size:.9rem;
            }

            .status-pill,
            .mini-pill {
                display:inline-flex;
                align-items:center;
                gap:.4rem;
                border-radius:999px;
                border:1px solid transparent;
                font-size:.8rem;
                font-weight:800;
                padding:.35rem .65rem;
                white-space:nowrap;
            }

            .status-pending { background:#fff7ed; color:#9a3412; border-color:#fed7aa; }
            .status-confirmed { background:#eff6ff; color:#1d4ed8; border-color:#bfdbfe; }
            .status-preparing { background:#f0f9ff; color:#0369a1; border-color:#bae6fd; }
            .status-shipping { background:#eef2ff; color:#4338ca; border-color:#c7d2fe; }
            .status-delivered,
            .status-completed { background:#ecfdf5; color:#047857; border-color:#a7f3d0; }
            .status-paid { background:#f0fdf4; color:#15803d; border-color:#bbf7d0; }
            .status-cancelled,
            .status-returned { background:#fef2f2; color:#b91c1c; border-color:#fecaca; }
            .status-unknown,
            .status-default { background:#f8fafc; color:#475569; border-color:#e2e8f0; }

            .order-summary {
                display:grid;
                grid-template-columns:repeat(3, minmax(0, 1fr));
                gap:1px;
                background:#edf2f7;
                border-bottom:1px solid #edf2f7;
            }

            .summary-cell {
                background:#fbfdff;
                padding:.9rem 1.25rem;
            }

            .summary-label {
                color:var(--order-muted);
                font-size:.82rem;
                font-weight:750;
                margin-bottom:.25rem;
            }

            .summary-value {
                font-weight:850;
                color:var(--order-ink);
            }

            .summary-value.total {
                color:var(--order-green);
                font-size:1.1rem;
            }

            .order-items {
                padding:.35rem 1.25rem;
            }

            .order-item {
                display:grid;
                grid-template-columns:76px minmax(0, 1fr) auto;
                gap:1rem;
                align-items:center;
                padding:1rem 0;
                border-bottom:1px solid #edf2f7;
            }

            .order-item:last-child {
                border-bottom:0;
            }

            .order-item-img {
                width:76px;
                height:94px;
                object-fit:cover;
                border-radius:8px;
                border:1px solid #e5e7eb;
                background:#f1f5f9;
            }

            .item-name {
                color:var(--order-ink);
                font-size:1rem;
                line-height:1.35;
                font-weight:850;
            }

            .item-meta {
                color:var(--order-muted);
                font-size:.9rem;
                margin-top:.25rem;
            }

            .item-price {
                min-width:150px;
                text-align:right;
                font-weight:850;
            }

            .item-price .line-total {
                display:block;
                color:var(--order-green);
            }

            .item-price .old-price {
                display:block;
                margin-top:.2rem;
                color:var(--order-muted);
                font-size:.85rem;
                font-weight:650;
            }

            .mini-pill {
                margin-top:.55rem;
                font-size:.75rem;
                padding:.25rem .55rem;
                background:#f8fafc;
                color:#475569;
                border-color:#e2e8f0;
            }

            .mini-pill.available {
                background:#ecfdf5;
                color:#047857;
                border-color:#a7f3d0;
            }

            .order-card-footer {
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:1rem;
                padding:1rem 1.25rem;
                border-top:1px solid #edf2f7;
                background:#fbfdff;
            }

            .footer-note {
                color:var(--order-muted);
                font-size:.9rem;
            }

            .footer-actions {
                display:flex;
                justify-content:flex-end;
                gap:.6rem;
                flex-wrap:wrap;
            }

            .order-action {
                min-height:40px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:.45rem;
                padding:.55rem .9rem;
                border:1px solid transparent;
                font-weight:800;
            }

            .order-action.primary {
                background:var(--order-ink);
                border-color:var(--order-ink);
                color:#fff;
            }

            .order-action.primary:hover {
                background:var(--order-blue);
                border-color:var(--order-blue);
            }

            .order-action.danger {
                background:#fff;
                color:var(--order-red);
                border-color:#fecaca;
            }

            .order-action.danger:hover {
                background:var(--order-red);
                color:#fff;
                border-color:var(--order-red);
            }

            .empty-state {
                max-width:560px;
                margin:4rem auto;
                padding:2.25rem;
                text-align:center;
                background:#fff;
                border:1px solid var(--order-line);
                border-radius:8px;
                box-shadow:0 20px 50px rgba(15, 23, 42, .07);
            }

            .empty-mark {
                width:70px;
                height:70px;
                margin:0 auto 1rem;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                background:#eff6ff;
                color:var(--order-blue);
                font-size:1.35rem;
            }

            @media (max-width: 768px) {
                .order-card-header,
                .order-card-footer {
                    display:block;
                }

                .footer-actions {
                    margin-top:1rem;
                }

                .order-summary {
                    grid-template-columns:1fr;
                }

                .order-item {
                    grid-template-columns:64px minmax(0, 1fr);
                    align-items:start;
                }

                .order-item-img {
                    width:64px;
                    height:82px;
                }

                .item-price {
                    grid-column:2;
                    text-align:left;
                    min-width:0;
                }
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="container orders-page py-4 py-lg-5">
            <div class="page-heading">
                <div>
                    <div class="page-kicker">Orders</div>
                    <h1 class="page-title">My Orders</h1>
                    <p class="page-subtitle">Track all of your orders by status.</p>
                </div>

            </div>

            <nav class="filter-bar" aria-label="Order status filter">
                <a href="${pageContext.request.contextPath}/customer/orders"
                   class="filter-link ${empty statusFilter ? 'active' : ''}">
                    All
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=WAIT_PAYMENT"
                   class="filter-link ${statusFilter eq 'WAIT_PAYMENT' ? 'active' : ''}">
                    Awaiting Payment
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=SHIPPING"
                   class="filter-link ${statusFilter eq 'SHIPPING' ? 'active' : ''}">
                    Shipping
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=WAIT_DELIVERY"
                   class="filter-link ${statusFilter eq 'WAIT_DELIVERY' ? 'active' : ''}">
                    Awaiting Delivery
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=COMPLETED"
                   class="filter-link ${statusFilter eq 'COMPLETED' ? 'active' : ''}">
                    Completed
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=CANCELLED"
                   class="filter-link ${statusFilter eq 'CANCELLED' ? 'active' : ''}">
                    Cancelled
                </a>

                <a href="${pageContext.request.contextPath}/customer/orders?status=RETURNED"
                   class="filter-link ${statusFilter eq 'RETURNED' ? 'active' : ''}">
                    Returns/Refunds
                </a>
            </nav>

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
            <section class="orders-list">
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
                    <c:if test="${o.orderStatus eq 'DELIVERED' or o.displayStatus eq 'DELIVERED' or o.displayStatus eq 'RECEIVED' or o.shippingStatus eq 'DELIVERED'}">
                        <c:set var="statusClass" value="status-delivered"/>
                    </c:if>
                    <c:if test="${o.orderStatus eq 'COMPLETED' or o.displayStatus eq 'COMPLETED'}">
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

                        <article class="order-card">
                            <header class="order-card-header">
                                <div>
                                    <div class="order-code">
                                        <i class="fa-solid fa-receipt"></i>
                                        Order #${o.orderCode}
                                    </div>
                                    <div class="order-date">
                                        <i class="fa-regular fa-calendar me-1"></i>
                                        ${o.createdAt}
                                    </div>
                                </div>

                                <span class="status-pill ${statusClass}">
                                    <i class="fa-solid fa-circle"></i>
                                    <c:out value="${not empty o.displayStatusLabel ? o.displayStatusLabel : o.orderStatus}"/>
                                </span>
                            </header>

                            <div class="order-summary">
                                <div class="summary-cell">
                                    <div class="summary-label">Total payment</div>
                                    <div class="summary-value total">
                                        <fmt:formatNumber value="${o.totalPayment}" pattern="#,##0"/> VND
                                    </div>
                                </div>

                                <div class="summary-cell">
                                    <div class="summary-label">Shipping</div>
                                    <div class="summary-value">
                                        <c:choose>
                                            <c:when test="${not empty o.shippingStatusLabel}">
                                                ${o.shippingStatusLabel}
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <div class="summary-cell">
                                    <div class="summary-label">Payment</div>
                                    <div class="summary-value">
                                        <c:choose>
                                            <c:when test="${not empty o.paymentMethod}">
                                                ${o.paymentMethod}
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <div class="order-items">
                                <c:forEach items="${o.details}" var="d">
                                    <div class="order-item">
                                        <c:choose>
                                            <c:when test="${not empty d.currentImageUrl}">
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(d.currentImageUrl, 'http://') or fn:startsWith(d.currentImageUrl, 'https://')}">
                                                        <img class="order-item-img"
                                                             src="${d.currentImageUrl}"
                                                             alt="${d.productNameSnapshot}">
                                                    </c:when>
                                                    <c:when test="${fn:startsWith(d.currentImageUrl, '/')}">
                                                        <img class="order-item-img"
                                                             src="${pageContext.request.contextPath}${d.currentImageUrl}"
                                                             alt="${d.productNameSnapshot}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img class="order-item-img"
                                                             src="${pageContext.request.contextPath}/${d.currentImageUrl}"
                                                             alt="${d.productNameSnapshot}">
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <img class="order-item-img"
                                                     src="${pageContext.request.contextPath}/uploads/product/placeholder.png"
                                                     alt="${d.productNameSnapshot}">
                                            </c:otherwise>
                                        </c:choose>

                                        <div>
                                            <div class="item-name">${d.productNameSnapshot}</div>
                                            <div class="item-meta">
                                                ${empty d.variantAttributesSnapshot ? 'Standard' : d.variantAttributesSnapshot}
                                            </div>
                                            <div class="item-meta">Quantity: ${d.quantity}</div>

                                            <span class="mini-pill ${d.reorderable ? 'available' : ''}">
                                                <i class="fa-solid ${d.reorderable ? 'fa-check' : 'fa-circle-info'}"></i>
                                                ${d.reorderNote}
                                                <c:if test="${d.reorderable}">
                                                    - ${d.currentStock} in stock
                                                </c:if>
                                            </span>
                                        </div>

                                        <div class="item-price">
                                            <span class="line-total">
                                                <fmt:formatNumber value="${d.lineTotal}" pattern="#,##0"/> VND
                                            </span>
                                            <span class="old-price">
                                                <fmt:formatNumber value="${d.price}" pattern="#,##0"/> VND each
                                            </span>
                                            <c:if test="${d.reorderable and d.currentPrice ne d.price}">
                                                <span class="old-price">
                                                    Now:
                                                    <fmt:formatNumber value="${d.currentPrice}" pattern="#,##0"/> VND
                                                </span>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <footer class="order-card-footer">
                                <div class="footer-note">
                                    <i class="fa-solid fa-shield-halved me-1"></i>
                                    Reorder uses current stock and current product price.
                                </div>

                                <div class="footer-actions">
                                    <c:if test="${o.orderStatus eq 'PENDING'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/customer/cancel-order">
                                            <input type="hidden" name="orderId" value="${o.id}">
                                            <button class="order-action danger" type="submit">
                                                <i class="fa-solid fa-xmark"></i>
                                                Cancel Order
                                            </button>
                                        </form>
                                    </c:if>

                                    <form method="post"
                                          action="${pageContext.request.contextPath}/customer/orders">
                                        <input type="hidden" name="action" value="reorder">
                                        <c:if test="${not empty param.status}">
                                            <input type="hidden" name="status" value="${param.status}">
                                        </c:if>
                                        <input type="hidden" name="orderId" value="${o.id}">
                                        <button class="order-action primary" type="submit">
                                            <i class="fa-solid fa-rotate-right"></i>
                                            Reorder
                                        </button>
                                    </form>
                                </div>
                            </footer>
                        </article>
                </c:forEach>
            </section>

            <c:if test="${not hasVisibleOrder}">
                <div class="empty-state">
                    <div class="empty-mark">
                        <i class="fa-solid fa-receipt"></i>
                    </div>
                    <h4>No orders found</h4>
                    <p class="text-muted mb-3">Orders matching this status will appear here.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-dark">
                        Browse Products
                    </a>
                </div>
            </c:if>
        </main>
    </body>
</html>
