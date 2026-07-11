<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Voucher Campaign Management - Admin Panel</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
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

        <div class="main-content admin-page">
            <div class="container-fluid">

                <div class="page-header d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="page-title">Voucher Management</h2>
                        <p class="page-subtitle text-muted mb-0">Monitor, filter, and schedule store-wide discount campaigns smoothly</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary font-weight-bold px-4">
                        <i class="fas fa-plus-circle mr-2"></i> Create New Voucher
                    </a>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMessage}"/></div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                </c:if>

                <div class="card mb-4">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="GET">
                            <input type="hidden" name="action" value="list">
                            <div class="row align-items-end">
                                <div class="form-group col-md-5 mb-0">
                                    <label class="font-weight-bold text-secondary">Search Criteria</label>
                                    <input type="text" class="form-control" name="search" placeholder="Enter Campaign Code or Title..." value="${param.search}">
                                </div>
                                <div class="form-group col-md-4 mb-0">
                                    <label class="font-weight-bold text-secondary">Filter by Lifecycle Status</label>
                                    <select class="form-control" name="status">
                                        <option value="ALL" ${param.status == 'ALL' ? 'selected' : ''}>All Statuses</option>
                                        <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active Only</option>
                                        <option value="UPCOMING" ${param.status == 'UPCOMING' ? 'selected' : ''}>Upcoming Schemes</option>
                                        <option value="EXPIRED" ${param.status == 'EXPIRED' ? 'selected' : ''}>Expired Records</option>
                                        <option value="EXHAUSTED" ${param.status == 'EXHAUSTED' ? 'selected' : ''}>Fully Exhausted</option>
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

                <div class="card admin-card">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 admin-table">
                                <thead>
                                    <tr>
                                        <th class="border-top-0 px-4">Code</th>
                                        <th class="border-top-0">Campaign Details & Scope</th>
                                        <th class="border-top-0">Discount Incentives</th>
                                        <th class="border-top-0">Min Order</th>
                                        <th class="border-top-0">Metrics (Used/Total/User)</th>
                                        <th class="border-top-0">Validity Period</th>
                                        <th class="border-top-0">Status</th>
                                        <th class="border-top-0 text-center px-4">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <jsp:useBean id="now" class="java.util.Date" />
                                    <c:choose>
                                        <c:when test="${not empty voucherList}">
                                            <c:forEach var="v" items="${voucherList}">
                                                <c:set var="isExhausted" value="${v.usedCount >= v.usageLimit}" />
                                                <c:set var="isUpcoming" value="${now.time < v.startDate.time}" />
                                                <c:set var="isExpired" value="${now.time > v.endDate.time}" />

                                                <tr>
                                                    <td class="px-4">
                                                        <span class="badge badge-light border text-dark font-weight-bold p-2">${v.code}</span>
                                                    </td>
                                                    <td>
                                                        <div class="font-weight-bold text-dark">${v.title}</div>
                                                        <div class="mt-1">
                                                            <c:choose>
                                                                <c:when test="${v.categoryId == null}">
                                                                    <span class="badge badge-secondary"><i class="fas fa-globe mr-1"></i> Global Scale</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-info"><i class="fas fa-folder mr-1"></i> Category Restricted</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <c:if test="${not empty v.terminateReason}">
                                                            <div class="text-danger small mt-2 bg-light p-1 rounded border">
                                                                <strong><i class="fas fa-ban mr-1"></i> Terminated Reason:</strong> ${v.terminateReason}
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.discountType == 'PERCENTAGE'}">
                                                                <span class="text-success font-weight-bold">${v.discountValue}% Off</span>
                                                                <div class="small text-muted">Max: <fmt:formatNumber value="${v.maxDiscountAmount}" type="currency" currencySymbol="đ"/></div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-success font-weight-bold"><fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="đ"/> Off</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="đ"/></td>
                                                    <td>
                                                        <div class="font-weight-bold">${v.usedCount} / ${v.usageLimit} Used</div>
                                                        <div class="small text-muted">Max per User: <strong>${v.limitPerUser}</strong></div>
                                                        <div class="progress progress-sm mt-1" style="height: 5px; width: 100px;">
                                                            <div class="progress-bar bg-info" style="width: ${(v.usedCount / v.usageLimit) * 100}%"></div>
                                                        </div>
                                                    </td>
                                                    <td class="small text-secondary">
                                                        <div><strong>Start:</strong> <fmt:formatDate value="${v.startDate}" pattern="yyyy-MM-dd HH:mm"/></div>
                                                        <div><strong>End:</strong> <fmt:formatDate value="${v.endDate}" pattern="yyyy-MM-dd HH:mm"/></div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${isExhausted}"><span class="badge badge-exhausted p-2 font-weight-bold">Exhausted</span></c:when>
                                                            <c:when test="${isUpcoming}"><span class="badge badge-upcoming p-2 font-weight-bold">Upcoming</span></c:when>
                                                            <c:when test="${isExpired}"><span class="badge badge-expired p-2 font-weight-bold">Expired</span></c:when>
                                                            <c:otherwise><span class="badge badge-active p-2 font-weight-bold">Active</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center px-4">
                                                        <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${v.id}" class="btn btn-sm btn-outline-primary mr-1" title="Edit Properties">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <button class="btn btn-sm btn-outline-danger" title="Graceful Early Termination" 
                                                                onclick="openTerminateModal(${v.id}, '${v.code}')" ${(isExpired || isExhausted) ? 'disabled' : ''}>
                                                            <i class="fas fa-stop-circle"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="text-center py-5 text-muted">
                                                    <i class="fas fa-ticket-alt fa-3x mb-3"></i>
                                                    <p class="mb-0">No vouchers matching your filter conditions were found.</p>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
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
                        <h5 class="modal-title font-weight-bold" id="terminateModalLabel"><i class="fas fa-exclamation-triangle mr-2"></i> Graceful Early Termination</h5>
                        <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/voucher" method="POST">
                        <input type="hidden" name="action" value="terminate">
                        <div class="modal-body">
                            <input type="hidden" id="terminateVoucherId" name="id">
                            <p>You are scheduling an advanced early termination schedule for voucher campaign: <strong id="terminateVoucherCode" class="text-danger"></strong></p>

                            <div class="form-group">
                                <label for="daysLeft" class="font-weight-bold">Remaining Buffer Timeline <span class="text-danger">*</span></label>
                                <select class="form-control" id="daysLeft" name="daysLeft">
                                    <option value="1">1 Day Left (Concludes exactly in 24 hours)</option>
                                    <option value="2" selected>2 Days Left (Concludes in 48 hours buffer)</option>
                                    <option value="3">3 Days Left Grace Period</option>
                                    <option value="5">5 Days Left Grace Period</option>
                                </select>
                                <small class="text-muted">The code remains safely redeemable during this buffer timeline for shoppers completing transactions.</small>
                            </div>

                            <div class="form-group">
                                <label for="reason" class="font-weight-bold">Termination Notice Reason <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="reason" name="reason" rows="3" required 
                                          placeholder="Provide transparent explanation for system audit logs (e.g., Budget limits reached, business direction shift)"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light border" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-danger font-weight-bold">Confirm & Schedule Close</button>
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