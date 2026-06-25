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

            body{
                background:#f5f7fb;
            }

            .page-header{
                background:white;
                padding:30px;
                border-radius:15px;
                margin-bottom:25px;
                box-shadow:0 2px 10px rgba(0,0,0,.05);
            }

            .product-card{
                border:none;
                border-radius:15px;
                overflow:hidden;
                transition:.25s;
                box-shadow:0 2px 10px rgba(0,0,0,.08);
            }

            .product-card:hover{
                transform:translateY(-5px);
                box-shadow:0 10px 25px rgba(0,0,0,.15);
            }

            .product-image{
                height:250px;
                object-fit:cover;
            }

            .price{
                color:#ee4d2d;
                font-size:20px;
                font-weight:bold;
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
                  class="card p-3 mb-4">

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

                        <button class="btn btn-primary w-100">

                            Search

                        </button>

                    </div>

                </div>

            </form>

            <div class="row">

                <c:forEach items="${products}" var="p">

                    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">

                        <div class="card product-card h-100">

                            <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">

                                <img
                                    src="${pageContext.request.contextPath}/uploads/product/${p.mainImageUrl}"
                                    class="card-img-top product-image"
                                    alt="${p.productName}">

                            </a>

                            <div class="card-body">

                                <h6 class="fw-bold">
                                    ${p.productName}
                                </h6>

                                <c:if test="${not empty p.variants}">

                                    <div class="price">

                                        ${p.variants[0].salePrice} đ

                                    </div>

                                    <small class="text-muted">

                                        ${p.variants[0].attributeDetails}

                                    </small>

                                </c:if>

                            </div>

                            <div class="card-footer bg-white border-0">

                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                   class="btn btn-primary w-100">

                                    View Detail

                                </a>

                            </div>

                        </div>

                    </div>

                </c:forEach>

            </div>

        </div>

        <jsp:include page="/view/customer/common/footer.jsp"/>

    </body>
</html>