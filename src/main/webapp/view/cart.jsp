<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    java.util.Collection items = (java.util.Collection) request.getAttribute("items");
    java.util.Map variantsByProductId = (java.util.Map) request.getAttribute("variantsByProductId");
    String ctx = request.getContextPath();
    java.text.NumberFormat currencyFormat = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giỏ hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --cart-ink:#0f172a;
            --cart-muted:#64748b;
            --cart-line:#e2e8f0;
            --cart-soft:#f8fafc;
            --cart-accent:#2563eb;
            --cart-danger:#dc2626;
            --cart-success:#047857;
        }

        * { box-sizing:border-box; }

        body {
            min-height:100vh;
            margin:0;
            background:linear-gradient(180deg, #f5f7fb 0%, #ffffff 42%, #f8fafc 100%);
            color:var(--cart-ink);
            font-family:system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .navbar {
            border-bottom:1px solid rgba(226, 232, 240, .9);
            box-shadow:none!important;
        }

        .navbar-brand {
            color:var(--cart-ink);
        }

        .navbar .btn,
        .empty-state .btn,
        .checkout-btn,
        .continue-link {
            border-radius:8px;
            font-weight:700;
        }

        .cart-page {
            max-width:1180px;
        }

        .page-heading {
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:1rem;
            margin-bottom:1.4rem;
        }

        .page-kicker {
            color:var(--cart-accent);
            font-size:.9rem;
            font-weight:700;
            margin-bottom:.25rem;
        }

        .cart-title {
            margin:0;
            font-size:2rem;
            line-height:1.2;
            font-weight:800;
        }

        .page-subtitle {
            color:var(--cart-muted);
            margin:.45rem 0 0;
        }

        .alert {
            border:1px solid #bfdbfe;
            border-radius:8px;
            background:#eff6ff;
            color:#1e40af;
            overflow:hidden;
            transition:opacity .28s ease, transform .28s ease, max-height .28s ease,
                       margin .28s ease, padding .28s ease, border-width .28s ease;
        }

        .alert.is-hiding {
            max-height:0;
            margin-top:0;
            margin-bottom:0;
            padding-top:0;
            padding-bottom:0;
            border-width:0;
            opacity:0;
            transform:translateY(-6px);
        }

        .empty-state {
            max-width:540px;
            margin:5rem auto;
            padding:2.25rem;
            text-align:center;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:8px;
            box-shadow:0 20px 50px rgba(15, 23, 42, .07);
        }

        .empty-mark {
            width:70px;
            height:70px;
            margin:0 auto 1rem;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            background:#eff6ff;
            color:var(--cart-accent);
            font-weight:800;
            font-size:1.35rem;
        }

        .cart-list {
            display:grid;
            gap:1rem;
        }

        .cart-item {
            position:relative;
            padding:1.15rem 1.15rem 1.15rem 3.75rem;
            border:1px solid var(--cart-line);
            border-radius:8px;
            background:#fff;
            box-shadow:0 14px 35px rgba(15, 23, 42, .06);
            transition:border-color .18s ease, box-shadow .18s ease, transform .18s ease;
        }

        .cart-item:hover {
            border-color:#bfdbfe;
            box-shadow:0 18px 45px rgba(37, 99, 235, .11);
            transform:translateY(-1px);
        }

        .cart-row {
            gap:1rem;
            align-items:flex-start!important;
        }

        .cart-img {
            width:108px;
            height:132px;
            flex:0 0 auto;
            object-fit:cover;
            border:1px solid #e5e7eb;
            border-radius:8px;
            background:#e5e7eb;
        }

        .cart-remove-form {
            position:absolute;
            top:.8rem;
            left:.8rem;
            z-index:2;
        }

        .cart-remove-btn {
            position:relative;
            width:34px;
            height:34px;
            border-radius:50%;
            padding:0;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            appearance:none;
            border:1px solid #fecdd3;
            background:#fff;
            color:#ef4444;
            box-shadow:0 8px 18px rgba(220, 38, 38, .12);
            cursor:pointer;
            transition:background .18s ease, border-color .18s ease, color .18s ease,
                       box-shadow .18s ease, transform .18s ease;
        }

        .cart-remove-btn::before,
        .cart-remove-btn::after {
            content:"";
            position:absolute;
            width:13px;
            height:2px;
            border-radius:999px;
            background:currentColor;
        }

        .cart-remove-btn::before {
            transform:rotate(45deg);
        }

        .cart-remove-btn::after {
            transform:rotate(-45deg);
        }

        .cart-remove-btn:hover,
        .cart-remove-btn:focus {
            background:var(--cart-danger);
            border-color:var(--cart-danger);
            color:#fff;
            box-shadow:0 10px 22px rgba(220, 38, 38, .22);
            transform:translateY(-1px);
        }

        .cart-remove-btn:focus-visible {
            outline:none;
            box-shadow:0 0 0 .22rem rgba(220, 38, 38, .16),
                       0 10px 22px rgba(220, 38, 38, .22);
        }

        .product-summary {
            min-width:0;
        }

        .product-top {
            display:grid;
            grid-template-columns:minmax(0, 1fr) auto;
            gap:1rem;
            align-items:start;
        }

        .product-name {
            display:inline-block;
            color:var(--cart-ink);
            font-size:1.05rem;
            line-height:1.35;
            font-weight:800;
        }

        .product-name:hover {
            color:var(--cart-accent);
        }

        .product-meta {
            color:var(--cart-muted);
            font-size:.9rem;
        }

        .price-stack {
            min-width:128px;
            text-align:right;
        }

        .item-price {
            font-weight:800;
            color:var(--cart-ink);
        }

        .item-qty {
            color:var(--cart-muted);
            font-size:.9rem;
            margin-top:.15rem;
        }

        .item-subtotal {
            margin-top:.35rem;
            color:var(--cart-success);
            font-weight:800;
        }

        .cart-update-form {
            margin-top:1rem;
            padding-top:1rem;
            border-top:1px solid #edf2f7;
        }

        .control-label {
            color:#475569;
            font-weight:700;
        }

        .form-select,
        .form-control {
            border-color:#cbd5e1;
            border-radius:8px;
        }

        .form-select:focus,
        .form-control:focus {
            border-color:var(--cart-accent);
            box-shadow:0 0 0 .2rem rgba(37, 99, 235, .12);
        }

        .quantity-control {
            display:grid;
            grid-template-columns:38px 58px 38px;
            width:134px;
            height:38px;
            border:1px solid #cbd5e1;
            border-radius:8px;
            overflow:hidden;
            background:#fff;
        }

        .quantity-control .btn {
            border:0;
            border-radius:0;
            display:flex;
            align-items:center;
            justify-content:center;
            background:var(--cart-soft);
            color:var(--cart-ink);
            font-size:1.05rem;
            font-weight:800;
        }

        .quantity-control .btn:hover:not(:disabled) {
            background:#e0ecff;
            color:var(--cart-accent);
        }

        .quantity-control .btn:disabled {
            color:#94a3b8;
            cursor:not-allowed;
        }

        .quantity-input {
            border:0;
            border-left:1px solid #e2e8f0;
            border-right:1px solid #e2e8f0;
            border-radius:0;
            text-align:center;
            min-width:0;
            font-weight:800;
            box-shadow:none!important;
            -moz-appearance:textfield;
        }

        .quantity-input::-webkit-outer-spin-button,
        .quantity-input::-webkit-inner-spin-button {
            -webkit-appearance:none;
            margin:0;
        }

        .summary-panel {
            position:sticky;
            top:1rem;
            padding:1.25rem;
            border:1px solid var(--cart-line);
            border-radius:8px;
            background:#fff;
            box-shadow:0 18px 45px rgba(15, 23, 42, .08);
        }

        .summary-title {
            margin:0 0 1rem;
            font-size:1.1rem;
            font-weight:800;
        }

        .summary-line {
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:1rem;
            padding:.75rem 0;
            border-bottom:1px solid #edf2f7;
            color:var(--cart-muted);
        }

        .summary-line strong {
            color:var(--cart-ink);
        }

        .summary-line.total {
            padding-top:1rem;
            border-bottom:0;
            color:var(--cart-ink);
            font-size:1.15rem;
            font-weight:800;
        }

        .summary-line.total strong {
            color:var(--cart-success);
        }

        .checkout-btn {
            min-height:46px;
            display:flex;
            align-items:center;
            justify-content:center;
            background:var(--cart-ink);
            border-color:var(--cart-ink);
        }

        .checkout-btn:hover,
        .checkout-btn:focus {
            background:var(--cart-accent);
            border-color:var(--cart-accent);
        }

        .continue-link {
            min-height:42px;
            display:flex;
            align-items:center;
            justify-content:center;
            color:var(--cart-accent);
            text-decoration:none;
        }

        .continue-link:hover,
        .continue-link:focus {
            background:#eff6ff;
            color:#1d4ed8;
        }

        @media (max-width: 768px) {
            .page-heading {
                display:block;
            }

            .cart-title {
                font-size:1.65rem;
            }

            .cart-item {
                padding:3rem 1rem 1rem;
            }

            .cart-remove-form {
                top:.75rem;
                left:.75rem;
            }

            .cart-row {
                align-items:flex-start!important;
            }

            .cart-img {
                width:86px;
                height:104px;
            }

            .product-top {
                grid-template-columns:1fr;
                gap:.6rem;
            }

            .price-stack {
                min-width:0;
                text-align:left;
            }

            .summary-panel {
                position:static;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="<%= ctx %>/home">Clothing Sale</a>
            <a class="btn btn-outline-dark" href="<%= ctx %>/home">Tiếp tục mua sắm</a>
        </div>
    </nav>

    <div class="container cart-page py-4 py-lg-5">
        <div class="page-heading">
            <div>
                <div class="page-kicker">Giỏ hàng</div>
                <h1 class="cart-title">Giỏ hàng của bạn</h1>
                <% if (items != null && !items.isEmpty()) { %>
                    <p class="page-subtitle">Có <%= items.size() %> sản phẩm trong giỏ</p>
                <% } %>
            </div>
        </div>

        <% if (request.getAttribute("cartMessage") != null) { %>
            <div id="cartFlashMessage" class="alert alert-info"><%= request.getAttribute("cartMessage") %></div>
        <% } %>

        <% if (items == null || items.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-mark">0</div>
                <h4>Giỏ hàng trống</h4>
                <p class="text-muted">Bạn chưa có sản phẩm nào trong giỏ.</p>
                <a href="<%= ctx %>/home" class="btn btn-primary">Quay lại mua sắm</a>
            </div>
        <% } else { %>
            <div class="row g-4 align-items-start">
                <div class="col-12 col-lg-8">
                    <div class="cart-list">
                        <% java.math.BigDecimal total = java.math.BigDecimal.ZERO; int totalQuantity = 0; %>
                        <% for (Object o : items) {
                               com.clothingsale.model.CartItem it = (com.clothingsale.model.CartItem) o;
                               java.math.BigDecimal price = it.getPrice() != null ? it.getPrice() : java.math.BigDecimal.ZERO;
                               int qty = it.getQuantity();
                               java.math.BigDecimal itemTotal = price.multiply(new java.math.BigDecimal(qty));
                               total = total.add(itemTotal);
                               totalQuantity += qty;

                               String rawImageUrl = it.getImageUrl();
                               String imageUrl = rawImageUrl;
                               if (imageUrl == null || imageUrl.trim().isEmpty()) {
                                   imageUrl = ctx + "/uploads/product/placeholder.png";
                               } else {
                                   imageUrl = imageUrl.trim();
                                   if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://") || imageUrl.startsWith(ctx + "/")) {
                                       imageUrl = imageUrl;
                                   } else {
                                       while (imageUrl.startsWith("/")) {
                                           imageUrl = imageUrl.substring(1);
                                       }
                                       if (imageUrl.startsWith("uploads/")) {
                                           imageUrl = ctx + "/" + imageUrl;
                                       } else if (imageUrl.contains("/")) {
                                           imageUrl = ctx + "/uploads/" + imageUrl;
                                       } else {
                                           imageUrl = ctx + "/uploads/product/" + imageUrl;
                                       }
                                   }
                               }

                               String attributes = it.getAttributes();
                               if (attributes == null || attributes.trim().isEmpty()) {
                                   attributes = "Standard";
                               }
                               java.util.List variants = variantsByProductId != null
                                       ? (java.util.List) variantsByProductId.get(it.getProductId())
                                       : null;
                        %>
                        <div class="list-group-item cart-item">
                            <form action="<%= ctx %>/cart/remove" method="post" class="cart-remove-form">
                                <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                <button type="submit"
                                        class="cart-remove-btn"
                                        title="Xóa sản phẩm"
                                        aria-label="Xóa sản phẩm">
                                </button>
                            </form>
                            <div class="d-flex cart-row align-items-start">
                                <img src="<%= imageUrl %>"
                                     alt="<%= it.getProductName() %>"
                                     class="cart-img"
                                     onerror="this.onerror=null;this.src='<%= ctx %>/uploads/product/placeholder.png';">

                                <div class="product-summary flex-grow-1">
                                    <div class="product-top">
                                        <div>
                                            <a class="product-name text-decoration-none" href="<%= ctx %>/product/detail?id=<%= it.getProductId() %>">
                                                <%= it.getProductName() %>
                                            </a>
                                            <div class="product-meta mt-1"><%= attributes %></div>
                                            <div class="product-meta">Mã biến thể: <%= it.getVariantId() %></div>
                                        </div>
                                        <div class="price-stack">
                                            <div class="item-price"><%= currencyFormat.format(price) %></div>
                                            <div class="item-qty">x <%= qty %></div>
                                            <div class="item-subtotal"><%= currencyFormat.format(itemTotal) %></div>
                                        </div>
                                    </div>

                                    <form action="<%= ctx %>/cart/update" method="post" class="cart-update-form mt-3">
                                        <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                        <input type="hidden" name="productId" value="<%= it.getProductId() %>">
                                        <input type="hidden" name="productName" value="<%= it.getProductName() %>">
                                        <input type="hidden" name="attributes" class="attributes-input" value="<%= attributes %>">
                                        <input type="hidden" name="price" class="price-input" value="<%= price %>">
                                        <input type="hidden" name="imageUrl" value="<%= rawImageUrl != null ? rawImageUrl : imageUrl %>">

                                        <div class="row g-2 align-items-end">
                                            <div class="col-12 col-md-7">
                                                <label class="form-label small control-label mb-1">Size / màu</label>
                                                <% if (variants != null && !variants.isEmpty()) { %>
                                                    <select name="newVariantId" class="form-select form-select-sm variant-select">
                                                       <% for (Object vo : variants) {
                                                               com.clothingsale.model.ProductVariant v = (com.clothingsale.model.ProductVariant) vo;
                                                               String detail = v.getAttributeDetails() != null ? v.getAttributeDetails() : "Standard";
                                                               java.math.BigDecimal variantPrice = v.getSalePrice() != null ? v.getSalePrice() : java.math.BigDecimal.ZERO;
                                                               boolean selected = v.getId() == it.getVariantId();
                                                        %>
                                                            <option value="<%= v.getId() %>"
                                                                    data-price="<%= variantPrice %>"
                                                                    data-attributes="<%= detail %>"
                                                                    <%= selected ? "selected" : "" %>>
                                                                <%= detail %> - <%= currencyFormat.format(variantPrice) %> - còn <%= v.getStockQuantity() %>
                                                            </option>
                                                        <% } %>
                                                    </select>
                                                <% } else { %>
                                                    <input type="hidden" name="newVariantId" value="<%= it.getVariantId() %>">
                                                    <div class="form-control form-control-sm bg-light"><%= attributes %></div>
                                                <% } %>
                                            </div>
                                            <div class="col-12 col-md-5">
                                                <label class="form-label small control-label mb-1">Số lượng</label>
                                                <div class="quantity-control">
                                                    <button type="button"
                                                            class="btn btn-sm btn-light quantity-step"
                                                            data-step="-1"
                                                            aria-label="Decrease quantity"
                                                            <%= qty <= 1 ? "disabled" : "" %>>
                                                        -
                                                    </button>
                                                    <input type="number"
                                                           name="quantity"
                                                           value="<%= qty %>"
                                                           min="1"
                                                           class="form-control form-control-sm quantity-input">
                                                    <button type="button"
                                                            class="btn btn-sm btn-light quantity-step"
                                                            data-step="1"
                                                            aria-label="Increase quantity">
                                                        +
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-12 col-lg-4">
                    <div class="summary-panel">
                        <h2 class="summary-title">Tóm tắt đơn hàng</h2>
                        <div class="summary-line">
                            <span>Số lượng</span>
                            <strong><%= totalQuantity %></strong>
                        </div>
                        <div class="summary-line">
                            <span>Tạm tính</span>
                            <strong><%= currencyFormat.format(total) %></strong>
                        </div>
                        <div class="summary-line total">
                            <span>Tổng cộng</span>
                            <strong><%= currencyFormat.format(total) %></strong>
                        </div>
                        <div class="mt-3">
                            <a href="<%= ctx %>/customer/checkout" class="btn btn-primary w-100 checkout-btn">Thanh toán</a>
                        </div>
                        <div class="mt-2">
                            <a href="<%= ctx %>/home" class="continue-link w-100">Tiếp tục mua sắm</a>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        function submitCartForm(form) {
            if (form.requestSubmit) {
                form.requestSubmit();
            } else {
                form.submit();
            }
        }

        document.querySelectorAll('.variant-select').forEach(function(select) {
            function syncVariant() {
                var form = select.closest('.cart-update-form');
                var option = select.options[select.selectedIndex];
                form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                form.querySelector('.price-input').value = option.dataset.price || '0';
            }
            select.addEventListener('change', function() {
                syncVariant();
                submitCartForm(select.closest('.cart-update-form'));
            });
            syncVariant();
        });

        document.querySelectorAll('.quantity-step').forEach(function(button) {
            button.addEventListener('click', function() {
                if (button.disabled) {
                    return;
                }

                var form = button.closest('.cart-update-form');
                var input = form.querySelector('.quantity-input');
                var current = parseInt(input.value, 10);
                var step = parseInt(button.dataset.step, 10);
                var next = (isNaN(current) ? 1 : current) + (isNaN(step) ? 0 : step);

                if (next < 1) {
                    return;
                }

                input.value = next;
                submitCartForm(form);
            });
        });

        document.querySelectorAll('.quantity-input').forEach(function(input) {
            input.addEventListener('change', function() {
                var value = parseInt(input.value, 10);
                if (isNaN(value) || value < 1) {
                    input.value = '1';
                }

                submitCartForm(input.closest('.cart-update-form'));
            });
        });

        var cartFlashMessage = document.getElementById('cartFlashMessage');
        if (cartFlashMessage) {
            setTimeout(function() {
                cartFlashMessage.classList.add('is-hiding');
                setTimeout(function() {
                    cartFlashMessage.remove();
                }, 320);
            }, 5000);
        }
    </script>
</body>
</html>
