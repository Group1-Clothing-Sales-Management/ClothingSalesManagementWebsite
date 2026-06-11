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
        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper { display: flex; min-height: 100vh; }
        .content-area { flex: 1; padding: 28px 32px; min-width: 0; }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); }
        .card-main .card-header {
            background: #fff;
            border-bottom: 1px solid #eef0f5;
            border-radius: 14px 14px 0 0 !important;
            padding: 18px 24px;
        }

        .table thead th {
            background: #5c6bc0;
            color: #fff;
            font-weight: 600;
            font-size: .85rem;
            border: none;
            white-space: nowrap;
        }
        .table tbody tr:hover { background: #f0f4ff; }
        .table td { vertical-align: middle; font-size: .9rem; }

        .badge-active   { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fef3c7; color: #92400e; }
        .badge-locked   { background: #fee2e2; color: #991b1b; }

        .avatar-circle {
            width: 36px; height: 36px;
            border-radius: 50%;
            background: #e8eaf6;
            color: #5c6bc0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: .85rem;
            flex-shrink: 0;
        }

        .search-group { max-width: 360px; }

        .form-section-title {
            font-size: .8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #5c6bc0;
            margin-bottom: 14px;
        }
        .form-label { font-weight: 600; font-size: .875rem; color: #374151; }
        .required-star { color: #ef4444; }

        .empty-state { padding: 56px 0; text-align: center; color: #9ca3af; }
        .empty-state .bi { font-size: 2.8rem; display: block; margin-bottom: 12px; }

        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>
<div class="main-wrapper">

    <jsp:include page="/view/admin/sidebar.jsp"/>

    <div class="content-area">

        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <span>${sessionScope.successMsg}</span>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
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
                <a href="${pageContext.request.contextPath}/staff/customers?action=add"
                   class="btn btn-primary btn-sm px-3">
                    <i class="bi bi-person-plus-fill me-1"></i>Add Customer
                </a>
            </div>

            <div class="card card-main">
                <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <span class="fw-semibold text-secondary" style="font-size:.9rem">
                        <i class="bi bi-list-ul me-1"></i>
                        Customer List
                        <c:if test="${not empty customers}">
                            <span class="badge bg-primary ms-1">${fn:length(customers)}</span>
                        </c:if>
                    </span>

                    <form method="get" action="${pageContext.request.contextPath}/staff/customers"
                          class="d-flex search-group gap-2">
                        <input type="hidden" name="action" value="list"/>
                        <div class="input-group input-group-sm">
                            <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" class="form-control" name="keyword"
                                   placeholder="Name, email, phone..."
                                   value="${not empty keyword ? keyword : ''}"/>
                            <button class="btn btn-outline-primary" type="submit">Search</button>
                            <c:if test="${not empty keyword}">
                                <a href="${pageContext.request.contextPath}/staff/customers"
                                   class="btn btn-outline-secondary">
                                    <i class="bi bi-x-lg"></i>
                                </a>
                            </c:if>
                        </div>
                    </form>
                </div>

                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty customers}">
                            <div class="empty-state">
                                <i class="bi bi-person-slash"></i>
                                <p class="mb-0 fw-semibold">No customers found</p>
                                <p class="text-muted small mt-1">
                                    <c:choose>
                                        <c:when test="${not empty keyword}">Try searching with a different keyword.</c:when>
                                        <c:otherwise>There are no customers in the system yet.</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 align-middle">
                                    <thead>
                                        <tr>
                                            <th style="width:52px">#</th>
                                            <th>Customer</th>
                                            <th>Username</th>
                                            <th>Email</th>
                                            <th>Phone</th>
                                            <th>Created At</th>
                                            <th style="width:110px">Status</th>
                                            <th style="width:110px">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${customers}" varStatus="st">
                                            <tr>
                                                <td class="text-muted">${st.index + 1}</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="avatar-circle">
                                                            ${fn:toUpperCase(fn:substring(c.fullName, 0, 1))}
                                                        </span>
                                                        <span class="fw-semibold">${c.fullName}</span>
                                                    </div>
                                                </td>
                                                <td><code>${c.username}</code></td>
                                                <td>${c.email}</td>
                                                <td>${not empty c.phone ? c.phone : '—'}</td>
                                                <td class="text-muted" style="font-size:.82rem">${c.createdAt}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${c.status eq 'ACTIVE'}">
                                                            <span class="badge badge-active px-2 py-1 rounded-pill">Active</span>
                                                        </c:when>
                                                        <c:when test="${c.status eq 'INACTIVE'}">
                                                            <span class="badge badge-inactive px-2 py-1 rounded-pill">Inactive</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-locked px-2 py-1 rounded-pill">Locked</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/staff/customers?action=edit&id=${c.id}"
                                                       class="btn btn-sm btn-outline-primary px-2 py-1"
                                                       title="Edit">
                                                        <i class="bi bi-pencil-fill"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/staff/customers?action=view&id=${c.id}"
                                                       class="btn btn-sm btn-outline-secondary px-2 py-1"
                                                       title="View details">
                                                        <i class="bi bi-eye-fill"></i>
                                                    </a>
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

        <c:if test="${pageMode eq 'add'}">

            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/customers">Customer Management</a></li>
                    <li class="breadcrumb-item active">Add New</li>
                </ol>
            </nav>

            <div class="page-header">
                <h1 class="page-title"><i class="bi bi-person-plus-fill"></i>Add New Customer</h1>
                <a href="${pageContext.request.contextPath}/staff/customers"
                   class="btn btn-outline-secondary btn-sm px-3">
                    <i class="bi bi-arrow-left me-1"></i>Back
                </a>
            </div>

            <c:if test="${not empty errors.general}">
                <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${errors.general}</div>
            </c:if>

            <div class="card card-main">
                <div class="card-body p-4">
                    <form method="post" action="${pageContext.request.contextPath}/staff/customers" novalidate>
                        <input type="hidden" name="action" value="add"/>

                        <p class="form-section-title"><i class="bi bi-person-vcard me-1"></i>Account Information</p>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label">Username <span class="required-star">*</span></label>
                                <input type="text" name="username"
                                       class="form-control ${not empty errors.username ? 'is-invalid' : ''}"
                                       value="${formData.username}" placeholder="e.g. johndoe"/>
                                <c:if test="${not empty errors.username}">
                                    <div class="invalid-feedback">${errors.username}</div>
                                </c:if>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Password <span class="required-star">*</span></label>
                                <div class="input-group">
                                    <input type="password" name="password" id="addPassword"
                                           class="form-control" placeholder="Enter password"/>
                                    <button type="button" class="btn btn-outline-secondary"
                                            onclick="togglePassword('addPassword', this)">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <p class="form-section-title"><i class="bi bi-info-circle me-1"></i>Personal Information</p>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name <span class="required-star">*</span></label>
                                <input type="text" name="fullName"
                                       class="form-control ${not empty errors.fullName ? 'is-invalid' : ''}"
                                       value="${formData.fullName}" placeholder="John Doe"/>
                                <c:if test="${not empty errors.fullName}">
                                    <div class="invalid-feedback">${errors.fullName}</div>
                                </c:if>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone <span class="required-star">*</span></label>
                                <input type="text" name="phone"
                                       class="form-control ${not empty errors.phone ? 'is-invalid' : ''}"
                                       value="${formData.phone}" placeholder="09xxxxxxxx"/>
                                <c:if test="${not empty errors.phone}">
                                    <div class="invalid-feedback">${errors.phone}</div>
                                </c:if>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Email <span class="required-star">*</span></label>
                                <input type="email" name="email"
                                       class="form-control ${not empty errors.email ? 'is-invalid' : ''}"
                                       value="${formData.email}" placeholder="example@email.com"/>
                                <c:if test="${not empty errors.email}">
                                    <div class="invalid-feedback">${errors.email}</div>
                                </c:if>
                            </div>
                        </div>

                        <hr class="my-4"/>
                        <div class="d-flex gap-2 justify-content-end">
                            <a href="${pageContext.request.contextPath}/staff/customers"
                               class="btn btn-outline-secondary px-4">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-check-lg me-1"></i>Save Customer
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <c:if test="${pageMode eq 'edit'}">

            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/customers">Customer Management</a></li>
                    <li class="breadcrumb-item active">Edit</li>
                </ol>
            </nav>

            <div class="page-header">
                <h1 class="page-title"><i class="bi bi-pencil-square"></i>Edit Customer</h1>
                <a href="${pageContext.request.contextPath}/staff/customers"
                   class="btn btn-outline-secondary btn-sm px-3">
                    <i class="bi bi-arrow-left me-1"></i>Back
                </a>
            </div>

            <c:if test="${not empty errors.general}">
                <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${errors.general}</div>
            </c:if>

            <div class="card card-main">
                <div class="card-body p-4">
                    <form method="post" action="${pageContext.request.contextPath}/staff/customers" novalidate>
                        <input type="hidden" name="action" value="update"/>
                        <input type="hidden" name="id" value="${customer.id}"/>

                        <p class="form-section-title"><i class="bi bi-person-vcard me-1"></i>Account Information</p>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label">Username</label>
                                <input type="text" class="form-control bg-light"
                                       value="${customer.username}" disabled/>
                                <div class="form-text">Username cannot be changed.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Status <span class="required-star">*</span></label>
                                <select name="status"
                                        class="form-select ${not empty errors.status ? 'is-invalid' : ''}">
                                    <option value="ACTIVE"   ${customer.status eq 'ACTIVE'   ? 'selected' : ''}>Active</option>
                                    <option value="INACTIVE" ${customer.status eq 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                    <option value="LOCKED"   ${customer.status eq 'LOCKED'   ? 'selected' : ''}>Locked</option>
                                </select>
                                <c:if test="${not empty errors.status}">
                                    <div class="invalid-feedback">${errors.status}</div>
                                </c:if>
                            </div>
                        </div>

                        <p class="form-section-title"><i class="bi bi-info-circle me-1"></i>Personal Information</p>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name <span class="required-star">*</span></label>
                                <input type="text" name="fullName"
                                       class="form-control ${not empty errors.fullName ? 'is-invalid' : ''}"
                                       value="${customer.fullName}"/>
                                <c:if test="${not empty errors.fullName}">
                                    <div class="invalid-feedback">${errors.fullName}</div>
                                </c:if>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone <span class="required-star">*</span></label>
                                <input type="text" name="phone"
                                       class="form-control ${not empty errors.phone ? 'is-invalid' : ''}"
                                       value="${customer.phone}"/>
                                <c:if test="${not empty errors.phone}">
                                    <div class="invalid-feedback">${errors.phone}</div>
                                </c:if>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Email <span class="required-star">*</span></label>
                                <input type="email" name="email"
                                       class="form-control ${not empty errors.email ? 'is-invalid' : ''}"
                                       value="${customer.email}"/>
                                <c:if test="${not empty errors.email}">
                                    <div class="invalid-feedback">${errors.email}</div>
                                </c:if>
                            </div>
                        </div>

                        <hr class="my-4"/>

                        <div class="row g-3 mb-2">
                            <div class="col-md-6">
                                <label class="form-label text-muted">Created At</label>
                                <input type="text" class="form-control bg-light text-muted"
                                       value="${customer.createdAt}" disabled/>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-muted">Last Updated</label>
                                <input type="text" class="form-control bg-light text-muted"
                                       value="${customer.updatedAt}" disabled/>
                            </div>
                        </div>

                        <hr class="my-4"/>
                        <div class="d-flex gap-2 justify-content-end">
                            <a href="${pageContext.request.contextPath}/staff/customers"
                               class="btn btn-outline-secondary px-4">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-check-lg me-1"></i>Save Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const icon  = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }

    document.querySelectorAll('.alert').forEach(function (el) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(el);
            bsAlert.close();
        }, 4000);
    });
</script>
</body>
</html>
