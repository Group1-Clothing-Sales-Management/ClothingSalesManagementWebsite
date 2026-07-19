<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="loggedIn"
       value="${not empty sessionScope.authUserId}"/>
<jsp:useBean id="headerProductDAO" class="com.clothingsale.dao.CustomerProductDAO" scope="page"/>
<c:set var="navCategories"
       value="${not empty headerCategories ? headerCategories : headerProductDAO.activeCategories}"/>

<nav class="navbar custom-navbar market-header sticky-top" aria-label="Store navigation">
    <div class="market-mainbar">
        <div class="market-header-inner market-mainbar-inner">
            <a href="${pageContext.request.contextPath}/home" class="market-brand">
                <i class="fa-solid fa-bag-shopping"></i>
                <span>Clothing Sale</span>
            </a>

            <div class="market-search-area">
                <form action="${pageContext.request.contextPath}/products" method="get" class="market-search">
                    <input type="text" name="keyword" placeholder="Search shirts, pants, accessories..." aria-label="Search products">
                    <button type="submit" aria-label="Search products">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                </form>

                <div class="market-category-strip" aria-label="Product categories">
                    <c:forEach items="${navCategories}" var="category">
                        <a class="${param.categoryId == category.id ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/products?categoryId=${category.id}">
                            <c:out value="${category.categoryName}"/>
                        </a>
                    </c:forEach>
                </div>
            </div>

            <c:choose>
                <c:when test="${loggedIn}">
                    <details class="market-main-account">
                        <summary aria-haspopup="menu">
                            <span class="market-user-dot" aria-label="User avatar">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.authUsername}">
                                        <c:out value="${fn:toUpperCase(fn:substring(sessionScope.authUsername, 0, 1))}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-user"></i>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <span class="market-main-account-name">
                                <c:out value="${not empty sessionScope.customerFullName
                                                ? sessionScope.customerFullName
                                                : sessionScope.authUsername}" default="Account"/>
                            </span>
                            <i class="fa-solid fa-chevron-down market-main-account-chevron"></i>
                        </summary>
                        <div class="market-account-menu" role="menu">
                            <a href="${pageContext.request.contextPath}/customer/profile" role="menuitem">
                                Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/orders" role="menuitem">
                                My Orders
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/returns" role="menuitem">
                                Returns & Refunds
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/vouchers" role="menuitem">
                                My Vouchers
                            </a>
                            <a href="${pageContext.request.contextPath}/wishlist" role="menuitem">
                                My Wishlist
                            </a>
                            <hr>
                            <a class="js-customer-logout"
                               href="${pageContext.request.contextPath}/customer/logout"
                               data-logout-url="${pageContext.request.contextPath}/customer/logout"
                               role="menuitem">
                                Logout
                            </a>
                        </div>
                    </details>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/customer/login" class="market-user-action" aria-label="Login">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </c:otherwise>
            </c:choose>

            <a href="${pageContext.request.contextPath}/cart" class="market-cart" aria-label="Cart">
                <i class="fa-solid fa-cart-shopping"></i>
                <span class="market-cart-text">Cart</span>
                <c:if test="${loggedIn and sessionScope.cartCount > 0}">
                    <span class="market-cart-badge">${sessionScope.cartCount}</span>
                </c:if>
            </a>
        </div>
    </div>
</nav>

