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
        .variant-results {
            max-height: 280px;
            overflow-y: auto;
        }
        .variant-option {
            text-align: left;
        }
        .variant-option.is-selected {
            background: #eff6ff;
            border-color: #bfdbfe;
        }
        .variant-option .variant-meta {
            font-size: .8rem;
            color: #6b7280;
        }
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
                        <li class="breadcrumb-item"><a href="${ordersBasePath}">Order Management</a></li>
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
                    <a href="${ordersBasePath}" class="btn btn-outline-secondary btn-sm px-3">
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
                                        <form action="${ordersBasePath}" method="post" class="m-0">
                                            <input type="hidden" name="action" value="confirm">
                                            <input type="hidden" name="id" value="${order.id}">
                                            <input type="hidden" name="returnMode" value="detail">
                                            <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('Confirm this order?');">
                                                <i class="bi bi-check2-circle me-1"></i>Confirm
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${order.orderStatus eq 'PENDING' or order.orderStatus eq 'CONFIRMED'}">
                                        <form action="${ordersBasePath}" method="post" class="m-0">
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
                                        <form action="${ordersBasePath}" method="post">
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
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createStoreOrderModal">
                        <i class="bi bi-bag-plus me-1"></i>Create store order
                    </button>
                </div>

                <div class="card card-main mb-4">
                    <div class="card-body p-4">
                        <form class="row g-3 align-items-end" method="get" action="${ordersBasePath}">
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
                                <a href="${ordersBasePath}" class="btn btn-outline-secondary">
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
                                                        <a class="btn btn-sm btn-outline-primary" href="${ordersBasePath}?action=view&id=${o.id}">
                                                            <i class="bi bi-eye me-1"></i>View
                                                        </a>
                                                        <c:if test="${o.orderStatus eq 'PENDING'}">
                                                            <form action="${ordersBasePath}" method="post" class="m-0">
                                                                <input type="hidden" name="action" value="confirm">
                                                                <input type="hidden" name="id" value="${o.id}">
                                                                <button type="submit" class="btn btn-sm btn-success" onclick="return confirm('Confirm order ${o.orderCode}?');">
                                                                    <i class="bi bi-check2-circle me-1"></i>Confirm
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${o.orderStatus eq 'PENDING' or o.orderStatus eq 'CONFIRMED'}">
                                                            <form action="${ordersBasePath}" method="post" class="m-0">
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

<!-- This modal creates a walk-in order directly from the order screen so staff
     can complete a shop purchase without opening customer checkout. -->
