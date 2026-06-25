<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="loggedIn"
       value="${not empty sessionScope.authUserId}"/>

<nav class="navbar navbar-expand-lg bg-white shadow-sm sticky-top">

    <div class="container">

        <a href="${pageContext.request.contextPath}/home"
           class="navbar-brand fw-bold text-decoration-none">

            <i class="fa-solid fa-shirt"></i>
            Clothing Sale

        </a>

        <div class="d-flex gap-2 align-items-center flex-wrap justify-content-end">

            <c:choose>

                <c:when test="${loggedIn}">

                    <a href="${pageContext.request.contextPath}/cart"
                       class="btn btn-outline-dark position-relative">

                        <i class="fa-solid fa-cart-shopping"></i>
                        Cart

                        <c:if test="${sessionScope.cartCount > 0}">
                            <span class="position-absolute
                                  top-0 start-100
                                  translate-middle
                                  badge rounded-pill bg-danger">

                                ${sessionScope.cartCount}

                            </span>
                        </c:if>

                    </a>

                </c:when>

                <c:otherwise>

                    <a href="${pageContext.request.contextPath}/products"
                       class="btn btn-outline-dark">
                        <i class="fa-solid fa-id-card"></i>
                        Products
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/login"
                       class="btn btn-outline-dark">

                        <i class="fa-solid fa-cart-shopping"></i>
                        Cart

                    </a>

                </c:otherwise>

            </c:choose>

            <c:choose>

                <c:when test="${loggedIn}">

                    <span class="text-secondary small d-none d-md-inline">

                        <i class="fa-solid fa-user"></i>

                        <c:out value="${not empty sessionScope.customerFullName ? sessionScope.customerFullName : sessionScope.authUsername}"/>

                    </span>
                    <a href="${pageContext.request.contextPath}/customer/profile"
                       class="btn btn-outline-dark">

                        <i class="fa-solid fa-id-card"></i>
                        Profile

                    </a>

                    <a href="${pageContext.request.contextPath}/customer/orders"
                       class="btn btn-outline-dark">

                        <i class="fa-solid fa-box"></i>
                        My Orders

                    </a>

                    <a href="${pageContext.request.contextPath}/customer/logout"
                       class="btn btn-danger js-customer-logout"
                       data-logout-url="${pageContext.request.contextPath}/customer/logout">

                        <i class="fa-solid fa-right-from-bracket"></i>
                        Logout

                    </a>

                </c:when>

                <c:otherwise>

                    <a href="${pageContext.request.contextPath}/customer/login"
                       class="btn btn-danger">

                        Login

                    </a>

                </c:otherwise>

            </c:choose>

        </div>

    </div>

</nav>

<style>
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
        background: linear-gradient(135deg, #172033, #0f9b8e);
        box-shadow: 0 14px 30px rgba(15, 155, 142, .24);
        flex: 0 0 auto;
        font-size: 22px;
    }

    .logout-confirm-title {
        margin: 0 0 6px;
        color: #172033;
        font-size: 1.25rem;
        font-weight: 800;
    }

    .logout-confirm-text {
        margin: 0;
        color: #64748b;
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
        background: #dc2626;
        border-color: #dc2626;
    }

    .logout-confirm-actions .btn-danger:hover {
        background: #b91c1c;
        border-color: #b91c1c;
    }

    @media (max-width: 576px) {
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
