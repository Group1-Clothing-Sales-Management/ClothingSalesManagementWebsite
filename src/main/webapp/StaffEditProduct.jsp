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
        html, body { height: 100%; overflow: hidden; }
        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper { display: flex; height: 100vh; overflow: hidden; }
        .content-area { flex: 1; padding: 28px 32px; min-width: 0; height: 100vh; overflow-y: auto; }

        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); max-width: 860px; margin: 0 auto; }
        
        .card-main .card-header {
            background: #212529;
            border-radius: 14px 14px 0 0 !important;
            padding: 20px 24px;
            color: #ffffff;
        }
        
        .card-main .card-footer {
            background: #fafbff;
            border-top: 1px solid #eef0f5;
            border-radius: 0 0 14px 14px !important;
            padding: 16px 24px;
        }

        .field-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; color: #9ca3af; margin-bottom: 6px; }
        .field-readonly { background: #f3f4f6; border: 1px solid #e5e7eb; border-radius: 8px; padding: 10px 14px; font-size: .9rem; color: #6b7280; font-weight: 600; }
        .field-readonly.mono { font-family: monospace; }
        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
        .badge-active { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>

<%
    StaffProductModel product = (StaffProductModel) request.getAttribute("product");
    if (product == null) { response.sendRedirect("StaffManageProducts"); return; }
    String statusClass = "ACTIVE".equals(product.getStatus()) ? "badge-active" : "badge-inactive";
%>

<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="products"/>
</jsp:include>
        <div class="admin-page">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="StaffManageProducts">Product Management</a></li>
                <li class="breadcrumb-item active">Edit Product</li>
            </ol>
        </nav>

        <div class="d-flex align-items-center justify-content-between mb-4">
            <h1 class="page-title"><i class="bi bi-pencil-square"></i>Edit Product</h1>
        </div>

        <form action="StaffManageProducts" method="POST">
            <input type="hidden" name="sku" value="<%= product.getSku() %>"/>
            <input type="hidden" name="variantId" value="<%= product.getVariantId() %>"/>

            <div class="card card-main">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <div class="fw-bold" style="font-size:1rem;">Update product information</div>
                        <div class="text-white-50 mt-1" style="font-size:.82rem;">Edit only the fields that your role is allowed to change</div>
                    </div>
                    <span class="badge px-3 py-2 rounded-pill <%= statusClass %>"><%= product.getStatus() %></span>
                </div>

                <div class="card-body p-4">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="field-label">Product Name</div>
                            <input type="text" name="productName" value="<%= product.getProductName() %>" required class="form-control fw-semibold"/>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">SKU</div>
                            <div class="field-readonly mono"><%= product.getSku() %></div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Color</div>
                            <input type="text" name="color" value="<%= product.getColor() != null ? product.getColor() : "" %>" class="form-control"/>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Size</div>
                            <select name="size" class="form-select">
                                <%
                                    String[] sizes = {"XS","S","M","L","XL","XXL","XXXL"};
                                    String currentSize = product.getSize() != null ? product.getSize().trim() : "";
                                    for (String s : sizes) {
                                %>
                                <option value="<%= s %>" <%= s.equalsIgnoreCase(currentSize) ? "selected" : "" %>><%= s %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Purchase Cost</div>
                            <div class="field-readonly"><%= (long)product.getCostPrice().doubleValue() %> VND</div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Sale Price</div>
                            <div class="field-readonly"><%= (long)product.getSalePrice().doubleValue() %> VND</div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Brand</div>
                            <div class="field-readonly"><%= product.getBrandName() %></div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-label">Stock Quantity</div>
                            <div class="field-readonly"><%= product.getStockQuantity() %> units</div>
                        </div>
                    </div>
                </div>

                <div class="card-footer d-flex justify-content-end gap-2">
                    <a href="StaffManageProducts" class="btn btn-outline-secondary px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4"><i class="bi bi-cloud-arrow-up-fill me-1"></i>Save Changes</button>
                </div>
            </div>
        </form>
        </div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
