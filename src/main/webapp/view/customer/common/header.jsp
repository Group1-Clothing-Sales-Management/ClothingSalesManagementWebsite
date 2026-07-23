<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<c:set var="loggedIn" value="${not empty sessionScope.authUserId}"/>
<c:set var="selectedCategoryId" value="${param.categoryId}"/>

<jsp:useBean id="headerProductDAO"
             class="com.clothingsale.dao.CustomerProductDAO"
             scope="page"/>

<c:set var="navCategoryGroups"
       value="${not empty headerCategories
                ? headerCategories
                : headerProductDAO.headerCategories}"/>

<header class="store-header sticky-top">
    <div class="store-header-main">
        <div class="store-header-container store-header-main-inner">
            <a href="${pageContext.request.contextPath}/home"
               class="store-brand"
               aria-label="Clothing Sale home">
                <span class="store-brand-icon">
                    <i class="fa-solid fa-bag-shopping"></i>
                </span>
                <span>Clothing Sale</span>
            </a>

            <form action="${pageContext.request.contextPath}/products"
                  method="get"
                  class="store-search"
                  role="search">
                <c:if test="${not empty selectedCategoryId}">
                    <input type="hidden"
                           name="categoryId"
                           value="<c:out value='${selectedCategoryId}'/>"/>
                </c:if>

                <label class="visually-hidden" for="storeHeaderKeyword">
                    Search products
                </label>
                <input id="storeHeaderKeyword"
                       type="search"
                       name="keyword"
                       value="<c:out value='${param.keyword}'/>"
                       placeholder="Search clothing, accessories and sportswear..."
                       autocomplete="off"/>
                <button type="submit" aria-label="Search products">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>

            <div class="store-header-actions">
                <c:choose>
                    <c:when test="${loggedIn}">
                        <details class="store-account">
                            <summary aria-haspopup="menu">
                                <span class="store-user-avatar">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.authUsername}">
                                            <c:out value="${fn:toUpperCase(fn:substring(sessionScope.authUsername, 0, 1))}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-solid fa-user"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </span>

                                <span class="store-account-name">
                                    <c:out value="${not empty sessionScope.customerFullName
                                                    ? sessionScope.customerFullName
                                                    : sessionScope.authUsername}"
                                           default="Account"/>
                                </span>

                                <i class="fa-solid fa-chevron-down store-account-chevron"></i>
                            </summary>

                            <div class="store-account-menu" role="menu">
                                <a href="${pageContext.request.contextPath}/customer/profile"
                                   role="menuitem">
                                    <i class="fa-regular fa-user"></i>
                                    Profile
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/orders"
                                   role="menuitem">
                                    <i class="fa-solid fa-box"></i>
                                    My Orders
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/returns"
                                   role="menuitem">
                                    <i class="fa-solid fa-rotate-left"></i>
                                    Returns &amp; Refunds
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/vouchers"
                                   role="menuitem">
                                    <i class="fa-solid fa-ticket"></i>
                                    My Vouchers
                                </a>
                                <a href="${pageContext.request.contextPath}/wishlist"
                                   role="menuitem">
                                    <i class="fa-regular fa-heart"></i>
                                    My Wishlist
                                </a>
                                <hr/>
                                <a class="js-customer-logout"
                                   href="${pageContext.request.contextPath}/customer/logout"
                                   data-logout-url="${pageContext.request.contextPath}/customer/logout"
                                   role="menuitem">
                                    <i class="fa-solid fa-right-from-bracket"></i>
                                    Logout
                                </a>
                            </div>
                        </details>
                    </c:when>

                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/login"
                           class="store-login"
                           aria-label="Login">
                            <i class="fa-regular fa-user"></i>
                            <span>Login</span>
                        </a>
                    </c:otherwise>
                </c:choose>

                <a href="${pageContext.request.contextPath}/cart"
                   class="store-cart"
                   aria-label="Cart">
                    <i class="fa-solid fa-cart-shopping"></i>
                    <span>Cart</span>
                    <c:if test="${loggedIn and sessionScope.cartCount > 0}">
                        <span class="store-cart-badge">
                            <c:out value="${sessionScope.cartCount}"/>
                        </span>
                    </c:if>
                </a>
            </div>
        </div>
    </div>

    <nav class="store-category-nav" aria-label="Product categories">
        <div class="store-header-container store-category-track">
            <a href="${pageContext.request.contextPath}/products"
               class="store-category-all ${empty selectedCategoryId ? 'is-active' : ''}">
                <i class="fa-solid fa-border-all"></i>
                All Products
            </a>

            <c:forEach items="${navCategoryGroups}" var="parentCategory">
                <c:set var="parentActive"
                       value="${selectedCategoryId == parentCategory.id}"/>

                <c:forEach items="${parentCategory.children}" var="childCategory">
                    <c:if test="${selectedCategoryId == childCategory.id}">
                        <c:set var="parentActive" value="true"/>
                    </c:if>
                </c:forEach>

                <div class="store-category-group ${parentActive ? 'is-active' : ''}">
                    <a href="${pageContext.request.contextPath}/products?categoryId=${parentCategory.id}"
                       class="store-category-parent">
                        <c:out value="${parentCategory.categoryName}"/>
                    </a>

                    <c:if test="${not empty parentCategory.children}">
                        <button type="button"
                                class="store-category-toggle"
                                aria-label="Open ${parentCategory.categoryName} categories"
                                aria-expanded="false">
                            <i class="fa-solid fa-chevron-down"></i>
                        </button>

                        <div class="store-category-menu">
                            <a href="${pageContext.request.contextPath}/products?categoryId=${parentCategory.id}"
                               class="store-category-view-all ${selectedCategoryId == parentCategory.id ? 'is-active' : ''}">
                                <span>View all</span>
                                <strong><c:out value="${parentCategory.categoryName}"/></strong>
                            </a>

                            <div class="store-category-menu-list">
                                <c:forEach items="${parentCategory.children}" var="childCategory">
                                    <a href="${pageContext.request.contextPath}/products?categoryId=${childCategory.id}"
                                       class="${selectedCategoryId == childCategory.id ? 'is-active' : ''}">
                                        <span><c:out value="${childCategory.categoryName}"/></span>
                                        <i class="fa-solid fa-arrow-right"></i>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </nav>
