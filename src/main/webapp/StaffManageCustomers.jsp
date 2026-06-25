<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Customer Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        html, body { height: 100%; overflow: hidden; }
        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper { display: flex; height: 100vh; overflow: hidden; }
        .content-area { flex: 1; padding: 28px 32px; min-width: 0; height: 100vh; overflow-y: auto; }
        
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }
        
        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); }
        .card-main .card-header { background: #fff; border-bottom: 1px solid #eef0f5; border-radius: 14px 14px 0 0 !important; padding: 18px 24px; }
        
        /* Cập nhật màu bảng sang đen */
        .table thead th { background: #212529; color: #fff; font-weight: 600; font-size: .85rem; border: none; white-space: nowrap; }
        .table tbody tr:hover { background: #f0f4ff; }
        .table td { vertical-align: middle; font-size: .9rem; }
        
        .badge-active { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fef3c7; color: #92400e; }
        .badge-locked { background: #fee2e2; color: #991b1b; }
        .avatar-circle { width: 36px; height: 36px; border-radius: 50%; background: #e8eaf6; color: #5c6bc0; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: .85rem; }
        .form-section-title { font-size: .8rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: #5c6bc0; margin-bottom: 14px; }
        .empty-state { padding: 56px 0; text-align: center; color: #9ca3af; }
        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>
<div class="main-wrapper">
    <jsp:include page="/view/admin/sidebar.jsp"><jsp:param name="activeTab" value="customers"/></jsp:include>

    <div class="content-area">
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-check-circle-fill"></i> ${sessionScope.successMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <c:if test="${empty pageMode or pageMode eq 'list'}">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active">Customer Management</li>
                </ol>
            </nav>

            <div class="page-header">
                <h1 class="page-title"><i class="bi bi-people-fill"></i>Customer Management</h1>
                <a href="${pageContext.request.contextPath}/staff/customers?action=add" class="btn btn-primary btn-sm px-3">
                    <i class="bi bi-person-plus-fill me-1"></i>Add Customer
                </a>
            </div>

            <div class="card card-main mb-4">
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/staff/customers" class="d-flex gap-2">
                        <input type="hidden" name="action" value="list"/>
                        <input type="text" class="form-control" name="keyword" placeholder="Name, email, phone number..." value="${keyword}"/>
                        <button class="btn btn-primary px-4" type="submit">Search</button>
                        <c:if test="${not empty keyword}">
                            <a href="${pageContext.request.contextPath}/staff/customers" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
                        </c:if>
                    </form>
                </div>
            </div>

            <div class="card card-main">
                <div class="card-header">
                    <span class="fw-semibold text-secondary"><i class="bi bi-list-ul me-1"></i>Customer List 
                        <c:if test="${not empty customers}"><span class="badge bg-dark ms-1">${fn:length(customers)}</span></c:if>
                    </span>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty customers}">
                            <div class="empty-state">No customers found</div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Customer</th>
                                            <th>Username</th>
                                            <th>Email</th>
                                            <th>Phone</th>
                                            <th>Created</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${customers}" varStatus="st">
                                            <tr>
                                                <td class="text-muted">${st.index + 1}</td>
                                                <td><span class="avatar-circle me-2">${fn:toUpperCase(fn:substring(c.fullName, 0, 1))}</span>${c.fullName}</td>
                                                <td><code>${c.username}</code></td>
                                                <td>${c.email}</td>
                                                <td>${not empty c.phone ? c.phone : '—'}</td>
                                                <td class="text-muted">${c.createdAt}</td>
                                                <td>
                                                    <span class="badge ${c.status eq 'ACTIVE' ? 'badge-active' : (c.status eq 'INACTIVE' ? 'badge-inactive' : 'badge-locked')} px-2 py-1 rounded-pill">
                                                        ${c.status}
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/staff/customers?action=edit&id=${c.id}" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i></a>
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
        </c:if>

        <%-- Phần Edit/Add giữ nguyên logic của bạn --%>
        <c:if test="${pageMode eq 'add' or pageMode eq 'edit'}">
            <%-- (Mã của phần Add/Edit bạn để nguyên ở đây) --%>
        </c:if>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>