<style>
    .market-header{
        display:block;
        width:100%;
        padding:0;
        border:0;
        background:transparent;
        box-shadow:0 2px 10px rgba(122,37,20,.12);
    }

    .market-header-inner{
        width:min(1200px, calc(100% - 32px));
        max-width:1200px;
        margin:0 auto;
    }

    .market-mainbar{
        color:#fff;
        background:#c65b3d;
    }

    .market-login{
        color:#fff;
        text-decoration:none;
    }

    .market-login:hover{
        color:#fff;
        text-decoration:underline;
    }

    .market-mainbar{
        min-height:80px;
    }

    .market-mainbar-inner{
        min-height:58px;
        display:flex;
        align-items:center;
        gap:14px;
    }

    .market-brand{
        display:flex;
        align-items:center;
        gap:8px;
        min-width:180px;
        color:#fff;
        font-size:28px;
        font-weight:500;
        text-decoration:none;
        white-space:nowrap;
    }

    .market-brand:hover{
        color:#fff;
    }

    .market-brand i{
        font-size:38px;
    }

    .market-search{
        display:flex;
        flex:1;
        max-width:840px;
        height:40px;
        margin-left:18px;
    }

    .market-search input{
        flex:1;
        min-width:0;
        border:2px solid #fff;
        border-right:0;
        border-radius:2px 0 0 2px;
        padding:0 12px;
        color:#39302c;
        outline:0;
    }

    .market-search button{
        width:64px;
        border:0;
        border-radius:0 2px 2px 0;
        background:#c65b3d;
        color:#fff;
    }

    .market-search button:hover{
        background:#a9462d;
    }

    .market-cart{
        position:relative;
        margin-left:auto;
        padding:4px 10px;
        color:#fff;
        font-size:29px;
        text-decoration:none;
    }

    .market-cart:hover{
        color:#fff;
    }

    .market-cart-badge{
        position:absolute;
        top:-3px;
        right:-2px;
        min-width:20px;
        height:18px;
        padding:1px 5px;
        border:2px solid #c65b3d;
        border-radius:10px;
        background:#fff;
        color:#c65b3d;
        font-size:11px;
        line-height:14px;
        text-align:center;
    }

    .market-account{
        position:relative;
    }

    .market-account summary{
        display:flex;
        align-items:center;
        gap:6px;
        cursor:pointer;
        list-style:none;
    }

    .market-account summary::-webkit-details-marker{
        display:none;
    }

    .market-avatar{
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

    .market-account-menu{
        position:absolute;
        z-index:1050;
        top:calc(100% + 10px);
        right:0;
        width:170px;
        padding:8px 0;
        border:1px solid #e5e5e5;
        border-radius:6px;
        background:#fff;
        box-shadow:0 8px 22px rgba(37,33,30,.16);
    }

    .market-account-menu a{
        display:block;
        padding:9px 14px;
        color:#25211e;
        font-size:13px;
        text-decoration:none;
    }

    .market-account-menu a:hover{
        background:#fff3ef;
        color:#c65b3d;
    }

    .market-account-menu hr{
        margin:5px 0;
        border:0;
        border-top:1px solid #e5e5e5;
    }
    .logout-confirm-modal .modal-dialog {
        max-width: 460px;
    }

    .logout-confirm-modal .modal-content {
        border: 0;
        border-radius: 18px;
        overflow: hidden;
        box-shadow: 0 26px 80px rgba(15, 23, 42, .26);
    }

    .logout-confirm-modal .modal-body {
        padding: 28px;
    }

    .logout-confirm-icon {
        width: 54px;
        height: 54px;
        border-radius: 16px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        background: linear-gradient(135deg, #25211e, #c65b3d);
        box-shadow: 0 14px 30px rgba(198, 91, 61, .24);
        flex: 0 0 auto;
        font-size: 22px;
    }

    .logout-confirm-title {
        margin: 0 0 6px;
        color: #25211e;
        font-size: 1.25rem;
        font-weight: 800;
    }

    .logout-confirm-text {
        margin: 0;
        color: #6f665e;
    }

    .logout-confirm-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 26px;
        flex-wrap: wrap;
    }

    .logout-confirm-actions .btn {
        min-height: 42px;
        border-radius: 10px;
        padding: 9px 16px;
        font-weight: 700;
    }

    .logout-confirm-actions .btn-danger {
        background: #a9462d;
        border-color: #a9462d;
    }

    .logout-confirm-actions .btn-danger:hover {
        background: #873724;
        border-color: #873724;
    }

    @media (max-width: 900px) {
        .market-header-inner {
            width:calc(100% - 24px);
        }

        .market-mainbar {
            padding-bottom:10px;
        }

        .market-mainbar-inner {
            min-height:92px;
            flex-wrap:wrap;
            padding-top:10px;
        }

        .market-brand {
            min-width:0;
            font-size:24px;
        }

        .market-brand i {
            font-size:32px;
        }

        .market-search {
            order:3;
            flex:0 0 100%;
            max-width:none;
            height:38px;
            margin:0;
        }

        .market-cart {
            margin-left:auto;
        }

    }

    @media (max-width: 576px) {
        .market-mainbar-inner {
            min-height:86px;
            width:calc(100% - 20px);
        }

        .market-brand {
            font-size:21px;
        }

        .market-brand i {
            font-size:29px;
        }

        .market-cart {
            font-size:25px;
        }

        .market-account-menu {
            right:-4px;
        }

        .logout-confirm-actions .btn {
            width: 100%;
        }
    }

    /* Baby blue header refresh */
    .market-header{
        background:#fff;
        box-shadow:0 8px 28px rgba(95,132,214,.16);
    }

    .market-mainbar{
        color:#fff;
        background:#8AAAE5;
        padding:12px 0 0;
    }

    .market-login{
        color:#fff;
        font-weight:700;
    }

    .market-mainbar-inner{
        min-height:70px;
        gap:18px;
    }

    .market-brand{
        color:#fff;
        font-weight:800;
        letter-spacing:0;
        min-width:300px;
        font-size:32px;
    }

    .market-brand:hover{
        color:#fff;
    }

    .market-brand i{
        width:58px;
        height:58px;
        border-radius:8px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        background:#fff;
        color:#5f84d6;
        font-size:31px;
        box-shadow:0 12px 24px rgba(95,132,214,.22);
    }

    .market-catalog{
        min-width:150px;
        height:54px;
        border-radius:999px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        gap:10px;
        color:#fff;
        background:rgba(54,91,159,.32);
        text-decoration:none;
        font-size:18px;
        font-weight:800;
        box-shadow:inset 0 0 0 1px rgba(255,255,255,.18);
        transition:background .18s ease, transform .18s ease;
    }

    .market-catalog:hover{
        color:#fff;
        background:rgba(54,91,159,.48);
        transform:translateY(-1px);
    }

    .market-catalog i{
        font-size:23px;
    }

    .market-search{
        height:58px;
        max-width:none;
        margin-left:0;
        border-radius:8px;
        overflow:hidden;
        box-shadow:0 12px 28px rgba(95,132,214,.18);
    }

    .market-search input{
        border:0;
        padding:0 22px;
        color:#1f2937;
        background:#fff;
        font-size:16px;
    }

    .market-search input::placeholder{
        color:#8b98ad;
    }

    .market-search button{
        width:76px;
        border:0;
        background:#fff;
        color:#5f84d6;
        font-size:24px;
    }

    .market-search button:hover{
        background:#eef4ff;
        color:#365b9f;
    }

    .market-user-action{
        width:58px;
        height:58px;
        border-radius:50%;
        flex:0 0 58px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        color:#fff;
        background:rgba(54,91,159,.32);
        text-decoration:none;
        font-size:24px;
        font-weight:800;
        transition:background .18s ease, transform .18s ease;
    }

    .market-user-action:hover{
        color:#fff;
        background:rgba(54,91,159,.48);
        transform:translateY(-1px);
    }

    .market-main-account{
        position:relative;
        flex:0 0 auto;
    }

    .market-main-account summary{
        min-width:190px;
        height:58px;
        border-radius:999px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        gap:10px;
        padding:0 16px 0 10px;
        color:#fff;
        background:rgba(54,91,159,.32);
        cursor:pointer;
        list-style:none;
        font-weight:800;
        transition:background .18s ease, transform .18s ease;
    }

    .market-main-account summary::-webkit-details-marker{
        display:none;
    }

    .market-main-account summary:hover{
        background:rgba(54,91,159,.48);
        transform:translateY(-1px);
    }

    .market-main-account-name{
        max-width:125px;
        overflow:hidden;
        text-overflow:ellipsis;
        white-space:nowrap;
        font-size:16px;
    }

    .market-main-account-chevron{
        font-size:12px;
        opacity:.9;
    }

    .market-main-account .market-account-menu{
        top:calc(100% + 10px);
        right:0;
    }

    .market-user-dot{
        width:30px;
        height:30px;
        border-radius:50%;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        background:#fff;
        color:#5f84d6;
        font-size:14px;
        font-weight:900;
    }

    .market-cart{
        min-width:142px;
        height:58px;
        border-radius:999px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        gap:10px;
        color:#fff;
        background:rgba(31,41,55,.22);
        font-size:21px;
        font-weight:800;
        transition:transform .18s ease;
    }

    .market-cart:hover{
        color:#fff;
        transform:translateY(-1px);
        background:rgba(31,41,55,.32);
    }

    .market-cart i{
        font-size:25px;
    }

    .market-cart-text{
        font-size:18px;
        line-height:1;
    }

    .market-cart-badge{
        border-color:#8AAAE5;
        color:#5f84d6;
        background:#fff;
    }

    .market-avatar{
        background:#fff;
        color:#5f84d6;
    }

    .market-account-menu{
        border-color:#d7e1f5;
        border-radius:8px;
        box-shadow:0 18px 42px rgba(95,132,214,.18);
    }

    .market-account-menu a{
        color:#1f2937;
    }

    .market-account-menu a:hover{
        background:#eef4ff;
        color:#365b9f;
    }

    .logout-confirm-icon{
        background:linear-gradient(135deg,#5f84d6,#8AAAE5);
        box-shadow:0 14px 30px rgba(95,132,214,.28);
    }

    .logout-confirm-title{
        color:#1f2937;
    }

    .logout-confirm-text{
        color:#61708a;
    }

    .logout-confirm-actions .btn-danger{
        background:#8AAAE5;
        border-color:#8AAAE5;
    }

    .logout-confirm-actions .btn-danger:hover{
        background:#5f84d6;
        border-color:#5f84d6;
    }

    @media (max-width: 900px) {
        .market-mainbar {
            padding-bottom:12px;
        }

        .market-mainbar-inner {
            min-height:96px;
            flex-wrap:wrap;
            padding-top:12px;
        }

        .market-brand {
            min-width:0;
            font-size:24px;
        }

        .market-brand i {
            width:40px;
            height:40px;
            font-size:24px;
        }

        .market-search {
            order:4;
            flex:0 0 100%;
            max-width:none;
            height:44px;
            margin:0;
        }

        .market-catalog{
            order:3;
            min-width:132px;
            height:42px;
            font-size:15px;
        }

        .market-user-action{
            width:42px;
            height:42px;
            flex-basis:42px;
            font-size:18px;
        }

        .market-main-account summary{
            min-width:42px;
            width:42px;
            height:42px;
            padding:0;
        }

        .market-main-account-name,
        .market-main-account-chevron{
            display:none;
        }

        .market-main-account .market-user-dot{
            width:26px;
            height:26px;
            font-size:12px;
        }

        .market-cart {
            margin-left:auto;
            min-width:46px;
            width:46px;
            height:42px;
            padding:0;
            border-radius:50%;
        }

        .market-cart-text{
            display:none;
        }
    }

    @media (max-width: 576px) {
        .market-mainbar-inner {
            min-height:88px;
        }

        .market-brand {
            font-size:21px;
        }

        .market-brand i {
            width:36px;
            height:36px;
            font-size:21px;
        }

        .market-cart {
            font-size:25px;
        }

        .market-catalog{
            min-width:118px;
            height:38px;
            font-size:14px;
        }

        .market-user-action{
            width:38px;
            height:38px;
            flex-basis:38px;
            font-size:16px;
        }

        .market-main-account summary{
            min-width:38px;
            width:38px;
            height:38px;
        }
    }

    /* Compact header with inline categories */
    .market-mainbar{
        padding:8px 0 7px;
    }

    .market-mainbar-inner{
        min-height:68px;
        gap:14px;
        align-items:center;
    }

    .market-brand{
        min-width:260px;
        font-size:28px;
    }

    .market-brand i{
        width:48px;
        height:48px;
        font-size:26px;
    }

    .market-catalog{
        min-width:138px;
        height:44px;
        gap:8px;
        font-size:16px;
    }

    .market-catalog i{
        font-size:20px;
    }

    .market-search-area{
        flex:1 1 420px;
        min-width:260px;
        display:flex;
        flex-direction:column;
        gap:7px;
    }

    .market-search{
        width:100%;
        height:44px;
        margin:0;
    }

    .market-search input{
        padding:0 18px;
        font-size:15px;
    }

    .market-search button{
        width:62px;
        font-size:21px;
    }

    .market-category-strip{
        min-height:18px;
        display:flex;
        align-items:center;
        justify-content:center;
        gap:24px;
        overflow:hidden;
        color:#fff;
    }

    .market-category-strip a{
        color:#fff;
        font-size:13px;
        font-weight:800;
        line-height:1;
        text-decoration:none;
        text-shadow:0 1px 8px rgba(54,91,159,.25);
        white-space:nowrap;
    }

    .market-category-strip a:hover{
        color:#eef4ff;
        text-decoration:underline;
        text-underline-offset:4px;
    }

    .market-category-strip a.active{
        color:#fff;
        text-decoration:underline;
        text-decoration-thickness:2px;
        text-underline-offset:5px;
    }

    .market-user-action{
        width:48px;
        height:48px;
        flex-basis:48px;
        font-size:20px;
    }

    .market-main-account summary{
        min-width:176px;
        height:48px;
        padding:0 14px 0 9px;
    }

    .market-user-dot{
        width:28px;
        height:28px;
        font-size:13px;
    }

    .market-main-account-name{
        max-width:116px;
        font-size:15px;
    }

    .market-cart{
        min-width:122px;
        height:48px;
        gap:9px;
        font-size:19px;
    }

    .market-cart i{
        font-size:22px;
    }

    .market-cart-text{
        font-size:16px;
    }

    @media (max-width: 1100px) {
        .market-brand{
            min-width:220px;
            font-size:24px;
        }

        .market-category-strip{
            gap:16px;
        }

        .market-main-account summary{
            min-width:150px;
        }
    }

    @media (max-width: 900px) {
        .market-mainbar{
            padding:8px 0 10px;
        }

        .market-mainbar-inner{
            min-height:112px;
            gap:10px;
        }

        .market-search-area{
            order:5;
            flex:0 0 100%;
            min-width:0;
            gap:8px;
        }

        .market-search{
            height:42px;
        }

        .market-category-strip{
            justify-content:flex-start;
            gap:10px;
            overflow-x:auto;
            padding-bottom:2px;
            scrollbar-width:none;
        }

        .market-category-strip::-webkit-scrollbar{
            display:none;
        }

        .market-category-strip a{
            padding:6px 10px;
            border-radius:999px;
            background:rgba(54,91,159,.22);
            font-size:12px;
        }
    }

    @media (max-width: 576px) {
        .market-brand{
            font-size:20px;
        }

        .market-brand i{
            width:36px;
            height:36px;
            font-size:20px;
        }

        .market-catalog{
            min-width:112px;
            height:36px;
            font-size:13px;
        }

        .market-search{
            height:40px;
        }
    }
</style>

<div class="modal fade logout-confirm-modal" id="customerLogoutModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <div class="d-flex align-items-start gap-3">
                    <div class="logout-confirm-icon">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </div>
                    <div class="pe-4">
                        <h5 class="logout-confirm-title">Sign out?</h5>
                        <p class="logout-confirm-text">
                            You will leave your customer account and return to the store homepage.
                        </p>
                    </div>
                    <button type="button"
                            class="btn-close ms-auto"
                            data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="logout-confirm-actions">
                    <button type="button"
                            class="btn btn-outline-secondary"
                            data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <a id="confirmCustomerLogoutButton"
                       href="${pageContext.request.contextPath}/customer/logout"
                       class="btn btn-danger">
                        Sign out
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
        document.querySelectorAll('.market-account, .market-main-account').forEach(function (account) {
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

        var logoutLink = document.querySelector('.js-customer-logout');
        var logoutModalElement = document.getElementById('customerLogoutModal');
        var confirmLogoutButton = document.getElementById('confirmCustomerLogoutButton');

        if (!logoutLink || !logoutModalElement || !confirmLogoutButton) {
            return;
        }

        logoutLink.addEventListener('click', function (event) {
            event.preventDefault();
            var logoutUrl = logoutLink.getAttribute('data-logout-url') || logoutLink.href;
            confirmLogoutButton.href = logoutUrl;

            if (window.bootstrap && window.bootstrap.Modal) {
                bootstrap.Modal.getOrCreateInstance(logoutModalElement).show();
            } else {
                window.location.href = logoutUrl;
            }
        });
    })();
</script>
