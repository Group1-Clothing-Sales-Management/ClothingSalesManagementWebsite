<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>My Wishlist</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

        <style>
            :root {
                --wishlist-primary:#c65b3d;
                --wishlist-primary-dark:#a9462d;
                --wishlist-primary-soft:#fff3ed;
                --wishlist-ink:#222;
                --wishlist-muted:#6b7280;
                --wishlist-line:#e7e7e7;
            }

            * { box-sizing:border-box; }

            body {
                min-height:100vh;
                margin:0;
                background:#f5f5f5;
                color:var(--wishlist-ink);
                font-family:Arial, Helvetica, sans-serif;
                font-size:14px;
            }

            .wishlist-page {
                width:min(1200px, calc(100% - 32px));
                max-width:none;
                padding-top:24px;
                padding-bottom:48px;
            }

            .wishlist-header,
            .empty-state {
                background:#fff;
                box-shadow:0 1px 2px rgba(0,0,0,.05);
            }

            .wishlist-header {
                min-height:96px;
                padding:22px 24px;
                border-bottom:2px solid var(--wishlist-primary);
            }

            .wishlist-header h2 {
                margin:0;
                color:var(--wishlist-ink);
                font-size:24px;
                font-weight:600;
            }

            .wishlist-header h2 i { color:var(--wishlist-primary) !important; }

            .wishlist-count {
                display:inline-flex;
                align-items:center;
                gap:8px;
                min-height:34px;
                padding:6px 12px;
                border:1px solid #f0c8bc;
                border-radius:2px;
                background:var(--wishlist-primary-soft);
                color:var(--wishlist-primary-dark);
                font-weight:700;
            }

            .wishlist-card {
                border:1px solid var(--wishlist-line);
                border-radius:0;
                overflow:hidden;
                background:#fff;
                box-shadow:0 1px 2px rgba(0,0,0,.05);
                transition:border-color .2s, box-shadow .2s;
            }

            .wishlist-card:hover {
                border-color:#e1b2a5;
                box-shadow:0 4px 12px rgba(0,0,0,.08);
            }

            .wishlist-image {
                width:100%;
                height:230px;
                object-fit:cover;
                background:#fafafa;
            }

            .wishlist-title {
                color:var(--wishlist-ink);
                font-size:16px;
                font-weight:600;
            }

            .wishlist-price {
                color:var(--wishlist-primary);
                font-size:20px;
                font-weight:500;
            }

            .variant-note {
                min-height:42px;
                color:var(--wishlist-muted);
            }

            .form-select {
                min-height:42px;
                border-color:#ddd;
                border-radius:2px;
                padding:9px 11px;
                font-size:14px;
            }

            .form-select:focus {
                border-color:var(--wishlist-primary);
                box-shadow:0 0 0 .2rem rgba(198,91,61,.12);
            }

            .btn-main {
                border:1px solid var(--wishlist-primary);
                border-radius:2px;
                background:var(--wishlist-primary);
                color:#fff;
                font-weight:600;
            }

            .btn-main:hover {
                border-color:var(--wishlist-primary-dark);
                background:var(--wishlist-primary-dark);
                color:#fff;
            }

            .btn-soft {
                border:1px solid #ddd;
                border-radius:2px;
                background:#fff;
                color:#555;
                font-weight:600;
            }

            .btn-soft:hover {
                border-color:var(--wishlist-primary);
                color:var(--wishlist-primary-dark);
            }

            .empty-state {
                padding:58px 24px;
                text-align:center;
            }

            .empty-icon {
                width:64px;
                height:64px;
                border-radius:50%;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                background:var(--wishlist-primary-soft);
                color:var(--wishlist-primary);
                font-size:24px;
            }

            .alert { border-radius:2px; }

            @media (max-width:768px) {
                .wishlist-page { width:100%; padding-top:12px; }
                .wishlist-header { padding:18px 16px; }
                .wishlist-header h2 { font-size:21px; }
                .wishlist-image { height:210px; }
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="container wishlist-page">
            <div class="wishlist-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2>
                        <i class="fa-solid fa-heart me-2 text-danger"></i>
                        My Wishlist
                    </h2>
                    <p class="text-muted mb-0 mt-2">
                        Save products you like and choose the variant when you are ready.
                    </p>
                </div>

                <span class="wishlist-count">
                    <i class="fa-solid fa-heart"></i>
                    ${fn:length(wishlistItems)} item(s)
                </span>
            </div>

            <c:if test="${not empty wishlistMessage}">
                <div class="alert alert-${wishlistMessageType} alert-dismissible fade show" role="alert">
                    ${wishlistMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty wishlistItems}">
                    <div class="empty-state">
                        <div class="empty-icon mb-3">
                            <i class="fa-regular fa-heart"></i>
                        </div>
                        <h4 class="fw-bold">Your wishlist is empty</h4>
                        <p class="text-muted mb-4">
                            Browse products and tap the heart button to save your favorites.
                        </p>
                        <a href="${pageContext.request.contextPath}/products"
                           class="btn btn-main px-4 py-2">
                            <i class="fa-solid fa-store me-2"></i>
                            Shop Products
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach items="${wishlistItems}" var="item">
                            <div class="col-lg-4 col-md-6">
                                <div class="wishlist-card h-100">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}">
                                        <c:choose>
                                            <c:when test="${not empty item.mainImageUrl}">
                                                <img src="${pageContext.request.contextPath}/uploads/product/${item.mainImageUrl}"
                                                     class="wishlist-image"
                                                     alt="${item.productName}">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="wishlist-image d-flex align-items-center justify-content-center">
                                                    <i class="fa-solid fa-shirt fs-1 text-secondary"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>

                                    <div class="p-4">
                                        <div class="d-flex justify-content-between gap-3 mb-2">
                                            <div class="wishlist-title text-truncate">
                                                ${item.productName}
                                            </div>
                                            <form action="${pageContext.request.contextPath}/wishlist/delete"
                                                  method="post"
                                                  class="m-0">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <button type="submit"
                                                        class="btn btn-link text-danger p-0"
                                                        title="Remove from wishlist">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>

                                        <div class="wishlist-price mb-1">
                                            <c:choose>
                                                <c:when test="${not empty item.salePrice}">
                                                    <fmt:formatNumber value="${item.salePrice}" pattern="#,##0"/> &#8363;
                                                </c:when>
                                                <c:otherwise>
                                                    Contact
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="variant-note small mb-3">
                                            <i class="fa-solid fa-layer-group me-1"></i>
                                            ${item.attributeDetails}
                                            <br>
                                            <span class="${item.available ? 'text-success' : 'text-danger'}">
                                                <c:choose>
                                                    <c:when test="${item.available}">
                                                        In stock: ${item.stockQuantity}
                                                    </c:when>
                                                    <c:otherwise>
                                                        Currently unavailable
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <c:choose>
                                            <c:when test="${not empty item.availableVariants}">
                                                <form action="${pageContext.request.contextPath}/wishlist/update"
                                                      method="post"
                                                      class="wishlist-form"
                                                      data-product-active="${item.productStatus}">

                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                    <input type="hidden" name="productName" value="${item.productName}">
                                                    <input type="hidden" name="attributes" class="attributes-input"
                                                           value="${item.attributeDetails}">
                                                    <input type="hidden" name="price" class="price-input"
                                                           value="${item.salePrice}">
                                                    <input type="hidden" name="quantity" value="1">
                                                    <input type="hidden" name="imageUrl"
                                                           value="${pageContext.request.contextPath}/uploads/product/${item.mainImageUrl}">

                                                    <label class="form-label fw-bold">Variant</label>
                                                    <select name="variantId"
                                                            class="form-select mb-3 variant-select">
                                                        <c:forEach items="${item.availableVariants}" var="variant">
                                                            <option value="${variant.id}"
                                                                    data-price="${variant.salePrice}"
                                                                    data-stock="${variant.stockQuantity}"
                                                                    data-attributes="${variant.attributeDetails}"
                                                                    ${variant.id == item.variantId ? 'selected' : ''}>
                                                                ${variant.attributeDetails}
                                                                -
                                                                <fmt:formatNumber value="${variant.salePrice}" pattern="#,##0"/> &#8363;
                                                            </option>
                                                        </c:forEach>
                                                    </select>

                                                    <div>
                                                        <button type="submit"
                                                                formaction="${pageContext.request.contextPath}/cart"
                                                                formmethod="post"
                                                                class="btn btn-main w-100 wishlist-cart-button">
                                                            <i class="fa-solid fa-cart-plus me-1"></i>
                                                            Add To Cart
                                                        </button>
                                                    </div>
                                                </form>
                                            </c:when>

                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}"
                                                   class="btn btn-soft w-100">
                                                    <i class="fa-solid fa-eye me-1"></i>
                                                    View Details
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.querySelectorAll('.wishlist-form').forEach(function (form) {
                var select = form.querySelector('.variant-select');
                var cartButton = form.querySelector('.wishlist-cart-button');

                function syncVariant() {
                    var option = select.options[select.selectedIndex];
                    var stock = parseInt(option.dataset.stock || '0', 10);
                    var productActive = (form.dataset.productActive || '').toUpperCase() === 'ACTIVE';

                    form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                    form.querySelector('.price-input').value = option.dataset.price || '0';

                    if (cartButton) {
                        cartButton.disabled = !productActive || stock <= 0;
                    }
                }

                if (select) {
                    select.addEventListener('change', function () {
                        syncVariant();
                        form.requestSubmit();
                    });
                    syncVariant();
                }
            });
        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>
</html>
