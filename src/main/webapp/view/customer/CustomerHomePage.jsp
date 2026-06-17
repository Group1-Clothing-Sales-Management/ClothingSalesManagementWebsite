<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>

    <head>

        <title>Clothing Sale</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <style>

            :root{
                --navy:#172033;
                --navy-light:#22304d;
                --teal:#0f9b8e;
                --teal-light:#19b8aa;
                --bg:#f4f8fb;
                --card:#ffffff;
                --text:#1f2937;
                --muted:#6b7280;
            }

            body{
                background:
                    radial-gradient(circle at top left,
                    rgba(15,155,142,.08),
                    transparent 30%),
                    radial-gradient(circle at right top,
                    rgba(23,32,51,.08),
                    transparent 25%),
                    var(--bg);

                font-family:'Segoe UI',sans-serif;
                color:var(--text);
            }

            /* NAVBAR */

            .navbar{
                background:rgba(255,255,255,.85)!important;
                backdrop-filter:blur(12px);
                box-shadow:0 5px 20px rgba(0,0,0,.05)!important;
            }

            .navbar-brand{
                color:var(--navy)!important;
                font-size:24px;
            }

            .navbar-brand i{
                color:var(--teal);
            }

            /* BUTTON */

            .btn-danger{
                background:linear-gradient(
                    135deg,
                    var(--navy),
                    var(--teal)
                    ) !important;

                border:none!important;
            }

            .btn-danger:hover{
                background:linear-gradient(
                    135deg,
                    var(--navy-light),
                    var(--teal-light)
                    ) !important;
            }

            .btn-outline-dark{
                border:2px solid var(--navy);
                color:var(--navy);
            }

            .btn-outline-dark:hover{
                background:var(--navy);
                color:white;
            }

            /* HERO */

            .hero{
                padding:90px 0;
            }

            .hero-title{
                font-size:58px;
                font-weight:800;
                color:var(--navy);
                line-height:1.1;
            }

            .hero-text{
                color:var(--muted);
                font-size:18px;
            }

            .hero-image{
                width:100%;
                border-radius:25px;
                box-shadow:0 20px 50px rgba(23,32,51,.15);
            }

            /* SEARCH CARD */

            .search-card{
                border:none;
                border-radius:24px;
                background:white;
                box-shadow:0 15px 40px rgba(0,0,0,.08);
            }

            .form-control,
            .form-select{
                border-radius:12px;
                padding:12px;
            }

            .form-control:focus,
            .form-select:focus{
                border-color:var(--teal);
                box-shadow:0 0 0 .25rem rgba(15,155,142,.15);
            }

            /* SECTION */

            .section-title{
                font-size:34px;
                font-weight:800;
                color:var(--navy);
            }

            .section-subtitle{
                color:var(--muted);
            }

            /* PRODUCT CARD */

            .product-card{
                border:none;
                border-radius:24px;
                overflow:hidden;
                background:white;
                transition:.3s;
                box-shadow:0 8px 25px rgba(0,0,0,.05);
            }

            .product-card:hover{
                transform:translateY(-8px);
                box-shadow:0 20px 45px rgba(23,32,51,.15);
            }

            .product-image{
                height:300px;
                object-fit:cover;
            }

            .card-body h5{
                color:var(--navy);
            }

            .text-danger{
                color:var(--teal)!important;
            }

            .badge.bg-primary{
                background:rgba(15,155,142,.15)!important;
                color:var(--teal)!important;
            }

            /* PRODUCT FOOTER */

            .card-footer{
                background:white!important;
            }

            .card-footer .btn-danger{
                border-radius:12px;
            }

            /* EMPTY PRODUCT */

            .fa-box-open{
                color:var(--teal)!important;
            }

            /* FOOTER */

            footer{
                background:linear-gradient(
                    135deg,
                    var(--navy),
                    #1f2c45
                    )!important;
            }

            footer h4,
            footer h5{
                color:white;
            }

            footer p,
            footer li{
                color:#d1d5db;
            }

            hr{
                border-color:rgba(255,255,255,.2);
            }

            /* RESPONSIVE */

            @media(max-width:768px){

                .hero-title{
                    font-size:42px;
                }

                .hero{
                    text-align:center;
                }

                .hero-image{
                    margin-top:30px;
                }
            }

        </style>

    </head>

    <body>
        <c:set var="loggedIn"
               value="${not empty sessionScope.authUserId}"/>
        <!-- NAVBAR -->

        <nav class="navbar navbar-expand-lg bg-white shadow-sm sticky-top">

            <div class="container">

                <a class="navbar-brand fw-bold">

                    <i class="fa-solid fa-shirt"></i>
                    Clothing Sale

                </a>

                <div class="d-flex gap-2">

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

                    <a href="${pageContext.request.contextPath}/customer/login"
                       class="btn btn-danger">
                        Login
                    </a>

                </div>

            </div>

        </nav>

        <!-- HERO -->

        <section class="hero">

            <div class="container">

                <div class="row align-items-center">

                    <div class="col-lg-6">

                        <h1 class="hero-title">

                            Discover New Fashion Trends

                        </h1>

                        <p class="hero-text mt-3">

                            Explore premium clothing, hoodies, sneakers,
                            jeans and accessories at affordable prices.

                        </p>

                        <a href="#products"
                           class="btn btn-danger btn-lg mt-3">

                            Shop Now

                        </a>

                    </div>

                    <div class="col-lg-6">

                        <img
                            src="https://images.unsplash.com/photo-1441986300917-64674bd600d8"
                            class="hero-image">

                    </div>

                </div>

            </div>

        </section>

        <!-- MAIN -->

        <div class="container">

            <!-- SEARCH + FILTER -->

            <form action="${pageContext.request.contextPath}/home"
                  method="GET"
                  class="card search-card p-4 mb-5">

                <div class="row g-3">               
                    <div class="col-md-2">

                        <input
                            type="number"
                            name="minPrice"
                            value="${param.minPrice}"
                            class="form-control"
                            placeholder="Min Price">

                    </div>

                    <div class="col-md-2">

                        <input
                            type="number"
                            name="maxPrice"
                            value="${param.maxPrice}"
                            class="form-control"
                            placeholder="Max Price">

                    </div>

                    <div class="col-md-2">

                        <select
                            name="sort"
                            class="form-select">

                            <option value="">
                                Sort By
                            </option>

                            <option value="priceAsc">
                                Price ↑
                            </option>

                            <option value="priceDesc">
                                Price ↓
                            </option>

                            <option value="newest">
                                Newest
                            </option>

                        </select>

                    </div>
                    <div class="col-md-4">

                        <input
                            type="text"
                            name="keyword"
                            value="${param.keyword}"
                            class="form-control"
                            placeholder="Search products...">

                    </div>

                    <div class="col-md-2">

                        <button
                            class="btn btn-danger w-100">

                            Search

                        </button>

                    </div>

                </div>

            </form>

            <!-- PRODUCT SECTION TITLE -->

            <div class="mb-4">

                <h2 class="section-title">

                    Featured Products

                </h2>

                <p class="section-subtitle">

                    Best selling products this season

                </p>

            </div>
            <!-- PRODUCT LIST -->

            <c:if test="${not empty products}">

                <div id="products"
                     class="row g-4">

                    <c:forEach items="${products}"
                               var="p">

                        <div class="col-lg-3 col-md-4 col-sm-6">

                            <div class="card product-card h-100">

                                <!-- IMAGE -->

                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">

                                    <img
                                        src="${pageContext.request.contextPath}/uploads/${p.mainImageUrl}"
                                        class="card-img-top product-image">

                                </a>
                                <!-- BODY -->

                                <div class="card-body">

                                    <span class="badge bg-primary mb-2">
                                        Trending
                                    </span>

                                    <h5 class="fw-bold">

                                        <a 
                                            href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                            class="text-decoration-none">

                                            ${p.productName}

                                        </a>

                                    </h5>

                                    <p class="text-secondary small">

                                        Premium fashion product

                                    </p>

                                    <c:choose>

                                        <c:when test="${not empty p.variants}">

                                            <h4 class="text-danger fw-bold">

                                                ${p.variants[0].salePrice} $

                                            </h4>

                                        </c:when>

                                        <c:otherwise>

                                            <h4 class="text-secondary">

                                                Contact

                                            </h4>

                                        </c:otherwise>

                                    </c:choose>

                                </div>

                                <!-- FOOTER -->

                                <div class="card-footer bg-white border-0">


                                    <a 
                                        href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                        class="btn btn-danger w-100">

                                        View Details

                                    </a>
                                    <c:if test="${not empty p.variants}">

                                        <c:choose>

                                            <c:when test="${loggedIn}">

                                                <a 
                                                    href="${pageContext.request.contextPath}/cart?action=add&variantId=${p.variants[0].id}"
                                                    class="btn btn-danger w-100">

                                                    <i class="fa-solid fa-cart-plus"></i>
                                                    Add To Cart

                                                </a>

                                            </c:when>


                                            <c:otherwise>

                                                <a 
                                                    href="${pageContext.request.contextPath}/customer/login"
                                                    class="btn btn-danger w-100">

                                                    <i class="fa-solid fa-cart-plus"></i>
                                                    Add To Cart

                                                </a>

                                            </c:otherwise>


                                        </c:choose>

                                    </c:if>

                                </div>

                            </div>

                        </div>

                    </c:forEach>

                </div>

            </c:if>


            <!-- EMPTY PRODUCT -->

            <c:if test="${empty products}">

                <div class="text-center py-5">

                    <i class="fa-solid fa-box-open fa-4x text-secondary"></i>

                    <h3 class="mt-4">

                        No Products Found

                    </h3>

                    <p class="text-secondary">

                        Please try another keyword.

                    </p>

                </div>

            </c:if>

        </div>

        <!-- FOOTER -->

        <footer class="bg-dark text-white mt-5">

            <div class="container py-5">

                <div class="row">

                    <div class="col-md-4">

                        <h4>

                            Clothing Sale

                        </h4>

                        <p class="text-light">

                            Modern fashion for everyone.

                        </p>

                    </div>

                    <div class="col-md-4">

                        <h5>

                            Categories

                        </h5>

                        <ul class="list-unstyled">

                            <li>T-Shirts</li>
                            <li>Hoodies</li>
                            <li>Jeans</li>
                            <li>Sneakers</li>

                        </ul>

                    </div>

                    <div class="col-md-4">

                        <h5>

                            Contact

                        </h5>

                        <p>

                            Email: supportclothingsale@gmail.com
                        </p>

                        <p>

                            Phone: +84 123 456 789
                        </p>

                    </div>

                </div>

                <hr>

                <div class="text-center">

                    © 2026 Clothing Sale. All Rights Reserved.

                </div>

            </div>

        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    </body>

</html>