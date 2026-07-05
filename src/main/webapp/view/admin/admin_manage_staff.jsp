<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Staff Management</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
        <style>
            html, body {
                height: 100%;
                overflow: hidden;
            }
            body {
                background: #f5f6fa;
                font-family: 'Segoe UI', sans-serif;
            }
            .main-wrapper {
                display: flex;
                height: 100vh;
                overflow: hidden;
            }
            .content-area {
                flex: 1;
                padding: 28px 32px;
                min-width: 0;
                height: 100vh;
                overflow-y: auto;
            }

            .page-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 24px;
            }
            .page-title {
                font-size: 1.45rem;
                font-weight: 700;
                color: #1a1d23;
                margin: 0;
            }
            .page-title .bi {
                color: #5c6bc0;
                margin-right: 8px;
            }

            .card-main {
                border: none;
                border-radius: 14px;
                box-shadow: 0 2px 12px rgba(0,0,0,.07);
            }
            .card-main .card-header {
                background: #fff;
                border-bottom: 1px solid #eef0f5;
                border-radius: 14px 14px 0 0 !important;
                padding: 18px 24px;
            }

            .table thead th {
                background: #212529;
                color: #fff;
                font-weight: 600;
                font-size: .85rem;
                border: none;
                white-space: nowrap;
            }
            .table tbody tr:hover {
                background: #f0f4ff;
            }
            .table td {
                vertical-align: middle;
                font-size: .9rem;
            }

            .badge-active {
                background: #d1fae5;
                color: #065f46;
            }
            .badge-inactive {
                background: #fef3c7;
                color: #92400e;
            }
            .badge-locked {
                background: #fee2e2;
                color: #991b1b;
            }
            .avatar-circle {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background: #e8eaf6;
                color: #5c6bc0;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: .85rem;
            }
            .form-section-title {
                font-size: .8rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: .06em;
                color: #5c6bc0;
                margin-bottom: 14px;
            }
            .empty-state {
                padding: 56px 0;
                text-align: center;
                color: #9ca3af;
            }
            .breadcrumb {
                font-size: .82rem;
                margin-bottom: 6px;
            }
        </style>
    </head>
    <body>
        <%
            String staffBasePath = request.getContextPath() + "/admin/staffs";
            request.setAttribute("staffBasePath", staffBasePath);
        %>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="staffs"/>
        </jsp:include>
        <div class="admin-page">
            <%-- Thông báo thành công --%>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${sessionScope.successMsg}"/></div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>

            <c:if test="${not empty errors_general}">
                <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errors_general}"/></div>
            </c:if>

            <%-- 1. GIAO DIỆN DANH SÁCH NHÂN VIÊN --%>
            <c:if test="${empty pageMode or pageMode eq 'list'}">
                <div class="page-header">
                    <h1 class="page-title"><i class="bi bi-person-badge-fill"></i> Staff Management</h1>
                    <a href="${staffBasePath}?action=add" class="btn btn-primary btn-sm px-3">
                        <i class="bi bi-person-plus-fill me-1"></i>Add Staff
                    </a>
                </div>

                <div class="card card-main mb-4">
                    <div class="card-body">
                        <form method="get" action="${staffBasePath}" class="d-flex gap-2">
                            <input type="hidden" name="action" value="list"/>
                            <input type="text" class="form-control" name="keyword" placeholder="Name, email, phone number..." value="${keyword}"/>
                            <button class="btn btn-primary px-4" type="submit">Search</button>
                            <c:if test="${not empty keyword}">
                                <a href="${staffBasePath}" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
                                </c:if>
                        </form>
                    </div>
                </div>

                <div class="card card-main">
                    <div class="card-header">
                        <span class="fw-semibold text-secondary"><i class="bi bi-list-ul me-1"></i>Staff List 
                            <c:if test="${not empty staffs}"><span class="badge bg-dark ms-1">${fn:length(staffs)}</span></c:if>
                            </span>
                        </div>
                        <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${empty staffs}">
                                <div class="empty-state">No staff members found</div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Staff Name</th>
                                                <th>Username</th>
                                                <th>Email</th>
                                                <th>Phone</th>
                                                <th>Created</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="s" items="${staffs}" varStatus="st">
                                                <tr>
                                                    <td class="text-muted">${st.index + 1}</td>
                                                    <td><span class="avatar-circle me-2">${fn:toUpperCase(fn:substring(s.fullName, 0, 1))}</span>${s.fullName}</td>
                                                    <td><code>${s.username}</code></td>
                                                    <td>${s.email}</td>
                                                    <td>${not empty s.phone ? s.phone : '—'}</td>
                                                    <td class="text-muted">${s.createdAt}</td>
                                                    <td>
                                                        <span class="badge ${s.status eq 'ACTIVE' ? 'badge-active' : (s.status eq 'INACTIVE' ? 'badge-inactive' : 'badge-locked')} px-2 py-1 rounded-pill">
                                                            ${s.status}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <a href="${staffBasePath}?action=edit&id=${s.id}" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i></a>
                                                    </td>
                                                    <td>
                                                        <div class="d-flex gap-1">
                                                            <%-- Nút Edit --%>
                                                            <a href="${staffBasePath}?action=edit&id=${s.id}" class="btn btn-sm btn-outline-primary" title="Sửa thông tin">
                                                                <i class="bi bi-pencil-fill"></i>
                                                            </a>

                                                            
                                                            <c:choose>
                                                                <c:when test="${s.status eq 'LOCKED'}">
                                                                    <a href="${staffBasePath}?action=toggle&id=${s.id}" 
                                                                       class="btn btn-sm btn-outline-success" 
                                                                       onclick="return confirm('Are you sure you want to UNLOCK?');" 
                                                                       title="Mở khóa tài khoản">
                                                                        <i class="bi bi-unlock-fill"></i>
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <a href="${staffBasePath}?action=toggle&id=${s.id}" 
                                                                       class="btn btn-sm btn-outline-danger" 
                                                                       onclick="return confirm('Are you sure you want to UNLOCK?');" 
                                                                       title="Khóa / Xóa tài khoản">
                                                                        <i class="bi bi-lock-fill"></i>
                                                                    </a>
                                                                </c:otherwise>
                                                            </c:choose>
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
            </c:if>

            <%-- 2. GIAO DIỆN FORM THÊM MỚI / CHỈNH SỬA NHÂN VIÊN --%>
            <c:if test="${pageMode eq 'add' or pageMode eq 'edit'}">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="${staffBasePath}">Staff Management</a></li>
                        <li class="breadcrumb-item active">${pageMode eq 'add' ? 'Add New Staff' : 'Edit Staff'}</li>
                    </ol>
                </nav>

                <div class="page-header">
                    <h1 class="page-title">
                        <i class="bi ${pageMode eq 'add' ? 'bi-person-plus-fill' : 'bi-pencil-square'}"></i>
                        ${pageMode eq 'add' ? 'Add New Staff' : 'Edit Staff Info'}
                    </h1>
                </div>

                <div class="card card-main mx-auto" style="max-width: 720px;">
                    <div class="card-body p-4">
                        <form method="post" action="${staffBasePath}">
                            <input type="hidden" name="action" value="${pageMode eq 'add' ? 'add' : 'update'}"/>
                            <c:if test="${pageMode eq 'edit'}">
                                <input type="hidden" name="id" value="${staff.id}"/>
                            </c:if>

                            <div class="form-section-title">Account Information</div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small">Username <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="username" 
                                           value="${pageMode eq 'add' ? formData.username : staff.username}" 
                                           placeholder="Enter username" required
                                           ${pageMode eq 'edit' ? 'readonly' : ''}/>
                                    <c:if test="${pageMode eq 'edit'}">
                                        <div class="form-text text-muted">Username cannot be changed.</div>
                                    </c:if>
                                </div>

                                <c:if test="${pageMode eq 'add'}">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Password <span class="text-danger">*</span></label>
                                        <input type="password" class="form-control" name="password" placeholder="Min 6 characters" required/>
                                    </div>
                                </c:if>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small">Status <span class="text-danger">*</span></label>
                                    <select class="form-select" name="status">
                                        <option value="ACTIVE" ${staff.status eq 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="INACTIVE" ${staff.status eq 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                        <option value="LOCKED" ${staff.status eq 'LOCKED' ? 'selected' : ''}>LOCKED</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-section-title">Personal Profile</div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-12">
                                    <label class="form-label fw-semibold small">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="fullName" 
                                           value="${pageMode eq 'add' ? formData.fullName : staff.fullName}" 
                                           placeholder="Enter staff full name" required/>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small">Email Address <span class="text-danger">*</span></label>
                                    <input type="email" class="form-control" name="email" 
                                           value="${pageMode eq 'add' ? formData.email : staff.email}" 
                                           placeholder="example@domain.com" required/>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small">Phone Number</label>
                                    <input type="text" class="form-control" name="phone" 
                                           value="${pageMode eq 'add' ? formData.phone : staff.phone}" 
                                           placeholder="Phone number"/>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 border-top pt-3">
                                <a href="${staffBasePath}" class="btn btn-outline-secondary px-4">Cancel</a>
                                <button type="submit" class="btn btn-primary px-4">
                                    <i class="bi bi-save me-1"></i> Save Changes
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
            <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        </div>
    </body>
</html>