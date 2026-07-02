<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Voucher Management - Admin</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <style>
            .wrapper {
                display: flex;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                background-color: #f4f6f9;
                min-height: 100vh;
            }
            .card {
                border: none;
                border-radius: 8px;
                box-shadow: 0 0 15px rgba(0,0,0,0.05);
            }
            .table th {
                background-color: #f8f9fa;
                color: #495057;
            }
            .badge-active {
                background-color: #28a745;
                color: white;
            }
            .badge-upcoming {
                background-color: #007bff;
                color: white;
            }
            .badge-expired {
                background-color: #dc3545;
                color: white;
            }
            .badge-exhausted {
                background-color: #6c757d;
                color: white;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="discounts" />
        </jsp:include>

        <div class="main-content">
            <div class="container-fluid">

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="font-weight-bold">Voucher Management</h2>
                        <p class="text-muted mb-0">Create, monitor, and manage discount campaigns smoothly</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary font-weight-bold px-4">
                        <i class="fas fa-plus-circle mr-2"></i> Create New Voucher
                    </a>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show card p-3 mb-4 border-left border-success">
                        <i class="fas fa-check-circle mr-2"></i> ${successMessage}
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show card p-3 mb-4 border-left border-danger">
                        <i class="fas fa-exclamation-circle mr-2"></i> ${errorMessage}
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>

                <div class="card mb-4">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="GET">
                            <input type="hidden" name="action" value="list">
                            <div class="row align-items-end">
                                <div class="form-group col-md-5 mb-0">
                                    <label class="font-weight-bold text-secondary">Search Voucher</label>
                                    <input type="text" class="form-control" name="search" placeholder="Enter Code or Campaign Title..." value="${param.search}">
                                </div>
                                <div class="form-group col-md-4 mb-0">
                                    <label class="font-weight-bold text-secondary">Filter by Status</label>
                                    <select class="form-control" name="status">
                                        <option value="ALL" ${param.status == 'ALL' ? 'selected' : ''}>All Status</option>
                                        <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                        <option value="UPCOMING" ${param.status == 'UPCOMING' ? 'selected' : ''}>Upcoming</option>
                                        <option value="EXPIRED" ${param.status == 'EXPIRED' ? 'selected' : ''}>Expired</option>
                                        <option value="EXHAUSTED" ${param.status == 'EXHAUSTED' ? 'selected' : ''}>Exhausted</option>
                                    </select>
                                </div>
                                <div class="form-group col-md-3 mb-0">
                                    <button type="submit" class="btn btn-dark btn-block font-weight-bold">
                                        <i class="fas fa-filter mr-2"></i> Apply Filters
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Voucher</th>
                                        <th>Title</th>
                                        <th>Start Day</th>
                                        <th>End Day</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${voucherList}" var="v">
                                        <tr>
                                            <td>${v.id}</td>
                                            <td><span class="badge bg-secondary">${v.code}</span></td>
                                            <td>${v.title}</td>
                                            <td>${v.startDate}</td>
                                            <td>${v.endDate}</td>
                                            <td>
                                                <a href="${pageContext.request.getContextPath()}/admin/voucher?action=detail&id=${v.id}" 
                                                   class="btn btn-sm btn-info text-white">
                                                    <i class="fas fa-eye"></i> View
                                                </a>

                                                <a href="${pageContext.request.getContextPath()}/admin/voucher?action=edit&id=${v.id}" 
                                                   class="btn btn-sm btn-warning text-white">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>

                                                <button type="button" class="btn btn-sm btn-danger text-white" 
                                                        data-toggle="modal" data-target="#terminateModal${v.id}">
                                                    <i class="fas fa-trash-alt"></i> Delete
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>  
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <div class="modal fade" id="terminateModal" tabindex="-1" role="dialog" aria-labelledby="terminateModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title font-weight-bold" id="terminateModalLabel">Graceful Voucher Termination</h5>
                        <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/voucher?action=terminate" method="POST">
                        <div class="modal-body">
                            <input type="hidden" id="terminateVoucherId" name="id">
                            <p>You are scheduling an early termination for voucher: <strong id="terminateVoucherCode" class="text-danger"></strong></p>

                            <div class="form-group">
                                <label for="daysLeft" class="font-weight-bold">Remaining Grace Period <span class="text-danger">*</span></label>
                                <select class="form-control" id="daysLeft" name="daysLeft">
                                    <option value="1">1 Day left (Concludes in 24 hours)</option>
                                    <option value="2" selected>2 Days left (Concludes in 48 hours)</option>
                                    <option value="3">3 Days left</option>
                                    <option value="5">5 Days left</option>
                                </select>
                                <small class="text-muted">The campaign remains safe and active during this buffer timeline for active shoppers.</small>
                            </div>

                            <div class="form-group">
                                <label for="reason" class="font-weight-bold">Termination Notice Reason <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="reason" name="reason" rows="3" required 
                                          placeholder="Provide transparent reasons for customers (e.g., Supply limit reached, technical adjustment)"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light border" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-danger font-weight-bold">Confirm & Schedule</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            function openTerminateModal(id, code) {
                document.getElementById("terminateVoucherId").value = id;
                document.getElementById("terminateVoucherCode").innerText = code;
                $('#terminateModal').modal('show');
            }
        </script>
    </body>
</html>
