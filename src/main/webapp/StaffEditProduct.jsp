<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clothingsale.model.StaffProductModel" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Edit Product</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper { display: flex; min-height: 100vh; }
        .content-area { flex: 1; padding: 28px 32px; min-width: 0; }

        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); max-width: 860px; margin: 0 auto; }
        .card-main .card-header {
            background: #fafbff;
            border-bottom: 1px solid #eef0f5;
            border-radius: 14px 14px 0 0 !important;
            padding: 20px 24px;
        }
        .card-main .card-footer {
            background: #fafbff;
            border-top: 1px solid #eef0f5;
            border-radius: 0 0 14px 14px !important;
            padding: 16px 24px;
        }

        .field-label {
            font-size: .75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #9ca3af;
            margin-bottom: 6px;
        }
        .field-label.required { color: #6b7280; }

        .field-readonly {
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: .9rem;
            color: #6b7280;
            font-weight: 600;
            user-select: none;
        }
        .field-readonly.mono { font-family: monospace; }

        .form-control:focus {
            border-color: #5c6bc0;
            box-shadow: 0 0 0 3px rgba(92,107,192,.15);
        }

        .badge-active   { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fee2e2; color: #991b1b; }

        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>

<%
    StaffProductModel product = (StaffProductModel) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("StaffManageProducts");
        return;
    }
    String statusClass = "ACTIVE".equals(product.getStatus()) ? "badge-active" : "badge-inactive";
%>

<div class="main-wrapper">

    <jsp:include page="/view/admin/sidebar.jsp">
        <jsp:param name="activeTab" value="products"/>
    </jsp:include>

    <div class="content-area">

        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="StaffManageProducts">Product Management</a></li>
                <li class="breadcrumb-item active">Edit Product</li>
            </ol>
        </nav>

        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
            <h1 class="page-title"><i class="bi bi-pencil-square"></i>Edit Product</h1>
            <a href="StaffManageProducts" class="btn btn-outline-secondary btn-sm px-3">
                <i class="bi bi-arrow-left me-1"></i>Back to list
            </a>
        </div>

        <form action="StaffManageProducts" method="POST">
            <input type="hidden" name="sku" value="<%= product.getSku() %>"/>
            <input type="hidden" name="variantId" value="<%= product.getVariantId() %>"/>

            <div class="card card-main">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <div class="fw-bold text-dark" style="font-size:1rem;">Update product information</div>
                        <div class="text-muted mt-1" style="font-size:.82rem;">Edit only the fields that your role is allowed to change</div>
                    </div>
                    <span class="badge px-3 py-2 rounded-pill <%= statusClass %>">
                        <%= product.getStatus() %>
                    </span>
                </div>

                <div class="card-body p-4">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="field-label required">Product Name <span class="text-danger">*</span></div>
                            <input type="text" name="productName" value="<%= product.getProductName() %>" required
                                   class="form-control fw-semibold"/>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Listed Sale Price (VND) <span class="text-danger">*</span></div>
                            <input type="number" name="salePrice" value="<%= (long)product.getSalePrice().doubleValue() %>"
                                   min="0" required class="form-control fw-bold"/>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">SKU (read only)</div>
                            <div class="field-readonly mono"><%= product.getSku() %></div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Purchase Cost (read only)</div>
                            <div class="field-readonly"><%= (long)product.getCostPrice().doubleValue() %> VND</div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Brand (read only)</div>
                            <div class="field-readonly"><%= product.getBrandName() %></div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Stock Quantity (read only)</div>
                            <div class="field-readonly"><%= product.getStockQuantity() %> units</div>
                        </div>
                    </div>
                </div>

                <div class="card-footer d-flex justify-content-end gap-2">
                    <a href="StaffManageProducts" class="btn btn-outline-secondary px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4">
                        <i class="bi bi-cloud-arrow-up-fill me-1"></i>Save Changes
                    </button>
                </div>
            </div>
        </form>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
