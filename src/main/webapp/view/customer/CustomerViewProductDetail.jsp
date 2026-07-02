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

            body{
                background:#f5f5f5;
            }

            .detail-card{
                background:white;
                border-radius:8px;
                padding:30px;
                box-shadow:0 2px 8px rgba(0,0,0,.08);
            }

            .product-image{
                width:100%;
                height:500px;
                object-fit:cover;
                border-radius:8px;
                border:1px solid #eee;
            }

            .product-name{
                font-size:28px;
                font-weight:600;
                line-height:1.5;
            }

            .price{
                color:#ee4d2d;
                font-size:34px;
                font-weight:700;
                background:#fafafa;
                padding:15px;
                border-radius:6px;
            }

            .btn-cart{
                background:#fff5f1;
                border:1px solid #ee4d2d;
                color:#ee4d2d;
            }

            .btn-cart:hover{
                background:#ee4d2d;
                color:white;
            }

            .btn-buy-now{
                background:#ee4d2d;
                color:white;
                margin-left:10px;
            }

            .btn-buy-now:hover{
                background:#d73211;
                color:white;
            }

            .product-description{
                background:white;
                border-radius:8px;
                padding:25px;
                margin-top:20px;
                box-shadow:0 2px 8px rgba(0,0,0,.08);
            }

            .stock-text{
                font-size:15px;
                color:#666;
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

            .cart-message-modal .modal-body{
                padding:8px 28px 20px;
            }

            .cart-message-modal .modal-header{
                border:0;
                padding:28px 28px 12px;
                align-items:center;
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
                color:#172033;
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
                background:linear-gradient(135deg,#172033,#0f9b8e);
                box-shadow:0 12px 24px rgba(15,155,142,.24);
            }

            .cart-message-modal.is-error .cart-modal-mark{
                background:linear-gradient(135deg,#7f1d1d,#ef4444);
                box-shadow:0 12px 24px rgba(239,68,68,.22);
            }

            .cart-modal-text{
                color:#64748b;
                margin:0;
                font-size:1rem;
            }

            .cart-message-modal .modal-footer .btn{
                border-radius:10px;
                min-height:42px;
                padding:9px 16px;
                font-weight:700;
            }

            .cart-message-modal .modal-footer .btn-cart{
                background:#0f9b8e;
                border-color:#0f9b8e;
                color:#fff;
            }

            .cart-message-modal .modal-footer .btn-cart:hover{
                background:#0d8278;
                border-color:#0d8278;
                color:#fff;
            }

            @media(max-width:576px){
                .cart-message-modal .modal-body{
                    padding:24px 20px;
                }

                .cart-message-modal .modal-footer .btn{
                    width:100%;
                }
            }


        </style>

    </head>


    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container my-5">

            <div class="detail-card">

                <div class="row">

                    <!-- IMAGE -->

                    <div class="col-md-5">

                        <img
                            src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}"
                            class="product-image">

                    </div>

                    <!-- INFO -->

                    <div class="col-md-7">

                        <h1 class="product-name">
                            ${product.productName}
                        </h1>

                        <br>

                        <c:choose>

                            <c:when test="${not empty product.variants}">

                                <div class="price">
                                    ${product.variants[0].salePrice} đ
                                </div>

                            </c:when>

                            <c:otherwise>

                                <div class="price">
                                    Liên hệ
                                </div>

                            </c:otherwise>

                        </c:choose>

                        <div class="mt-4">

                            <c:if test="${not empty product.variants}">

                                <form action="${pageContext.request.contextPath}/cart"
                                      method="post"
                                      class="add-cart-form">

                                    <label class="form-label fw-semibold">
                                        Chọn phân loại
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

                                    <div class="mb-3 stock-text">

                                        Còn lại:
                                        <b id="stockText">

                                            ${product.variants[0].stockQuantity}

                                        </b>

                                        sản phẩm

                                    </div>

                                    <input type="hidden"
                                           name="productId"
                                           value="${product.id}" />

                                    <input type="hidden"
                                           name="productName"
                                           value="${product.productName}" />

                                    <input type="hidden"
                                           name="attributes"
                                           class="attributes-input"
                                           value="${product.variants[0].attributeDetails}" />

                                    <input type="hidden"
                                           name="price"
                                           class="price-input"
                                           value="${product.variants[0].salePrice}" />

                                    <input type="hidden"
                                           name="quantity"
                                           value="1" />

                                    <input type="hidden"
                                           name="imageUrl"
                                           value="${pageContext.request.contextPath}/uploads/${product.mainImageUrl}" />

                                    <button type="submit"
                                            class="btn btn-cart btn-lg">

                                        <i class="fa-solid fa-cart-shopping"></i>
                                        Thêm vào giỏ hàng

                                    </button>

                                    <a href="${pageContext.request.contextPath}/cart"
                                       class="btn btn-buy-now btn-lg">

                                        Mua ngay

                                    </a>

                                </form>

                            </c:if>

                        </div>

                    </div>

                </div>

            </div>

            <!-- DESCRIPTION -->

            <div class="product-description">

                <h4 class="fw-bold mb-3">
                    Mô tả sản phẩm
                </h4>

                <p>
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
                            <span id="cartMessageTitle">Cart Updated</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body cart-modal-text" id="cartMessageText">
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
        </script>


    </body>

</html>
