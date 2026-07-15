<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shipment Status Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        .table { table-layout: fixed; }
        .table td { vertical-align: middle; height: 64px; }
        .note-failure {
            font-size: .8rem;
            color: #991b1b;
            background: #fee2e2;
            border: 1px solid #fca5a5;
            border-radius: 6px;
            padding: 4px 8px;
            margin-top: 4px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="shipments" />
</jsp:include>

        <div class="py-5 px-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="text-dark fw-bold">Shipment Status Management</h2>
            </div>

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1080;">
                    <div id="successToast" class="toast align-items-center text-white bg-success border-0 shadow" role="alert" aria-live="assertive" aria-atomic="true">
                        <div class="d-flex">
                            <div class="toast-body d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill"></i> ${sessionScope.successMsg}
                            </div>
                            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                        </div>
                    </div>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>

            <div class="card shadow-sm mb-4">
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

            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped mb-0 align-middle">
                            <colgroup>
                                <col style="width:10%">
                                <col style="width:16%">
                                <col style="width:20%">
                                <col style="width:10%">
                                <col style="width:12%">
                                <col style="width:13%">
                                <col style="width:10%">
                                <col style="width:9%">
                            </colgroup>
                            <thead class="table-dark">
                                <tr>
                                    <th>Order Code</th>
                                    <th>Recipient</th>
                                    <th>Delivery Address</th>
                                    <th>Carrier</th>
                                    <th>Est. Delivery Time</th>
                                    <th>Status</th>
                                    <th>Note</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody id="shipmentTable">
                                <c:choose>
                                    <c:when test="${empty shipments}">
                                        <tr>
                                            <td colspan="8" class="text-center py-4 text-muted">No shipment records found.</td>
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
                                                <td>
    <c:choose>
        <c:when test="${s.shippingStatus == 'FAILURE' and not empty s.note}">
            <div class="note-failure">${s.note}</div>
        </c:when>
        <c:otherwise>
            <span class="text-muted">—</span>
        </c:otherwise>
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
                <c:if test="${not empty shipments}">
                    <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
                        <small class="text-muted" id="paginationInfo"></small>
                        <nav>
                            <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const successToastEl = document.getElementById('successToast');
    if (successToastEl) {
        const toast = new bootstrap.Toast(successToastEl, { delay: 3000 });
        toast.show();
    }

    const ROWS_PER_PAGE = 10;
    let currentPage = 1;

    function getAllRows() {
        const tbody = document.getElementById("shipmentTable");
        if (!tbody) return [];
        return Array.from(tbody.getElementsByTagName("tr")).filter(r => r.cells.length > 1);
    }

    function renderPage() {
        const allRows = getAllRows();
        if (allRows.length === 0) return;

        const totalPages = Math.max(1, Math.ceil(allRows.length / ROWS_PER_PAGE));
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        allRows.forEach(row => row.style.display = "none");

        const start = (currentPage - 1) * ROWS_PER_PAGE;
        const end = start + ROWS_PER_PAGE;
        allRows.slice(start, end).forEach(row => row.style.display = "");

        renderPaginationControls(totalPages, allRows.length);
    }

    function renderPaginationControls(totalPages, totalItems) {
        const info = document.getElementById("paginationInfo");
        const controls = document.getElementById("paginationControls");
        if (!info || !controls) return;
        controls.innerHTML = "";

        const start = (currentPage - 1) * ROWS_PER_PAGE + 1;
        const end = Math.min(currentPage * ROWS_PER_PAGE, totalItems);
        info.textContent = "Showing " + start + "-" + end + " of " + totalItems + " shipments";

        const addPageItem = (label, page, disabled, active) => {
            const li = document.createElement("li");
            li.className = "page-item" + (disabled ? " disabled" : "") + (active ? " active" : "");
            const a = document.createElement("a");
            a.className = "page-link";
            a.href = "#";
            a.textContent = label;
            a.onclick = (e) => { e.preventDefault(); if (!disabled) { currentPage = page; renderPage(); } };
            li.appendChild(a);
            controls.appendChild(li);
        };

        addPageItem("«", currentPage - 1, currentPage === 1, false);
        for (let p = 1; p <= totalPages; p++) {
            addPageItem(p, p, false, p === currentPage);
        }
        addPageItem("»", currentPage + 1, currentPage === totalPages, false);
    }

    document.addEventListener("DOMContentLoaded", renderPage);
</script>
</body>
</html>