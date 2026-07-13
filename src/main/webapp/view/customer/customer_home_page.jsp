<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html>

    <head>

        <title>Clothing Sale</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <style>

            :root{
                --ink:#25211e;
                --ink-soft:#5f5750;
                --primary:#c65b3d;
                --primary-dark:#a9462d;
                --accent:#e9a957;
                --bg:#faf7f2;
                --surface:#ffffff;
                --border:#e9e0d7;
                --shadow:0 12px 30px rgba(74,54,39,.09);
            }

            body{
                background:var(--bg);
                font-family:'Segoe UI',sans-serif;
                color:var(--ink);
            }

            .btn-danger{
                background:var(--primary)!important;
                border-color:var(--primary)!important;
                color:#fff!important;
                font-weight:700;
            }

            .btn-danger:hover,
            .btn-danger:focus-visible{
                background:var(--primary-dark)!important;
                border-color:var(--primary-dark)!important;
            }

            .btn-outline-dark{
                border-color:var(--ink);
                color:var(--ink);
                font-weight:700;
            }

            .btn-outline-dark:hover,
            .btn-outline-dark:focus-visible{
                background:var(--ink);
                color:#fff;
            }

            .hero{
                padding:34px 0 30px;
            }

            .hero-panel{
                position:relative;
                overflow:hidden;
                border-radius:24px;
                padding:38px 42px;
                background:linear-gradient(115deg,#fffdf9 0%,#f5e8dc 100%);
                border:1px solid var(--border);
            }

            .hero-panel:after{
                content:'';
                position:absolute;
                width:230px;
                height:230px;
                right:40%;
                bottom:-150px;
                border-radius:50%;
                background:rgba(230,157,79,.18);
            }

            .hero-content,
            .hero-visual{
                position:relative;
                z-index:1;
            }

            .hero-kicker{
                display:inline-flex;
                align-items:center;
                gap:8px;
                margin-bottom:14px;
                color:var(--primary-dark);
                font-size:.75rem;
                font-weight:800;
                letter-spacing:.12em;
                text-transform:uppercase;
            }

            .hero-kicker:before{
                content:'';
                width:28px;
                height:2px;
                background:var(--accent);
            }

            .hero-title{
                max-width:520px;
                margin:0;
                font-size:clamp(2.4rem,5vw,4.35rem);
                font-weight:800;
                letter-spacing:-.04em;
                color:var(--ink);
                line-height:1.02;
            }

            .hero-text{
                max-width:500px;
                color:var(--ink-soft);
                font-size:1rem;
                line-height:1.65;
            }

            .hero-benefits{
                display:flex;
                flex-wrap:wrap;
                gap:10px 18px;
                margin:22px 0 0;
                padding:0;
                color:var(--ink-soft);
                font-size:.87rem;
                font-weight:600;
                list-style:none;
            }

            .hero-benefits i{
                margin-right:6px;
                color:var(--primary);
            }

            .hero-image{
                width:100%;
                min-height:275px;
                max-height:330px;
                object-fit:cover;
                border-radius:18px;
                box-shadow:0 18px 38px rgba(74,54,39,.18);
            }

            .search-card{
                border:1px solid var(--border);
                border-radius:18px;
                background:var(--surface);
                box-shadow:var(--shadow);
            }

            .search-heading{
                display:flex;
                align-items:center;
                gap:10px;
                margin:0;
                color:var(--ink);
                font-size:1rem;
                font-weight:800;
            }

            .search-heading i{
                color:var(--primary);
            }

            .search-hint{
                margin:3px 0 0;
                color:var(--ink-soft);
                font-size:.82rem;
            }

            .filter-label{
                display:block;
                margin-bottom:6px;
                color:var(--ink-soft);
                font-size:.75rem;
                font-weight:700;
                letter-spacing:.02em;
            }

            .form-control,
            .form-select{
                min-height:44px;
                border:1px solid var(--border);
                border-radius:10px;
                padding:9px 12px;
                color:var(--ink);
                background-color:#fffdfa;
            }

            .form-control::placeholder{
                color:#9a9189;
            }

            .form-control:focus,
            .form-select:focus{
                border-color:var(--primary);
                box-shadow:0 0 0 .2rem rgba(198,91,61,.16);
            }

            .section-heading{
                display:flex;
                align-items:end;
                justify-content:space-between;
                gap:16px;
                margin:38px 0 18px;
            }

            .section-title{
                margin:0;
                font-size:clamp(1.55rem,2.6vw,2rem);
                font-weight:800;
                letter-spacing:-.025em;
                color:var(--ink);
            }

            .section-subtitle{
                margin:5px 0 0;
                color:var(--ink-soft);
                font-size:.9rem;
            }

            .result-count{
                flex:0 0 auto;
                padding:7px 11px;
                border-radius:999px;
                background:#f1e6dc;
                color:var(--primary-dark);
                font-size:.78rem;
                font-weight:800;
            }

            .product-card{
                border:1px solid var(--border);
                border-radius:16px;
                overflow:hidden;
                background:var(--surface);
                box-shadow:0 4px 14px rgba(74,54,39,.04);
                transition:transform .2s ease, box-shadow .2s ease, border-color .2s ease;
                position:relative;
            }

            .product-card:hover{
                transform:translateY(-4px);
                border-color:#d9b6a4;
                box-shadow:0 16px 28px rgba(74,54,39,.12);
            }

            .product-image{
                height:250px;
                object-fit:cover;
                background:#f1ebe5;
            }

            .product-card .card-body{
                padding:16px 16px 8px;
            }

            .product-card h6{
                min-height:20px;
                color:var(--ink);
            }

            .product-price{
                color:var(--primary-dark);
                font-size:1.15rem;
                font-weight:800;
            }

            .product-info{
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:8px;
                margin-top:8px;
                color:var(--ink-soft);
                font-size:.76rem;
            }

            .product-info span:first-child{
                min-width:0;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
            }

            .product-info .stock-ok{
                flex:0 0 auto;
            }

            .stock-ok{
                color:#28714d;
            }

            .wishlist-heart-form{
                position:absolute;
                top:12px;
                right:12px;
                z-index:5;
                margin:0;
            }

            .wishlist-heart{
                width:38px;
                height:38px;
                border:1px solid rgba(255,255,255,.75);
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                background:rgba(255,255,255,.94);
                color:var(--primary);
                box-shadow:0 6px 16px rgba(74,54,39,.18);
                transition:.2s;
            }

            .wishlist-heart:hover,
            .wishlist-heart.is-active{
                background:var(--primary);
                color:#fff;
                transform:scale(1.05);
            }

            .wishlist-toast{
                position:fixed;
                top:84px;
                right:20px;
                z-index:1080;
                min-width:260px;
                max-width:360px;
                padding:13px 16px;
                border-radius:12px;
                background:var(--ink);
                color:#fff;
                box-shadow:0 18px 40px rgba(37,33,30,.22);
                opacity:0;
                transform:translateY(-12px);
                pointer-events:none;
                transition:.25s;
                font-size:.9rem;
                font-weight:700;
            }

            .wishlist-toast.show{
                opacity:1;
                transform:translateY(0);
            }

            .wishlist-toast.is-error{
                background:#a53e2d;
            }

            .card-footer{
                padding:8px 16px 16px;
                background:var(--surface)!important;
                border-top:0;
            }

            .card-footer .form-select{
                min-height:38px;
                padding-top:6px;
                padding-bottom:6px;
                font-size:.78rem;
            }

            .product-actions{
                display:grid;
                grid-template-columns:1fr 1.25fr;
                gap:8px;
            }

            .product-actions .btn{
                min-height:38px;
                padding:7px 8px;
                border-radius:9px;
                font-size:.78rem;
            }

            .fa-box-open{
                color:var(--primary)!important;
            }

            .empty-state{
                padding:58px 20px;
                border:1px dashed #d8c9bc;
                border-radius:18px;
                background:rgba(255,255,255,.55);
            }

            .home-more{
                display:flex;
                justify-content:center;
                margin:26px 0 8px;
            }

            .home-more .btn{
                min-width:210px;
                border-radius:8px;
                padding:10px 20px;
            }

            /* Compact marketplace-style product grid */
            .product-grid{
                display:grid;
                grid-template-columns:repeat(6,minmax(0,1fr));
                gap:12px;
            }

            .product-item{
                min-width:0;
            }

            .product-card{
                border-radius:5px;
                box-shadow:0 1px 3px rgba(74,54,39,.12);
            }

            .product-card:hover{
                transform:translateY(-2px);
                border-color:#d8b29f;
                box-shadow:0 5px 14px rgba(74,54,39,.16);
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
                background:var(--primary);
            }

            .product-stock-badge{
                right:0;
                color:#8b4a27;
                background:#fff3dc;
            }

            .product-card .card-body{
                padding:8px 9px 3px;
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
                color:var(--ink);
                text-decoration:none;
            }

            .product-title-link:hover{
                color:var(--primary-dark);
            }

            .product-price{
                font-size:1rem;
                line-height:1.2;
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
            }

            .product-info{
                margin-top:5px;
                font-size:.68rem;
            }

            .product-info .stock-ok{
                color:#81766d;
            }

            .product-info span:first-child{
                display:none;
            }

            .product-info{
                justify-content:flex-end;
            }

            .product-card .wishlist-heart-form{
                position:static;
                display:block;
                margin:6px 0 2px;
            }

            .product-card .wishlist-heart{
                width:30px;
                height:30px;
                border:1px solid #efd4c8;
                background:#fff;
                color:var(--primary);
                box-shadow:none;
                font-size:.82rem;
            }

            .product-card .wishlist-heart:hover,
            .product-card .wishlist-heart.is-active{
                background:var(--primary);
                color:#fff;
            }

            .product-card .card-footer{
                display:none;
            }

            .card-footer{
                padding:5px 9px 9px;
            }

            .card-footer .form-select{
                min-height:32px;
                margin-bottom:5px!important;
                padding:4px 7px;
                font-size:.69rem;
            }

            .product-actions{
                grid-template-columns:1fr 1.35fr;
                gap:5px;
            }

            .product-actions .btn{
                min-height:32px;
                padding:5px 4px;
                border-radius:4px;
                font-size:.69rem;
                white-space:nowrap;
            }

            @media(max-width:1199px){
                .product-grid{
                    grid-template-columns:repeat(5,minmax(0,1fr));
                }
            }

            @media(max-width:991px){
                .product-grid{
                    grid-template-columns:repeat(4,minmax(0,1fr));
                }
            }

            @media(max-width:767px){
                .product-grid{
                    grid-template-columns:repeat(3,minmax(0,1fr));
                    gap:9px;
                }
            }

            @media(max-width:575px){
                .product-grid{
                    grid-template-columns:repeat(2,minmax(0,1fr));
                    gap:8px;
                }
            }

            .cart-message-modal .modal-dialog{
                max-width:520px;
            }

            .cart-message-modal .modal-content{
                border:0;
                border-radius:18px;
                overflow:hidden;
                box-shadow:0 24px 70px rgba(15,23,42,.24);
            }

            .cart-message-modal .modal-header{
                border:0;
                padding:28px 28px 12px;
                align-items:center;
            }

            .cart-message-modal .modal-body{
                color:var(--ink-soft);
                padding:8px 28px 20px;
                font-size:1rem;
            }

            .cart-message-modal .modal-footer{
                border:0;
                gap:10px;
                padding:0 28px 28px;
            }

            .cart-message-modal .modal-title{
                display:flex;
                align-items:center;
                gap:12px;
                color:var(--ink);
                font-weight:800;
            }

            .cart-modal-mark{
                width:42px;
                height:42px;
                border-radius:14px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                background:linear-gradient(135deg,var(--ink),var(--primary));
                box-shadow:0 12px 24px rgba(198,91,61,.24);
            }

            .cart-message-modal.is-error .cart-modal-mark{
                background:linear-gradient(135deg,#873724,#c65b3d);
                box-shadow:0 12px 24px rgba(198,91,61,.22);
            }

            .cart-message-modal .modal-footer .btn{
                border-radius:10px;
                min-height:42px;
                padding:9px 16px;
                font-weight:700;
            }

            .cart-message-modal .modal-footer .btn-danger{
                background:var(--primary)!important;
                border-color:var(--primary)!important;
            }

            .cart-message-modal .modal-footer .btn-danger:hover{
                background:var(--primary-dark)!important;
                border-color:var(--primary-dark)!important;
            }

            /* RESPONSIVE */

            @media(max-width:768px){

                .hero{
                    padding:20px 0;
                }

                .hero-panel{
                    padding:28px 22px;
                    text-align:center;
                }

                .hero-title,
                .hero-text{
                    margin-left:auto;
                    margin-right:auto;
                }

                .hero-benefits{
                    justify-content:center;
                }

                .hero-image{
                    min-height:210px;
                    max-height:250px;
                    margin-top:26px;
                }

                .section-heading{
                    align-items:start;
                    flex-direction:column;
                }

                .cart-message-modal .modal-footer .btn{
                    width:100%;
                }
            }

            /* Cart message modal */
            .cart-message-modal .modal-content{
                border:0;
                border-radius:20px;
                overflow:hidden;
                box-shadow:0 24px 70px rgba(37,33,30,.22);
            }

            .cart-message-modal .modal-header{
                padding:28px 28px 10px;
                border:0;
            }

            .cart-message-modal .modal-title{
                color:var(--ink);
                font-size:1.25rem;
                font-weight:800;
            }

            .cart-message-modal .modal-body{
                padding:8px 28px 20px;
                color:var(--ink-soft);
                font-size:.98rem;
            }

            .cart-modal-mark{
                width:44px;
                height:44px;
                border-radius:14px;
                background:#e8f5ee;
                color:#287a58;
                box-shadow:none;
            }

            .cart-message-modal.is-error .cart-modal-mark{
                background:#fbe9e6;
                color:#bd4a38;
                box-shadow:none;
            }

            .cart-message-modal .modal-footer{
                gap:10px;
                padding:0 28px 28px;
                border:0;
            }

            .cart-message-modal .modal-footer .btn{
                min-height:44px;
                padding:9px 18px;
                border-radius:10px;
                font-weight:700;
            }

            .cart-message-modal .modal-footer .btn-outline-dark{
                border:1px solid #25211e!important;
                background:#fff!important;
                color:#25211e!important;
            }

            .cart-message-modal .modal-footer .btn-outline-dark:hover{
                background:#25211e!important;
                color:#fff!important;
            }

            .cart-message-modal .modal-footer .btn-danger{
                background:#c65b3d!important;
                border:1px solid #c65b3d!important;
                color:#fff!important;
            }

            .cart-message-modal .modal-footer .btn-danger:hover{
                background:#a9462d!important;
                border-color:#a9462d!important;
            }

        </style>

    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>
        <!-- HERO -->

        <section class="hero">
            <div class="container">
                <div class="hero-panel">
                    <div class="row align-items-center g-4">
                        <div class="col-lg-6 hero-content">
                            <span class="hero-kicker">New season edit</span>
                            <h1 class="hero-title">Find your everyday favourite.</h1>
                            <p class="hero-text mt-3">
                                Curated clothing, sneakers and accessories that make getting dressed simple.
                            </p>
                            <a href="#products" class="btn btn-danger mt-3 px-4 py-2">
                                Explore collection <i class="fa-solid fa-arrow-right ms-2"></i>
                            </a>
                            <ul class="hero-benefits">
                                <li><i class="fa-solid fa-circle-check"></i>Easy shopping</li>
                                <li><i class="fa-solid fa-tag"></i>Good value</li>
                                <li><i class="fa-solid fa-truck"></i>Fast delivery</li>
                            </ul>
                        </div>
                        <div class="col-lg-6 hero-visual">
                            <img
                                src="https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=1000&q=80"
                                class="hero-image"
                                alt="Clothing collection"
                                loading="eager">
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- MAIN -->

        <div class="container">

            <!-- SEARCH + FILTER -->

            <c:if test="${not empty param.keyword}">
            <form action="${pageContext.request.contextPath}/home" method="GET" class="card search-card p-3 p-md-4 mb-5">
                <div class="mb-3">
                    <h2 class="search-heading"><i class="fa-solid fa-sliders"></i> Find the right piece</h2>
                    <p class="search-hint">Search by name, narrow by budget, or sort the collection.</p>
                </div>
                <div class="row g-3 align-items-end">
                    <div class="col-6 col-md-2">
                        <label class="filter-label" for="minPrice">Min price</label>
                        <input id="minPrice" type="number" name="minPrice" value="${param.minPrice}" class="form-control" placeholder="0" min="0">
                    </div>
                    <div class="col-6 col-md-2">
                        <label class="filter-label" for="maxPrice">Max price</label>
                        <input id="maxPrice" type="number" name="maxPrice" value="${param.maxPrice}" class="form-control" placeholder="Any" min="0">
                    </div>
                    <div class="col-md-2">
                        <label class="filter-label" for="sort">Sort by</label>
                        <select id="sort" name="sort" class="form-select">
                            <option value="" ${empty param.sort ? 'selected' : ''}>Recommended</option>
                            <option value="priceAsc" ${param.sort == 'priceAsc' ? 'selected' : ''}>Price: low to high</option>
                            <option value="priceDesc" ${param.sort == 'priceDesc' ? 'selected' : ''}>Price: high to low</option>
                            <option value="newest" ${param.sort == 'newest' ? 'selected' : ''}>Newest first</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="filter-label" for="keyword">Search</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0" style="border-color:var(--border); color:var(--primary);"><i class="fa-solid fa-magnifying-glass"></i></span>
                            <input id="keyword" type="text" name="keyword" value="${param.keyword}" class="form-control border-start-0" placeholder="Try &quot;hoodie&quot; or &quot;sneakers&quot;">
                        </div>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button class="btn btn-danger flex-grow-1"><i class="fa-solid fa-magnifying-glass me-1"></i> Search</button>
                        <c:if test="${not empty param.keyword or not empty param.minPrice or not empty param.maxPrice or not empty param.sort}">
                            <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-dark" title="Clear filters" aria-label="Clear filters"><i class="fa-solid fa-rotate-left"></i></a>
                        </c:if>
                    </div>
                </div>
            </form>
            </c:if>

            <!-- PRODUCT SECTION TITLE -->

            <div class="section-heading">
                <div>
                    <h2 class="section-title">Featured products</h2>
                    <p class="section-subtitle">Pieces selected for your next everyday look.</p>
                </div>
                <c:if test="${not empty products}">
                    <span class="result-count">${products.size()} items</span>
                </c:if>
            </div>
            <!-- PRODUCT LIST -->

            <c:if test="${not empty products}">

                <div id="products" class="product-grid">

                    <c:forEach items="${products}"
                               var="p">

                        <div class="product-item">

                            <c:set var="isWishlisted"
                                   value="${wishlistProductIds.contains(p.id)}"/>

                            <div class="card product-card h-100">

                                <!-- IMAGE -->

                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="product-image-link">
                                    <span class="product-ribbon">Featured</span>
                                    <c:if test="${not empty p.variants}">
                                        <span class="product-stock-badge">In stock</span>
                                    </c:if>

                                    <img
                                        src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}"
                                        class="card-img-top product-image"
                                        alt="${p.productName}"
                                        loading="lazy">

                                </a>    
                                <!-- BODY -->

                                <div class="card-body">

                                    <h6 class="fw-bold text-truncate mb-2">
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="product-title-link">
                                            ${p.productName}
                                        </a>
                                    </h6>
                                    <c:choose>
                                        <c:when test="${not empty p.variants}">
                                            <div class="product-price mb-2">
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
                                            <div class="product-info">
                                                <span><i class="fa-solid fa-palette me-1"></i>${p.variants[0].attributeDetails}</span>
                                                <span class="stock-ok"><i class="fa-solid fa-box me-1"></i>${p.variants[0].stockQuantity} left</span>
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
                                    <c:if test="${not empty p.variants}">
                                        <form action="${pageContext.request.contextPath}/cart"
                                              method="post"
                                              class="add-cart-form"
                                              style="margin:0">
                                            <label class="visually-hidden" for="variant-${p.id}">Choose a variant for ${p.productName}</label>
                                            <select id="variant-${p.id}" name="variantId" class="form-select form-select-sm mb-2 variant-select">
                                                <c:forEach items="${p.variants}" var="v">
                                                    <option value="${v.id}"
                                                            data-price="${v.salePrice}"
                                                            data-attributes="${v.attributeDetails}">
                                                        ${v.attributeDetails} - <fmt:formatNumber value="${v.salePrice}" pattern="#,##0"/> &#8363;
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <input type="hidden" name="productId" value="${p.id}" />
                                            <input type="hidden" name="productName" value="${p.productName}" />
                                            <input type="hidden" name="attributes" class="attributes-input" value="${p.variants[0].attributeDetails}" />
                                            <input type="hidden" name="price" class="price-input" value="${p.variants[0].salePrice}" />
                                            <input type="hidden" name="quantity" value="1" />
                                            <input type="hidden"name="imageUrl"value="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}" />
                                            <div class="product-actions">
                                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="btn btn-outline-dark">
                                                    Details
                                                </a>
                                                <button type="submit" class="btn btn-danger">
                                                    <i class="fa-solid fa-cart-plus"></i>
                                                    Add to cart
                                                </button>
                                            </div>
                                        </form>
                                    </c:if>
                                    <c:if test="${empty p.variants}">
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}" class="btn btn-outline-dark w-100">
                                            View details
                                        </a>
                                    </c:if>

                                </div>

                            </div>

                        </div>

                    </c:forEach>

                </div>

                <c:if test="${hasMoreProducts}">
                    <c:url var="productsPageUrl" value="/products">
                        <c:param name="keyword" value="${param.keyword}"/>
                        <c:param name="minPrice" value="${param.minPrice}"/>
                        <c:param name="maxPrice" value="${param.maxPrice}"/>
                        <c:param name="sort" value="${param.sort}"/>
                    </c:url>
                    <div class="home-more">
                        <a href="${productsPageUrl}" class="btn btn-outline-dark">
                            View more products <i class="fa-solid fa-arrow-right ms-2"></i>
                        </a>
                    </div>
                </c:if>

            </c:if>


            <!-- EMPTY PRODUCT -->

            <c:if test="${empty products}">

                <div class="text-center empty-state">

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

        <div class="wishlist-toast" id="wishlistToast">
            <i class="fa-solid fa-heart me-2"></i>
            <span id="wishlistToastText"></span>
        </div>

        <div class="modal fade cart-message-modal" id="cartMessageModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="cart-modal-mark">
                                <i class="fa-solid fa-check"></i>
                            </span>
                            <span id="cartMessageTitle">Cart Updated</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body" id="cartMessageText">
                        Item added to your cart.
                    </div>
                    <div class="modal-footer">
                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-dark">View Cart</a>
                        <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Continue Shopping</button>
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
                var modalElement = document.getElementById('cartMessageModal');
                var isError = params.has('cartError');
                modalElement.classList.toggle('is-error', isError);
                var icon = modalElement.querySelector('.cart-modal-mark i');
                if (icon) {
                    icon.className = isError
                            ? 'fa-solid fa-triangle-exclamation'
                            : 'fa-solid fa-check';
                }
                document.getElementById('cartMessageTitle').textContent =
                        isError ? 'Could Not Add Item' : 'Cart Updated';
                var message = params.has('cartAdded')
                        ? 'Item added to your cart.'
                        : 'Could not add this item to your cart. Please check available stock.';
                document.getElementById('cartMessageText').textContent = message;
                new bootstrap.Modal(modalElement).show();
            }

            if (params.has('wishlistAdded') || params.has('wishlistRemoved') || params.has('wishlistError')) {
                var wishlistToast = document.getElementById('wishlistToast');
                var wishlistToastText = document.getElementById('wishlistToastText');
                var wishlistMessage = 'Added to your wishlist.';

                if (params.has('wishlistRemoved')) {
                    wishlistMessage = 'Removed from your wishlist.';
                }

                if (params.has('wishlistError')) {
                    wishlistMessage = 'Unable to update your wishlist.';
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
