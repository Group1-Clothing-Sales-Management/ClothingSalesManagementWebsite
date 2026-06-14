<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Order Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        /* Khoa chieu cao trang de sidebar va noi dung co thanh cuon rieng. */
        html, body {
            height: 100%;
            overflow: hidden;
        }

        body { background: #f5f7fb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .main-wrapper {
            display: flex;
            height: 100vh;
            overflow: hidden;
        }
        .content-area {
            flex: 1;
            padding: 28px 32px 36px;
            min-width: 0;
            height: 100vh;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        .page-header { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-bottom: 24px; }
        .page-title { font-size: 1.5rem; font-weight: 800; color: #111827; margin: 0; }
        .page-title .bi { color: #2563eb; margin-right: 10px; }
        .card-main { border: none; border-radius: 16px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06); }
        .table thead th { background: #1f2937; color: #fff; font-weight: 600; font-size: .85rem; white-space: nowrap; border: none; }
        .table tbody tr:hover { background: #f8fbff; }
        .order-code { font-weight: 800; color: #111827; }
        .subtext { font-size: .83rem; color: #6b7280; }
        .empty-state { padding: 64px 20px; text-align: center; color: #9ca3af; }
        .empty-state .bi { font-size: 2.75rem; display: block; margin-bottom: 12px; }
        .status-pill { border-radius: 999px; padding: .35rem .65rem; font-size: .78rem; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; border: 1px solid transparent; }
        .status-pending { background: #fff7ed; color: #9a3412; border-color: #fed7aa; }
        .status-confirmed { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
        .status-shipping { background: #eef2ff; color: #4f46e5; border-color: #c7d2fe; }
        .status-delivered { background: #ecfdf5; color: #047857; border-color: #a7f3d0; }
        .status-cancelled { background: #fef2f2; color: #b91c1c; border-color: #fecaca; }
        .status-returned { background: #f3f4f6; color: #374151; border-color: #d1d5db; }
        .badge-soft { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
        .detail-label { font-size: .8rem; text-transform: uppercase; letter-spacing: .04em; color: #6b7280; font-weight: 700; margin-bottom: 6px; }
        .detail-value { font-weight: 600; color: #111827; word-break: break-word; }
        .item-title { font-weight: 700; color: #111827; }
    </style>
</head>
<body>
<div class="main-wrapper">
    <jsp:include page="/view/admin/sidebar.jsp">
        <jsp:param name="activeTab" value="orders"/>
    </jsp:include>

    <div class="content-area">
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${pageMode eq 'detail'}">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-2">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/orders">Order Management</a></li>
                        <li class="breadcrumb-item active">Order Details</li>
                    </ol>
                </nav>

                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="bi bi-receipt-cutoff"></i>Order ${order.orderCode}</h1>
                        <div class="text-muted mt-1">
                            Customer: <strong>${not empty order.customerFullName ? order.customerFullName : order.customerUsername}</strong>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-outline-secondary btn-sm px-3">
                        <i class="bi bi-arrow-left me-1"></i>Back to list
                    </a>
                </div>

                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="card card-main mb-4">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4">
                                    <div>
                                        <div class="detail-label">Current status</div>
                                        <c:choose>
                                            <c:when test="${order.orderStatus eq 'PENDING'}"><span class="status-pill status-pending"><i class="bi bi-hourglass-split"></i>PENDING</span></c:when>
                                            <c:when test="${order.orderStatus eq 'CONFIRMED'}"><span class="status-pill status-confirmed"><i class="bi bi-check2-circle"></i>CONFIRMED</span></c:when>
                                            <c:when test="${order.orderStatus eq 'SHIPPING'}"><span class="status-pill status-shipping"><i class="bi bi-truck"></i>SHIPPING</span></c:when>
                                            <c:when test="${order.orderStatus eq 'DELIVERED'}"><span class="status-pill status-delivered"><i class="bi bi-box-seam"></i>DELIVERED</span></c:when>
                                            <c:when test="${order.orderStatus eq 'CANCELLED'}"><span class="status-pill status-cancelled"><i class="bi bi-x-circle"></i>CANCELLED</span></c:when>
                                            <c:otherwise><span class="status-pill status-returned"><i class="bi bi-arrow-counterclockwise"></i>RETURNED</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-end">
                                        <div class="detail-label">Total payment</div>
                                        <div class="fs-3 fw-bold text-dark"><fmt:formatNumber value="${order.totalPayment}" pattern="#,##0"/> VND</div>
                                    </div>
                                </div>

                                <div class="row g-4">
                                    <div class="col-md-6">
                                        <div class="detail-label">Order information</div>
                                        <div class="detail-value mb-2">Order code: ${order.orderCode}</div>
                                        <div class="subtext mb-1">Created: <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        <div class="subtext">Updated: <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="detail-label">Recipient information</div>
                                        <div class="detail-value mb-2">${order.recipientName} - ${order.recipientPhone}</div>
                                        <div class="subtext">
                                            <c:choose>
                                                <c:when test="${not empty order.wardName}">
                                                    ${order.addressDetail}, ${order.wardName}
                                                    <c:if test="${not empty order.districtName}">, ${order.districtName}</c:if>
                                                    <c:if test="${not empty order.provinceName}">, ${order.provinceName}</c:if>
                                                </c:when>
                                                <c:otherwise>${order.addressDetail}</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="detail-label">Payment</div>
                                        <div class="detail-value mb-1">${not empty order.paymentMethod ? order.paymentMethod : 'Not recorded'}</div>
                                        <c:choose>
                                            <c:when test="${order.paymentStatus eq 'PAID'}"><span class="badge rounded-pill text-bg-success">PAID</span></c:when>
                                            <c:when test="${order.paymentStatus eq 'REFUNDED'}"><span class="badge rounded-pill text-bg-warning">REFUNDED</span></c:when>
                                            <c:when test="${order.paymentStatus eq 'FAILED'}"><span class="badge rounded-pill text-bg-danger">FAILED</span></c:when>
                                            <c:otherwise><span class="badge rounded-pill badge-soft">UNPAID</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="detail-label">Shipping</div>
                                        <div class="detail-value mb-1">${not empty order.shipmentCarrierName ? order.shipmentCarrierName : 'No shipping info'}</div>
                                        <div class="subtext">${not empty order.shipmentTrackingCode ? 'Tracking: ' : ''}${not empty order.shipmentTrackingCode ? order.shipmentTrackingCode : 'No tracking code yet'}</div>
                                        <div class="subtext">Shipping status: ${not empty order.shippingStatus ? order.shippingStatus : 'N/A'}</div>
                                    </div>
                                    <div class="col-12">
                                        <div class="detail-label">Note</div>
                                        <div class="detail-value">
                                            <c:choose>
                                                <c:when test="${not empty order.note}">${order.note}</c:when>
                                                <c:otherwise>No note from the customer.</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card card-main">
                            <div class="card-header bg-white border-0 pt-4 px-4">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <h5 class="fw-bold mb-0 text-dark"><i class="bi bi-box-seam me-2 text-primary"></i>Order items</h5>
                                    <span class="badge badge-soft">${fn:length(orderDetails)} lines</span>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${empty orderDetails}">
                                        <div class="empty-state">
                                            <i class="bi bi-box2"></i>
                                            <p class="fw-semibold mb-1">This order has no item details</p>
                                            <p class="small mb-0">The Order_Detail table is empty or the line items have not been recorded yet.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover align-middle mb-0">
                                                <thead>
                                                <tr>
                                                    <th class="ps-4">Product</th>
                                                    <th>Attributes</th>
                                                    <th class="text-center">Qty</th>
                                                    <th class="text-end">Unit price</th>
                                                    <th class="text-end pe-4">Line total</th>
                                                </tr>
                                                </thead>
                                                <tbody>
                                                <c:forEach var="item" items="${orderDetails}">
                                                    <tr>
                                                        <td class="ps-4">
                                                            <div class="item-title">${item.productNameSnapshot}</div>
                                                            <div class="subtext">Variant ID: ${item.variantId}</div>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty item.variantAttributesSnapshot}">
                                                                    <span class="badge badge-soft">${item.variantAttributesSnapshot}</span>
                                                                </c:when>
                                                                <c:otherwise><span class="text-muted">No attributes</span></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-center fw-semibold">${item.quantity}</td>
                                                        <td class="text-end"><fmt:formatNumber value="${item.price}" pattern="#,##0"/> VND</td>
                                                        <td class="text-end pe-4 fw-bold"><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> VND</td>
                                                    </tr>
                                                </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card card-main mb-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold text-dark mb-3"><i class="bi bi-shuffle me-2 text-primary"></i>Status actions</h5>

                                <div class="d-flex flex-wrap gap-2 mb-3">
                                    <c:if test="${order.orderStatus eq 'PENDING'}">
                                        <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0">
                                            <input type="hidden" name="action" value="confirm">
                                            <input type="hidden" name="id" value="${order.id}">
                                            <input type="hidden" name="returnMode" value="detail">
                                            <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('Confirm this order?');">
                                                <i class="bi bi-check2-circle me-1"></i>Confirm
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${order.orderStatus eq 'PENDING' or order.orderStatus eq 'CONFIRMED'}">
                                        <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="id" value="${order.id}">
                                            <input type="hidden" name="returnMode" value="detail">
                                            <button type="submit" class="btn btn-outline-danger btn-sm" onclick="return confirm('Cancel this order?');">
                                                <i class="bi bi-x-circle me-1"></i>Cancel
                                            </button>
                                        </form>
                                    </c:if>
                                </div>

                                <c:choose>
                                    <c:when test="${empty allowedStatuses}">
                                        <div class="alert alert-light border mb-0">This is the final status in the order lifecycle.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <form action="${pageContext.request.contextPath}/staff/orders" method="post">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="id" value="${order.id}">
                                            <input type="hidden" name="returnMode" value="detail">
                                            <label class="form-label fw-semibold">Select next status</label>
                                            <select name="newStatus" class="form-select mb-3" required>
                                                <c:forEach var="nextStatus" items="${allowedStatuses}">
                                                    <option value="${nextStatus}">${nextStatus}</option>
                                                </c:forEach>
                                            </select>
                                            <button type="submit" class="btn btn-primary w-100">
                                                <i class="bi bi-save2 me-1"></i>Update status
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="card card-main">
                            <div class="card-body p-4">
                                <h5 class="fw-bold text-dark mb-3"><i class="bi bi-person-badge me-2 text-primary"></i>Customer information</h5>
                                <div class="mb-3">
                                    <div class="detail-label">Username</div>
                                    <div class="detail-value">${not empty order.customerUsername ? order.customerUsername : 'N/A'}</div>
                                </div>
                                <div class="mb-3">
                                    <div class="detail-label">Full name</div>
                                    <div class="detail-value">${not empty order.customerFullName ? order.customerFullName : 'N/A'}</div>
                                </div>
                                <div class="mb-3">
                                    <div class="detail-label">Email</div>
                                    <div class="detail-value">${not empty order.customerEmail ? order.customerEmail : 'N/A'}</div>
                                </div>
                                <div class="mb-0">
                                    <div class="detail-label">Item count</div>
                                    <div class="detail-value">${order.detailCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-2">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Order Management</li>
                    </ol>
                </nav>

                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="bi bi-receipt"></i>Order Management</h1>
                        <div class="text-muted mt-1">View orders, confirm orders, cancel orders, and update status across the order lifecycle.</div>
                    </div>
                </div>

                <div class="card card-main mb-4">
                    <div class="card-body p-4">
                        <form class="row g-3 align-items-end" method="get" action="${pageContext.request.contextPath}/staff/orders">
                            <div class="col-lg-5">
                                <label class="form-label fw-semibold">Keyword</label>
                                <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Order code, customer name, phone number...">
                            </div>
                            <div class="col-lg-3">
                                <label class="form-label fw-semibold">Status</label>
                                <select name="status" class="form-select">
                                    <c:forEach var="option" items="${statusOptions}">
                                        <option value="${option}" ${selectedStatus eq option ? 'selected' : ''}>${option}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-lg-4 d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-search me-1"></i>Search
                                </button>
                                <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-counterclockwise me-1"></i>Reset
                                </a>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card card-main">
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="empty-state">
                                    <i class="bi bi-inbox"></i>
                                    <p class="fw-semibold mb-1">No orders matched the current filters</p>
                                    <p class="small mb-0">Try a different keyword or status to view records.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                        <tr>
                                            <th class="ps-4">Order</th>
                                            <th>Customer</th>
                                            <th>Recipient</th>
                                            <th class="text-end">Total</th>
                                            <th>Payment</th>
                                            <th>Shipping</th>
                                            <th>Status</th>
                                            <th>Created</th>
                                            <th class="text-end pe-4" style="width: 220px;">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="o" items="${orders}">
                                            <tr>
                                                <td class="ps-4">
                                                    <div class="order-code">${o.orderCode}</div>
                                                    <div class="subtext">${o.detailCount} items</div>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold">${not empty o.customerFullName ? o.customerFullName : o.customerUsername}</div>
                                                    <div class="subtext">${o.customerEmail}</div>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold">${o.recipientName}</div>
                                                    <div class="subtext">${o.recipientPhone}</div>
                                                </td>
                                                <td class="text-end fw-bold"><fmt:formatNumber value="${o.totalPayment}" pattern="#,##0"/> VND</td>
                                                <td>
                                                    <div class="fw-semibold">${not empty o.paymentMethod ? o.paymentMethod : 'N/A'}</div>
                                                    <c:choose>
                                                        <c:when test="${o.paymentStatus eq 'PAID'}"><span class="badge rounded-pill text-bg-success">PAID</span></c:when>
                                                        <c:when test="${o.paymentStatus eq 'REFUNDED'}"><span class="badge rounded-pill text-bg-warning">REFUNDED</span></c:when>
                                                        <c:when test="${o.paymentStatus eq 'FAILED'}"><span class="badge rounded-pill text-bg-danger">FAILED</span></c:when>
                                                        <c:otherwise><span class="badge rounded-pill badge-soft">UNPAID</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold">${not empty o.shipmentCarrierName ? o.shipmentCarrierName : 'N/A'}</div>
                                                    <div class="subtext">${not empty o.shipmentTrackingCode ? o.shipmentTrackingCode : 'No tracking code yet'}</div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${o.orderStatus eq 'PENDING'}"><span class="status-pill status-pending">PENDING</span></c:when>
                                                        <c:when test="${o.orderStatus eq 'CONFIRMED'}"><span class="status-pill status-confirmed">CONFIRMED</span></c:when>
                                                        <c:when test="${o.orderStatus eq 'SHIPPING'}"><span class="status-pill status-shipping">SHIPPING</span></c:when>
                                                        <c:when test="${o.orderStatus eq 'DELIVERED'}"><span class="status-pill status-delivered">DELIVERED</span></c:when>
                                                        <c:when test="${o.orderStatus eq 'CANCELLED'}"><span class="status-pill status-cancelled">CANCELLED</span></c:when>
                                                        <c:otherwise><span class="status-pill status-returned">RETURNED</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy"/></div>
                                                    <div class="subtext"><fmt:formatDate value="${o.createdAt}" pattern="HH:mm"/></div>
                                                </td>
                                                <td class="pe-4">
                                                    <div class="d-flex justify-content-end flex-wrap gap-2">
                                                        <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/staff/orders?action=view&id=${o.id}">
                                                            <i class="bi bi-eye me-1"></i>View
                                                        </a>
                                                        <c:if test="${o.orderStatus eq 'PENDING'}">
                                                            <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0">
                                                                <input type="hidden" name="action" value="confirm">
                                                                <input type="hidden" name="id" value="${o.id}">
                                                                <button type="submit" class="btn btn-sm btn-success" onclick="return confirm('Confirm order ${o.orderCode}?');">
                                                                    <i class="bi bi-check2-circle me-1"></i>Confirm
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${o.orderStatus eq 'PENDING' or o.orderStatus eq 'CONFIRMED'}">
                                                            <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0">
                                                                <input type="hidden" name="action" value="cancel">
                                                                <input type="hidden" name="id" value="${o.id}">
                                                                <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Cancel order ${o.orderCode}?');">
                                                                    <i class="bi bi-x-circle me-1"></i>Cancel
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.alert').forEach(function (el) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(el);
            bsAlert.close();
        }, 4500);
    });
</script>
</body>
</html>
