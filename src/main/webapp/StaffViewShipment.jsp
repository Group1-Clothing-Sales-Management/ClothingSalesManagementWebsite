<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Trạng Thế Giao Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container-fluid">
    <div class="row">
        <jsp:include page="/view/admin/sidebar.jsp">
            <jsp:param name="activeTab" value="shipments" />
        </jsp:include>

        <div class="col-md-10 py-5 px-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="text-dark fw-bold">Quản Lý Trạng Thái Giao Hàng</h2>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">Quay lại Dashboard</a>
            </div>

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>

            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/staff/shipments" method="GET" class="row g-3">
                        <div class="col-md-5">
                            <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Tìm kiếm theo mã đơn, tên khách hàng...">
                        </div>
                        <div class="col-md-4">
                            <select name="status" class="form-select">
                                <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>-- Tất cả trạng thái giao dịch --</option>
                                <option value="PENDING_PICKUP" ${selectedStatus == 'PENDING_PICKUP' ? 'selected' : ''}>Chờ lấy hàng</option>
                                <option value="SHIPPING" ${selectedStatus == 'SHIPPING' ? 'selected' : ''}>Đang giao hàng</option>
                                <option value="DELIVERED" ${selectedStatus == 'DELIVERED' ? 'selected' : ''}>Giao thành công</option>
                                <option value="FAILED" ${selectedStatus == 'FAILED' ? 'selected' : ''}>Giao thất bại</option>
                            </select>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button type="submit" class="btn btn-primary">Tìm kiếm & Lọc</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped mb-0 align-middle">
                            <thead class="table-dark">
                                <tr>
                                    <th>Mã Đơn Hàng</th>
                                    <th>Người Nhận</th>
                                    <th>Địa Chỉ Giao Hàng</th>
                                    <th>Đơn Vị VC</th>
                                    <th>Ngày Giao Dự Kiến</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-center">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty shipments}">
                                        <tr>
                                            <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy bản ghi vận chuyển nào phù hợp.</td>
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
                                                        <c:when test="${s.shippingStatus == 'DELIVERED'}"><span class="badge bg-success">Thành công</span></c:when>
                                                        <c:when test="${s.shippingStatus == 'SHIPPING'}"><span class="badge bg-primary">Đang giao</span></c:when>
                                                        <c:when test="${s.shippingStatus == 'PENDING_PICKUP'}"><span class="badge bg-warning text-dark">Chờ lấy hàng</span></c:when>
                                                        <c:otherwise><span class="badge bg-danger">Thất bại</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${s.shippingStatus == 'SHIPPING'}">
                                                            <a href="${pageContext.request.contextPath}/staff/shipments?action=confirmForm&id=${s.shipmentId}" class="btn btn-sm btn-success">Xác nhận kết quả</a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-sm btn-secondary" disabled>Đã hoàn thành</button>
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
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>