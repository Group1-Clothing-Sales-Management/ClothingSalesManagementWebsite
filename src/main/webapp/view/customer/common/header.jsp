<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="loggedIn"
       value="${not empty sessionScope.authUserId}"/>

<nav class="navbar custom-navbar market-header sticky-top" aria-label="Store navigation">
    <div class="market-topbar">
        <div class="market-header-inner market-topbar-inner">
            <div class="market-topbar-group">
                <a href="${pageContext.request.contextPath}/home">Seller Centre</a>
                <span class="market-separator">|</span>
                <a href="${pageContext.request.contextPath}/product">Shop Now</a>
                <span class="market-separator">|</span>
                <span>Follow us on</span>
                <i class="fa-brands fa-facebook"></i>
                <i class="fa-brands fa-instagram"></i>
            </div>

            <div class="market-topbar-group market-topbar-right">
                <span><i class="fa-regular fa-bell me-1"></i>Notifications</span>
                <span><i class="fa-regular fa-circle-question me-1"></i>Help</span>
                <span>English</span>

                <c:choose>
                    <c:when test="${loggedIn}">
                        <details class="market-account">
                            <summary aria-haspopup="menu">
                                <span class="market-avatar" aria-label="User avatar">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.authUsername}">
                                            <c:out value="${fn:toUpperCase(fn:substring(sessionScope.authUsername, 0, 1))}"/>
                                        </c:when>
                                        <c:otherwise>A</c:otherwise>
                                    </c:choose>
                                </span>
                                <span><c:out value="${not empty sessionScope.customerFullName
                                                ? sessionScope.customerFullName
                                                : sessionScope.authUsername}" default="Account"/></span>
                                <i class="fa-solid fa-chevron-down"></i>
                            </summary>
                            <div class="market-account-menu" role="menu">
                                <a href="${pageContext.request.contextPath}/customer/profile" role="menuitem">
                                    Profile
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/orders" role="menuitem">
                                    My Orders
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
                        <a class="market-login" href="${pageContext.request.contextPath}/customer/login">
                            Login
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="market-mainbar">
        <div class="market-header-inner market-mainbar-inner">
            <a href="${pageContext.request.contextPath}/home" class="market-brand">
                <i class="fa-solid fa-bag-shopping"></i>
                <span>Clothing Sale</span>
            </a>

            <form action="${pageContext.request.contextPath}/products" method="get" class="market-search">
                <input type="text" name="keyword" placeholder="500.000 &#8363; gift" aria-label="Search products">
                <button type="submit" aria-label="Search products">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>

            <a href="${pageContext.request.contextPath}/cart" class="market-cart" aria-label="Cart">
                <i class="fa-solid fa-cart-shopping"></i>
                <c:if test="${loggedIn and sessionScope.cartCount > 0}">
                    <span class="market-cart-badge">${sessionScope.cartCount}</span>
                </c:if>
            </a>
        </div>

        <div class="market-header-inner market-category-row" aria-label="Popular categories">
            <c:choose>
                <c:when test="${not empty headerCategories}">
                    <c:forEach items="${headerCategories}" var="category" varStatus="status">
                        <c:if test="${status.index < 7}">
                            <a href="${pageContext.request.contextPath}/product">
                                <c:out value="${category.categoryName}"/>
                            </a>
                        </c:if>
                    </c:forEach>
                    <c:if test="${fn:length(headerCategories) > 7}">
                        <a href="${pageContext.request.contextPath}/product" aria-label="More categories">...</a>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/product">Products</a>
                </c:otherwise>
            </c:choose>
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

    .market-topbar,
    .market-mainbar{
        color:#fff;
        background:#c65b3d;
    }

    .market-topbar{
        min-height:32px;
        font-size:12px;
    }

    .market-topbar-inner{
        min-height:32px;
        display:flex;
        align-items:center;
        justify-content:space-between;
        gap:16px;
    }

    .market-topbar-group{
        display:flex;
        align-items:center;
        gap:8px;
        white-space:nowrap;
    }

    .market-topbar a,
    .market-login{
        color:#fff;
        text-decoration:none;
    }

    .market-topbar a:hover,
    .market-login:hover{
        color:#fff;
        text-decoration:underline;
    }

    .market-separator{
        opacity:.65;
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

    .market-category-row{
        min-height:22px;
        display:flex;
        align-items:center;
        justify-content:center;
        gap:18px;
        overflow:hidden;
        font-size:12px;
        white-space:nowrap;
    }

    .market-category-row a{
        color:#fff;
        text-decoration:none;
    }

    .market-category-row a:hover{
        color:#fff;
        text-decoration:underline;
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
        top:calc(100% + 9px);
        right:0;
        width:180px;
        padding:8px 0;
        border:1px solid #eee2dc;
        border-radius:5px;
        background:#fff;
        box-shadow:0 10px 25px rgba(68,35,25,.18);
    }

    .market-account-menu a{
        display:block;
        padding:9px 14px;
        color:#332b27;
        font-size:13px;
        text-decoration:none;
    }

    .market-account-menu a:hover{
        background:#fff2ed;
        color:#c65b3d;
    }

    .market-account-menu hr{
        margin:5px 0;
        border:0;
        border-top:1px solid #eee2dc;
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

        .market-category-row {
            display:none;
        }
    }

    @media (max-width: 576px) {
        .market-topbar-inner {
            min-height:30px;
            width:calc(100% - 20px);
            gap:8px;
            overflow:visible;
        }

        .market-topbar-group {
            gap:5px;
            font-size:11px;
        }

        .market-topbar-right > span {
            display:none;
        }

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
        document.querySelectorAll('.market-account').forEach(function (account) {
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
