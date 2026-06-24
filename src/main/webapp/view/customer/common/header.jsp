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
                       class="btn btn-danger"
                       onclick="return confirm('Are you sure you want to logout?');">

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