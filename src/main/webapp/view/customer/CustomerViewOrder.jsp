<%@page contentType="text/html"
        pageEncoding="UTF-8"%>

<%@taglib prefix="c"
          uri="jakarta.tags.core"%>
<%@taglib prefix="fmt"
          uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>

        <title>My Orders</title>

        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
            rel="stylesheet">

        <link
            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            rel="stylesheet">

        <style>

            body{
                background:#f5f5f5;
            }

            .order-container{
                max-width:1100px;
                margin:auto;
            }

            .order-tabs{
                background:white;
                border-radius:10px;
                padding:0;
                overflow:hidden;
                box-shadow:0 2px 10px rgba(0,0,0,.05);
            }

            .order-tabs .nav-link{
                color:#555;
                font-weight:600;
                padding:15px 25px;
                border:none;
            }

            .order-tabs .nav-link.active{
                color:#ee4d2d;
                border-bottom:3px solid #ee4d2d;
                background:white;
            }

            .order-card{
                background:white;
                border-radius:12px;
                padding:20px;
                margin-top:15px;
                box-shadow:0 2px 8px rgba(0,0,0,.05);
            }

            .order-top{
                display:flex;
                justify-content:space-between;
                align-items:center;
                border-bottom:1px solid #eee;
                padding-bottom:10px;
                margin-bottom:15px;
            }

            .order-code{
                font-weight:700;
            }

            .status{
                color:#ee4d2d;
                font-weight:600;
            }

            .order-info{
                display:flex;
                justify-content:space-between;
                flex-wrap:wrap;
                gap:10px;
            }

            .total-price{
                font-size:20px;
                font-weight:bold;
                color:#ee4d2d;
            }

            .order-actions{
                margin-top:15px;
                text-align:right;
            }

        </style>

    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>
        <div class="container mt-4">

            <h2>My Orders</h2>
            <div class="mb-4">

                <a href="${pageContext.request.contextPath}/customer/orders"
                   class="btn ${empty param.status ? 'btn-primary' : 'btn-outline-primary'}">
                    Tất cả
                </a>

                <a href="?status=PENDING"
                   class="btn ${param.status eq 'PENDING' ? 'btn-warning' : 'btn-outline-warning'}">
                    Chờ xác nhận
                </a>

                <a href="?status=CONFIRMED"
                   class="btn ${param.status eq 'CONFIRMED' ? 'btn-info' : 'btn-outline-info'}">
                    Chờ vận chuyển
                </a>

                <a href="?status=SHIPPING"
                   class="btn ${param.status eq 'SHIPPING' ? 'btn-secondary' : 'btn-outline-secondary'}">
                    Chờ nhận hàng
                </a>

                <a href="?status=CANCELLED"
                   class="btn ${param.status eq 'CANCELLED' ? 'btn-danger' : 'btn-outline-danger'}">
                    Đã hủy
                </a>

            </div>

            <a href="${pageContext.request.contextPath}/"
               class="btn btn-primary mb-3">

                Home

            </a>

            <a href="${pageContext.request.contextPath}/cart"
               class="btn btn-secondary mb-3">

                Cart

            </a>

            <c:forEach items="${orders}" var="o">

                <c:if test="${empty param.status || o.orderStatus eq param.status}">

                    <div class="order-card">

                        <div class="order-top">

                            <div>

                                <div class="order-code">

                                    Order #${o.orderCode}

                                </div>

                                <small class="text-muted">

                                    ${o.createdAt}

                                </small>

                            </div>

                            <div class="status">

                                <c:out value="${not empty o.displayStatusLabel ? o.displayStatusLabel : o.orderStatus}"/>

                            </div>

                        </div>

                        <div class="order-info">

                            <div>

                                <strong>Total:</strong><br>

                                <span class="total-price">

                                    <fmt:formatNumber
                                        value="${o.totalPayment}"
                                        pattern="#,##0"/> VND

                                </span>

                            </div>

                            <div>

                                <strong>Shipping</strong><br>

                                <c:choose>

                                    <c:when test="${not empty o.shippingStatusLabel}">

                                        ${o.shippingStatusLabel}

                                    </c:when>

                                    <c:otherwise>

                                        N/A

                                    </c:otherwise>

                                </c:choose>

                            </div>

                        </div>

                        <div class="order-actions">
                            <c:if test="${o.orderStatus eq 'PENDING'}">

                                <form method="post"
                                      action="${pageContext.request.contextPath}/customer/cancel-order"
                                      style="display:inline">

                                    <input type="hidden"
                                           name="orderId"
                                           value="${o.id}">

                                    <button class="btn btn-danger">

                                        Cancel Order

                                    </button>

                                </form>

                            </c:if>

                        </div>

                    </div>

                </c:if>

            </c:forEach>

        </div>

    </body>

</html>
