<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shipment Status Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="shipments" />
</jsp:include>

        <div class="admin-page">
            <div class="page-header">
                <div>
                    <h2 class="page-title">Shipment Status Management</h2>
                    <p class="page-subtitle mb-0">Review shipments and update delivery progress from one place.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">Dashboard</a>
            </div>

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${sessionScope.successMsg}"/></div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${sessionScope.errorMsg}"/></div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>

            <div class="card card-main admin-card mb-4">
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/staff/shipments" method="GET" class="row g-3">
                        <div class="col-md-5">
                            <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Search by order code, recipient name...">
                        </div>
                        <div class="col-md-4">
                            <select name="status" class="form-select">
                                <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>-- All Statuses --</option>
                                <option value="PENDING_PICKUP" ${selectedStatus == 'PENDING_PICKUP' ? 'selected' : ''}>Pending Pickup</option>
                                <option value="SHIPPING" ${selectedStatus == 'SHIPPING' ? 'selected' : ''}>In Transit</option>
                                <option value="SUCCESS" ${selectedStatus == 'SUCCESS' ? 'selected' : ''}>Success</option>
                                <option value="FAILURE" ${selectedStatus == 'FAILURE' ? 'selected' : ''}>Failure</option>
                            </select>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button type="submit" class="btn btn-primary">Search & Filter</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card card-main admin-card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped mb-0 align-middle admin-table">
                            <thead class="table-dark">
                                <tr>
                                    <th>Order Code</th>
                                    <th>Recipient</th>
                                    <th>Delivery Address</th>
                                    <th>Carrier</th>
                                    <th>Est. Delivery Time</th>
                                    <th>Status</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty shipments}">
                                        <tr>
                                            <td colspan="7" class="text-center py-4 text-muted">No shipment records found.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="s" items="${shipments}">
                                            <tr>
                                                <td><strong>${s.orderCode}</strong></td>
                                                <td>${s.customerName}<br><small class="text-muted">${s.customerPhone}</small></td>
                                                <td><span class="d-inline-block text-truncate" style="max-width: 250px;" title="${s.deliveryAddress}">${s.deliveryAddress}</span></td>
                                                <td>${s.carrierName}</td>
                                                <td>${s.estimatedDeliveryTime}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${s.shippingStatus == 'PENDING_PICKUP'}"><span class="badge bg-warning text-dark">Pending Pickup</span></c:when>
                                                        <c:when test="${s.shippingStatus == 'SHIPPING'}"><span class="badge bg-primary">In Transit</span></c:when>
                                                        <c:when test="${s.shippingStatus == 'SUCCESS'}"><span class="badge bg-success">Success</span></c:when>
                                                        <c:otherwise><span class="badge bg-danger">Failure</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
    <c:choose>
        <c:when test="${s.shippingStatus == 'SUCCESS' || s.shippingStatus == 'SUCCESSFUL' || s.shippingStatus == 'Success' || s.shippingStatus == 'FAILURE' || s.shippingStatus == 'Failure' || s.shippingStatus == 'FAILED'}">
            <button class="btn btn-sm btn-secondary" disabled>Completed</button>
        </c:when>
        <c:otherwise>
            <a href="${pageContext.request.contextPath}/staff/shipments?action=confirmForm&id=${s.shipmentId}" class="btn btn-sm btn-success">Update Status</a>
        </c:otherwise>
    </c:choose>
</td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
