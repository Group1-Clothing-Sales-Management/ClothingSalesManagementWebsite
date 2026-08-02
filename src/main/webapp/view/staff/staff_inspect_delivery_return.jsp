<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inspect Returned Goods</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .inspection-info {
            display: grid;
            grid-template-columns: minmax(180px, .8fr) minmax(220px, 1fr) minmax(280px, 1.6fr);
            gap: 18px;
            padding: 18px 20px;
            margin-bottom: 18px;
            border: 1px solid #d7e1f5;
            border-radius: 10px;
            background: #fff;
            box-shadow: 0 8px 24px rgba(15, 23, 42, .05);
        }

        .inspection-info-label {
            margin-bottom: 4px;
            color: #64748b;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .inspection-info-value {
            color: #0f172a;
            font-size: 15px;
            font-weight: 700;
            line-height: 1.45;
        }

        .inspection-rule {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding: 13px 16px;
            border: 1px solid #bfdbfe;
            border-radius: 9px;
            background: #eff6ff;
            color: #1e3a8a;
            font-size: 14px;
        }

        .inspection-rule i {
            color: #2563eb;
            font-size: 17px;
        }

        .inspection-card {
            overflow: hidden;
            border: 1px solid #dbe3ef;
            border-radius: 10px;
            background: #fff;
            box-shadow: 0 12px 30px rgba(15, 23, 42, .07);
        }

        .inspection-card-header {
            padding: 17px 20px;
            border-bottom: 1px solid #e2e8f0;
        }

        .inspection-card-header h2 {
            margin: 0;
            color: #0f172a;
            font-size: 17px;
            font-weight: 800;
        }

        .inspection-table {
            margin: 0;
        }

        .inspection-table thead th {
            padding: 13px 14px;
            border: 0;
            background: #24324a;
            color: #fff;
            font-size: 13px;
            font-weight: 800;
            white-space: nowrap;
        }

        .inspection-table tbody td {
            padding: 15px 14px;
            border-color: #e2e8f0;
            vertical-align: top;
        }

        .product-name {
            color: #0f172a;
            font-weight: 800;
        }

        .variant-text {
            color: #475569;
            line-height: 1.45;
        }

        .returned-quantity {
            display: inline-flex;
            min-width: 36px;
            min-height: 32px;
            align-items: center;
            justify-content: center;
            border-radius: 7px;
            background: #eef4ff;
            color: #365b9f;
            font-weight: 800;
        }

        .quantity-input {
            min-width: 105px;
            min-height: 42px;
            text-align: center;
            font-weight: 700;
        }

        .condition-input {
            min-width: 210px;
            min-height: 42px;
        }

        .row-error {
            display: none;
            margin-top: 8px;
            color: #dc2626;
            font-size: 12px;
            font-weight: 700;
            line-height: 1.35;
        }

        .inspection-row.has-error .row-error {
            display: block;
        }

        .inspection-row.has-error .quantity-input,
        .inspection-row.has-error .condition-input.note-required {
            border-color: #dc2626;
            box-shadow: 0 0 0 3px rgba(220, 38, 38, .10);
        }

        .client-error-alert {
            display: none;
            margin-bottom: 18px;
        }

        .client-error-alert.is-visible {
            display: block;
        }

        .inspection-note-wrap {
            padding: 18px 20px;
            border-top: 1px solid #e2e8f0;
        }

        .inspection-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            padding: 16px 20px;
            border-top: 1px solid #e2e8f0;
            background: #fff;
        }

        .inspection-actions .btn {
            min-height: 44px;
            border-radius: 8px;
            font-weight: 800;
        }

        .inspection-actions .btn-primary {
            min-width: 280px;
            background: #2563eb;
            border-color: #2563eb;
        }

        @media (max-width: 992px) {
            .inspection-info {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .inspection-actions {
                flex-direction: column-reverse;
            }

            .inspection-actions .btn,
            .inspection-actions .btn-primary {
                width: 100%;
                min-width: 0;
            }
        }
    </style>
</head>

<body class="bg-light">
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="shipments"/>
</jsp:include>

<div class="admin-page">
    <div class="page-header">
        <jsp:include page="/view/admin/common/page_heading.jsp">
            <jsp:param name="icon" value="fa-solid fa-box-open"/>
            <jsp:param name="title" value="Inspect Returned Goods"/>
        </jsp:include>
    </div>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger mb-3" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>
            <c:out value="${errorMsg}"/>
        </div>
    </c:if>

    <div id="clientErrorAlert"
         class="alert alert-danger client-error-alert"
         role="alert"
         aria-live="polite">
        <i class="fa-solid fa-circle-exclamation me-2"></i>
        <span id="clientErrorMessage">
            Please correct the invalid inspection quantities before continuing.
        </span>
    </div>

    <section class="inspection-info">
        <div>
            <div class="inspection-info-label">Order code</div>
            <div class="inspection-info-value">
                <c:out value="${shipment.orderCode}"/>
            </div>
        </div>

        <div>
            <div class="inspection-info-label">Recipient</div>
            <div class="inspection-info-value">
                <c:out value="${shipment.customerName}"/>
            </div>
        </div>

        <div>
            <div class="inspection-info-label">Failure reason</div>
            <div class="inspection-info-value">
                <c:out value="${empty shipment.note ? 'No reason provided' : shipment.note}"/>
            </div>
        </div>
    </section>

    

    <div class="inspection-card">
        <div class="inspection-card-header">
            <h2>Returned product inspection</h2>
        </div>

        <form id="inspectionForm"
              method="post"
              novalidate
              action="${pageContext.request.contextPath}/staff/shipments?action=confirmReturnInspection">

            <input type="hidden" name="id" value="${shipment.shipmentId}">

            <div class="table-responsive">
                <table class="table inspection-table align-middle">
                    <thead>
                        <tr>
                            <th class="ps-4">Product</th>
                            <th>Variant</th>
                            <th class="text-center">Returned</th>
                            <th style="width: 145px;">Restock</th>
                            <th style="width: 175px;">Damaged / Missing</th>
                            <th style="width: 270px;">Condition note</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach var="item" items="${inspectionItems}">
                            <tr class="inspection-row"
                                data-total="${item.returnQuantity}"
                                data-product="<c:out value='${item.productNameSnapshot}'/>">

                                <td class="ps-4">
                                    <div class="product-name">
                                        <c:out value="${item.productNameSnapshot}"/>
                                    </div>
                                </td>

                                <td>
                                    <div class="variant-text">
                                        <c:out value="${empty item.variantAttributesSnapshot
                                                ? 'Standard'
                                                : item.variantAttributesSnapshot}"/>
                                    </div>
                                </td>

                                <td class="text-center">
                                    <span class="returned-quantity">
                                        ${item.returnQuantity}
                                    </span>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${shipment.returnInspectionStatus eq 'COMPLETED'}">
                                            <span class="fw-bold text-success">
                                                ${item.restockQuantity}
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <input type="number"
                                                   class="form-control quantity-input restock-input"
                                                   name="restock_${item.id}"
                                                   min="0"
                                                   max="${item.returnQuantity}"
                                                   step="1"
                                                   inputmode="numeric"
                                                   value="${not empty submittedRestock[item.id]
                                                           ? submittedRestock[item.id]
                                                           : ''}"
                                                   aria-label="Restock quantity for ${item.productNameSnapshot}">
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${shipment.returnInspectionStatus eq 'COMPLETED'}">
                                            <span class="fw-bold text-danger">
                                                ${item.damagedQuantity}
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <input type="number"
                                                   class="form-control quantity-input damaged-input"
                                                   name="damaged_${item.id}"
                                                   min="0"
                                                   max="${item.returnQuantity}"
                                                   step="1"
                                                   inputmode="numeric"
                                                   value="${not empty submittedDamaged[item.id]
                                                           ? submittedDamaged[item.id]
                                                           : ''}"
                                                   aria-label="Damaged or missing quantity for ${item.productNameSnapshot}">
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${shipment.returnInspectionStatus eq 'COMPLETED'}">
                                            <c:out value="${empty item.itemNote ? '—' : item.itemNote}"/>
                                        </c:when>

                                        <c:otherwise>
                                            <input type="text"
                                                   class="form-control condition-input"
                                                   maxlength="500"
                                                   name="itemNote_${item.id}"
                                                   value="${submittedItemNotes[item.id]}"
                                                   placeholder="Required when damaged/missing > 0">
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="row-error" aria-live="polite"></div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <div class="inspection-note-wrap">
                <label for="inspectionNote" class="form-label fw-bold">
                    Overall inspection note
                    <span class="text-muted fw-normal">(optional)</span>
                </label>

                <c:choose>
                    <c:when test="${shipment.returnInspectionStatus eq 'COMPLETED'}">
                        <div class="form-control bg-light">
                            Inspection completed.
                        </div>
                    </c:when>

                    <c:otherwise>
                        <textarea id="inspectionNote"
                                  name="inspectionNote"
                                  class="form-control"
                                  rows="3"
                                  maxlength="1000"
                                  placeholder="Add an overall note about the returned package..."><c:out value="${submittedInspectionNote}"/></textarea>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="inspection-actions">
                <a href="${pageContext.request.contextPath}/staff/shipments"
                   class="btn btn-light border px-4">
                    Back
                </a>

                <c:if test="${shipment.returnInspectionStatus ne 'COMPLETED'}">
                    <button id="confirmInspectionButton"
                            type="submit"
                            class="btn btn-primary px-4">
                        Confirm Inspection &amp; Update Inventory
                    </button>
                </c:if>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

