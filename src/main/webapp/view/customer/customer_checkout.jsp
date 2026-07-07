<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>

    <head>

        <meta charset="UTF-8">
        <title>Checkout</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
              rel="stylesheet">

        <style>

            body{
                background:#f4f6f9;
                font-family:'Segoe UI',sans-serif;
            }

            .page-title{
                font-size:34px;
                font-weight:700;
                color:#212529;
            }

            .page-subtitle{
                color:#6c757d;
                margin-bottom:30px;
            }

            .card{
                border:none;
                border-radius:18px;
                box-shadow:0 8px 25px rgba(0,0,0,.06);
                overflow:hidden;
            }

            .card-header{
                background:#fff;
                border-bottom:1px solid #ececec;
                padding:18px 24px;
                font-weight:700;
                font-size:18px;
            }

            .card-body{
                padding:24px;
            }

            .address-item{

                border:1px solid #e8e8e8;
                border-radius:15px;
                padding:18px;
                transition:.25s;
                margin-bottom:15px;
                cursor:pointer;

            }

            .address-item:hover{

                border-color:#0d6efd;
                background:#f8fbff;

            }

            .address-item input{

                margin-top:6px;

            }

            .recipient{

                font-size:18px;
                font-weight:700;

            }

            .address-info{

                color:#6c757d;
                margin-top:6px;

            }

            .default-badge{

                background:#198754;
                color:#fff;
                padding:7px 12px;
                border-radius:30px;
                font-size:12px;

            }

            .btn-manage{

                border-radius:12px;
                padding:9px 18px;

            }

            .btn-back{

                border-radius:12px;

            }

            .form-control{

                border-radius:12px;

            }

            textarea{

                resize:none;

            }

            .summary-row{

                display:flex;
                justify-content:space-between;
                margin-bottom:12px;

            }

            .total{

                font-size:22px;
                font-weight:bold;
                color:#dc3545;

            }

            .btn-place{

                border-radius:14px;
                padding:12px;
                font-size:17px;
                font-weight:600;

            }

            .table td{

                vertical-align:middle;

            }

        </style>

    </head>

    <body>

        <div class="container py-5">

            <div class="d-flex justify-content-between align-items-center mb-4">

                <div>

                    <div class="page-title">

                        Checkout

                    </div>

                    <div class="page-subtitle">

                        Review your shipping information before placing the order.

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/cart"
                   class="btn btn-outline-secondary btn-back">

                    <i class="bi bi-arrow-left"></i>

                    Back To Cart

                </a>

            </div>

            <form method="post"
                  action="${pageContext.request.contextPath}/customer/checkout">

                <div class="row">

                    <!-- LEFT -->

                    <div class="col-lg-8">

                        <!-- ADDRESS -->

                        <div class="card mb-4">

                            <div class="card-header">

                                <div class="d-flex justify-content-between align-items-center">

                                    <span>

                                        <i class="bi bi-geo-alt-fill text-danger"></i>

                                        Shipping Address

                                    </span>

                                    <a href="${pageContext.request.contextPath}/customer/address?from=checkout"
                                       class="btn btn-outline-primary btn-manage">

                                        <i class="bi bi-pencil-square"></i>

                                        Manage Address

                                    </a>

                                </div>

                            </div>

                            <div class="card-body">

                                <c:forEach items="${addresses}" var="a">

                                    <label class="address-item d-block">

                                        <div class="form-check">

                                            <input class="form-check-input"
                                                   type="radio"
                                                   name="addressId"
                                                   value="${a.id}"

                                                   <c:if test="${a.isDefault()}">
                                                       checked
                                                   </c:if>>

                                            <div class="ms-4">

                                                <div class="d-flex justify-content-between">

                                                    <div>

                                                        <div class="recipient">

                                                            <i class="bi bi-person-circle"></i>

                                                            ${a.recipientName}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-telephone-fill"></i>

                                                            ${a.recipientPhone}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-house-door-fill"></i>

                                                            ${a.addressDetail}

                                                        </div>

                                                        <div class="address-info">

                                                            <i class="bi bi-pin-map-fill"></i>

                                                            Ward :

                                                            ${a.wardId}

                                                        </div>

                                                    </div>

                                                    <div>

                                                        <c:if test="${a.isDefault()}">

                                                            <span class="default-badge">

                                                                <i class="bi bi-check-circle-fill"></i>

                                                                Default

                                                            </span>

                                                        </c:if>

                                                    </div>

                                                </div>

                                            </div>

                                        </div>

                                    </label>

                                </c:forEach>

                            </div>

                        </div>
                        <!-- PRODUCTS -->

                        <div class="card mb-4">

                            <div class="card-header">

                                <i class="bi bi-bag-check-fill text-primary"></i>

                                Products

                            </div>

                            <div class="card-body p-0">

                                <table class="table table-hover align-middle mb-0">

                                    <thead class="table-light">

                                        <tr>

                                            <th>Product</th>

                                            <th width="130">Price</th>

                                            <th width="90">Quantity</th>

                                            <th width="140">Total</th>

                                        </tr>

                                    </thead>

                                    <tbody>

                                        <c:forEach items="${cartItems}" var="item">

                                            <tr>

                                                <td>

                                                    <div class="fw-bold">

                                                        ${item.productName}

                                                    </div>

                                                </td>

                                                <td>

                                                    ${item.price}

                                                </td>

                                                <td>

                                                    <span class="badge bg-secondary">

                                                        x${item.quantity}

                                                    </span>

                                                </td>

                                                <td>

                                                    <strong>

                                                        ${item.price * item.quantity}

                                                    </strong>

                                                </td>

                                            </tr>

                                        </c:forEach>

                                    </tbody>

                                </table>

                            </div>

                        </div>

                    </div>

                    <!-- RIGHT -->

                    <div class="col-lg-4">

                        <div class="card sticky-top"
                             style="top:25px;">

                            <div class="card-header">

                                <i class="bi bi-receipt-cutoff text-success"></i>

                                Order Summary

                            </div>

                            <div class="card-body">

                                <div class="mb-3">

                                    <label class="form-label fw-semibold">

                                        Voucher Code

                                    </label>

                                    <input
                                        type="text"
                                        class="form-control"
                                        name="voucherCode"
                                        placeholder="Enter voucher...">

                                </div>
                                <div class="mb-3">

                                    <label class="form-label fw-semibold">
                                        Payment Method
                                    </label>

                                    <div class="form-check">
                                        <input class="form-check-input"
                                               type="radio"
                                               name="paymentMethod"
                                               value="COD"
                                               checked>
                                        <label class="form-check-label">
                                            Cash on Delivery
                                        </label>
                                    </div>

                                    <div class="form-check">
                                        <input class="form-check-input"
                                               type="radio"
                                               name="paymentMethod"
                                               value="VNPAY">
                                        <label class="form-check-label">
                                            VNPay Online
                                        </label>
                                    </div>

                                </div>

                                <div class="mb-3">

                                    <label class="form-label fw-semibold">

                                        Order Note

                                    </label>

                                    <textarea
                                        class="form-control"
                                        rows="4"
                                        name="note"
                                        placeholder="Write something for the shop..."></textarea>

                                </div>

                                <hr>

                                <div class="summary-row">

                                    <span>

                                        Subtotal

                                    </span>

                                    <strong>

                                        ${cartTotal}

                                    </strong>

                                </div>

                                <div class="mb-3">

                                    <label class="form-label fw-semibold">
                                        Shipping Method
                                    </label>

                                    <select class="form-select" name="carrierName">

                                        <option value="GHN">
                                            Giao Hàng Nhanh (GHN)
                                        </option>

                                        <option value="GHTK">
                                            Giao Hàng Tiết Kiệm (GHTK)
                                        </option>

                                        <option value="STORE">
                                            Tự giao hàng
                                        </option>

                                    </select>

                                </div>

                                <hr>

                                <div class="summary-row total">

                                    <span>

                                        Total

                                    </span>

                                    <span>

                                        ${cartTotal}

                                    </span>

                                </div>

                                <div class="d-grid mt-4">

                                    <button
                                        type="submit"
                                        class="btn btn-success btn-place">

                                        <i class="bi bi-credit-card-fill"></i>

                                        Place Order

                                    </button>

                                </div>

                            </div>

                        </div>

                    </div>

                </div>

            </form>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    </body>

</html>