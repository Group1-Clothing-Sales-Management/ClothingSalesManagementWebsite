<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Feedback Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        /* Chia khung trang theo kiểu dashboard để sidebar luôn đứng bên trái. */
        html, body {
            height: 100%;
            overflow: hidden;
        }

        body {
            background: #f5f7fb;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .main-wrapper {
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        .content-area {
            flex: 1;
            min-width: 0;
            height: 100vh;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            padding: 28px 32px 36px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 800;
            color: #111827;
            margin: 0;
        }

        .page-title .bi {
            color: #2563eb;
            margin-right: 10px;
        }

        .card-main {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
        }

        .table thead th {
            background: #1f2937;
            color: #fff;
            font-weight: 700;
            font-size: .85rem;
            white-space: nowrap;
            border: none;
        }

        .table tbody tr:hover {
            background: #f8fbff;
        }

        .thumb {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            object-fit: cover;
            background: #eef2ff;
            border: 1px solid #e5e7eb;
            flex-shrink: 0;
        }

        .thumb-fallback {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            background: #eef2ff;
            border: 1px solid #e5e7eb;
            color: #64748b;
            font-size: .72rem;
            font-weight: 700;
        }

        .product-title {
            font-weight: 800;
            color: #111827;
        }

        .subtext {
            font-size: .84rem;
            color: #6b7280;
        }

        .empty-state {
            padding: 68px 20px;
            text-align: center;
            color: #9ca3af;
        }

        .empty-state .bi {
            font-size: 2.8rem;
            display: block;
            margin-bottom: 12px;
        }

        .detail-label {
            font-size: .78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .04em;
            color: #6b7280;
            margin-bottom: 8px;
        }

        .detail-box {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 16px;
        }

        .comment-box {
            white-space: pre-line;
            line-height: 1.65;
            color: #111827;
        }

        .response-box {
            background: #f8fbff;
            border: 1px solid #dbeafe;
            border-radius: 14px;
            padding: 16px;
        }

        .rating-pill {
            border-radius: 999px;
            padding: .35rem .7rem;
            font-size: .78rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: 1px solid #fde68a;
            background: #fffbeb;
            color: #b45309;
        }

        .status-pill {
            border-radius: 999px;
            padding: .35rem .7rem;
            font-size: .78rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: 1px solid transparent;
        }

        .status-replied {
            background: #ecfdf5;
            color: #047857;
            border-color: #a7f3d0;
        }

        .status-pending {
            background: #fff7ed;
            color: #9a3412;
            border-color: #fed7aa;
        }

        .badge-soft {
            background: #f3f4f6;
            color: #374151;
            border: 1px solid #e5e7eb;
        }

        .action-group {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        /* Utility nhỏ để text-truncate hoạt động đúng trong flex item. */
        .min-w-0 {
            min-width: 0;
        }
    </style>
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="feedback"/>
</jsp:include>
        <%-- Flash message từ session giúp báo kết quả sau khi respond/delete. --%>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <span>${sessionScope.successMsg}</span>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <span>${sessionScope.errorMsg}</span>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <c:choose>
            <%-- ===== DANH SÁCH FEEDBACK ===== --%>
            <c:when test="${pageMode eq 'list' or empty pageMode}">
                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="bi bi-chat-left-text-fill"></i>Feedback Management</h1>
                        <div class="subtext mt-1">View customer feedback, open the detail screen, reply, or delete an entry.</div>
                    </div>
                </div>

                <div class="card card-main">
                    <div class="card-header bg-white border-0 pt-4 px-4">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div class="fw-bold text-dark">
                                <i class="bi bi-list-ul me-2 text-primary"></i>Feedback List
                                <c:if test="${not empty feedbacks}">
                                    <span class="badge badge-soft ms-1">${fn:length(feedbacks)}</span>
                                </c:if>
                            </div>
                            <span class="subtext">Newest feedback appears first.</span>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${empty feedbacks}">
                                <div class="empty-state">
                                    <i class="bi bi-chat-square-dots"></i>
                                    <p class="fw-semibold mb-1">No feedback found</p>
                                    <p class="small mb-0">When customers submit feedback, it will appear here for Staff/Admin review.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                        <tr>
                                            <th class="ps-4" style="width:72px">ID</th>
                                            <th>Product</th>
                                            <th>Customer</th>
                                            <th class="text-center" style="width:110px">Rating</th>
                                            <th class="text-center" style="width:140px">Reply Status</th>
                                            <th style="width:180px">Created</th>
                                            <th class="text-end pe-4" style="width:220px">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="fb" items="${feedbacks}">
                                            <tr>
                                                <td class="ps-4 fw-bold text-secondary">#${fb.id}</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-3">
                                                        <c:choose>
                                                            <c:when test="${not empty fb.productImageUrl}">
                                                                <img src="${pageContext.request.contextPath}/uploads/product/${fb.productImageUrl}"
                                                                     class="thumb shadow-sm"
                                                                     alt="${fb.productName}"
                                                                     onerror="this.style.display='none'; this.nextElementSibling.classList.remove('d-none');">
                                                                <div class="thumb-fallback d-none d-flex align-items-center justify-content-center text-center px-1">
                                                                    No Img
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="thumb-fallback d-flex align-items-center justify-content-center text-center px-1">
                                                                    No Img
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <div class="min-w-0">
                                                            <div class="product-title text-truncate">${fb.productName}</div>
                                                            <div class="subtext text-truncate">
                                                                Product ID: ${fb.productId}
                                                                <c:if test="${not empty fb.orderCode}">
                                                                    | Order: ${fb.orderCode}
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold text-dark text-truncate">
                                                        <c:choose>
                                                            <c:when test="${not empty fb.customerFullName}">
                                                                ${fb.customerFullName}
                                                            </c:when>
                                                            <c:otherwise>${fb.customerUsername}</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="subtext text-truncate">${fb.customerEmail}</div>
                                                </td>
                                                <td class="text-center">
                                                    <span class="rating-pill">
                                                        <i class="bi bi-star-fill"></i>${fb.rating}/5
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${not empty fb.adminResponse}">
                                                            <span class="status-pill status-replied">
                                                                <i class="bi bi-reply-fill"></i>Replied
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-pill status-pending">
                                                                <i class="bi bi-hourglass-split"></i>Pending
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-muted" style="font-size:.85rem">
                                                    <fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td class="text-end pe-4">
                                                    <div class="action-group justify-content-end">
                                                        <a href="${feedbackBasePath}?action=view&id=${fb.id}" class="btn btn-sm btn-outline-primary">
                                                            <i class="bi bi-eye me-1"></i>View
                                                        </a>
                                                        <a href="${feedbackBasePath}?action=view&id=${fb.id}#response-section" class="btn btn-sm btn-outline-success">
                                                            <i class="bi bi-reply me-1"></i>Respond
                                                        </a>
                                                        <form action="${feedbackBasePath}" method="post" class="d-inline" onsubmit="return confirm('Delete this feedback permanently?');">
                                                            <input type="hidden" name="action" value="delete"/>
                                                            <input type="hidden" name="id" value="${fb.id}"/>
                                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                                <i class="bi bi-trash me-1"></i>Delete
                                                            </button>
                                                        </form>
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
            </c:when>

            <%-- ===== CHI TIẾT FEEDBACK ===== --%>
            <c:otherwise>
                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="bi bi-chat-right-text-fill"></i>Feedback Detail</h1>
                        <div class="subtext mt-1">This screen shows the full context so Staff/Admin can decide how to respond.</div>
                    </div>
                </div>

                <div class="row g-4">
                    <div class="col-lg-7">
                        <%-- Thẻ này gom toàn bộ ngữ cảnh: sản phẩm, khách hàng, đơn hàng, nội dung feedback. --%>
                        <div class="card card-main mb-4">
                            <div class="card-body p-4">
                                <div class="d-flex flex-wrap gap-4">
                                    <div>
                                        <c:choose>
                                            <c:when test="${not empty feedback.productImageUrl}">
                                                <img src="${pageContext.request.contextPath}/uploads/product/${feedback.productImageUrl}"
                                                     class="rounded-4 border shadow-sm"
                                                     style="width:160px;height:160px;object-fit:cover;"
                                                     alt="${feedback.productName}"
                                                     onerror="this.style.display='none'; this.nextElementSibling.classList.remove('d-none');">
                                                <div class="thumb-fallback d-none d-flex align-items-center justify-content-center text-center px-2"
                                                     style="width:160px;height:160px;font-size:.9rem;">
                                                    No Image
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="thumb-fallback d-flex align-items-center justify-content-center text-center px-2"
                                                     style="width:160px;height:160px;font-size:.9rem;">
                                                    No Image
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="flex-grow-1 min-w-0">
                                        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                                            <div>
                                                <div class="detail-label mb-2">Product</div>
                                                <h3 class="fw-bold text-dark mb-1">${feedback.productName}</h3>
                                                <div class="subtext">
                                                    Product ID: ${feedback.productId}
                                                    <c:if test="${not empty feedback.productSlug}">
                                                        | Slug: <code>${feedback.productSlug}</code>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <span class="rating-pill">
                                                <i class="bi bi-star-fill"></i>${feedback.rating}/5
                                            </span>
                                        </div>

                                        <div class="row g-3 mt-1">
                                            <div class="col-md-6">
                                                <div class="detail-label">Customer</div>
                                                <div class="detail-box">
                                                    <div class="fw-bold text-dark">
                                                        <c:choose>
                                                            <c:when test="${not empty feedback.customerFullName}">
                                                                ${feedback.customerFullName}
                                                            </c:when>
                                                            <c:otherwise>${feedback.customerUsername}</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="subtext">${feedback.customerEmail}</div>
                                                    <div class="subtext">User ID: ${feedback.userId}</div>
                                                </div>
                                            </div>

                                            <div class="col-md-6">
                                                <div class="detail-label">Order Link</div>
                                                <div class="detail-box">
                                                    <div class="fw-bold text-dark">
                                                        <c:choose>
                                                            <c:when test="${not empty feedback.orderCode}">
                                                                Order ${feedback.orderCode}
                                                            </c:when>
                                                            <c:otherwise>No linked order</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="subtext">
                                                        Order ID:
                                                        <c:choose>
                                                            <c:when test="${not empty feedback.orderId}">
                                                                ${feedback.orderId}
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-12">
                                                <div class="detail-label">Customer Comment</div>
                                                <div class="detail-box comment-box">
                                                    <c:out value="${feedback.comment}"/>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Thẻ này hiển thị phản hồi hiện tại để Staff/Admin biết đã trả lời hay chưa. --%>
                        <div class="card card-main">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                                    <div>
                                        <div class="detail-label">Response Preview</div>
                                        <div class="fw-bold text-dark">Current staff reply</div>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty feedback.adminResponse}">
                                            <span class="status-pill status-replied"><i class="bi bi-reply-fill"></i>Replied</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill status-pending"><i class="bi bi-hourglass-split"></i>Pending</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <c:choose>
                                    <c:when test="${not empty feedback.adminResponse}">
                                        <div class="response-box comment-box mb-3">
                                            <c:out value="${feedback.adminResponse}"/>
                                        </div>
                                        <div class="subtext">
                                            <c:choose>
                                                <c:when test="${not empty feedback.responderFullName}">
                                                    Replied by ${feedback.responderFullName}
                                                </c:when>
                                                <c:otherwise>
                                                    Replied by ${feedback.responderUsername}
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty feedback.respondedAt}">
                                                | <fmt:formatDate value="${feedback.respondedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </c:if>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="response-box text-muted">
                                            No reply has been saved yet. Use the form on the right to respond to this customer.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-5">
                        <%-- Form phản hồi nằm riêng bên phải để thao tác nhanh và không bị rối thông tin. --%>
                        <div class="card card-main mb-4" id="response-section">
                            <div class="card-body p-4">
                                <div class="detail-label">Respond to Feedback</div>
                                <h5 class="fw-bold mb-3 text-dark">Write or update the reply</h5>

                                <form action="${feedbackBasePath}" method="post">
                                    <input type="hidden" name="action" value="respond"/>
                                    <input type="hidden" name="id" value="${feedback.id}"/>

                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Response content</label>
                                        <textarea class="form-control" name="adminResponse" rows="10" placeholder="Write a clear, polite response for the customer..." required><c:out value="${feedback.adminResponse}"/></textarea>
                                    </div>

                                    <div class="d-flex flex-wrap gap-2">
                                        <button type="submit" class="btn btn-primary px-4">
                                            <i class="bi bi-send me-1"></i>Save Response
                                        </button>
                                        <a href="${feedbackBasePath}" class="btn btn-outline-secondary">
                                            Cancel
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="card card-main">
                            <div class="card-body p-4">
                                <div class="detail-label">Record Information</div>
                                <div class="detail-box mb-3">
                                    <div class="subtext mb-1">Created at</div>
                                    <div class="fw-semibold text-dark">
                                        <fmt:formatDate value="${feedback.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>

                                <div class="detail-box mb-3">
                                    <div class="subtext mb-1">Visibility</div>
                                    <c:choose>
                                        <c:when test="${feedback.visible}">
                                            <span class="badge text-bg-success">Visible</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge text-bg-secondary">Hidden</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <form action="${feedbackBasePath}" method="post" onsubmit="return confirm('Delete this feedback permanently?');">
                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="id" value="${feedback.id}"/>
                                    <button type="submit" class="btn btn-outline-danger w-100">
                                        <i class="bi bi-trash me-1"></i>Delete Feedback
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
