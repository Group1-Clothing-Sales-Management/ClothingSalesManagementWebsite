<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"
          uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>

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
                --detail-primary:#c65b3d;
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
                position:relative;
                display:flex;
                align-items:center;
                justify-content:center;
                width:100%;
                height:450px;
                background:#fafafa;
                overflow:hidden;
            }

            .detail-wishlist-form{
                position:absolute;
                top:14px;
                right:14px;
                z-index:4;
                margin:0;
            }

            .detail-wishlist-button{
                width:42px;
                height:42px;
                border:1px solid rgba(198,91,61,.28);
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                background:rgba(255,255,255,.96);
                color:var(--detail-primary);
                box-shadow:0 8px 20px rgba(37,33,30,.16);
                transition:.2s;
            }

            .detail-wishlist-button:hover,
            .detail-wishlist-button.is-active{
                background:var(--detail-primary);
                color:#fff;
                transform:scale(1.05);
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
                gap:10px;
            }

            /* Color */

            .color-option{
                min-width:90px;
                min-height:40px;
                padding:8px 18px;
                background:#fff;
                border:1px solid #d9d9d9;
                border-radius:4px;
                transition:.2s;
                cursor:pointer;
                font-size:14px;
            }
            .color-option:hover{
                border-color:var(--detail-primary);
            }
            .color-option.active{
                border:2px solid var(--detail-primary);
                color:var(--detail-primary);
                background:#fffaf8;
                box-shadow:0 0 0 1px var(--detail-primary);
            }
            /* Size */
            .size-option{
                width:48px;
                height:42px;
                border:1px solid #d9d9d9;
                background:#fff;
                border-radius:4px;
                cursor:pointer;
                transition:.2s;
                font-weight:600;
            }
            .size-option:hover{
                border-color:var(--detail-primary);
            }
            .size-option.active{
                border:2px solid var(--detail-primary);
                color:var(--detail-primary);
                background:#fffaf8;
                box-shadow:0 0 0 1px var(--detail-primary);
            }
            .color-option:disabled,
            .size-option:disabled{
                opacity:.42;
                color:#9ca3af;
                background:#f3f4f6;
                border-color:#e5e7eb;
                cursor:not-allowed;
                box-shadow:none;
            }
            .color-option:disabled:hover,
            .size-option:disabled:hover{
                border-color:#e5e7eb;
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
                color:#a9462d;
            }

            .btn-buy-now{
                margin-left:0;
                background:var(--detail-primary);
                border:1px solid var(--detail-primary);
                color:#fff;
            }

            .btn-buy-now:hover{
                background:#a9462d;
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
                border-radius:24px;
                box-shadow:0 20px 40px rgba(15, 23, 42, 0.06);
            }

            .feedback-section > h4{
                margin-bottom:18px!important;
                font-size:22px;
                font-weight:700!important;
            }

            .feedback-grid{
                display:grid;
                grid-template-columns:minmax(260px, 370px) 1fr;
                gap:24px;
            }

            /* Keep left panel fixed height; allow right (comments) to scroll */
            .feedback-grid{
                align-items:start;
            }

            .feedback-left{
                align-self:flex-start;
                /* prevent left from stretching with long comments */
            }

            .feedback-right{
                display:flex;
                flex-direction:column;
                gap:18px;
                /* limit total height of the right column */
                max-height:520px;
            }

            .feedback-right > .feedback-toolbar,
            .feedback-right > .review-composer{
                flex: 0 0 auto; /* keep toolbar and composer fixed */
            }

            .feedback-right > .feedback-list{
                flex: 1 1 auto;
                overflow:auto;
                padding-right:8px; /* room for scrollbar */
                display:flex;
                flex-direction:column;
                gap:12px;
            }

            .feedback-list{
                display:flex;
                flex-direction:column;
                gap:12px;
            }

            .feedback-left{
                display:flex;
                flex-direction:column;
                gap:20px;
                background:#f5f8ff;
                border-radius:24px;
                padding:24px;
            }

            .feedback-score-card{
                text-align:center;
                padding:22px 16px;
                background:#ffffff;
                border-radius:20px;
                box-shadow:0 16px 30px rgba(15, 23, 42, 0.05);
            }

            .feedback-score-card .feedback-score-value{
                font-size:54px;
                font-weight:800;
                color:#0f9b8e;
                line-height:1;
            }

            .feedback-score-card .feedback-score-stars{
                margin-top:12px;
                color:#f9b01d;
                font-size:20px;
                letter-spacing:2px;
            }

            .feedback-score-card .feedback-score-total{
                margin-top:10px;
                color:#65748b;
                font-size:14px;
            }

            .feedback-distribution{
                display:flex;
                flex-direction:column;
                gap:12px;
            }

            .distribution-row{
                display:grid;
                grid-template-columns:28px minmax(0, 1fr) 36px;
                gap:10px;
                align-items:center;
            }

            .distribution-label{
                font-weight:700;
                color:#1f2937;
            }

            .distribution-bar{
                height:10px;
                border-radius:999px;
                background:rgba(15, 23, 42, 0.08);
                overflow:hidden;
            }

            .distribution-fill{
                display:block;
                height:100%;
                width:0;
                background:linear-gradient(90deg, #0f9b8e, #2db1f0);
                border-radius:999px;
                transition:width .4s ease;
            }

            .distribution-count{
                color:#475569;
                font-size:13px;
                text-align:right;
            }

            .feedback-right{
                display:flex;
                flex-direction:column;
                gap:18px;
            }

            .feedback-toolbar{
                display:flex;
                justify-content:flex-end;
            }

            .feedback-filters{
                display:flex;
                flex-wrap:wrap;
                gap:10px;
            }

            .feedback-filter{
                min-width:110px;
                padding:10px 14px;
                border-radius:14px;
                border:1px solid rgba(15, 23, 42, 0.12);
                background:#ffffff;
                color:#0f172a;
                font-size:13px;
                font-weight:600;
                transition:all .2s ease;
            }

            .feedback-filter:hover,
            .feedback-filter.active{
                border-color:#0f9b8e;
                background:rgba(15, 155, 142, 0.08);
                color:#0f9b8e;
            }

            .feedback-list{
                margin-top:0;
            }

            .feedback-item{
                padding:26px 24px;
                border-radius:20px;
                background:#ffffff;
                box-shadow:0 20px 40px rgba(15, 23, 42, 0.04);
                margin-bottom:18px;
            }

            .feedback-user{
                display:flex;
                align-items:center;
                gap:14px;
            }

            .feedback-avatar{
                display:flex;
                align-items:center;
                justify-content:center;
                width:48px;
                height:48px;
                border-radius:50%;
                background:#eaf4ff;
                color:#0f9b8e;
                font-weight:700;
                font-size:16px;
            }

            .feedback-user-name{
                font-weight:700;
                color:#0f172a;
                font-size:14px;
            }

            .feedback-stars{
                margin-top:2px;
                color:#f9b01d;
                font-size:16px;
                letter-spacing:1px;
            }

            .feedback-meta{
                margin-top:4px;
                color:#64748b;
                font-size:12px;
            }

            .feedback-comment{
                margin-top:18px;
                color:#334155;
                font-size:14px;
                line-height:1.8;
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
                padding:26px;
                border:1px solid rgba(15, 23, 42, 0.08);
                background:#f8fbff;
                border-radius:20px;
                box-shadow:0 18px 40px rgba(15, 23, 42, 0.04);
            }

            .feedback-form .form-label{
                color:var(--detail-ink);
                font-size:13px;
                font-weight:600;
                letter-spacing:.02em;
                margin-bottom:.5rem;
                display:block;
            }

            .feedback-form .form-control,
            .feedback-form .form-select{
                border-radius:12px;
                border:1px solid rgba(15, 23, 42, 0.12);
                box-shadow:none;
                padding:.95rem 1rem;
            }

            .feedback-form .form-control:focus,
            .feedback-form .form-select:focus{
                border-color:#0f9b8e;
                box-shadow:0 0 0 .15rem rgba(15, 155, 142, 0.12);
            }

            .star-rating{
                display:flex;
                flex-direction:row-reverse;
                justify-content:flex-end;
                gap:4px;
                font-size:2.1rem;
                line-height:1;
            }

            .star-rating input{
                display:none;
            }

            .star-rating label{
                cursor:pointer;
                color:#dde1e7;
                transition: color .15s ease-in-out, transform .12s ease;
            }

            .star-rating label:hover,
            .star-rating label:hover ~ label,
            .star-rating input:checked ~ label{
                color:#f9b01d;
                transform:translateY(-1px) scale(1.05);
            }

            /* Review composer — single unified card */
            .review-composer{
                background:#ffffff;
                border:1px solid rgba(15, 23, 42, 0.08);
                border-radius:24px;
                box-shadow:0 16px 30px rgba(15, 23, 42, 0.04);
                padding:26px 28px;
            }

            .review-composer-head{
                display:flex;
                align-items:baseline;
                justify-content:space-between;
                gap:12px;
                margin-bottom:18px;
            }

            .review-composer-title{
                margin:0;
                font-size:17px;
                font-weight:700;
                color:#0f172a;
            }

            .review-composer-sub{
                margin:2px 0 0;
                font-size:13px;
                color:#64748b;
            }

            .review-composer-rating{
                display:flex;
                align-items:center;
                gap:14px;
                padding-bottom:20px;
                margin-bottom:20px;
                border-bottom:1px dashed rgba(15, 23, 42, 0.1);
            }

            .rating-mood{
                font-size:13px;
                font-weight:700;
                color:#f9b01d;
                letter-spacing:.2px;
            }

            .review-composer-body{
                position:relative;
            }

            .review-composer-body .form-label{
                display:none;
            }

            .feedback-form .feedback-textarea{
                min-height:110px;
                resize:vertical;
                border-radius:14px;
                padding:14px 16px;
                border:1px solid rgba(15, 23, 42, 0.12);
            }

            .review-composer-counter{
                position:absolute;
                right:14px;
                bottom:12px;
                font-size:11px;
                color:#9aa4b2;
                background:#fff;
                padding:0 4px;
                pointer-events:none;
            }

            .review-composer-foot{
                display:flex;
                justify-content:flex-end;
                margin-top:18px;
            }

            .feedback-form .btn-submit-custom{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:12px 26px;
                border-radius:14px;
                font-size:0.95rem;
                font-weight:700;
            }

            .feedback-form .btn-submit-custom i{
                font-size:.9em;
            }

            @media(max-width:767px){
                .review-composer{
                    padding:20px;
                }

                .review-composer-rating{
                    flex-wrap:wrap;
                }

                .review-composer-foot .btn-submit-custom{
                    width:100%;
                    justify-content:center;
                }
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

            /* Baby blue detail refresh */
            :root{
                --detail-ink:#1f2937;
                --detail-muted:#61708a;
                --detail-primary:#8AAAE5;
                --detail-primary-dark:#5f84d6;
                --detail-soft:#eef4ff;
                --detail-border:#d7e1f5;
                --detail-bg:#f7faff;
            }

            body{
                background:
                    linear-gradient(135deg, rgba(138,170,229,.12) 0 26%, transparent 26% 100%),
                    linear-gradient(180deg, #fff 0%, var(--detail-bg) 100%);
                color:var(--detail-ink);
                font-family:"Segoe UI", Arial, Helvetica, sans-serif;
            }

            .container.my-5{
                width:min(1220px, calc(100% - 32px));
                max-width:1220px;
                margin-top:36px!important;
            }

            .detail-card,
            .product-description,
            .feedback-section{
                border:1px solid rgba(138,170,229,.36);
                border-radius:8px;
                background:rgba(255,255,255,.97);
                box-shadow:0 18px 42px rgba(95,132,214,.13);
            }

            .detail-card{
                padding:20px;
            }

            .product-media-frame{
                height:500px;
                border:1px solid var(--detail-border);
                border-radius:8px;
                background:var(--detail-soft);
            }

            .product-image{
                border-radius:8px;
            }

            .detail-wishlist-button{
                width:46px;
                height:46px;
                border:1px solid rgba(138,170,229,.46);
                background:#fff;
                color:var(--detail-primary-dark);
                box-shadow:0 12px 26px rgba(95,132,214,.18);
            }

            .detail-wishlist-button:hover,
            .detail-wishlist-button.is-active{
                background:var(--detail-primary);
                color:#fff;
            }

            .media-thumb{
                border-color:var(--detail-border);
                border-radius:6px;
                background:#fff;
            }

            .media-thumb.active{
                border:2px solid var(--detail-primary-dark);
                box-shadow:0 0 0 3px rgba(138,170,229,.18);
            }

            .product-name{
                color:var(--detail-ink);
                font-size:25px;
                font-weight:850;
            }

            .product-tag{
                border-radius:6px;
                background:var(--detail-primary);
                font-weight:850;
            }

            .rating-score{
                color:#365b9f;
            }

            .price{
                border:1px solid rgba(138,170,229,.28);
                border-radius:8px;
                background:linear-gradient(180deg,#fff,#f7faff);
                color:#365b9f;
                font-weight:850;
            }

            .price-note{
                color:var(--detail-primary-dark);
                font-weight:700;
            }

            .detail-row + .detail-row{
                border-top-color:#edf2fb;
            }

            .service-line i{
                color:var(--detail-primary-dark);
            }

            .variant-option{
                border-color:var(--detail-border);
                border-radius:8px;
                color:var(--detail-ink);
                font-weight:700;
            }

            .variant-option:hover,
            .variant-option.active{
                border-color:var(--detail-primary);
                background:var(--detail-soft);
                color:#365b9f;
                box-shadow:inset 0 0 0 1px var(--detail-primary);
            }

            .quantity-control{
                overflow:hidden;
                border-color:var(--detail-border);
                border-radius:8px;
                box-shadow:0 8px 18px rgba(95,132,214,.08);
            }

            .quantity-control button:hover{
                background:var(--detail-soft);
                color:var(--detail-primary-dark);
            }

            .detail-actions .btn{
                min-height:50px;
                border-radius:8px;
                font-weight:850;
            }

            .btn-cart{
                border:1px solid var(--detail-primary);
                background:var(--detail-soft);
                color:#365b9f;
            }

            .btn-cart:hover{
                border-color:var(--detail-primary-dark);
                background:#dfeaff;
                color:#365b9f;
            }

            .btn-buy-now{
                border:1px solid var(--detail-primary);
                background:var(--detail-primary);
                color:#fff;
                box-shadow:0 12px 24px rgba(95,132,214,.22);
            }

            .btn-buy-now:hover{
                border-color:var(--detail-primary-dark);
                background:var(--detail-primary-dark);
                color:#fff;
            }

            .product-description h4,
            .feedback-section > h4{
                color:var(--detail-ink);
                font-weight:850!important;
            }

            .feedback-summary{
                border-color:rgba(138,170,229,.36);
                border-radius:8px;
                background:var(--detail-soft);
            }

            .feedback-score,
            .feedback-stars,
            .feedback-score-stars{
                color:#365b9f;
            }

            .feedback-filter{
                border-color:var(--detail-border);
                border-radius:8px;
                font-weight:700;
            }

            .feedback-filter:hover,
            .feedback-filter.active{
                border-color:var(--detail-primary);
                background:#fff;
                color:#365b9f;
            }

            .feedback-form,
            .feedback-item{
                border-color:#edf2fb;
            }

            .feedback-form .form-control,
            .feedback-form .form-select{
                border-color:var(--detail-border);
                border-radius:8px;
            }

            .feedback-form .form-control:focus,
            .feedback-form .form-select:focus{
                border-color:var(--detail-primary);
                box-shadow:0 0 0 3px rgba(138,170,229,.18);
            }

            .seller-response{
                border-radius:8px;
                background:var(--detail-soft);
            }

            .cart-message-modal .modal-content{
                box-shadow:0 24px 70px rgba(95,132,214,.24);
            }

            .cart-modal-mark{
                background:var(--detail-soft);
                color:var(--detail-primary-dark);
            }

            .cart-message-modal .modal-footer .btn-outline-dark{
                border-color:var(--detail-border)!important;
                border-radius:8px;
                color:#365b9f!important;
            }

            .cart-message-modal .modal-footer .btn-outline-dark:hover{
                background:var(--detail-soft)!important;
                color:#365b9f!important;
            }

            .cart-message-modal .modal-footer .btn-cart{
                border:1px solid var(--detail-primary)!important;
                background:var(--detail-primary)!important;
                color:#fff!important;
            }

            .cart-message-modal .modal-footer .btn-cart:hover{
                border-color:var(--detail-primary-dark)!important;
                background:var(--detail-primary-dark)!important;
            }

            @media(max-width:576px){
                .container.my-5{
                    width:min(100% - 20px, 1220px);
                    margin-top:24px!important;
                }

                .product-media-frame{
                    height:340px;
                }
            }
            .product-image-placeholder {
                width: 100%;
                height: 100%;
                min-height: 220px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 10px;
                background: #eef4ff;
                color: #71809b;
                text-align: center;
            }

            .product-image-placeholder i {
                font-size: 42px;
            }

            .product-image-placeholder span {
                font-size: 13px;
                font-weight: 600;
            }

            .product-image {
                width: 100%;
                height: 100%;
                object-fit: contain;
                background: #ffffff;
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
                            <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                  method="post"
                                  class="detail-wishlist-form">

                                <input type="hidden" name="productId" value="${product.id}">

                                <input type="hidden"
                                       name="variantId"
                                       class="wishlist-variant-id"
                                       value="">

                                <input type="hidden"
                                       name="wishlisted"
                                       value="${isWishlisted}">

                                <button type="submit"
                                        class="detail-wishlist-button ${isWishlisted ? 'is-active' : ''}"
                                        title="${isWishlisted ? 'Remove from wishlist' : 'Add to wishlist'}">

                                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                </button>
                            </form>

                            <c:set var="initialImageUrl" value="${product.mainImageUrl}"/>

                            <img id="mainProductImage"
                                 src="${not empty initialImageUrl ? pageContext.request.contextPath.concat('/media/product/').concat(initialImageUrl) : ''}"
                                 class="product-image"
                                 alt="<c:out value='${product.productName}'/>"
                                 data-default-image="${product.mainImageUrl}"
                                 style="${empty initialImageUrl ? 'display:none;' : ''}">

                            <div id="productImagePlaceholder"
                                 class="product-image-placeholder"
                                 style="${empty initialImageUrl ? 'display:flex;' : 'display:none;'}">
                                <i class="fa-regular fa-image"></i>
                                <span>Image not available</span>
                            </div>
                        </div>
                        <div class="media-thumbs" aria-label="Selected product image">
                            <img id="mainProductThumb"
                                 src="${not empty initialImageUrl ? pageContext.request.contextPath.concat('/media/product/').concat(initialImageUrl) : ''}"
                                 class="media-thumb active"
                                 alt="${product.productName} preview"
                                 style="${empty initialImageUrl ? 'display:none;' : ''}">
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
                            <span>
                                <span class="rating-score">Customer reviews</span>
                                <span class="rating-stars">★★★★★</span>
                            </span>
                            <span>${feedbacks.size()} Ratings</span>
                            <span>In stock</span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty product.variants}">
                                <div class="price">
                                    <span id="priceValue">Select color and size</span>
                                    <span class="price-note">Best price today</span>
                                </div>
                            </c:when>

                            <c:otherwise>
                                <div class="price">Contact</div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${not empty product.variants}">

                            <div class="detail-row">

                                <div class="detail-row-label">
                                    Shipping
                                </div>

                                <div>
                                    <div class="service-line">
                                        <i class="fa-solid fa-truck"></i>
                                        <span>Fast delivery to your address</span>
                                    </div>

                                    <div class="service-line mt-1">
                                        <i class="fa-solid fa-ticket"></i>
                                        <span>Free shipping for eligible orders</span>
                                    </div>
                                </div>

                            </div>

                            <div class="detail-row">

                                <div class="detail-row-label">
                                    Guarantee
                                </div>

                                <div class="service-line">
                                    <i class="fa-solid fa-shield-heart"></i>
                                    <span>15-day return support</span>
                                </div>

                            </div>

                            <!-- COLOR -->
                            <div class="detail-row">

                                <div class="detail-row-label">
                                    Color
                                </div>

                                <div class="variant-options">

                                    <c:set var="lastColor" value="" />

                                    <c:forEach items="${product.variants}" var="v">

                                        <c:if test="${lastColor != v.color}">

                                            <button type="button"
                                                    class="color-option"
                                                    data-color="${v.color}">

                                                ${v.color}

                                            </button>

                                            <c:set var="lastColor" value="${v.color}" />

                                        </c:if>

                                    </c:forEach>

                                </div>

                            </div>

                            <!-- SIZE -->
                            <div class="detail-row">

                                <div class="detail-row-label">
                                    Size
                                </div>

                                <div class="variant-options">

                                    <c:forEach items="${sizes}" var="size">

                                        <button
                                            type="button"
                                            class="size-option"
                                            data-size="${size}">

                                            ${size}

                                        </button>

                                    </c:forEach>

                                </div>

                            </div>

                            <div class="detail-row">

                                <div class="detail-row-label">
                                    Quantity
                                </div>

                                <div class="d-flex align-items-center gap-3 flex-wrap">

                                    <div class="quantity-control">

                                        <button type="button"
                                                class="quantity-decrease">

                                            −

                                        </button>

                                        <input type="number"
                                               class="quantity-input"
                                               value="1"
                                               min="1"
                                               max="1"
                                               disabled>

                                        <button type="button"
                                                class="quantity-increase">

                                            +

                                        </button>

                                    </div>

                                    <span class="stock-text">

                                        <i class="fa-solid fa-box-open me-1"></i>

                                        <b id="stockText">
                                            Select color and size
                                        </b>

                                    </span>

                                </div>

                            </div>

                            <div class="detail-actions">

                                <!-- ADD TO CART -->
                                <form action="${pageContext.request.contextPath}/cart"
                                      method="post"
                                      class="add-cart-form">

                                    <input type="hidden"
                                           name="variantId"
                                           class="variant-id-input"
                                           value="">

                                    <input type="hidden"
                                           name="productId"
                                           value="${product.id}">

                                    <input type="hidden"
                                           name="productName"
                                           value="${product.productName}">

                                    <input type="hidden"
                                           name="attributes"
                                           class="attributes-input"
                                           value="">
                                    <input type="hidden"
                                           name="price"
                                           class="price-input"
                                           value="">

                                    <input type="hidden"
                                           name="quantity"
                                           class="quantity-input-hidden"
                                           value="1">

                                    <input type="hidden"
                                           name="imageUrl"
                                           class="cart-image-input"
                                           value="${product.mainImageUrl}">

                                    <button type="submit"
                                            class="btn btn-cart"
                                            disabled>

                                        <i class="fa-solid fa-cart-shopping me-2"></i>
                                        Add to cart

                                    </button>

                                </form>

                                <!-- BUY NOW -->
                                <form action="${pageContext.request.contextPath}/customer/buy-now"
                                      method="post"
                                      class="buy-now-form">

                                    <input type="hidden"
                                           name="variantId"
                                           class="buy-now-variant-id"
                                           value="">

                                    <input type="hidden"
                                           name="quantity"
                                           class="buy-now-quantity"
                                           value="1">

                                    <button type="submit"
                                            class="btn btn-buy-now"
                                            disabled>

                                        <i class="fa-solid fa-bag-shopping me-2"></i>
                                        Buy Now

                                    </button>

                                </form>

                            </div>

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

                <c:if test="${not empty param.feedbackSuccess}">
                    <div class="alert alert-success">Cảm ơn bạn đã đánh giá sản phẩm!</div>
                </c:if>
                <c:if test="${param.feedbackError == 'permission'}">
                    <div class="alert alert-danger">Bạn không được phép đánh giá sản phẩm này.</div>
                </c:if>
                <c:if test="${param.feedbackError == 'rating'}">
                    <div class="alert alert-danger">Vui lòng chọn số sao hợp lệ.</div>
                </c:if>
                <c:if test="${param.feedbackError == 'create'}">
                    <div class="alert alert-danger">Có lỗi khi gửi đánh giá, vui lòng thử lại.</div>
                </c:if>
                <div class="feedback-grid">
                    <div class="feedback-left">
                        <div class="feedback-score-card">
                            <div class="feedback-score-value">
                                <fmt:formatNumber value="${averageRating}" minFractionDigits="1" maxFractionDigits="1"/>
                            </div>
                            <div class="feedback-score-stars">★★★★★</div>
                            <div class="feedback-score-total">
                                Dựa trên ${feedbacks.size()} lượt đánh giá
                            </div>
                        </div>
                        <div class="feedback-distribution">
                            <div class="distribution-row" data-count="${ratingCounts[5]}">
                                <span class="distribution-label">5</span>
                                <div class="distribution-bar"><span class="distribution-fill"></span></div>
                                <span class="distribution-count">${ratingCounts[5]}</span>
                            </div>
                            <div class="distribution-row" data-count="${ratingCounts[4]}">
                                <span class="distribution-label">4</span>
                                <div class="distribution-bar"><span class="distribution-fill"></span></div>
                                <span class="distribution-count">${ratingCounts[4]}</span>
                            </div>
                            <div class="distribution-row" data-count="${ratingCounts[3]}">
                                <span class="distribution-label">3</span>
                                <div class="distribution-bar"><span class="distribution-fill"></span></div>
                                <span class="distribution-count">${ratingCounts[3]}</span>
                            </div>
                            <div class="distribution-row" data-count="${ratingCounts[2]}">
                                <span class="distribution-label">2</span>
                                <div class="distribution-bar"><span class="distribution-fill"></span></div>
                                <span class="distribution-count">${ratingCounts[2]}</span>
                            </div>
                            <div class="distribution-row" data-count="${ratingCounts[1]}">
                                <span class="distribution-label">1</span>
                                <div class="distribution-bar"><span class="distribution-fill"></span></div>
                                <span class="distribution-count">${ratingCounts[1]}</span>
                            </div>
                        </div>
                    </div>

                    <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            try {
                                const rows = document.querySelectorAll('.distribution-row');
                                let total = 0;
                                rows.forEach(r => {
                                    total += parseInt(r.getAttribute('data-count')) || 0;
                                });
                                rows.forEach(r => {
                                    const c = parseInt(r.getAttribute('data-count')) || 0;
                                    const fill = r.querySelector('.distribution-fill');
                                    if (!fill)
                                        return;
                                    const pct = total > 0 ? (c / total) * 100 : 0;
                                    fill.style.width = pct + '%';
                                });
                            } catch (e) {
                                console.error(e);
                            }
                        });
                    </script>

                    <div class="feedback-right">
                        <div class="feedback-toolbar">
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
                                <input type="hidden" name="action" value="create">
                                <input type="hidden" name="productId" value="${product.id}">
                                <c:forEach items="${eligibleOrderDetails}" var="detail" begin="0" end="0">
                                    <input type="hidden" name="orderDetailId" value="${detail.id}">
                                </c:forEach>
                                <div class="review-composer">
                                    <div class="review-composer-head">
                                        <div>
                                            <h5 class="review-composer-title">Write a review</h5>
                                            <p class="review-composer-sub">Your feedback helps other shoppers decide.</p>
                                        </div>
                                    </div>
                                    <div class="review-composer-rating">
                                        <div class="star-rating" id="reviewStarRating">
                                            <input type="radio" id="rating-5" name="rating" value="5" checked>
                                            <label for="rating-5" title="5 stars">★</label>
                                            <input type="radio" id="rating-4" name="rating" value="4">
                                            <label for="rating-4" title="4 stars">★</label>
                                            <input type="radio" id="rating-3" name="rating" value="3">
                                            <label for="rating-3" title="3 stars">★</label>
                                            <input type="radio" id="rating-2" name="rating" value="2">
                                            <label for="rating-2" title="2 stars">★</label>
                                            <input type="radio" id="rating-1" name="rating" value="1">
                                            <label for="rating-1" title="1 star">★</label>
                                        </div>
                                        <span class="rating-mood" id="ratingMood">Excellent</span>
                                    </div>
                                    <div class="review-composer-body">
                                        <label class="form-label" for="reviewComment">Your comment</label>
                                        <textarea id="reviewComment" name="comment" rows="4" maxlength="500"
                                                  class="form-control feedback-textarea"
                                                  placeholder="What did you like or dislike? Share details that help other buyers."
                                                  required></textarea>
                                        <span class="review-composer-counter"><span id="commentCount">0</span>/500</span>
                                    </div>
                                    <div class="review-composer-foot">
                                        <button type="submit" class="btn btn-cart btn-submit-custom">
                                            <i class="fa-solid fa-paper-plane"></i> Submit review
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </c:if>

                        <div class="feedback-list">
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

                        const variants = [
            <c:forEach items="${product.variants}" var="v">
                            {
                                id:${v.id},
                                color: "${v.color}",
                                size: "${v.size}",
                                price:${v.salePrice},
                                stock:${v.stockQuantity},
                                imageUrl: "${v.imageUrl}",
                                imageVersion: "${not empty v.imageUpdatedAt ? v.imageUpdatedAt.time : 0}"
                            },
            </c:forEach>
                        ];
                        let selectedColor = null;
                        let selectedSize = null;

                        const colorButtons = document.querySelectorAll(".color-option");
                        const sizeButtons = document.querySelectorAll(".size-option");
                        const variantIdInput = document.querySelector(".variant-id-input");
                        const buyNowVariant = document.querySelector(".buy-now-variant-id");
                        const wishlistVariantInput = document.querySelector(".wishlist-variant-id");
                        const attributesInput = document.querySelector(".attributes-input");
                        const priceInput = document.querySelector(".price-input");
                        const cartImageInput = document.querySelector(".cart-image-input");
                        const stockText = document.getElementById("stockText");
                        const priceValue = document.getElementById("priceValue");
                        const quantityInput = document.querySelector(".quantity-input");
                        const increaseBtn = document.querySelector(".quantity-increase");
                        const decreaseBtn = document.querySelector(".quantity-decrease");
                        const addCartButton = document.querySelector(".add-cart-form button[type='submit']");
                        const buyNowButton = document.querySelector(".buy-now-form button[type='submit']");
                        const wishlistForm = document.querySelector(".detail-wishlist-form");
                        const mainProductImage = document.getElementById("mainProductImage");
                        const mainProductThumb = document.getElementById("mainProductThumb");
                        const productImagePlaceholder = document.getElementById("productImagePlaceholder");
                        const mediaBaseUrl = "${pageContext.request.contextPath}/media/product/";
                        const defaultProductImage = "${product.mainImageUrl}";

                        const hiddenQuantity = document.querySelector(".quantity-input-hidden");
                        const buyNowQuantity = document.querySelector(".buy-now-quantity");

                        function showDetailModal(title, text, isError, showCartLink) {
                            const modalElement = document.getElementById('cartMessageModal');

                            if (!modalElement || !window.bootstrap) {
                                alert(text);
                                return;
                            }

                            modalElement.classList.toggle('is-error', !!isError);

                            const icon = modalElement.querySelector('.cart-modal-mark i');
                            if (icon) {
                                icon.className = isError
                                        ? 'fa-solid fa-triangle-exclamation'
                                        : 'fa-solid fa-check';
                            }

                            const titleElement = document.getElementById('cartMessageTitle');
                            const textElement = document.getElementById('cartMessageText');
                            const cartLink = modalElement.querySelector('.modal-footer a');

                            if (titleElement) {
                                titleElement.textContent = title;
                            }
                            if (textElement) {
                                textElement.textContent = text;
                            }
                            if (cartLink) {
                                cartLink.classList.toggle('d-none', !showCartLink);
                            }

                            new bootstrap.Modal(modalElement).show();
                        }

                        if (wishlistForm) {
                            wishlistForm.addEventListener('submit', function (event) {
                                const wishlistedInput = wishlistForm.querySelector('input[name="wishlisted"]');
                                const alreadyWishlisted = wishlistedInput
                                        && wishlistedInput.value.toLowerCase() === 'true';

                                if (!alreadyWishlisted
                                        && wishlistVariantInput
                                        && !wishlistVariantInput.value) {
                                    event.preventDefault();
                                    showDetailModal(
                                            'Choose Variant',
                                            'Please select color and size before adding to wishlist.',
                                            true,
                                            false
                                    );
                                }
                            });
                        }

                        function buildImageUrl(fileName, version) {
                            if (!fileName) {
                                return "";
                            }

                            const cacheVersion = version && version !== "0"
                                    ? "?v=" + encodeURIComponent(version)
                                    : "";

                            return mediaBaseUrl + encodeURIComponent(fileName) + cacheVersion;
                        }

                        function showVariantImage(fileName, version) {
                            const selectedFile = fileName || defaultProductImage;

                            if (!mainProductImage || !selectedFile) {
                                if (mainProductImage) {
                                    mainProductImage.style.display = "none";
                                }
                                if (mainProductThumb) {
                                    mainProductThumb.style.display = "none";
                                }
                                if (productImagePlaceholder) {
                                    productImagePlaceholder.style.display = "flex";
                                }
                                return;
                            }

                            const selectedUrl = buildImageUrl(selectedFile, version);
                            mainProductImage.dataset.currentFile = selectedFile;
                            mainProductImage.src = selectedUrl;
                            mainProductImage.style.display = "block";

                            if (mainProductThumb) {
                                mainProductThumb.src = selectedUrl;
                                mainProductThumb.style.display = "block";
                            }

                            if (productImagePlaceholder) {
                                productImagePlaceholder.style.display = "none";
                            }
                        }

                        if (mainProductImage) {
                            mainProductImage.addEventListener("error", function () {
                                const currentFile = mainProductImage.dataset.currentFile || "";

                                if (defaultProductImage && currentFile !== defaultProductImage) {
                                    showVariantImage(defaultProductImage, "");
                                    return;
                                }

                                mainProductImage.style.display = "none";
                                if (mainProductThumb) {
                                    mainProductThumb.style.display = "none";
                                }
                                if (productImagePlaceholder) {
                                    productImagePlaceholder.style.display = "flex";
                                }
                            });
                        }

                        function updateQuantity() {
                            let qty = parseInt(quantityInput.value) || 1;
                            let max = parseInt(quantityInput.max) || 1;

                            if (qty < 1) {
                                qty = 1;
                            }
                            if (qty > max) {
                                qty = max;
                            }

                            quantityInput.value = qty;

                            if (hiddenQuantity) {
                                hiddenQuantity.value = qty;
                            }

                            if (buyNowQuantity) {
                                buyNowQuantity.value = qty;
                            }
                        }

                        function setSelectionReady(ready) {
                            quantityInput.disabled = !ready;
                            increaseBtn.disabled = !ready;
                            decreaseBtn.disabled = !ready;
                            addCartButton.disabled = !ready;
                            buyNowButton.disabled = !ready;
                        }

                        function getColorImageVariant(color) {
                            if (!color) {
                                return null;
                            }

                            const sameColorVariants = variants.filter(v =>
                                v.color === color
                            );

                            return sameColorVariants.find(v =>
                                v.imageUrl && v.imageUrl.trim() !== ""
                            ) || sameColorVariants[0] || null;
                        }

                        function showImageForCurrentSelection(exactVariant) {
                            if (exactVariant) {
                                const colorImageVariant = getColorImageVariant(
                                        exactVariant.color
                                );

                                const imageFile = exactVariant.imageUrl
                                        || (colorImageVariant ? colorImageVariant.imageUrl : "")
                                        || defaultProductImage;

                                const imageVersion = exactVariant.imageUrl
                                        ? exactVariant.imageVersion
                                        : (colorImageVariant ? colorImageVariant.imageVersion : "");

                                showVariantImage(imageFile, imageVersion);
                                return;
                            }

                            if (selectedColor) {
                                const colorImageVariant = getColorImageVariant(selectedColor);

                                if (colorImageVariant) {
                                    showVariantImage(
                                            colorImageVariant.imageUrl || defaultProductImage,
                                            colorImageVariant.imageVersion
                                    );
                                    return;
                                }
                            }

                            showVariantImage(defaultProductImage, "");
                        }

                        function clearResolvedVariant() {
                            variantIdInput.value = "";
                            buyNowVariant.value = "";

                            if (wishlistVariantInput) {
                                wishlistVariantInput.value = "";
                            }
                            if (attributesInput) {
                                attributesInput.value = "";
                            }
                            if (priceInput) {
                                priceInput.value = "";
                            }
                            if (cartImageInput) {
                                cartImageInput.value = defaultProductImage;
                            }

                            let selectionMessage = "Select color and size";

                            if (selectedColor && !selectedSize) {
                                selectionMessage = "Select size";
                            } else if (!selectedColor && selectedSize) {
                                selectionMessage = "Select color";
                            }

                            priceValue.textContent = selectionMessage;
                            stockText.textContent = selectionMessage;
                            quantityInput.value = 1;
                            quantityInput.max = 1;
                            setSelectionReady(false);
                            showImageForCurrentSelection(null);
                            updateQuantity();
                        }

                        function updateOptionAvailability() {
                            colorButtons.forEach(btn => {
                                const color = btn.dataset.color;
                                const isActive = color === selectedColor;

                                const isAvailable = !selectedSize || variants.some(v =>
                                    v.size === selectedSize && v.color === color
                                );

                                // Nút đang chọn luôn được phép bấm lại để bỏ chọn.
                                btn.disabled = !isActive && !isAvailable;
                                btn.classList.toggle("active", isActive);
                            });

                            sizeButtons.forEach(btn => {
                                const size = btn.dataset.size;
                                const isActive = size === selectedSize;

                                const isAvailable = !selectedColor || variants.some(v =>
                                    v.color === selectedColor && v.size === size
                                );

                                // Nút đang chọn luôn được phép bấm lại để bỏ chọn.
                                btn.disabled = !isActive && !isAvailable;
                                btn.classList.toggle("active", isActive);
                            });
                        }

                        function renderSelection() {
                            updateOptionAvailability();

                            if (!selectedColor || !selectedSize) {
                                clearResolvedVariant();
                                updateOptionAvailability();
                                return;
                            }

                            const variant = variants.find(v =>
                                v.color === selectedColor
                                    && v.size === selectedSize
                            );

                            if (!variant) {
                                clearResolvedVariant();
                                updateOptionAvailability();
                                return;
                            }

                            variantIdInput.value = variant.id;
                            buyNowVariant.value = variant.id;

                            if (wishlistVariantInput) {
                                wishlistVariantInput.value = variant.id;
                            }
                            if (attributesInput) {
                                attributesInput.value = variant.color + " - " + variant.size;
                            }
                            if (priceInput) {
                                priceInput.value = variant.price;
                            }
                            if (cartImageInput) {
                                const colorImageVariant = getColorImageVariant(variant.color);
                                cartImageInput.value = variant.imageUrl
                                        || (colorImageVariant ? colorImageVariant.imageUrl : "")
                                        || defaultProductImage;
                            }

                            showImageForCurrentSelection(variant);
                            stockText.textContent = variant.stock + " in stock";
                            priceValue.textContent =
                                    Number(variant.price).toLocaleString("vi-VN") + " ₫";
                            quantityInput.max = Math.max(1, Number(variant.stock) || 1);
                            quantityInput.value = 1;

                            setSelectionReady(Number(variant.stock) > 0);
                            updateQuantity();
                        }

                        increaseBtn.addEventListener("click", function () {
                            quantityInput.value = (parseInt(quantityInput.value) || 1) + 1;
                            updateQuantity();
                        });

                        decreaseBtn.addEventListener("click", function () {
                            quantityInput.value = (parseInt(quantityInput.value) || 1) - 1;
                            updateQuantity();
                        });

                        quantityInput.addEventListener("input", updateQuantity);

                        colorButtons.forEach(btn => {
                            btn.addEventListener("click", function () {
                                const clickedColor = btn.dataset.color;

                                if (selectedColor === clickedColor) {
                                    selectedColor = null;
                                } else {
                                    selectedColor = clickedColor;
                                }

                                renderSelection();
                            });
                        });

                        sizeButtons.forEach(btn => {
                            btn.addEventListener("click", function () {
                                const clickedSize = btn.dataset.size;

                                if (selectedSize === clickedSize) {
                                    selectedSize = null;
                                } else {
                                    selectedSize = clickedSize;
                                }

                                renderSelection();
                            });
                        });

                        renderSelection();

                        // ================= FEEDBACK FILTER =================

                        document.querySelectorAll('.feedback-filter').forEach(function (filterButton) {

                            filterButton.addEventListener('click', function () {

                                var filter = filterButton.dataset.filter;
                                document.querySelectorAll('.feedback-filter').forEach(function (button) {

                                    button.classList.toggle('active', button === filterButton);
                                });
                                document.querySelectorAll('.feedback-item').forEach(function (item) {

                                    var matches =
                                            filter === 'all'
                                            || item.dataset.rating === filter
                                            || (filter === 'comments'
                                                    && item.dataset.hasComment === 'true');
                                    item.hidden = !matches;
                                });
                            });
                        });
                        // ================= REVIEW COMPOSER =================

                        var ratingMoods = {
                            5: 'Excellent',
                            4: 'Very good',
                            3: 'Good',
                            2: 'Fair',
                            1: 'Poor'
                        };
                        var starRatingEl = document.getElementById('reviewStarRating');
                        var ratingMoodEl = document.getElementById('ratingMood');
                        if (starRatingEl && ratingMoodEl) {

                            var updateMood = function (value) {
                                ratingMoodEl.textContent = ratingMoods[value] || '';
                            };
                            starRatingEl.querySelectorAll('input[name="rating"]').forEach(function (input) {

                                input.addEventListener('change', function () {
                                    updateMood(input.value);
                                });
                                var label = starRatingEl.querySelector('label[for="' + input.id + '"]');
                                if (label) {

                                    label.addEventListener('mouseenter', function () {
                                        updateMood(input.value);
                                    });
                                }
                            });
                            starRatingEl.addEventListener('mouseleave', function () {
                                var checked = starRatingEl.querySelector('input[name="rating"]:checked');
                                if (checked)
                                    updateMood(checked.value);
                            });
                            var checkedInitial = starRatingEl.querySelector('input[name="rating"]:checked');
                            if (checkedInitial)
                                updateMood(checkedInitial.value);
                        }

                        var reviewComment = document.getElementById('reviewComment');
                        var commentCount = document.getElementById('commentCount');
                        if (reviewComment && commentCount) {

                            var updateCount = function () {
                                commentCount.textContent = reviewComment.value.length;
                            };
                            reviewComment.addEventListener('input', updateCount);
                            updateCount();
                        }

                        // ================= URL CLEAN =================

                        var params = new URLSearchParams(window.location.search);
                        var wishlistStatusParams = [
                            'wishlistAdded',
                            'wishlistRemoved',
                            'wishlistError'
                        ];
                        var hasWishlistStatus = wishlistStatusParams.some(function (key) {
                            return params.has(key);
                        });
                        if (hasWishlistStatus) {

                            wishlistStatusParams.forEach(function (key) {
                                params.delete(key);
                            });
                            var cleanUrl =
                                    window.location.pathname
                                    + (params.toString() ? '?' + params.toString() : '')
                                    + window.location.hash;
                            window.history.replaceState({}, '', cleanUrl);
                        }

                        // ================= CART MODAL =================

                        if (params.has('cartAdded') || params.has('cartError')) {

                            var modalElement =
                                    document.getElementById('cartMessageModal');
                            var isError =
                                    params.has('cartError');
                            modalElement.classList.toggle('is-error', isError);
                            var icon =
                                    modalElement.querySelector('.cart-modal-mark i');
                            if (icon) {

                                icon.className =
                                        isError
                                        ? 'fa-solid fa-triangle-exclamation'
                                        : 'fa-solid fa-check';
                            }

                            document.getElementById('cartMessageTitle').textContent =
                                    isError
                                    ? 'Could Not Add Item'
                                    : 'Cart Updated';
                            document.getElementById('cartMessageText').textContent =
                                    params.has('wishlistAdded')
                                    ? 'Added to your wishlist.'
                                    : params.has('wishlistRemoved')
                                    ? 'Removed from wishlist.'
                                    : params.has('wishlistError')
                                    ? 'Unable to update your wishlist.'
                                    : params.has('cartAdded')
                                    ? 'Item added to your cart.'
                                    : 'Could not add this item to your cart. Please check available stock.';
                            new bootstrap.Modal(modalElement).show();
                        }

        </script>
        <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>
</html>
