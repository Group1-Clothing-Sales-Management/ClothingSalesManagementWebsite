<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html>

    <head>

        <meta charset="UTF-8">
        <title>Checkout</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
              rel="stylesheet">

        <style>

            body{
                background:#f4f6f9;
                font-family:'Segoe UI',sans-serif;
            }

            .page-title{
                font-size:34px;
                font-weight:700;
                color:#212529;
            }

            .page-subtitle{
                color:#6c757d;
                margin-bottom:30px;
            }

            .card{
                border:none;
                border-radius:18px;
                box-shadow:0 8px 25px rgba(0,0,0,.06);
                overflow:hidden;
            }

            .card-header{
                background:#fff;
                border-bottom:1px solid #ececec;
                padding:18px 24px;
                font-weight:700;
                font-size:18px;
            }

            .card-body{
                padding:24px;
            }

            .address-item{

                border:1px solid #e8e8e8;
                border-radius:15px;
                padding:18px;
                transition:.25s;
                margin-bottom:15px;
                cursor:pointer;

            }

            .address-item:hover{

                border-color:#0d6efd;
                background:#f8fbff;

            }

            .address-item input{

                margin-top:6px;

            }

            .recipient{

                font-size:18px;
                font-weight:700;

            }

            .address-info{

                color:#6c757d;
                margin-top:6px;

            }

            .default-badge{

                background:#198754;
                color:#fff;
                padding:7px 12px;
                border-radius:30px;
                font-size:12px;

            }

            .btn-manage{

                border-radius:12px;
                padding:9px 18px;

            }

            .btn-back{

                border-radius:12px;

            }

            .form-control{

                border-radius:12px;

            }

            textarea{

                resize:none;

            }

            .summary-row{

                display:flex;
                justify-content:space-between;
                margin-bottom:12px;

            }

            .total{

                font-size:22px;
                font-weight:bold;
                color:#dc3545;

            }

            .btn-place{

                border-radius:14px;
                padding:12px;
                font-size:17px;
                font-weight:600;

            }

            .table td{

                vertical-align:middle;

            }

            /* Shopee-style checkout layout */
            :root{
                --checkout-ink:#25211e;
                --checkout-muted:#6f665e;
                --checkout-primary:#c65b3d;
                --checkout-border:#e5e5e5;
                --checkout-page:#f5f5f5;
            }

            body{
                background:var(--checkout-page);
                color:var(--checkout-ink);
            }

            .checkout-topbar{
                min-height:34px;
                background:#c65b3d;
                color:#fff;
                font-size:12px;
            }

            .checkout-topbar-inner{
                max-width:1200px;
                min-height:34px;
                margin:0 auto;
                padding:0 4px;
                display:flex;
                align-items:center;
                justify-content:flex-start;
                gap:12px;
            }

            .checkout-topbar-group{
                display:flex;
                align-items:center;
                gap:9px;
                white-space:nowrap;
            }

            .checkout-topbar-group:nth-child(2){
                margin-left:auto;
            }

            .account-menu{
                position:relative;
            }

            .account-menu summary{
                display:flex;
                align-items:center;
                gap:6px;
                cursor:pointer;
                list-style:none;
            }

            .account-menu summary::-webkit-details-marker{
                display:none;
            }

            .account-avatar{
                width:20px;
                height:20px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                border-radius:50%;
                background:#087f68;
                color:#fff;
                font-size:11px;
                font-weight:700;
            }

            .account-dropdown{
                position:absolute;
                z-index:20;
                top:calc(100% + 10px);
                right:0;
                width:170px;
                padding:8px 0;
                background:#fff;
                border:1px solid var(--checkout-border);
                border-radius:6px;
                box-shadow:0 8px 22px rgba(37,33,30,.16);
            }

            .account-dropdown a{
                display:block;
                padding:9px 14px;
                color:var(--checkout-ink);
                font-size:13px;
                text-decoration:none;
            }

            .account-dropdown a:hover{
                background:#fff3ef;
                color:var(--checkout-primary);
            }

            .account-dropdown hr{
                margin:5px 0;
                border:0;
                border-top:1px solid var(--checkout-border);
            }

            .checkout-brand{
                min-height:100px;
                background:#fff;
                border-bottom:1px solid var(--checkout-border);
            }

            .checkout-brand-inner{
                max-width:1200px;
                min-height:100px;
                margin:0 auto;
                display:flex;
                align-items:center;
                gap:14px;
            }

            .checkout-logo{
                display:flex;
                align-items:center;
                gap:8px;
                color:var(--checkout-primary);
                font-size:27px;
                text-decoration:none;
            }

            .checkout-logo i{
                font-size:32px;
            }

            .checkout-brand-title{
                padding-left:14px;
                border-left:1px solid var(--checkout-primary);
                color:var(--checkout-primary);
                font-size:20px;
            }

            .checkout-search{
                display:flex;
                flex:1;
                max-width:700px;
                height:40px;
                margin-left:28px;
            }

            .checkout-search input{
                flex:1;
                min-width:0;
                border:2px solid var(--checkout-primary);
                border-right:0;
                padding:0 12px;
                color:var(--checkout-ink);
            }

            .checkout-search button{
                width:62px;
                border:0;
                background:var(--checkout-primary);
                color:#fff;
            }

            .checkout-cart-link{
                position:relative;
                margin-left:auto;
                color:var(--checkout-primary);
                font-size:28px;
                text-decoration:none;
            }

            .checkout-cart-count{
                position:absolute;
                top:-5px;
                right:-12px;
                min-width:18px;
                height:18px;
                padding:1px 5px;
                border-radius:10px;
                background:#fff;
                color:var(--checkout-primary);
                font-size:11px;
                text-align:center;
            }

            .checkout-category-row{
                display:none;
                justify-content:center;
                gap:20px;
                overflow:hidden;
                color:#fff;
                font-size:12px;
                white-space:nowrap;
            }

            .checkout-shell{
                width:calc(100% - 32px);
                max-width:1240px;
                margin:0 auto;
                padding:32px 0 56px!important;
            }

            .checkout-intro{
                display:none!important;
            }

            .checkout-layout{
                display:grid;
                grid-template-columns:minmax(0, 1.15fr) minmax(340px, .85fr);
                align-items:start;
                gap:20px;
                margin:0!important;
            }

            .checkout-main{
                display:contents;
            }

            .checkout-layout > .col-lg-8{
                grid-column:1;
                width:auto;
                max-width:none;
                padding:0!important;
            }

            .checkout-layout > .checkout-summary{
                grid-column:2;
                grid-row:1;
                width:auto;
                padding:0!important;
            }

            .checkout-page .card{
                border:1px solid var(--checkout-border);
                border-radius:14px;
                box-shadow:0 14px 36px rgba(74,54,39,.08);
            }

            .checkout-page .card-header{
                padding:17px 22px;
                border-bottom:1px solid var(--checkout-border);
                background:#fff;
                color:var(--checkout-ink);
                font-size:16px;
                font-weight:800;
            }

            .checkout-page .card-header i{
                color:var(--checkout-primary)!important;
            }

            .checkout-page .card-body{
                padding:0;
            }

            .address-card .card-header{
                border-top:3px solid var(--checkout-primary);
                border-radius:13px 13px 0 0;
            }

            .address-item{
                margin:0;
                padding:17px 22px;
                border:0;
                border-bottom:1px solid var(--checkout-border);
                border-radius:0;
            }

            .address-item:last-child{
                border-bottom:0;
            }

            .address-item .form-check{
                display:flex;
                align-items:flex-start;
                gap:10px;
            }

            .address-item .form-check-input{
                float:none;
                flex:0 0 auto;
                margin:4px 0 0;
            }

            .address-item .ms-4{
                min-width:0;
                flex:1;
                margin-left:0!important;
            }

            .address-item:hover{
                border-color:var(--checkout-border);
                background:#fffaf8;
            }

            .recipient{
                color:var(--checkout-ink);
                font-size:16px;
            }

            .address-info{
                display:inline-block;
                margin:5px 18px 0 0;
                color:var(--checkout-muted);
                font-size:14px;
            }

            .default-badge{
                padding:3px 6px;
                border:1px solid var(--checkout-primary);
                border-radius:0;
                background:#fff;
                color:var(--checkout-primary);
                font-size:11px;
            }

            .btn-manage{
                display:inline-flex;
                align-items:center;
                gap:6px;
                min-height:34px;
                padding:0 11px;
                border:1px solid #e0b9a6;
                border-radius:8px;
                color:var(--checkout-primary);
                background:#fff;
                font-weight:700;
            }

            .btn-manage:hover,
            .btn-manage:focus-visible{
                border-color:var(--checkout-primary);
                color:#fff;
                background:var(--checkout-primary);
            }

            .payment-card .card-body{
                padding:22px;
            }

            .checkout-summary .card-header{
                display:flex;
                align-items:center;
                justify-content:space-between;
            }

            .checkout-summary .card-body > .d-flex{
                min-height:104px;
                margin:0!important;
                padding:16px 22px!important;
                border-bottom:1px solid var(--checkout-border)!important;
            }

            .checkout-summary .card-body > .d-flex img{
                width:64px!important;
                height:64px!important;
                border-radius:0!important;
                object-fit:cover;
            }

            .checkout-summary .card-body > .d-flex .ms-3{
                min-width:0;
            }

            .checkout-summary .card-body > .d-flex .fw-bold{
                max-width:380px;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
                color:var(--checkout-ink);
                font-weight:400!important;
            }

            .checkout-summary .card-body > .d-flex .text-danger{
                color:var(--checkout-primary)!important;
            }

            .checkout-summary .card-body > hr{
                display:none;
            }

            .checkout-summary .card-body > .mb-4{
                margin:0!important;
                padding:16px 22px;
                border-bottom:1px solid var(--checkout-border);
            }

            .checkout-summary .summary-row{
                margin:0;
                padding:6px 22px;
                color:var(--checkout-muted);
            }

            .checkout-summary .summary-row.total{
                padding:16px 22px 22px;
                color:var(--checkout-muted);
            }

            .checkout-summary .summary-row.total span:last-child{
                color:var(--checkout-primary);
                font-size:25px;
                font-weight:500;
            }

            .checkout-page .form-control,
            .checkout-page .form-select{
                border:1px solid var(--checkout-border);
                border-radius:8px;
            }

            .checkout-page .form-control:focus,
            .checkout-page .form-select:focus{
                border-color:var(--checkout-primary);
                box-shadow:0 0 0 .2rem rgba(198,91,61,.12);
            }

            .checkout-page .btn-primary,
            .checkout-page .btn-success,
            .checkout-page .btn-place{
                border:0;
                border-radius:8px;
                background:var(--checkout-primary);
                color:#fff;
            }

            .checkout-page .btn-primary:hover,
            .checkout-page .btn-success:hover,
            .checkout-page .btn-place:hover{
                background:#a9462d;
                color:#fff;
            }

            .btn-place{
                width:100%;
                min-height:46px;
                min-width:0;
                font-size:15px;
            }

            @media(max-width:991px){
                .checkout-layout{
                    grid-template-columns:1fr;
                }

                .checkout-layout > .col-lg-8,
                .checkout-layout > .checkout-summary{
                    grid-column:1;
                    grid-row:auto;
                }
            }

            @media(max-width:767px){
                .checkout-topbar-inner{
                    padding:0 16px;
                }

                .checkout-topbar-group:nth-child(2){
                    display:none;
                }

                .checkout-account-menu{
                    display:flex;
                    margin-left:auto;
                }

                .checkout-brand-inner{
                    min-height:82px;
                    padding:0 16px;
                }

                .checkout-logo{
                    font-size:22px;
                }

                .checkout-brand-title{
                    font-size:17px;
                }

                .checkout-search{
                    margin-left:8px;
                }

                .checkout-category-row{
                    display:none;
                }

                .checkout-page .card-header,
                .address-item,
                .payment-card .card-body{
                    padding-left:16px;
                    padding-right:16px;
                }

                .checkout-summary .card-body > .d-flex{
                    padding-left:16px!important;
                    padding-right:16px!important;
                }

                .checkout-summary .summary-row{
                    padding-left:16px;
                    padding-right:16px;
                }

                .checkout-shell{
                    width:calc(100% - 20px);
                    padding-top:22px!important;
                }

                .address-info{
                    display:block;
                }
            }

            @media(max-width:575px){
                .checkout-brand-inner{
                    min-height:124px;
                    padding:12px 16px;
                    flex-wrap:wrap;
                }

                .checkout-search{
                    flex:0 0 100%;
                    max-width:none;
                    margin:0;
                    order:3;
                }
            }

        </style>

    </head>

    <body class="checkout-page">

        <div class="checkout-topbar">
            <div class="checkout-topbar-inner">
                <div class="checkout-topbar-group">
                    <span>Seller Centre</span>
                    <span>|</span>
                    <span>Shop Now</span>
                    <span>|</span>
                    <span>Follow us on</span>
                    <i class="bi bi-facebook"></i>
                    <i class="bi bi-instagram"></i>
                </div>
                <div class="checkout-topbar-group">
                    <span><i class="bi bi-bell me-1"></i>Notifications</span>
                    <span><i class="bi bi-question-circle me-1"></i>Help</span>
                    <span>English</span>
                </div>
                <details class="account-menu checkout-account-menu">
                    <summary aria-haspopup="menu">
                        <span class="account-avatar">M</span>
                        <span><c:out value="${not empty sessionScope.customerFullName ? sessionScope.customerFullName : sessionScope.authUsername}" default="Account"/></span>
                        <i class="bi bi-chevron-down"></i>
                    </summary>
                    <div class="account-dropdown" role="menu">
                        <a href="${pageContext.request.contextPath}/customer/profile" role="menuitem">Profile</a>
                        <a href="${pageContext.request.contextPath}/customer/orders" role="menuitem">My Orders</a>
                        <hr>
                        <a href="${pageContext.request.contextPath}/customer/logout" role="menuitem">Logout</a>
                    </div>
                </details>
            </div>
        </div>

        <div class="checkout-brand">
            <div class="checkout-brand-inner">
                <a href="${pageContext.request.contextPath}/home" class="checkout-logo">
                    <i class="bi bi-bag-fill"></i>
                    Clothing Sale
                </a>
                <span class="checkout-brand-title">Checkout</span>
                <form action="${pageContext.request.contextPath}/products" method="get" class="checkout-search">
                    <input type="text" name="keyword" placeholder="Search products">
                    <button type="submit" aria-label="Search products">
                        <i class="bi bi-search"></i>
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/cart" class="checkout-cart-link" aria-label="Cart">
                    <i class="bi bi-cart3"></i>
                    <span class="checkout-cart-count">0</span>
                </a>
            </div>
            <div class="checkout-category-row">
                <span>Phone Cases</span>
                <span>Desktop Microphones</span>
                <span>Yisong 003</span>
                <span>iPhone Models</span>
                <span>Arm sleeve gaming</span>
                <span>Centaur Gundam Chairs</span>
            </div>
        </div>

        <div class="container checkout-shell py-5">

            <div class="checkout-intro d-flex justify-content-between align-items-center mb-4">

                <div>

                    <div class="page-title">

                        Checkout

                    </div>

                    <div class="page-subtitle">

                        Review your shipping information before placing the order.

                    </div>

                </div>

            </div>

            <form method="post"
                  action="${pageContext.request.contextPath}/customer/checkout">

                <div class="row checkout-layout">

                    <!-- ================= LEFT ================= -->

                    <div class="col-lg-8">

                        <!-- SHIPPING ADDRESS -->

                        <div class="card address-card mb-4">

                            <div class="card-header">

                                <div class="d-flex justify-content-between align-items-center">

                                    <span>

                                        <i class="bi bi-geo-alt-fill text-danger"></i>

                                        Shipping Address

                                    </span>

                                    <a href="${pageContext.request.contextPath}/customer/address?from=checkout"
                                       class="btn btn-outline-primary btn-manage">

                                        <i class="bi bi-pencil-square"></i>

                                        Change

                                    </a>

                                </div>

                            </div>

                            <div class="card-body">

                                <c:forEach items="${addresses}" var="a">

                                    <label class="address-item d-block">

                                        <div class="form-check">

                                            <input class="form-check-input"
                                                   type="radio"
                                                   name="addressId"
                                                   value="${a.id}"

                                                   <c:if test="${a.isDefault()}">
                                                       checked
                                                   </c:if>>

                                            <div class="ms-4">

                                                <div class="d-flex justify-content-between">

                                                    <div>

                                                        <div class="recipient">

                                                            <i class="bi bi-person-circle"></i>

                                                            ${a.recipientName}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-telephone-fill"></i>

                                                            ${a.recipientPhone}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-house-door-fill"></i>

                                                            ${a.addressDetail}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-pin-map-fill"></i>

                                                            Ward :
                                                            ${a.wardId}

                                                        </div>

                                                    </div>

                                                    <div>

                                                        <c:if test="${a.isDefault()}">

                                                            <span class="default-badge">

                                                                <i class="bi bi-check-circle-fill"></i>

                                                                Default

                                                            </span>

                                                        </c:if>

                                                    </div>

                                                </div>

                                            </div>

                                        </div>

                                    </label>

                                </c:forEach>

                            </div>

                        </div>

                        <!-- PAYMENT & SHIPPING -->

                        <div class="card payment-card mb-4">

                            <div class="card-header">

                                <i class="bi bi-credit-card-fill text-primary"></i>

                                Payment & Shipping

                            </div>

                            <div class="card-body">

                                <!-- PAYMENT -->

                                <div class="mb-4">

                                    <label class="form-label fw-semibold">

                                        Payment Method

                                    </label>

                                    <div class="form-check">

                                        <input class="form-check-input"
                                               type="radio"
                                               name="paymentMethod"
                                               value="COD"
                                               checked>

                                        <label class="form-check-label">

                                            Cash On Delivery

                                        </label>

                                    </div>

                                    <div class="form-check">

                                        <input class="form-check-input"
                                               type="radio"
                                               name="paymentMethod"
                                               value="VNPAY">

                                        <label class="form-check-label">

                                            VNPay Online

                                        </label>

                                    </div>

                                </div>

                                <!-- SHIPPING -->

                                <div class="mb-4">

                                    <label class="form-label fw-semibold">

                                        Shipping Method

                                    </label>

                                    <select class="form-select"
                                            name="carrierName">
                                        <option value="GHTK">

                                            Economical Delivery (GHTK)

                                        </option>

                                        <option value="STORE">

                                            Self Delivery

                                        </option>

                                    </select>

                                </div>

                                <!-- ORDER NOTE -->

                                <div class="mb-4">

                                    <label class="form-label fw-semibold">

                                        Order Note

                                    </label>

                                    <textarea class="form-control"
                                              rows="4"
                                              name="note"
                                              placeholder="Write something for the shop..."></textarea>

                                </div>

                                <!-- PLACE ORDER -->

                                <div class="d-grid">

                                    <button type="submit"
                                            class="btn btn-success btn-place"
                                            name="action"
                                            value="placeOrder">

                                        <i class="bi bi-credit-card-fill"></i>

                                        Place Order

                                    </button>

                                </div>

                            </div>

                        </div>

                    </div>

                    <!-- ================= END LEFT ================= -->

                    <!-- ================= RIGHT ================= -->

                    <div class="col-lg-4 checkout-summary">

                        <div class="card">

                            <div class="card-header">

                                <i class="bi bi-bag-check-fill text-success"></i>

                                Products Ordered

                            </div>

                            <div class="card-body">
                                <c:forEach items="${cartItems}" var="item">

                                    <div class="d-flex align-items-start mb-3 pb-3 border-bottom">

                                        <!-- IMAGE -->

                                        <img src="${pageContext.request.contextPath}/uploads/product/${item.imageUrl}"
                                             class="rounded border"
                                             style="width:90px;
                                             height:90px;
                                             object-fit:cover;">

                                        <!-- INFO -->

                                        <div class="ms-3 flex-grow-1">

                                            <div class="fw-bold mb-2">

                                                ${item.productName}

                                            </div>

                                            <div class="small text-muted mb-1">

                                                <strong>Color :</strong>

                                                ${item.color}

                                            </div>

                                            <div class="small text-muted mb-1">

                                                <strong>Size :</strong>

                                                ${item.size}

                                            </div>

                                            <div class="small">

                                                <strong>Quantity :</strong>

                                                x${item.quantity}

                                            </div>

                                        </div>

                                        <!-- PRICE -->

                                        <div class="text-end">

                                            <div class="fw-bold text-danger">

                                                <fmt:formatNumber value="${item.price}" pattern="#,##0"/> &#8363;

                                            </div>

                                        </div>

                                    </div>

                                </c:forEach>


                                <hr>

                                <!-- Voucher -->

                                <div class="mb-4">

                                    <label class="form-label fw-semibold">
                                        Voucher Code
                                    </label>

                                    <div class="input-group">

                                        <input
                                            type="text"
                                            class="form-control"
                                            name="voucherCode"
                                            value="${voucherCode}"
                                            placeholder="Enter voucher...">

                                        <button
                                            class="btn btn-primary"
                                            type="submit"
                                            name="action"
                                            value="applyVoucher">

                                            Apply

                                        </button>

                                    </div>

                                    <c:if test="${not empty voucherError}">
                                        <div class="text-danger mt-2">
                                            ${voucherError}
                                        </div>
                                    </c:if>

                                </div>

                                <hr>

                                <div class="summary-row">

                                    <span>

                                        Subtotal

                                    </span>

                                    <strong>

                                        <fmt:formatNumber value="${cartTotal}" pattern="#,##0"/> &#8363;

                                    </strong>

                                </div>

                                <div class="summary-row">

                                    <span>

                                        Shipping Fee

                                    </span>

                                    <strong>

                                        <fmt:formatNumber value="30000" pattern="#,##0"/> &#8363;

                                    </strong>

                                </div>
                                <c:if test="${discountAmount != null}">
                                    <div class="summary-row">
                                        <span>Discount</span>
                                        <strong class="text-success">
                                            - <fmt:formatNumber value="${discountAmount}" pattern="#,##0"/> &#8363;
                                        </strong>
                                    </div>
                                </c:if>

                                <hr>

                                <div class="summary-row total">

                                    <span>

                                        Total

                                    </span>

                                    <span>

                                        <fmt:formatNumber value="${totalPayment}" pattern="#,##0"/> &#8363;

                                    </span>

                                </div>

                            </div>

                        </div>

                    </div>

                    <!-- ================= END RIGHT ================= -->

                </div>

            </form>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                document.querySelectorAll('.account-menu').forEach(function (account) {
                    var summary = account.querySelector('summary');

                    if (!summary) {
                        return;
                    }

                    account.addEventListener('toggle', function () {
                        summary.setAttribute('aria-expanded', account.open ? 'true' : 'false');
                    });
                    summary.setAttribute('aria-expanded', account.open ? 'true' : 'false');

                    document.addEventListener('click', function (event) {
                        if (!account.contains(event.target)) {
                            account.removeAttribute('open');
                            summary.setAttribute('aria-expanded', 'false');
                        }
                    });

                    document.addEventListener('keydown', function (event) {
                        if (event.key === 'Escape' && account.open) {
                            account.removeAttribute('open');
                            summary.setAttribute('aria-expanded', 'false');
                            summary.focus();
                        }
                    });
                });
            }());
        </script>

    </body>

</html>
