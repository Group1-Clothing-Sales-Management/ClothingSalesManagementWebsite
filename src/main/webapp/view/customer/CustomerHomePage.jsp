<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>

    <head>
        <title>Clothing Sale</title>

        <style>

            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: Arial, sans-serif;
            }

            body {
                background: #f5f5f5;
            }


            /* ================= HEADER ================= */

            .header {
                background: #d70018;
                height: 70px;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .logo {
                color: white;
                font-size: 28px;
                font-weight: bold;
            }


            /* ================= CONTAINER ================= */

            .container {
                width: 90%;
                margin: 30px auto;
            }


            /* ================= SEARCH + FILTER ================= */

            .filter-box {
                background: white;
                padding: 20px;
                border-radius: 12px;
                margin-bottom: 25px;

                display: flex;
                align-items: center;
                gap: 15px;
                flex-wrap: wrap;

                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            }


            /* Input và Select chung */

            .filter-box input,
            .filter-box select {
                height: 42px;
                border: 1px solid #ddd;
                border-radius: 8px;
                padding: 0 15px;
                outline: none;
                font-size: 15px;
            }


            /* Ô tìm kiếm lớn hơn */

            .filter-box input[name="keyword"] {
                flex: 3;
            }


            /* Min Price, Max Price và Sort nhỏ hơn */

            .filter-box input[name="minPrice"],
            .filter-box input[name="maxPrice"],
            .filter-box select {
                flex: 1;
            }


            /* Focus khi chọn */

            .filter-box input:focus,
            .filter-box select:focus {
                border-color: #d70018;
            }


            /* ================= TITLE ================= */

            .title {
                margin-bottom: 20px;
                font-size: 28px;
                color: #222;
            }


            /* ================= PRODUCT LIST ================= */

            .product-list {
                display: grid;
                grid-template-columns: repeat(5, 1fr);
                gap: 20px;
            }


            /* ================= PRODUCT CARD ================= */

            .product-card {
                background: white;
                border-radius: 12px;
                padding: 15px;
                text-align: center;
                transition: 0.3s;
                cursor: pointer;
            }


            .product-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 0 15px rgba(0,0,0,0.2);
            }


            /* Hình ảnh sản phẩm */

            .product-card img {
                width: 100%;
                height: 230px;
                object-fit: cover;
            }


            /* Tên sản phẩm */

            .name {
                margin: 12px 0;
                font-size: 17px;
                height: 45px;
                overflow: hidden;
                color: #333;
            }


            /* Giá */

            .price {
                color: #d70018;
                font-size: 20px;
                font-weight: bold;
                min-height: 30px;
            }


            /* Button */

            .btn {
                margin-top: 12px;
                background: #d70018;
                color: white;
                border: none;
                padding: 10px 18px;
                border-radius: 8px;
                cursor: pointer;
                transition: 0.3s;
            }


            .btn:hover {
                background: black;
            }


            /* Không có sản phẩm */

            .empty-message {
                text-align: center;
                font-size: 22px;
                color: #777;
                margin-top: 50px;
            }


            /* ================= RESPONSIVE ================= */

            /* Tablet */
            @media (max-width: 1024px) {

                .product-list {
                    grid-template-columns: repeat(3, 1fr);
                }

            }


            /* Điện thoại */
            @media (max-width: 768px) {

                .filter-box {
                    flex-direction: column;
                }

                .filter-box input,
                .filter-box select {
                    width: 100%;
                }

                .product-list {
                    grid-template-columns: repeat(2, 1fr);
                }

            }


            /* Điện thoại nhỏ */
            @media (max-width: 480px) {

                .product-list {
                    grid-template-columns: 1fr;
                }

                .logo {
                    font-size: 22px;
                }

                .title {
                    font-size: 24px;
                }

            }
        </style>

    </head>


    <body>

        <!-- Header -->

        <div class="header">

            <div class="logo">
                Clothing Sale
            </div>

        </div>


        <!-- Main Content -->

        <div class="container">


            <!-- Filter -->

            <form action="${pageContext.request.contextPath}/home"
                  method="GET"
                  class="filter-box">


                <input
                    type="number"
                    name="minPrice"
                    value="${param.minPrice}"
                    placeholder="Minimum Price">


                <input
                    type="number"
                    name="maxPrice"
                    value="${param.maxPrice}"
                    placeholder="Maximum Price">


                <select name="sort" onchange="this.form.submit()">

                    <option value="">
                        Sort By
                    </option>


                    <option value="priceAsc"
                            ${param.sort == 'priceAsc' ? 'selected' : ''}>

                        Price: Low to High

                    </option>


                    <option value="priceDesc"
                            ${param.sort == 'priceDesc' ? 'selected' : ''}>

                        Price: High to Low

                    </option>


                    <option value="newest"
                            ${param.sort == 'newest' ? 'selected' : ''}>

                        Newest Products

                    </option>

                </select>


                <!-- Search -->

                <form action="${pageContext.request.contextPath}/home"
                      method="GET"
                      class="search-box">

                    <input
                        type="text"
                        name="keyword"
                        value="${param.keyword}"
                        placeholder="Search clothes, shoes, accessories...">

                </form>

            </form>
            <!-- Product Section -->

            <h1 class="title">
                Featured Products
            </h1>


            <c:if test="${not empty products}">

                <div class="product-list">

                    <c:forEach items="${products}" var="p">

                        <div class="product-card">

                            <!-- Product Image -->

                            <img 
                                src="${pageContext.request.contextPath}/uploads/${p.mainImageUrl}"
                                alt="${p.productName}">


                            <!-- Product Name -->

                            <h3 class="name">

                                ${p.productName}

                            </h3>


                            <!-- Product Price -->

                            <p class="price">

                                <c:choose>

                                    <c:when test="${not empty p.variants}">

                                        ${p.variants[0].salePrice} VND

                                    </c:when>


                                    <c:otherwise>

                                        Price not available

                                    </c:otherwise>

                                </c:choose>

                            </p>


                            <!-- Button -->

                            <button class="btn">

                                View Details

                            </button>


                        </div>

                    </c:forEach>

                </div>

            </c:if>


            <!-- No Product -->

            <c:if test="${empty products}">

                <div class="empty-message">

                    No products found.

                </div>

            </c:if>


        </div>


    </body>

</html>