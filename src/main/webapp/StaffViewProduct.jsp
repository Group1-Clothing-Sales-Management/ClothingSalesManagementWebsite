<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clothingsale.model.StaffProductModel" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Product Details</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        /* Khoa chieu cao trang de sidebar va noi dung co thanh cuon rieng. */
        html, body {
            height: 100%;
            overflow: hidden;
        }

        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper {
            display: flex;
            height: 100vh;
            overflow: hidden;
        }
        .content-area {
            flex: 1;
            padding: 28px 32px;
            min-width: 0;
            height: 100vh;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); }
        .card-main .card-header {
            background: #fff;
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
        .field-value {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: .9rem;
            color: #1e293b;
        }
        .field-value.mono { font-family: monospace; font-weight: 700; color: #6b7280; }
        .field-value.price-main { font-size: 1.1rem; font-weight: 700; color: #1e293b; }

        .brand-badge {
            background: #eef2ff;
            color: #4338ca;
            font-size: .8rem;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 5px;
            display: inline-block;
        }

        .badge-active   { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fee2e2; color: #991b1b; }
        .badge-stock-ok  { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .badge-stock-out { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

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
    NumberFormat numFormat = NumberFormat.getNumberInstance(Locale.US);
    String stockClass  = product.getStockQuantity() > 0 ? "badge-stock-ok" : "badge-stock-out";
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
                <li class="breadcrumb-item active">Product Details</li>
            </ol>
        </nav>

        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
            <h1 class="page-title"><i class="bi bi-box-seam-fill"></i>Product Details</h1>
            <a href="StaffManageProducts" class="btn btn-outline-secondary btn-sm px-3">
                <i class="bi bi-arrow-left me-1"></i>Back to list
            </a>
        </div>

        <div class="card card-main" style="max-width: 960px; margin: 0 auto;">
            <div class="card-header d-flex align-items-center justify-content-between">
                <div>
                    <div class="fw-bold text-dark" style="font-size:1rem;">Current detail data for the selected variant</div>
                    <div class="text-muted mt-1" style="font-size:.82rem;">Read-only view — use Edit to make changes</div>
                </div>
                <span class="badge px-3 py-2 rounded-pill <%= statusClass %>">
                    <%= product.getStatus() %>
                </span>
            </div>

            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="field-label">Product Name</div>
                        <div class="field-value fw-semibold"><%= product.getProductName() %></div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">SKU</div>
                        <div class="field-value mono"><%= product.getSku() %></div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Brand</div>
                        <div class="field-value">
                            <span class="brand-badge"><%= product.getBrandName() %></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Stock Quantity</div>
                        <div class="field-value">
                            <span class="badge px-3 py-2 rounded-pill <%= stockClass %>">
                                <%= product.getStockQuantity() %> units
                            </span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Cost Price</div>
                        <div class="field-value text-muted"><%= numFormat.format(product.getCostPrice()) %> VND</div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Sale Price</div>
                        <div class="field-value price-main"><%= numFormat.format(product.getSalePrice()) %> VND</div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Color</div>
                        <div class="field-value">
                            <% if (product.getColor() != null && !product.getColor().isEmpty()) { %>
                                <span class="badge rounded-pill px-3 py-2" style="background:#eef2ff;color:#4338ca;font-size:.85rem;">
                                    <i class="bi bi-palette-fill me-1"></i><%= product.getColor() %>
                                </span>
                            <% } else { %>
                                <span class="text-muted">—</span>
                            <% } %>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-label">Size</div>
                        <div class="field-value">
                            <% if (product.getSize() != null && !product.getSize().isEmpty()) { %>
                                <span class="badge rounded-pill px-3 py-2" style="background:#f0fdf4;color:#166534;font-size:.85rem;">
                                    <i class="bi bi-tag-fill me-1"></i><%= product.getSize() %>
                                </span>
                            <% } else { %>
                                <span class="text-muted">—</span>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card-footer d-flex justify-content-end gap-2">
                <a href="StaffManageProducts" class="btn btn-outline-secondary px-4">Close</a>
                <a href="StaffManageProducts?action=edit&sku=<%= product.getSku() %>"
                   class="btn btn-warning px-4 text-white">
                    <i class="bi bi-pencil-fill me-1"></i>Edit Product
                </a>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
