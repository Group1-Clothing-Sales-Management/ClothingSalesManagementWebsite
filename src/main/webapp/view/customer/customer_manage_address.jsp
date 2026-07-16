<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Addresses | Clothing Sale</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --address-ink:#25211e;
                --address-muted:#6f665e;
                --address-line:#e9e0d7;
                --address-primary:#c65b3d;
                --address-primary-dark:#a9462d;
                --address-accent:#e9a957;
                --address-bg:#faf7f2;
                --address-surface:#fff;
            }

            * {
                box-sizing:border-box;
            }

            body {
                min-height:100vh;
                margin:0;
                color:var(--address-ink);
                background:
                    radial-gradient(circle at 8% 10%, rgba(230,157,79,.16), transparent 27%),
                    radial-gradient(circle at 92% 20%, rgba(198,91,61,.08), transparent 25%),
                    linear-gradient(180deg, #fffdf9 0%, var(--address-bg) 55%, #f5eee7 100%);
                font-family:"Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            }

            .address-shell {
                width:100%;
                max-width:1120px;
                margin:0 auto;
                padding:40px 18px 68px;
            }

            .address-hero {
                display:flex;
                align-items:flex-end;
                justify-content:space-between;
                gap:24px;
                margin-bottom:28px;
            }

            .address-kicker {
                display:inline-flex;
                align-items:center;
                gap:8px;
                margin-bottom:12px;
                padding:7px 11px;
                border:1px solid #f0d7c4;
                border-radius:999px;
                color:var(--address-primary-dark);
                background:#fff3dc;
                font-size:.78rem;
                font-weight:800;
                letter-spacing:.04em;
                text-transform:uppercase;
            }

            .address-hero h1 {
                margin:0;
                font-size:clamp(2rem, 4vw, 2.8rem);
                font-weight:900;
                letter-spacing:-.04em;
            }

            .address-hero p {
                max-width:650px;
                margin:10px 0 0;
                color:var(--address-muted);
                line-height:1.6;
            }

            .hero-actions {
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:10px;
                flex-wrap:wrap;
            }

            .btn {
                min-height:44px;
                border-radius:9px;
                font-weight:800;
            }

            .btn-add-address {
                display:inline-flex;
                align-items:center;
                gap:8px;
                border:0;
                padding:0 18px;
                color:#fff;
                background:linear-gradient(135deg, var(--address-primary), var(--address-accent));
                box-shadow:0 14px 24px rgba(198,91,61,.22);
            }

            .btn-add-address:hover,
            .btn-add-address:focus-visible {
                color:#fff;
                background:linear-gradient(135deg, var(--address-primary-dark), var(--address-primary));
            }

            .btn-checkout {
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:0 14px;
                border:1px solid var(--address-line);
                color:var(--address-ink);
                background:#fff;
            }

            .btn-checkout:hover,
            .btn-checkout:focus-visible {
                border-color:#d9b6a4;
                color:var(--address-primary);
                background:#fff;
            }

            .address-overview {
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:18px;
                margin-bottom:14px;
                padding:18px 20px;
                border:1px solid rgba(233,224,215,.95);
                border-radius:14px;
                background:rgba(255,255,255,.7);
            }

            .overview-title {
                display:flex;
                align-items:center;
                gap:12px;
                font-weight:900;
            }

            .overview-icon {
                width:38px;
                height:38px;
                display:grid;
                place-items:center;
                border-radius:10px;
                color:var(--address-primary);
                background:#fff3dc;
            }

            .overview-note {
                margin:3px 0 0;
                color:var(--address-muted);
                font-size:.88rem;
            }

            .address-count {
                flex:0 0 auto;
                color:var(--address-muted);
                font-size:.88rem;
                font-weight:700;
            }

            .address-grid {
                display:grid;
                grid-template-columns:repeat(2, minmax(0, 1fr));
                gap:16px;
            }

            .address-card {
                position:relative;
                display:flex;
                flex-direction:column;
                min-height:260px;
                overflow:hidden;
                padding:22px;
                border:1px solid var(--address-line);
                border-radius:16px;
                background:rgba(255,255,255,.96);
                box-shadow:0 16px 40px rgba(74,54,39,.07);
                transition:transform .2s ease, box-shadow .2s ease, border-color .2s ease;
            }

            .address-card::before {
                position:absolute;
                inset:0 auto 0 0;
                width:4px;
                content:"";
                background:transparent;
            }

            .address-card.is-default {
                border-color:#e3b39d;
                box-shadow:0 18px 42px rgba(198,91,61,.12);
            }

            .address-card.is-default::before {
                background:linear-gradient(180deg, var(--address-primary), var(--address-accent));
            }

            .address-card:hover {
                transform:translateY(-3px);
                border-color:#d9b6a4;
                box-shadow:0 22px 48px rgba(74,54,39,.12);
            }

            .address-card-header {
                display:flex;
                align-items:flex-start;
                justify-content:space-between;
                gap:12px;
            }

            .recipient {
                display:flex;
                align-items:center;
                gap:10px;
                min-width:0;
                font-size:1.08rem;
                font-weight:900;
            }

            .recipient-avatar {
                width:36px;
                height:36px;
                display:grid;
                place-items:center;
                flex:0 0 auto;
                border-radius:10px;
                color:#fff;
                background:linear-gradient(135deg, var(--address-ink), var(--address-primary));
                font-size:.9rem;
            }

            .recipient-name {
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
            }

            .default-badge {
                display:inline-flex;
                align-items:center;
                gap:6px;
                flex:0 0 auto;
                padding:6px 9px;
                border-radius:999px;
                color:var(--address-primary-dark);
                background:#fff3dc;
                font-size:.72rem;
                font-weight:900;
                white-space:nowrap;
            }

            .address-details {
                display:grid;
                gap:11px;
                margin:20px 0 22px;
            }

            .address-line {
                display:flex;
                align-items:flex-start;
                gap:11px;
                color:#554b44;
                font-size:.92rem;
                line-height:1.45;
            }

            .address-line i {
                width:17px;
                margin-top:3px;
                color:var(--address-primary);
                text-align:center;
                flex:0 0 auto;
            }

            .address-line.muted {
                color:var(--address-muted);
            }

            .address-place {
                margin-top:2px;
                padding:11px 13px;
                border-radius:10px;
                color:var(--address-muted);
                background:#fcf8f4;
                font-size:.82rem;
            }

            .address-place strong {
                color:var(--address-ink);
            }

            .address-actions {
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:12px;
                margin-top:auto;
                padding-top:16px;
                border-top:1px solid #f0e8e1;
            }

            .address-action-group {
                display:flex;
                align-items:center;
                gap:8px;
                flex-wrap:wrap;
            }

            .address-actions .btn {
                display:inline-flex;
                align-items:center;
                justify-content:center;
                min-height:36px;
                padding:0 11px;
                font-size:.82rem;
            }

            .btn-edit {
                min-width:78px;
                border:1px solid #d9b6a4;
                color:var(--address-primary);
                background:#fff;
            }

            .btn-edit:hover,
            .btn-edit:focus-visible {
                color:#fff;
                background:var(--address-primary);
            }

            .btn-delete {
                min-width:78px;
                border:1px solid #f0d5ce;
                color:#aa5748;
                background:#fff;
            }

            .btn-delete:hover,
            .btn-delete:focus-visible {
                color:#8d3527;
                background:#fff1ed;
            }

            .btn-default {
                min-width:126px;
                border:1px solid #e8c68d;
                color:#9c6417;
                background:#fffaf0;
            }

            .btn-default:hover,
            .btn-default:focus-visible {
                border-color:var(--address-accent);
                color:#7e4d0c;
                background:#fff3dc;
            }

            .empty-state {
                padding:54px 24px;
                border:1px dashed #d9b6a4;
                border-radius:16px;
                background:rgba(255,255,255,.65);
                text-align:center;
            }

            .empty-icon {
                width:58px;
                height:58px;
                display:grid;
                place-items:center;
                margin:0 auto 15px;
                border-radius:16px;
                color:var(--address-primary);
                background:#fff3dc;
                font-size:1.35rem;
            }

            .empty-state h2 {
                margin:0 0 7px;
                font-size:1.18rem;
                font-weight:900;
            }

            .empty-state p {
                max-width:440px;
                margin:0 auto 20px;
                color:var(--address-muted);
            }

            .address-modal .modal-content {
                overflow:hidden;
                border:1px solid var(--address-line);
                border-radius:18px;
                box-shadow:0 26px 80px rgba(37,33,30,.22);
            }

            .address-modal .modal-header {
                padding:22px 24px 16px;
                border-bottom:1px solid #f0e8e1;
            }

            .modal-heading {
                display:flex;
                align-items:center;
                gap:11px;
            }

            .modal-heading-icon {
                width:38px;
                height:38px;
                display:grid;
                place-items:center;
                border-radius:10px;
                color:var(--address-primary);
                background:#fff3dc;
            }

            .address-modal .modal-title {
                margin:0;
                font-size:1.2rem;
                font-weight:900;
            }

            .address-modal .modal-body {
                padding:22px 24px 8px;
            }

            .address-modal .modal-footer {
                padding:16px 24px 22px;
                border-top:0;
            }

            .address-modal .form-label {
                margin-bottom:7px;
                color:#504740;
                font-size:.86rem;
                font-weight:800;
            }

            .address-field {
                position:relative;
            }

            .address-field > i {
                position:absolute;
                top:50%;
                left:15px;
                z-index:1;
                transform:translateY(-50%);
                color:#a6968a;
                pointer-events:none;
            }

            .address-field .form-control {
                min-height:48px;
                padding-left:42px;
                border:1px solid #d9cfc6;
                border-radius:10px;
                color:var(--address-ink);
            }

            .address-field textarea.form-control {
                min-height:92px;
                padding-top:13px;
                resize:vertical;
            }

            .address-field textarea + i {
                top:19px;
                transform:none;
            }

            .address-field .form-control:focus {
                border-color:var(--address-primary);
                box-shadow:0 0 0 .22rem rgba(198,91,61,.14);
            }

            .default-check {
                display:flex;
                align-items:flex-start;
                gap:9px;
                margin-top:3px;
                padding:12px 13px;
                border-radius:10px;
                background:#fcf8f4;
            }

            .default-check .form-check-input {
                margin-top:3px;
                border-color:#cbb9aa;
            }

            .default-check .form-check-input:checked {
                border-color:var(--address-primary);
                background-color:var(--address-primary);
            }

            .default-check label {
                color:#554b44;
                font-size:.88rem;
                font-weight:700;
            }

            .modal-cancel {
                border:1px solid var(--address-line);
                color:var(--address-muted);
                background:#fff;
            }

            .modal-save {
                border:0;
                padding:0 18px;
                color:#fff;
                background:var(--address-primary);
            }

            .modal-save:hover,
            .modal-save:focus-visible {
                color:#fff;
                background:var(--address-primary-dark);
            }

            @media (max-width: 760px) {
                .address-shell {
                    padding-top:30px;
                }
                .address-hero {
                    align-items:flex-start;
                    flex-direction:column;
                }
                .hero-actions {
                    justify-content:flex-start;
                }
                .address-grid {
                    grid-template-columns:1fr;
                }
            }

            @media (max-width: 480px) {
                .address-shell {
                    padding-right:14px;
                    padding-left:14px;
                }
                .address-overview {
                    align-items:flex-start;
                    flex-direction:column;
                }
                .address-card {
                    padding:19px;
                }
                .address-card-header {
                    flex-direction:column;
                }
                .address-actions {
                    align-items:flex-start;
                    flex-direction:column;
                }
                .address-action-group {
                    width:100%;
                }
                .address-modal .modal-header,
                .address-modal .modal-body,
                .address-modal .modal-footer {
                    padding-right:18px;
                    padding-left:18px;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="address-shell">
            <section class="address-hero">
                <div>
                    <div class="address-kicker">
                        <i class="fa-solid fa-location-dot"></i>
                        Account settings
                    </div>
                    <h1>My addresses</h1>
                    <p>Save your delivery details once and choose the right address faster whenever you shop.</p>
                </div>

                <div class="hero-actions">
                    <c:if test="${from eq 'checkout'}">
                        <a class="btn btn-checkout" href="${pageContext.request.contextPath}/customer/checkout">
                            <i class="fa-solid fa-arrow-left"></i>
                            Back to checkout
                        </a>
                    </c:if>
                    <button class="btn btn-add-address" type="button" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                        <i class="fa-solid fa-plus"></i>
                        Add address
                    </button>
                </div>
            </section>

            <section class="address-overview" aria-label="Address overview">
                <div class="overview-title">
                    <span class="overview-icon"><i class="fa-solid fa-bookmark"></i></span>
                    <div>
                        <div>Saved addresses</div>
                        <p class="overview-note">Your default address will be preselected at checkout.</p>
                    </div>
                </div>
                <span class="address-count">
                    <c:choose>
                        <c:when test="${not empty addresses}">${fn:length(addresses)} address<c:if test="${fn:length(addresses) != 1}">es</c:if></c:when>
                        <c:otherwise>No addresses yet</c:otherwise>
                    </c:choose>
                </span>
            </section>

            <c:choose>
                <c:when test="${not empty addresses}">
                    <section class="address-grid" aria-label="Saved delivery addresses">
                        <c:forEach items="${addresses}" var="a">
                            <article class="address-card ${a.isDefault() ? 'is-default' : ''}">
                                <div class="address-card-header">
                                    <div class="recipient">
                                        <span class="recipient-avatar"><i class="fa-solid fa-user"></i></span>
                                        <span class="recipient-name"><c:out value="${a.recipientName}"/></span>
                                    </div>
                                    <c:if test="${a.isDefault()}">
                                        <span class="default-badge"><i class="fa-solid fa-check"></i> Default</span>
                                    </c:if>
                                </div>

                                <div class="address-details">
                                    <div class="address-line">
                                        <i class="fa-solid fa-phone"></i>
                                        <span><c:out value="${a.recipientPhone}"/></span>
                                    </div>
                                    <div class="address-line">
                                        <i class="fa-solid fa-house"></i>
                                        <span><c:out value="${a.addressDetail}" default="Address detail not added"/></span>
                                    </div>
                                    <div class="address-place">
                                        <i class="fa-solid fa-map-pin me-1"></i>
                                        <strong>
                                            <c:out value="${a.addressDetail}"/>,
                                            <c:out value="${a.wardName}"/>,
                                            <c:out value="${a.districtName}"/>,
                                            <c:out value="${a.provinceName}"/>
                                        </strong>
                                    </div>
                                </div>

                                <div class="address-actions">
                                    <div class="address-action-group">
                                        <button class="btn btn-edit" type="button" data-bs-toggle="modal" data-bs-target="#editModal${a.id}">
                                            <i class="fa-solid fa-pen me-1"></i> Edit
                                        </button>
                                        <a class="btn btn-delete"
                                           href="${pageContext.request.contextPath}/customer/address?action=delete&amp;id=${a.id}&amp;from=${from}"
                                           onclick="return confirm('Delete this address?')">
                                            <i class="fa-regular fa-trash-can me-1"></i> Delete
                                        </a>
                                    </div>
                                    <c:if test="${not a.isDefault()}">
                                        <a class="btn btn-default"
                                           href="${pageContext.request.contextPath}/customer/address?action=setDefault&amp;id=${a.id}&amp;from=${from}">
                                            <i class="fa-regular fa-star me-1"></i> Make default
                                        </a>
                                    </c:if>
                                </div>
                            </article>
                        </c:forEach>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="empty-state">
                        <div class="empty-icon"><i class="fa-solid fa-location-dot"></i></div>
                        <h2>No delivery address yet</h2>
                        <p>Add an address to make checkout quicker and keep your delivery information in one place.</p>
                        <button class="btn btn-add-address" type="button" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                            <i class="fa-solid fa-plus"></i>
                            Add your first address
                        </button>
                    </section>
                </c:otherwise>
            </c:choose>
        </main>

        <c:forEach items="${addresses}" var="a">
            <div class="modal fade address-modal" id="editModal${a.id}" tabindex="-1" aria-labelledby="editModalTitle${a.id}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <form method="post" action="${pageContext.request.contextPath}/customer/address?action=update">
                            <input type="hidden" name="from" value="${from}">
                            <div class="modal-header">
                                <div class="modal-heading">
                                    <span class="modal-heading-icon"><i class="fa-solid fa-pen"></i></span>
                                    <h2 class="modal-title" id="editModalTitle${a.id}">Edit address</h2>
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <input type="hidden" name="id" value="${a.id}">
                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <label class="form-label" for="editName${a.id}">Recipient name</label>
                                        <div class="address-field">
                                            <i class="fa-regular fa-user"></i>
                                            <input id="editName${a.id}" class="form-control" type="text" name="recipientName" value="${fn:escapeXml(a.recipientName)}" required>
                                        </div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="form-label" for="editPhone${a.id}">Phone number</label>
                                        <div class="address-field">
                                            <i class="fa-solid fa-phone"></i>
                                            <input id="editPhone${a.id}" class="form-control" type="tel" name="recipientPhone" value="${fn:escapeXml(a.recipientPhone)}" required>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label" for="editDetail${a.id}">Address detail</label>
                                        <div class="address-field">
                                            <i class="fa-solid fa-house"></i>
                                            <textarea id="editDetail${a.id}" class="form-control" name="addressDetail" rows="3" placeholder="House number, street, building..."><c:out value="${a.addressDetail}"/></textarea>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">
                                            Province
                                        </label>
                                        <select id="editProvince${a.id}" class="form-select"> </select>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">
                                            District
                                        </label>
                                        <select id="editDistrict${a.id}" class="form-select"> </select>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">
                                            Ward
                                        </label>
                                        <select id="editWard${a.id}" name="wardId" class="form-select" required> </select>
                                    </div>
                                    <div class="col-12">
                                        <div class="default-check">
                                            <input class="form-check-input" id="editDefault${a.id}" type="checkbox" name="isDefault" ${a.isDefault() ? 'checked' : ''}>
                                            <label for="editDefault${a.id}">Use this as my default delivery address</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn modal-cancel" type="button" data-bs-dismiss="modal">Cancel</button>
                                <button class="btn modal-save" type="submit"><i class="fa-solid fa-check me-1"></i> Save changes</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </c:forEach>

        <div class="modal fade address-modal" id="addAddressModal" tabindex="-1" aria-labelledby="addAddressModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <form method="post" action="${pageContext.request.contextPath}/customer/address?action=insert">
                        <input type="hidden" name="from" value="${from}">
                        <div class="modal-header">
                            <div class="modal-heading">
                                <span class="modal-heading-icon"><i class="fa-solid fa-house"></i></span>
                                <h2 class="modal-title" id="addAddressModalTitle">Add new address</h2>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-sm-6">
                                    <label class="form-label" for="addName">Recipient name</label>
                                    <div class="address-field">
                                        <i class="fa-regular fa-user"></i>
                                        <input id="addName" class="form-control" type="text" name="recipientName" autocomplete="name" required>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <label class="form-label" for="addPhone">Phone number</label>
                                    <div class="address-field">
                                        <i class="fa-solid fa-phone"></i>
                                        <input id="addPhone" class="form-control" type="tel" name="recipientPhone" autocomplete="tel" required>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <label class="form-label" for="addDetail">Address detail</label>
                                    <div class="address-field">
                                        <i class="fa-solid fa-house"></i>
                                        <textarea id="addDetail" class="form-control" name="addressDetail" rows="3" placeholder="House number, street, building..."></textarea>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">
                                        Province
                                    </label>
                                    <select id="addProvince" class="form-select">
                                        <option value=""> Select Province </option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">
                                        District
                                    </label>
                                    <select id="addDistrict" class="form-select"> 
                                        <option value="">  Select District  </option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">
                                        Ward
                                    </label>
                                    <select id="addWard" name="wardId" class="form-select" required>
                                        <option value=""> Select Ward </option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <div class="default-check">
                                        <input class="form-check-input" id="addDefault" type="checkbox" name="isDefault">
                                        <label for="addDefault">Use this as my default delivery address</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button class="btn modal-cancel" type="button" data-bs-dismiss="modal">Cancel</button>
                            <button class="btn modal-save" type="submit"><i class="fa-solid fa-check me-1"></i> Save address</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>

                                               const baseUrl = "${pageContext.request.contextPath}/customer/address";
                                               async function loadProvinces(selectId) {

                                                   const select = document.getElementById(selectId);
                                                   if (!select)
                                                       return;
                                                   const res = await fetch(baseUrl + "?action=provinces");
                                                   const data = await
                                                           res.json();
                                                   select.innerHTML = "";
                                                   const first = document.createElement("option");
                                                   first.value = "";
                                                   first.textContent = "Select Province";
                                                   select.appendChild(first);
                                                   data.forEach(p => {

                                                       const option = document.createElement("option");
                                                       option.value = p.id;
                                                       option.textContent = p.name;
                                                       select.appendChild(option);
                                                   });
                                               }

                                               async function loadDistricts(provinceId, districtSelectId) {

                                                   const district = document.getElementById(districtSelectId);

                                                   if (!district)
                                                       return;

                                                   district.innerHTML = "";

                                                   const first = document.createElement("option");
                                                   first.value = "";
                                                   first.textContent = "Select District";
                                                   district.appendChild(first);

                                                   if (!provinceId)
                                                       return;

                                                   const res = await fetch(
                                                           baseUrl + "?action=districts&provinceId=" + encodeURIComponent(provinceId)
                                                           );

                                                   const data = await res.json();

                                                   console.log(data);

                                                   data.forEach(d => {

                                                       const option = document.createElement("option");
                                                       option.value = d.id;
                                                       option.textContent = d.name;

                                                       district.appendChild(option);

                                                   });
                                               }

                                               async function loadWards(districtId, wardSelectId) {

                                                   const ward = document.getElementById(wardSelectId);

                                                   if (!ward)
                                                       return;

                                                   ward.innerHTML = "";

                                                   const first = document.createElement("option");
                                                   first.value = "";
                                                   first.textContent = "Select Ward";
                                                   ward.appendChild(first);

                                                   if (!districtId)
                                                       return;

                                                   const res = await fetch(
                                                           baseUrl + "?action=wards&districtId=" + encodeURIComponent(districtId)
                                                           );

                                                   const data = await res.json();

                                                   console.log(data);

                                                   data.forEach(w => {

                                                       const option = document.createElement("option");
                                                       option.value = w.id;
                                                       option.textContent = w.name;

                                                       ward.appendChild(option);

                                                   });
                                               }

                                               document.addEventListener("DOMContentLoaded", function () {

                                                   //================ ADD ==================

                                                   loadProvinces("addProvince");
                                                   document.getElementById("addProvince")
                                                           .addEventListener("change", function () {

                                                               loadDistricts(
                                                                       this.value,
                                                                       "addDistrict");
                                                               document.getElementById("addWard").innerHTML =
                                                                       "<option value=''>Select Ward</option>";
                                                           });
                                                   document.getElementById("addDistrict")
                                                           .addEventListener("change", function () {

                                                               loadWards(
                                                                       this.value,
                                                                       "addWard");
                                                           });
                                               });
        </script>
        <c:forEach items="${addresses}" var="a">
            <script>

                (async function () {

                    await loadProvinces("editProvince${a.id}");
                    document.getElementById("editProvince${a.id}").value =
                            "${a.provinceId}";
                    await loadDistricts(
                            "${a.provinceId}",
                            "editDistrict${a.id}");
                    document.getElementById("editDistrict${a.id}").value =
                            "${a.districtId}";
                    await loadWards(
                            "${a.districtId}",
                            "editWard${a.id}");
                    document.getElementById("editWard${a.id}").value =
                            "${a.wardId}";
                })();
                document.getElementById("editProvince${a.id}")
                        .addEventListener("change", function () {

                            loadDistricts(
                                    this.value,
                                    "editDistrict${a.id}");
                            document.getElementById("editWard${a.id}").innerHTML =
                                    "<option value=''>Select Ward</option>";
                        });
                document.getElementById("editDistrict${a.id}")
                        .addEventListener("change", function () {

                            loadWards(
                                    this.value,
                                    "editWard${a.id}");
                        });

            </script>
        </c:forEach>
    </body>
</html>
