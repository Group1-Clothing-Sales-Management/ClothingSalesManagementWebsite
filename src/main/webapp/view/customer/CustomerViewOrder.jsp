<%@page contentType="text/html"
        pageEncoding="UTF-8"%>

<%@taglib prefix="c"
          uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>
    <head>

        <title>My Orders</title>

        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
            rel="stylesheet">

    </head>

    <body>

        <div class="container mt-4">

            <h2>My Orders</h2>

            <a href="${pageContext.request.contextPath}/"
               class="btn btn-primary mb-3">

                Home

            </a>

            <a href="${pageContext.request.contextPath}/cart"
               class="btn btn-secondary mb-3">

                Cart

            </a>

            <table class="table table-bordered">

                <thead>

                    <tr>

                        <th>ID</th>
                        <th>Code</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Action</th>

                    </tr>

                </thead>

                <tbody>

                <c:forEach items="${orders}"
                           var="o">

                    <tr>

                        <td>${o.id}</td>

                        <td>${o.orderCode}</td>

                        <td>${o.totalPayment}</td>

                        <td>${o.orderStatus}</td>

                        <td>${o.createdAt}</td>

                        <td>

                    <c:if test="${o.orderStatus eq 'PENDING'}">

                        <form method="post"
                              action="${pageContext.request.contextPath}/customer/cancel-order">

                            <input type="hidden"
                                   name="orderId"
                                   value="${o.id}">

                            <button
                                class="btn btn-danger btn-sm">

                                Cancel

                            </button>

                        </form>

                    </c:if>

                    </td>

                    </tr>

                </c:forEach>

                </tbody>

            </table>

        </div>

    </body>

</html>