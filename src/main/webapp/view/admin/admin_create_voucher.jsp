<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Create New Voucher - Admin Panel</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
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

        <div class="admin-page voucher-form-page">
            <div class="container-fluid">

                <div class="page-header">
                    <jsp:include page="/view/admin/common/page_heading.jsp">
                        <jsp:param name="icon" value="fa-solid fa-ticket"/>
                        <jsp:param name="title" value="Create New Voucher"/>
                        <jsp:param name="subtitle" value="Configure a new promotional discount campaign for the store."/>
                    </jsp:include>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="success"><c:out value="${successMessage}"/></div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                </c:if>

                <div class="card admin-card">
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="POST" id="voucherForm">
                            <input type="hidden" name="action" value="create">

                            <div class="row g-3">
                                <div class="form-group col-md-6">
                                    <label for="code" class="fw-bold">Voucher Code <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fa-solid fa-tag text-muted"></i></span>
                                        <input type="text" class="form-control text-uppercase fw-bold" id="code" name="code" 
                                               required placeholder="e.g., SUMMER2026" value="${oldVoucher.code}">
                                    </div>
                                    <small class="text-muted">No spaces or special characters allowed. Automatically capitalized.</small>
                                </div>

                                <div class="form-group col-md-6">
                                    <label for="title" class="fw-bold">Campaign Title <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="title" name="title" 
                                           required placeholder="e.g., Summer Beach Flash Sale 2026" value="${oldVoucher.title}">
                                    <small class="text-muted">Public campaign name displayed transparently to customers.</small>
                                </div>
                            </div>

                            <div class="row g-3 mt-0">
                                <div class="form-group col-md-4">
                                    <label for="discountType" class="fw-bold">Discount Type <span class="text-danger">*</span></label>
                                    <select class="form-select" id="discountType" name="discountType" onchange="toggleDiscountFields()">
                                        <option value="PERCENTAGE" ${oldVoucher.discountType == 'PERCENTAGE' ? 'selected' : ''}>Percentage (%)</option>
                                        <option value="FIXED_AMOUNT" ${oldVoucher.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed Amount (₫)</option>
                                    </select>
                                </div>

                                <div class="form-group col-md-4">
                                    <label for="discountValue" class="fw-bold">Discount Value <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="discountValue" name="discountValue" 
                                           required min="1" step="any" placeholder="Enter value..." value="${oldVoucher.discountValue}">
                                </div>

                                <div class="form-group col-md-4" id="maxDiscountGroup">
                                    <label for="maxDiscountAmount" class="fw-bold">Max Discount Limit (₫) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" 
                                           min="0" step="1" placeholder="Caps the maximum reward deduction" value="${oldVoucher.maxDiscountAmount}">
                                </div>
                            </div>

                            <div class="row g-3 mt-0">
                                <div class="form-group col-md-3">
                                    <label for="minOrderValue" class="fw-bold">Min Order Value (₫)</label>
                                    <input type="number" class="form-control" id="minOrderValue" name="minOrderValue" 
                                           min="0" step="1" placeholder="Minimum required basket cost"
                                           value="${oldVoucher.minOrderValue != null ? oldVoucher.minOrderValue : 0}">
                                </div>

                                <div class="form-group col-md-3">
                                    <label for="usageLimit" class="fw-bold">Total Supply Limit <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="usageLimit" name="usageLimit" 
                                           required min="1" placeholder="Total vouchers pool size" value="${oldVoucher.usageLimit}">
                                </div>

                                <div class="form-group col-md-3">
                                    <label for="limitPerUser" class="fw-bold">Limit Per Customer <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="limitPerUser" name="limitPerUser" 
                                           required min="1" placeholder="Max usage per account" value="${oldVoucher.limitPerUser != null ? oldVoucher.limitPerUser : 1}">
                                </div>

                                <div class="form-group col-md-3">
                                    <label for="categoryId" class="fw-bold">Applicable Scope</label>
                                    <select class="form-select" id="categoryId" name="categoryId">
                                        <option value="ALL">Entire Store (Global Scope)</option>
                                        <c:forEach var="cat" items="${categoryList}">
                                            <option value="${cat.id}" ${oldVoucher.categoryId == cat.id ? 'selected' : ''}>Category: ${cat.categoryName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="row g-3 mt-0">
                                <div class="form-group col-md-6">
                                    <label for="startDate" class="fw-bold">Start Date & Time <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fa-regular fa-calendar-alt text-muted"></i></span>
                                        <input type="datetime-local" class="form-control" id="startDate" name="startDate" required>
                                    </div>
                                </div>

                                <div class="form-group col-md-6">
                                    <label for="endDate" class="fw-bold">End Date & Time <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fa-regular fa-calendar-times text-muted"></i></span>
                                        <input type="datetime-local" class="form-control" id="endDate" name="endDate" required>
                                    </div>
                                </div>
                            </div>

                            <hr class="my-4">

                            <div class="admin-form-actions">
                                <button type="reset" class="btn btn-light border fw-bold px-4 me-2" onclick="setTimeout(toggleDiscountFields, 50)">
                                    Reset Form
                                </button>
                                <button type="submit" class="btn btn-primary fw-bold px-5">
                                    <i class="fa-solid fa-save me-2"></i> Save Campaign
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
                var discountInput = document.getElementById("discountValue");
                var maxDiscountGroup = document.getElementById("maxDiscountGroup");
                var maxDiscountInput = document.getElementById("maxDiscountAmount");
                discountInput.step = type === "FIXED_AMOUNT" ? "1" : "0.01";

                if (type === "FIXED_AMOUNT") {
                    maxDiscountGroup.style.display = "none";
                    maxDiscountInput.removeAttribute("required");
                    maxDiscountInput.value = "";
                } else {
                    maxDiscountGroup.style.display = "block";
                    maxDiscountInput.setAttribute("required", "required");
                }
            }

            window.onload = function () {
                toggleDiscountFields();
            };

            document.getElementById("voucherForm").addEventListener("submit", function (event) {
                var start = new Date(document.getElementById("startDate").value);
                var end = new Date(document.getElementById("endDate").value);

                if (end <= start) {
                    window.showAppToast("Campaign end date and time must occur after the start date and time.", "error", {title: "Validation error"});
                    event.preventDefault();
                }
            });
            function toggleDiscountFields() {
                var type = document.getElementById("discountType").value;
                var discountInput = document.getElementById("discountValue");
                var maxDiscountGroup = document.getElementById("maxDiscountGroup");
                var maxDiscountInput = document.getElementById("maxDiscountAmount");
                discountInput.step = type === "FIXED_AMOUNT" ? "1" : "0.01";

                if (type === "FIXED_AMOUNT") {
                    maxDiscountGroup.style.display = "none";
                    maxDiscountInput.removeAttribute("required");
                    maxDiscountInput.value = "";
                } else {
                    maxDiscountGroup.style.display = "block";
                    maxDiscountInput.setAttribute("required", "required");
                }
            }

            window.onload = function () {
                toggleDiscountFields();
            };
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
