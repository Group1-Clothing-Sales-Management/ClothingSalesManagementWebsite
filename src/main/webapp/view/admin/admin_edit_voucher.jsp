<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit Voucher - Admin</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        <style>
            .wrapper {
                display: flex;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                background-color: #f4f6f9;
                min-height: 100vh;
            }
            .card {
                border: none;
                border-radius: 8px;
                box-shadow: 0 0 15px rgba(0,0,0,0.05);
            }
            .form-group label {
                color: #495057;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="discounts" />
        </jsp:include>

            <div class="main-content">
                <div class="container-fluid">

                    <jsp:useBean id="now" class="java.util.Date" />
                    <c:set var="isActive" value="${now.time >= voucher.startDate.time && now.time <= voucher.endDate.time}" />
                    <c:set var="isExpired" value="${now.time > voucher.endDate.time || voucher.usedCount >= voucher.usageLimit}" />

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h2 class="font-weight-bold">Edit Voucher: ${voucher.code}</h2>
                            <p class="text-muted mb-0">Modify information for an existing discount campaign</p>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show card p-3 mb-4 border-left border-danger" role="alert">
                            <i class="fas fa-exclamation-circle mr-2"></i> ${errorMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <div class="card">
                        <div class="card-body p-4">
                            <form action="${pageContext.request.contextPath}/admin/voucher" method="POST" id="editVoucherForm">
                                <input type="hidden" name="id" value="${voucher.id}">
                                <input type="hidden" name="code" value="${voucher.code}">

                                <div class="row">
                                    <div class="form-group col-md-6">
                                        <label class="font-weight-bold">Voucher Code</label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="fas fa-lock text-muted"></i></span>
                                            </div>
                                            <input type="text" class="form-control font-weight-bold bg-light" value="${voucher.code}" disabled>
                                        </div>
                                        <small class="text-muted">Voucher codes cannot be modified after initial creation.</small>
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="title" class="font-weight-bold">Campaign Title <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="title" name="title" 
                                               required value="${voucher.title}" ${isExpired ? 'disabled' : ''}>
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <div class="form-group col-md-4">
                                        <label for="discountType" class="font-weight-bold">Discount Type</label>
                                        <c:choose>
                                            <c:when test="${isActive || isExpired}">
                                                <input type="hidden" name="discountType" value="${voucher.discountType}">
                                                <input type="text" class="form-control bg-light" value="${voucher.discountType == 'PERCENTAGE' ? 'Percentage (%)' : 'Fixed Amount (đ)'}" disabled>
                                            </c:when>
                                            <c:otherwise>
                                                <select class="form-control" id="discountType" name="discountType" onchange="toggleDiscountFields()">
                                                    <option value="PERCENTAGE" ${voucher.discountType == 'PERCENTAGE' ? 'selected' : ''}>Percentage (%)</option>
                                                    <option value="FIXED_AMOUNT" ${voucher.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed Amount (đ)</option>
                                                </select>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="form-group col-md-4">
                                        <label for="discountValue" class="font-weight-bold">Discount Value</label>
                                        <input type="number" class="form-control" id="discountValue" name="discountValue" required min="1" step="any" 
                                               value="${voucher.discountValue}" ${(isActive || isExpired) ? 'readonly style="background-color: #e9ecef;"' : ''}>
                                    </div>

                                    <div class="form-group col-md-4" id="maxDiscountGroup">
                                        <label for="maxDiscountAmount" class="font-weight-bold">Max Discount Amount (đ)</label>
                                        <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" min="0" 
                                               value="${voucher.maxDiscountAmount}" ${(isActive || isExpired) ? 'readonly style="background-color: #e9ecef;"' : ''}>
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <div class="form-group col-md-6">
                                        <label for="minOrderValue" class="font-weight-bold">Min Order Value (đ)</label>
                                        <input type="number" class="form-control" id="minOrderValue" name="minOrderValue" min="0" 
                                               value="${voucher.minOrderValue}" ${(isActive || isExpired) ? 'readonly style="background-color: #e9ecef;"' : ''}>
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="usageLimit" class="font-weight-bold">Total Usage Limit <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="usageLimit" name="usageLimit" required min="1" 
                                               value="${voucher.usageLimit}" ${isExpired ? 'disabled' : ''}>
                                        <small class="text-info font-weight-bold">Current Usage Progress: ${voucher.usedCount} used.</small>
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <fmt:formatDate var="formattedStart" value="${voucher.startDate}" pattern="yyyy-MM-dd'T'HH:mm" />
                                    <fmt:formatDate var="formattedEnd" value="${voucher.endDate}" pattern="yyyy-MM-dd'T'HH:mm" />

                                    <div class="form-group col-md-6">
                                        <label for="startDate" class="font-weight-bold">Start Date & Time</label>
                                        <input type="datetime-local" class="form-control" id="startDate" name="startDate" required 
                                               value="${formattedStart}" ${(isActive || isExpired) ? 'readonly style="background-color: #e9ecef;"' : ''}>
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="endDate" class="font-weight-bold">End Date & Time <span class="text-danger">*</span></label>
                                        <input type="datetime-local" class="form-control" id="endDate" name="endDate" required 
                                               value="${formattedEnd}" ${isExpired ? 'disabled' : ''}>
                                    </div>
                                </div>

                                <hr class="my-4">

                                <div class="d-flex justify-content-end">
                                    <c:if test="${!isExpired}">
                                        <button type="submit" class="btn btn-primary font-weight-bold px-5">
                                            <i class="fas fa-save mr-2"></i> Update Voucher
                                        </button>
                                    </c:if>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>
            </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <script>
            function toggleDiscountFields() {
                var type = document.getElementById("discountType");
                if (!type)
                    return; // Dropdown is completely frozen from display mutations

                var maxDiscountGroup = document.getElementById("maxDiscountGroup");
                var maxDiscountInput = document.getElementById("maxDiscountAmount");

                if (type.value === "FIXED_AMOUNT") {
                    maxDiscountGroup.style.display = "none";
                    maxDiscountInput.removeAttribute("required");
                } else {
                    maxDiscountGroup.style.display = "block";
                    maxDiscountInput.setAttribute("required", "required");
                }
            }

            window.onload = function () {
                toggleDiscountFields();
            };

            document.getElementById("editVoucherForm").addEventListener("submit", function (event) {
                var start = new Date(document.getElementById("startDate").value);
                var end = new Date(document.getElementById("endDate").value);

                if (end <= start) {
                    alert("Validation Error: End Date & Time must occur after the Start Date & Time.");
                    event.preventDefault();
                }
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
