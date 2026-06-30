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
        .table { table-layout: fixed; }
        .table thead th {
            background: #212529;
            color: #fff;
            font-weight: 600;
            font-size: .85rem;
            border: none;
            white-space: nowrap;
        }
        .table tbody tr:hover { background: #f0f4ff; }
        .table td {
            vertical-align: middle;
            font-size: .9rem;
            height: 64px;
        }

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
        .product-name {
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
        }
        .empty-state { padding: 56px 0; text-align: center; color: #9ca3af; }
        .breadcrumb { font-size: .82rem; margin-bottom: 6px; }
    </style>
</head>
<body>
<jsp:include page="/view/admin/common/admin_layout_start.jsp">
    <jsp:param name="activeTab" value="products"/>
</jsp:include>
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
                        <colgroup>
                            <col style="width:5%">
                            <col style="width:28%">
                            <col style="width:22%">
                            <col style="width:12%">
                            <col style="width:13%">
                            <col style="width:20%">
                        </colgroup>
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
                                    <div class="fw-semibold text-dark product-name" title="<%= item.getProductName() %>"><%= item.getProductName() %></div>
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
            <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3" style="border-top:1px solid #eee;">
                <small class="text-muted" id="paginationInfo"></small>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
                </nav>
            </div>
        </div>
<jsp:include page="/view/admin/common/admin_layout_end.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const ROWS_PER_PAGE = 10;
    let currentPage = 1;

    function getAllRows() {
        return Array.from(document.getElementById("productTable").getElementsByTagName("tr"));
    }

    function getFilteredRows() {
        const filter = document.getElementById("searchInput").value.toLowerCase();
        return getAllRows().filter(row => {
            const nameEl = row.querySelector(".product-name");
            if (!nameEl) return false;
            return nameEl.textContent.toLowerCase().includes(filter);
        });
    }

    function renderPage() {
        const filteredRows = getFilteredRows();
        const allRows = getAllRows();
        const totalPages = Math.max(1, Math.ceil(filteredRows.length / ROWS_PER_PAGE));

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        allRows.forEach(row => row.style.display = "none");

        const start = (currentPage - 1) * ROWS_PER_PAGE;
        const end = start + ROWS_PER_PAGE;
        filteredRows.slice(start, end).forEach(row => row.style.display = "");

        if (filteredRows.length === 0) {
            const emptyRow = allRows.find(r => !r.querySelector(".product-name"));
            if (emptyRow) emptyRow.style.display = "";
        }

        renderPaginationControls(totalPages, filteredRows.length);
    }

    function renderPaginationControls(totalPages, totalItems) {
        const info = document.getElementById("paginationInfo");
        const controls = document.getElementById("paginationControls");
        controls.innerHTML = "";

        if (totalItems === 0) {
            info.textContent = "No products found";
            return;
        }

        const start = (currentPage - 1) * ROWS_PER_PAGE + 1;
        const end = Math.min(currentPage * ROWS_PER_PAGE, totalItems);
        info.textContent = "Showing " + start + "-" + end + " of " + totalItems + " products";

        const addPageItem = (label, page, disabled, active) => {
            const li = document.createElement("li");
            li.className = "page-item" + (disabled ? " disabled" : "") + (active ? " active" : "");
            const a = document.createElement("a");
            a.className = "page-link";
            a.href = "#";
            a.textContent = label;
            a.onclick = (e) => { e.preventDefault(); if (!disabled) { currentPage = page; renderPage(); } };
            li.appendChild(a);
            controls.appendChild(li);
        };

        addPageItem("«", currentPage - 1, currentPage === 1, false);

        for (let p = 1; p <= totalPages; p++) {
            addPageItem(p, p, false, p === currentPage);
        }

        addPageItem("»", currentPage + 1, currentPage === totalPages, false);
    }

    function filterProducts() {
        currentPage = 1;
        renderPage();
    }

    document.addEventListener("DOMContentLoaded", renderPage);
</script>
</body>
</html>