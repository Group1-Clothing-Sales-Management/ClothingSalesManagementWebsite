<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>
    <head>

        <title>Product List</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

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

            /* PAGE HEADER */

            .page-header{
                background:white;
                border:none;
                border-radius:24px;
                padding:35px;
                margin-bottom:30px;
                box-shadow:0 15px 40px rgba(0,0,0,.08);
            }

            .page-header h2{
                font-weight:800;
                color:var(--navy);
            }

            .page-header p{
                color:var(--muted);
            }

            /* SEARCH */

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

            /* BUTTON */

            .btn-danger{
                background:linear-gradient(
                    135deg,
                    var(--navy),
                    var(--teal)
                    ) !important;

                border:none !important;
            }

            .btn-danger:hover{
                background:linear-gradient(
                    135deg,
                    var(--navy-light),
                    var(--teal-light)
                    ) !important;
            }

            /* PRODUCT */

            .product-card{
                border:1px solid #eef2f7;
                border-radius:18px;
                overflow:hidden;
                background:white;
                transition:.25s;
                position:relative;
            }

            .product-card:hover{
                transform:translateY(-8px);
                box-shadow:0 20px 45px rgba(23,32,51,.15);
            }

            .product-image{
                height:300px;
                object-fit:cover;
            }

            .card-body h6{
                color:var(--navy);
                font-weight:700;
            }

            .price{
                color:var(--teal);
                font-size:24px;
                font-weight:800;
            }

            .card-footer{
                background:white;
                border:none;
            }

            .card-footer .btn{
                border-radius:12px;
            }

            .wishlist-heart-form{
                position:absolute;
                top:12px;
                right:12px;
                z-index:5;
                margin:0;
            }

            .wishlist-heart{
                width:42px;
                height:42px;
                border:0;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                background:rgba(255,255,255,.94);
                color:#dc2626;
                box-shadow:0 8px 24px rgba(15,23,42,.18);
                transition:.2s;
            }

            .wishlist-heart:hover,
            .wishlist-heart.is-active{
                background:#dc2626;
                color:#fff;
                transform:scale(1.05);
            }

            .wishlist-toast{
                position:fixed;
                top:92px;
                right:24px;
                z-index:1080;
                min-width:280px;
                max-width:360px;
                padding:14px 18px;
                border-radius:14px;
                background:#172033;
                color:#fff;
                box-shadow:0 18px 45px rgba(15,23,42,.24);
                opacity:0;
                transform:translateY(-12px);
                pointer-events:none;
                transition:.25s;
                font-weight:700;
            }

            .wishlist-toast.show{
                opacity:1;
                transform:translateY(0);
            }

            .wishlist-toast.is-error{
                background:#dc2626;
            }

            @media(max-width:768px){

                .page-header{
                    padding:25px;
                }

                .product-image{
                    height:240px;
                }

            }
        </style>

    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container mt-4">

            <div class="page-header">

                <h2>
                    <i class="fa-solid fa-shirt"></i>
                    Product List
                </h2>

                <p class="text-muted mb-0">
                    Browse all available products
                </p>

            </div>

            <!-- SEARCH -->

            <form action="${pageContext.request.contextPath}/products"
                  method="get"
                  class="card search-card p-4 mb-5">

                <div class="row">

                    <div class="col-md-4">

                        <input type="text"
                               name="keyword"
                               value="${param.keyword}"
                               class="form-control"
                               placeholder="Search product">

                    </div>

                    <div class="col-md-2">

                        <input type="number"
                               name="minPrice"
                               value="${param.minPrice}"
                               class="form-control"
                               placeholder="Min Price">

                    </div>

                    <div class="col-md-2">

                        <input type="number"
                               name="maxPrice"
                               value="${param.maxPrice}"
                               class="form-control"
                               placeholder="Max Price">

                    </div>

                    <div class="col-md-2">

                        <select name="sort"
                                class="form-select">

                            <option value="">
                                Sort
                            </option>

                            <option value="priceAsc">
                                Price ↑
                            </option>

                            <option value="priceDesc">
                                Price ↓
                            </option>

                        </select>

                    </div>

                    <div class="col-md-2">

                        <button class="btn btn-danger w-100">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            Search
                        </button>
                    </div>

                </div>

            </form>

            <div class="row g-4">

                <c:forEach items="${products}" var="p">

                    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">

                        <c:set var="isWishlisted"
                               value="${wishlistProductIds.contains(p.id)}"/>

                        <div class="card product-card h-100">

                            <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                  method="post"
                                  class="wishlist-heart-form">
                                <input type="hidden" name="productId" value="${p.id}">
                                <input type="hidden" name="variantId"
                                       value="${not empty p.variants ? p.variants[0].id : ''}">
                                <input type="hidden" name="wishlisted" value="${isWishlisted}">
                                <button type="submit"
                                        class="wishlist-heart ${isWishlisted ? 'is-active' : ''}"
                                        title="${isWishlisted ? 'Remove from wishlist' : 'Add to wishlist'}">
                                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                </button>
                            </form>

                            <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">

                                <img
                                    src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}"
                                    class="card-img-top product-image"
                                    alt="${p.productName}">

                            </a>

                            <div class="card-body">

                                <h6 class="fw-bold text-truncate mb-2">
                                    ${p.productName}
                                </h6>

                                <c:if test="${not empty p.variants}">

                                    <div class="price mb-2">
                                        ${p.variants[0].salePrice} đ
                                    </div>

                                    <div class="small text-muted mb-2">
                                        <b>Color / Size:</b>
                                        ${p.variants[0].attributeDetails}
                                    </div>

                                </c:if>

                            </div>

                            <div class="card-footer bg-white">

                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                   class="btn btn-danger w-100 mb-2">

                                    View Details

                                </a>

                                <c:if test="${not empty p.variants}">

                                    <form action="${pageContext.request.contextPath}/cart"
                                          method="post"
                                          class="add-cart-form"
                                          style="margin:0">

                                        <select name="variantId"
                                                class="form-select form-select-sm mb-2 variant-select">

                                            <c:forEach items="${p.variants}" var="v">

                                                <option value="${v.id}"
                                                        data-price="${v.salePrice}"
                                                        data-attributes="${v.attributeDetails}">

                                                    ${v.attributeDetails} - ${v.salePrice} đ

                                                </option>

                                            </c:forEach>

                                        </select>

                                        <input type="hidden" name="productId" value="${p.id}">
                                        <input type="hidden" name="productName" value="${p.productName}">
                                        <input type="hidden" name="attributes"
                                               class="attributes-input"
                                               value="${p.variants[0].attributeDetails}">
                                        <input type="hidden" name="price"
                                               class="price-input"
                                               value="${p.variants[0].salePrice}">
                                        <input type="hidden" name="quantity" value="1">
                                        <input type="hidden"
                                               name="imageUrl"
                                               value="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}">

                                        <button type="submit"
                                                class="btn btn-danger w-100">

                                            <i class="fa-solid fa-cart-plus"></i>
                                            Add To Cart

                                        </button>

                                    </form>

                                </c:if>

                            </div>

                        </div>

                    </div>

                </c:forEach>

            </div>

        </div>

        <div class="wishlist-toast" id="wishlistToast">
            <i class="fa-solid fa-heart me-2"></i>
            <span id="wishlistToastText"></span>
        </div>

        <script>
            var wishlistParams = new URLSearchParams(window.location.search);

            if (wishlistParams.has('wishlistAdded')
                    || wishlistParams.has('wishlistRemoved')
                    || wishlistParams.has('wishlistError')) {
                var wishlistToast = document.getElementById('wishlistToast');
                var wishlistToastText = document.getElementById('wishlistToastText');
                var wishlistMessage = 'Đã thêm vào mục yêu thích.';

                if (wishlistParams.has('wishlistRemoved')) {
                    wishlistMessage = 'Đã bỏ khỏi mục yêu thích.';
                }

                if (wishlistParams.has('wishlistError')) {
                    wishlistMessage = 'Không thể cập nhật mục yêu thích.';
                    wishlistToast.classList.add('is-error');
                }

                wishlistToastText.textContent = wishlistMessage;
                wishlistToast.classList.add('show');
                setTimeout(function () {
                    wishlistToast.classList.remove('show');
                }, 2600);
            }
        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>

    </body>
</html>
