<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html>
    <head>
        <title>My Wishlist</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

        <style>
            :root{
                --navy:#172033;
                --teal:#0f9b8e;
                --bg:#f4f8fb;
                --muted:#64748b;
                --danger:#dc2626;
            }

            body{
                background:
                    radial-gradient(circle at top left, rgba(15,155,142,.08), transparent 30%),
                    radial-gradient(circle at right top, rgba(23,32,51,.08), transparent 25%),
                    var(--bg);
                font-family:'Segoe UI',sans-serif;
                color:#1f2937;
            }

            .wishlist-header,
            .empty-state{
                background:#fff;
                border-radius:20px;
                box-shadow:0 15px 40px rgba(0,0,0,.08);
            }

            .wishlist-header{
                padding:32px;
            }

            .wishlist-header h2{
                margin:0;
                color:var(--navy);
                font-weight:800;
            }

            .wishlist-count{
                display:inline-flex;
                align-items:center;
                gap:8px;
                border-radius:999px;
                padding:8px 14px;
                background:rgba(15,155,142,.1);
                color:var(--teal);
                font-weight:700;
            }

            .wishlist-card{
                border:1px solid #e5e7eb;
                border-radius:18px;
                overflow:hidden;
                background:#fff;
                box-shadow:0 12px 30px rgba(23,32,51,.08);
            }

            .wishlist-image{
                width:100%;
                height:230px;
                object-fit:cover;
                background:#e5e7eb;
            }

            .wishlist-title{
                color:var(--navy);
                font-size:1.05rem;
                font-weight:800;
            }

            .wishlist-price{
                color:var(--teal);
                font-size:1.45rem;
                font-weight:800;
            }

            .variant-note{
                min-height:42px;
                color:var(--muted);
            }

            .form-select{
                border-radius:12px;
                padding:11px;
            }

            .form-select:focus{
                border-color:var(--teal);
                box-shadow:0 0 0 .25rem rgba(15,155,142,.15);
            }

            .btn-main{
                background:linear-gradient(135deg,var(--navy),var(--teal));
                border:0;
                color:#fff;
                font-weight:700;
                border-radius:12px;
            }

            .btn-main:hover{
                color:#fff;
                opacity:.92;
            }

            .btn-soft{
                border:1px solid #e5e7eb;
                border-radius:12px;
                color:var(--navy);
                font-weight:700;
            }

            .btn-soft:hover{
                background:#f8fafc;
                color:var(--teal);
            }

            .empty-state{
                padding:58px 24px;
                text-align:center;
            }

            .empty-icon{
                width:70px;
                height:70px;
                border-radius:22px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                background:rgba(15,155,142,.1);
                color:var(--teal);
                font-size:30px;
            }
        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <div class="container my-5">
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

                                                    <div class="d-flex flex-wrap gap-2">
                                                        <button type="submit"
                                                                class="btn btn-soft flex-fill">
                                                            <i class="fa-solid fa-rotate me-1"></i>
                                                            Update
                                                        </button>

                                                        <button type="submit"
                                                                formaction="${pageContext.request.contextPath}/cart"
                                                                formmethod="post"
                                                                class="btn btn-main flex-fill wishlist-cart-button">
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
        </div>

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
                    select.addEventListener('change', syncVariant);
                    syncVariant();
                }
            });
        </script>

        <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>
</html>
