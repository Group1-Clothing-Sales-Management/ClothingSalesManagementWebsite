<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Create New Voucher - Admin</title>
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

            <div class="main-content admin-page">
                <div class="mb-3">
                <a href="${pageContext.request.contextPath}/admin/voucher" class="btn btn-sm btn-secondary">&larr; Back to Voucher List</a>
            </div>
                <div class="container-fluid">

                    <div class="page-header">
                        <div>
                            <h2 class="page-title">Create New Voucher</h2>
                            <p class="page-subtitle mb-0">Configure a new discount campaign for the store</p>
                        </div>
                    </div>

                    <c:if test="${not empty successMessage}">
                        <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMessage}"/></div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                    </c:if>

                    <div class="card card-main admin-card">
                        <div class="card-body p-4">
                            <form action="${pageContext.request.contextPath}/admin/voucher" method="POST" id="voucherForm">

                                <div class="row">
                                    <div class="form-group col-md-6">
                                        <label for="code" class="font-weight-bold">Voucher Code <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="fas fa-tag text-muted"></i></span>
                                            </div>
                                            <input type="text" class="form-control text-uppercase font-weight-bold" id="code" name="code" 
                                                   required placeholder="e.g., SUMMER2026" value="${oldVoucher.code}">
                                        </div>
                                        <small class="text-muted">No spaces or special characters. Automatically capitalized.</small>
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="title" class="font-weight-bold">Campaign Title <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="title" name="title" 
                                               required placeholder="e.g., Summer Beach Sale 2026" value="${oldVoucher.title}">
                                        <small class="text-muted">Public campaign name visible to customers.</small>
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <div class="form-group col-md-4">
                                        <label for="discountType" class="font-weight-bold">Discount Type <span class="text-danger">*</span></label>
                                        <select class="form-control" id="discountType" name="discountType" onchange="toggleDiscountFields()">
                                            <option value="PERCENTAGE" ${oldVoucher.discountType == 'PERCENTAGE' ? 'selected' : ''}>Percentage (%)</option>
                                            <option value="FIXED_AMOUNT" ${oldVoucher.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed Amount (đ)</option>
                                        </select>
                                    </div>

                                    <div class="form-group col-md-4">
                                        <label for="discountValue" class="font-weight-bold">Discount Value <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="discountValue" name="discountValue" 
                                               required min="1" step="any" placeholder="Value..." value="${oldVoucher.discountValue}">
                                    </div>

                                    <div class="form-group col-md-4" id="maxDiscountGroup">
                                        <label for="maxDiscountAmount" class="font-weight-bold">Max Discount Amount (đ) <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" 
                                               min="0" placeholder="Caps the maximum discount value" value="${oldVoucher.maxDiscountAmount}">
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <div class="form-group col-md-6">
                                        <label for="minOrderValue" class="font-weight-bold">Min Order Value (đ)</label>
                                        <input type="number" class="form-control" id="minOrderValue" name="minOrderValue" 
                                               min="0" placeholder="Minimum required cart total (default: 0)" 
                                               value="${oldVoucher.minOrderValue != null ? oldVoucher.minOrderValue : 0}">
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="usageLimit" class="font-weight-bold">Total Usage Limit <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="usageLimit" name="usageLimit" 
                                               required min="1" placeholder="Total vouchers available for issue" value="${oldVoucher.usageLimit}">
                                    </div>
                                </div>

                                <div class="row mt-3">
                                    <div class="form-group col-md-6">
                                        <label for="startDate" class="font-weight-bold">Start Date & Time <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="far fa-calendar-alt text-muted"></i></span>
                                            </div>
                                            <input type="datetime-local" class="form-control" id="startDate" name="startDate" required>
                                        </div>
                                    </div>

                                    <div class="form-group col-md-6">
                                        <label for="endDate" class="font-weight-bold">End Date & Time <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="far fa-calendar-times text-muted"></i></span>
                                            </div>
                                            <input type="datetime-local" class="form-control" id="endDate" name="endDate" required>
                                        </div>
                                    </div>
                                </div>

                                <hr class="my-4">

                                <div class="d-flex justify-content-end">
                                    <button type="reset" class="btn btn-light border font-weight-bold px-4 mr-2" onclick="setTimeout(toggleDiscountFields, 50)">
                                        Reset Form
                                    </button>
                                    <button type="submit" class="btn btn-primary font-weight-bold px-5">
                                        <i class="fas fa-save mr-2"></i> Save Voucher
                                    </button>
                                </div>

                            </form>
                        </div>
                    </div>

                </div>
            </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <script>
            function toggleDiscountFields() {
                var type = document.getElementById("discountType").value;
                var maxDiscountGroup = document.getElementById("maxDiscountGroup");
                var maxDiscountInput = document.getElementById("maxDiscountAmount");

                if (type === "FIXED_AMOUNT") {
                    maxDiscountGroup.style.display = "none";
                    maxDiscountInput.removeAttribute("required");
                    maxDiscountInput.value = "";
                } else {
                    maxDiscountGroup.style.display = "block";
                    maxDiscountInput.setAttribute("required", "required");
                }
            }

            // Run layout adjustments when error payloads are thrown back from back-end
            window.onload = function () {
                toggleDiscountFields();
            };

            // Client-side date comparison to reduce wrong submissions
            document.getElementById("voucherForm").addEventListener("submit", function (event) {
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
