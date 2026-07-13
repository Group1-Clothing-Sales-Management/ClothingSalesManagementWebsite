<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="editMode" value="${not empty errorMessage or not empty phoneError}"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Customer Profile | Clothing Sale</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --ink:#25211e;
                --muted:#6f665e;
                --line:#e9e0d7;
                --primary:#c65b3d;
                --primary-dark:#a9462d;
                --accent:#e9a957;
                --surface:#ffffff;
                --bg:#faf7f2;
                --danger:#bd4a38;
            }

            * {
                box-sizing:border-box;
            }

            body {
                min-height:100vh;
                margin:0;
                color:var(--ink);
                background:
                    radial-gradient(circle at 8% 8%, rgba(230, 157, 79, .18), transparent 28%),
                    radial-gradient(circle at 88% 12%, rgba(198, 91, 61, .09), transparent 24%),
                    linear-gradient(180deg, #fffdf9 0%, var(--bg) 48%, #f5eee7 100%);
                font-family:"Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            }

            body.profile-modal-open {
                overflow:hidden;
            }

            .profile-shell {
                width:100%;
                max-width:1120px;
                margin:0 auto;
                padding-left:18px;
                padding-right:18px;
            }

            .profile-navbar {
                position:sticky;
                top:0;
                z-index:20;
                border-bottom:1px solid rgba(228, 231, 236, .9);
                background:rgba(255, 255, 255, .9);
                backdrop-filter:blur(14px);
            }

            .profile-nav-inner {
                min-height:70px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:18px;
            }

            .brand-link {
                display:inline-flex;
                align-items:center;
                gap:10px;
                color:var(--ink);
                text-decoration:none;
                font-weight:900;
            }

            .brand-mark {
                width:38px;
                height:38px;
                border-radius:8px;
                display:grid;
                place-items:center;
                color:#fff;
                background:linear-gradient(135deg, var(--ink), var(--primary));
                box-shadow:0 12px 26px rgba(198, 91, 61, .22);
            }

            .nav-actions {
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:10px;
                flex-wrap:wrap;
            }

            .nav-action {
                min-height:42px;
                border-radius:8px;
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:0 14px;
                font-weight:800;
                text-decoration:none;
            }

            .nav-action.home {
                border:1px solid var(--line);
                background:#fff;
                color:var(--ink);
            }

            .nav-action.home:hover {
                border-color:#d9b6a4;
                color:var(--primary);
            }

            .nav-action.logout {
                border:1px solid #efd4c8;
                background:#fff;
                color:var(--danger);
            }

            .nav-action.logout:hover {
                background:#fff1ed;
                color:var(--primary-dark);
            }

            .page-hero {
                padding:42px 0 22px;
                display:flex;
                align-items:flex-end;
                justify-content:space-between;
                gap:18px;
            }

            .page-kicker {
                width:max-content;
                margin-bottom:12px;
                padding:7px 11px;
                border-radius:999px;
                background:#fff3dc;
                color:var(--primary-dark);
                font-size:.8rem;
                font-weight:900;
                text-transform:uppercase;
                letter-spacing:.06em;
            }

            .page-title {
                margin:0;
                font-size:clamp(2.1rem, 4vw, 3.35rem);
                line-height:1.02;
                font-weight:950;
            }

            .page-subtitle {
                max-width:620px;
                margin:12px 0 0;
                color:var(--muted);
                font-size:1rem;
            }

            .status-pill {
                min-height:42px;
                border:1px solid #bbf7d0;
                border-radius:999px;
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:0 14px;
                color:#047857;
                background:#f0fdf4;
                font-weight:800;
                white-space:nowrap;
            }

            .alert {
                border:0;
                border-radius:8px;
                display:flex;
                align-items:center;
                gap:10px;
                font-weight:700;
                box-shadow:0 14px 35px rgba(15, 23, 42, .08);
            }

            .profile-grid {
                display:grid;
                grid-template-columns:minmax(280px, .72fr) minmax(0, 1.28fr);
                gap:22px;
                align-items:stretch;
                padding-bottom:54px;
            }

            .profile-summary,
            .profile-form-panel {
                border:1px solid rgba(233, 224, 215, .95);
                border-radius:18px;
                background:rgba(255, 255, 255, .94);
                box-shadow:0 22px 60px rgba(74, 54, 39, .09);
            }

            .profile-summary {
                display:flex;
                flex-direction:column;
                overflow:hidden;
            }

            .summary-cover {
                height:118px;
                background:linear-gradient(135deg, rgba(37, 33, 30, .98), rgba(198, 91, 61, .92));
            }

            .summary-body {
                flex:1;
                display:flex;
                flex-direction:column;
                padding:0 24px 26px;
            }

            .avatar-preview {
                width:128px;
                height:128px;
                margin-top:-64px;
                border:6px solid #fff;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                overflow:hidden;
                color:#fff;
                background:linear-gradient(135deg, var(--ink), var(--primary));
                box-shadow:0 18px 38px rgba(74, 54, 39, .20);
                font-size:2.35rem;
            }

            .avatar-preview img {
                width:100%;
                height:100%;
                object-fit:cover;
            }

            .profile-name {
                margin:18px 0 4px;
                font-size:1.45rem;
                font-weight:900;
                line-height:1.18;
            }

            .profile-handle {
                color:var(--muted);
                font-weight:700;
            }

            .contact-list {
                display:grid;
                gap:12px;
                margin-top:22px;
            }

            .contact-row {
                min-width:0;
                display:flex;
                align-items:center;
                gap:12px;
                color:#344054;
            }

            .contact-icon {
                width:36px;
                height:36px;
                border-radius:8px;
                display:grid;
                place-items:center;
                color:var(--primary);
                background:#fff3dc;
                flex:0 0 auto;
            }

            .contact-row span:last-child {
                min-width:0;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
            }

            .summary-divider {
                height:1px;
                margin:24px 0 24px;
                margin-top:auto;
                background:var(--line);
            }

            .summary-note {
                margin:0;
                color:var(--muted);
                font-size:.92rem;
                line-height:1.55;
            }

            .profile-form-panel {
                padding:28px;
            }

            .form-heading {
                display:flex;
                align-items:flex-start;
                justify-content:space-between;
                gap:16px;
                margin-bottom:24px;
            }

            .form-heading h2 {
                margin:0;
                font-size:1.35rem;
                font-weight:900;
            }

            .form-heading p {
                margin:6px 0 0;
                color:var(--muted);
            }

            .section-chip {
                min-height:34px;
                border-radius:999px;
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:0 12px;
                color:var(--primary-dark);
                background:#fff3dc;
                font-weight:800;
                white-space:nowrap;
            }

            .form-label {
                margin-bottom:8px;
                color:#344054;
                font-size:.9rem;
                font-weight:800;
            }

            .field-control {
                position:relative;
            }

            .field-icon {
                position:absolute;
                left:15px;
                top:50%;
                transform:translateY(-50%);
                color:#98a2b3;
                pointer-events:none;
            }

            .form-control {
                min-height:50px;
                border:1px solid #d9cfc6;
                border-radius:12px;
                padding-left:44px;
                background:var(--surface);
                color:var(--ink);
                box-shadow:0 1px 2px rgba(16, 24, 40, .04);
            }

            .form-control.readonly-control {
                background:#fcf8f4;
                color:#6f665e;
                border-color:#eaded4;
                cursor:default;
            }

            .form-control:focus {
                border-color:var(--primary);
                box-shadow:0 0 0 .22rem rgba(198, 91, 61, .14);
            }

            .form-text {
                color:var(--muted);
            }

            .form-actions {
                display:flex;
                justify-content:flex-end;
                gap:10px;
                padding-top:8px;
                flex-wrap:wrap;
            }

            .btn {
                border-radius:8px;
                font-weight:800;
            }

            .btn-save {
                min-height:46px;
                border:0;
                display:inline-flex;
                align-items:center;
                gap:8px;
                background:linear-gradient(135deg, var(--primary), var(--accent));
                box-shadow:0 14px 24px rgba(198, 91, 61, .22);
            }

            .btn-save:hover,
            .btn-save:focus {
                background:linear-gradient(135deg, var(--primary-dark), var(--primary));
                box-shadow:0 16px 28px rgba(198, 91, 61, .27);
            }

            .btn-edit-profile {
                min-height:42px;
                display:inline-flex;
                align-items:center;
                gap:8px;
                border:1px solid var(--primary);
                color:var(--primary);
                background:#fff;
            }

            .btn-edit-profile:hover,
            .btn-edit-profile:focus-visible {
                border-color:var(--primary-dark);
                color:#fff;
                background:var(--primary);
            }

            .form-heading-actions {
                display:flex;
                align-items:center;
                gap:10px;
                flex-wrap:wrap;
                justify-content:flex-end;
            }

            .profile-editable:not([readonly]) {
                background:#fff;
                border-color:#d9cfc6;
                cursor:text;
            }

            .profile-editable:disabled {
                opacity:.72;
                cursor:not-allowed;
            }

            .logout-dialog {
                position:fixed;
                inset:0;
                z-index:1000;
                display:none;
                align-items:center;
                justify-content:center;
                padding:18px;
                background:rgba(15, 23, 42, .46);
                backdrop-filter:blur(4px);
            }

            .logout-dialog.is-open {
                display:flex;
            }

            .logout-panel {
                width:min(460px, 100%);
                border-radius:8px;
                background:#fff;
                padding:28px;
                box-shadow:0 26px 80px rgba(15, 23, 42, .28);
            }

            .logout-icon {
                width:54px;
                height:54px;
                border-radius:16px;
                display:grid;
                place-items:center;
                color:#fff;
                background:linear-gradient(135deg, var(--ink), var(--primary));
                box-shadow:0 14px 30px rgba(198, 91, 61, .24);
                font-size:1.25rem;
                flex:0 0 auto;
            }

            .logout-title {
                margin:0 0 6px;
                font-size:1.25rem;
                font-weight:900;
            }

            .logout-text {
                margin:0;
                color:var(--muted);
            }

            .logout-actions {
                display:flex;
                justify-content:flex-end;
                gap:10px;
                margin-top:24px;
                flex-wrap:wrap;
            }

            .logout-actions .btn {
                min-height:42px;
                padding:9px 16px;
            }

            @media (max-width: 991.98px) {
                .profile-grid {
                    grid-template-columns:1fr;
                }

                .page-hero {
                    align-items:flex-start;
                    flex-direction:column;
                }
            }

            @media (max-width: 575.98px) {
                .profile-nav-inner {
                    align-items:flex-start;
                    flex-direction:column;
                    padding:14px 0;
                }

                .nav-actions,
                .nav-action,
                .form-actions .btn,
                .logout-actions .btn {
                    width:100%;
                }

                .form-heading {
                    flex-direction:column;
                }

                .profile-form-panel {
                    padding:22px;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="profile-shell">
            <section class="page-hero">
                <div>
                    <div class="page-kicker">Account Settings</div>
                    <h1 class="page-title">My Profile</h1>
                    <p class="page-subtitle">
                        Keep your account details up to date so checkout, delivery, and order updates stay smooth.
                    </p>
                </div>
                <span class="status-pill">
                    <i class="fa-solid fa-circle-check"></i>
                    Customer Account
                </span>
            </section>

            <c:if test="${param.updated == '1'}">
                <div class="alert alert-success mb-4">
                    <i class="fa-solid fa-circle-check"></i>
                    Profile updated successfully.
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger mb-4">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <section class="profile-grid">
                <aside class="profile-summary">
                    <div class="summary-cover"></div>
                    <div class="summary-body">
                        <div class="avatar-preview">
                            <c:choose>
                                <c:when test="${not empty profile.avatarUrl}">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(profile.avatarUrl, 'http://')
                                                        or fn:startsWith(profile.avatarUrl, 'https://')}">
                                            <c:set var="avatarSrc" value="${profile.avatarUrl}"/>
                                        </c:when>
                                        <c:when test="${fn:startsWith(profile.avatarUrl, '/')}">
                                            <c:set var="avatarSrc" value="${pageContext.request.contextPath}${profile.avatarUrl}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="avatarSrc" value="${pageContext.request.contextPath}/${profile.avatarUrl}"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <img id="avatarImage"
                                         src="${fn:escapeXml(avatarSrc)}"
                                         alt="Customer avatar"
                                         onerror="this.style.display='none';document.getElementById('avatarFallback').style.display='';">
                                    <i id="avatarFallback"
                                       class="fa-solid fa-user"
                                       style="display:none;"></i>
                                </c:when>
                                <c:otherwise>
                                    <img id="avatarImage"
                                         src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
                                         alt="Customer avatar"
                                         style="display:none;">
                                    <i id="avatarFallback" class="fa-solid fa-user"></i>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <h2 class="profile-name">
                            <c:out value="${profile.fullName}"/>
                        </h2>
                        <div class="profile-handle">
                            @<c:out value="${profile.username}"/>
                        </div>

                        <div class="contact-list">
                            <div class="contact-row">
                                <span class="contact-icon"><i class="fa-solid fa-envelope"></i></span>
                                <span><c:out value="${profile.email}"/></span>
                            </div>
                            <div class="contact-row">
                                <span class="contact-icon"><i class="fa-solid fa-phone"></i></span>
                                <span>
                                    <c:choose>
                                        <c:when test="${not empty profile.phone}">
                                            <c:out value="${profile.phone}"/>
                                        </c:when>
                                        <c:otherwise>Phone not added</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="contact-row">
                                <span class="contact-icon"><i class="fa-solid fa-user-tag"></i></span>
                                <span><c:out value="${profile.roleName}"/></span>
                            </div>
                        </div>

                        <div class="summary-divider"></div>
                        <p class="summary-note">
                            Your profile information is used for order contact and account recovery.
                            Review it before placing new orders.
                        </p>
                    </div>
                </aside>

                <section class="profile-form-panel">
                    <div class="form-heading">
                        <div>
                            <h2>Profile Details</h2>
                            <p id="profileHint">View your personal information and avatar.</p>
                        </div>
                        <div class="form-heading-actions">
                            <span class="section-chip">
                                <i class="fa-solid fa-shield-halved"></i>
                                Private
                            </span>
                            <button type="button"
                                    class="btn btn-edit-profile ${editMode ? 'd-none' : ''}"
                                    id="editProfileBtn">
                                <i class="fa-solid fa-pen"></i>
                                Edit profile
                            </button>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/customer/profile"
                          method="post"
                          enctype="multipart/form-data"
                          id="profileForm"
                          data-edit-mode="${editMode}"
                          autocomplete="off">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Username</label>
                                <div class="field-control">
                                    <i class="fa-regular fa-user field-icon"></i>
                                    <input type="text"
                                           class="form-control readonly-control"
                                           value="${fn:escapeXml(profile.username)}"
                                           readonly>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Role</label>
                                <div class="field-control">
                                    <i class="fa-solid fa-user-tag field-icon"></i>
                                    <input type="text"
                                           class="form-control readonly-control"
                                           value="${fn:escapeXml(profile.roleName)}"
                                           readonly>
                                </div>
                            </div>
                            <div class="col-12">
                                <label class="form-label" for="fullName">Full name</label>
                                <div class="field-control">
                                    <i class="fa-regular fa-id-card field-icon"></i>
                                    <input type="text"
                                            id="fullName"
                                            name="fullName"
                                           class="form-control profile-editable readonly-control"
                                           maxlength="255"
                                           value="${fn:escapeXml(profile.fullName)}"
                                           readonly
                                           required>
                                </div>
                            </div>
                            <div class="col-md-7">
                                <label class="form-label" for="email">Email</label>
                                <div class="field-control">
                                    <i class="fa-regular fa-envelope field-icon"></i>
                                    <input type="email"
                                            id="email"
                                            name="email"
                                           class="form-control profile-editable readonly-control"
                                           maxlength="100"
                                           value="${fn:escapeXml(profile.email)}"
                                           readonly
                                           required>
                                </div>
                            </div>
                            <div class="col-md-5">
                                <label class="form-label" for="phone">Phone</label>
                                <div class="field-control">
                                    <i class="fa-solid fa-phone field-icon"></i>
                                    <input type="text"
                                            id="phone"
                                            name="phone"
                                           class="form-control profile-editable readonly-control ${not empty phoneError ? 'is-invalid' : ''}"
                                           maxlength="10"
                                           pattern="^0[1-9][0-9]{8}$"
                                           title="Phone must be 10 digits starting with single 0, for example 0123456789."
                                           placeholder="0123456789"
                                           readonly
                                           value="${fn:escapeXml(profile.phone)}">
                                </div>
                                <c:if test="${not empty phoneError}">
                                    <div class="invalid-feedback d-block">
                                        <c:out value="${phoneError}"/>
                                    </div>
                                </c:if>
                            </div>
                            <div class="col-12">
                                <label class="form-label" for="avatarFile">Avatar image</label>
                                <div class="field-control">
                                    <i class="fa-regular fa-image field-icon"></i>
                                    <input type="file"
                                            id="avatarFile"
                                            name="avatarFile"
                                           class="form-control profile-editable"
                                           disabled
                                           accept="image/jpeg,image/png,image/gif,image/webp">
                                </div>
                                <div class="form-text">Select Edit profile to upload a JPG, PNG, GIF, or WEBP image up to 5MB.</div>
                            </div>
                            <div class="col-12 form-actions ${editMode ? '' : 'd-none'}" id="profileFormActions">
                                <button type="button" class="btn btn-outline-secondary px-4" id="cancelEditBtn">
                                    Cancel
                                </button>
                                <button type="submit" class="btn btn-primary btn-save px-4">
                                    <i class="fa-solid fa-floppy-disk"></i>
                                    Save changes
                                </button>
                            </div>
                        </div>
                    </form>
                </section>
            </section>
        </main>

        <div class="logout-dialog" id="logoutDialog" hidden>
            <div class="logout-panel" role="dialog" aria-modal="true" aria-labelledby="logoutDialogTitle">
                <div class="d-flex align-items-start gap-3">
                    <div class="logout-icon">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </div>
                    <div class="flex-grow-1">
                        <h2 class="logout-title" id="logoutDialogTitle">Sign out?</h2>
                        <p class="logout-text">You will leave your customer account and return to the store homepage.</p>
                    </div>
                    <button type="button" class="btn-close" id="closeLogoutDialog" aria-label="Close"></button>
                </div>
                <div class="logout-actions">
                    <button type="button" class="btn btn-outline-secondary" id="cancelLogoutDialog">Cancel</button>
                    <a href="${pageContext.request.contextPath}/customer/logout" class="btn btn-danger">Sign out</a>
                </div>
            </div>
        </div>

        <script>
            (function() {
                var openLogout = document.getElementById('openLogoutDialog');
                var logoutDialog = document.getElementById('logoutDialog');
                var closeLogout = document.getElementById('closeLogoutDialog');
                var cancelLogout = document.getElementById('cancelLogoutDialog');

                function showLogoutDialog(event) {
                    if (event) {
                        event.preventDefault();
                    }
                    logoutDialog.hidden = false;
                    logoutDialog.classList.add('is-open');
                    document.body.classList.add('profile-modal-open');
                    if (closeLogout) {
                        closeLogout.focus();
                    }
                }

                function hideLogoutDialog() {
                    logoutDialog.classList.remove('is-open');
                    document.body.classList.remove('profile-modal-open');
                    logoutDialog.hidden = true;
                }

                if (openLogout && logoutDialog && closeLogout && cancelLogout) {
                    openLogout.addEventListener('click', showLogoutDialog);
                    closeLogout.addEventListener('click', hideLogoutDialog);
                    cancelLogout.addEventListener('click', hideLogoutDialog);
                    logoutDialog.addEventListener('click', function(event) {
                        if (event.target === logoutDialog) {
                            hideLogoutDialog();
                        }
                    });
                    document.addEventListener('keydown', function(event) {
                        if (event.key === 'Escape' && logoutDialog.classList.contains('is-open')) {
                            hideLogoutDialog();
                        }
                    });
                }

                var profileForm = document.getElementById('profileForm');
                var editProfileBtn = document.getElementById('editProfileBtn');
                var cancelEditBtn = document.getElementById('cancelEditBtn');
                var profileFormActions = document.getElementById('profileFormActions');
                var profileHint = document.getElementById('profileHint');
                var profileEditableFields = profileForm
                        ? profileForm.querySelectorAll('.profile-editable')
                        : [];
                var isEditing = false;

                function setEditMode(enabled, focusFirstField) {
                    isEditing = enabled;

                    for (var i = 0; i < profileEditableFields.length; i++) {
                        var field = profileEditableFields[i];
                        if (field.type === 'file') {
                            field.disabled = !enabled;
                        } else {
                            field.readOnly = !enabled;
                        }
                        field.classList.toggle('readonly-control', !enabled);
                    }

                    if (editProfileBtn) {
                        editProfileBtn.classList.toggle('d-none', enabled);
                    }
                    if (profileFormActions) {
                        profileFormActions.classList.toggle('d-none', !enabled);
                    }
                    if (profileHint) {
                        profileHint.textContent = enabled
                                ? 'Make your changes, then save them to update your account.'
                                : 'View your personal information and avatar.';
                    }
                    if (focusFirstField) {
                        var fullNameInput = document.getElementById('fullName');
                        if (fullNameInput) {
                            fullNameInput.focus();
                        }
                    }
                }

                if (profileForm) {
                    setEditMode(profileForm.dataset.editMode === 'true');
                    profileForm.addEventListener('submit', function(event) {
                        if (!isEditing) {
                            event.preventDefault();
                        }
                    });
                }

                if (editProfileBtn) {
                    editProfileBtn.addEventListener('click', function() {
                        setEditMode(true, true);
                    });
                }

                if (cancelEditBtn) {
                    cancelEditBtn.addEventListener('click', function() {
                        window.location.reload();
                    });
                }

                var avatarInput = document.getElementById('avatarFile');
                var avatarImage = document.getElementById('avatarImage');
                var avatarFallback = document.getElementById('avatarFallback');
                var previewUrl = null;

                if (avatarInput && avatarImage && avatarFallback) {
                    avatarInput.addEventListener('change', function() {
                        var file = avatarInput.files && avatarInput.files.length > 0
                                ? avatarInput.files[0]
                                : null;

                        if (previewUrl) {
                            URL.revokeObjectURL(previewUrl);
                            previewUrl = null;
                        }

                        if (!file) {
                            avatarImage.style.display = 'none';
                            avatarFallback.style.display = '';
                            return;
                        }

                        previewUrl = URL.createObjectURL(file);
                        avatarImage.src = previewUrl;
                        avatarImage.style.display = '';
                        avatarFallback.style.display = 'none';
                    });

                    avatarImage.addEventListener('error', function() {
                        avatarImage.style.display = 'none';
                        avatarFallback.style.display = '';
                    });
                }
            })();
        </script>

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
