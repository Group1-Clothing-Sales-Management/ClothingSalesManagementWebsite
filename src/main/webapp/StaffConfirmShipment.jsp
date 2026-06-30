<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Update Shipment Status</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <style>
        .card-custom {
            border: none;
            border-radius: 12px;
        }
        .form-check-custom {
            padding: 1rem 1.25rem;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            margin-bottom: 0.75rem;
            transition: all 0.2s ease-in-out;
            cursor: pointer;
        }
        .form-check-custom:hover {
            background-color: #f8f9fa;
            border-color: #bcd0f7;
        }
        .form-check-input:checked ~ .form-check-label {
            font-weight: 700;
        }
        .modal-content-custom {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }
    </style>
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="shipments" />
</jsp:include>

        <div class="admin-page">
            <div class="page-header">
                <div>
                    <h2 class="page-title">Update Shipment Status</h2>
                    <p class="page-subtitle mb-0">Confirm delivery progress and record the final outcome.</p>
                </div>
            </div>

            <div class="d-flex justify-content-center align-items-start">
            <div class="card card-main admin-card w-100" style="max-width: 750px;">
                <div class="card-header bg-dark text-white py-3" style="border-top-left-radius: 12px; border-top-right-radius: 12px;">
                    <h5 class="mb-0 fw-bold"><i class="fa-solid fa-truck-ramp-box me-2"></i>Update Shipment Status</h5>
                </div>
                <div class="card-body p-4">
                    
                    <h6 class="text-secondary fw-bold text-uppercase mb-3" style="font-size: 0.85rem; letter-spacing: 0.5px;">Order Information</h6>
                    <div class="table-responsive mb-4">
                        <table class="table table-bordered align-middle mb-0 bg-white shadow-sm rounded">
                            <tr>
                                <th width="35%" class="bg-light text-secondary font-monospace">Order Code</th>
                                <td><span class="badge bg-dark px-2.5 py-1.5 font-monospace text-wrap">${shipment.orderCode}</span></td>
                            </tr>
                            <tr>
                                <th class="bg-light text-secondary">Recipient Name</th>
                                <td class="fw-semibold text-dark">${shipment.customerName}</td>
                            </tr>
                            <tr>
                                <th class="bg-light text-secondary">Delivery Address</th>
                                <td class="text-muted"><c:out value="${shipment.deliveryAddress}"/></td>
                            </tr>
                            <tr>
                                <th class="bg-light text-secondary">Current Status</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${shipment.shippingStatus == 'PENDING_PICKUP'}"><span class="badge bg-warning text-dark px-3 py-2 rounded-pill"><i class="fa-solid fa-clock me-1"></i>Pending Pickup</span></c:when>
                                        <c:when test="${shipment.shippingStatus == 'SHIPPING'}"><span class="badge bg-primary px-3 py-2 rounded-pill"><i class="fa-solid fa-truck fast me-1"></i>In Transit</span></c:when>
                                        <c:when test="${shipment.shippingStatus == 'SUCCESS'}"><span class="badge bg-success px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-check me-1"></i>Success</span></c:when>
                                        <c:otherwise><span class="badge bg-danger px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-xmark me-1"></i>Failure</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <form id="shipmentForm" action="${pageContext.request.contextPath}/staff/shipments?action=confirmDelivery" method="POST">
                        <input type="hidden" name="id" value="${shipment.shipmentId}">
                        
                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark mb-3">Select New Shipment Status <span class="text-danger">*</span></label>
                            <div class="card p-3 bg-white">
                                
                                <c:choose>
                                    <%-- CASE 1: Current status is Pending Pickup -> ONLY allow transition to Shipping --%>
                                    <c:when test="${shipment.shippingStatus == 'PENDING_PICKUP'}">
                                        <div class="form-check form-check-custom d-flex align-items-center mb-0">
                                            <input class="form-check-input me-3" type="radio" name="outcome" id="statusShipping" value="SHIPPING" checked required>
                                            <label class="form-check-label text-primary fw-bold fs-6 mb-0 w-100" for="statusShipping">
                                                <i class="fa-solid fa-truck-moving me-2"></i>In Transit / Shipping
                                            </label>
                                        </div>
                                    </c:when>

                                    <%-- CASE 2: Current status is Shipping -> ONLY allow final states (Success / Failure) --%>
                                    <c:when test="${shipment.shippingStatus == 'SHIPPING'}">
                                        <div class="form-check form-check-custom d-flex align-items-center">
                                            <input class="form-check-input me-3" type="radio" name="outcome" id="statusDelivered" value="SUCCESS" checked required>
                                            <label class="form-check-label text-success fw-bold fs-6 mb-0 w-100" for="statusDelivered">
                                                <i class="fa-solid fa-house-chimney-user me-2"></i>Success
                                            </label>
                                        </div>
                                        
                                        <div class="form-check form-check-custom d-flex align-items-center mb-0">
                                            <input class="form-check-input me-3" type="radio" name="outcome" id="statusFailed" value="FAILURE" required>
                                            <label class="form-check-label text-danger fw-bold fs-6 mb-0 w-100" for="statusFailed">
                                                <i class="fa-solid fa-circle-exclamation me-2"></i>Failure
                                            </label>
                                        </div>
                                    </c:when>
                                </c:choose>

                            </div>
                        </div>

                        <div id="remarksContainer" class="mb-4 d-none">
                            <label for="remarks" class="form-label fw-bold text-dark">Reason for Failure <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="remarks" name="remarks" rows="3" style="border-radius: 8px;" placeholder="Please write why the delivery failed or was returned..."></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2 pt-2">
                            <a href="${pageContext.request.contextPath}/staff/shipments" class="btn btn-light px-4 fw-semibold border text-secondary" style="border-radius: 8px;">Cancel</a>
                            <button type="button" class="btn btn-primary px-4 fw-semibold" style="border-radius: 8px;" onclick="showConfirmModal()">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>
            </div>
        </div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />

