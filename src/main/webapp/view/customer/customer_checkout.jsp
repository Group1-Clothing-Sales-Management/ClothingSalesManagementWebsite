<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<c:set var="bestVoucherCode" value=""/>
<c:if test="${not empty suggestedVouchers}">
    <c:set var="bestVoucherCode" value="${suggestedVouchers[0].code}"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Checkout</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --checkout-ink: #172033;
                --checkout-muted: #697386;
                --checkout-line: #e6e9ef;
                --checkout-soft: #f6f8fb;
                --checkout-accent: #ee4d2d;
                --checkout-accent-dark: #d93d20;
            }

            body {
                background: #f4f6f9;
                color: var(--checkout-ink);
            }

            .checkout-page {
                min-height: 760px;
            }

            .checkout-heading {
                font-size: clamp(28px, 3vw, 38px);
                font-weight: 800;
                letter-spacing: -.03em;
            }

            .checkout-subtitle {
                color: var(--checkout-muted);
                margin: 0;
            }

            .checkout-card {
                background: #fff;
                border: 1px solid var(--checkout-line);
                border-radius: 18px;
                box-shadow: 0 8px 28px rgba(23, 32, 51, .045);
                margin-bottom: 22px;
                overflow: hidden;
            }

            .checkout-card-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 16px;
                padding: 21px 24px;
                border-bottom: 1px solid var(--checkout-line);
            }

            .checkout-card-title {
                display: flex;
                align-items: center;
                gap: 11px;
                margin: 0;
                font-size: 19px;
                font-weight: 800;
            }

            .checkout-card-title i {
                color: var(--checkout-accent);
            }

            .checkout-card-body {
                padding: 22px 24px;
            }

            .address-option {
                display: block;
                padding: 17px 18px;
                border: 1px solid var(--checkout-line);
                border-radius: 13px;
                cursor: pointer;
                transition: border-color .18s ease, box-shadow .18s ease, background .18s ease;
            }

            .address-option:hover {
                border-color: #b9c0cc;
            }

            .address-option.selected {
                border-color: var(--checkout-accent);
                background: #fff9f7;
                box-shadow: 0 0 0 3px rgba(238, 77, 45, .08);
            }

            .recipient-name {
                font-weight: 800;
            }

            .address-text {
                color: var(--checkout-muted);
                line-height: 1.55;
                margin-top: 6px;
            }

            .order-item {
                display: grid;
                grid-template-columns: 112px minmax(0, 1fr) auto;
                gap: 18px;
                align-items: center;
                padding: 18px 0;
                border-bottom: 1px solid #edf0f4;
            }

            .order-item:first-child {
                padding-top: 0;
            }

            .order-item:last-child {
                padding-bottom: 0;
                border-bottom: 0;
            }

            .product-image-box {
                width: 112px;
                height: 136px;
                border: 1px solid var(--checkout-line);
                border-radius: 13px;
                overflow: hidden;
                background: var(--checkout-soft);
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .product-image-box img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .image-fallback {
                display: none;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: #9aa3b2;
                font-size: 12px;
            }

            .image-fallback.show {
                display: flex;
            }

            .image-fallback i {
                font-size: 25px;
                margin-bottom: 7px;
            }

            .product-category {
                display: inline-flex;
                align-items: center;
                border: 1px solid #dce3ec;
                background: #f8fafc;
                border-radius: 999px;
                padding: 4px 9px;
                color: #526071;
                font-size: 12px;
                margin-bottom: 8px;
            }

            .product-name {
                font-size: 17px;
                font-weight: 800;
                line-height: 1.35;
            }

            .variant-line {
                color: var(--checkout-muted);
                font-size: 14px;
                margin-top: 8px;
            }

            .price-line {
                display: flex;
                flex-wrap: wrap;
                gap: 18px;
                margin-top: 13px;
                color: var(--checkout-muted);
                font-size: 14px;
            }

            .line-total {
                min-width: 130px;
                text-align: right;
            }

            .line-total-label {
                color: var(--checkout-muted);
                font-size: 12px;
                margin-bottom: 5px;
            }

            .line-total-value {
                font-size: 17px;
                font-weight: 800;
            }

            .fulfillment-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 14px;
            }

            .fulfillment-item {
                border: 1px solid var(--checkout-line);
                border-radius: 13px;
                padding: 17px;
                display: flex;
                gap: 13px;
                align-items: flex-start;
                background: #fff;
            }

            .fulfillment-icon {
                width: 40px;
                height: 40px;
                border-radius: 11px;
                display: grid;
                place-items: center;
                background: #fff0eb;
                color: var(--checkout-accent);
                flex: 0 0 40px;
            }

            .fulfillment-label {
                color: var(--checkout-muted);
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .04em;
                font-weight: 700;
            }

            .fulfillment-value {
                font-weight: 800;
                margin-top: 2px;
            }

            .fulfillment-note {
                color: var(--checkout-muted);
                font-size: 13px;
                margin-top: 3px;
            }

            .voucher-overview {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 18px;
                border: 1px dashed #f2a18d;
                background: #fffaf8;
                border-radius: 14px;
                padding: 16px 18px;
            }

            .voucher-selected-title {
                font-weight: 800;
                color: var(--checkout-accent-dark);
            }

            .voucher-selected-meta {
                color: var(--checkout-muted);
                font-size: 13px;
                margin-top: 4px;
            }

            .btn-voucher {
                border-color: var(--checkout-accent);
                color: var(--checkout-accent);
                white-space: nowrap;
            }

            .btn-voucher:hover,
            .btn-voucher:focus {
                border-color: var(--checkout-accent-dark);
                color: #fff;
                background: var(--checkout-accent-dark);
            }

            .summary-card {
                position: sticky;
                top: 20px;
            }

            .summary-row {
                display: flex;
                justify-content: space-between;
                gap: 16px;
                margin-bottom: 13px;
                color: #465163;
            }

            .summary-row strong {
                color: var(--checkout-ink);
            }

            .summary-total {
                display: flex;
                justify-content: space-between;
                align-items: flex-end;
                gap: 16px;
                border-top: 1px solid var(--checkout-line);
                padding-top: 17px;
                margin-top: 18px;
            }

            .summary-total-label {
                font-weight: 800;
            }

            .summary-total-value {
                font-size: 26px;
                font-weight: 900;
                color: var(--checkout-accent);
                line-height: 1;
            }

            .place-order-button {
                background: var(--checkout-ink);
                border-color: var(--checkout-ink);
                border-radius: 12px;
                font-weight: 800;
                padding: 14px 18px;
            }

            .place-order-button:hover,
            .place-order-button:focus {
                background: #0f1728;
                border-color: #0f1728;
            }

            .cod-note {
                color: var(--checkout-muted);
                text-align: center;
                font-size: 12px;
                margin-top: 11px;
            }

            .voucher-modal-content {
                border: 0;
                border-radius: 18px;
                overflow: hidden;
            }

            .voucher-modal-header {
                border-bottom: 1px solid var(--checkout-line);
                padding: 20px 22px;
            }

            .voucher-list {
                display: grid;
                gap: 14px;
            }

            .voucher-item {
                position: relative;
                display: grid;
                grid-template-columns: 132px minmax(0, 1fr) 140px;
                border: 1px solid var(--checkout-line);
                border-radius: 14px;
                overflow: hidden;
                background: #fff;
                transition: transform .15s ease, box-shadow .15s ease, opacity .15s ease;
            }

            .voucher-item:not(.is-disabled):hover {
                transform: translateY(-1px);
                box-shadow: 0 10px 25px rgba(23, 32, 51, .08);
            }

            .voucher-item.is-selected {
                border-color: var(--checkout-accent);
                box-shadow: 0 0 0 2px rgba(238, 77, 45, .09);
            }

            .voucher-item.is-disabled {
                opacity: .52;
                background: #f7f8fa;
            }

            .voucher-ticket-side {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 178px;
                padding: 16px 10px;
                text-align: center;
                color: #fff;
                background: linear-gradient(145deg, #ff6749, #ee4d2d);
            }

            .voucher-ticket-side i {
                font-size: 28px;
                margin-bottom: 10px;
            }

            .voucher-ticket-value {
                font-size: 22px;
                font-weight: 900;
            }

            .voucher-ticket-label {
                font-size: 11px;
                margin-top: 5px;
                letter-spacing: .04em;
            }

            .voucher-content {
                padding: 18px;
                min-width: 0;
            }

            .voucher-name {
                font-weight: 800;
                font-size: 16px;
            }

            .voucher-code {
                display: inline-block;
                margin-top: 5px;
                padding: 3px 7px;
                border-radius: 6px;
                color: var(--checkout-accent-dark);
                background: #fff0eb;
                font-size: 12px;
                font-weight: 800;
            }

            .voucher-scope {
                display: flex;
                align-items: flex-start;
                gap: 7px;
                color: #4f5c6d;
                font-size: 13px;
                margin-top: 11px;
            }

            .voucher-details {
                color: var(--checkout-muted);
                font-size: 13px;
                line-height: 1.55;
                margin-top: 9px;
            }

            .voucher-unavailable-reason {
                color: #a73b2a;
                font-size: 12px;
                font-weight: 700;
                margin-top: 9px;
            }

            .voucher-action {
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: stretch;
                gap: 8px;
                padding: 17px;
                border-left: 1px solid var(--checkout-line);
            }

            .best-choice {
                position: absolute;
                top: 0;
                right: 0;
                background: #16855b;
                color: #fff;
                border-radius: 0 13px 0 10px;
                padding: 5px 10px;
                font-size: 10px;
                font-weight: 900;
                letter-spacing: .04em;
            }

            .voucher-saving {
                color: #16855b;
                text-align: center;
                font-size: 12px;
                font-weight: 800;
            }

            .btn-apply-voucher {
                color: #fff;
                background: var(--checkout-accent);
                border-color: var(--checkout-accent);
            }

            .btn-apply-voucher:hover {
                color: #fff;
                background: var(--checkout-accent-dark);
                border-color: var(--checkout-accent-dark);
            }

            @media (max-width: 767.98px) {
                .checkout-card-header,
                .checkout-card-body {
                    padding-left: 17px;
                    padding-right: 17px;
                }

                .order-item {
                    grid-template-columns: 88px minmax(0, 1fr);
                    align-items: start;
                }

                .product-image-box {
                    width: 88px;
                    height: 108px;
                }

                .line-total {
                    grid-column: 2;
                    text-align: left;
                }

                .fulfillment-grid {
                    grid-template-columns: 1fr;
                }

                .voucher-overview {
                    align-items: flex-start;
                    flex-direction: column;
                }

                .voucher-item {
                    grid-template-columns: 100px minmax(0, 1fr);
                }

                .voucher-ticket-side {
                    min-height: 100%;
                }

                .voucher-action {
                    grid-column: 1 / -1;
                    border-left: 0;
                    border-top: 1px solid var(--checkout-line);
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <c:set var="defaultAddressId" value=""/>
        <c:forEach items="${addresses}" var="address">
            <c:if test="${address.isDefault()}">
                <c:set var="defaultAddressId" value="${address.id}"/>
            </c:if>
        </c:forEach>

        <main class="container checkout-page py-5">
            <div class="mb-4">
                <h1 class="checkout-heading mb-1">Checkout</h1>
                <p class="checkout-subtitle">Review your products, delivery address and payment total before placing the order.</p>
            </div>

            <c:if test="${param.error == 'invalid_address'}">
                <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i>Please select a valid delivery address.</div>
            </c:if>
            <c:if test="${param.error == 'invalid_checkout'}">
                <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i>Checkout information is invalid. Please review your order.</div>
            </c:if>
            <c:if test="${not empty checkoutError}">
                <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${checkoutError}"/></div>
            </c:if>
            <c:if test="${not empty voucherError}">
                <div class="alert alert-danger"><i class="fa-solid fa-ticket me-2"></i><c:out value="${voucherError}"/></div>
            </c:if>

            <div class="row g-4">
                <div class="col-lg-8">
                    <section class="checkout-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-solid fa-location-dot"></i>Delivery Address</h2>
                            <a href="${contextPath}/customer/address?from=checkout" class="btn btn-outline-dark btn-sm">Manage Addresses</a>
                        </div>
                        <div class="checkout-card-body">
                            <c:choose>
                                <c:when test="${empty addresses}">
                                    <div class="alert alert-warning mb-0">
                                        You do not have a delivery address.
                                        <a href="${contextPath}/customer/address?from=checkout" class="alert-link">Add an address</a>
                                        before placing the order.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="row g-3">
                                        <c:forEach items="${addresses}" var="address" varStatus="status">
                                            <c:set var="isSelectedAddress"
                                                   value="${not empty selectedAddressId
                                                            ? address.id == selectedAddressId
                                                            : ((not empty defaultAddressId and address.id == defaultAddressId)
                                                            or (empty defaultAddressId and status.first))}"/>
                                            <div class="col-12">
                                                <label class="address-option ${isSelectedAddress ? 'selected' : ''}">
                                                    <div class="d-flex gap-3">
                                                        <input type="radio" name="addressId" value="${address.id}"
                                                               form="checkoutForm" class="form-check-input address-radio mt-1"
                                                               ${isSelectedAddress ? 'checked' : ''} required>
                                                        <div class="flex-grow-1">
                                                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                                                                <div>
                                                                    <span class="recipient-name"><c:out value="${address.recipientName}"/></span>
                                                                    <span class="text-muted ms-2"><c:out value="${address.recipientPhone}"/></span>
                                                                </div>
                                                                <c:if test="${address.isDefault()}"><span class="badge text-bg-success">Default</span></c:if>
                                                            </div>
                                                            <div class="address-text">
                                                                <c:out value="${address.addressDetail}"/>
                                                                <c:if test="${not empty address.wardName}">, <c:out value="${address.wardName}"/></c:if>
                                                                <c:if test="${not empty address.provinceName}">, <c:out value="${address.provinceName}"/></c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </label>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-solid fa-bag-shopping"></i>Order Items</h2>
                            <span class="text-muted small">${fn:length(cartItems)} product line(s)</span>
                        </div>
                        <div class="checkout-card-body">
                            <c:forEach items="${cartItems}" var="item">
                                <c:set var="imageParts" value="${fn:split(item.imageUrl, '/')}"/>
                                <c:set var="imageName" value="${imageParts[fn:length(imageParts) - 1]}"/>
                                <c:url var="mediaImageUrl" value="/media/product/${imageName}"/>

                                <article class="order-item">
                                    <div class="product-image-box">
                                        <c:choose>
                                            <c:when test="${not empty item.imageUrl}">
                                                <img src="${mediaImageUrl}" alt="${fn:escapeXml(item.productName)}"
                                                     onerror="handleCheckoutImageError(this);">
                                                <div class="image-fallback"><i class="fa-regular fa-image"></i><span>No image</span></div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="image-fallback show"><i class="fa-regular fa-image"></i><span>No image</span></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div>
                                        <c:if test="${not empty item.categoryName}">
                                            <span class="product-category"><i class="fa-regular fa-folder me-1"></i><c:out value="${item.categoryName}"/></span>
                                        </c:if>
                                        <div class="product-name"><c:out value="${item.productName}"/></div>
                                        <div class="variant-line">
                                            <c:choose>
                                                <c:when test="${not empty item.attributes}"><c:out value="${item.attributes}"/></c:when>
                                                <c:otherwise>Standard variant</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="price-line">
                                            <span>Unit price: <strong><fmt:formatNumber value="${item.price}" type="number" maxFractionDigits="0"/> ₫</strong></span>
                                            <span>Quantity: <strong>${item.quantity}</strong></span>
                                        </div>
                                    </div>

                                    <div class="line-total">
                                        <div class="line-total-label">Item total</div>
                                        <div class="line-total-value"><fmt:formatNumber value="${item.price * item.quantity}" type="number" maxFractionDigits="0"/> ₫</div>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-solid fa-ticket"></i>Shop Voucher</h2>
                        </div>
                        <div class="checkout-card-body">
                            <div class="voucher-overview">
                                <div>
                                    <c:choose>
                                        <c:when test="${not empty voucher}">
                                            <div class="voucher-selected-title"><i class="fa-solid fa-circle-check me-1"></i><c:out value="${voucher.title}"/></div>
                                            <div class="voucher-selected-meta">
                                                Code: <strong><c:out value="${voucher.code}"/></strong>
                                                <span class="mx-1">•</span>
                                                Applies to: <strong><c:out value="${voucher.scopeLabel}"/></strong>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="fw-bold">Choose the best voucher for this order</div>
                                            <div class="voucher-selected-meta">Unavailable vouchers are shown dimmed and cannot be selected.</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="d-flex gap-2">
                                    <c:if test="${not empty voucher}">
                                        <form method="post" action="${contextPath}/customer/checkout" class="voucher-state-form">
                                            <input type="hidden" name="action" value="applyVoucher">
                                            <input type="hidden" name="voucherCode" value="">
                                            <input type="hidden" name="selectedAddressId" class="voucher-state-address">
                                            <input type="hidden" name="checkoutNote" class="voucher-state-note">
                                            <button type="submit" class="btn btn-outline-secondary btn-sm">Remove</button>
                                        </form>
                                    </c:if>
                                    <button type="button" class="btn btn-voucher btn-sm"
                                            data-bs-toggle="modal" data-bs-target="#voucherSelectionModal">
                                        ${not empty voucher ? 'Change Voucher' : 'Select Voucher'}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-solid fa-truck-fast"></i>Delivery & Payment</h2>
                        </div>
                        <div class="checkout-card-body">
                            <div class="fulfillment-grid">
                                <div class="fulfillment-item">
                                    <div class="fulfillment-icon"><i class="fa-solid fa-truck"></i></div>
                                    <div>
                                        <div class="fulfillment-label">Delivery method</div>
                                        <div class="fulfillment-value">Standard Home Delivery</div>
                                        <div class="fulfillment-note">The order will be delivered to your selected address.</div>
                                    </div>
                                </div>
                                <div class="fulfillment-item">
                                    <div class="fulfillment-icon"><i class="fa-solid fa-money-bill-wave"></i></div>
                                    <div>
                                        <div class="fulfillment-label">Payment method</div>
                                        <div class="fulfillment-value">Cash on Delivery (COD)</div>
                                        <div class="fulfillment-note">Pay in cash after receiving the order.</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-regular fa-note-sticky"></i>Order Note</h2>
                        </div>
                        <div class="checkout-card-body">
                            <textarea name="note" form="checkoutForm" class="form-control" rows="4" maxlength="500"
                                      placeholder="Notes for the store or delivery staff..."><c:out value="${checkoutNote}"/></textarea>
                        </div>
                    </section>
                </div>

                <div class="col-lg-4">
                    <section class="checkout-card summary-card">
                        <div class="checkout-card-header">
                            <h2 class="checkout-card-title"><i class="fa-solid fa-receipt"></i>Order Summary</h2>
                        </div>
                        <div class="checkout-card-body">
                            <div class="summary-row"><span>Merchandise subtotal</span><strong><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</strong></div>
                            <div class="summary-row"><span>Voucher discount</span><strong class="text-success">-<fmt:formatNumber value="${discountAmount}" type="number" maxFractionDigits="0"/> ₫</strong></div>
                            <div class="summary-row"><span>Delivery fee</span><strong><fmt:formatNumber value="${shippingFee}" type="number" maxFractionDigits="0"/> ₫</strong></div>

                            <c:if test="${not empty voucher}">
                                <div class="alert alert-success py-2 px-3 small mt-3 mb-0">
                                    You save <strong><fmt:formatNumber value="${discountAmount}" type="number" maxFractionDigits="0"/> ₫</strong> with <c:out value="${voucher.code}"/>.
                                </div>
                            </c:if>

                            <div class="summary-total">
                                <div>
                                    <div class="summary-total-label">Total Payment</div>
                                    <div class="text-muted small">Cash payable on delivery</div>
                                </div>
                                <div class="summary-total-value"><fmt:formatNumber value="${totalPayment}" type="number" maxFractionDigits="0"/> ₫</div>
                            </div>

                            <form method="post" action="${contextPath}/customer/checkout"
                                  id="checkoutForm" class="needs-validation" novalidate>
                                <input type="hidden" name="action" value="placeOrder">
                                <input type="hidden" name="voucherCode" value="${fn:escapeXml(voucherCode)}">
                                <input type="hidden" name="paymentMethod" value="COD">
                                <input type="hidden" name="carrierName" value="GHN">
                                <button type="submit" id="placeOrderButton"
                                        class="btn btn-dark place-order-button w-100 mt-4"
                                        ${empty addresses or empty cartItems ? 'disabled' : ''}>
                                    <i class="fa-solid fa-lock me-2"></i>Place Order
                                </button>
                            </form>
                            <div class="cod-note"><i class="fa-solid fa-shield-halved me-1"></i>No online payment is required.</div>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <div class="modal fade" id="voucherSelectionModal" tabindex="-1"
             aria-labelledby="voucherSelectionModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl">
                <div class="modal-content voucher-modal-content">
                    <div class="modal-header voucher-modal-header">
                        <div>
                            <h5 class="modal-title fw-bold" id="voucherSelectionModalLabel">Select Shop Voucher</h5>
                            <div class="text-muted small mt-1">Minimum spend is calculated only from products inside each voucher's scope.</div>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <c:choose>
                            <c:when test="${empty customerVouchers}">
                                <div class="text-center py-5">
                                    <i class="fa-solid fa-ticket fs-1 text-secondary"></i>
                                    <h6 class="mt-3">No vouchers available</h6>
                                    <p class="text-muted mb-0">New vouchers will appear here.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="voucher-list">
                                    <c:forEach items="${customerVouchers}" var="cv">
                                        <c:set var="voucherApplied" value="${not empty voucherCode and voucherCode eq cv.code}"/>
                                        <c:set var="bestVoucher" value="${not empty bestVoucherCode and bestVoucherCode eq cv.code}"/>

                                        <article class="voucher-item ${cv.eligibleForCheckout ? '' : 'is-disabled'} ${voucherApplied ? 'is-selected' : ''}">
                                            <c:if test="${bestVoucher and cv.eligibleForCheckout}"><div class="best-choice">BEST SAVING</div></c:if>

                                            <div class="voucher-ticket-side">
                                                <i class="fa-solid fa-tags"></i>
                                                <div class="voucher-ticket-value">
                                                    <c:choose>
                                                        <c:when test="${cv.discountType == 'PERCENTAGE'}"><fmt:formatNumber value="${cv.discountValue}" maxFractionDigits="2"/>%</c:when>
                                                        <c:otherwise><fmt:formatNumber value="${cv.discountValue}" type="number" maxFractionDigits="0"/>₫</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="voucher-ticket-label">SHOP VOUCHER</div>
                                            </div>

                                            <div class="voucher-content">
                                                <div class="voucher-name"><c:out value="${cv.title}"/></div>
                                                <span class="voucher-code"><c:out value="${cv.code}"/></span>
                                                <div class="voucher-scope">
                                                    <i class="fa-solid ${empty cv.categoryId ? 'fa-globe' : 'fa-folder-tree'} mt-1"></i>
                                                    <span><strong>Applies to:</strong> <c:out value="${cv.scopeLabel}"/></span>
                                                </div>
                                                <div class="voucher-details">
                                                    Eligible subtotal: <strong><fmt:formatNumber value="${cv.applicableSubtotal}" type="number" maxFractionDigits="0"/> ₫</strong><br>
                                                    Minimum eligible spend: <strong><fmt:formatNumber value="${cv.minOrderValue}" type="number" maxFractionDigits="0"/> ₫</strong>
                                                    <c:if test="${cv.discountType == 'PERCENTAGE' and not empty cv.maxDiscountAmount}">
                                                        <br>Maximum discount: <strong><fmt:formatNumber value="${cv.maxDiscountAmount}" type="number" maxFractionDigits="0"/> ₫</strong>
                                                    </c:if>
                                                    <br>Valid until: <strong><fmt:formatDate value="${cv.endDate}" pattern="dd/MM/yyyy HH:mm"/></strong>
                                                </div>
                                                <c:if test="${not cv.eligibleForCheckout}">
                                                    <div class="voucher-unavailable-reason">
                                                        <i class="fa-solid fa-circle-info me-1"></i><c:out value="${cv.checkoutIneligibilityReason}"/>
                                                        <c:if test="${cv.amountNeeded > 0}">
                                                            Add <fmt:formatNumber value="${cv.amountNeeded}" type="number" maxFractionDigits="0"/> ₫ more in eligible products.
                                                        </c:if>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <div class="voucher-action">
                                                <c:choose>
                                                    <c:when test="${voucherApplied}">
                                                        <div class="voucher-saving">Applied to order</div>
                                                        <button type="button" class="btn btn-outline-success btn-sm" disabled>Selected</button>
                                                    </c:when>
                                                    <c:when test="${cv.eligibleForCheckout}">
                                                        <div class="voucher-saving">Save <fmt:formatNumber value="${cv.applicableDiscount}" type="number" maxFractionDigits="0"/> ₫</div>
                                                        <form method="post" action="${contextPath}/customer/checkout" class="voucher-state-form">
                                                            <input type="hidden" name="action" value="applyVoucher">
                                                            <input type="hidden" name="voucherCode" value="${fn:escapeXml(cv.code)}">
                                                            <input type="hidden" name="selectedAddressId" class="voucher-state-address">
                                                            <input type="hidden" name="checkoutNote" class="voucher-state-note">
                                                            <button type="submit" class="btn btn-apply-voucher btn-sm w-100">Apply</button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn btn-secondary btn-sm" disabled>Not Eligible</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/customer/common/footer.jsp"/>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const addressOptions = document.querySelectorAll(".address-option");
                const addressRadios = document.querySelectorAll(".address-radio");
                const checkoutForm = document.getElementById("checkoutForm");
                const placeOrderButton = document.getElementById("placeOrderButton");

                function refreshSelectedAddress() {
                    addressOptions.forEach(option => option.classList.remove("selected"));
                    addressRadios.forEach(radio => {
                        if (radio.checked) {
                            const option = radio.closest(".address-option");
                            if (option) option.classList.add("selected");
                        }
                    });
                }

                addressRadios.forEach(radio => radio.addEventListener("change", refreshSelectedAddress));
                refreshSelectedAddress();

                if (checkoutForm) {
                    checkoutForm.addEventListener("submit", function (event) {
                        const selectedAddress = document.querySelector(".address-radio:checked");
                        if (!selectedAddress) {
                            event.preventDefault();
                            window.showAppToast("Please select a delivery address.", "warning", {title: "Delivery address required"});
                            return;
                        }

                        if (!checkoutForm.checkValidity()) {
                            event.preventDefault();
                            event.stopPropagation();
                            checkoutForm.classList.add("was-validated");
                            return;
                        }

                        if (placeOrderButton) {
                            placeOrderButton.disabled = true;
                            placeOrderButton.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing...';
                        }
                    });
                }

                document.querySelectorAll(".voucher-state-form").forEach(function (voucherForm) {
                    voucherForm.addEventListener("submit", function () {
                        const address = document.querySelector('input[name="addressId"]:checked');
                        const note = document.querySelector('textarea[name="note"]');
                        const addressField = voucherForm.querySelector(".voucher-state-address");
                        const noteField = voucherForm.querySelector(".voucher-state-note");

                        if (addressField) addressField.value = address ? address.value : "";
                        if (noteField) noteField.value = note ? note.value : "";
                    });
                });
            });

            function handleCheckoutImageError(imageElement) {
                imageElement.style.display = "none";
                const fallbackElement = imageElement.nextElementSibling;
                if (fallbackElement) fallbackElement.classList.add("show");
            }
        </script>
    </body>
</html>