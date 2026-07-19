<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<fmt:setLocale value="en_US"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Voucher Wallet</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root{
            --voucher-accent:#8AAAE5;
            --voucher-accent-dark:#5f84d6;
            --voucher-ink:#1f2937;
            --voucher-muted:#61708a;
            --voucher-line:#d7e1f5;
            --voucher-soft:#eef4ff;
            --voucher-page:#f7faff;
        }

        *{box-sizing:border-box}

        body{
            margin:0;
            background:
                linear-gradient(135deg, rgba(138,170,229,.12) 0 26%, transparent 26% 100%),
                linear-gradient(180deg, #fff 0%, var(--voucher-page) 100%);
            color:var(--voucher-ink);
            font-family:"Segoe UI", Arial, Helvetica, sans-serif;
        }

        main{
            width:min(1220px, calc(100% - 32px));
            margin:34px auto 64px;
        }

        .wallet-hero{
            min-height:112px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:18px;
            margin-bottom:20px;
            padding:24px 26px;
            border:1px solid rgba(138,170,229,.36);
            border-radius:8px;
            background:rgba(255,255,255,.96);
            box-shadow:0 18px 42px rgba(95,132,214,.13);
        }

        .wallet-kicker{
            display:inline-flex;
            align-items:center;
            gap:8px;
            margin-bottom:7px;
            color:var(--voucher-accent-dark);
            font-size:.8rem;
            font-weight:900;
            letter-spacing:.08em;
            text-transform:uppercase;
        }

        h1{
            margin:0;
            color:var(--voucher-ink);
            font-size:1.8rem;
            font-weight:850;
        }

        .lead{
            margin:7px 0 0;
            color:var(--voucher-muted);
            font-size:1rem;
        }

        .wallet-link{
            flex:0 0 auto;
            color:#365b9f;
            font-weight:800;
            text-decoration:none;
        }

        .wallet-link:hover{
            color:var(--voucher-accent-dark);
            text-decoration:underline;
            text-underline-offset:4px;
        }

        .tabs{
            display:flex;
            flex-wrap:wrap;
            gap:10px;
            margin-bottom:22px;
        }

        .tab{
            min-height:44px;
            display:inline-flex;
            align-items:center;
            gap:8px;
            border:1px solid var(--voucher-line);
            border-radius:999px;
            background:#fff;
            padding:9px 18px;
            color:var(--voucher-muted);
            text-decoration:none;
            font-weight:800;
            box-shadow:0 8px 20px rgba(95,132,214,.08);
        }

        .tab:hover{
            border-color:var(--voucher-accent);
            color:#365b9f;
        }

        .tab.active{
            border-color:var(--voucher-accent);
            background:var(--voucher-accent);
            color:#fff;
            box-shadow:0 14px 28px rgba(95,132,214,.22);
        }

        .tab-count{
            min-width:24px;
            height:24px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            padding:0 7px;
            border-radius:999px;
            background:var(--voucher-soft);
            color:#365b9f;
            font-size:12px;
            font-weight:850;
        }

        .tab.active .tab-count{
            background:rgba(255,255,255,.25);
            color:#fff;
        }

        .grid{
            display:grid;
            grid-template-columns:repeat(2,minmax(0,1fr));
            gap:18px;
        }

        .voucher{
            position:relative;
            display:grid;
            grid-template-columns:168px minmax(0,1fr);
            min-height:214px;
            overflow:hidden;
            border:1px solid rgba(138,170,229,.36);
            border-radius:8px;
            background:#fff;
            box-shadow:0 14px 34px rgba(95,132,214,.12);
        }

        .voucher-side{
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:center;
            padding:22px 12px;
            border-right:2px dashed rgba(255,255,255,.72);
            background:linear-gradient(145deg, #9ab7ec, var(--voucher-accent-dark));
            color:#fff;
            text-align:center;
        }

        .voucher-side i{
            font-size:34px;
        }

        .discount{
            margin-top:10px;
            font-size:23px;
            font-weight:900;
            line-height:1.18;
        }

        .code{
            max-width:132px;
            margin-top:11px;
            padding:5px 9px;
            overflow:hidden;
            border:1px dashed rgba(255,255,255,.85);
            color:#fff;
            font-size:12px;
            font-weight:850;
            text-overflow:ellipsis;
            white-space:nowrap;
        }

        .voucher-body{
            min-width:0;
            display:flex;
            flex-direction:column;
            padding:22px 24px;
        }

        .voucher h2{
            margin:0 0 12px;
            color:var(--voucher-ink);
            font-size:18px;
            font-weight:850;
        }

        .condition{
            margin:4px 0;
            color:var(--voucher-muted);
            font-size:14px;
        }

        .condition i{
            width:20px;
            color:var(--voucher-accent-dark);
        }

        .expiry{
            margin-top:11px;
            color:#365b9f;
            font-size:13px;
            font-weight:800;
        }

        .usage-history{
            margin-top:10px;
            padding-top:10px;
            border-top:1px solid var(--voucher-line);
            color:var(--voucher-muted);
            font-size:13px;
        }

        .usage-row{
            display:flex;
            justify-content:space-between;
            gap:10px;
            margin-top:6px;
        }

        .usage-order{
            color:var(--voucher-ink);
            font-weight:800;
        }

        .usage-status{
            flex:0 0 auto;
            font-weight:850;
        }

        .usage-status.APPLIED{
            color:#365b9f;
        }

        .usage-status.REFUNDED{
            color:#187743;
        }

        .actions{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;
            margin-top:auto;
        }

        .status{
            padding:6px 11px;
            border-radius:999px;
            font-size:12px;
            font-weight:850;
        }

        .AVAILABLE{
            background:#e9f7ef;
            color:#187743;
        }

        .EXPIRED{
            background:#edf1f7;
            color:#6b7280;
        }

        .USED{
            background:var(--voucher-soft);
            color:#365b9f;
        }

        .use{
            padding:9px 16px;
            border-radius:8px;
            background:var(--voucher-accent);
            color:#fff;
            text-decoration:none;
            font-size:14px;
            font-weight:850;
            box-shadow:0 12px 22px rgba(95,132,214,.18);
        }

        .use:hover{
            background:var(--voucher-accent-dark);
            color:#fff;
        }

        .voucher.inactive{
            opacity:.78;
        }

        .voucher.inactive .voucher-side{
            background:linear-gradient(145deg, #c8d2e6, #97a6c4);
        }

        .empty{
            grid-column:1/-1;
            padding:62px 24px;
            border:1px solid rgba(138,170,229,.36);
            border-radius:8px;
            background:#fff;
            color:var(--voucher-muted);
            text-align:center;
            box-shadow:0 14px 34px rgba(95,132,214,.12);
        }

        .empty i{
            color:var(--voucher-accent-dark);
        }

        .empty strong{
            display:block;
            margin-top:12px;
            color:var(--voucher-ink);
            font-size:18px;
        }

        @media(max-width:900px){
            .wallet-hero{
                align-items:flex-start;
                flex-direction:column;
            }

            .grid{
                grid-template-columns:1fr;
            }
        }

        @media(max-width:520px){
            main{
                width:min(100% - 20px, 1220px);
                margin-top:22px;
            }

            .wallet-hero{
                padding:20px;
            }

            .voucher{
                grid-template-columns:118px minmax(0,1fr);
            }

            .voucher-side{
                padding:16px 8px;
            }

            .discount{
                font-size:17px;
            }

            .voucher-body{
                padding:18px 16px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/view/customer/common/header.jsp"/>
<main>
    <section class="wallet-hero">
        <div>
            <span class="wallet-kicker"><i class="bi bi-ticket-perforated-fill"></i> Voucher Wallet</span>
            <h1>Your vouchers</h1>
            <p class="lead">Choose a suitable offer and apply it to your next order.</p>
        </div>
        <a class="wallet-link" href="${pageContext.request.contextPath}/products">Browse products</a>
    </section>

    <div class="tabs" aria-label="Filter vouchers by status">
        <a class="tab ${statusFilter eq 'ALL' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers">
            All <span class="tab-count">${allCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'AVAILABLE' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=AVAILABLE">
            Available <span class="tab-count">${availableCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'EXPIRED' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=EXPIRED">
            Expired <span class="tab-count">${expiredCount}</span>
        </a>
        <a class="tab ${statusFilter eq 'USED' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/vouchers?status=USED">
            Used <span class="tab-count">${usedCount}</span>
        </a>
    </div>

    <div class="grid" id="voucherGrid">
        <c:forEach items="${vouchers}" var="v">
            <article class="voucher ${v.customerStatus ne 'AVAILABLE' ? 'inactive' : ''}" data-status="${v.customerStatus}">
                <div class="voucher-side">
                    <i class="bi bi-ticket-perforated-fill"></i>
                    <div class="discount">
                        <c:choose>
                            <c:when test="${v.discountType eq 'PERCENTAGE' or v.discountType eq 'PERCENT'}">
                                <fmt:formatNumber value="${v.discountValue}" pattern="#0"/>% off
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${v.discountValue}" pattern="#,##0"/>đ off
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="code"><c:out value="${v.code}"/></div>
                </div>

                <div class="voucher-body">
                    <h2><c:out value="${v.title}"/></h2>
                    <p class="condition">
                        <i class="bi bi-bag-check"></i>
                        Minimum order <fmt:formatNumber value="${v.minOrderValue}" pattern="#,##0"/>đ
                    </p>
                    <c:if test="${(v.discountType eq 'PERCENTAGE' or v.discountType eq 'PERCENT') && v.maxDiscountAmount != null}">
                        <p class="condition">
                            <i class="bi bi-arrow-down-circle"></i>
                            Max discount <fmt:formatNumber value="${v.maxDiscountAmount}" pattern="#,##0"/>đ
                        </p>
                    </c:if>
                    <p class="expiry">
                        <i class="bi bi-clock"></i>
                        <c:choose>
                            <c:when test="${v.customerStatus eq 'USED'}">Already used</c:when>
                            <c:when test="${v.customerStatus eq 'EXPIRED'}">Expired</c:when>
                            <c:when test="${v.daysRemaining <= 2}">Expires in ${v.daysRemaining} day(s)</c:when>
                            <c:otherwise>Valid until <fmt:formatDate value="${v.endDate}" pattern="MM/dd/yyyy"/></c:otherwise>
                        </c:choose>
                    </p>
                    <p class="condition">
                        <i class="bi bi-diagram-3"></i>
                        <c:choose>
                            <c:when test="${not empty v.categoryName}">Category: <c:out value="${v.categoryName}"/></c:when>
                            <c:otherwise>Scope: Entire store</c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${not empty v.usageHistory}">
                        <div class="usage-history">
                            <strong>Usage history</strong>
                            <c:forEach items="${v.usageHistory}" var="usage">
                                <div class="usage-row">
                                    <span>
                                        Order <span class="usage-order"><c:out value="${usage.orderCode}"/></span>
                                        <span> - </span>
                                        <fmt:formatNumber value="${usage.discountAmount}" pattern="#,##0"/>Ä‘
                                    </span>
                                    <span class="usage-status ${usage.status}">
                                        <c:choose>
                                            <c:when test="${usage.status eq 'REFUNDED'}">Refunded</c:when>
                                            <c:otherwise>Applied</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                    <div class="actions">
                        <span class="status ${v.customerStatus}">
                            <c:choose>
                                <c:when test="${v.customerStatus eq 'AVAILABLE'}">Available</c:when>
                                <c:when test="${v.customerStatus eq 'USED'}">Used</c:when>
                                <c:otherwise>Expired</c:otherwise>
                            </c:choose>
                        </span>
                        <c:if test="${v.customerStatus eq 'AVAILABLE'}">
                            <a class="use" href="${pageContext.request.contextPath}/products?voucherCode=${v.code}">Use now</a>
                        </c:if>
                    </div>
                </div>
            </article>
        </c:forEach>

        <c:if test="${empty vouchers}">
            <div class="empty">
                <i class="bi bi-ticket-perforated fs-1"></i>
                <strong>No matching vouchers</strong>
                <p>Try another filter to see your remaining vouchers.</p>
            </div>
        </c:if>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
