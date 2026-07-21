<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Returns &amp; Refunds</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        :root {
            --return-blue: #5f84d6;
            --return-blue-dark: #365b9f;
            --return-blue-soft: #eef4ff;
            --return-ink: #1f2937;
            --return-muted: #718096;
            --return-line: #e5eaf3;
            --return-bg: #f6f8fc;
        }

        body.returns-shell {
            background: radial-gradient(circle at 8% 0%, #edf4ff 0, transparent 31rem), var(--return-bg);
            color: var(--return-ink);
        }

        .returns-page {
            width: min(1180px, calc(100% - 32px));
            margin: 34px auto 72px;
        }

        .returns-hero {
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 28px;
            min-height: 190px;
            padding: 30px 36px;
            border-radius: 24px;
            color: #fff;
            background: linear-gradient(120deg, #365b9f 0%, #6f95df 58%, #9bb9ef 100%);
            box-shadow: 0 18px 38px rgba(72, 111, 181, .2);
        }

        .returns-hero::after {
            position: absolute;
            right: -72px;
            bottom: -115px;
            width: 330px;
            height: 330px;
            border: 1px solid rgba(255,255,255,.25);
            border-radius: 50%;
            box-shadow: 0 0 0 28px rgba(255,255,255,.06), 0 0 0 58px rgba(255,255,255,.045);
            content: "";
        }

        .returns-hero__copy,
        .returns-hero__visual { position: relative; z-index: 1; }
        .returns-hero__copy { max-width: 620px; }
        .returns-eyebrow,
        .section-eyebrow {
            margin: 0 0 9px;
            color: #86a8e8;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: .14em;
            text-transform: uppercase;
        }
        .returns-hero .returns-eyebrow { color: #dbe8ff; }
        .returns-hero h1 { margin: 0 0 9px; color: #fff; font-size: clamp(1.7rem, 3vw, 2.45rem); font-weight: 800; }
        .returns-hero p { max-width: 560px; margin: 0; color: #edf4ff; font-size: 15px; }
        .returns-hero__visual {
            display: grid;
            place-items: center;
            width: 118px;
            height: 118px;
            flex: 0 0 118px;
            border: 1px solid rgba(255,255,255,.25);
            border-radius: 32px;
            background: rgba(255,255,255,.15);
            font-size: 52px;
            transform: rotate(5deg);
        }

        .returns-alert { margin: 18px 0; border: 0; border-radius: 14px; box-shadow: 0 5px 16px rgba(31,41,55,.05); }
        .returns-card {
            overflow: hidden;
            border: 1px solid rgba(215,225,245,.85);
            border-radius: 20px;
            background: #fff;
            box-shadow: 0 10px 28px rgba(44, 62, 92, .07);
        }

        .returns-form-card { margin-top: 22px; }
        .returns-card__header { padding: 27px 30px; border-bottom: 1px solid var(--return-line); }
        .returns-card__header h2 { margin: 0; font-size: 1.25rem; font-weight: 800; }
        .returns-card__header p { margin: 5px 0 0; color: var(--return-muted); }
        .returns-card__body { padding: 28px 30px; }
        .return-title-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 46px;
            height: 46px;
            margin-right: 13px;
            border-radius: 14px;
            color: var(--return-blue-dark);
            background: var(--return-blue-soft);
            font-size: 20px;
        }
        .order-ref { display: inline-flex; align-items: center; gap: 8px; margin-top: 12px; padding: 7px 11px; border-radius: 8px; color: var(--return-blue-dark); background: var(--return-blue-soft); font-size: 13px; font-weight: 700; }
        .window-badge { display: inline-flex; align-items: center; gap: 6px; padding: 7px 10px; border-radius: 999px; color: #896119; background: #fff6df; font-size: 12px; font-weight: 800; }

        .return-steps { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin: 0 0 28px; padding: 15px; border-radius: 14px; background: #f8faff; }
        .return-step { display: flex; align-items: center; gap: 9px; color: #7f8ba0; font-size: 12px; font-weight: 700; }
        .return-step__number { display: grid; place-items: center; width: 27px; height: 27px; flex: 0 0 27px; border-radius: 50%; color: var(--return-blue-dark); background: #dce8ff; }
        .return-step.is-active { color: var(--return-blue-dark); }
        .return-step.is-active .return-step__number { color: #fff; background: var(--return-blue); box-shadow: 0 5px 12px rgba(95,132,214,.28); }

        .field-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; margin-bottom: 25px; }
        .returns-form-card .form-label { margin-bottom: 7px; color: var(--return-ink); font-size: 13px; font-weight: 800; }
        .returns-form-card .form-control,
        .returns-form-card .form-select { min-height: 46px; border-color: #dbe2ef; border-radius: 10px; }
        .returns-form-card .form-control:focus,
        .returns-form-card .form-select:focus { border-color: var(--return-blue); box-shadow: 0 0 0 3px rgba(95,132,214,.15); }
        .form-section-title { display: flex; align-items: center; gap: 9px; margin: 0 0 12px; font-size: 14px; font-weight: 800; }
        .form-section-title i { color: var(--return-blue); }
        .return-products { margin-bottom: 25px; border: 1px solid var(--return-line); border-radius: 14px; overflow: hidden; }
        .return-products__head { display: grid; grid-template-columns: 48px minmax(0,1fr) 150px 105px; gap: 12px; padding: 11px 16px; color: #66738b; background: #f7f9fd; font-size: 11px; font-weight: 800; letter-spacing: .06em; text-transform: uppercase; }
        .return-product { display: grid; grid-template-columns: 48px minmax(0,1fr) 150px 105px; gap: 12px; align-items: center; padding: 14px 16px; border-top: 1px solid var(--return-line); }
        .return-product:hover { background: #fbfcff; }
        .return-product__select { display: flex; justify-content: center; }
        .return-product__select input { position: absolute; opacity: 0; }
        .return-product__select span { display: grid; place-items: center; width: 22px; height: 22px; border: 1px solid #b8c4d8; border-radius: 7px; color: transparent; cursor: pointer; transition: .2s ease; }
        .return-product__select input:checked + span { border-color: var(--return-blue); color: #fff; background: var(--return-blue); }
        .return-product__select input:focus-visible + span { outline: 3px solid rgba(95,132,214,.22); }
        .return-product__name { font-weight: 800; }
        .return-product__variant { color: var(--return-muted); font-size: 13px; }
        .return-product__quantity { width: 100%; min-height: 40px !important; padding: 7px 10px; }
        .bank-panel { margin-bottom: 24px; padding: 20px; border: 1px solid #d9e5fb; border-radius: 15px; background: linear-gradient(135deg,#f7faff,#eef4ff); }
        .bank-panel .form-control, .bank-panel .form-select { background: #fff; }
        .bank-panel__note { margin: 11px 0 0; color: #6b7a95; font-size: 12px; }
        .form-actions { display: flex; align-items: center; justify-content: space-between; gap: 15px; padding-top: 20px; border-top: 1px solid var(--return-line); }
        .form-actions .btn { min-height: 44px; border-radius: 10px; padding: 10px 17px; font-weight: 800; }
        .form-actions .btn-primary { border-color: var(--return-blue); background: var(--return-blue); }
        .form-actions .btn-primary:hover { border-color: var(--return-blue-dark); background: var(--return-blue-dark); }

        .requests-layout { display: grid; grid-template-columns: minmax(0, 1fr) 278px; gap: 22px; margin-top: 22px; }
        .requests-card__head { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 23px 26px; border-bottom: 1px solid var(--return-line); }
        .requests-card__head h2 { margin: 0; font-size: 1.12rem; font-weight: 800; }
        .request-count { padding: 5px 10px; border-radius: 999px; color: var(--return-blue-dark); background: var(--return-blue-soft); font-size: 12px; font-weight: 800; }
        .request-list { display: grid; gap: 12px; padding: 16px; }
        .request-card { padding: 18px; border: 1px solid var(--return-line); border-radius: 15px; background: #fff; transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease; }
        .request-card:hover { border-color: #c5d5f4; box-shadow: 0 8px 20px rgba(65,91,140,.08); transform: translateY(-1px); }
        .request-card__top { display: flex; align-items: flex-start; justify-content: space-between; gap: 14px; }
        .request-code { margin: 0 0 4px; font-size: 15px; font-weight: 800; }
        .request-order { color: var(--return-muted); font-size: 12px; }
        .status { display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px; border-radius: 999px; font-size: 11px; font-weight: 800; line-height: 1.2; white-space: nowrap; }
        .status::before { width: 6px; height: 6px; border-radius: 50%; background: currentColor; content: ""; }
        .status-PENDING,.status-INFO_REQUIRED { color:#9a6700; background:#fff5d9; }
        .status-APPROVED,.status-RECEIVED { color:#2e62be; background:#e9f1ff; }
        .status-REFUND_PENDING { color:#6d48b2; background:#f0eaff; }
        .status-COMPLETED { color:#17734f; background:#e4f7ee; }
        .status-REJECTED { color:#b33b46; background:#ffebed; }
        .status-CANCELLED { color:#9b5c1c; background:#fff0df; }
        .request-meta { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; margin: 17px 0; padding: 14px 0; border-top: 1px solid #eef1f6; border-bottom: 1px solid #eef1f6; }
        .request-meta__label { display: block; margin-bottom: 3px; color: #8a96a9; font-size: 10px; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; }
        .request-meta__value { color: var(--return-ink); font-size: 13px; font-weight: 700; }
        .request-meta__value.amount { color: var(--return-blue-dark); }
        .request-note { margin: 0 0 14px; color: #66738b; font-size: 13px; line-height: 1.55; }
        .request-card__bottom { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
        .request-date { color: #8994a7; font-size: 12px; }
        .request-card .btn { border-radius: 8px; font-size: 12px; font-weight: 800; }
        .request-card .btn-outline-primary { border-color: #b9caec; color: var(--return-blue-dark); }
        .request-card .btn-outline-primary:hover { border-color: var(--return-blue); background: var(--return-blue); color: #fff; }
        .supplement-form { margin-top: 14px; padding: 12px; border-radius: 10px; background: #fff9eb; }
        .supplement-form__label { display: block; margin-bottom: 7px; color: #8b681e; font-size: 12px; font-weight: 800; }
        .supplement-form .form-control { border-color: #eedcae; }
        .empty-requests { padding: 58px 24px; text-align: center; color: #8290a7; }
        .empty-requests i { display: block; margin-bottom: 12px; color: #b6c5df; font-size: 38px; }
        .returns-help { align-self: start; padding: 23px; }
        .returns-help__icon { display: grid; place-items: center; width: 42px; height: 42px; margin-bottom: 16px; border-radius: 13px; color: var(--return-blue-dark); background: var(--return-blue-soft); }
        .returns-help h2 { margin: 0 0 8px; font-size: 16px; font-weight: 800; }
        .returns-help p { margin: 0 0 17px; color: var(--return-muted); font-size: 13px; line-height: 1.6; }
        .returns-help ul { display: grid; gap: 11px; margin: 0; padding: 16px 0 0; border-top: 1px solid var(--return-line); list-style: none; }
        .returns-help li { display: flex; gap: 9px; color: #5f6e84; font-size: 12px; }
        .returns-help li i { margin-top: 3px; color: #5c9b7d; }

        @media (max-width: 800px) {
            .returns-hero { min-height: 170px; padding: 25px; }
            .returns-hero__visual { width: 88px; height: 88px; flex-basis: 88px; border-radius: 24px; font-size: 38px; }
            .requests-layout { grid-template-columns: 1fr; }
            .returns-help { order: 2; }
        }
        @media (max-width: 600px) {
            .returns-page { width: min(100% - 20px, 560px); margin-top: 22px; }
            .returns-hero { display: block; padding: 24px 21px; border-radius: 19px; }
            .returns-hero__visual { display: none; }
            .returns-card__header, .returns-card__body { padding: 21px 18px; }
            .return-steps { grid-template-columns: 1fr; gap: 9px; padding: 13px; }
            .field-grid { grid-template-columns: 1fr; gap: 14px; margin-bottom: 20px; }
            .return-products__head { display: none; }
            .return-product { grid-template-columns: 35px minmax(0,1fr) 72px; gap: 9px; padding: 14px 12px; }
            .return-product__variant { grid-column: 2; grid-row: 2; }
            .return-product__ordered { display: none; }
            .return-product__quantity { grid-column: 3; grid-row: 1 / span 2; }
            .bank-panel { padding: 16px; }
            .form-actions { align-items: stretch; flex-direction: column-reverse; }
            .form-actions .btn { width: 100%; }
            .requests-card__head { padding: 19px 18px; }
            .request-list { padding: 11px; }
            .request-card { padding: 15px; }
            .request-card__top { display: block; }
            .request-card__top .status { margin-top: 11px; }
            .request-meta { grid-template-columns: 1fr 1fr; gap: 12px; }
            .request-card__bottom { align-items: stretch; flex-direction: column; }
            .request-card__bottom .btn { width: 100%; }
        }
    </style>
</head>
<body class="returns-shell">
    <jsp:include page="/view/customer/common/header.jsp"/>
    <main class="returns-page">
        <section class="returns-hero">
            <div class="returns-hero__copy">
                <p class="returns-eyebrow">Customer care</p>
                <h1>Returns made simple.</h1>
                <p>Send a request in a few steps, then follow every update until your refund is complete.</p>
            </div>
            <div class="returns-hero__visual" aria-hidden="true"><i class="fa-solid fa-rotate-left"></i></div>
        </section>

        <c:if test="${not empty successMsg}"><div class="alert alert-success returns-alert"><i class="fa-solid fa-circle-check me-2"></i>${successMsg}</div></c:if>
        <c:if test="${not empty errorMsg}"><div class="alert alert-danger returns-alert"><i class="fa-solid fa-circle-exclamation me-2"></i>${errorMsg}</div></c:if>

        <c:if test="${param.action eq 'create'}">
            <section class="returns-card returns-form-card">
                <c:choose>
                    <c:when test="${not empty selectedOrder}">
                        <div class="returns-card__header">
                            <div class="d-flex align-items-start justify-content-between gap-3 flex-wrap">
                                <div class="d-flex align-items-center">
                                    <span class="return-title-icon"><i class="fa-solid fa-box-open"></i></span>
                                    <div><p class="section-eyebrow">New request</p><h2>Start a return or exchange</h2></div>
                                </div>
                                <span class="window-badge"><i class="fa-regular fa-clock"></i> 14-day return window</span>
                            </div>
                            <span class="order-ref"><i class="fa-solid fa-receipt"></i> Order ${selectedOrder.orderCode}</span>
                        </div>
                        <div class="returns-card__body">
                            <div class="return-steps" aria-label="Return request steps">
                                <div class="return-step is-active"><span class="return-step__number">1</span><span>Choose items</span></div>
                                <div class="return-step"><span class="return-step__number">2</span><span>Tell us why</span></div>
                                <div class="return-step"><span class="return-step__number">3</span><span>Receive your refund</span></div>
                            </div>
                            <form id="returnRequestForm" method="post" action="${pageContext.request.contextPath}/customer/returns">
                                <input type="hidden" name="orderId" value="${selectedOrder.id}">
                                <div class="field-grid">
                                    <div><label class="form-label" for="requestType">What would you like to do?</label><select id="requestType" name="type" class="form-select" required><option value="RETURN">Return &amp; refund</option><option value="EXCHANGE">Exchange product</option></select></div>
                                    <div><label class="form-label" for="returnReason">Why are you returning it?</label><select id="returnReason" name="reason" class="form-select" required><option value="">Select a reason</option><option value="WRONG_ITEM">Wrong item received</option><option value="DAMAGED">Product is damaged</option><option value="WRONG_SIZE">Wrong size or fit</option><option value="NOT_AS_DESCRIBED">Not as described</option><option value="CHANGE_OF_MIND">Changed my mind</option></select></div>
                                </div>

                                <div class="form-section-title"><i class="fa-solid fa-list-check"></i><span>Select products and quantities</span></div>
                                <div class="return-products">
                                    <div class="return-products__head"><span></span><span>Product</span><span>Ordered</span><span>Return qty.</span></div>
                                    <c:forEach var="item" items="${returnItems}">
                                        <div class="return-product">
                                            <label class="return-product__select" title="Select ${item.productNameSnapshot}"><input type="checkbox" class="js-return-item" aria-label="Select ${item.productNameSnapshot}" data-quantity-input="quantity_${item.orderDetailId}"><span><i class="fa-solid fa-check"></i></span></label>
                                            <div><div class="return-product__name">${item.productNameSnapshot}</div><div class="return-product__variant">${item.variantAttributesSnapshot}</div></div>
                                            <div class="return-product__ordered">${item.orderedQuantity} item(s)</div>
                                            <input type="hidden" name="detailId" value="${item.orderDetailId}">
                                            <input type="number" name="quantity_${item.orderDetailId}" class="form-control return-product__quantity js-return-quantity" min="0" max="${item.orderedQuantity}" value="0" aria-label="Return quantity for ${item.productNameSnapshot}">
                                        </div>
                                    </c:forEach>
                                </div>
                                <div id="returnSelectionError" class="alert alert-warning d-none py-2 mb-4"><i class="fa-solid fa-circle-info me-2"></i>Select at least one product and enter a return quantity.</div>

                                <div class="bank-panel">
                                    <h3 class="form-section-title"><i class="fa-solid fa-building-columns"></i><span>Where should we send your refund?</span></h3>
                                    <div class="row g-3">
                                        <div class="col-md-4"><label class="form-label" for="accountName">Account holder name</label><input id="accountName" type="text" name="accountName" class="form-control" maxlength="120" required placeholder="As shown by your bank"></div>
                                        <div class="col-md-4"><label class="form-label" for="accountNumber">Account number</label><input id="accountNumber" type="text" name="accountNumber" class="form-control" inputmode="numeric" pattern="[0-9]{4,25}" maxlength="25" required placeholder="Your bank account number"></div>
                                        <div class="col-md-4"><label class="form-label" for="bankId">Bank</label><select id="bankId" name="bankId" class="form-select" required><option value="">Select a bank</option><c:forEach var="bank" items="${refundBanks}"><option value="${bank.bankId}">${bank.bankName}</option></c:forEach></select></div>
                                    </div>
                                    <p class="bank-panel__note mb-0"><i class="fa-solid fa-lock me-1"></i>Your bank details are used only to process the approved refund.</p>
                                </div>

                                <label class="form-label" for="customerNote">Additional information <span class="text-muted fw-normal">(optional)</span></label>
                                <textarea id="customerNote" name="customerNote" class="form-control mb-4" rows="3" maxlength="1000" placeholder="Tell us what happened or add a helpful note..."></textarea>
                                <div class="form-actions"><a class="btn btn-light" href="${pageContext.request.contextPath}/customer/returns"><i class="fa-solid fa-arrow-left me-2"></i>Back to requests</a><button class="btn btn-primary" type="submit"><i class="fa-solid fa-paper-plane me-2"></i>Submit request</button></div>
                            </form>
                        </div>
                    </c:when>
                    <c:otherwise><div class="returns-card__body"><div class="alert alert-warning mb-0"><i class="fa-solid fa-circle-info me-2"></i>This order is not eligible for a new return request.</div></div></c:otherwise>
                </c:choose>
            </section>
        </c:if>

        <div class="requests-layout">
            <section class="returns-card requests-card">
                <div class="requests-card__head"><h2>My return requests</h2><span class="request-count"><i class="fa-solid fa-layer-group me-1"></i>${fn:length(returnRequests)}</span></div>
                <c:choose>
                    <c:when test="${empty returnRequests}"><div class="empty-requests"><i class="fa-solid fa-box-open"></i><div class="fw-bold mb-1">No return requests yet</div><div>When you request a return, its progress will appear here.</div></div></c:when>
                    <c:otherwise>
                        <div class="request-list">
                            <c:forEach var="item" items="${returnRequests}">
                                <article class="request-card">
                                    <div class="request-card__top"><div><h3 class="request-code">${item.requestCode}</h3><div class="request-order"><i class="fa-solid fa-receipt me-1"></i> Order ${item.orderCode}</div></div><span class="status status-${item.status}">${item.statusLabel}</span></div>
                                    <div class="request-meta"><div><span class="request-meta__label">Request type</span><span class="request-meta__value">${item.requestType}</span></div><div><span class="request-meta__label">Reason</span><span class="request-meta__value">${item.reason}</span></div><div><span class="request-meta__label">Refund amount</span><span class="request-meta__value amount"><fmt:formatNumber value="${item.refundAmount}" pattern="#,##0"/> VND</span></div></div>
                                    <c:if test="${not empty item.customerNote}"><p class="request-note"><i class="fa-regular fa-message me-1"></i>${item.customerNote}</p></c:if>
                                    <c:if test="${item.status eq 'INFO_REQUIRED'}"><form method="post" action="${pageContext.request.contextPath}/customer/returns" class="supplement-form"><input type="hidden" name="action" value="supplement"><input type="hidden" name="requestId" value="${item.id}"><label class="supplement-form__label" for="additionalNote_${item.id}"><i class="fa-solid fa-circle-question me-1"></i>We need a little more information</label><div class="input-group"><input id="additionalNote_${item.id}" name="additionalNote" class="form-control" placeholder="Add requested information" required><button class="btn btn-outline-primary" type="submit">Send</button></div></form></c:if>
                                    <div class="request-card__bottom"><span class="request-date"><i class="fa-regular fa-calendar me-1"></i><fmt:formatDate value="${item.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></span><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/customer/returns?action=view&amp;id=${item.id}">View details <i class="fa-solid fa-arrow-right ms-1"></i></a></div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
            <aside class="returns-card returns-help">
                <div class="returns-help__icon"><i class="fa-solid fa-headset"></i></div>
                <h2>Need a hand?</h2>
                <p>We review every request carefully and keep you updated at each step.</p>
                <ul><li><i class="fa-solid fa-check"></i><span>Return requests are reviewed within 1–2 business days.</span></li><li><i class="fa-solid fa-check"></i><span>Keep the item, tags and packaging in good condition.</span></li><li><i class="fa-solid fa-check"></i><span>Refunds are sent after the returned package is received.</span></li></ul>
            </aside>
        </div>
    </main>
    <jsp:include page="/view/customer/common/footer.jsp"/>
    <script>
        (function () {
            var form = document.getElementById('returnRequestForm');
            if (!form) return;
            var error = document.getElementById('returnSelectionError');
            form.querySelectorAll('.js-return-item').forEach(function (checkbox) {
                var input = form.querySelector('input[name="' + checkbox.dataset.quantityInput + '"]');
                if (!input) return;
                checkbox.addEventListener('change', function () {
                    if (!checkbox.checked) input.value = '0';
                    if (error) error.classList.add('d-none');
                });
                input.addEventListener('input', function () {
                    checkbox.checked = parseInt(input.value || '0', 10) > 0;
                    if (error) error.classList.add('d-none');
                });
            });
            form.addEventListener('submit', function (event) {
                var selected = false;
                form.querySelectorAll('.js-return-item').forEach(function (checkbox) {
                    var input = form.querySelector('input[name="' + checkbox.dataset.quantityInput + '"]');
                    var quantity = input ? parseInt(input.value || '0', 10) : 0;
                    if (checkbox.checked && quantity <= 0 && input) { input.value = '1'; quantity = 1; }
                    if (quantity > 0) { checkbox.checked = true; selected = true; }
                });
                if (!selected) { event.preventDefault(); if (error) error.classList.remove('d-none'); }
            });
        })();
    </script>
</body>
</html>
