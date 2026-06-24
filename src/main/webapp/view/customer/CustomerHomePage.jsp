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
                border:1px solid #f0f0f0;
                border-radius:4px;
                overflow:hidden;
                background:white;
                transition:.2s;
            }

            .product-card:hover{
                transform:translateY(-2px);
                border-color:#ee4d2d;
                box-shadow:0 3px 10px rgba(0,0,0,.1);
            }

            .product-image{
                height:260px;
                object-fit:cover;
            }

            .text-danger{
                color:#ee4d2d !important;
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
        <jsp:include page="/view/customer/common/header.jsp"/>
        <c:set var="loggedIn"
               value="${not empty sessionScope.authUserId}"/>

        <!-- HERO -->

        <section class="hero">

            <div class="container">

                <div class="row align-items-center">

                    <div class="col-lg-6">

                        <h1 class="hero-title">Discover New Fashion Trends</h1>

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
                            <option value=""> Sort By </option>
                            <option value="priceAsc"> Price ↑ </option>
                            <option value="priceDesc"> Price ↓ </option>
                            <option value="newest"> Newest </option>
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
                                        src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}"
                                        class="card-img-top product-image"
                                        alt="${p.productName}">

                                </a>    
                                <!-- BODY -->

                                <div class="card-body">

                                    <h6 class="fw-bold text-truncate mb-2">
                                        ${p.productName}
                                    </h6>
                                    <c:choose>
                                        <c:when test="${not empty p.variants}">
                                            <div class="text-danger fw-bold fs-5 mb-2">
                                                ${p.variants[0].salePrice} đ
                                            </div>
                                            <div class="small text-muted mb-2">
                                                <b>Color / Size:</b>
                                                ${p.variants[0].attributeDetails}
                                            </div>
                                            <div class="small mb-2">
                                                <b>Stock:</b>
                                                ${p.variants[0].stockQuantity}
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-secondary">
                                                Contact
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <!-- FOOTER -->
                                <div class="card-footer bg-white">


                                    <a 
                                        href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                        class="btn btn-danger w-100">

                                        View Details

                                    </a>
                                    <c:if test="${not empty p.variants}">
                                        <c:choose>
                                            <c:when test="${loggedIn}">
                                                <form action="${pageContext.request.contextPath}/cart" method="post" class="add-cart-form" style="margin:0">
                                                    <select name="variantId" class="form-select form-select-sm mb-2 variant-select">
                                                        <c:forEach items="${p.variants}" var="v">
                                                            <option value="${v.id}"
                                                                    data-price="${v.salePrice}"
                                                                    data-attributes="${v.attributeDetails}">
                                                                ${v.attributeDetails} - ${v.salePrice} $
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                    <input type="hidden" name="productId" value="${p.id}" />
                                                    <input type="hidden" name="productName" value="${p.productName}" />
                                                    <input type="hidden" name="attributes" class="attributes-input" value="${p.variants[0].attributeDetails}" />
                                                    <input type="hidden" name="price" class="price-input" value="${p.variants[0].salePrice}" />
                                                    <input type="hidden" name="quantity" value="1" />
                                                    <input type="hidden"name="imageUrl"value="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}" />
                                                    <button type="submit" class="btn btn-danger w-100">
                                                        <i class="fa-solid fa-cart-plus"></i>
                                                        Add To Cart
                                                    </button>
                                                </form>

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

        <div class="modal fade" id="cartMessageModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Giỏ hàng</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body" id="cartMessageText">
                        Đã thêm sản phẩm vào giỏ hàng.
                    </div>
                    <div class="modal-footer">
                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-dark">Xem giỏ hàng</a>
                        <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Tiếp tục mua sắm</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.querySelectorAll('.variant-select').forEach(function (select) {
                function syncVariant() {
                    var form = select.closest('.add-cart-form');
                    var option = select.options[select.selectedIndex];
                    form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                    form.querySelector('.price-input').value = option.dataset.price || '0';
                }
                select.addEventListener('change', syncVariant);
                syncVariant();
            });

            var params = new URLSearchParams(window.location.search);
            if (params.has('cartAdded') || params.has('cartError')) {
                var message = params.has('cartAdded')
                        ? 'Đã thêm sản phẩm vào giỏ hàng.'
                        : 'Không thể thêm sản phẩm vào giỏ hàng. Vui lòng kiểm tra tồn kho.';
                document.getElementById('cartMessageText').textContent = message;
                new bootstrap.Modal(document.getElementById('cartMessageModal')).show();
            }
        </script>
        <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>

</html>
