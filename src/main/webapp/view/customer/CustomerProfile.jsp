<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Customer Profile</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --ink:#172033;
                --muted:#64748b;
                --line:#e2e8f0;
                --accent:#0f9b8e;
                --soft:#f4f8fb;
            }

            body {
                min-height:100vh;
                background:linear-gradient(180deg, #f7fbfd 0%, #fff 48%, #f4f8fb 100%);
                color:var(--ink);
                font-family:'Segoe UI', system-ui, sans-serif;
            }

            .navbar {
                border-bottom:1px solid var(--line);
                box-shadow:none!important;
            }

            .profile-shell {
                max-width:980px;
            }

            .profile-card {
                border:1px solid var(--line);
                border-radius:8px;
                background:#fff;
                box-shadow:0 18px 45px rgba(15, 23, 42, .08);
                overflow:hidden;
            }

            .profile-side {
                height:100%;
                padding:2rem;
                background:var(--ink);
                color:#fff;
            }

            .avatar-preview {
                width:112px;
                height:112px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                overflow:hidden;
                background:rgba(255,255,255,.12);
                border:2px solid rgba(255,255,255,.18);
                font-size:2rem;
                font-weight:800;
            }

            .avatar-preview img {
                width:100%;
                height:100%;
                object-fit:cover;
            }

            .form-control {
                border-radius:8px;
                border-color:#cbd5e1;
                min-height:44px;
            }

            .form-control:focus {
                border-color:var(--accent);
                box-shadow:0 0 0 .2rem rgba(15, 155, 142, .14);
            }

            .btn-save {
                min-height:44px;
                border-radius:8px;
                background:var(--accent);
                border-color:var(--accent);
                font-weight:700;
            }

            .btn-save:hover {
                background:#0d8278;
                border-color:#0d8278;
            }

            .btn {
                border-radius:8px;
                font-weight:700;
            }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg bg-white">
            <div class="container profile-shell">
                <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">
                    <i class="fa-solid fa-shirt text-success"></i>
                    Clothing Sale
                </a>
                <div class="d-flex gap-2 align-items-center">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-dark">
                        <i class="fa-solid fa-house"></i>
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/logout"
                       class="btn btn-outline-danger"
                       onclick="return confirm('Are you sure you want to logout?');">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        Logout
                    </a>
                </div>
            </div>
        </nav>

        <main class="container profile-shell py-4 py-lg-5">
            <div class="mb-4">
                <h1 class="fw-bold mb-1">My Profile</h1>
                <p class="text-secondary mb-0">View and update your customer account information.</p>
            </div>

            <c:if test="${param.updated == '1'}">
                <div class="alert alert-success">
                    Profile updated successfully.
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <div class="profile-card">
                <div class="row g-0">
                    <div class="col-lg-4">
                        <aside class="profile-side">
                            <div class="avatar-preview mb-3">
                                <c:choose>
                                    <c:when test="${not empty profile.avatarUrl}">
                                        <img src="${fn:escapeXml(profile.avatarUrl)}" alt="Avatar">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-user"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <h2 class="h4 fw-bold mb-1">
                                <c:out value="${profile.fullName}"/>
                            </h2>
                            <p class="mb-3 text-white-50">
                                @<c:out value="${profile.username}"/>
                            </p>
                            <div class="small text-white-50">
                                <div class="mb-2">
                                    <i class="fa-solid fa-envelope me-2"></i>
                                    <c:out value="${profile.email}"/>
                                </div>
                                <c:if test="${not empty profile.phone}">
                                    <div>
                                        <i class="fa-solid fa-phone me-2"></i>
                                        <c:out value="${profile.phone}"/>
                                    </div>
                                </c:if>
                            </div>
                        </aside>
                    </div>
                    <div class="col-lg-8">
                        <form action="${pageContext.request.contextPath}/customer/profile"
                              method="post"
                              class="p-4 p-lg-5"
                              autocomplete="off">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Username</label>
                                    <input type="text"
                                           class="form-control bg-light"
                                           value="${fn:escapeXml(profile.username)}"
                                           readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Role</label>
                                    <input type="text"
                                           class="form-control bg-light"
                                           value="${fn:escapeXml(profile.roleName)}"
                                           readonly>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold" for="fullName">Full name</label>
                                    <input type="text"
                                           id="fullName"
                                           name="fullName"
                                           class="form-control"
                                           maxlength="255"
                                           value="${fn:escapeXml(profile.fullName)}"
                                           required>
                                </div>
                                <div class="col-md-7">
                                    <label class="form-label fw-semibold" for="email">Email</label>
                                    <input type="email"
                                           id="email"
                                           name="email"
                                           class="form-control"
                                           maxlength="100"
                                           value="${fn:escapeXml(profile.email)}"
                                           required>
                                </div>
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold" for="phone">Phone</label>
                                    <input type="text"
                                           id="phone"
                                           name="phone"
                                           class="form-control ${not empty phoneError ? 'is-invalid' : ''}"
                                           maxlength="10"
                                           pattern="^0[1-9][0-9]{8}$"
                                           title="Phone must be 10 digits starting with single 0, for example 0123456789."
                                           placeholder="0123456789"
                                           value="${fn:escapeXml(profile.phone)}">
                                    <c:if test="${not empty phoneError}">
                                        <div class="invalid-feedback d-block">
                                            <c:out value="${phoneError}"/>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold" for="avatarUrl">Avatar URL</label>
                                    <input type="url"
                                           id="avatarUrl"
                                           name="avatarUrl"
                                           class="form-control"
                                           maxlength="255"
                                           value="${fn:escapeXml(profile.avatarUrl)}"
                                           placeholder="https://example.com/avatar.jpg">
                                    <div class="form-text">Use an image URL. Leave blank to keep the default avatar.</div>
                                </div>
                                <div class="col-12 d-flex gap-2 justify-content-end mt-4">
                                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary px-4">
                                        Cancel
                                    </a>
                                    <button type="submit" class="btn btn-primary btn-save px-4">
                                        <i class="fa-solid fa-floppy-disk"></i>
                                        Save changes
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
        <c:if test="${focusField == 'phone'}">
            <script>
                var phoneInput = document.getElementById('phone');
                if (phoneInput) {
                    phoneInput.focus();
                }
            </script>
        </c:if>
    </body>
</html>
