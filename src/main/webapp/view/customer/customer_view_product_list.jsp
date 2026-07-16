<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<fmt:setLocale value="vi_VN"/>

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

            /* Compact marketplace-style catalog */
            :root{
                --catalog-ink:#25211e;
                --catalog-muted:#6f665e;
                --catalog-primary:#c65b3d;
                --catalog-border:#e9e0d7;
                --catalog-bg:#faf7f2;
            }

            body{
                background:var(--catalog-bg);
                color:var(--catalog-ink);
            }

            .product-list-page{
                max-width:1180px;
            }

            .page-header{
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:18px;
                padding:22px 24px;
                margin-bottom:16px;
                border:1px solid var(--catalog-border);
                border-radius:8px;
                background:#fff;
                box-shadow:0 4px 14px rgba(74,54,39,.06);
            }

            .page-header h2{
                margin:0;
                font-size:1.45rem;
                color:var(--catalog-ink);
            }

            .page-header p{
                margin-top:4px;
                color:var(--catalog-muted)!important;
                font-size:.86rem;
            }

            .search-card{
                padding:14px!important;
                border:1px solid var(--catalog-border);
                border-radius:8px;
                background:#fff;
                box-shadow:0 4px 14px rgba(74,54,39,.06);
            }

            .search-card .row{
                row-gap:10px;
            }

            .form-control,
            .form-select{
                min-height:40px;
                border:1px solid var(--catalog-border);
                border-radius:6px;
                padding:8px 10px;
            }

            .form-control:focus,
            .form-select:focus{
                border-color:var(--catalog-primary);
                box-shadow:0 0 0 .18rem rgba(198,91,61,.14);
            }

            .btn-danger{
                background:var(--catalog-primary)!important;
                border-color:var(--catalog-primary)!important;
            }

            .btn-danger:hover{
                background:#a9462d!important;
                border-color:#a9462d!important;
            }

            .product-grid{
                display:grid;
                grid-template-columns:repeat(6,minmax(0,1fr));
                gap:12px;
            }

            .product-item{
                min-width:0;
            }

            .product-card{
                border:1px solid var(--catalog-border);
                border-radius:5px;
                background:#fff;
                box-shadow:0 1px 3px rgba(74,54,39,.1);
                transition:transform .2s ease, box-shadow .2s ease;
            }

            .product-card:hover{
                transform:translateY(-2px);
                box-shadow:0 5px 14px rgba(74,54,39,.15);
            }

            .product-image-link{
                display:block;
                position:relative;
                aspect-ratio:1 / 1;
                overflow:hidden;
                background:#f1ebe5;
            }

            .product-image{
                width:100%;
                height:100%;
                display:block;
                object-fit:cover;
                transition:transform .25s ease;
            }

            .product-card:hover .product-image{
                transform:scale(1.03);
            }

            .product-ribbon,
            .product-stock-badge{
                position:absolute;
                z-index:2;
                top:0;
                padding:4px 6px;
                font-size:.66rem;
                line-height:1;
                font-weight:800;
            }

            .product-ribbon{
                left:0;
                color:#fff;
                background:var(--catalog-primary);
            }

            .product-stock-badge{
                right:0;
                color:#8b4a27;
                background:#fff3dc;
            }

            .product-card .card-body{
                padding:8px 9px 7px;
            }

            .product-card h6{
                min-height:36px;
                margin-bottom:4px!important;
                font-size:.82rem;
                line-height:1.35;
                display:-webkit-box;
                -webkit-box-orient:vertical;
                -webkit-line-clamp:2;
                overflow:hidden;
                white-space:normal;
            }

            .product-title-link{
                color:var(--catalog-ink);
                text-decoration:none;
            }

            .product-title-link:hover{
                color:var(--catalog-primary);
            }

            .price{
                margin:0;
                color:var(--catalog-primary);
                font-size:1rem;
                line-height:1.2;
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
            }

            .product-meta{
                display:flex;
                justify-content:space-between;
                gap:8px;
                margin-top:6px;
                color:#81766d;
                font-size:.68rem;
            }

            .product-meta span:first-child{
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
            }

            .product-meta span:last-child{
                flex:0 0 auto;
            }

            .product-list-page .wishlist-heart-form{
                position:static;
                display:block;
                margin:6px 0 2px;
            }

            .product-list-page .wishlist-heart{
                width:30px;
                height:30px;
                border:1px solid #efd4c8;
                background:#fff;
                color:var(--catalog-primary);
                box-shadow:none;
                font-size:.82rem;
            }

            .product-list-page .wishlist-heart:hover,
            .product-list-page .wishlist-heart.is-active{
                background:var(--catalog-primary);
                color:#fff;
            }

            .product-list-page .card-footer{
                display:none;
            }

            @media(max-width:1199px){
                .product-grid{grid-template-columns:repeat(5,minmax(0,1fr));}
            }

            @media(max-width:991px){
                .product-grid{grid-template-columns:repeat(4,minmax(0,1fr));}
            }

            @media(max-width:767px){
                .product-grid{grid-template-columns:repeat(3,minmax(0,1fr));gap:9px;}
                .page-header{align-items:flex-start;flex-direction:column;}
            }

            @media(max-width:575px){
                .product-grid{grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;}
            }

            /* Home-aligned product list refresh */
            :root{
                --catalog-ink:#1f2937;
                --catalog-muted:#61708a;
                --catalog-primary:#8AAAE5;
                --catalog-primary-dark:#5f84d6;
                --catalog-border:#d7e1f5;
                --catalog-bg:#eef4ff;
            }

            body{
                background:
                    linear-gradient(135deg, rgba(138,170,229,.14) 0 24%, transparent 24% 100%),
                    linear-gradient(180deg, #ffffff 0%, #eef4ff 100%);
                color:var(--catalog-ink);
            }

            .product-list-page{
                max-width:1220px;
                margin-top:30px!important;
            }

            .page-header{
                min-height:92px;
                border:1px solid rgba(138,170,229,.38);
                border-radius:8px;
                background:rgba(255,255,255,.96);
                box-shadow:0 18px 42px rgba(95,132,214,.14);
            }

            .page-header h2{
                color:var(--catalog-ink);
                font-size:1.55rem;
                letter-spacing:0;
            }

            .page-header h2 i{
                color:var(--catalog-primary-dark);
                margin-right:8px;
            }

            .page-header p{
                color:var(--catalog-muted)!important;
                font-weight:500;
            }

            .search-card{
                border:1px solid rgba(138,170,229,.42);
                background:#fff;
                box-shadow:0 18px 42px rgba(95,132,214,.14);
            }

            .form-control,
            .form-select{
                border-color:var(--catalog-border);
                border-radius:8px;
                background:#fff;
                color:var(--catalog-ink);
            }

            .form-control:focus,
            .form-select:focus{
                border-color:rgba(138,170,229,.86);
                box-shadow:0 0 0 .22rem rgba(138,170,229,.20);
            }

            .btn-danger{
                background:var(--catalog-primary)!important;
                border-color:var(--catalog-primary)!important;
                color:#fff!important;
                box-shadow:0 12px 26px rgba(95,132,214,.22);
            }

            .btn-danger:hover,
            .btn-danger:focus-visible{
                background:var(--catalog-primary-dark)!important;
                border-color:var(--catalog-primary-dark)!important;
            }

            .product-grid{
                gap:16px;
            }

            .product-card{
                border:1px solid rgba(138,170,229,.30);
                border-radius:8px;
                background:#fff;
                box-shadow:0 8px 26px rgba(31,41,55,.08);
            }

            .product-card:hover{
                transform:translateY(-4px);
                border-color:rgba(138,170,229,.78);
                box-shadow:0 20px 38px rgba(95,132,214,.20);
            }

            .product-image-link{
                background:#eef4ff;
            }

            .product-ribbon,
            .product-stock-badge{
                top:8px;
                border-radius:0 8px 8px 0;
                padding:6px 8px;
                font-size:.68rem;
            }

            .product-ribbon{
                background:var(--catalog-primary);
                color:#fff;
            }

            .product-stock-badge{
                right:8px;
                border-radius:8px;
                background:#fff;
                color:#365b9f;
                box-shadow:0 8px 18px rgba(31,41,55,.10);
            }

            .product-card .card-body{
                padding:11px 12px 8px;
            }

            .product-card h6{
                min-height:40px;
                font-size:.86rem;
            }

            .product-title-link{
                color:var(--catalog-ink);
            }

            .product-title-link:hover{
                color:var(--catalog-primary-dark);
            }

            .price{
                color:#365b9f;
                font-size:1.05rem;
                letter-spacing:.01em;
            }

            .product-list-page .wishlist-heart-form{
                margin:8px 0 2px;
            }

            .product-list-page .wishlist-heart{
                width:34px;
                height:34px;
                border:1px solid #d7e1f5;
                color:var(--catalog-primary-dark);
                background:#fff;
                box-shadow:0 8px 18px rgba(95,132,214,.14);
            }

            .product-list-page .wishlist-heart:hover,
            .product-list-page .wishlist-heart.is-active{
                background:var(--catalog-primary);
                border-color:var(--catalog-primary);
                color:#fff;
            }

            .product-meta{
                color:var(--catalog-muted);
                font-weight:500;
            }

            .wishlist-toast{
                background:#1f2937;
                box-shadow:0 18px 40px rgba(31,41,55,.22);
            }

            .wishlist-toast.is-error{
                background:#9f3a38;
            }
        </style>

    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container product-list-page mt-4">

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

            <c:if test="${not empty param.keyword or not empty param.categoryId}">
            <form action="${pageContext.request.contextPath}/products"
                  method="get"
                  class="card search-card p-4 mb-5">
                <c:if test="${not empty param.categoryId}">
                    <input type="hidden" name="categoryId" value="${param.categoryId}">
                </c:if>

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
            </c:if>

            <div class="product-grid">

                <c:forEach items="${products}" var="p">

                    <div class="product-item">

                        <c:set var="isWishlisted"
                               value="${wishlistProductIds.contains(p.id)}"/>

                        <div class="card product-card h-100">

                            <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="product-image-link">
                                <span class="product-ribbon">Featured</span>
                                <c:if test="${not empty p.variants}">
                                    <span class="product-stock-badge">In stock</span>
                                </c:if>

                                <img
                                    src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}"
                                    class="card-img-top product-image"
                                    alt="${p.productName}"
                                    loading="lazy"
                                    decoding="async">

                            </a>

                            <div class="card-body">

                                <h6 class="fw-bold mb-2">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="product-title-link">
                                        ${p.productName}
                                    </a>
                                </h6>

                                <c:if test="${not empty p.variants}">

                                    <div class="price mb-2">
                                        <fmt:formatNumber value="${p.variants[0].salePrice}" pattern="#,##0"/> &#8363;
                                    </div>

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

                                    <div class="product-meta">
                                        <span>${p.variants[0].attributeDetails}</span>
                                        <span>${p.variants[0].stockQuantity} in stock</span>
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

                                                    ${v.attributeDetails} - <fmt:formatNumber value="${v.salePrice}" pattern="#,##0"/> &#8363;

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

            <c:if test="${empty products}">
                <div class="text-center py-5 text-muted">
                    <i class="fa-solid fa-box-open fa-3x mb-3"></i>
                    <h4>No products found</h4>
                    <p>Try another keyword or price range.</p>
                </div>
            </c:if>

        </div>

        <div class="wishlist-toast" id="wishlistToast">
            <i class="fa-solid fa-heart me-2"></i>
            <span id="wishlistToastText"></span>
        </div>

        <script>
            var wishlistParams = new URLSearchParams(window.location.search);
            var wishlistToast = document.getElementById('wishlistToast');
            var wishlistToastText = document.getElementById('wishlistToastText');

            function showWishlistToast(message, isError) {
                if (!wishlistToast || !wishlistToastText) {
                    return;
                }

                wishlistToast.classList.toggle('is-error', !!isError);
                wishlistToastText.textContent = message;
                wishlistToast.classList.add('show');
                clearTimeout(wishlistToast.hideTimer);
                wishlistToast.hideTimer = setTimeout(function () {
                    wishlistToast.classList.remove('show');
                }, 2600);
            }

            if (wishlistParams.has('wishlistAdded')
                    || wishlistParams.has('wishlistRemoved')
                    || wishlistParams.has('wishlistError')) {
                var wishlistMessage = 'Added to your wishlist.';
                var wishlistIsError = false;

                if (wishlistParams.has('wishlistRemoved')) {
                    wishlistMessage = 'Removed from your wishlist.';
                }

                if (wishlistParams.has('wishlistError')) {
                    wishlistMessage = 'Unable to update your wishlist.';
                    wishlistIsError = true;
                }

                showWishlistToast(wishlistMessage, wishlistIsError);
            }

            document.querySelectorAll('.wishlist-heart-form').forEach(function (form) {
                form.addEventListener('submit', function () {
                    sessionStorage.setItem('wishlistScrollY', String(window.scrollY || 0));
                });
            });

            var savedWishlistScroll = sessionStorage.getItem('wishlistScrollY');
            if (savedWishlistScroll !== null) {
                sessionStorage.removeItem('wishlistScrollY');
                requestAnimationFrame(function () {
                    window.scrollTo(0, parseInt(savedWishlistScroll, 10) || 0);
                });
            }
        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>

    </body>
</html>
