<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Request Details</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        :root {
            --detail-blue: #5f84d6;
            --detail-blue-dark: #365b9f;
            --detail-blue-soft: #eef4ff;
            --detail-ink: #1f2937;
            --detail-muted: #718096;
            --detail-line: #e5eaf3;
            --detail-bg: #f6f8fc;
        }
        body.detail-shell { background: radial-gradient(circle at 90% 8%, #edf4ff 0, transparent 28rem), var(--detail-bg); color: var(--detail-ink); }
        .detail-page { width: min(1180px, calc(100% - 32px)); margin: 30px auto 72px; }
        .detail-back { display: inline-flex; align-items: center; gap: 8px; margin-bottom: 17px; color: var(--detail-muted); font-size: 13px; font-weight: 700; text-decoration: none; }
        .detail-back:hover { color: var(--detail-blue-dark); }
        .detail-hero { position: relative; overflow: hidden; display: grid; grid-template-columns: minmax(0,1fr) 255px; gap: 25px; padding: 30px 34px; border-radius: 24px; color: #fff; background: linear-gradient(120deg, #365b9f 0%, #6f95df 62%, #9bb9ef 100%); box-shadow: 0 18px 38px rgba(72,111,181,.2); }
        .detail-hero::after { position: absolute; right: -78px; bottom: -160px; width: 370px; height: 370px; border: 1px solid rgba(255,255,255,.24); border-radius: 50%; box-shadow: 0 0 0 28px rgba(255,255,255,.06), 0 0 0 57px rgba(255,255,255,.045); content: ""; }
        .detail-hero__main, .detail-hero__amount { position: relative; z-index: 1; }
        .detail-eyebrow { margin: 0 0 8px; color: #dbe8ff; font-size: 11px; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; }
        .detail-hero h1 { margin: 0 0 7px; color: #fff; font-size: clamp(1.6rem, 3vw, 2.2rem); font-weight: 800; }
        .detail-hero__order { color: #eaf1ff; font-size: 14px; }
        .detail-hero__status { display: inline-flex; align-items: center; gap: 7px; margin-top: 21px; padding: 8px 12px; border: 1px solid rgba(255,255,255,.23); border-radius: 999px; color: #fff; background: rgba(255,255,255,.14); font-size: 12px; font-weight: 800; }
        .detail-hero__status i { color: #dce8ff; font-size: 10px; }
        .detail-hero__amount { display: flex; flex-direction: column; justify-content: center; padding-left: 25px; border-left: 1px solid rgba(255,255,255,.2); }
        .detail-hero__amount-label { margin-bottom: 8px; color: #dbe8ff; font-size: 11px; font-weight: 800; letter-spacing: .1em; text-transform: uppercase; }
        .detail-hero__amount strong { font-size: clamp(1.4rem, 3vw, 2rem); font-weight: 800; }
        .detail-hero__amount small { margin-top: 6px; color: #eaf1ff; }

        .detail-card { overflow: hidden; border: 1px solid rgba(215,225,245,.85); border-radius: 20px; background: #fff; box-shadow: 0 10px 28px rgba(44,62,92,.07); }
        .detail-card__head { display: flex; align-items: center; justify-content: space-between; gap: 14px; padding: 22px 26px; border-bottom: 1px solid var(--detail-line); }
        .detail-card__head h2 { margin: 0; font-size: 1.08rem; font-weight: 800; }
        .detail-card__body { padding: 25px 26px; }
        .detail-section { margin-top: 22px; }
        .detail-grid { display: grid; grid-template-columns: minmax(0,1fr) 290px; gap: 22px; margin-top: 22px; align-items: start; }
        .info-label { display: block; margin-bottom: 5px; color: #8a96a9; font-size: 10px; font-weight: 800; letter-spacing: .09em; text-transform: uppercase; }
        .detail-summary { display: grid; grid-template-columns: repeat(3,1fr); gap: 14px; padding: 17px; border-radius: 14px; background: #f8faff; }
        .detail-summary__item { min-width: 0; }
        .detail-summary__value { color: var(--detail-ink); font-size: 14px; font-weight: 800; }
        .detail-summary__value.accent { color: var(--detail-blue-dark); }
        .detail-table { margin: 0; }
        .detail-table thead th { padding: 12px 14px; border-bottom: 1px solid #dfe6f2; color: #68778f; background: #f7f9fd; font-size: 10px; font-weight: 800; letter-spacing: .06em; text-transform: uppercase; white-space: nowrap; }
        .detail-table tbody td { padding: 16px 14px; border-color: #edf0f5; color: #4c5a71; font-size: 13px; }
        .detail-table tbody td:first-child { color: var(--detail-ink); font-weight: 800; }
        .detail-table tbody td:last-child { color: var(--detail-blue-dark); font-weight: 800; white-space: nowrap; }
        .detail-table tbody tr:last-child td { border-bottom: 0; }
        .detail-dates { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 21px; padding-top: 21px; border-top: 1px solid var(--detail-line); }
        .detail-date { color: #52627a; font-size: 13px; font-weight: 700; }
        .detail-note { margin-top: 18px; padding: 14px 16px; border: 1px solid var(--detail-line); border-radius: 12px; background: #fbfcfe; color: #64738b; font-size: 13px; line-height: 1.6; }
        .detail-note .info-label { margin-bottom: 7px; }

        .return-timeline { display: grid; grid-template-columns: repeat(4,1fr); gap: 0; padding: 25px 26px 22px; }
        .timeline-step { position: relative; display: flex; flex-direction: column; align-items: center; gap: 9px; color: #9aa6b9; font-size: 11px; font-weight: 800; text-align: center; }
        .timeline-step:not(:last-child)::after { position: absolute; top: 13px; left: calc(50% + 16px); width: calc(100% - 31px); height: 2px; background: #e6ebf4; content: ""; }
        .timeline-step__dot { position: relative; z-index: 1; display: grid; place-items: center; width: 27px; height: 27px; border: 2px solid #dce3ef; border-radius: 50%; color: #a5b0c1; background: #fff; }
        .timeline-step.is-done { color: var(--detail-blue-dark); }
        .timeline-step.is-done .timeline-step__dot { border-color: var(--detail-blue); color: #fff; background: var(--detail-blue); }
        .timeline-step.is-done:not(:last-child)::after { background: #9bb6ed; }
        .timeline-step.is-current .timeline-step__dot { box-shadow: 0 0 0 5px rgba(95,132,214,.13); }

        .side-stack { display: grid; gap: 22px; }
        .side-card { padding: 22px; }
        .side-card h2 { margin: 0 0 15px; font-size: 15px; font-weight: 800; }
        .side-row { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; padding: 11px 0; border-bottom: 1px solid #eef1f6; font-size: 12px; }
        .side-row:first-of-type { padding-top: 0; }
        .side-row:last-child { padding-bottom: 0; border-bottom: 0; }
        .side-row span { color: #8995a8; }
        .side-row strong { color: #4b5a72; text-align: right; }
        .side-card--help { color: #56667f; background: linear-gradient(145deg,#f7faff,#edf4ff); }
        .side-card--help .side-card__icon { display: grid; place-items: center; width: 39px; height: 39px; margin-bottom: 13px; border-radius: 12px; color: var(--detail-blue-dark); background: #dce8ff; }
        .side-card--help p { margin: 0; font-size: 12px; line-height: 1.65; }

        .status-pill { display: inline-flex; align-items: center; gap: 7px; padding: 7px 11px; border-radius: 999px; font-size: 11px; font-weight: 800; }
        .status-pill::before { width: 6px; height: 6px; border-radius: 50%; background: currentColor; content: ""; }
        .status-pill--pending, .status-pill--info-required { color:#956500; background:#fff5d9; }
        .status-pill--approved, .status-pill--received { color:#2e62be; background:#e9f1ff; }
        .status-pill--refund-pending { color:#6d48b2; background:#f0eaff; }
        .status-pill--completed { color:#17734f; background:#e4f7ee; }
        .status-pill--rejected { color:#b33b46; background:#ffebed; }
        .status-pill--cancelled { color:#9b5c1c; background:#fff0df; }
        .state-message { display: flex; align-items: flex-start; gap: 13px; margin-top: 22px; padding: 18px 20px; border: 1px solid; border-radius: 15px; }
        .state-message i { margin-top: 2px; font-size: 19px; }
        .state-message h2 { margin: 0 0 5px; font-size: 14px; font-weight: 800; }
        .state-message p { margin: 0; font-size: 12px; line-height: 1.6; }
        .state-message--blue { border-color: #cadcf9; color: #3767ae; background: #f0f6ff; }
        .state-message--green { border-color: #c4e8d7; color: #247354; background: #effbf5; }
        .state-message--yellow { border-color: #f1dda9; color: #8a641b; background: #fffaf0; }
        .proof-card { margin-top: 22px; }
        .proof-card__intro { margin: -7px 0 17px; color: var(--detail-muted); font-size: 13px; }
        .proof-image { display: block; max-width: 100%; max-height: 390px; object-fit: contain; border: 1px solid var(--detail-line); border-radius: 13px; background: #fafbfd; padding: 8px; }
        .proof-link { display: inline-flex; align-items: center; gap: 7px; color: var(--detail-blue-dark); font-size: 12px; font-weight: 800; }

        @media (max-width: 850px) {
            .detail-hero { grid-template-columns: 1fr; }
            .detail-hero__amount { align-items: flex-start; padding: 19px 0 0; border-top: 1px solid rgba(255,255,255,.2); border-left: 0; }
            .detail-grid { grid-template-columns: 1fr; }
            .side-stack { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 600px) {
            .detail-page { width: min(100% - 20px, 560px); margin-top: 22px; }
            .detail-hero { padding: 24px 21px; border-radius: 19px; }
            .detail-card__head, .detail-card__body { padding: 20px 17px; }
            .return-timeline { gap: 4px; padding: 21px 11px 17px; }
            .timeline-step { font-size: 9px; }
            .timeline-step__dot { width: 24px; height: 24px; font-size: 10px; }
            .timeline-step:not(:last-child)::after { top: 11px; left: calc(50% + 14px); width: calc(100% - 27px); }
            .detail-summary { grid-template-columns: 1fr 1fr; }
            .detail-summary__item:last-child { grid-column: 1 / -1; }
            .detail-dates { grid-template-columns: 1fr; gap: 11px; }
            .side-stack { grid-template-columns: 1fr; }
            .detail-table thead th, .detail-table tbody td { padding: 11px 10px; }
        }
    </style>
</head>
<body class="detail-shell">
<jsp:include page="/view/customer/common/header.jsp"/>
<main class="detail-page">
    <a class="detail-back" href="${pageContext.request.contextPath}/customer/returns"><i class="fa-solid fa-arrow-left"></i> Back to returns</a>

    <c:choose>
        <c:when test="${empty returnRequest}"><div class="alert alert-danger detail-card border-0 p-4"><i class="fa-solid fa-circle-exclamation me-2"></i>Return request not found.</div></c:when>
        <c:otherwise>
            <c:set var="returnStep" value="1"/>
            <c:choose><c:when test="${returnRequest.status eq 'APPROVED'}"><c:set var="returnStep" value="2"/></c:when><c:when test="${returnRequest.status eq 'RECEIVED' or returnRequest.status eq 'REFUND_PENDING'}"><c:set var="returnStep" value="3"/></c:when><c:when test="${returnRequest.status eq 'COMPLETED'}"><c:set var="returnStep" value="4"/></c:when></c:choose>

            <section class="detail-hero">
                <div class="detail-hero__main"><p class="detail-eyebrow">Return request</p><h1>${returnRequest.requestCode}</h1><div class="detail-hero__order"><i class="fa-solid fa-receipt me-1"></i> Order ${returnRequest.orderCode}</div><span class="detail-hero__status"><i class="fa-solid fa-circle"></i>${returnRequest.statusLabel}</span></div>
                <div class="detail-hero__amount"><span class="detail-hero__amount-label">Estimated refund</span><strong><fmt:formatNumber value="${returnRequest.refundAmount}" pattern="#,##0"/> VND</strong><small><i class="fa-solid fa-shield-heart me-1"></i>Processed securely</small></div>
            </section>

            <section class="detail-card detail-section" aria-label="Return progress">
                <div class="return-timeline">
                    <div class="timeline-step is-done ${returnStep eq 1 ? 'is-current' : ''}"><span class="timeline-step__dot"><i class="fa-solid fa-check"></i></span><span>Request sent</span></div>
                    <div class="timeline-step ${returnStep >= 2 ? 'is-done' : ''} ${returnStep eq 2 ? 'is-current' : ''}"><span class="timeline-step__dot"><c:choose><c:when test="${returnStep >= 2}"><i class="fa-solid fa-check"></i></c:when><c:otherwise>2</c:otherwise></c:choose></span><span>Request reviewed</span></div>
                    <div class="timeline-step ${returnStep >= 3 ? 'is-done' : ''} ${returnStep eq 3 ? 'is-current' : ''}"><span class="timeline-step__dot"><c:choose><c:when test="${returnStep >= 3}"><i class="fa-solid fa-check"></i></c:when><c:otherwise>3</c:otherwise></c:choose></span><span>Package received</span></div>
                    <div class="timeline-step ${returnStep >= 4 ? 'is-done' : ''} ${returnStep eq 4 ? 'is-current' : ''}"><span class="timeline-step__dot"><c:choose><c:when test="${returnStep >= 4}"><i class="fa-solid fa-check"></i></c:when><c:otherwise>4</c:otherwise></c:choose></span><span>Refund complete</span></div>
                </div>
            </section>

            <div class="detail-grid">
                <div>
                    <section class="detail-card">
                        <div class="detail-card__head"><h2>Request overview</h2><span class="status-pill status-pill--${fn:toLowerCase(fn:replace(returnRequest.status, '_', '-'))}">${returnRequest.statusLabel}</span></div>
                        <div class="detail-card__body">
                            <div class="detail-summary"><div class="detail-summary__item"><span class="info-label">Request type</span><span class="detail-summary__value">${returnRequest.requestType}</span></div><div class="detail-summary__item"><span class="info-label">Reason</span><span class="detail-summary__value">${returnRequest.reason}</span></div><div class="detail-summary__item"><span class="info-label">Refund amount</span><span class="detail-summary__value accent"><fmt:formatNumber value="${returnRequest.refundAmount}" pattern="#,##0"/> VND</span></div></div>
                            <div class="detail-section"><div class="d-flex align-items-center justify-content-between gap-3 mb-3"><h3 class="h6 fw-bold mb-0">Products in this request</h3><span class="text-muted small">${fn:length(returnRequest.items)} item(s)</span></div><div class="table-responsive border rounded-3"><table class="table detail-table align-middle"><thead><tr><th>Product</th><th>Variant</th><th>Qty.</th><th>Unit price</th><th>Total</th></tr></thead><tbody><c:forEach var="item" items="${returnRequest.items}"><tr><td>${item.productNameSnapshot}</td><td>${item.variantAttributesSnapshot}</td><td>${item.quantity}</td><td><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> VND</td><td><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> VND</td></tr></c:forEach></tbody></table></div></div>
                            <div class="detail-dates"><div><span class="info-label">Submitted</span><span class="detail-date"><i class="fa-regular fa-calendar me-1"></i><fmt:formatDate value="${returnRequest.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></span></div><div><span class="info-label">Refund confirmed</span><span class="detail-date"><c:choose><c:when test="${not empty returnRequest.refundConfirmedAt}"><i class="fa-regular fa-circle-check me-1"></i><fmt:formatDate value="${returnRequest.refundConfirmedAt}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise><i class="fa-regular fa-clock me-1"></i>Not completed yet</c:otherwise></c:choose></span></div></div>
                            <c:if test="${not empty returnRequest.customerNote}"><div class="detail-note"><span class="info-label"><i class="fa-regular fa-message me-1"></i>Your note</span>${returnRequest.customerNote}</div></c:if>
                            <c:if test="${not empty returnRequest.staffNote}"><div class="detail-note"><span class="info-label"><i class="fa-solid fa-store me-1"></i>Store note</span>${returnRequest.staffNote}</div></c:if>
                        </div>
                    </section>

                    <c:if test="${returnRequest.status eq 'APPROVED'}"><div class="state-message state-message--blue"><i class="fa-solid fa-truck-fast"></i><div><h2>Package collection is scheduled</h2><p>A shipper will come to collect the returned products within 1–2 days. This status remains active for 3 days; if the store does not receive the package, the request will be automatically cancelled.</p></div></div></c:if>
                    <c:if test="${returnRequest.status eq 'RECEIVED'}"><div class="state-message state-message--green"><i class="fa-solid fa-box-open"></i><div><h2>Package received by the store</h2><p>The store has received your returned products. Your refund is being processed.</p></div></div></c:if>
                    <c:if test="${returnRequest.status eq 'CANCELLED'}"><div class="state-message state-message--yellow"><i class="fa-solid fa-circle-xmark"></i><div><h2>Request cancelled</h2><p>The store did not receive the returned package within 3 days, so this refund request was automatically cancelled.</p></div></div></c:if>

                    <c:if test="${not empty returnRequest.refundProofPath}"><section class="detail-card proof-card"><div class="detail-card__head"><h2>Refund completion proof</h2><i class="fa-solid fa-file-circle-check text-success"></i></div><div class="detail-card__body"><p class="proof-card__intro">The refund was confirmed by the store. Click the image to open the full-size transfer proof.</p><c:choose><c:when test="${fn:startsWith(returnRequest.refundProofPath, 'http://') or fn:startsWith(returnRequest.refundProofPath, 'https://')}"><a href="${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img class="proof-image" src="${returnRequest.refundProofPath}" alt="Refund transfer proof"></a></c:when><c:otherwise><a href="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" target="_blank" rel="noopener"><img class="proof-image" src="${pageContext.request.contextPath}/${returnRequest.refundProofPath}" alt="Refund transfer proof"></a></c:otherwise></c:choose></div></section></c:if>
                </div>

                <aside class="side-stack">
                    <section class="detail-card side-card"><h2>Refund destination</h2><c:choose><c:when test="${not empty returnRequest.refundBankName}"><div class="side-row"><span>Bank</span><strong>${returnRequest.refundBankName}</strong></div><div class="side-row"><span>Account holder</span><strong>${returnRequest.refundAccountName}</strong></div><div class="side-row"><span>Account number</span><strong>•••• ${fn:substring(returnRequest.refundAccountNumber, fn:length(returnRequest.refundAccountNumber) - 4, fn:length(returnRequest.refundAccountNumber))}</strong></div></c:when><c:otherwise><p class="text-muted small mb-0">Refund destination details will appear here once available.</p></c:otherwise></c:choose></section>
                    <section class="detail-card side-card side-card--help"><div class="side-card__icon"><i class="fa-solid fa-headset"></i></div><h2>Need help with this request?</h2><p>If you have questions, keep your request code handy when contacting our support team.</p></section>
                </aside>
            </div>
        </c:otherwise>
    </c:choose>
</main>
<jsp:include page="/view/customer/common/footer.jsp"/>
</body>
</html>
