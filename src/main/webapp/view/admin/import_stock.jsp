<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Create Stock Import - Admin Area</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet"/>
        <style>
            body {
                background-color: #f8f9fa;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            .wrapper {
                display: flex;
                width: 100%;
                align-items: stretch;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                min-height: 100vh;
                background-color: #f8f9fa;
            }
            .form-label {
                font-weight: 600;
                color: #374151;
                margin-bottom: 0.4rem;
            }
        </style>
    </head>
    <body>
        <div class="wrapper">
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <div class="container-fluid">

                    <div class="mb-4">
                        <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-arrow-left me-2"></i>Back to Stock Logs
                        </a>
                    </div>

                    <c:if test="${param.status eq 'error'}">
                        <div class="alert alert-danger"><strong>Error!</strong> Transaction failed to commit database. Please try again.</div>
                    </c:if>
                    <c:if test="${param.status eq 'invalid'}">
                        <div class="alert alert-warning"><strong>Invalid Input!</strong> Please check numeric formats or missing fields.</div>
                    </c:if>

                    <div class="row justify-content-center">
                        <div class="col-xl-8 col-lg-10">
                            <div class="card shadow-sm border-0 rounded-3 p-4">
                                <div class="border-bottom pb-3 mb-4">
                                    <h4 class="fw-bold text-dark mb-1"><i class="fa-solid fa-square-plus me-2 text-success"></i>New Stock Inflow Import</h4>
                                    <p class="text-muted small mb-0">Add real physical inventory batches to a specific product variant SKU</p>
                                </div>

                                <form action="${pageContext.request.contextPath}/admin/inventory?action=create" method="POST">

                                    <div class="mb-4">
                                        <label class="form-label">Select Variant ID *</label>
                                        <input type="number" name="variantId" class="form-control" placeholder="Enter Variant Database ID (e.g., 1, 2, 3...)" required />
                                        <div class="form-text">Currently, enter the exact ID from Product Variant table. This updates stock directly for that SKU.</div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label">Batch Code *</label>
                                        <input type="text" id="batchCode" name="batchCode" class="form-control bg-light fw-bold text-primary" readonly required />
                                        <div class="form-text">This system auto-generates a unique code for tracking FIFO constraints.</div>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label class="form-label">Initial Quantity *</label>
                                            <input type="number" name="quantity" class="form-control" placeholder="e.g., 100" min="1" required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Cost Price ($) *</label>
                                            <input type="number" name="costPrice" class="form-control" placeholder="e.g., 15.50" step="0.01" min="0" required />
                                        </div>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label class="form-label">New Sale Price ($) *</label>
                                            <input type="number" name="salePrice" class="form-control" placeholder="e.g., 29.99" step="0.01" min="0" required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Transaction Note</label>
                                            <input type="text" name="note" class="form-control" placeholder="e.g., Summer batch import from Supplier A" />
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 border-top pt-3 mt-4">
                                        <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-light px-4">Cancel</a>
                                        <button type="submit" class="btn btn-success px-4">Confirm & Process Import</button>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var now = new Date();
                var year = now.getFullYear();
                var month = String(now.getMonth() + 1).padStart(2, '0');
                var day = String(now.getDate()).padStart(2, '0');
                var hours = String(now.getHours()).padStart(2, '0');
                var minutes = String(now.getMinutes()).padStart(2, '0');

                // Tạo chuỗi Batch Code chuẩn ERP: BATCH-YYYYMMDD-HHMM
                var generatedCode = "BATCH-" + year + month + day + "-" + hours + minutes;
                document.getElementById("batchCode").value = generatedCode;
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>