<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Voucher Campaign Management - Admin Panel</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
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

        <div class="admin-page voucher-page">
            <div class="container-fluid">

                <div class="page-header">
                    <jsp:include page="/view/admin/common/page_heading.jsp">
                        <jsp:param name="icon" value="fa-solid fa-ticket"/>
                        <jsp:param name="title" value="Voucher Management"/>
                        <jsp:param name="subtitle" value="Monitor, filter, and schedule store-wide discount campaigns."/>
                    </jsp:include>
                    <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary fw-bold px-4">
                        <i class="fa-solid fa-plus-circle me-2"></i> Create New Voucher
                    </a>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMessage}"/></div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                </c:if>

                <div class="card mb-4 voucher-filter-panel">
                    <div class="card-body p-0">
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="GET">
                            <input type="hidden" name="action" value="list">
                            <div class="voucher-filter-grid">
                                <div class="voucher-filter-field voucher-filter-search">
                                    <label class="fw-bold text-secondary">Search Criteria</label>
                                    <input type="text" class="form-control" name="search" placeholder="Enter Campaign Code or Title..." value="${param.search}">
                                </div>
                                <div class="voucher-filter-field voucher-filter-status">
                                    <label class="fw-bold text-secondary">Filter by Lifecycle Status</label>
                                    <select class="form-select" name="status">
                                        <option value="ALL" ${param.status == 'ALL' ? 'selected' : ''}>All Statuses</option>
                                        <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Active Only</option>
                                        <option value="UPCOMING" ${param.status == 'UPCOMING' ? 'selected' : ''}>Upcoming Schemes</option>
                                        <option value="EXPIRED" ${param.status == 'EXPIRED' ? 'selected' : ''}>Expired Records</option>
                                        <option value="EXHAUSTED" ${param.status == 'EXHAUSTED' ? 'selected' : ''}>Fully Exhausted</option>
                                    </select>
                                </div>
                                <div class="voucher-filter-field voucher-filter-actions">
                                    <button type="submit" class="btn btn-dark w-100 fw-bold">
                                        <i class="fa-solid fa-filter me-2"></i> Apply Filters
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
                                                        <span class="badge text-bg-light border text-dark fw-bold p-2">${v.code}</span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-dark">${v.title}</div>
                                                        <div class="mt-1">
                                                            <c:choose>
                                                                <c:when test="${v.categoryId == null}">
                                                                    <span class="badge text-bg-secondary"><i class="fa-solid fa-globe me-1"></i> Global Scale</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-info"><i class="fa-solid fa-folder me-1"></i> Category Restricted</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <c:if test="${not empty v.terminateReason}">
                                                            <div class="text-danger small mt-2 bg-light p-1 rounded border">
                                                                <strong><i class="fa-solid fa-ban me-1"></i> Terminated Reason:</strong> ${v.terminateReason}
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.discountType == 'PERCENTAGE'}">
                                                                <span class="text-success fw-bold">${v.discountValue}% Off</span>
                                                                <div class="small text-muted">Max: <fmt:formatNumber value="${v.maxDiscountAmount}" type="currency" currencySymbol="đ"/></div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-success fw-bold"><fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="đ"/> Off</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="đ"/></td>
                                                    <td>
                                                        <div class="fw-bold">${v.usedCount} / ${v.usageLimit} Used</div>
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
                                                            <c:when test="${isExhausted}"><span class="badge badge-exhausted p-2 fw-bold">Exhausted</span></c:when>
                                                            <c:when test="${isUpcoming}"><span class="badge badge-upcoming p-2 fw-bold">Upcoming</span></c:when>
                                                            <c:when test="${isExpired}"><span class="badge badge-expired p-2 fw-bold">Expired</span></c:when>
                                                            <c:otherwise><span class="badge badge-active p-2 fw-bold">Active</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center px-4">
                                                        <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${v.id}" class="btn btn-sm btn-outline-primary me-1" title="Edit Properties">
                                                            <i class="fa-solid fa-edit"></i>
                                                        </a>
                                                        <button class="btn btn-sm btn-outline-danger" title="Graceful Early Termination" 
                                                                onclick="openTerminateModal(${v.id}, '${v.code}')" ${(isExpired || isExhausted) ? 'disabled' : ''}>
                                                            <i class="fa-solid fa-stop-circle"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="text-center py-5 text-muted">
                                                    <i class="fa-solid fa-ticket-alt fa-3x mb-3"></i>
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
                        <h5 class="modal-title fw-bold" id="terminateModalLabel"><i class="fa-solid fa-exclamation-triangle me-2"></i> Graceful Early Termination</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/voucher" method="POST">
                        <input type="hidden" name="action" value="terminate">
                        <div class="modal-body">
                            <input type="hidden" id="terminateVoucherId" name="id">
                            <p>You are scheduling an advanced early termination schedule for voucher campaign: <strong id="terminateVoucherCode" class="text-danger"></strong></p>

                            <div class="form-group">
                                <label for="daysLeft" class="fw-bold">Remaining Buffer Timeline <span class="text-danger">*</span></label>
                                <select class="form-select" id="daysLeft" name="daysLeft">
                                    <option value="1">1 Day Left (Concludes exactly in 24 hours)</option>
                                    <option value="2" selected>2 Days Left (Concludes in 48 hours buffer)</option>
                                    <option value="3">3 Days Left Grace Period</option>
                                    <option value="5">5 Days Left Grace Period</option>
                                </select>
                                <small class="text-muted">The code remains safely redeemable during this buffer timeline for shoppers completing transactions.</small>
                            </div>

                            <div class="form-group">
                                <label for="reason" class="fw-bold">Termination Notice Reason <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="reason" name="reason" rows="3" required 
                                          placeholder="Provide transparent explanation for system audit logs (e.g., Budget limits reached, business direction shift)"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-danger fw-bold">Confirm & Schedule Close</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                                                    function openTerminateModal(id, code) {
                                                                        document.getElementById("terminateVoucherId").value = id;
                                                                        document.getElementById("terminateVoucherCode").innerText = code;
                                                                        bootstrap.Modal.getOrCreateInstance(document.getElementById("terminateModal")).show();
                                                                    }
        </script>
    </body>
</html>