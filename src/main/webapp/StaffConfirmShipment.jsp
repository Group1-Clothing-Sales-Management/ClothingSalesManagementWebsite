<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập Nhật Kết Quả Giao Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container-fluid">
    <div class="row">
        <jsp:include page="/view/admin/sidebar.jsp">
            <jsp:param name="activeTab" value="shipments" />
        </jsp:include>

        <div class="col-md-10 py-5 px-4 d-flex justify-content-center align-items-start">
            <div class="card shadow w-100" style="max-width: 700px;">
                <div class="card-header bg-dark text-white">
                    <h4 class="mb-0">Cập Nhật Kết Quả Giao Hàng</h4>
                </div>
                <div class="card-body">
                    <c:if test="${not empty errorMsg}">
                        <div class="alert alert-danger">${errorMsg}</div>
                    </c:if>

                    <h5 class="text-primary mb-3">Thông Tin Vận Chuyển</h5>
                    <table class="table table-bordered bg-white">
                        <tr>
                            <th width="35%">Mã Đơn Hàng</th>
                            <td><strong>${shipment.orderCode}</strong></td>
                        </tr>
                        <tr>
                            <th>Tên Người Nhận</th>
                            <td>${shipment.customerName}</td>
                        </tr>
                        <tr>
                            <th>Địa Chỉ Giao Hàng</th>
                            <td>${shipment.deliveryAddress}</td>
                        </tr>
                    </table>

                    <form action="${pageContext.request.contextPath}/staff/shipments?action=confirmDelivery" method="POST" class="mt-4">
                        <input type="hidden" name="id" value="${shipment.shipmentId}">
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Kết quả giao hàng <span class="text-danger">*</span></label>
                            <div class="card p-3">
                                <div class="form-check mb-2">
                                    <input class="form-check-input" type="radio" name="outcome" id="successRadio" value="DELIVERED" required>
                                    <label class="form-check-label text-success fw-bold" for="successRadio">
                                        Giao hàng thành công (Đơn hàng hoàn thành)
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="outcome" id="failedRadio" value="FAILED" required>
                                    <label class="form-check-label text-danger fw-bold" for="failedRadio">
                                        Giao hàng thất bại (Hủy / Hoàn đơn)
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="remarks" class="form-label fw-bold">Ghi chú từ nhân viên</label>
                            <textarea class="form-control" id="remarks" name="remarks" rows="3" placeholder="Nhập lý do giao hàng thất bại hoặc ghi chú thêm nếu có..."></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2 mt-4">
                            <a href="${pageContext.request.contextPath}/staff/shipments" class="btn btn-outline-secondary">Quay lại</a>
                            <button type="submit" class="btn btn-primary">Xác nhận kết quả</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>