</header>

<style>
    :root {
        --store-blue: #86a8e5;
        --store-blue-dark: #5f84d6;
        --store-blue-deep: #365b9f;
        --store-navy: #17233d;
        --store-text: #24324a;
        --store-muted: #6b7890;
        --store-border: #dbe4f3;
        --store-surface: #ffffff;
        --store-soft: #f4f7fc;
    }

    .store-header {
        z-index: 1035;
        width: 100%;
        color: var(--store-text);
        background: var(--store-surface);
        box-shadow: 0 5px 24px rgba(49, 78, 130, .14);
    }

    .store-header-container {
        width: min(1500px, calc(100% - 32px));
        margin: 0 auto;
    }

    .store-header-main {
        background: linear-gradient(115deg, var(--store-blue) 0%, #92b1e8 100%);
    }

    .store-header-main-inner {
        min-height: 72px;
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .store-brand {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        flex: 0 0 auto;
        color: #fff;
        font-size: 27px;
        font-weight: 800;
        line-height: 1;
        text-decoration: none;
        white-space: nowrap;
    }

    .store-brand:hover {
        color: #fff;
    }

    .store-brand-icon {
        width: 48px;
        height: 48px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 13px;
        color: var(--store-blue-dark);
        background: #fff;
        box-shadow: 0 8px 20px rgba(54, 91, 159, .18);
    }

    .store-brand-icon i {
        font-size: 24px;
    }

    .store-search {
        height: 44px;
        display: flex;
        flex: 1 1 580px;
        min-width: 240px;
        overflow: hidden;
        border-radius: 11px;
        background: #fff;
        box-shadow: 0 6px 20px rgba(54, 91, 159, .16);
    }

    .store-search input {
        flex: 1;
        min-width: 0;
        border: 0;
        outline: 0;
        padding: 0 18px;
        color: var(--store-text);
        background: transparent;
        font-size: 15px;
    }

    .store-search input::placeholder {
        color: #8a96aa;
    }

    .store-search button {
        width: 58px;
        flex: 0 0 58px;
        border: 0;
        color: var(--store-blue-dark);
        background: #fff;
        font-size: 21px;
        transition: background .2s ease, color .2s ease;
    }

    .store-search button:hover {
        color: #fff;
        background: var(--store-blue-dark);
    }

    .store-header-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        flex: 0 0 auto;
    }

    .store-account {
        position: relative;
    }

    .store-account summary,
    .store-login,
    .store-cart {
        min-height: 46px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        border: 1px solid rgba(255, 255, 255, .18);
        border-radius: 999px;
        color: #fff;
        background: rgba(54, 91, 159, .27);
        text-decoration: none;
        cursor: pointer;
        transition: background .2s ease, transform .2s ease;
    }

    .store-account summary {
        min-width: 190px;
        padding: 6px 16px 6px 8px;
        list-style: none;
    }

    .store-account summary::-webkit-details-marker {
        display: none;
    }

    .store-account summary:hover,
    .store-login:hover,
    .store-cart:hover {
        color: #fff;
        background: rgba(54, 91, 159, .42);
        transform: translateY(-1px);
    }

    .store-user-avatar {
        width: 34px;
        height: 34px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 34px;
        border-radius: 50%;
        color: var(--store-blue-dark);
        background: #fff;
        font-size: 14px;
        font-weight: 800;
    }

    .store-account-name {
        max-width: 126px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        font-size: 14px;
        font-weight: 750;
    }

    .store-account-chevron {
        font-size: 11px;
        transition: transform .2s ease;
    }

    .store-account[open] .store-account-chevron {
        transform: rotate(180deg);
    }

    .store-login {
        padding: 0 18px;
        font-weight: 750;
    }

    .store-cart {
        position: relative;
        min-width: 118px;
        padding: 0 20px;
        font-weight: 750;
    }

    .store-cart i {
        font-size: 20px;
    }

    .store-cart-badge {
        position: absolute;
        top: -6px;
        right: -3px;
        min-width: 22px;
        height: 22px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0 6px;
        border: 2px solid var(--store-blue);
        border-radius: 999px;
        color: #fff;
        background: #e05252;
        font-size: 11px;
        font-weight: 800;
    }

    .store-account-menu {
        position: absolute;
        z-index: 1085;
        top: calc(100% + 10px);
        right: 0;
        width: 220px;
        padding: 8px;
        border: 1px solid var(--store-border);
        border-radius: 14px;
        background: #fff;
        box-shadow: 0 20px 50px rgba(23, 35, 61, .20);
    }

    .store-account-menu::before {
        content: "";
        position: absolute;
        top: -7px;
        right: 28px;
        width: 13px;
        height: 13px;
        border-top: 1px solid var(--store-border);
        border-left: 1px solid var(--store-border);
        background: #fff;
        transform: rotate(45deg);
    }

    .store-account-menu a {
        position: relative;
        z-index: 1;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 11px;
        border-radius: 9px;
        color: var(--store-text);
        font-size: 13px;
        font-weight: 650;
        text-decoration: none;
    }

    .store-account-menu a i {
        width: 18px;
        color: var(--store-blue-dark);
        text-align: center;
    }

    .store-account-menu a:hover {
        color: var(--store-blue-deep);
        background: #eef4ff;
    }

    .store-account-menu hr {
        margin: 6px 4px;
        border: 0;
        border-top: 1px solid var(--store-border);
        opacity: 1;
    }

    .store-category-nav {
        min-height: 48px;
        border-bottom: 1px solid var(--store-border);
        background: #fff;
    }

    .store-category-track {
        min-height: 48px;
        display: flex;
        align-items: stretch;
        justify-content: center;
        gap: 4px;
    }

    .store-category-all,
    .store-category-group {
        position: relative;
        display: flex;
        align-items: center;
        flex: 0 0 auto;
    }

    .store-category-all,
    .store-category-parent {
        min-height: 48px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 0 15px;
        color: var(--store-text);
        font-size: 13px;
        font-weight: 750;
        text-decoration: none;
        white-space: nowrap;
    }

    .store-category-parent {
        padding-right: 5px;
    }

    .store-category-toggle {
        width: 30px;
        height: 36px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 0;
        border-radius: 8px;
        color: var(--store-muted);
        background: transparent;
        font-size: 10px;
    }

    .store-category-all:hover,
    .store-category-parent:hover,
    .store-category-group:hover .store-category-parent,
    .store-category-group:hover .store-category-toggle {
        color: var(--store-blue-deep);
    }

    .store-category-all::after,
    .store-category-group::after {
        content: "";
        position: absolute;
        right: 12px;
        bottom: 0;
        left: 12px;
        height: 3px;
        border-radius: 3px 3px 0 0;
        background: var(--store-blue-dark);
        transform: scaleX(0);
        transition: transform .2s ease;
    }

    .store-category-all.is-active::after,
    .store-category-group.is-active::after,
    .store-category-all:hover::after,
    .store-category-group:hover::after {
        transform: scaleX(1);
    }

    .store-category-all.is-active,
    .store-category-group.is-active .store-category-parent,
    .store-category-group.is-active .store-category-toggle {
        color: var(--store-blue-deep);
    }

    .store-category-menu {
        position: absolute;
        z-index: 1080;
        top: calc(100% - 1px);
        left: 0;
        width: 255px;
        padding: 10px;
        border: 1px solid var(--store-border);
        border-radius: 0 0 14px 14px;
        visibility: hidden;
        opacity: 0;
        background: #fff;
        box-shadow: 0 20px 45px rgba(23, 35, 61, .18);
        transform: translateY(8px);
        transition: opacity .18s ease, transform .18s ease, visibility .18s ease;
    }

    .store-category-group:hover .store-category-menu,
    .store-category-group:focus-within .store-category-menu,
    .store-category-group.is-open .store-category-menu {
        visibility: visible;
        opacity: 1;
        transform: translateY(0);
    }

    .store-category-view-all {
        display: flex;
        flex-direction: column;
        gap: 2px;
        padding: 11px 12px;
        border-radius: 10px;
        color: var(--store-text);
        background: var(--store-soft);
        text-decoration: none;
    }

    .store-category-view-all span {
        color: var(--store-muted);
        font-size: 11px;
    }

    .store-category-view-all strong {
        color: var(--store-blue-deep);
        font-size: 14px;
    }

    .store-category-view-all:hover,
    .store-category-view-all.is-active {
        background: #e8f0ff;
    }

    .store-category-menu-list {
        display: grid;
        gap: 3px;
        margin-top: 7px;
    }

    .store-category-menu-list a {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 10px 11px;
        border-radius: 9px;
        color: var(--store-text);
        font-size: 13px;
        font-weight: 650;
        text-decoration: none;
    }

    .store-category-menu-list a i {
        color: var(--store-blue-dark);
        font-size: 10px;
        opacity: 0;
        transform: translateX(-5px);
        transition: opacity .18s ease, transform .18s ease;
    }

    .store-category-menu-list a:hover,
    .store-category-menu-list a.is-active {
        color: var(--store-blue-deep);
        background: #eef4ff;
    }

    .store-category-menu-list a:hover i,
    .store-category-menu-list a.is-active i {
        opacity: 1;
        transform: translateX(0);
    }

    .logout-confirm-modal .modal-dialog {
        max-width: 460px;
    }

    .logout-confirm-modal .modal-content {
        overflow: hidden;
        border: 0;
        border-radius: 18px;
        box-shadow: 0 26px 80px rgba(15, 23, 42, .26);
    }

    .logout-confirm-modal .modal-body {
        padding: 28px;
    }

    .logout-confirm-icon {
        width: 54px;
        height: 54px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 54px;
        border-radius: 16px;
        color: #fff;
        background: linear-gradient(135deg, var(--store-blue-deep), var(--store-blue));
        box-shadow: 0 14px 30px rgba(95, 132, 214, .24);
        font-size: 22px;
    }

    .logout-confirm-title {
        margin: 2px 0 6px;
        color: var(--store-navy);
        font-weight: 800;
    }

    .logout-confirm-text {
        margin: 0;
        color: var(--store-muted);
        font-size: 14px;
    }

    .logout-confirm-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 25px;
    }

    .logout-confirm-actions .btn {
        min-width: 105px;
        border-radius: 10px;
        font-weight: 700;
    }

    .logout-confirm-actions .btn-danger {
        border-color: var(--store-blue-dark);
        background: var(--store-blue-dark);
    }

    @media (max-width: 1180px) {
        .store-header-main-inner {
            gap: 12px;
        }

        .store-brand {
            font-size: 23px;
        }

        .store-account summary {
            min-width: 155px;
        }

        .store-account-name {
            max-width: 92px;
        }

        .store-category-track {
            justify-content: flex-start;
        }
    }

    @media (max-width: 900px) {
        .store-header-main {
            padding: 10px 0;
        }

        .store-header-main-inner {
            flex-wrap: wrap;
        }

        .store-search {
            order: 5;
            flex-basis: 100%;
        }

        .store-header-actions {
            margin-left: auto;
        }

        .store-category-track {
            flex-wrap: wrap;
            justify-content: center;
            padding: 5px 0;
        }

        .store-category-nav,
        .store-category-track {
            min-height: 44px;
        }

        .store-category-all,
        .store-category-parent {
            min-height: 38px;
            padding-right: 10px;
            padding-left: 10px;
        }

        .store-category-group::after,
        .store-category-all::after {
            right: 8px;
            left: 8px;
        }
    }

    @media (max-width: 620px) {
        .store-header-container {
            width: min(100% - 20px, 1500px);
        }

        .store-brand {
            font-size: 20px;
        }

        .store-brand-icon {
            width: 40px;
            height: 40px;
        }

        .store-account summary {
            min-width: 46px;
            width: 46px;
            padding: 5px;
        }

        .store-account-name,
        .store-account-chevron,
        .store-login span,
        .store-cart span:not(.store-cart-badge) {
            display: none;
        }

        .store-login,
        .store-cart {
            width: 46px;
            min-width: 46px;
            padding: 0;
        }

        .store-category-track {
            justify-content: flex-start;
        }

        .store-category-menu {
            right: auto;
            left: 50%;
            width: min(280px, calc(100vw - 20px));
            border-radius: 14px;
            transform: translate(-50%, 8px);
        }

        .store-category-group:hover .store-category-menu,
        .store-category-group:focus-within .store-category-menu,
        .store-category-group.is-open .store-category-menu {
            transform: translate(-50%, 0);
        }
    }
