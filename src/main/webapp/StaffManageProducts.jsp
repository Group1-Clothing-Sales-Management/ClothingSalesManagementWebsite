<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.clothingsale.model.StaffProductModel" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <style>
        html, body { height: 100%; overflow: hidden; }
        body { background: #f5f6fa; font-family: 'Segoe UI', sans-serif; }
        .main-wrapper { display: flex; height: 100vh; overflow: hidden; }
        .content-area { flex: 1; padding: 28px 32px; min-width: 0; height: 100vh; overflow-y: auto; }

        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .search-bar-wrapper {
            background: #fff;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .search-bar-wrapper .form-control, .search-bar-wrapper .form-select {
            border: 1px solid #ced4da;
            border-radius: 6px;
        }
        .search-bar-wrapper .form-control {
            flex: 1;
        }
        .search-bar-wrapper .btn-primary {
            background-color: #0d6efd;
            border: none;
            padding: 8px 24px;
            font-weight: 500;
        }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); }
        .table thead th {
            background: #212529;
            color: #fff;
            font-weight: 600;
            font-size: .85rem;
            border: none;
            white-space: nowrap;
        }
        .table tbody tr:hover { background: #f0f4ff; }
        .table td { vertical-align: middle; font-size: .9rem; }

        .badge-active   { background: #d1fae5; color: #065f46; }
        .badge-inactive { background: #fee2e2; color: #991b1b; }
        .badge-stock-ok  { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .badge-stock-out { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        .brand-badge {
            background: #eef2ff;
            color: #4338ca;
            font-size: .75rem;
            font-weight: 600;
            padding: 2px 8px;
            border-radius: 4px;
            display: inline-block;
            margin-top: 3px;
        }
        .empty-state { padding: 56px 0; text-align: center; color: #9ca3af; }
        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>
<div class="main-wrapper">
    <jsp:include page="/view/admin/sidebar.jsp"><jsp:param name="activeTab" value="products"/></jsp:include>

    <div class="content-area">
        <nav aria-label="breadcrumb"><ol class="breadcrumb"><li class="breadcrumb-item active">Product Management</li></ol></nav>
        <div class="page-header"><h1 class="page-title"><i class="bi bi-box-seam-fill"></i>Product Management</h1></div>

        <div class="search-bar-wrapper">
            <input type="text" id="searchInput" onkeyup="filterProducts()" class="form-control" placeholder="Search by product name..."/>
            <button class="btn btn-primary" type="button">Search & Filter</button>
        </div>

        <div class="card card-main">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Product & Brand</th>
                                <th class="text-center">Color / Size</th>
                                <th class="text-center">Stock</th>
                                <th class="text-center">Status</th>
                                <th class="text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="productTable">
                            <%
                                List<StaffProductModel> products = (List<StaffProductModel>) request.getAttribute("productList");
                                if (products == null || products.isEmpty()) {
                            %>
                            <tr><td colspan="6"><div class="empty-state"><i class="bi bi-box-seam"></i><p>No products available</p></div></td></tr>
                            <%
                                } else {
                                    int index = 1;
                                    for (StaffProductModel item : products) {
                                        String stockClass = item.getStockQuantity() > 0 ? "badge-stock-ok" : "badge-stock-out";
                                        String statusClass = "ACTIVE".equals(item.getStatus()) ? "badge-active" : "badge-inactive";
                            %>
                            <tr>
                                <td class="text-muted"><%= index++ %></td>
                                <td>
                                    <div class="fw-semibold text-dark product-name"><%= item.getProductName() %></div>
                                    <span class="brand-badge"><%= item.getBrandName() %></span>
                                </td>
                                <td class="text-center">
                                    <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;"><%= item.getColor() %></span>
                                    <span class="badge rounded-pill ms-1" style="background:#f0fdf4;color:#166534;"><%= item.getSize() %></span>
                                </td>
                                <td class="text-center"><span class="badge px-2 py-1 rounded-pill <%= stockClass %>"><%= item.getStockQuantity() %></span></td>
                                <td class="text-center"><span class="badge px-2 py-1 rounded-pill <%= statusClass %>"><%= item.getStatus() %></span></td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/StaffManageProducts?action=view&sku=<%= item.getSku() %>" class="btn btn-sm btn-outline-info"><i class="bi bi-eye-fill"></i> View</a>
                                    <a href="${pageContext.request.contextPath}/StaffManageProducts?action=edit&sku=<%= item.getSku() %>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i> Edit</a>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filterProducts() {
        const filter = document.getElementById("searchInput").value.toLowerCase();
        const rows = document.getElementById("productTable").getElementsByTagName("tr");
        for (let i = 0; i < rows.length; i++) {
            const nameEl = rows[i].querySelector(".product-name");
            if (nameEl) {
                rows[i].style.display = (nameEl.textContent.toLowerCase().includes(filter)) ? "" : "none";
            }
        }
    }
</script>
</body>
</html>