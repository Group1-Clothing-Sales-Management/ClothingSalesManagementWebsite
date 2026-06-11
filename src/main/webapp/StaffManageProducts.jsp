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

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .page-title { font-size: 1.45rem; font-weight: 700; color: #1a1d23; margin: 0; }
        .page-title .bi { color: #5c6bc0; margin-right: 8px; }

        .card-main { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,.07); }
        .card-main .card-header {
            background: #fff;
            border-bottom: 1px solid #eef0f5;
            border-radius: 14px 14px 0 0 !important;
            padding: 18px 24px;
        }

        .table thead th {
            background: #5c6bc0;
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

        .search-bar-wrapper {
            background: #fff;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,.06);
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .search-bar-wrapper label {
            font-size: .88rem;
            font-weight: 600;
            color: #374151;
            white-space: nowrap;
            margin: 0;
        }
        .search-bar-wrapper .input-group {
            max-width: 420px;
            flex: 1;
        }
        .search-bar-wrapper .form-control {
            border-left: none;
            box-shadow: none;
        }
        .search-bar-wrapper .input-group-text {
            background: #fff;
            border-right: none;
        }
        .result-count {
            font-size: .82rem;
            color: #6b7280;
            margin-left: auto;
        }

        .empty-state { padding: 56px 0; text-align: center; color: #9ca3af; }
        .empty-state .bi { font-size: 2.8rem; display: block; margin-bottom: 12px; }

        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>
<div class="main-wrapper">

    <jsp:include page="/view/admin/sidebar.jsp">
        <jsp:param name="activeTab" value="products"/>
    </jsp:include>

    <div class="content-area">
        <%
            String errorMsg = (String) request.getAttribute("errorMessage");
            if (errorMsg != null) {
        %>
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span><%= errorMsg %></span>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <%
            String successMsg = (String) request.getAttribute("successMessage");
            if (successMsg != null) {
        %>
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
            <i class="bi bi-check-circle-fill"></i>
            <span><%= successMsg %></span>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item active">Product Management</li>
            </ol>
        </nav>

        <div class="page-header">
            <h1 class="page-title"><i class="bi bi-box-seam-fill"></i>Product Management</h1>
        </div>

        <!-- Search Bar -->
        <div class="search-bar-wrapper">
            <label for="searchInput"><i class="bi bi-search me-1 text-primary"></i>Search by name:</label>
            <div class="input-group input-group-sm">
                <span class="input-group-text"><i class="bi bi-type text-muted"></i></span>
                <input type="text" id="searchInput" onkeyup="filterProducts()"
                       class="form-control" placeholder="Enter product name..."/>
                <button class="btn btn-outline-secondary" type="button" onclick="clearSearch()" title="Clear">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
            <span class="result-count" id="resultCount"></span>
        </div>

        <div class="card card-main">
            <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                <span class="fw-semibold text-secondary" style="font-size:.9rem">
                    <i class="bi bi-list-ul me-1"></i>Product List
                </span>
            </div>

            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Product & Brand</th>
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
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <i class="bi bi-box-seam"></i>
                                        <p class="mb-0 fw-semibold">No products available</p>
                                        <p class="text-muted small mt-1">No product data has been recorded in the system yet.</p>
                                    </div>
                                </td>
                            </tr>
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
                                    <span class="badge px-2 py-1 rounded-pill <%= stockClass %>">
                                        <%= item.getStockQuantity() %>
                                    </span>
                                </td>
                                <td class="text-center">
                                    <span class="badge px-2 py-1 rounded-pill <%= statusClass %>">
                                        <%= item.getStatus() %>
                                    </span>
                                </td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/StaffManageProducts?action=view&sku=<%= item.getSku() %>"
   class="btn btn-sm btn-outline-info px-2 py-1" title="View details">
    <i class="bi bi-eye-fill"></i> View
</a>
                                    <a href="${pageContext.request.contextPath}/StaffManageProducts?action=edit&sku=<%= item.getSku() %>"
   class="btn btn-sm btn-outline-primary px-2 py-1" title="Edit">
    <i class="bi bi-pencil-fill"></i> Edit
</a>
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
    const totalRows = document.getElementById("productTable").querySelectorAll("tr[class=''], tr:not([class])").length;

    function filterProducts() {
        const filter = document.getElementById("searchInput").value.toLowerCase().trim();
        const rows   = document.getElementById("productTable").getElementsByTagName("tr");
        let visible  = 0;

        for (let i = 0; i < rows.length; i++) {
            const nameEl = rows[i].querySelector(".product-name");
            if (nameEl) {
                const name = nameEl.textContent || nameEl.innerText;
                const show = name.toLowerCase().includes(filter);
                rows[i].style.display = show ? "" : "none";
                if (show) visible++;
            }
        }

        const countEl = document.getElementById("resultCount");
        if (filter === "") {
            countEl.textContent = "";
        } else {
            countEl.textContent = visible + " result(s) found";
        }
    }

    function clearSearch() {
        document.getElementById("searchInput").value = "";
        filterProducts();
    }

    document.querySelectorAll('.alert').forEach(function (el) {
        setTimeout(function () {
            bootstrap.Alert.getOrCreateInstance(el).close();
        }, 4000);
    });
</script>
</body>
</html>
