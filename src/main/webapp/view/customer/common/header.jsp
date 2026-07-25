<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<c:set var="loggedIn" value="${not empty sessionScope.authUserId}"/>
<c:set var="requestUri" value="${pageContext.request.requestURI}"/>

<c:set var="activeCategoryId"
       value="${not empty requestScope.selectedCategoryId
                ? requestScope.selectedCategoryId
                : (not empty param.categoryId
                   ? param.categoryId
                   : (not empty requestScope.product
                      ? requestScope.product.categoryId
                      : null))}"/>

<c:set var="isProductListPage"
       value="${fn:endsWith(requestUri, '/products')
                or fn:endsWith(requestUri, '/product')}"/>

<c:set var="allProductsActive"
       value="${isProductListPage and empty activeCategoryId}"/>

<c:set var="headerDisplayName"
       value="${not empty sessionScope.customerFullName
                ? sessionScope.customerFullName
                : (not empty sessionScope.authFullName
                   ? sessionScope.authFullName
                   : sessionScope.authUsername)}"/>

<c:set var="headerCartCount"
       value="${not empty sessionScope.cart
                ? fn:length(sessionScope.cart)
                : 0}"/>

<header class="customer-store-header sticky-top">
    <div class="customer-store-header-main">
        <div class="customer-layout-container customer-store-header-row">
            <a href="${pageContext.request.contextPath}/home"
               class="customer-store-brand"
               aria-label="Go to Clothing Sale homepage">
                <span class="customer-store-brand-mark">
                    <i class="fa-solid fa-bag-shopping"></i>
                </span>
                <span class="customer-store-brand-name">Clothing Sale</span>
            </a>

            <form action="${pageContext.request.contextPath}/products"
                  method="get"
                  class="customer-store-search"
                  role="search">
                <label class="visually-hidden"
                       for="customerStoreSearchInput">
                    Search products
                </label>

                <input id="customerStoreSearchInput"
                       type="search"
                       name="keyword"
                       value="<c:out value='${param.keyword}'/>"
                       placeholder="Search products..."
                       autocomplete="off"/>

                <button type="submit" aria-label="Search products">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>

            <div class="customer-store-actions">
                <a href="${pageContext.request.contextPath}/wishlist"
                   class="customer-store-action customer-store-wishlist"
                   aria-label="Wishlist"
                   title="Wishlist">
                    <span class="customer-store-action-icon">
                        <i class="fa-regular fa-heart"></i>
                    </span>
                    <span class="customer-store-action-label">Wishlist</span>

                    <c:if test="${sessionScope.wishlistCount > 0}">
                        <span class="customer-store-count-badge">
                            <c:out value="${sessionScope.wishlistCount}"/>
                        </span>
                    </c:if>
                </a>

                <c:choose>
                    <c:when test="${loggedIn}">
                        <details class="customer-store-account">
                            <summary aria-haspopup="menu"
                                     aria-expanded="false">
                                <span class="customer-store-user-avatar">
                                    <c:choose>
                                        <c:when test="${not empty headerDisplayName}">
                                            <c:out value="${fn:toUpperCase(
                                                            fn:substring(
                                                                headerDisplayName,
                                                                0,
                                                                1
                                                            )
                                                        )}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-solid fa-user"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </span>

                                <span class="customer-store-account-copy">
                                    <small>Account</small>
                                    <strong>
                                        <c:out value="${headerDisplayName}"
                                               default="Customer"/>
                                    </strong>
                                </span>

                                <i class="fa-solid fa-chevron-down
                                   customer-store-account-chevron"></i>
                            </summary>

                            <div class="customer-store-account-menu"
                                 role="menu">
                                <div class="customer-store-account-menu-heading">
                                    <span>Signed in as</span>
                                    <strong>
                                        <c:out value="${headerDisplayName}"
                                               default="Customer"/>
                                    </strong>
                                </div>

                                <a href="${pageContext.request.contextPath}/customer/profile"
                                   role="menuitem">
                                    <i class="fa-regular fa-user"></i>
                                    <span>Profile</span>
                                </a>

                                <a href="${pageContext.request.contextPath}/customer/orders"
                                   role="menuitem">
                                    <i class="fa-solid fa-box"></i>
                                    <span>My Orders</span>
                                </a>

                                <a href="${pageContext.request.contextPath}/customer/returns"
                                   role="menuitem">
                                    <i class="fa-solid fa-rotate-left"></i>
                                    <span>Returns &amp; Refunds</span>
                                </a>

                                <a href="${pageContext.request.contextPath}/customer/vouchers"
                                   role="menuitem">
                                    <i class="fa-solid fa-ticket"></i>
                                    <span>My Vouchers</span>
                                </a>

                                <a href="${pageContext.request.contextPath}/wishlist"
                                   role="menuitem">
                                    <i class="fa-regular fa-heart"></i>
                                    <span>My Wishlist</span>
                                </a>

                                <hr/>

                                <a class="js-customer-logout
                                   customer-store-logout-link"
                                   href="${pageContext.request.contextPath}/customer/logout"
                                   data-logout-url="${pageContext.request.contextPath}/customer/logout"
                                   role="menuitem">
                                    <i class="fa-solid fa-right-from-bracket"></i>
                                    <span>Logout</span>
                                </a>
                            </div>
                        </details>
                    </c:when>

                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/login"
                           class="customer-store-action customer-store-login"
                           aria-label="Login"
                           title="Login">
                            <span class="customer-store-action-icon">
                                <i class="fa-regular fa-user"></i>
                            </span>
                            <span class="customer-store-action-label">Login</span>
                        </a>
                    </c:otherwise>
                </c:choose>

                <a href="${pageContext.request.contextPath}/cart"
                   class="customer-store-action customer-store-cart"
                   aria-label="Shopping cart"
                   title="Shopping cart">
                    <span class="customer-store-action-icon">
                        <i class="fa-solid fa-cart-shopping"></i>
                    </span>
                    <span class="customer-store-action-label">Cart</span>

                    <c:if test="${headerCartCount > 0}">
                        <span class="customer-store-count-badge">
                            <c:out value="${headerCartCount}"/>
                        </span>
                    </c:if>
                </a>
            </div>
        </div>
    </div>

    <nav class="customer-store-category-nav"
         aria-label="Product categories">
        <div class="customer-layout-container
             customer-store-category-track">
            <a href="${pageContext.request.contextPath}/products"
               class="customer-store-category-all
                      ${allProductsActive ? 'is-active' : ''}">
                <i class="fa-solid fa-border-all"></i>
                <span>All Products</span>
            </a>

            <c:forEach items="${headerCategories}"
                       var="parentCategory">
                <c:set var="parentActive"
                       value="${activeCategoryId == parentCategory.id}"/>

                <c:forEach items="${parentCategory.children}"
                           var="childCategory">
                    <c:if test="${activeCategoryId == childCategory.id}">
                        <c:set var="parentActive" value="true"/>
                    </c:if>
                </c:forEach>

                <div class="customer-store-category-group
                     ${parentActive ? 'is-active' : ''}">
                    <a href="${pageContext.request.contextPath}/products?categoryId=${parentCategory.id}"
                       class="customer-store-category-parent">
                        <c:out value="${parentCategory.categoryName}"/>
                    </a>

                    <c:if test="${not empty parentCategory.children}">
                        <button type="button"
                                class="customer-store-category-toggle"
                                aria-label="Open ${fn:escapeXml(parentCategory.categoryName)} categories"
                                aria-expanded="false">
                            <i class="fa-solid fa-chevron-down"></i>
                        </button>

                        <div class="customer-store-category-menu">
                            <a href="${pageContext.request.contextPath}/products?categoryId=${parentCategory.id}"
                               class="customer-store-category-overview
                                      ${activeCategoryId == parentCategory.id
                                        ? 'is-active'
                                        : ''}">
                                <span>View all</span>
                                <strong>
                                    <c:out value="${parentCategory.categoryName}"/>
                                </strong>
                            </a>

                            <div class="customer-store-category-menu-list">
                                <c:forEach items="${parentCategory.children}"
                                           var="childCategory">
                                    <a href="${pageContext.request.contextPath}/products?categoryId=${childCategory.id}"
                                       class="${activeCategoryId == childCategory.id
                                                ? 'is-active'
                                                : ''}">
                                        <span>
                                            <c:out value="${childCategory.categoryName}"/>
                                        </span>
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
        --customer-layout-max-width: 1320px;
        --customer-layout-gutter: 24px;

        --customer-header-blue: #86a8e5;
        --customer-header-blue-light: #9bb7e9;
        --customer-header-blue-dark: #5f84d6;
        --customer-header-blue-deep: #365b9f;
        --customer-header-navy: #17233d;
        --customer-header-text: #283750;
        --customer-header-muted: #6b7890;
        --customer-header-border: #dbe4f3;
        --customer-header-surface: #ffffff;
        --customer-header-soft: #f4f7fc;
    }

    .customer-layout-container {
        width: min(
            var(--customer-layout-max-width),
            calc(100% - (var(--customer-layout-gutter) * 2))
        );
        margin-right: auto;
        margin-left: auto;
    }

    .customer-store-header {
        z-index: 1035;
        width: 100%;
        color: var(--customer-header-text);
        background: var(--customer-header-surface);
        box-shadow: 0 5px 24px rgba(49, 78, 130, .14);
    }

    .customer-store-header-main {
        background: linear-gradient(
            115deg,
            var(--customer-header-blue) 0%,
            var(--customer-header-blue-light) 100%
        );
    }

    .customer-store-header-row {
        min-height: 76px;
        display: flex;
        align-items: center;
        gap: 18px;
    }

    .customer-store-brand {
        flex: 0 0 auto;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        color: #ffffff;
        font-size: 1.55rem;
        font-weight: 850;
        line-height: 1;
        letter-spacing: -.035em;
        text-decoration: none;
        white-space: nowrap;
    }

    .customer-store-brand:hover {
        color: #ffffff;
    }

    .customer-store-brand-mark {
        width: 46px;
        height: 46px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 13px;
        color: var(--customer-header-blue-dark);
        background: #ffffff;
        box-shadow: 0 8px 20px rgba(54, 91, 159, .18);
    }

    .customer-store-brand-mark i {
        font-size: 1.35rem;
    }

    .customer-store-search {
        height: 44px;
        display: flex;
        flex: 1 1 520px;
        min-width: 220px;
        overflow: hidden;
        border: 1px solid rgba(255, 255, 255, .68);
        border-radius: 11px;
        background: #ffffff;
        box-shadow: 0 6px 20px rgba(54, 91, 159, .15);
    }

    .customer-store-search input {
        flex: 1 1 auto;
        min-width: 0;
        border: 0;
        outline: 0;
        padding: 0 16px;
        color: var(--customer-header-text);
        background: transparent;
        font-size: .9rem;
    }

    .customer-store-search input::placeholder {
        color: #8a96aa;
    }

    .customer-store-search button {
        width: 54px;
        flex: 0 0 54px;
        border: 0;
        color: var(--customer-header-blue-deep);
        background: #ffffff;
        font-size: 1.05rem;
        transition: color .2s ease, background-color .2s ease;
    }

    .customer-store-search button:hover {
        color: #ffffff;
        background: var(--customer-header-blue-deep);
    }

    .customer-store-actions {
        flex: 0 0 auto;
        display: flex;
        align-items: center;
        gap: 9px;
    }

    .customer-store-action,
    .customer-store-account summary {
        position: relative;
        min-height: 46px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        border: 1px solid rgba(255, 255, 255, .2);
        border-radius: 12px;
        color: #ffffff;
        background: rgba(54, 91, 159, .25);
        text-decoration: none;
        cursor: pointer;
        transition: color .2s ease, background-color .2s ease,
            transform .2s ease;
    }

    .customer-store-action {
        min-width: 86px;
        padding: 0 13px;
    }

    .customer-store-action:hover,
    .customer-store-account summary:hover {
        color: #ffffff;
        background: rgba(54, 91, 159, .4);
        transform: translateY(-1px);
    }

    .customer-store-action-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1.05rem;
    }

    .customer-store-action-label {
        font-size: .78rem;
        font-weight: 750;
    }

    .customer-store-count-badge {
        position: absolute;
        top: -7px;
        right: -5px;
        min-width: 21px;
        height: 21px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0 5px;
        border: 2px solid var(--customer-header-blue);
        border-radius: 999px;
        color: #ffffff;
        background: #d9485f;
        font-size: .64rem;
        font-weight: 850;
        line-height: 1;
    }

    .customer-store-account {
        position: relative;
        margin: 0;
    }

    .customer-store-account summary {
        min-width: 164px;
        max-width: 205px;
        padding: 5px 12px 5px 6px;
        list-style: none;
    }

    .customer-store-account summary::-webkit-details-marker {
        display: none;
    }

    .customer-store-user-avatar {
        width: 34px;
        height: 34px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 34px;
        border-radius: 10px;
        color: var(--customer-header-blue-deep);
        background: #ffffff;
        font-size: .78rem;
        font-weight: 850;
    }

    .customer-store-account-copy {
        min-width: 0;
        display: flex;
        flex: 1 1 auto;
        flex-direction: column;
        align-items: flex-start;
        line-height: 1.15;
    }

    .customer-store-account-copy small {
        color: rgba(255, 255, 255, .78);
        font-size: .62rem;
        font-weight: 650;
    }

    .customer-store-account-copy strong {
        max-width: 112px;
        overflow: hidden;
        color: #ffffff;
        font-size: .76rem;
        font-weight: 780;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .customer-store-account-chevron {
        flex: 0 0 auto;
        font-size: .62rem;
        transition: transform .2s ease;
    }

    .customer-store-account[open]
    .customer-store-account-chevron {
        transform: rotate(180deg);
    }

    .customer-store-account-menu {
        position: absolute;
        z-index: 1085;
        top: calc(100% + 11px);
        right: 0;
        width: 236px;
        padding: 8px;
        border: 1px solid var(--customer-header-border);
        border-radius: 14px;
        background: #ffffff;
        box-shadow: 0 22px 54px rgba(23, 35, 61, .22);
    }

    .customer-store-account-menu::before {
        content: "";
        position: absolute;
        top: -7px;
        right: 25px;
        width: 13px;
        height: 13px;
        border-top: 1px solid var(--customer-header-border);
        border-left: 1px solid var(--customer-header-border);
        background: #ffffff;
        transform: rotate(45deg);
    }

    .customer-store-account-menu-heading {
        position: relative;
        z-index: 1;
        display: flex;
        flex-direction: column;
        gap: 2px;
        margin: 2px 2px 7px;
        padding: 10px;
        border-radius: 10px;
        background: var(--customer-header-soft);
    }

    .customer-store-account-menu-heading span {
        color: var(--customer-header-muted);
        font-size: .65rem;
        font-weight: 650;
    }

    .customer-store-account-menu-heading strong {
        overflow: hidden;
        color: var(--customer-header-navy);
        font-size: .8rem;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .customer-store-account-menu a {
        position: relative;
        z-index: 1;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 11px;
        border-radius: 9px;
        color: var(--customer-header-text);
        font-size: .78rem;
        font-weight: 650;
        text-decoration: none;
    }

    .customer-store-account-menu a i {
        width: 18px;
        color: var(--customer-header-blue-deep);
        text-align: center;
    }

    .customer-store-account-menu a:hover {
        color: var(--customer-header-blue-deep);
        background: #eef4ff;
    }

    .customer-store-account-menu
    .customer-store-logout-link:hover {
        color: #b83247;
        background: #fff1f3;
    }

    .customer-store-account-menu
    .customer-store-logout-link:hover i {
        color: #b83247;
    }

    .customer-store-account-menu hr {
        margin: 6px 4px;
        border: 0;
        border-top: 1px solid var(--customer-header-border);
        opacity: 1;
    }

    .customer-store-category-nav {
        min-height: 50px;
        border-bottom: 1px solid var(--customer-header-border);
        background: #ffffff;
    }

    .customer-store-category-track {
        min-height: 50px;
        display: flex;
        align-items: stretch;
        justify-content: center;
        gap: 2px;
    }

    .customer-store-category-all,
    .customer-store-category-group {
        position: relative;
        flex: 0 0 auto;
        display: flex;
        align-items: center;
    }

    .customer-store-category-all,
    .customer-store-category-parent {
        min-height: 50px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 0 13px;
        color: var(--customer-header-text);
        font-size: .78rem;
        font-weight: 750;
        text-decoration: none;
        white-space: nowrap;
    }

    .customer-store-category-parent {
        padding-right: 4px;
    }

    .customer-store-category-toggle {
        width: 29px;
        height: 34px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 0;
        border-radius: 8px;
        color: var(--customer-header-muted);
        background: transparent;
        font-size: .58rem;
    }

    .customer-store-category-all:hover,
    .customer-store-category-parent:hover,
    .customer-store-category-group:hover
    .customer-store-category-parent,
    .customer-store-category-group:hover
    .customer-store-category-toggle {
        color: var(--customer-header-blue-deep);
    }

    .customer-store-category-all::after,
    .customer-store-category-group::after {
        content: "";
        position: absolute;
        right: 10px;
        bottom: 0;
        left: 10px;
        height: 3px;
        border-radius: 3px 3px 0 0;
        background: var(--customer-header-blue-dark);
        transform: scaleX(0);
        transition: transform .2s ease;
    }

    .customer-store-category-all.is-active::after,
    .customer-store-category-group.is-active::after,
    .customer-store-category-all:hover::after,
    .customer-store-category-group:hover::after {
        transform: scaleX(1);
    }

    .customer-store-category-all.is-active,
    .customer-store-category-group.is-active
    .customer-store-category-parent,
    .customer-store-category-group.is-active
    .customer-store-category-toggle {
        color: var(--customer-header-blue-deep);
    }

    .customer-store-category-menu {
        position: absolute;
        z-index: 1080;
        top: calc(100% - 1px);
        left: 0;
        width: 258px;
        padding: 10px;
        border: 1px solid var(--customer-header-border);
        border-radius: 0 0 14px 14px;
        visibility: hidden;
        opacity: 0;
        background: #ffffff;
        box-shadow: 0 20px 45px rgba(23, 35, 61, .18);
        transform: translateY(8px);
        transition: opacity .18s ease, transform .18s ease,
            visibility .18s ease;
    }

    .customer-store-category-group:nth-last-child(-n+2)
    .customer-store-category-menu {
        right: 0;
        left: auto;
    }

    .customer-store-category-group:hover
    .customer-store-category-menu,
    .customer-store-category-group:focus-within
    .customer-store-category-menu,
    .customer-store-category-group.is-open
    .customer-store-category-menu {
        visibility: visible;
        opacity: 1;
        transform: translateY(0);
    }

    .customer-store-category-overview {
        display: flex;
        flex-direction: column;
        gap: 2px;
        padding: 11px 12px;
        border-radius: 10px;
        color: var(--customer-header-text);
        background: var(--customer-header-soft);
        text-decoration: none;
    }

    .customer-store-category-overview span {
        color: var(--customer-header-muted);
        font-size: .66rem;
    }

    .customer-store-category-overview strong {
        color: var(--customer-header-blue-deep);
        font-size: .82rem;
    }

    .customer-store-category-overview:hover,
    .customer-store-category-overview.is-active {
        background: #e8f0ff;
    }

    .customer-store-category-menu-list {
        display: grid;
        gap: 3px;
        margin-top: 7px;
    }

    .customer-store-category-menu-list a {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 10px 11px;
        border-radius: 9px;
        color: var(--customer-header-text);
        font-size: .76rem;
        font-weight: 650;
        text-decoration: none;
    }

    .customer-store-category-menu-list a i {
        color: var(--customer-header-blue-dark);
        font-size: .58rem;
        opacity: 0;
        transform: translateX(-5px);
        transition: opacity .18s ease, transform .18s ease;
    }

    .customer-store-category-menu-list a:hover,
    .customer-store-category-menu-list a.is-active {
        color: var(--customer-header-blue-deep);
        background: #eef4ff;
    }

    .customer-store-category-menu-list a:hover i,
    .customer-store-category-menu-list a.is-active i {
        opacity: 1;
        transform: translateX(0);
    }

    .customer-logout-modal .modal-dialog {
        max-width: 460px;
    }

    .customer-logout-modal .modal-content {
        overflow: hidden;
        border: 0;
        border-radius: 18px;
        box-shadow: 0 26px 80px rgba(15, 23, 42, .26);
    }

    .customer-logout-modal .modal-body {
        padding: 28px;
    }

    .customer-logout-icon {
        width: 54px;
        height: 54px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 54px;
        border-radius: 16px;
        color: #ffffff;
        background: linear-gradient(
            135deg,
            var(--customer-header-blue-deep),
            var(--customer-header-blue)
        );
        box-shadow: 0 14px 30px rgba(95, 132, 214, .24);
        font-size: 1.3rem;
    }

    .customer-logout-title {
        margin: 2px 0 6px;
        color: var(--customer-header-navy);
        font-weight: 800;
    }

    .customer-logout-text {
        margin: 0;
        color: var(--customer-header-muted);
        font-size: .84rem;
    }

    .customer-logout-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 25px;
    }

    .customer-logout-actions .btn {
        min-width: 105px;
        border-radius: 10px;
        font-weight: 700;
    }

    .customer-logout-actions .btn-danger {
        border-color: var(--customer-header-blue-dark);
        background: var(--customer-header-blue-dark);
    }

    @media (max-width: 1199.98px) {
        .customer-store-header-row {
            gap: 12px;
        }

        .customer-store-brand-name {
            display: none;
        }

        .customer-store-action {
            min-width: 46px;
            width: 46px;
            padding: 0;
        }

        .customer-store-action-label {
            display: none;
        }

        .customer-store-account summary {
            min-width: 48px;
            width: 48px;
            padding: 6px;
        }

        .customer-store-account-copy,
        .customer-store-account-chevron {
            display: none;
        }

        .customer-store-category-track {
            justify-content: flex-start;
        }
    }

    @media (max-width: 767.98px) {
        :root {
            --customer-layout-gutter: 16px;
        }

        .customer-store-header-main {
            padding: 10px 0;
        }

        .customer-store-header-row {
            min-height: 108px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .customer-store-brand-name {
            display: inline;
            font-size: 1.18rem;
        }

        .customer-store-brand-mark {
            width: 40px;
            height: 40px;
        }

        .customer-store-actions {
            margin-left: auto;
        }

        .customer-store-search {
            order: 10;
            flex: 1 0 100%;
            height: 42px;
        }

        .customer-store-category-nav {
            overflow-x: auto;
            overscroll-behavior-inline: contain;
            scrollbar-width: thin;
        }

        .customer-store-category-track {
            width: max-content;
            min-width: 100%;
            justify-content: flex-start;
        }

        .customer-store-category-all,
        .customer-store-category-parent {
            min-height: 46px;
            padding-right: 11px;
            padding-left: 11px;
        }

        .customer-store-category-toggle,
        .customer-store-category-menu {
            display: none;
        }

        .customer-store-category-parent {
            padding-right: 11px;
        }
    }

    @media (max-width: 479.98px) {
        .customer-store-brand-name {
            display: none;
        }

        .customer-store-actions {
            gap: 6px;
        }

        .customer-store-action,
        .customer-store-account summary {
            width: 42px;
            min-width: 42px;
            min-height: 42px;
        }

        .customer-store-user-avatar {
            width: 30px;
            height: 30px;
            flex-basis: 30px;
        }

        .customer-store-account-menu {
            position: fixed;
            top: 68px;
            right: 12px;
            width: min(236px, calc(100vw - 24px));
        }
    }
</style>

<div class="modal fade customer-logout-modal"
     id="customerLogoutModal"
     tabindex="-1"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <div class="d-flex align-items-start gap-3">
                    <div class="customer-logout-icon">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </div>

                    <div class="pe-4">
                        <h5 class="customer-logout-title">Sign out?</h5>
                        <p class="customer-logout-text">
                            You will leave your customer account and return
                            to the store homepage.
                        </p>
                    </div>

                    <button type="button"
                            class="btn-close ms-auto"
                            data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="customer-logout-actions">
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
        "use strict";

        var categoryGroups = document.querySelectorAll(
                ".customer-store-category-group"
        );

        categoryGroups.forEach(function (group) {
            var toggle = group.querySelector(
                    ".customer-store-category-toggle"
            );

            if (!toggle) {
                return;
            }

            toggle.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();

                var shouldOpen = !group.classList.contains("is-open");

                categoryGroups.forEach(function (otherGroup) {
                    otherGroup.classList.remove("is-open");

                    var otherToggle = otherGroup.querySelector(
                            ".customer-store-category-toggle"
                    );

                    if (otherToggle) {
                        otherToggle.setAttribute(
                                "aria-expanded",
                                "false"
                        );
                    }
                });

                group.classList.toggle("is-open", shouldOpen);
                toggle.setAttribute(
                        "aria-expanded",
                        shouldOpen ? "true" : "false"
                );
            });
        });

        document.addEventListener("click", function (event) {
            categoryGroups.forEach(function (group) {
                if (group.contains(event.target)) {
                    return;
                }

                group.classList.remove("is-open");

                var toggle = group.querySelector(
                        ".customer-store-category-toggle"
                );

                if (toggle) {
                    toggle.setAttribute(
                            "aria-expanded",
                            "false"
                    );
                }
            });
        });

        document.querySelectorAll(
                ".customer-store-account"
        ).forEach(function (account) {
            var summary = account.querySelector("summary");

            if (!summary) {
                return;
            }

            account.addEventListener("toggle", function () {
                summary.setAttribute(
                        "aria-expanded",
                        account.open ? "true" : "false"
                );
            });

            document.addEventListener("click", function (event) {
                if (!account.contains(event.target)) {
                    account.removeAttribute("open");
                    summary.setAttribute(
                            "aria-expanded",
                            "false"
                    );
                }
            });
        });

        document.addEventListener("keydown", function (event) {
            if (event.key !== "Escape") {
                return;
            }

            categoryGroups.forEach(function (group) {
                group.classList.remove("is-open");

                var toggle = group.querySelector(
                        ".customer-store-category-toggle"
                );

                if (toggle) {
                    toggle.setAttribute(
                            "aria-expanded",
                            "false"
                    );
                }
            });

            document.querySelectorAll(
                    ".customer-store-account[open]"
            ).forEach(function (account) {
                account.removeAttribute("open");
            });
        });

        var logoutLink = document.querySelector(
                ".js-customer-logout"
        );

        var logoutModalElement = document.getElementById(
                "customerLogoutModal"
        );

        var confirmLogoutButton = document.getElementById(
                "confirmCustomerLogoutButton"
        );

        if (!logoutLink
                || !logoutModalElement
                || !confirmLogoutButton) {
            return;
        }

        logoutLink.addEventListener("click", function (event) {
            event.preventDefault();

            confirmLogoutButton.href
                    = logoutLink.getAttribute("data-logout-url")
                    || logoutLink.href;

            if (window.bootstrap
                    && window.bootstrap.Modal) {

                window.bootstrap.Modal
                        .getOrCreateInstance(logoutModalElement)
                        .show();

                return;
            }

            if (window.confirm("Sign out of your customer account?")) {
                window.location.href = confirmLogoutButton.href;
            }
        });
    })();
</script>