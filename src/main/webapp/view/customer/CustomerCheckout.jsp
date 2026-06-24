<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>

    <head>

        <meta charset="UTF-8">

        <title>Checkout</title>

        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
            rel="stylesheet">

    </head>

    <body>

        <div class="container mt-4">

            <h2 class="mb-4">
                Checkout
            </h2>

            <form method="post"
                  action="${pageContext.request.contextPath}/customer/checkout">

                <div class="row">

                    <!-- LEFT -->

                    <div class="col-md-8">

                        <!-- ADDRESS -->

                        <div class="card mb-3">
                            <div class="card-header">

                                <div class="d-flex justify-content-between align-items-center">

                                    <span>Shipping Address</span>

                                    <a href="${pageContext.request.contextPath}/customer/address?from=checkout"
                                       class="btn btn-light btn-sm">

                                        Manage Address

                                    </a>

                                </div>

                            </div>
                            <div class="card-body">

                                <c:forEach items="${addresses}" var="a">

                                    <div class="form-check mb-3">

                                        <input
                                            class="form-check-input"
                                            type="radio"
                                            name="addressId"
                                            value="${a.id}"

                                            <c:if test="${a.isDefault()}">
                                                checked="checked"
                                            </c:if>
                                            >

                                        <label class="form-check-label">

                                            <strong>
                                                ${a.recipientName}
                                            </strong>

                                            -
                                            ${a.recipientPhone}

                                            <br>

                                            ${a.addressDetail}

                                            <br>

                                            Ward :
                                            ${a.wardId}

                                            <c:if test="${a.isDefault()}">

                                                <span class="badge bg-success">
                                                    Default
                                                </span>

                                            </c:if>

                                        </label>

                                    </div>

                                </c:forEach>

                            </div>

                        </div>

                        <!-- PRODUCTS -->

                        <div class="card">

                            <div class="card-header">
                                Products
                            </div>

                            <div class="card-body">

                                <table class="table table-bordered">

                                    <thead>

                                        <tr>

                                            <th>Product</th>
                                            <th>Price</th>
                                            <th>Qty</th>
                                            <th>Total</th>

                                        </tr>

                                    </thead>

                                    <tbody>

                                        <c:forEach items="${cartItems}" var="item">

                                            <tr>

                                                <td>
                                                    ${item.productName}
                                                </td>

                                                <td>
                                                    ${item.price}
                                                </td>

                                                <td>
                                                    ${item.quantity}
                                                </td>

                                                <td>
                                                    ${item.price * item.quantity}
                                                </td>

                                            </tr>

                                        </c:forEach>

                                    </tbody>

                                </table>

                            </div>

                        </div>

                    </div>

                    <!-- RIGHT -->

                    <div class="col-md-4">

                        <div class="card">

                            <div class="card-header">
                                Payment Summary
                            </div>

                            <div class="card-body">

                                <div class="mb-3">

                                    <label class="form-label">
                                        Voucher Code
                                    </label>

                                    <input
                                        type="text"
                                        name="voucherCode"
                                        class="form-control"
                                        placeholder="SALE10">

                                </div>

                                <div class="mb-3">

                                    <label class="form-label">
                                        Note
                                    </label>

                                    <textarea
                                        name="note"
                                        rows="3"
                                        class="form-control"></textarea>

                                </div>

                                <hr>

                                <p>

                                    Subtotal :

                                    <strong>
                                        ${cartTotal}
                                    </strong>

                                </p>

                                <p>

                                    Shipping :

                                    <strong>
                                        30000
                                    </strong>

                                </p>

                                <button
                                    type="submit"
                                    class="btn btn-success w-100">

                                    Place Order

                                </button>

                            </div>

                        </div>

                    </div>

                </div>

            </form>

        </div>

    </body>
</html>