</style>

<div class="modal fade logout-confirm-modal"
     id="customerLogoutModal"
     tabindex="-1"
     aria-hidden="true">
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
        var categoryGroups = document.querySelectorAll('.store-category-group');

        categoryGroups.forEach(function (group) {
            var toggle = group.querySelector('.store-category-toggle');

            if (!toggle) {
                return;
            }

            toggle.addEventListener('click', function (event) {
                event.preventDefault();
                event.stopPropagation();

                var willOpen = !group.classList.contains('is-open');

                categoryGroups.forEach(function (otherGroup) {
                    otherGroup.classList.remove('is-open');
                    var otherToggle = otherGroup.querySelector('.store-category-toggle');
                    if (otherToggle) {
                        otherToggle.setAttribute('aria-expanded', 'false');
                    }
                });

                group.classList.toggle('is-open', willOpen);
                toggle.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
            });
        });

        document.addEventListener('click', function (event) {
            categoryGroups.forEach(function (group) {
                if (!group.contains(event.target)) {
                    group.classList.remove('is-open');
                    var toggle = group.querySelector('.store-category-toggle');
                    if (toggle) {
                        toggle.setAttribute('aria-expanded', 'false');
                    }
                }
            });
        });

        document.querySelectorAll('.store-account').forEach(function (account) {
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
        });

        document.addEventListener('keydown', function (event) {
            if (event.key !== 'Escape') {
                return;
            }

            categoryGroups.forEach(function (group) {
                group.classList.remove('is-open');
                var toggle = group.querySelector('.store-category-toggle');
                if (toggle) {
                    toggle.setAttribute('aria-expanded', 'false');
                }
            });

            document.querySelectorAll('.store-account[open]').forEach(function (account) {
                account.removeAttribute('open');
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
            confirmLogoutButton.href = logoutLink.getAttribute('data-logout-url') || logoutLink.href;

            if (window.bootstrap && window.bootstrap.Modal) {
                window.bootstrap.Modal.getOrCreateInstance(logoutModalElement).show();
            } else {
                window.location.href = confirmLogoutButton.href;
            }
        });
    })();
</script>