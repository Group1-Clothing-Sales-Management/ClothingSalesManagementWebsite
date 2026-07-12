<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"
          uri="http://java.sun.com/jsp/jstl/core"%>

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

        </style>

    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container my-5">

            <div class="detail-card">

                <div class="row align-items-center g-5">

                    <!-- IMAGE -->

                    <div class="col-lg-5 col-md-6">

                        <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                             class="product-image"
                             alt="${product.productName}">

                    </div>

                    <!-- INFO -->

                    <div class="col-lg-7 col-md-6">

                        <h1 class="product-name mb-3">
                            ${product.productName}
                        </h1>

                        <c:choose>

                            <c:when test="${not empty product.variants}">

                                <div class="price mb-4">
                                    ${product.variants[0].salePrice} đ
                                </div>

                            </c:when>

                            <c:otherwise>

                                <div class="price mb-4">
                                    Contact
                                </div>

                            </c:otherwise>

                        </c:choose>

                        <c:if test="${not empty product.variants}">

                            <form action="${pageContext.request.contextPath}/cart"
                                  method="post"
                                  class="add-cart-form">

                                <label class="form-label fw-bold mb-2">
                                    <i class="fa-solid fa-layer-group me-2 text-success"></i>
                                    Choose Variant
                                </label>

                                <select name="variantId"
                                        class="form-select mb-3 variant-select">

                                    <c:forEach items="${product.variants}" var="v">

                                        <option value="${v.id}"
                                                data-price="${v.salePrice}"
                                                data-stock="${v.stockQuantity}"
                                                data-attributes="${v.attributeDetails}">

                                            ${v.attributeDetails}

                                        </option>

                                    </c:forEach>

                                </select>

                                <div class="stock-text mb-4">

                                    <i class="fa-solid fa-box-open me-2"></i>

                                    Available:
                                    <b id="stockText">
                                        ${product.variants[0].stockQuantity}
                                    </b>
                                    products

                                </div>

                                <input type="hidden" name="productId" value="${product.id}">
                                <input type="hidden" name="productName" value="${product.productName}">
                                <input type="hidden" name="attributes" class="attributes-input"
                                       value="${product.variants[0].attributeDetails}">
                                <input type="hidden" name="price" class="price-input"
                                       value="${product.variants[0].salePrice}">
                                <input type="hidden" name="quantity" value="1">
                                <input type="hidden" name="imageUrl"
                                       value="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}">

                                <div class="d-flex flex-wrap gap-3 mt-4">

                                    <button type="submit"
                                            class="btn btn-cart btn-lg px-4">

                                        <i class="fa-solid fa-cart-shopping me-2"></i>
                                        Add To Cart

                                    </button>

                                    <a href="${pageContext.request.contextPath}/cart"
                                       class="btn btn-buy-now btn-lg px-4">

                                        <i class="fa-solid fa-bag-shopping me-2"></i>
                                        Buy Now

                                    </a>

                                    <button type="submit"
                                            formaction="${pageContext.request.contextPath}/wishlist/add"
                                            formmethod="post"
                                            class="btn btn-wishlist btn-lg px-4">

                                        <i class="fa-solid fa-heart me-2"></i>
                                        Add To Wishlist

                                    </button>

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

                    form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                    form.querySelector('.price-input').value = option.dataset.price || '0';

                    document.getElementById('stockText').textContent = option.dataset.stock;

                    document.querySelector('.price').innerHTML = option.dataset.price + ' đ';

                }

                select.addEventListener('change', syncVariant);

                syncVariant();

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
