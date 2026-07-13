<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="loggedIn"
       value="${not empty sessionScope.authUserId}"/>

<nav class="navbar navbar-expand-lg custom-navbar sticky-top">

    <div class="container">

        <!-- LOGO -->
        <a href="${pageContext.request.contextPath}/home"
           class="navbar-brand brand-logo">

            <i class="fa-solid fa-shirt"></i>
            Clothing Sale

        </a>

        <!-- MENU -->
        <div class="d-flex align-items-center gap-1 flex-wrap ms-auto nav-actions">

            <a href="${pageContext.request.contextPath}/home"
               class="nav-btn">
                <i class="fa-solid fa-house"></i>
                Home
            </a>

            <a href="${pageContext.request.contextPath}/products"
               class="nav-btn">
                <i class="fa-solid fa-store"></i>
                Products
            </a>

            <c:if test="${loggedIn}">
                <a href="${pageContext.request.contextPath}/wishlist"
                   class="nav-btn position-relative">
                    <i class="fa-solid fa-heart"></i>
                    Wishlist

                    <c:if test="${sessionScope.wishlistCount > 0}">
                        <span class="cart-badge">
                            ${sessionScope.wishlistCount}
                        </span>
                    </c:if>
                </a>
            </c:if>

            <a href="${pageContext.request.contextPath}/cart"
               class="nav-btn position-relative">

                <i class="fa-solid fa-cart-shopping"></i>
                Cart

                <c:if test="${loggedIn and sessionScope.cartCount > 0}">
                    <span class="cart-badge">
                        ${sessionScope.cartCount}
                    </span>
                </c:if>

            </a>

            <c:choose>

                <c:when test="${loggedIn}">

                    <div class="dropdown">

                        <button
                            class="btn btn-outline-dark dropdown-toggle user-menu"
                            type="button"
                            data-bs-toggle="dropdown"
                            aria-expanded="false">

                            <i class="fa-solid fa-user-circle me-2"></i>

                            <c:out value="${not empty sessionScope.customerFullName
                                            ? sessionScope.customerFullName
                                            : sessionScope.authUsername}"/>

                        </button>

                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">

                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/customer/profile">

                                    <i class="fa-solid fa-id-card me-2"></i>
                                    Profile

                                </a>
                            </li>

                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/customer/orders">

                                    <i class="fa-solid fa-box me-2"></i>
                                    My Orders

                                </a>
                            </li>

                            <li>
                                <hr class="dropdown-divider">
                            </li>

                            <li>

                                <a class="dropdown-item text-danger js-customer-logout"
                                   href="${pageContext.request.contextPath}/customer/logout"
                                   data-logout-url="${pageContext.request.contextPath}/customer/logout">

                                    <i class="fa-solid fa-right-from-bracket me-2"></i>
                                    Logout

                                </a>

                            </li>

                        </ul>

                    </div>

                </c:when>

                <c:otherwise>

                    <a href="${pageContext.request.contextPath}/customer/login"
                       class="btn btn-login">

                        <i class="fa-solid fa-right-to-bracket"></i>
                        Login

                    </a>

                </c:otherwise>

            </c:choose>

        </div>

    </div>

</nav>

<style>
    :root{
        --navy:#25211e;
        --teal:#c65b3d;
        --bg:#faf7f2;
    }

    .custom-navbar{
        background:rgba(255,253,249,.96);
        backdrop-filter:blur(12px);
        border-bottom:1px solid #e9e0d7;
        box-shadow:0 3px 18px rgba(74,54,39,.06);
        padding:10px 0;
    }

    .brand-logo{
        font-size:21px;
        font-weight:800;
        color:var(--navy);
        text-decoration:none;
    }

    .brand-logo i{
        color:var(--teal);
        margin-right:6px;
    }

    .nav-btn{
        text-decoration:none;
        color:#5f5750;
        padding:9px 12px;
        border-radius:9px;
        transition:.25s;
        font-weight:600;
    }

    .nav-btn:hover{
        background:#f4e9df;
        color:var(--teal);
    }

    .nav-actions{
        row-gap:3px;
    }

    .user-box{
        background:#faf7f2;
        border:1px solid #e9e0d7;
        padding:10px 16px;
        border-radius:14px;
        color:#334155;
        font-weight:600;
    }

    .btn-login{
        background:var(--teal);
        color:white;
        border:none;
        border-radius:12px;
        padding:10px 18px;
        font-weight:600;
    }

    .btn-login:hover{
        color:white;
        background:#a9462d;
        opacity:1;
    }

    .btn-logout{
        background:#a9462d;
        color:white;
        border:none;
        border-radius:12px;
        padding:10px 18px;
        font-weight:600;
    }

    .btn-logout:hover{
        background:#873724;
        color:white;
    }

    .cart-badge{
        position:absolute;
        top:-6px;
        right:-6px;
        min-width:20px;
        height:20px;
        border-radius:50%;
        background:#ef4444;
        color:white;
        font-size:12px;
        display:flex;
        align-items:center;
        justify-content:center;
    }

    .user-menu{
        border-radius:30px;
        padding:10px 18px;
        font-weight:600;
        border:1px solid #e5e7eb;
    }

    .user-menu:hover{
        background:#faf7f2;
    }

    .dropdown-menu{
        min-width:220px;
        border-radius:15px;
        padding:10px;
    }

    .dropdown-item{
        border-radius:10px;
        padding:10px 14px;
        font-weight:500;
    }

    .dropdown-item:hover{
        background:#f4e9df;
    }

    .dropdown-item.text-danger:hover{
        background:#fbecea;
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

    @media (max-width: 576px) {
        .custom-navbar .container {
            align-items: flex-start;
        }

        .brand-logo {
            font-size: 19px;
        }

        .nav-actions {
            justify-content: flex-end;
            max-width: 100%;
        }

        .nav-btn {
            padding: 7px 8px;
            font-size: .8rem;
        }

        .user-menu {
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            padding: 8px 10px;
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
        var userMenuButton = document.querySelector('.user-menu');
        var userDropdown = userMenuButton ? userMenuButton.closest('.dropdown') : null;
        var userDropdownMenu = userDropdown ? userDropdown.querySelector('.dropdown-menu') : null;

        if (userMenuButton && userDropdownMenu) {
            userMenuButton.addEventListener('click', function (event) {
                if (window.bootstrap && window.bootstrap.Dropdown) {
                    return;
                }

                event.preventDefault();
                event.stopPropagation();

                var shouldOpen = !userDropdownMenu.classList.contains('show');
                userDropdownMenu.classList.toggle('show', shouldOpen);
                userMenuButton.setAttribute('aria-expanded', shouldOpen ? 'true' : 'false');
            });

            document.addEventListener('click', function (event) {
                if (window.bootstrap && window.bootstrap.Dropdown) {
                    return;
                }

                if (!userDropdown.contains(event.target)) {
                    userDropdownMenu.classList.remove('show');
                    userMenuButton.setAttribute('aria-expanded', 'false');
                }
            });

            document.addEventListener('keydown', function (event) {
                if (window.bootstrap && window.bootstrap.Dropdown) {
                    return;
                }

                if (event.key === 'Escape') {
                    userDropdownMenu.classList.remove('show');
                    userMenuButton.setAttribute('aria-expanded', 'false');
                }
            });
        }

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
