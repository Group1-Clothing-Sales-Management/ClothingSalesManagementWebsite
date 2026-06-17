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

        </style>

    </head>


    <body>


        <div class="container my-5">


            <a 
                href="${pageContext.request.contextPath}/home"
                class="btn btn-secondary mb-4">

                <i class="fa-solid fa-arrow-left"></i>
                Back to Home

            </a>


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


                                Price:
                                $ ${v.salePrice}


                                <br>


                                Stock:
                                ${v.stockQuantity}


                            </div>


                        </c:forEach>



                        <!-- BUTTON -->


                        <div class="mt-4">


                            <a 
                                href="${pageContext.request.contextPath}/customer/login"
                                class="btn btn-cart btn-lg">

                                <i class="fa-solid fa-cart-shopping"></i>

                                Add To Cart

                            </a>


                        </div>


                    </div>


                </div>


            </div>


        </div>


    </body>

</html>