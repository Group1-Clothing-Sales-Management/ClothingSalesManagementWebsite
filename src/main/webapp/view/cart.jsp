<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    java.util.Collection items = (java.util.Collection) request.getAttribute("items");
    java.util.Map variantsByProductId = (java.util.Map) request.getAttribute("variantsByProductId");
    String ctx = request.getContextPath();
    java.text.NumberFormat currencyFormat = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Cart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --cart-accent:#0f9b8e;
            --cart-accent-dark:#0b7f75;
            --cart-teal:#172033;
            --cart-ink:#172033;
            --cart-muted:#64748b;
            --cart-line:#e2e8f0;
            --cart-page:#f8fafc;
            --cart-soft:#f1f5f9;
        }

        * { box-sizing:border-box; }

        body {
            min-height:100vh;
            margin:0;
            background:var(--cart-page);
            color:var(--cart-ink);
            font-family:Arial, Helvetica, sans-serif;
            padding-bottom:150px;
        }

        .navbar {
            border-bottom:1px solid rgba(0, 0, 0, .06);
            box-shadow:none!important;
            background:#fff!important;
        }

        .cart-shell {
            max-width:1200px;
            margin:0 auto;
            padding:24px 16px 0;
        }

        .cart-brand-row {
            display:flex;
            align-items:center;
            justify-content:flex-start;
            min-height:86px;
            margin-bottom:16px;
            background:#fff;
            border-bottom:1px solid var(--cart-line);
        }

        .cart-brand-title {
            display:flex;
            align-items:center;
            gap:0;
            color:var(--cart-accent);
            font-size:26px;
            font-weight:500;
            padding-left:20px;
            white-space:nowrap;
        }

        .cart-brand-title span {
            padding-left:0;
            border-left:0;
        }

        .cart-grid {
            display:grid;
            grid-template-columns:48px minmax(300px, 1fr) 150px 160px 150px 130px;
            gap:16px;
            align-items:center;
        }

        .cart-head {
            min-height:58px;
            padding:0 24px;
            margin-bottom:12px;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
            color:var(--cart-muted);
            font-size:14px;
        }

        .cart-head .product-col {
            color:var(--cart-ink);
            font-size:16px;
        }

        .shop-card {
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
        }

        .cart-item {
            min-height:170px;
            padding:24px;
            border-bottom:1px solid var(--cart-line);
        }

        .product-info {
            display:flex;
            align-items:flex-start;
            gap:14px;
            min-width:0;
        }

        .cart-img {
            width:88px;
            height:88px;
            flex:0 0 auto;
            object-fit:cover;
            border:1px solid #eee;
            background:#f1f1f1;
        }

        .product-name {
            display:-webkit-box;
            -webkit-line-clamp:2;
            -webkit-box-orient:vertical;
            overflow:hidden;
            color:var(--cart-ink);
            font-size:15px;
            line-height:1.35;
            text-decoration:none;
        }

        .product-name:hover {
            color:var(--cart-accent);
        }

        .stock-note {
            margin-top:8px;
            color:var(--cart-muted);
            font-size:13px;
            line-height:1.35;
        }

        .stock-note strong {
            color:var(--cart-accent);
            font-weight:700;
        }

        .variant-block {
            min-width:0;
        }

        .variant-label {
            color:var(--cart-muted);
            font-size:14px;
            margin-bottom:6px;
        }

        .variant-select {
            width:100%;
            max-width:170px;
            border:0;
            color:#475569;
            font-size:14px;
            padding:0;
            background:transparent;
            box-shadow:none!important;
        }

        .variant-select:focus {
            outline:0;
        }

        .price-col,
        .amount-col,
        .action-col {
            text-align:center;
        }

        .item-price {
            color:var(--cart-ink);
            font-size:15px;
        }

        .amount-col {
            color:var(--cart-accent);
            font-size:16px;
            font-weight:500;
        }

        .cart-update-form {
            margin:0;
        }

        .quantity-control {
            display:grid;
            grid-template-columns:36px 54px 36px;
            width:126px;
            height:34px;
            margin:0 auto;
            border:1px solid #ddd;
            background:#fff;
        }

        .quantity-control .btn {
            border:0;
            border-radius:0;
            background:#fff;
            color:#475569;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:16px;
            line-height:1;
        }

        .quantity-control .btn:hover:not(:disabled) {
            background:#f7f7f7;
            color:var(--cart-accent);
        }

        .quantity-control .btn:disabled {
            color:#cfcfcf;
        }

        .quantity-input {
            border:0;
            border-left:1px solid #ddd;
            border-right:1px solid #ddd;
            border-radius:0;
            text-align:center;
            min-width:0;
            box-shadow:none!important;
            -moz-appearance:textfield;
        }

        .quantity-input::-webkit-outer-spin-button,
        .quantity-input::-webkit-inner-spin-button {
            -webkit-appearance:none;
            margin:0;
        }

        .cart-remove-form {
            margin:0;
        }

        .cart-remove-btn {
            border:0;
            background:transparent;
            color:#475569;
            font-size:14px;
            padding:4px 0;
        }

        .cart-remove-btn:hover,
        .cart-remove-btn:focus {
            color:var(--cart-accent);
        }

        .checkout-bar {
            position:fixed;
            left:0;
            right:0;
            bottom:0;
            z-index:20;
            background:#fff;
            border-top:1px solid var(--cart-line);
            box-shadow:0 -4px 16px rgba(0, 0, 0, .08);
        }

        .checkout-inner {
            max-width:1200px;
            min-height:96px;
            margin:0 auto;
            padding:12px 16px;
            display:grid;
            grid-template-columns:auto auto 1fr auto auto;
            gap:22px;
            align-items:center;
        }

        .select-all-wrap {
            display:flex;
            align-items:center;
            gap:12px;
            white-space:nowrap;
            color:var(--cart-ink);
        }

        .selected-summary {
            justify-self:end;
            text-align:right;
        }

        .selected-summary-main {
            display:flex;
            align-items:baseline;
            gap:8px;
            justify-content:flex-end;
            color:var(--cart-ink);
        }

        .selected-summary-main strong {
            color:var(--cart-accent);
            font-size:28px;
            font-weight:500;
            line-height:1;
        }

        .saving-line {
            color:var(--cart-accent);
            font-size:13px;
            margin-top:4px;
        }

        .checkout-btn {
            width:210px;
            height:50px;
            border:0;
            border-radius:2px;
            background:linear-gradient(135deg, var(--cart-teal), var(--cart-accent));
            color:#fff;
            font-size:16px;
            font-weight:600;
        }

        .checkout-btn:hover,
        .checkout-btn:focus {
            background:linear-gradient(135deg, #111827, var(--cart-accent-dark));
            color:#fff;
        }

        .checkout-btn:disabled {
            background:#94a3b8;
            color:#fff;
        }

        .continue-link {
            color:#333;
            text-decoration:none;
            white-space:nowrap;
        }

        .continue-link:hover {
            color:var(--cart-accent);
        }

        .cart-check {
            width:18px;
            height:18px;
            accent-color:var(--cart-accent);
            cursor:pointer;
        }

        .alert {
            border:1px solid #bae6e1;
            border-radius:3px;
            background:#ecfdf5;
            color:var(--cart-accent);
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
            max-width:560px;
            margin:64px auto;
            padding:42px;
            text-align:center;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
        }

        .empty-mark {
            width:76px;
            height:76px;
            margin:0 auto 16px;
            display:flex;
            align-items:center;
            justify-content:center;
            border-radius:50%;
            background:var(--cart-soft);
            color:var(--cart-accent);
            font-size:30px;
        }

        @media (max-width: 992px) {
            body {
                padding-bottom:190px;
            }

            .cart-brand-row {
                display:block;
                padding:18px 0;
            }

            .cart-head {
                display:none;
            }

            .cart-item {
                padding-left:16px;
                padding-right:16px;
            }

            .cart-grid {
                grid-template-columns:34px minmax(0, 1fr);
                gap:12px;
            }

            .variant-block,
            .price-col,
            .cart-update-form,
            .amount-col,
            .action-col {
                grid-column:2;
                text-align:left;
            }

            .quantity-control {
                margin:0;
            }

            .voucher-row,
            .shipping-row {
                padding:14px 16px;
            }

            .checkout-inner {
                grid-template-columns:1fr 1fr;
                gap:12px;
            }

            .selected-summary {
                grid-column:1 / -1;
                justify-self:stretch;
            }

            .selected-summary-main {
                justify-content:space-between;
            }

            .checkout-btn {
                width:100%;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/view/customer/common/header.jsp"/>

    <div class="cart-shell">
        <div class="cart-brand-row">
            <div class="cart-brand-title">
                <span>Cart</span>
            </div>
        </div>

        <% if (request.getAttribute("cartMessage") != null) { %>
            <div id="cartFlashMessage" class="alert alert-info"><%= request.getAttribute("cartMessage") %></div>
        <% } %>

        <% if (items == null || items.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-mark">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>
                <h4>Your cart is empty</h4>
                <p class="text-muted">Add items you like to start shopping.</p>
                <a href="<%= ctx %>/home" class="btn btn-dark">Continue Shopping</a>
            </div>
        <% } else { %>
            <div class="cart-head cart-grid">
                <div>
                    <input type="checkbox" class="cart-check" id="cartSelectAllTop" checked>
                </div>
                <div class="product-col">Product</div>
                <div class="text-center">Unit Price</div>
                <div class="text-center">Quantity</div>
                <div class="text-center">Subtotal</div>
                <div class="text-center">Action</div>
            </div>

            <div class="shop-card">
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
                       int currentStock = qty;
                       if (variants != null && !variants.isEmpty()) {
                           for (Object stockObject : variants) {
                               com.clothingsale.model.ProductVariant stockVariant = (com.clothingsale.model.ProductVariant) stockObject;
                               if (stockVariant.getId() == it.getVariantId()) {
                                   currentStock = stockVariant.getStockQuantity();
                                   break;
                               }
                           }
                       }
                %>
                    <div class="cart-item cart-grid">
                        <div>
                            <input type="checkbox"
                                   class="cart-check cart-select-input"
                                   name="selectedVariantId"
                                   value="<%= it.getVariantId() %>"
                                   form="cartCheckoutForm"
                                   data-line-quantity="<%= qty %>"
                                   data-line-total="<%= itemTotal %>"
                                   checked>
                        </div>

                        <div class="product-info">
                            <img src="<%= imageUrl %>"
                                 alt="<%= it.getProductName() %>"
                                 class="cart-img"
                                 onerror="this.onerror=null;this.src='<%= ctx %>/uploads/product/placeholder.png';">
                            <div>
                                <a class="product-name" href="<%= ctx %>/product/detail?id=<%= it.getProductId() %>">
                                    <%= it.getProductName() %>
                                </a>
                                <div class="stock-note">
                                    In stock: <strong><%= currentStock %></strong>
                                </div>
                            </div>
                        </div>

                        <div class="price-col">
                            <div class="item-price"><%= currencyFormat.format(price) %></div>
                        </div>

                        <form action="<%= ctx %>/cart/update" method="post" class="cart-update-form">
                            <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                            <input type="hidden" name="productId" value="<%= it.getProductId() %>">
                            <input type="hidden" name="productName" value="<%= it.getProductName() %>">
                            <input type="hidden" name="attributes" class="attributes-input" value="<%= attributes %>">
                            <input type="hidden" name="price" class="price-input" value="<%= price %>">
                            <input type="hidden" name="imageUrl" value="<%= rawImageUrl != null ? rawImageUrl : imageUrl %>">

                            <div class="variant-block mb-3">
                                <div class="variant-label">Variant:</div>
                                <% if (variants != null && !variants.isEmpty()) { %>
                                    <select name="newVariantId" class="variant-select">
                                       <% for (Object vo : variants) {
                                               com.clothingsale.model.ProductVariant v = (com.clothingsale.model.ProductVariant) vo;
                                               String detail = v.getAttributeDetails() != null ? v.getAttributeDetails() : "Standard";
                                               java.math.BigDecimal variantPrice = v.getSalePrice() != null ? v.getSalePrice() : java.math.BigDecimal.ZERO;
                                               boolean selected = v.getId() == it.getVariantId();
                                        %>
                                            <option value="<%= v.getId() %>"
                                                    data-price="<%= variantPrice %>"
                                                    data-attributes="<%= detail %>"
                                                    data-stock="<%= v.getStockQuantity() %>"
                                                    <%= (v.getStockQuantity() <= 0 && !selected) ? "disabled" : "" %>
                                                    <%= selected ? "selected" : "" %>>
                                                <%= detail %>
                                            </option>
                                        <% } %>
                                    </select>
                                <% } else { %>
                                    <input type="hidden" name="newVariantId" value="<%= it.getVariantId() %>">
                                    <div class="variant-select"><%= attributes %></div>
                                <% } %>
                            </div>

                            <div class="quantity-control">
                                <button type="button"
                                        class="btn quantity-step"
                                        data-step="-1"
                                        aria-label="Decrease quantity"
                                        <%= qty <= 1 ? "disabled" : "" %>>
                                    -
                                </button>
                                <input type="number"
                                       name="quantity"
                                       value="<%= qty %>"
                                       min="1"
                                       max="<%= currentStock %>"
                                       data-stock="<%= currentStock %>"
                                       class="form-control quantity-input">
                                <button type="button"
                                        class="btn quantity-step"
                                        data-step="1"
                                        aria-label="Increase quantity"
                                        <%= currentStock <= 0 || qty >= currentStock ? "disabled" : "" %>>
                                    +
                                </button>
                            </div>
                        </form>

                        <div class="amount-col">
                            <%= currencyFormat.format(itemTotal) %>
                        </div>

                        <div class="action-col">
                            <form action="<%= ctx %>/cart/remove" method="post" class="cart-remove-form">
                                <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                <button type="submit" class="cart-remove-btn">
                                    Remove
                                </button>
                            </form>
                        </div>
                    </div>
                <% } %>

            </div>

            <form id="cartCheckoutForm" action="<%= ctx %>/customer/checkout" method="get">
                <input type="hidden" name="selectionMode" value="1">
            </form>

            <div class="checkout-bar">
                <div class="checkout-inner">
                    <label class="select-all-wrap">
                        <input type="checkbox" class="cart-check" id="cartSelectAllBottom" checked>
                        <span>Select All (<%= items.size() %>)</span>
                    </label>

                    <a href="<%= ctx %>/home" class="continue-link">Continue Shopping</a>

                    <div class="selected-summary">
                        <div class="selected-summary-main">
                            <span>Total (<span id="selectedQuantity"><%= totalQuantity %></span> item(s)):</span>
                            <strong id="selectedTotal"><%= currencyFormat.format(total) %></strong>
                        </div>
                        <div class="saving-line">
                            Shipping and payment are handled at checkout.
                        </div>
                    </div>

                    <button id="checkoutSelectedButton"
                            type="submit"
                            form="cartCheckoutForm"
                            class="checkout-btn">
                        Checkout
                    </button>
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

        function getCurrentStock(form) {
            var select = form.querySelector('.variant-select');
            if (select && select.selectedIndex >= 0) {
                var option = select.options[select.selectedIndex];
                var optionStock = parseInt(option.dataset.stock, 10);
                if (!isNaN(optionStock)) {
                    return optionStock;
                }
            }

            var input = form.querySelector('.quantity-input');
            if (!input) {
                return 0;
            }

            var inputStock = parseInt(input.dataset.stock || input.getAttribute('max'), 10);
            return isNaN(inputStock) ? 0 : inputStock;
        }

        function normalizeQuantity(input, stock) {
            var value = parseInt(input.value, 10);
            if (isNaN(value) || value < 1) {
                value = 1;
            }

            if (stock > 0 && value > stock) {
                value = stock;
            }

            input.value = value;
            return value;
        }

        function updateQuantityButtons(form) {
            var input = form.querySelector('.quantity-input');
            var buttons = form.querySelectorAll('.quantity-step');
            if (!input || buttons.length < 2) {
                return;
            }

            var stock = getCurrentStock(form);
            var value = normalizeQuantity(input, stock);
            buttons[0].disabled = value <= 1;
            buttons[1].disabled = stock <= 0 || value >= stock;
        }

        document.querySelectorAll('.variant-select').forEach(function(select) {
            function syncVariant() {
                var form = select.closest('.cart-update-form');
                var option = select.options[select.selectedIndex];
                form.querySelector('.attributes-input').value = option.dataset.attributes || 'Standard';
                form.querySelector('.price-input').value = option.dataset.price || '0';
                var stock = parseInt(option.dataset.stock, 10);
                var input = form.querySelector('.quantity-input');
                if (input && !isNaN(stock)) {
                    input.max = stock;
                    input.dataset.stock = stock;
                    normalizeQuantity(input, stock);
                }
                updateQuantityButtons(form);
            }
            select.addEventListener('change', function() {
                syncVariant();
                submitCartForm(select.closest('.cart-update-form'));
            });
            syncVariant();
        });

        document.querySelectorAll('.cart-update-form').forEach(updateQuantityButtons);

        document.querySelectorAll('.quantity-step').forEach(function(button) {
            button.addEventListener('click', function() {
                if (button.disabled) {
                    return;
                }

                var form = button.closest('.cart-update-form');
                var input = form.querySelector('.quantity-input');
                var current = parseInt(input.value, 10);
                var step = parseInt(button.dataset.step, 10);
                var stock = getCurrentStock(form);
                var next = (isNaN(current) ? 1 : current) + (isNaN(step) ? 0 : step);

                if (next < 1) {
                    return;
                }

                if (stock <= 0 || next > stock) {
                    updateQuantityButtons(form);
                    return;
                }

                input.value = next;
                updateQuantityButtons(form);
                submitCartForm(form);
            });
        });

        document.querySelectorAll('.quantity-input').forEach(function(input) {
            input.addEventListener('change', function() {
                var form = input.closest('.cart-update-form');
                normalizeQuantity(input, getCurrentStock(form));
                updateQuantityButtons(form);
                submitCartForm(form);
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

        var cartSelectInputs = document.querySelectorAll('.cart-select-input');
        var selectAllInputs = document.querySelectorAll('#cartSelectAllTop, #cartSelectAllShop, #cartSelectAllBottom');
        var selectedQuantity = document.getElementById('selectedQuantity');
        var selectedTotal = document.getElementById('selectedTotal');
        var checkoutSelectedButton = document.getElementById('checkoutSelectedButton');
        var cartCheckoutForm = document.getElementById('cartCheckoutForm');

        function formatVnd(value) {
            try {
                return new Intl.NumberFormat('vi-VN', {
                    style: 'currency',
                    currency: 'VND'
                }).format(value);
            } catch (error) {
                return value.toLocaleString('vi-VN') + ' VND';
            }
        }

        function updateSelectedSummary() {
            var quantity = 0;
            var total = 0;
            var checkedLines = 0;

            cartSelectInputs.forEach(function(input) {
                if (!input.checked) {
                    return;
                }

                checkedLines += 1;
                quantity += Number(input.dataset.lineQuantity || 0);
                total += Number(input.dataset.lineTotal || 0);
            });

            if (selectedQuantity) {
                selectedQuantity.textContent = quantity;
            }

            if (selectedTotal) {
                selectedTotal.textContent = formatVnd(total);
            }

            if (checkoutSelectedButton) {
                checkoutSelectedButton.disabled = quantity === 0;
            }

            selectAllInputs.forEach(function(input) {
                input.checked = cartSelectInputs.length > 0 && checkedLines === cartSelectInputs.length;
                input.indeterminate = checkedLines > 0 && checkedLines < cartSelectInputs.length;
            });
        }

        cartSelectInputs.forEach(function(input) {
            input.addEventListener('change', updateSelectedSummary);
        });

        selectAllInputs.forEach(function(input) {
            input.addEventListener('change', function() {
                var shouldSelect = input.checked;
                cartSelectInputs.forEach(function(itemInput) {
                    itemInput.checked = shouldSelect;
                });
                updateSelectedSummary();
            });
        });

        if (cartCheckoutForm) {
            cartCheckoutForm.addEventListener('submit', function(event) {
                var hasSelectedItem = false;

                cartSelectInputs.forEach(function(input) {
                    if (input.checked) {
                        hasSelectedItem = true;
                    }
                });

                if (!hasSelectedItem) {
                    event.preventDefault();
                }
            });
        }

        updateSelectedSummary();
    </script>
</body>
</html>
