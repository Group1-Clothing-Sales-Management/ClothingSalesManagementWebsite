<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath"
       value="${pageContext.request.contextPath}"/>

<c:set var="bestVoucherCode" value=""/>

<c:if test="${not empty suggestedVouchers}">
    <c:set var="bestVoucherCode"
           value="${suggestedVouchers[0].code}"/>
</c:if>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Checkout</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">
        
        <style>
            body {
                background: #f5f6f8;
            }

            .checkout-page {
                min-height: 700px;
            }

            .checkout-title {
                font-size: 30px;
                font-weight: 700;
            }

            .checkout-section {
                background: #ffffff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 24px;
                margin-bottom: 22px;
            }

            .section-title {
                font-size: 19px;
                font-weight: 700;
                margin-bottom: 18px;
            }

            .address-option {
                display: block;
                border: 1px solid #dee2e6;
                border-radius: 10px;
                padding: 16px;
                cursor: pointer;
                transition: 0.2s ease;
            }

            .address-option:hover {
                border-color: #999fa6;
            }

            .address-option.selected {
                border: 2px solid #212529;
                background: #fafafa;
            }

            .address-option input[type="radio"] {
                margin-top: 5px;
            }

            .recipient-name {
                font-weight: 700;
            }

            .address-text {
                color: #555d65;
                line-height: 1.55;
            }

            .product-item {
                display: flex;
                gap: 14px;
                padding: 15px 0;
                border-bottom: 1px solid #edf0f2;
            }

            .product-item:last-child {
                border-bottom: none;
            }

            .product-image {
                width: 75px;
                height: 90px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e3e5e8;
                background: #f8f9fa;
            }

            .product-name {
                font-weight: 600;
            }

            .product-variant {
                color: #6c757d;
                font-size: 14px;
            }

            .summary-row {
                display: flex;
                justify-content: space-between;
                gap: 15px;
                margin-bottom: 12px;
            }

            .summary-total {
                border-top: 1px solid #dee2e6;
                padding-top: 16px;
                margin-top: 16px;
                font-size: 20px;
                font-weight: 700;
            }

            .sticky-summary {
                position: sticky;
                top: 20px;
            }

            .payment-option,
            .shipping-option {
                border: 1px solid #dee2e6;
                border-radius: 10px;
                padding: 15px;
                cursor: pointer;
            }

            .payment-option:has(input:checked),
            .shipping-option:has(input:checked) {
                border: 2px solid #212529;
                background: #fafafa;
            }

            .voucher-box {
                background: #f8f9fa;
                border-radius: 10px;
                padding: 16px;
            }
            /* ================= PRODUCT IMAGE ================= */

            .checkout-product-image-box {
                width: 92px;
                height: 112px;
                flex: 0 0 92px;
                border: 1px solid #e4e7eb;
                border-radius: 10px;
                overflow: hidden;
                background: #f7f7f7;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .checkout-product-image {
                width: 100%;
                height: 100%;
                display: block;
                object-fit: cover;
            }

            .checkout-image-fallback {
                width: 100%;
                height: 100%;
                display: none;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 8px;
                color: #9ca3af;
                text-align: center;
                font-size: 12px;
            }

            .checkout-image-fallback i {
                font-size: 25px;
                margin-bottom: 7px;
            }

            .checkout-image-fallback.show {
                display: flex;
            }


            /* ================= VOUCHER SUMMARY ================= */

            .checkout-voucher-box {
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                background: #fff;
                overflow: hidden;
            }

            .checkout-voucher-header {
                padding: 20px 22px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 15px;
            }

            .checkout-voucher-title {
                display: flex;
                align-items: center;
                gap: 10px;
                color: #25282c;
                font-size: 19px;
                font-weight: 700;
            }

            .checkout-voucher-title i {
                color: #ee4d2d;
            }

            .checkout-voucher-selected {
                margin: 0 22px 20px;
                padding: 14px 16px;
                border: 1px solid #f6c6ba;
                border-radius: 9px;
                background: #fff8f6;
            }

            .checkout-voucher-selected-title {
                color: #ee4d2d;
                font-weight: 700;
            }

            .checkout-voucher-selected-code {
                margin-top: 3px;
                color: #6b7280;
                font-size: 13px;
            }

            .btn-select-voucher {
                border: 1px solid #ee4d2d;
                background: #fff;
                color: #ee4d2d;
                white-space: nowrap;
            }

            .btn-select-voucher:hover,
            .btn-select-voucher:focus {
                border-color: #d93618;
                background: #fff4f1;
                color: #d93618;
            }


            /* ================= VOUCHER MODAL ================= */

            .voucher-modal-content {
                border: 0;
                border-radius: 14px;
                overflow: hidden;
            }

            .voucher-modal-header {
                padding: 20px 24px;
                border-bottom: 1px solid #eceff2;
            }

            .voucher-modal-body {
                padding: 18px;
                max-height: 70vh;
                overflow-y: auto;
                background: #f5f5f5;
            }

            .voucher-modal-section-title {
                margin-bottom: 12px;
                color: #4b5563;
                font-size: 14px;
                font-weight: 700;
                text-transform: uppercase;
            }

            .voucher-item {
                position: relative;
                display: flex;
                min-height: 126px;
                margin-bottom: 14px;
                border: 1px solid #e4e7eb;
                border-radius: 8px;
                background: #fff;
                overflow: hidden;
                transition: 0.15s ease;
            }

            .voucher-item:hover {
                border-color: #ee4d2d;
                box-shadow: 0 4px 14px rgba(238, 77, 45, 0.09);
            }

            .voucher-item.applied {
                border: 2px solid #ee4d2d;
            }

            .voucher-item.disabled {
                opacity: 0.62;
                background: #f4f4f4;
            }

            .voucher-left {
                position: relative;
                width: 116px;
                min-width: 116px;
                padding: 14px 10px;
                background: linear-gradient(145deg, #ff6d4a, #ee4d2d);
                color: #fff;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
            }

            .voucher-left::before,
            .voucher-left::after {
                content: "";
                position: absolute;
                right: -7px;
                width: 14px;
                height: 14px;
                border-radius: 50%;
                background: #f5f5f5;
            }

            .voucher-left::before {
                top: -7px;
            }

            .voucher-left::after {
                bottom: -7px;
            }

            .voucher-left-icon {
                margin-bottom: 7px;
                font-size: 26px;
            }

            .voucher-left-value {
                font-size: 18px;
                font-weight: 800;
                line-height: 1.2;
            }

            .voucher-left-label {
                margin-top: 4px;
                font-size: 11px;
                opacity: 0.95;
            }

            .voucher-main {
                flex: 1;
                min-width: 0;
                padding: 13px 14px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 14px;
            }

            .voucher-information {
                min-width: 0;
            }

            .voucher-name {
                color: #24272b;
                font-size: 15px;
                font-weight: 700;
            }

            .voucher-code {
                display: inline-block;
                margin-top: 4px;
                padding: 2px 7px;
                border-radius: 4px;
                background: #fff1ed;
                color: #ee4d2d;
                font-size: 12px;
                font-weight: 700;
            }

            .voucher-condition {
                margin-top: 7px;
                color: #606770;
                font-size: 13px;
                line-height: 1.5;
            }

            .voucher-expiry {
                margin-top: 5px;
                color: #8a919a;
                font-size: 12px;
            }

            .voucher-action {
                min-width: 90px;
                text-align: right;
            }

            .voucher-best-label {
                position: absolute;
                top: 0;
                left: 0;
                z-index: 2;
                padding: 3px 9px;
                border-bottom-right-radius: 7px;
                background: #ffbf00;
                color: #3d2e00;
                font-size: 11px;
                font-weight: 800;
            }

            .voucher-status-label {
                margin-bottom: 7px;
                color: #8a919a;
                font-size: 12px;
            }

            .btn-apply-voucher {
                min-width: 78px;
                border-color: #ee4d2d;
                background: #ee4d2d;
                color: #fff;
            }

            .btn-apply-voucher:hover {
                border-color: #d93618;
                background: #d93618;
                color: #fff;
            }

            .btn-apply-voucher:disabled {
                border-color: #c9cdd2;
                background: #c9cdd2;
                color: #fff;
            }

            .btn-remove-voucher {
                border: 0;
                background: transparent;
                color: #ee4d2d;
                font-size: 13px;
                text-decoration: underline;
            }

            @media (max-width: 575.98px) {
                .voucher-left {
                    width: 92px;
                    min-width: 92px;
                }

                .voucher-main {
                    align-items: flex-start;
                    flex-direction: column;
                }

                .voucher-action {
                    width: 100%;
                    text-align: left;
                }
            }
        </style>
    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <c:set var="contextPath"
               value="${pageContext.request.contextPath}"/>

        <%-- Tìm ID địa chỉ mặc định --%>
        <c:set var="defaultAddressId" value=""/>

        <c:forEach items="${addresses}" var="address">
            <c:if test="${address.isDefault()}">
                <c:set var="defaultAddressId"
                       value="${address.id}"/>
            </c:if>
        </c:forEach>

        <div class="container checkout-page py-5">

            <div class="mb-4">
                <h1 class="checkout-title mb-1">Checkout</h1>

                <p class="text-muted mb-0">
                    Review your order and delivery information.
                </p>
            </div>

            <c:if test="${param.error == 'invalid_address'}">
                <div class="alert alert-danger">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>
                    Please select a valid delivery address.
                </div>
            </c:if>

            <c:if test="${param.error == 'invalid_checkout'}">
                <div class="alert alert-danger">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>
                    Checkout information is invalid.
                    Please check your order and try again.
                </div>
            </c:if>

            <c:if test="${not empty voucherError}">
                <div class="alert alert-danger">
                    <i class="fa-solid fa-ticket me-2"></i>
                    <c:out value="${voucherError}"/>
                </div>
            </c:if>

            <div class="row g-4">

                <div class="col-lg-8">

                    <%-- Địa chỉ giao hàng --%>
                    <div class="checkout-section">

                        <div class="d-flex justify-content-between
                             align-items-center gap-3 mb-3">

                            <h2 class="section-title mb-0">
                                <i class="fa-solid fa-location-dot me-2"></i>
                                Delivery Address
                            </h2>

                            <a href="${contextPath}/customer/address?from=checkout"
                               class="btn btn-outline-dark btn-sm">

                                Manage Addresses
                            </a>
                        </div>

                        <c:choose>
                            <c:when test="${empty addresses}">

                                <div class="alert alert-warning mb-0">

                                    <i class="fa-solid
                                       fa-triangle-exclamation
                                       me-2">
                                    </i>

                                    You do not have a delivery address.

                                    <a href="${contextPath}/customer/address?from=checkout"
                                       class="alert-link">

                                        Add an address
                                    </a>
                                    before placing the order.
                                </div>
                            </c:when>

                            <c:otherwise>

                                <div class="row g-3">

                                    <c:forEach items="${addresses}"
                                               var="address"
                                               varStatus="status">

                                        <c:set var="isSelectedAddress"
                                               value="${(not empty defaultAddressId
                                                        and address.id == defaultAddressId)
                                                        or
                                                        (empty defaultAddressId
                                                        and status.first)}"/>

                                        <div class="col-12">

                                            <label class="address-option
                                                   ${isSelectedAddress
                                                     ? 'selected'
                                                     : ''}">

                                                <div class="d-flex gap-3">

                                                    <input type="radio"
                                                           name="addressId"
                                                           value="${address.id}"
                                                           form="checkoutForm"
                                                           class="form-check-input address-radio"
                                                           <c:if test="${isSelectedAddress}">
                                                               checked
                                                           </c:if>
                                                           required>

                                                    <div class="flex-grow-1">

                                                        <div class="d-flex
                                                             flex-wrap
                                                             justify-content-between
                                                             align-items-center
                                                             gap-2">

                                                            <div>
                                                                <span class="recipient-name">
                                                                    <c:out value="${address.recipientName}"/>
                                                                </span>

                                                                <span class="text-muted ms-2">
                                                                    <c:out value="${address.recipientPhone}"/>
                                                                </span>
                                                            </div>

                                                            <c:if test="${address.isDefault()}">

                                                                <span class="badge bg-success">
                                                                    Default
                                                                </span>
                                                            </c:if>
                                                        </div>

                                                        <div class="address-text mt-2">

                                                            <c:out value="${address.addressDetail}"/>

                                                            <c:if test="${not empty address.wardName}">
                                                                ,
                                                                <c:out value="${address.wardName}"/>
                                                            </c:if>

                                                            <%-- Huyện chỉ có ở địa chỉ cũ --%>
                                                            <c:if test="${not empty address.districtName}">
                                                                ,
                                                                <c:out value="${address.districtName}"/>
                                                            </c:if>

                                                            <c:if test="${not empty address.provinceName}">
                                                                ,
                                                                <c:out value="${address.provinceName}"/>
                                                            </c:if>
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

                    <%-- Phương thức vận chuyển --%>
                    <div class="checkout-section">

                        <h2 class="section-title">
                            <i class="fa-solid fa-truck me-2"></i>
                            Shipping Method
                        </h2>

                        <div class="row g-3">

                            <div class="col-md-6">

                                <label class="shipping-option d-block">

                                    <div class="d-flex gap-3">

                                        <input type="radio"
                                               name="carrierName"
                                               value="GHN"
                                               form="checkoutForm"
                                               class="form-check-input"
                                               checked>

                                        <div>
                                            <div class="fw-semibold">
                                                Economical Delivery
                                            </div>

                                            <small class="text-muted">
                                                Standard delivery service
                                            </small>
                                        </div>
                                    </div>
                                </label>
                            </div>

                            <div class="col-md-6">

                                <label class="shipping-option d-block">

                                    <div class="d-flex gap-3">

                                        <input type="radio"
                                               name="carrierName"
                                               value="SELF"
                                               form="checkoutForm"
                                               class="form-check-input">

                                        <div>
                                            <div class="fw-semibold">
                                                Store Delivery
                                            </div>

                                            <small class="text-muted">
                                                Delivered by the store
                                            </small>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <%-- Phương thức thanh toán --%>
                    <div class="checkout-section">

                        <h2 class="section-title">
                            <i class="fa-solid fa-credit-card me-2"></i>
                            Payment Method
                        </h2>

                        <div class="row g-3">

                            <div class="col-md-6">

                                <label class="payment-option d-block">

                                    <div class="d-flex gap-3">

                                        <input type="radio"
                                               name="paymentMethod"
                                               value="COD"
                                               form="checkoutForm"
                                               class="form-check-input"
                                               checked>

                                        <div>
                                            <div class="fw-semibold">
                                                Cash on Delivery
                                            </div>

                                            <small class="text-muted">
                                                Pay when you receive the order
                                            </small>
                                        </div>
                                    </div>
                                </label>
                            </div>

                            <div class="col-md-6">

                                <label class="payment-option d-block">

                                    <div class="d-flex gap-3">

                                        <input type="radio"
                                               name="paymentMethod"
                                               value="VNPAY"
                                               form="checkoutForm"
                                               class="form-check-input">

                                        <div>
                                            <div class="fw-semibold">
                                                VNPay
                                            </div>

                                            <small class="text-muted">
                                                Pay securely through VNPay
                                            </small>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <%-- Ghi chú --%>
                    <div class="checkout-section">

                        <h2 class="section-title">
                            <i class="fa-solid fa-note-sticky me-2"></i>
                            Order Note
                        </h2>

                        <textarea name="note"
                                  form="checkoutForm"
                                  class="form-control"
                                  rows="4"
                                  maxlength="500"
                                  placeholder="Notes for the store or delivery staff..."></textarea>
                    </div>
                </div>

                <div class="col-lg-4">

                    <div class="sticky-summary">

                        <%-- Voucher là form riêng, không lồng trong form checkout --%>
                        <div class="checkout-voucher-box">

                            <div class="checkout-voucher-header">

                                <div class="checkout-voucher-title">
                                    <i class="fa-solid fa-ticket"></i>
                                    <span>Shop Voucher</span>
                                </div>

                                <button type="button"
                                        class="btn btn-sm btn-select-voucher"
                                        data-bs-toggle="modal"
                                        data-bs-target="#voucherSelectionModal">

                                    <c:choose>
                                        <c:when test="${not empty voucher}">
                                            Change
                                        </c:when>

                                        <c:otherwise>
                                            Select Voucher
                                        </c:otherwise>
                                    </c:choose>
                                </button>
                            </div>

                            <c:choose>
                                <c:when test="${not empty voucher}">

                                    <div class="checkout-voucher-selected">

                                        <div class="d-flex justify-content-between
                                             align-items-start gap-3">

                                            <div>
                                                <div class="checkout-voucher-selected-title">
                                                    <i class="fa-solid
                                                       fa-circle-check me-1">
                                                    </i>

                                                    <c:out value="${voucher.title}"/>
                                                </div>

                                                <div class="checkout-voucher-selected-code">
                                                    Code:
                                                    <strong>
                                                        <c:out value="${voucher.code}"/>
                                                    </strong>
                                                </div>

                                                <div class="small text-success mt-1">
                                                    You saved

                                                    <strong>
                                                        <fmt:formatNumber
                                                            value="${discountAmount}"
                                                            type="number"
                                                            maxFractionDigits="0"/>
                                                        ₫
                                                    </strong>
                                                </div>
                                            </div>

                                            <form method="post"
                                                  action="${contextPath}/customer/checkout">

                                                <input type="hidden"
                                                       name="action"
                                                       value="applyVoucher">

                                                <input type="hidden"
                                                       name="voucherCode"
                                                       value="">

                                                <button type="submit"
                                                        class="btn-remove-voucher">

                                                    Remove
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>

                                    <div class="px-4 pb-4 text-muted small">
                                        Select an available voucher to receive
                                        the best discount for this order.
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <c:if test="${not empty voucherError}">
                                <div class="alert alert-danger mx-4 mb-4 py-2">
                                    <c:out value="${voucherError}"/>
                                </div>
                            </c:if>
                        </div>

                        <%-- Danh sách sản phẩm --%>
                        <div class="checkout-section">

                            <h2 class="section-title">
                                Order Summary
                            </h2>

                            <c:choose>
                                <c:when test="${empty cartItems}">

                                    <div class="alert alert-warning mb-0">
                                        Your shopping cart is empty.
                                    </div>
                                </c:when>

                                <c:otherwise>

                                    <c:forEach items="${cartItems}" var="item">

                                        <%--
                                            Ưu tiên đọc từ ProductImageServlet:
                                            /media/product/{filename}

        Nếu không tìm thấy, JavaScript sẽ thử:
        /uploads/product/{filename}
                                        --%>

                                        <c:url var="mediaImageUrl"
                                               value="/media/product/${item.imageUrl}"/>

                                        <c:url var="legacyImageUrl"
                                               value="/uploads/product/${item.imageUrl}"/>

                                        <div class="product-item">

                                            <div class="checkout-product-image-box">

                                                <c:choose>
                                                    <c:when test="${not empty item.imageUrl}">

                                                        <img src="${mediaImageUrl}"
                                                             data-fallback-src="${legacyImageUrl}"
                                                             alt="${fn:escapeXml(item.productName)}"
                                                             class="checkout-product-image"
                                                             onerror="handleCheckoutImageError(this);">

                                                        <div class="checkout-image-fallback">
                                                            <i class="fa-regular fa-image"></i>
                                                            <span>No image</span>
                                                        </div>

                                                    </c:when>

                                                    <c:otherwise>

                                                        <div class="checkout-image-fallback show">
                                                            <i class="fa-regular fa-image"></i>
                                                            <span>No image</span>
                                                        </div>

                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="flex-grow-1">

                                                <div class="product-name">
                                                    <c:out value="${item.productName}"/>
                                                </div>

                                                <div class="product-variant mt-2">

                                                    <c:if test="${not empty item.color}">
                                                        <span>
                                                            Color:
                                                            <c:out value="${item.color}"/>
                                                        </span>
                                                    </c:if>

                                                    <c:if test="${not empty item.color
                                                                  and not empty item.size}">
                                                          <span class="mx-2">|</span>
                                                    </c:if>

                                                    <c:if test="${not empty item.size}">
                                                        <span>
                                                            Size:
                                                            <c:out value="${item.size}"/>
                                                        </span>
                                                    </c:if>
                                                </div>

                                                <div class="d-flex justify-content-between
                                                     align-items-end gap-3 mt-3">

                                                    <span class="text-muted">
                                                        Quantity:
                                                        <c:out value="${item.quantity}"/>
                                                    </span>

                                                    <strong>
                                                        <fmt:formatNumber
                                                            value="${item.price * item.quantity}"
                                                            type="number"
                                                            maxFractionDigits="0"/>
                                                        ₫
                                                    </strong>
                                                </div>
                                            </div>
                                        </div>

                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>

                            <div class="mt-4">

                                <div class="summary-row">
                                    <span>Subtotal</span>

                                    <span>
                                        <fmt:formatNumber
                                            value="${cartTotal}"
                                            type="number"
                                            maxFractionDigits="0"/>
                                        ₫
                                    </span>
                                </div>

                                <div class="summary-row">
                                    <span>Discount</span>

                                    <span class="text-success">
                                        -
                                        <fmt:formatNumber
                                            value="${discountAmount}"
                                            type="number"
                                            maxFractionDigits="0"/>
                                        ₫
                                    </span>
                                </div>

                                <div class="summary-row">
                                    <span>Shipping Fee</span>

                                    <span>
                                        <fmt:formatNumber
                                            value="${shippingFee}"
                                            type="number"
                                            maxFractionDigits="0"/>
                                        ₫
                                    </span>
                                </div>

                                <div class="summary-row summary-total">
                                    <span>Total</span>

                                    <span>
                                        <fmt:formatNumber
                                            value="${totalPayment}"
                                            type="number"
                                            maxFractionDigits="0"/>
                                        ₫
                                    </span>
                                </div>
                            </div>

                            <%-- Form đặt hàng chính --%>
                            <form method="post"
                                  action="${contextPath}/customer/checkout"
                                  id="checkoutForm"
                                  class="needs-validation"
                                  novalidate>

                                <input type="hidden"
                                       name="action"
                                       value="placeOrder">

                                <input type="hidden"
                                       name="voucherCode"
                                       value="${fn:escapeXml(voucherCode)}">

                                <button type="submit"
                                        id="placeOrderButton"
                                        class="btn btn-dark w-100 py-3 mt-4"
                                        <c:if test="${empty addresses
                                                      or empty cartItems}">
                                              disabled
                                        </c:if>>

                                    <i class="fa-solid fa-lock me-2"></i>
                                    Place Order
                                </button>
                            </form>

                            <c:if test="${empty addresses}">
                                <div class="text-danger small mt-2 text-center">
                                    Add a delivery address before placing the order.
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/customer/common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js">
        </script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {

                const addressOptions =
                        document.querySelectorAll(
                                ".address-option"
                                );

                const addressRadios =
                        document.querySelectorAll(
                                ".address-radio"
                                );

                function refreshSelectedAddress() {
                    addressOptions.forEach(function (option) {
                        option.classList.remove("selected");
                    });

                    addressRadios.forEach(function (radio) {
                        if (radio.checked) {
                            const option =
                                    radio.closest(".address-option");

                            if (option) {
                                option.classList.add("selected");
                            }
                        }
                    });
                }

                addressRadios.forEach(function (radio) {
                    radio.addEventListener(
                            "change",
                            refreshSelectedAddress
                            );
                });

                refreshSelectedAddress();

                const checkoutForm =
                        document.getElementById("checkoutForm");

                const placeOrderButton =
                        document.getElementById(
                                "placeOrderButton"
                                );

                if (checkoutForm) {
                    checkoutForm.addEventListener(
                            "submit",
                            function (event) {

                                const selectedAddress =
                                        document.querySelector(
                                                ".address-radio:checked"
                                                );

                                if (!selectedAddress) {
                                    event.preventDefault();
                                    event.stopPropagation();

                                    alert(
                                            "Please select a delivery address."
                                            );

                                    return;
                                }

                                if (!checkoutForm.checkValidity()) {
                                    event.preventDefault();
                                    event.stopPropagation();

                                    checkoutForm.classList.add(
                                            "was-validated"
                                            );

                                    return;
                                }

                                if (placeOrderButton) {
                                    placeOrderButton.disabled = true;

                                    placeOrderButton.innerHTML =
                                            '<span class="spinner-border '
                                            + 'spinner-border-sm me-2"></span>'
                                            + 'Processing...';
                                }
                            }
                    );
                }
            });

            function handleCheckoutImageError(imageElement) {
                const fallbackSource =
                        imageElement.getAttribute("data-fallback-src");

                const alreadyTriedFallback =
                        imageElement.getAttribute("data-fallback-tried")
                        === "true";

                if (!alreadyTriedFallback && fallbackSource) {
                    imageElement.setAttribute(
                            "data-fallback-tried",
                            "true"
                            );

                    imageElement.src = fallbackSource;
                    return;
                }

                imageElement.style.display = "none";

                const fallbackElement =
                        imageElement.nextElementSibling;

                if (fallbackElement) {
                    fallbackElement.classList.add("show");
                }
            }

        </script>
        <div class="modal fade"
             id="voucherSelectionModal"
             tabindex="-1"
             aria-labelledby="voucherSelectionModalLabel"
             aria-hidden="true">

            <div class="modal-dialog
                 modal-dialog-centered
                 modal-dialog-scrollable
                 modal-lg">

                <div class="modal-content voucher-modal-content">

                    <div class="modal-header voucher-modal-header">

                        <div>
                            <h5 class="modal-title"
                                id="voucherSelectionModalLabel">

                                Select Shop Voucher
                            </h5>

                            <div class="text-muted small mt-1">
                                Only one shop voucher can be applied.
                            </div>
                        </div>

                        <button type="button"
                                class="btn-close"
                                data-bs-dismiss="modal"
                                aria-label="Close">
                        </button>
                    </div>

                    <div class="modal-body voucher-modal-body">

                        <c:choose>
                            <c:when test="${empty customerVouchers}">

                                <div class="text-center py-5">

                                    <i class="fa-solid fa-ticket
                                       fs-1 text-secondary">
                                    </i>

                                    <h6 class="mt-3">
                                        No vouchers available
                                    </h6>

                                    <p class="text-muted mb-0">
                                        New vouchers will appear here.
                                    </p>
                                </div>
                            </c:when>

                            <c:otherwise>

                                <div class="voucher-modal-section-title">
                                    Available Shop Vouchers
                                </div>

                                <c:forEach items="${customerVouchers}"
                                           var="cv">

                                    <c:set var="voucherAvailable"
                                           value="${cv.customerStatus == 'AVAILABLE'}"/>

                                    <c:set var="orderEnough"
                                           value="${cartTotal >= cv.minOrderValue}"/>

                                    <c:set var="voucherCanUse"
                                           value="${voucherAvailable
                                                    and orderEnough}"/>

                                    <c:set var="voucherApplied"
                                           value="${not empty voucherCode
                                                    and voucherCode == cv.code}"/>

                                    <c:set var="bestVoucher"
                                           value="${not empty bestVoucherCode
                                                    and bestVoucherCode == cv.code}"/>

                                    <div class="voucher-item
                                         ${voucherApplied ? 'applied' : ''}
                                         ${voucherCanUse ? '' : 'disabled'}">

                                        <c:if test="${bestVoucher
                                                      and voucherCanUse}">

                                              <div class="voucher-best-label">
                                                  BEST CHOICE
                                              </div>
                                        </c:if>

                                        <div class="voucher-left">

                                            <div class="voucher-left-icon">
                                                <i class="fa-solid fa-tags"></i>
                                            </div>

                                            <div class="voucher-left-value">

                                                <c:choose>
                                                    <c:when test="${cv.discountType
                                                                    == 'PERCENTAGE'}">

                                                            <fmt:formatNumber
                                                                value="${cv.discountValue}"
                                                                maxFractionDigits="0"/>
                                                            %
                                                    </c:when>

                                                    <c:otherwise>

                                                        <fmt:formatNumber
                                                            value="${cv.discountValue}"
                                                            type="number"
                                                            maxFractionDigits="0"/>
                                                        ₫
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="voucher-left-label">
                                                SHOP VOUCHER
                                            </div>
                                        </div>

                                        <div class="voucher-main">

                                            <div class="voucher-information">

                                                <div class="voucher-name">
                                                    <c:out value="${cv.title}"/>
                                                </div>

                                                <span class="voucher-code">
                                                    <c:out value="${cv.code}"/>
                                                </span>

                                                <div class="voucher-condition">

                                                    Min. spend:

                                                    <strong>
                                                        <fmt:formatNumber
                                                            value="${cv.minOrderValue}"
                                                            type="number"
                                                            maxFractionDigits="0"/>
                                                        ₫
                                                    </strong>

                                                    <c:if test="${cv.discountType
                                                                  == 'PERCENTAGE'
                                                                  and
                                                                  not empty
                                                                  cv.maxDiscountAmount}">

                                                          <br>

                                                          Maximum discount:

                                                          <strong>
                                                              <fmt:formatNumber
                                                                  value="${cv.maxDiscountAmount}"
                                                                  type="number"
                                                                  maxFractionDigits="0"/>
                                                              ₫
                                                          </strong>
                                                    </c:if>
                                                </div>

                                                <div class="voucher-expiry">
                                                    Valid until:

                                                    <fmt:formatDate
                                                        value="${cv.endDate}"
                                                        pattern="dd/MM/yyyy"/>
                                                </div>
                                            </div>

                                            <div class="voucher-action">

                                                <c:choose>
                                                    <c:when test="${voucherApplied}">

                                                        <div class="voucher-status-label
                                                             text-success">

                                                            Applied
                                                        </div>

                                                        <button type="button"
                                                                class="btn
                                                                btn-sm
                                                                btn-outline-success"
                                                                disabled>

                                                            Selected
                                                        </button>
                                                    </c:when>

                                                    <c:when test="${cv.customerStatus
                                                                    == 'USED'}">

                                                            <div class="voucher-status-label">
                                                                Already used
                                                            </div>

                                                            <button type="button"
                                                                    class="btn
                                                                    btn-sm
                                                                    btn-secondary"
                                                                    disabled>

                                                                Used
                                                            </button>
                                                    </c:when>

                                                    <c:when test="${cv.customerStatus
                                                                    == 'EXPIRED'}">

                                                            <div class="voucher-status-label">
                                                                Expired
                                                            </div>

                                                            <button type="button"
                                                                    class="btn
                                                                    btn-sm
                                                                    btn-secondary"
                                                                    disabled>

                                                                Expired
                                                            </button>
                                                    </c:when>

                                                    <c:when test="${not orderEnough}">

                                                        <div class="voucher-status-label
                                                             text-danger">

                                                            Minimum order not reached
                                                        </div>

                                                        <button type="button"
                                                                class="btn
                                                                btn-sm
                                                                btn-secondary"
                                                                disabled>

                                                            Unavailable
                                                        </button>
                                                    </c:when>

                                                    <c:otherwise>

                                                        <form method="post"
                                                              action="${contextPath}/customer/checkout"
                                                              id="checkoutForm">

                                                            <input type="hidden"
                                                                   name="action"
                                                                   value="placeOrder">

                                                            <input type="hidden"
                                                                   name="voucherCode"
                                                                   value="${fn:escapeXml(voucherCode)}">

                                                            <!-- Các field khác -->

                                                            <button type="submit"
                                                                    class="btn btn-dark w-100">

                                                                <i class="fa-solid fa-lock me-2"></i>
                                                                Place Order
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>

                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="modal-footer">

                        <button type="button"
                                class="btn btn-light"
                                data-bs-dismiss="modal">

                            Close
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>