<div class="modal fade" id="createStoreOrderModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold">
                    <i class="bi bi-bag-plus me-2"></i>Create store order
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${ordersBasePath}" method="post" id="createStoreOrderForm" novalidate>
                <input type="hidden" name="action" value="createStoreOrder">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Recipient name</label>
                            <input type="text" name="recipientName" id="storeRecipientName" class="form-control" required maxlength="100" minlength="2" placeholder="Enter recipient name">
                            <div class="invalid-feedback">Recipient name is required and must be at least 2 characters.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Recipient phone</label>
                            <input type="tel" name="recipientPhone" id="storeRecipientPhone" class="form-control" required inputmode="numeric" maxlength="10" pattern="[0-9]{1,10}" placeholder="Enter up to 10 digits">
                            <div class="invalid-feedback">Recipient phone is required and must contain up to 10 digits.</div>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Product variant</label>
                            <input type="hidden" name="variantId" id="storeVariantId" value="">
                            <c:choose>
                                <c:when test="${not hasSellableProducts}">
                                    <input type="search"
                                           id="storeVariantSearch"
                                           class="form-control"
                                           placeholder="No sellable variants available"
                                           autocomplete="off"
                                           disabled>
                                    <div class="form-text text-danger mt-2">
                                        No sellable product variants are available right now.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <input type="search"
                                           id="storeVariantSearch"
                                           class="form-control"
                                           placeholder="Search by product, brand, color, size, or SKU"
                                           autocomplete="off">
                                    <div class="form-text">
                                        Type to search, then click one result to select the exact product variant.
                                    </div>
                                    <div id="storeVariantSelected" class="small text-muted mt-2">
                                        No product variant selected yet.
                                    </div>
                                    <div id="storeVariantResults" class="list-group variant-results mt-2">
                                        <c:forEach var="item" items="${storeProducts}">
                                            <c:if test="${item.stockQuantity gt 0}">
                                                <c:set var="variantProductName" value="${item.productName}" />
                                                <c:set var="variantBrandName" value="${item.brandName}" />
                                                <c:set var="variantColor" value="${empty item.color ? 'No color' : item.color}" />
                                                <c:set var="variantSize" value="${empty item.size ? 'No size' : item.size}" />
                                                <c:set var="variantSku" value="${item.sku}" />
                                                <button type="button"
                                                        class="list-group-item list-group-item-action variant-option"
                                                        data-store-variant="true"
                                                        data-variant-id="${item.variantId}"
                                                        data-product-name="${fn:escapeXml(variantProductName)}"
                                                        data-brand-name="${fn:escapeXml(variantBrandName)}"
                                                        data-color="${fn:escapeXml(variantColor)}"
                                                        data-size="${fn:escapeXml(variantSize)}"
                                                        data-sku="${fn:escapeXml(variantSku)}"
                                                        data-sale-price="${item.salePrice}"
                                                        data-stock-quantity="${item.stockQuantity}">
                                                    <div class="d-flex justify-content-between align-items-start gap-3">
                                                        <div class="me-2">
                                                            <div class="fw-semibold text-dark">
                                                                <c:out value="${variantProductName}"/>
                                                                <c:if test="${not empty variantBrandName}"> - <c:out value="${variantBrandName}"/></c:if>
                                                            </div>
                                                            <div class="variant-meta">
                                                                <span>
                                                                    Color: <c:out value="${variantColor}"/>
                                                                </span>
                                                                <span class="mx-1">|</span>
                                                                <span>
                                                                    Size: <c:out value="${variantSize}"/>
                                                                </span>
                                                                <c:if test="${not empty variantSku}">
                                                                    <span class="mx-1">|</span>
                                                                    <span>SKU: <c:out value="${variantSku}"/></span>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                        <div class="text-end">
                                                            <div class="fw-semibold text-primary">
                                                                Stock: <c:out value="${item.stockQuantity}"/>
                                                            </div>
                                                            <div class="variant-meta">
                                                                <fmt:formatNumber value="${item.salePrice}" pattern="#,##0"/> VND
                                                            </div>
                                                        </div>
                                                    </div>
                                                </button>
                                            </c:if>
                                        </c:forEach>
                                        <div id="storeVariantNoResults" class="list-group-item text-muted d-none">
                                            No variants matched your search.
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Quantity</label>
                            <input type="number" name="quantity" id="storeQuantity" class="form-control" min="1" step="1" value="1" required>
                            <div class="invalid-feedback" id="storeQuantityFeedback">Quantity must be at least 1.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Payment method</label>
                            <select name="paymentMethod" id="storePaymentMethod" class="form-select" required>
                                <option value="CASH">CASH</option>
                                <option value="CARD">CARD</option>
                            </select>
                            <div class="invalid-feedback">Please select a payment method.</div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Note</label>
                            <textarea name="note" id="storeNote" class="form-control" rows="3" maxlength="500" placeholder="Optional internal note for the order"></textarea>
                            <div class="form-text">Optional. Maximum 500 characters.</div>
                        </div>
                        <div class="col-12">
                            <div class="alert alert-light border mb-0">
                                <div class="fw-semibold mb-1">Preview</div>
                                <div id="storeOrderPreview" class="small text-muted">
                                    Search and select a product variant to see the estimated total.
                                </div>
                                <div id="storeStockHint" class="small text-danger mt-2 d-none"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <c:choose>
                        <c:when test="${not hasSellableProducts}">
                            <button type="submit" class="btn btn-primary" disabled>
                                <i class="bi bi-check2-circle me-1"></i>Create order
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check2-circle me-1"></i>Create order
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // This script keeps the store-order modal simple:
    // - staff search a variant instead of browsing a long <select> menu;
    // - the chosen variant is copied into a hidden field named variantId;
    // - the preview and quantity validation always use the selected variant data.
    const storeOrderForm = document.getElementById('createStoreOrderForm');
    const recipientNameInput = document.getElementById('storeRecipientName');
    const recipientPhoneInput = document.getElementById('storeRecipientPhone');
    const variantHiddenInput = document.getElementById('storeVariantId');
    const variantSearchInput = document.getElementById('storeVariantSearch');
    const variantResults = document.getElementById('storeVariantResults');
    const variantNoResults = document.getElementById('storeVariantNoResults');
    const variantSelectedText = document.getElementById('storeVariantSelected');
    const variantOptions = Array.from(document.querySelectorAll('[data-store-variant="true"]'));
    const quantityInput = document.getElementById('storeQuantity');
    const paymentMethodSelect = document.getElementById('storePaymentMethod');
    const noteInput = document.getElementById('storeNote');
    const previewBox = document.getElementById('storeOrderPreview');
    const quantityFeedback = document.getElementById('storeQuantityFeedback');
    const stockHint = document.getElementById('storeStockHint');
    let selectedVariantButton = null;

    /**
     * Build a readable label for one variant.
     * This label is reused in the search field, the selected summary, and the preview.
     */
    function buildVariantLabel(variantButton) {
        if (!variantButton) {
            return '';
        }

        const productName = variantButton.dataset.productName || 'Unknown product';
        const brandName = variantButton.dataset.brandName || '';
        const colorName = variantButton.dataset.color || 'No color';
        const sizeName = variantButton.dataset.size || 'No size';
        const sku = variantButton.dataset.sku || '';

        const parts = [productName];
        if (brandName) {
            parts.push(brandName);
        }

        let label = parts.join(' - ');
        label += ' | ' + colorName + ' | ' + sizeName;
        if (sku) {
            label += ' | SKU: ' + sku;
        }
        return label;
    }

    /**
     * Build a searchable string from one variant.
     * The search box matches against this lower-cased text so staff can find a
     * variant using product name, brand, color, size, SKU, or ID.
     */
    function buildVariantSearchText(variantButton) {
        if (!variantButton) {
            return '';
        }

        return [
            variantButton.dataset.variantId || '',
            variantButton.dataset.productName || '',
            variantButton.dataset.brandName || '',
            variantButton.dataset.color || '',
            variantButton.dataset.size || '',
            variantButton.dataset.sku || ''
        ].join(' ').toLowerCase();
    }

    /**
     * Return the variant button that is currently selected.
     * The hidden input is the source of truth because that is what gets posted to the server.
     */
    function getSelectedVariantButton() {
        if (selectedVariantButton && variantHiddenInput && selectedVariantButton.dataset.variantId === variantHiddenInput.value) {
            return selectedVariantButton;
        }

        if (!variantHiddenInput) {
            return null;
        }

        const currentVariantId = (variantHiddenInput.value || '').trim();
        if (!currentVariantId) {
            return null;
        }

        return variantOptions.find(function (button) {
            return (button.dataset.variantId || '').trim() === currentVariantId;
        }) || null;
    }

    /**
     * Clear the current variant choice.
     * We do this when the staff edits the search field, because the typed text no
     * longer guarantees the hidden variant ID still matches the visible label.
     */
    function clearVariantSelection() {
        selectedVariantButton = null;

        variantOptions.forEach(function (variantButton) {
            variantButton.classList.remove('is-selected');
        });

        if (variantHiddenInput) {
            variantHiddenInput.value = '';
        }

        if (variantSelectedText) {
            variantSelectedText.textContent = 'No product variant selected yet.';
        }

        if (variantSearchInput) {
            variantSearchInput.setCustomValidity('');
        }

        updateStoreOrderPreview();
    }

    /**
     * Copy one clicked variant into the hidden input and the preview.
     * This is the only moment where the order form receives the actual variant ID.
     */
    function selectVariant(variantButton) {
        if (!variantButton || !variantHiddenInput || !variantSearchInput) {
            return;
        }

        selectedVariantButton = variantButton;
        variantOptions.forEach(function (button) {
            button.classList.toggle('is-selected', button === variantButton);
        });
        variantHiddenInput.value = (variantButton.dataset.variantId || '').trim();
        variantSearchInput.value = buildVariantLabel(variantButton);
        variantSearchInput.setCustomValidity('');

        if (variantSelectedText) {
            variantSelectedText.textContent = 'Selected variant: ' + buildVariantLabel(variantButton);
        }

        if (variantResults) {
            variantResults.classList.add('d-none');
        }

        updateStoreOrderPreview();
    }

    /**
     * Filter the variant list according to the current search text.
     * This keeps the modal usable even when many sellable variants exist.
     */
    function filterVariantOptions() {
        if (!variantSearchInput || !variantResults || variantOptions.length === 0) {
            return;
        }

        const searchText = variantSearchInput.value.trim().toLowerCase();
        let visibleCount = 0;

        variantOptions.forEach(function (variantButton) {
            const matches = searchText === '' || buildVariantSearchText(variantButton).includes(searchText);
            variantButton.classList.toggle('d-none', !matches);
            if (matches) {
                visibleCount++;
            }
        });

        if (variantNoResults) {
            const showNoResults = searchText !== '' && visibleCount === 0;
            variantNoResults.classList.toggle('d-none', !showNoResults);
        }

        const shouldShowResults = searchText !== '' || document.activeElement === variantSearchInput;
        variantResults.classList.toggle('d-none', !shouldShowResults);
    }

    /**
     * Validate that the visible search text still maps to one concrete variant.
     * The hidden input is the field that actually gets submitted, so the search box
     * must not be allowed to submit by itself.
     */
    function validateVariantSelection() {
        if (!variantSearchInput || !variantHiddenInput) {
            return true;
        }

        const selectedVariant = getSelectedVariantButton();
        if (!selectedVariant) {
            variantSearchInput.setCustomValidity('Please select a product variant from the search results.');
            return false;
        }

        variantSearchInput.setCustomValidity('');
        return true;
    }

    /**
     * Keep the order preview aligned with the currently selected variant and quantity.
     * The preview is intentionally small and direct so staff can confirm the sale quickly.
     */
    function updateStoreOrderPreview() {
        if (!quantityInput || !previewBox) {
            return;
        }

        const selectedOption = getSelectedVariantButton();
        if (!selectedOption) {
            previewBox.textContent = 'Search and select a product variant to see the estimated total.';
            if (stockHint) {
                stockHint.classList.add('d-none');
                stockHint.textContent = '';
            }
            quantityInput.removeAttribute('max');
            quantityInput.setCustomValidity('');
            if (quantityFeedback) {
                quantityFeedback.textContent = 'Quantity must be at least 1.';
            }
            return;
        }

        const productName = selectedOption.dataset.productName || 'Unknown product';
        const brandName = selectedOption.dataset.brandName || '';
        const price = parseFloat(selectedOption.dataset.salePrice) || 0;
        const stock = parseInt(selectedOption.dataset.stockQuantity, 10) || 0;
        const qty = Math.max(parseInt(quantityInput.value, 10) || 1, 1);
        const total = price * qty;

        quantityInput.max = String(stock > 0 ? stock : 1);
        if (qty > stock) {
            quantityInput.setCustomValidity('Quantity cannot exceed available stock.');
            if (quantityFeedback) {
                quantityFeedback.textContent = 'Quantity cannot exceed available stock (' + stock + ').';
            }
            if (stockHint) {
                stockHint.textContent = 'Available stock for this variant: ' + stock + '.';
                stockHint.classList.remove('d-none');
            }
        } else {
            quantityInput.setCustomValidity('');
            if (quantityFeedback) {
                quantityFeedback.textContent = 'Quantity must be at least 1.';
            }
            if (stockHint) {
                stockHint.textContent = 'Available stock for this variant: ' + stock + '.';
                stockHint.classList.remove('d-none');
            }
        }

        previewBox.innerHTML =
            '<div><strong>' + productName + '</strong>' + (brandName ? ' - ' + brandName : '') + '</div>' +
            '<div>Unit price: <strong>' + price.toLocaleString('en-US') + ' VND</strong></div>' +
            '<div>Stock available: <strong>' + stock + '</strong></div>' +
            '<div>Estimated total: <strong>' + total.toLocaleString('en-US') + ' VND</strong></div>';
    }

    function validateTextInput(input, minLength, message) {
        if (!input) {
            return;
        }
        const value = (input.value || '').trim();
        if (value.length < minLength) {
            input.setCustomValidity(message);
        } else {
            input.setCustomValidity('');
        }
    }

    function validatePhoneInput() {
        if (!recipientPhoneInput) {
            return;
        }
        const value = (recipientPhoneInput.value || '').trim();
        const phonePattern = /^[0-9]{1,10}$/;
        if (!value) {
            recipientPhoneInput.setCustomValidity('Recipient phone is required.');
        } else if (!phonePattern.test(value)) {
            recipientPhoneInput.setCustomValidity('Enter up to 10 digits only.');
        } else {
            recipientPhoneInput.setCustomValidity('');
        }
    }

    function validatePaymentMethod() {
        if (!paymentMethodSelect) {
            return;
        }
        const value = (paymentMethodSelect.value || '').trim().toUpperCase();
        if (value !== 'CASH' && value !== 'CARD') {
            paymentMethodSelect.setCustomValidity('Please select a payment method.');
        } else {
            paymentMethodSelect.setCustomValidity('');
        }
    }

    if (variantSearchInput) {
        variantSearchInput.addEventListener('focus', filterVariantOptions);
        variantSearchInput.addEventListener('blur', function () {
            setTimeout(function () {
                if (!variantSearchInput) {
                    return;
                }

                if (document.activeElement !== variantSearchInput && !getSelectedVariantButton() && variantResults) {
                    variantResults.classList.add('d-none');
                }
            }, 120);
        });
        variantSearchInput.addEventListener('input', function () {
            if (selectedVariantButton) {
                const selectedLabel = buildVariantLabel(selectedVariantButton);
                if (variantSearchInput.value !== selectedLabel) {
                    clearVariantSelection();
                }
            }

            filterVariantOptions();
        });
        variantSearchInput.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') {
                const visibleVariants = variantOptions.filter(function (button) {
                    return !button.classList.contains('d-none');
                });
                if (visibleVariants.length === 1) {
                    event.preventDefault();
                    selectVariant(visibleVariants[0]);
                }
            }
        });
    }

    variantOptions.forEach(function (variantButton) {
        variantButton.addEventListener('click', function () {
            selectVariant(variantButton);
        });
    });
    if (quantityInput) {
        quantityInput.addEventListener('input', updateStoreOrderPreview);
    }
    if (recipientNameInput) {
        recipientNameInput.addEventListener('input', function () {
            validateTextInput(recipientNameInput, 2, 'Recipient name is required and must be at least 2 characters.');
        });
    }
    if (recipientPhoneInput) {
        recipientPhoneInput.addEventListener('input', function () {
            const digitsOnly = (recipientPhoneInput.value || '').replace(/\D/g, '').slice(0, 10);
            if (recipientPhoneInput.value !== digitsOnly) {
                recipientPhoneInput.value = digitsOnly;
            }
            validatePhoneInput();
        });
    }
    if (paymentMethodSelect) {
        paymentMethodSelect.addEventListener('change', validatePaymentMethod);
    }
    if (noteInput) {
        noteInput.addEventListener('input', function () {
            if ((noteInput.value || '').length > 500) {
                noteInput.setCustomValidity('Note cannot exceed 500 characters.');
            } else {
                noteInput.setCustomValidity('');
            }
        });
    }
    if (storeOrderForm) {
        storeOrderForm.addEventListener('submit', function (event) {
            validateTextInput(recipientNameInput, 2, 'Recipient name is required and must be at least 2 characters.');
            validatePhoneInput();
            validatePaymentMethod();
            validateVariantSelection();
            updateStoreOrderPreview();

            if (noteInput && (noteInput.value || '').length > 500) {
                noteInput.setCustomValidity('Note cannot exceed 500 characters.');
            } else if (noteInput) {
                noteInput.setCustomValidity('');
            }

            if (!storeOrderForm.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }

            storeOrderForm.classList.add('was-validated');
        });
    }
    updateStoreOrderPreview();

    document.querySelectorAll('.alert').forEach(function (el) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(el);
            bsAlert.close();
        }, 4500);
    });
</script>
</body>
</html>
