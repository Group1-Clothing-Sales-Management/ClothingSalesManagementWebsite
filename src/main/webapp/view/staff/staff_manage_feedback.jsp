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
        .feedback-page { --feedback-blue:#2563eb; --feedback-ink:#111827; --feedback-muted:#64748b; }
        .feedback-page .min-w-0 { min-width:0; }
        .feedback-page .table thead th { background:#f8fafc !important; color:#64748b !important; font-size:.72rem; letter-spacing:.04em; }
        .feedback-page .card-main { border:1px solid #eef2f7; border-radius:18px; box-shadow:0 10px 30px rgba(15,23,42,.06); background:#fff; overflow:hidden; }
        .feedback-page .subtext { color:var(--feedback-muted); font-size:.84rem; }
        .feedback-page .thumb { width:74px; height:74px; border-radius:15px; object-fit:cover; background:#eef2ff; border:1px solid #e5e7eb; flex:0 0 auto; }
        .feedback-page .thumb-fallback { width:74px; height:74px; border-radius:15px; background:#eef2ff; border:1px solid #e5e7eb; color:#64748b; font-size:.72rem; font-weight:700; flex:0 0 auto; }
        .feedback-page .product-title { color:var(--feedback-ink); font-weight:800; font-size:1rem; }
        .feedback-page .product-row { transition:background .15s ease, transform .15s ease; }
        .feedback-page .product-row:hover { background:#f8fbff; }
        .feedback-page .product-link { color:inherit; text-decoration:none; }
        .feedback-page .metric { border:1px solid #eef2f7; border-radius:13px; padding:10px 13px; min-width:86px; background:#fff; }
        .feedback-page .metric-value { color:var(--feedback-ink); font-size:1.08rem; font-weight:800; line-height:1.1; }
        .feedback-page .metric-label { color:var(--feedback-muted); font-size:.72rem; margin-top:4px; }
        .feedback-page .rating-pill, .feedback-page .status-pill { border-radius:999px; padding:.38rem .7rem; font-size:.78rem; font-weight:700; display:inline-flex; align-items:center; gap:6px; white-space:nowrap; }
        .feedback-page .rating-pill { border:1px solid #fde68a; background:#fffbeb; color:#b45309; }
        .feedback-page .status-replied { background:#ecfdf5; color:#047857; border:1px solid #a7f3d0; }
        .feedback-page .status-pending { background:#fff7ed; color:#9a3412; border:1px solid #fed7aa; }
        .feedback-page .empty-state { padding:72px 20px; text-align:center; color:#94a3b8; }
        .feedback-page .empty-state .bi { display:block; font-size:2.8rem; margin-bottom:12px; }
        .feedback-page .detail-label { color:#64748b; font-size:.74rem; font-weight:800; letter-spacing:.05em; text-transform:uppercase; }
        .feedback-page .product-hero { background:linear-gradient(135deg,#eff6ff 0%,#fff 65%); border-bottom:1px solid #e5e7eb; }
        .feedback-page .hero-image { width:112px; height:112px; border-radius:20px; object-fit:cover; background:#e0e7ff; border:1px solid #dbeafe; }
        .feedback-page .feedback-card { border:1px solid #e8edf5; border-radius:16px; padding:16px; background:#fff; }
        .feedback-page .feedback-card + .feedback-card { margin-top:14px; }
        .feedback-page .avatar { width:42px; height:42px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; background:#dbeafe; color:#1d4ed8; font-weight:800; flex:0 0 auto; }
        .feedback-page .comment-box { white-space:pre-line; line-height:1.55; color:#1f2937; background:#f8fafc; border-radius:12px; padding:11px 13px; }
        .feedback-page .reply-panel { background:#f8fbff; border:1px solid #dbeafe; border-radius:12px; padding:12px; }
        .feedback-page textarea { min-height:76px; resize:vertical; }
        .feedback-page .star { color:#f59e0b; font-size:.82rem; }
        .feedback-page .star-muted { color:#cbd5e1; }
        @media (max-width: 767.98px) {
            .feedback-page .hero-image { width:84px; height:84px; }
            .feedback-page .metric { min-width:74px; padding:8px 9px; }
        }
    </style>
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="feedback"/>
</jsp:include>

<div class="admin-page feedback-page">
    <c:if test="${not empty sessionScope.successMsg}">
        <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${sessionScope.successMsg}"/></div>
        <c:remove var="successMsg" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMsg}">
        <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${sessionScope.errorMsg}"/></div>
        <c:remove var="errorMsg" scope="session"/>
    </c:if>

    <c:choose>
        <%-- Product overview --%>
        <c:when test="${pageMode eq 'list' or empty pageMode}">
            <div class="page-header">
                <jsp:include page="/view/admin/common/page_heading.jsp">
                    <jsp:param name="icon" value="fa-solid fa-comments"/>
                    <jsp:param name="title" value="Feedback Management"/>
                </jsp:include>
            </div>

            <div class="card card-main">
                <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <div class="fw-bold text-dark"><i class="bi bi-box-seam me-2 text-primary"></i>Products with feedback</div>
                        
                    </div>
                    <div class="d-flex gap-2">
                        <span class="badge rounded-pill text-bg-primary px-3 py-2">${fn:length(productGroups)} products</span>
                        <span class="badge rounded-pill bg-light text-dark border px-3 py-2">${totalFeedbackCount} feedback</span>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty productGroups}">
                        <div class="empty-state">
                            <i class="bi bi-chat-square-dots"></i>
                            <p class="fw-semibold mb-1">No feedback found</p>
                            <p class="small mb-0">New customer feedback will appear here grouped by product.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0" data-client-pagination data-pagination-label="products">
                                <thead class="table-light">
                                <tr>
                                    <th class="ps-4 border-0 text-secondary small">PRODUCT</th>
                                    <th class="text-center border-0 text-secondary small">FEEDBACK</th>
                                    <th class="text-center border-0 text-secondary small">RATING</th>
                                    <th class="text-center border-0 text-secondary small">REPLY STATUS</th>
                                    <th class="text-end pe-4 border-0"></th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="group" items="${productGroups}">
                                    <tr class="product-row">
                                        <td class="ps-4 py-3">
                                            <a class="product-link d-flex align-items-center gap-3" href="${feedbackBasePath}?action=view&productId=${group.productId}">
                                                <c:choose>
                                                    <c:when test="${not empty group.productImageUrl}">
                                                        <img src="${pageContext.request.contextPath}/media/product/${group.productImageUrl}" class="thumb" alt="Product image" onerror="this.style.display='none';this.nextElementSibling.classList.remove('d-none');"/>
                                                        <div class="thumb-fallback d-none align-items-center justify-content-center text-center">No image</div>
                                                    </c:when>
                                                    <c:otherwise><div class="thumb-fallback d-flex align-items-center justify-content-center text-center">No image</div></c:otherwise>
                                                </c:choose>
                                                <span class="min-w-0">
                                                    <span class="product-title d-block text-truncate"><c:out value="${group.productName}"/></span>
                                                    <span class="subtext d-block">Product #${group.productId}<c:if test="${not empty group.productSlug}"> · <c:out value="${group.productSlug}"/></c:if></span>
                                                </span>
                                            </a>
                                        </td>
                                        <td class="text-center">
                                            <div class="metric d-inline-block text-start"><div class="metric-value">${group.feedbackCount}</div><div class="metric-label">total reviews</div></div>
                                        </td>
                                        <td class="text-center">
                                            <span class="rating-pill"><i class="bi bi-star-fill"></i><fmt:formatNumber value="${group.averageRating}" maxFractionDigits="1"/> / 5</span>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${group.pendingCount eq 0}"><span class="status-pill status-replied"><i class="bi bi-check2-circle"></i>All replied</span></c:when>
                                                <c:otherwise><span class="status-pill status-pending"><i class="bi bi-hourglass-split"></i>${group.pendingCount} pending</span></c:otherwise>
                                            </c:choose>
                                            <div class="subtext mt-1"><fmt:formatDate value="${group.latestCreatedAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        </td>
                                        <td class="text-end pe-4"><a class="btn btn-sm btn-primary px-3" href="${feedbackBasePath}?action=view&productId=${group.productId}">View feedback <i class="bi bi-arrow-right ms-1"></i></a></td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:when>

        <%-- All feedback for one product --%>
        <c:otherwise>
            <div class="page-header">
                <jsp:include page="/view/admin/common/page_heading.jsp">
                    <jsp:param name="icon" value="fa-solid fa-comment-dots"/>
                    <jsp:param name="title" value="Product Feedback"/>
                </jsp:include>
            </div>

            <div class="card card-main mb-4">
                <div class="product-hero p-4">
                    <div class="d-flex align-items-center gap-3 flex-wrap">
                        <c:choose>
                            <c:when test="${not empty productGroup.productImageUrl}">
                                <img src="${pageContext.request.contextPath}/media/product/${productGroup.productImageUrl}" class="hero-image" alt="Product image" onerror="this.style.display='none';this.nextElementSibling.classList.remove('d-none');"/>
                                <div class="hero-image d-none align-items-center justify-content-center text-center text-muted small">No image</div>
                            </c:when>
                            <c:otherwise><div class="hero-image d-flex align-items-center justify-content-center text-center text-muted small">No image</div></c:otherwise>
                        </c:choose>
                        <div class="flex-grow-1 min-w-0">
                            <div class="detail-label mb-1">Product #${productGroup.productId}</div>
                            <h2 class="h4 fw-bold text-dark mb-1"><c:out value="${productGroup.productName}"/></h2>
                            <div class="subtext"><c:out value="${productGroup.productSlug}"/></div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <div class="metric"><div class="metric-value">${productGroup.feedbackCount}</div><div class="metric-label">feedback</div></div>
                            <div class="metric"><div class="metric-value"><fmt:formatNumber value="${productGroup.averageRating}" maxFractionDigits="1"/></div><div class="metric-label">average rating</div></div>
                            <div class="metric"><div class="metric-value">${productGroup.pendingCount}</div><div class="metric-label">pending reply</div></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <div><h3 class="h6 fw-bold mb-1">Customer feedback</h3><div class="subtext">Newest feedback appears first.</div></div>
                <span class="badge rounded-pill bg-light text-dark border px-3 py-2">${fn:length(feedbacks)} reviews</span>
            </div>

            <div id="feedbackPaginationList" data-client-pagination-container
                 data-pagination-page-size="10">
            <c:forEach var="fb" items="${feedbacks}">
                <div class="feedback-card">
                    <div class="d-flex justify-content-between align-items-start gap-3 flex-wrap">
                        <div class="d-flex align-items-center gap-3 min-w-0">
                            <div class="avatar"><c:choose><c:when test="${not empty fb.customerFullName}"><c:out value="${fn:substring(fb.customerFullName, 0, 1)}"/></c:when><c:otherwise>U</c:otherwise></c:choose></div>
                            <div class="min-w-0">
                                <div class="fw-bold text-dark text-truncate"><c:choose><c:when test="${not empty fb.customerFullName}"><c:out value="${fb.customerFullName}"/></c:when><c:otherwise><c:out value="${fb.customerUsername}"/></c:otherwise></c:choose></div>
                                <div class="subtext text-truncate"><c:out value="${fb.customerEmail}"/> · User #${fb.userId}</div>
                            </div>
                        </div>
                        <div class="text-end">
                            <div class="mb-1">
                                <c:forEach begin="1" end="5" var="star"><i class="bi bi-star-fill star ${star le fb.rating ? '' : 'star-muted'}"></i></c:forEach>
                                <span class="rating-pill ms-1">${fb.rating}/5</span>
                            </div>
                            <div class="subtext"><fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                        </div>
                    </div>

                    <div class="comment-box mt-2"><c:choose><c:when test="${not empty fb.comment}"><c:out value="${fb.comment}"/></c:when><c:otherwise><span class="text-muted">This customer left a rating without a written comment.</span></c:otherwise></c:choose></div>

                    <div class="reply-panel mt-2">
                        <div class="d-flex justify-content-between align-items-center gap-2 mb-1 flex-wrap">
                            <div class="fw-bold text-dark"><i class="bi bi-reply me-1 text-primary"></i><c:choose><c:when test="${not empty fb.adminResponse}">Staff/Admin response</c:when><c:otherwise>Reply to this feedback</c:otherwise></c:choose></div>
                            <c:choose><c:when test="${not empty fb.adminResponse}"><span class="status-pill status-replied"><i class="bi bi-check2-circle"></i>Replied</span></c:when><c:otherwise><span class="status-pill status-pending"><i class="bi bi-hourglass-split"></i>Needs reply</span></c:otherwise></c:choose>
                        </div>
                        <form action="${feedbackBasePath}" method="post">
                            <input type="hidden" name="action" value="respond"/>
                            <input type="hidden" name="id" value="${fb.id}"/>
                            <input type="hidden" name="productId" value="${productGroup.productId}"/>
                            <textarea class="form-control mb-1" name="adminResponse" rows="2" required placeholder="Write a clear, polite response for this customer..."><c:out value="${fb.adminResponse}"/></textarea>
                            <div class="d-flex justify-content-between align-items-center gap-2 flex-wrap">
                                <div class="subtext"><c:if test="${not empty fb.adminResponse}">Editing replaces the current Staff/Admin response.</c:if></div>
                                <button type="submit" class="btn btn-sm btn-primary"><i class="bi bi-send me-1"></i><c:choose><c:when test="${not empty fb.adminResponse}">Save edited response</c:when><c:otherwise>Send response</c:otherwise></c:choose></button>
                            </div>
                        </form>
                        <c:if test="${not empty fb.adminResponse and not empty fb.respondedAt}"><div class="subtext mt-2">Last updated <fmt:formatDate value="${fb.respondedAt}" pattern="dd/MM/yyyy HH:mm"/><c:if test="${not empty fb.responderFullName}"> by <c:out value="${fb.responderFullName}"/></c:if></div></c:if>
                    </div>

                    <c:if test="${sessionScope.authRoleName eq 'ADMIN'}">
                        <div class="d-flex justify-content-end mt-3">
                            <form action="${feedbackBasePath}" method="post"
                                  data-confirm="Remove this feedback from the selected customer permanently?"
                                  data-confirm-title="Remove feedback"
                                  data-confirm-label="Remove feedback"
                                  data-confirm-danger="true">
                                <input type="hidden" name="action" value="delete"/>
                                <input type="hidden" name="id" value="${fb.id}"/>
                                <input type="hidden" name="productId" value="${productGroup.productId}"/>
                                <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash me-1"></i>Remove this customer feedback</button>
                            </form>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
            </div>
            <div id="feedbackPagination" class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-3"
                 data-pagination-controls-for="feedbackPaginationList">
                <small class="text-muted pagination-info"></small>
                <nav aria-label="Feedback pages"><ul class="pagination pagination-sm mb-0 pagination-controls"></ul></nav>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/view/admin/common/admin_layout_end.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
