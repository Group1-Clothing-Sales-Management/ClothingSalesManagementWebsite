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
                background:#f4f8fb;
            }


            /* PRODUCT CARD */

            .detail-card{
                background:white;
                border-radius:20px;
                padding:30px;
                box-shadow:0 10px 25px rgba(0,0,0,.1);
            }


            .product-image{
                width:100%;
                height:500px;
                object-fit:cover;
                border-radius:20px;
            }


            .product-name{
                font-size:35px;
                font-weight:bold;
            }


            .price{
                color:#0f9b8e;
                font-size:32px;
                font-weight:bold;
            }


            .variant-box{
                border:1px solid #ddd;
                border-radius:10px;
                padding:10px;
                margin-bottom:10px;
            }


            .btn-cart{
                background:#172033;
                color:white;
            }


            .btn-cart:hover{
                background:#0f9b8e;
                color:white;
            }

            .detail-actions{
                display:flex;
                flex-wrap:wrap;
                gap:12px;
                align-items:center;
            }

            .btn-view-cart{
                background:#172033;
                border-color:#172033;
                color:white;
            }

            .btn-view-cart:hover{
                background:#0f9b8e;
                border-color:#0f9b8e;
                color:white;
            }

        </style>

    </head>


    <body>

        <c:set var="loggedIn"
               value="${not empty sessionScope.authUserId}"/>


        <div class="container my-5">


            <div class="detail-actions mb-4">
                <a 
                    href="${pageContext.request.contextPath}/home"
                    class="btn btn-secondary">

                    <i class="fa-solid fa-arrow-left"></i>
                    Back to Home

                </a>

                <a 
                    href="${pageContext.request.contextPath}/cart"
                    class="btn btn-view-cart">

                    <i class="fa-solid fa-cart-shopping"></i>
                    Xem giỏ hàng

                </a>
            </div>


            <div class="detail-card">


                <div class="row">


                    <!-- IMAGE -->

                    <div class="col-md-5">

                        <img 
                            src="${pageContext.request.contextPath}/uploads/${product.mainImageUrl}"
                            class="product-image">

                    </div>


                    <!-- INFO -->

                    <div class="col-md-7">


                        <h1 class="product-name">

                            ${product.productName}

                        </h1>


                        <hr>


                        <!-- PRICE -->

                        <c:choose>

                            <c:when test="${not empty product.variants}">

                                <div class="price">

                                    $ ${product.variants[0].salePrice}

                                </div>

                            </c:when>


                            <c:otherwise>

                                <div class="price">

                                    Contact

                                </div>

                            </c:otherwise>


                        </c:choose>


                        <br>


                        <h5>
                            Short Description
                        </h5>

                        <p>
                            ${product.shortDescription}
                        </p>


                        <h5>
                            Product Details
                        </h5>

                        <p>
                            ${product.longDescription}
                        </p>



                        <!-- VARIANTS -->


                        <h5 class="mt-4">
                            Available Variants
                        </h5>


                        <c:forEach 
                            items="${product.variants}"
                            var="v">


                            <div class="variant-box">


                                SKU:
                                <b>${v.sku}</b>

                                <br>

                                Thuộc tính:
                                ${v.attributeDetails}

                                <br>


                                Price:
                                $ ${v.salePrice}


                                <br>


                                Stock:
                                ${v.stockQuantity}


                            </div>


                        </c:forEach>



                        <!-- BUTTON -->


                        <div class="mt-4">
                            <c:choose>
                                <c:when test="${loggedIn and not empty product.variants}">
                                    <form action="${pageContext.request.contextPath}/cart" method="post" class="add-cart-form">
                                        <label class="form-label fw-semibold">Chọn size / màu</label>
                                        <select name="variantId" class="form-select mb-3 variant-select">
                                            <c:forEach items="${product.variants}" var="v">
                                                <option value="${v.id}"
                                                        data-price="${v.salePrice}"
                                                        data-attributes="${v.attributeDetails}">
                                                    ${v.attributeDetails} - $ ${v.salePrice} - Còn ${v.stockQuantity}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <input type="hidden" name="productId" value="${product.id}" />
                                        <input type="hidden" name="productName" value="${product.productName}" />
                                        <input type="hidden" name="attributes" class="attributes-input" value="${product.variants[0].attributeDetails}" />
                                        <input type="hidden" name="price" class="price-input" value="${product.variants[0].salePrice}" />
                                        <input type="hidden" name="quantity" value="1" />
                                        <input type="hidden" name="imageUrl" value="${pageContext.request.contextPath}/uploads/${product.mainImageUrl}" />
                                        <button type="submit" class="btn btn-cart btn-lg">
                                            <i class="fa-solid fa-cart-shopping"></i>
                                            Add To Cart
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a 
                                        href="${pageContext.request.contextPath}/customer/login"
                                        class="btn btn-cart btn-lg">

                                        <i class="fa-solid fa-cart-shopping"></i>

                                        Add To Cart

                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>


                    </div>


                </div>


            </div>


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
                        <button type="button" class="btn btn-cart" data-bs-dismiss="modal">Tiếp tục mua sắm</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.querySelectorAll('.variant-select').forEach(function(select) {
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


    </body>

</html>
