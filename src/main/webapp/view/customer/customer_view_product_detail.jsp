<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"
          uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>

<html>
    <head>

        <title>${product.productName}</title>

        <link 
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
            rel="stylesheet">

        <link 
            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            rel="stylesheet">


        <style>

            :root{
                --navy:#172033;
                --navy-light:#22304d;
                --teal:#0f9b8e;
                --teal-light:#19b8aa;
                --bg:#f4f8fb;
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

            /* CARD */

            .detail-card{
                background:#fff;
                border:none;
                border-radius:24px;
                padding:40px;
                box-shadow:0 18px 45px rgba(23,32,51,.08);
            }

            .product-description{
                background:#fff;
                border:none;
                border-radius:24px;
                padding:35px;
                margin-top:30px;
                box-shadow:0 18px 45px rgba(23,32,51,.08);
            }

            /* IMAGE */

            .product-image{
                width:100%;
                height:520px;
                object-fit:cover;
                border-radius:20px;
                transition:.3s;
                border:none;
            }

            .product-image:hover{
                transform:scale(1.02);
            }

            /* TEXT */

            .product-name{
                font-size:36px;
                font-weight:800;
                color:var(--navy);
                line-height:1.3;
            }

            .price{
                margin-top:25px;
                background:rgba(15,155,142,.08);
                border-left:6px solid var(--teal);
                border-radius:18px;
                padding:20px 24px;

                color:var(--teal);
                font-size:38px;
                font-weight:800;
            }

            .stock-text{
                color:var(--muted);
                font-size:16px;
            }

            /* FORM */

            .form-select{
                border-radius:14px;
                padding:12px;
            }

            .form-select:focus{
                border-color:var(--teal);
                box-shadow:0 0 0 .25rem rgba(15,155,142,.15);
            }

            /* BUTTON */

            .btn-cart{
                background:linear-gradient(
                    135deg,
                    var(--navy),
                    var(--teal)
                    );

                border:none;
                color:#fff;
                border-radius:12px;
                padding:12px 24px;
                font-weight:700;
            }

            .btn-cart:hover{
                background:linear-gradient(
                    135deg,
                    var(--navy-light),
                    var(--teal-light)
                    );

                color:#fff;
            }

            .btn-buy-now{
                background:#fff;
                color:var(--navy);
                border:2px solid var(--navy);
                border-radius:12px;
                padding:12px 24px;
                margin-left:12px;
                font-weight:700;
            }

            .btn-buy-now:hover{
                background:var(--navy);
                color:#fff;
            }

            .btn-wishlist{
                background:#fff;
                color:#dc2626;
                border:2px solid #dc2626;
                border-radius:12px;
                padding:12px 24px;
                font-weight:700;
            }

            .btn-wishlist:hover{
                background:#dc2626;
                color:#fff;
            }

            /* DESCRIPTION */

            .product-description h4{
                color:var(--navy);
                font-weight:800;
            }

            .product-description p{
                color:#4b5563;
                line-height:1.8;
            }

            /* MODAL */

            .cart-message-modal .modal-dialog{
                max-width:520px;
            }

            .cart-message-modal .modal-content{
                border:0;
                border-radius:20px;
                overflow:hidden;
                box-shadow:0 24px 70px rgba(23,32,51,.24);
            }

            .cart-message-modal .modal-header{
                border:0;
                padding:28px 28px 12px;
            }

            .cart-message-modal .modal-body{
                padding:8px 28px 20px;
                color:#64748b;
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
                color:var(--navy);
                font-weight:800;
            }

            .cart-modal-mark{
                width:42px;
                height:42px;
                border-radius:14px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                background:linear-gradient(135deg,var(--navy),var(--teal));
            }

            .cart-message-modal.is-error .cart-modal-mark{
                background:linear-gradient(135deg,#7f1d1d,#ef4444);
            }

            .cart-message-modal .modal-footer .btn{
                border-radius:10px;
                font-weight:700;
            }

            .cart-message-modal .modal-footer .btn-cart{
                background:var(--teal);
            }

            .cart-message-modal .modal-footer .btn-cart:hover{
                background:#0d8278;
            }

            @media(max-width:768px){

                .detail-card{
                    padding:25px;
                }

                .product-image{
                    height:360px;
                }

                .product-name{
                    font-size:28px;
                    margin-top:20px;
                }

                .price{
                    font-size:30px;
                }

                .btn-cart,
                .btn-buy-now,
                .btn-wishlist{
                    width:100%;
                    margin:8px 0 0;
                }

            }

            /* Marketplace-style product detail */
            :root{
                --detail-ink:#25211e;
                --detail-muted:#6f665e;
                --detail-primary:#ee4d2d;
                --detail-border:#e5e5e5;
                --detail-bg:#f5f5f5;
            }

            body{
                background:var(--detail-bg);
                color:var(--detail-ink);
            }

            .detail-card{
                padding:16px;
                border:1px solid #ededed;
                border-radius:4px;
                box-shadow:0 1px 2px rgba(0,0,0,.08);
            }

            .detail-card > .row{
                align-items:flex-start!important;
            }

            .product-gallery{
                padding:0 10px 0 0;
            }

            .product-media-frame{
                display:flex;
                align-items:center;
                justify-content:center;
                width:100%;
                height:450px;
                background:#fafafa;
                overflow:hidden;
            }

            .product-image{
                width:100%;
                height:100%;
                object-fit:contain;
                border-radius:0;
                transition:none;
            }

            .product-image:hover{
                transform:none;
            }

            .media-thumbs{
                display:flex;
                gap:8px;
                margin-top:10px;
                overflow-x:auto;
            }

            .media-thumb{
                flex:0 0 72px;
                width:72px;
                height:72px;
                padding:2px;
                border:1px solid var(--detail-border);
                background:#fff;
                object-fit:cover;
            }

            .media-thumb.active{
                border:2px solid var(--detail-primary);
            }

            .product-summary{
                padding:4px 8px 0 16px;
            }

            .detail-title-row{
                display:flex;
                align-items:flex-start;
                gap:8px;
            }

            .product-name{
                flex:1;
                margin:0!important;
                font-size:24px;
                font-weight:500;
                line-height:1.35;
                color:var(--detail-ink);
            }

            .favorite-button{
                flex:0 0 auto;
                color:var(--detail-primary);
                border:0;
                background:transparent;
                font-size:22px;
            }

            .product-tag{
                display:inline-block;
                padding:3px 6px;
                color:#fff;
                background:var(--detail-primary);
                font-size:12px;
                line-height:1;
                vertical-align:middle;
            }

            .product-rating{
                display:flex;
                align-items:center;
                flex-wrap:wrap;
                gap:0;
                margin-top:12px;
                color:var(--detail-muted);
                font-size:14px;
            }

            .product-rating > span{
                padding:0 16px;
                border-right:1px solid #ddd;
            }

            .product-rating > span:first-child{
                padding-left:0;
            }

            .product-rating > span:last-child{
                border-right:0;
            }

            .rating-score{
                color:var(--detail-ink);
                text-decoration:underline;
                font-size:16px;
            }

            .rating-stars{
                margin-left:6px;
                color:#ffb400;
                letter-spacing:1px;
            }

            .price{
                margin:16px 0 14px;
                padding:18px 20px;
                border:0;
                border-radius:0;
                background:#fff7f5;
                color:var(--detail-primary);
                font-size:32px;
                font-weight:500;
            }

            .price-note{
                margin-left:8px;
                font-size:13px;
                font-weight:400;
            }

            .detail-row{
                display:grid;
                grid-template-columns:102px 1fr;
                gap:12px;
                align-items:start;
                padding:14px 0;
                color:var(--detail-muted);
                font-size:14px;
            }

            .detail-row + .detail-row{
                border-top:1px solid #f1f1f1;
            }

            .detail-row-label{
                padding-top:7px;
            }

            .service-line{
                display:flex;
                align-items:flex-start;
                gap:10px;
                color:var(--detail-ink);
                line-height:1.55;
            }

            .service-line i{
                width:16px;
                margin-top:3px;
                color:#19a689;
            }

            .service-line small{
                display:block;
                color:var(--detail-muted);
            }

            .variant-options{
                display:flex;
                flex-wrap:wrap;
                gap:8px;
            }

            .variant-option{
                min-height:38px;
                padding:7px 12px;
                border:1px solid #d9d9d9;
                border-radius:2px;
                background:#fff;
                color:var(--detail-ink);
                font-size:14px;
            }

            .variant-option:hover,
            .variant-option.active{
                border-color:var(--detail-primary);
                color:var(--detail-primary);
                background:#fffaf8;
            }

            .stock-text{
                margin:0!important;
                color:var(--detail-muted);
                font-size:13px;
            }

            .quantity-control{
                display:inline-flex;
                align-items:center;
                border:1px solid #ddd;
                background:#fff;
            }

            .quantity-control button,
            .quantity-control input{
                width:38px;
                height:32px;
                border:0;
                background:#fff;
                color:var(--detail-muted);
                text-align:center;
            }

            .quantity-control button{
                font-size:16px;
            }

            .quantity-control button:hover{
                background:#f7f7f7;
                color:var(--detail-primary);
            }

            .quantity-control input{
                border-left:1px solid #eee;
                border-right:1px solid #eee;
                -moz-appearance:textfield;
            }

            .quantity-control input::-webkit-outer-spin-button,
            .quantity-control input::-webkit-inner-spin-button{
                margin:0;
                -webkit-appearance:none;
            }

            .detail-actions{
                display:flex;
                flex-wrap:wrap;
                gap:10px;
                margin-top:18px;
            }

            .detail-actions .btn{
                min-width:180px;
                min-height:46px;
                border-radius:2px;
                font-size:15px;
            }

            .btn-cart{
                background:#fff1ed;
                border:1px solid var(--detail-primary);
                color:var(--detail-primary);
            }

            .btn-cart:hover{
                background:#ffe5de;
                color:#d83f25;
            }

            .btn-buy-now{
                margin-left:0;
                background:var(--detail-primary);
                border:1px solid var(--detail-primary);
                color:#fff;
            }

            .btn-buy-now:hover{
                background:#d83f25;
                color:#fff;
            }

            .product-description{
                padding:22px 24px;
                border:1px solid #ededed;
                border-radius:4px;
                box-shadow:0 1px 2px rgba(0,0,0,.06);
            }

            .product-description h4{
                color:var(--detail-ink);
                font-size:18px;
            }

            .product-description p{
                color:var(--detail-muted);
                line-height:1.7;
            }

            @media(max-width:991px){
                .product-gallery{
                    padding-right:0;
                }

                .product-summary{
                    padding:20px 0 0;
                }
            }

            @media(max-width:576px){
                .detail-card{
                    padding:10px;
                }

                .product-media-frame{
                    height:330px;
                }

                .product-name{
                    font-size:20px;
                }

                .price{
                    font-size:26px;
                }

                .detail-row{
                    grid-template-columns:86px 1fr;
                }

                .detail-actions .btn{
                    flex:1 1 100%;
                    width:100%;
                }
            }

            /* Product ratings */
            .feedback-section{
                margin-top:18px;
                padding:24px 44px 34px;
                background:#fff;
            }

            .feedback-section > h4{
                margin-bottom:14px!important;
                font-size:20px;
                font-weight:500!important;
            }

            .feedback-summary{
                display:flex;
                align-items:center;
                gap:34px;
                padding:28px 30px;
                border:1px solid #f2e1d9;
                background:#fffaf8;
            }

            .feedback-score{
                flex:0 0 145px;
                text-align:center;
                color:var(--detail-primary);
            }

            .feedback-score-value{
                font-size:30px;
                line-height:1.1;
            }

            .feedback-score-value small{
                color:var(--detail-ink);
                font-size:14px;
            }

            .feedback-score-stars{
                margin-top:8px;
                font-size:20px;
                letter-spacing:2px;
            }

            .feedback-filters{
                display:flex;
                flex:1;
                flex-wrap:wrap;
                gap:8px;
            }

            .feedback-filter{
                min-width:100px;
                padding:8px 13px;
                border:1px solid #ddd;
                border-radius:2px;
                background:#fff;
                color:var(--detail-ink);
                font-size:13px;
            }

            .feedback-filter:hover,
            .feedback-filter.active{
                border-color:var(--detail-primary);
                color:var(--detail-primary);
                background:#fff;
            }

            .feedback-form{
                margin:24px 0 0;
                padding:18px;
                border:1px solid #eee;
                background:#fff;
            }

            .feedback-form .form-label{
                color:var(--detail-ink);
                font-size:14px;
            }

            .feedback-form .form-control,
            .feedback-form .form-select{
                border-radius:2px;
            }

            .feedback-list{
                margin-top:18px;
            }

            .feedback-item{
                padding:24px 20px;
                border-bottom:1px solid #eee;
            }

            .feedback-user{
                display:flex;
                align-items:flex-start;
                gap:12px;
            }

            .feedback-avatar{
                display:flex;
                align-items:center;
                justify-content:center;
                flex:0 0 40px;
                width:40px;
                height:40px;
                border:1px solid #ddd;
                border-radius:50%;
                background:#fafafa;
                color:#aaa;
            }

            .feedback-user-name{
                color:#1769aa;
                font-size:13px;
            }

            .feedback-stars{
                margin-top:4px;
                color:var(--detail-primary);
                font-size:16px;
                letter-spacing:1px;
            }

            .feedback-meta{
                margin-top:4px;
                color:#999;
                font-size:12px;
            }

            .feedback-comment{
                margin:16px 0 0 52px;
                color:#333;
                font-size:14px;
                line-height:1.65;
                white-space:pre-line;
            }

            .seller-response{
                margin:16px 0 0 52px;
                padding:14px 12px;
                background:#f6f6f6;
                color:#555;
                font-size:13px;
                line-height:1.55;
            }

            .feedback-actions{
                margin:16px 0 0 52px;
                color:#aaa;
                font-size:12px;
            }

            .feedback-empty{
                padding:36px 0;
                color:#888;
                text-align:center;
            }

            @media(max-width:767px){
                .feedback-section{
                    padding:20px 16px 28px;
                }

                .feedback-summary{
                    align-items:flex-start;
                    flex-direction:column;
                    gap:20px;
                    padding:20px;
                }

                .feedback-score{
                    flex-basis:auto;
                    width:100%;
                    text-align:left;
                }

                .feedback-comment,
                .seller-response,
                .feedback-actions{
                    margin-left:0;
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
                color:var(--detail-ink);
                font-size:1.25rem;
                font-weight:800;
            }

            .cart-message-modal .modal-body{
                padding:8px 28px 20px;
                color:var(--detail-muted);
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

            .cart-message-modal .modal-footer .btn-cart{
                background:#c65b3d!important;
                border:1px solid #c65b3d!important;
                color:#fff!important;
            }

            .cart-message-modal .modal-footer .btn-cart:hover{
                background:#a9462d!important;
                border-color:#a9462d!important;
            }

        </style>

    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container my-5">

            <div class="detail-card">
                <div class="row g-4">
                    <div class="col-lg-5 col-md-6 product-gallery">
                        <div class="product-media-frame">
                            <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                                 class="product-image"
                                 alt="${product.productName}">
                        </div>
                        <div class="media-thumbs" aria-label="Product images">
                            <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                                 class="media-thumb active"
                                 alt="${product.productName} preview">
                        </div>
                    </div>

                    <div class="col-lg-7 col-md-6 product-summary">
                        <div class="detail-title-row">
                            <h1 class="product-name">
                                <span class="product-tag">Featured</span>
                                ${product.productName}
                            </h1>
                        </div>

                        <div class="product-rating" aria-label="Product reviews">
                            <span><span class="rating-score">Customer reviews</span> <span class="rating-stars">★★★★★</span></span>
                            <span>${feedbacks.size()} Ratings</span>
                            <span>In stock</span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty product.variants}">
                                <div class="price">
                                    <span id="priceValue">${product.variants[0].salePrice} &#8363;</span>
                                    <span class="price-note">Best price today</span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="price">Contact</div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${not empty product.variants}">
                            <form action="${pageContext.request.contextPath}/cart" method="post" class="add-cart-form">
                                <div class="detail-row">
                                    <div class="detail-row-label">Shipping</div>
                                    <div>
                                        <div class="service-line"><i class="fa-solid fa-truck"></i><span>Fast delivery to your address</span></div>
                                        <div class="service-line mt-1"><i class="fa-solid fa-ticket"></i><span>Free shipping for eligible orders</span></div>
                                    </div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-row-label">Guarantee</div>
                                    <div class="service-line"><i class="fa-solid fa-shield-heart"></i><span>15-day return support</span></div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-row-label">Variant</div>
                                    <div>
                                        <div class="variant-options" role="radiogroup" aria-label="Choose variant">
                                            <c:forEach items="${product.variants}" var="v">
                                                <button type="button"
                                                        class="variant-option ${v.id == product.variants[0].id ? 'active' : ''}"
                                                        data-variant-id="${v.id}">
                                                    ${v.attributeDetails}
                                                </button>
                                            </c:forEach>
                                        </div>
                                        <select name="variantId" class="variant-select d-none">
                                            <c:forEach items="${product.variants}" var="v">
                                                <option value="${v.id}"
                                                        data-price="${v.salePrice}"
                                                        data-stock="${v.stockQuantity}"
                                                        data-attributes="${v.attributeDetails}">
                                                    ${v.attributeDetails}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-row-label">Quantity</div>
                                    <div class="d-flex align-items-center gap-3 flex-wrap">
                                        <div class="quantity-control">
                                            <button type="button" class="quantity-decrease" aria-label="Decrease quantity">−</button>
                                            <input type="number" name="quantity" class="quantity-input" value="1" min="1" max="${product.variants[0].stockQuantity}" aria-label="Quantity">
                                            <button type="button" class="quantity-increase" aria-label="Increase quantity">+</button>
                                        </div>
                                        <span class="stock-text"><i class="fa-solid fa-box-open me-1"></i><b id="stockText">${product.variants[0].stockQuantity}</b> in stock</span>
                                    </div>
                                </div>

                                <input type="hidden" name="productId" value="${product.id}">
                                <input type="hidden" name="productName" value="${product.productName}">
                                <input type="hidden" name="attributes" class="attributes-input" value="${product.variants[0].attributeDetails}">
                                <input type="hidden" name="price" class="price-input" value="${product.variants[0].salePrice}">
                                <input type="hidden" name="imageUrl" value="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}">

                                <div class="detail-actions">
                                    <button type="submit" class="btn btn-cart">
                                        <i class="fa-solid fa-cart-shopping me-2"></i>Add to cart
                                    </button>
                                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-buy-now">
                                        <i class="fa-solid fa-bag-shopping me-2"></i>Buy now
                                    </a>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- DESCRIPTION -->

            <div class="product-description">

                <h4 class="fw-bold mb-4">
                    <i class="fa-solid fa-circle-info me-2 text-success"></i>
                    Product Description
                </h4>

                <p class="mb-0">
                    ${product.longDescription}
                </p>

            </div>
            <!-- FEEDBACK -->

            <div class="product-description feedback-section" id="ratings">
                <h4>Product Ratings</h4>

                <div class="feedback-summary">
                    <div class="feedback-score">
                        <div class="feedback-score-value">
                            <fmt:formatNumber value="${averageRating}" minFractionDigits="1" maxFractionDigits="1"/>
                            <small> out of 5</small>
                        </div>
                        <div class="feedback-score-stars">★★★★★</div>
                    </div>
                    <div class="feedback-filters" role="group" aria-label="Filter reviews">
                        <button type="button" class="feedback-filter active" data-filter="all">All</button>
                        <button type="button" class="feedback-filter" data-filter="5">5 Star (${ratingCounts[5]})</button>
                        <button type="button" class="feedback-filter" data-filter="4">4 Star (${ratingCounts[4]})</button>
                        <button type="button" class="feedback-filter" data-filter="3">3 Star (${ratingCounts[3]})</button>
                        <button type="button" class="feedback-filter" data-filter="2">2 Star (${ratingCounts[2]})</button>
                        <button type="button" class="feedback-filter" data-filter="1">1 Star (${ratingCounts[1]})</button>
                        <button type="button" class="feedback-filter" data-filter="comments">With Comments (${commentsCount})</button>
                    </div>
                </div>

                <c:if test="${canFeedback}">
                    <form action="${pageContext.request.contextPath}/feedback/add" method="post" class="feedback-form">
                        <input type="hidden" name="productId" value="${product.id}">
                        <input type="hidden" name="orderId" value="${orderId}">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label">Your rating</label>
                                <select name="rating" class="form-select" required>
                                    <option value="5">★★★★★ (5)</option>
                                    <option value="4">★★★★☆ (4)</option>
                                    <option value="3">★★★☆☆ (3)</option>
                                    <option value="2">★★☆☆☆ (2)</option>
                                    <option value="1">★☆☆☆☆ (1)</option>
                                </select>
                            </div>
                            <div class="col-md-7">
                                <label class="form-label">Your comment</label>
                                <textarea name="comment" rows="1" class="form-control" required></textarea>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-cart w-100">
                                    <i class="fa-solid fa-paper-plane me-1"></i> Submit
                                </button>
                            </div>
                        </div>
                    </form>
                </c:if>

                <div class="feedback-list">
                    <c:if test="${empty feedbacks}">
                        <div class="feedback-empty">No feedback yet.</div>
                    </c:if>

                    <c:forEach items="${feedbacks}" var="fb">
                        <article class="feedback-item"
                                 data-rating="${fb.rating}"
                                 data-has-comment="${not empty fb.comment}">
                            <div class="feedback-user">
                                <div class="feedback-avatar"><i class="fa-solid fa-user"></i></div>
                                <div>
                                    <div class="feedback-user-name">
                                        <c:out value="${not empty fb.customerFullName ? fb.customerFullName : fb.customerUsername}"/>
                                    </div>
                                    <div class="feedback-stars">
                                        <c:forEach begin="1" end="5" var="i">
                                            <i class="fa-solid fa-star ${i <= fb.rating ? '' : 'text-muted'}"></i>
                                        </c:forEach>
                                    </div>
                                    <div class="feedback-meta">
                                        <fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        <c:if test="${not empty fb.orderCode}"> · Verified purchase</c:if>
                                    </div>
                                </div>
                            </div>

                            <div class="feedback-comment">
                                <c:out value="${fb.comment}"/>
                            </div>

                            <c:if test="${not empty fb.adminResponse}">
                                <div class="seller-response">
                                    <strong>Seller's Response:</strong><br>
                                    <c:out value="${fb.adminResponse}"/>
                                </div>
                            </c:if>

                            <div class="feedback-actions"><i class="fa-regular fa-thumbs-up me-1"></i> Helpful</div>
                        </article>
                    </c:forEach>
                </div>
            </div>

        </div>

        <div class="modal fade cart-message-modal" id="cartMessageModal" tabindex="-1" aria-hidden="true">

            <div class="modal-dialog modal-dialog-centered">

                <div class="modal-content">

                    <div class="modal-header">

                        <h5 class="modal-title">

                            <span class="cart-modal-mark">
                                <i class="fa-solid fa-check"></i>
                            </span>

                            <span id="cartMessageTitle">
                                Cart Updated
                            </span>

                        </h5>

                        <button type="button"
                                class="btn-close"
                                data-bs-dismiss="modal">
                        </button>

                    </div>

                    <div class="modal-body cart-modal-text"
                         id="cartMessageText">

                        Item added to your cart.

                    </div>

                    <div class="modal-footer">

                        <a href="${pageContext.request.contextPath}/cart"
                           class="btn btn-outline-dark">

                            View Cart

                        </a>

                        <button type="button"
                                class="btn btn-cart"
                                data-bs-dismiss="modal">

                            Continue Shopping

                        </button>

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
                    var priceValue = document.getElementById('priceValue');
                    var quantityInput = form.querySelector('.quantity-input');

                    form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                    form.querySelector('.price-input').value = option.dataset.price || '0';

                    document.getElementById('stockText').textContent = option.dataset.stock;

                    if (priceValue) {
                        priceValue.textContent = option.dataset.price + ' đ';
                    }

                    if (quantityInput) {
                        quantityInput.max = option.dataset.stock;
                        if (parseInt(quantityInput.value, 10) > parseInt(option.dataset.stock, 10)) {
                            quantityInput.value = option.dataset.stock;
                        }
                    }

                    form.querySelectorAll('.variant-option').forEach(function (button) {
                        button.classList.toggle('active', button.dataset.variantId === option.value);
                    });

                }

                select.addEventListener('change', syncVariant);

                select.closest('.add-cart-form').querySelectorAll('.variant-option').forEach(function (button) {
                    button.addEventListener('click', function () {
                        select.value = button.dataset.variantId;
                        select.dispatchEvent(new Event('change'));
                    });
                });

                syncVariant();

            });

            document.querySelectorAll('.add-cart-form').forEach(function (form) {
                var quantityInput = form.querySelector('.quantity-input');
                var decreaseButton = form.querySelector('.quantity-decrease');
                var increaseButton = form.querySelector('.quantity-increase');

                if (!quantityInput) {
                    return;
                }

                function clampQuantity() {
                    var min = parseInt(quantityInput.min || '1', 10);
                    var max = parseInt(quantityInput.max || '999', 10);
                    var value = parseInt(quantityInput.value || min, 10);
                    quantityInput.value = Math.min(Math.max(value, min), max);
                }

                decreaseButton.addEventListener('click', function () {
                    quantityInput.value = parseInt(quantityInput.value || '1', 10) - 1;
                    clampQuantity();
                });

                increaseButton.addEventListener('click', function () {
                    quantityInput.value = parseInt(quantityInput.value || '1', 10) + 1;
                    clampQuantity();
                });

                quantityInput.addEventListener('change', clampQuantity);
            });

            document.querySelectorAll('.feedback-filter').forEach(function (filterButton) {
                filterButton.addEventListener('click', function () {
                    var filter = filterButton.dataset.filter;

                    document.querySelectorAll('.feedback-filter').forEach(function (button) {
                        button.classList.toggle('active', button === filterButton);
                    });

                    document.querySelectorAll('.feedback-item').forEach(function (item) {
                        var matches = filter === 'all'
                                || item.dataset.rating === filter
                                || (filter === 'comments' && item.dataset.hasComment === 'true');
                        item.hidden = !matches;
                    });
                });
            });

            var params = new URLSearchParams(window.location.search);

            if (params.has('cartAdded') || params.has('cartError')
                    || params.has('wishlistAdded') || params.has('wishlistError')) {

                var modalElement = document.getElementById('cartMessageModal');
                var isWishlist = params.has('wishlistAdded') || params.has('wishlistError');
                var isError = params.has('cartError') || params.has('wishlistError');

                modalElement.classList.toggle('is-error', isError);

                var icon = modalElement.querySelector('.cart-modal-mark i');

                if (icon) {

                    icon.className = isError
                            ? 'fa-solid fa-triangle-exclamation'
                            : 'fa-solid fa-check';

                }

                document.getElementById('cartMessageTitle').textContent =
                        isWishlist
                        ? (isError ? 'Could Not Update Wishlist' : 'Wishlist Updated')
                        : (isError ? 'Could Not Add Item' : 'Cart Updated');

                document.getElementById('cartMessageText').textContent =
                        params.has('wishlistAdded')
                        ? 'Đã thêm vào mục yêu thích.'
                        : params.has('wishlistError')
                        ? 'Không thể cập nhật mục yêu thích.'
                        : params.has('cartAdded')
                        ? 'Item added to your cart.'
                        : 'Could not add this item to your cart. Please check available stock.';

                new bootstrap.Modal(modalElement).show();

            }

        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>

    </body>

</html>