<div class="modal fade" id="confirmModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 450px;">
        <div class="modal-content modal-content-custom p-2">
            <div class="modal-body text-center pt-4 pb-3">
                <div class="mb-3 text-primary">
                    <i class="fa-solid fa-circle-question fa-3x"></i>
                </div>
                <h5 class="modal-title fw-bold text-dark mb-2">Confirm Status Update?</h5>
                <p class="text-secondary px-2 mb-0">
                    Are you sure you want to change this shipment status to:
                </p>
                <div class="my-3">
                    <span id="modalStatusBadge" class="badge fs-6 px-3 py-2 rounded-pill">Status</span>
                </div>
                <p class="text-xs text-muted">This action will sync and update the customer's order tracking timeline.</p>
            </div>
            <div class="modal-footer border-0 d-flex justify-content-center gap-2 pb-3">
                <button type="button" class="btn btn-light px-4 border text-secondary" style="border-radius: 8px;" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary px-4" style="border-radius: 8px;" onclick="submitForm()">Confirm</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let bootstrapModal;

    const radioButtons = document.querySelectorAll('input[name="outcome"]');
    const remarksContainer = document.getElementById('remarksContainer');
    const remarksInput = document.getElementById('remarks');

    function toggleRemarksVisibility() {
        const selectedRadio = document.querySelector('input[name="outcome"]:checked');
        if (selectedRadio && selectedRadio.value === 'FAILURE') {
            remarksContainer.classList.remove('d-none');
            remarksInput.setAttribute('required', 'true');
        } else {
            remarksContainer.classList.add('d-none');
            remarksInput.removeAttribute('required');
            remarksInput.value = '';
        }
    }

    radioButtons.forEach(radio => {
        radio.addEventListener('change', toggleRemarksVisibility);
    });

    document.addEventListener("DOMContentLoaded", function() {
        toggleRemarksVisibility();
    });

    function showConfirmModal() {
        const form = document.getElementById('shipmentForm');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }

        const selectedRadio = document.querySelector('input[name="outcome"]:checked');
        const badge = document.getElementById('modalStatusBadge');
        
        badge.className = "badge fs-6 px-3 py-2 rounded-pill ";

        if (selectedRadio.value === 'PENDING_PICKUP') {
            badge.innerText = "Pending Pickup";
            badge.classList.add("bg-warning", "text-dark");
        } else if (selectedRadio.value === 'SHIPPING') {
            badge.innerText = "In Transit";
            badge.classList.add("bg-primary", "text-white");
        } else if (selectedRadio.value === 'SUCCESS') {
            badge.innerText = "Success";
            badge.classList.add("bg-success", "text-white");
        } else if (selectedRadio.value === 'FAILURE') {
            badge.innerText = "Failure";
            badge.classList.add("bg-danger", "text-white");
        }

        bootstrapModal = new bootstrap.Modal(document.getElementById('confirmModal'));
        bootstrapModal.show();
    }

    function submitForm() {
        if (bootstrapModal) {
            bootstrapModal.hide();
        }
        document.getElementById('shipmentForm').submit();
    }
</script>
</body>
</html>