<script>
    (function () {
        const form = document.getElementById('inspectionForm');
        const rows = Array.from(document.querySelectorAll('.inspection-row'));
        const clientErrorAlert = document.getElementById('clientErrorAlert');
        const clientErrorMessage = document.getElementById('clientErrorMessage');

        function readQuantity(input) {
            if (!input || input.value.trim() === '') {
                return null;
            }

            const value = Number(input.value);
            return Number.isFinite(value) ? value : null;
        }

        function setRowError(row, message, noteRequired) {
            const errorElement = row.querySelector('.row-error');
            const noteInput = row.querySelector('.condition-input');

            row.classList.toggle('has-error', Boolean(message));

            if (errorElement) {
                errorElement.textContent = message || '';
            }

            if (noteInput) {
                noteInput.classList.toggle('note-required', Boolean(noteRequired));
            }
        }

        function validateRow(row, showError) {
            const total = Number(row.dataset.total || 0);
            const productName = row.dataset.product || 'This product';
            const restockInput = row.querySelector('.restock-input');
            const damagedInput = row.querySelector('.damaged-input');
            const noteInput = row.querySelector('.condition-input');

            if (!restockInput || !damagedInput) {
                return true;
            }

            const restock = readQuantity(restockInput);
            const damaged = readQuantity(damagedInput);
            let message = '';
            let noteRequired = false;

            if (restock === null || damaged === null) {
                message = 'Enter both Restock and Damaged / Missing quantities.';
            } else if (!Number.isInteger(restock) || !Number.isInteger(damaged)) {
                message = 'Quantities must be whole numbers.';
            } else if (restock < 0 || damaged < 0) {
                message = 'Quantities cannot be negative.';
            } else if (restock > total || damaged > total) {
                message = 'Each quantity cannot be greater than the returned quantity (' + total + ').';
            } else if (restock + damaged !== total) {
                message = 'Restock + Damaged / Missing must equal '
                        + total + '. Current total: ' + (restock + damaged) + '.';
            } else if (damaged > 0
                    && (!noteInput || noteInput.value.trim() === '')) {
                message = 'Enter a condition note for damaged or missing goods.';
                noteRequired = true;
            }

            if (showError) {
                setRowError(row, message, noteRequired);
            } else if (!message) {
                setRowError(row, '', false);
            }

            restockInput.classList.toggle('is-invalid', Boolean(message));
            damagedInput.classList.toggle('is-invalid', Boolean(message));

            return message === '';
        }

        function validateAllRows(showErrors) {
            let allValid = true;
            let firstInvalidRow = null;

            rows.forEach(function (row) {
                const valid = validateRow(row, showErrors);

                if (!valid) {
                    allValid = false;

                    if (!firstInvalidRow) {
                        firstInvalidRow = row;
                    }
                }
            });

            if (clientErrorAlert) {
                clientErrorAlert.classList.toggle('is-visible', !allValid && showErrors);
            }

            if (!allValid && showErrors && clientErrorMessage) {
                clientErrorMessage.textContent =
                        'Some inspection quantities are invalid. Check the highlighted product row(s).';
            }

            return {
                valid: allValid,
                firstInvalidRow: firstInvalidRow
            };
        }

        rows.forEach(function (row) {
            row.querySelectorAll(
                    '.restock-input, .damaged-input, .condition-input'
            ).forEach(function (input) {
                input.addEventListener('input', function () {
                    validateRow(row, true);

                    const result = validateAllRows(false);
                    if (result.valid && clientErrorAlert) {
                        clientErrorAlert.classList.remove('is-visible');
                    }
                });
            });
        });

        if (form) {
            form.addEventListener('submit', function (event) {
                const result = validateAllRows(true);

                if (!result.valid) {
                    event.preventDefault();

                    if (clientErrorAlert) {
                        clientErrorAlert.scrollIntoView({
                            behavior: 'smooth',
                            block: 'center'
                        });
                    }

                    const firstInput = result.firstInvalidRow
                            ? result.firstInvalidRow.querySelector(
                                    '.restock-input, .damaged-input, .condition-input'
                            )
                            : null;

                    if (firstInput) {
                        setTimeout(function () {
                            firstInput.focus();
                        }, 250);
                    }

                    return;
                }

                if (!window.confirm(
                        'Confirm inspection results and update inventory? '
                        + 'This action cannot be repeated.'
                )) {
                    event.preventDefault();
                }
            });
        }
    }());
</script>
</body>
</html>