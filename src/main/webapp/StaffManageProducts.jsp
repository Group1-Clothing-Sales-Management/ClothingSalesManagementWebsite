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
    <title>Staff Dashboard - Manage Products</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased text-gray-900">

    <div class="min-h-screen flex">

        <aside class="w-64 bg-slate-900 text-white flex flex-col shadow-xl flex-shrink-0">
            <a href="StaffManageProducts" class="p-5 text-xl font-bold border-b border-slate-800 flex items-center gap-2 tracking-wide hover:bg-slate-800 transition-colors block">
                <i class="fa-solid fa-shirt text-indigo-400"></i>
                <span>ClothesShop</span>
            </a>

            <nav class="flex-1 p-4 space-y-1.5">
                <a href="StaffManageProducts" class="flex items-center gap-3 px-4 py-3 bg-indigo-600 text-white rounded-lg font-medium shadow-md transition-all text-sm">
                    <i class="fa-solid fa-box w-5 text-base"></i>
                    <span>Product Management</span>
                </a>
                <a href="${pageContext.request.contextPath}/staff/orders" class="flex items-center gap-3 px-4 py-3 text-gray-400 hover:bg-slate-800 hover:text-white rounded-lg transition-all text-sm font-medium">
                    <i class="fa-solid fa-receipt w-5 text-base"></i>
                    <span>Order Management</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/logout" class="flex items-center gap-3 px-4 py-3 text-rose-300 hover:bg-slate-800 hover:text-white rounded-lg transition-all text-sm font-medium">
                    <i class="fa-solid fa-right-from-bracket w-5 text-base"></i>
                    <span>Sign out</span>
                </a>
            </nav>

            <div class="p-4 border-t border-slate-800">
                <div class="flex items-center gap-3 px-2 py-2">
                    <div class="w-9 h-9 rounded-full bg-indigo-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                        ST
                    </div>
                    <div class="min-w-0">
                        <div class="text-sm font-semibold text-white truncate">
                            <%= (session != null && session.getAttribute("authUsername") != null)
                                    ? session.getAttribute("authUsername")
                                    : (request.getAttribute("staffUser") != null ? request.getAttribute("staffUser") : "staff01") %>
                        </div>
                        <div class="text-xs text-emerald-400 flex items-center gap-1">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block"></span>
                            Warehouse staff
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <main class="flex-1 flex flex-col min-w-0">

            <header class="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-8 shadow-sm flex-shrink-0">
                <div class="text-gray-800 font-bold text-lg tracking-wide">
                    Product Warehouse
                </div>
            </header>

            <div class="p-8 flex-1 overflow-y-auto">

                <% String errorMsg = (String) request.getAttribute("errorMessage");
                   if (errorMsg != null) { %>
                    <div class="mb-6 p-4 bg-rose-50 border border-rose-200 text-rose-800 rounded-xl flex items-center gap-3 shadow-sm">
                        <i class="fa-solid fa-circle-exclamation text-rose-500 text-xl flex-shrink-0"></i>
                        <span class="font-medium"><%= errorMsg %></span>
                    </div>
                <% } %>

                <% String successMsg = (String) request.getAttribute("successMessage");
                   if (successMsg != null) { %>
                    <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl flex items-center gap-3 shadow-sm">
                        <i class="fa-solid fa-circle-check text-emerald-500 text-xl flex-shrink-0"></i>
                        <span class="font-medium"><%= successMsg %></span>
                    </div>
                <% } %>

                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">

                    <div class="p-5 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-stretch sm:items-center gap-4 bg-gray-50/50">
                        <div class="relative">
                            <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i>
                            <input type="text" id="searchInput" onkeyup="filterProducts()" placeholder="Search by product name or SKU..."
                                   class="pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm w-full sm:w-80 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all bg-white">
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="border-b border-gray-200 bg-gray-50 text-xs font-bold uppercase tracking-wider text-gray-500 select-none">
                                    <th class="py-4 px-6">Product & Brand</th>
                                    <th class="py-4 px-6">SKU</th>
                                    <th class="py-4 px-6 text-right">Cost Price</th>
                                    <th class="py-4 px-6 text-right">Sale Price</th>
                                    <th class="py-4 px-6 text-center">Stock</th>
                                    <th class="py-4 px-6 text-center">Status</th>
                                    <th class="py-4 px-6 text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="productTable" class="divide-y divide-gray-100 text-sm text-gray-600">
                                <%
                                    NumberFormat numFormat = NumberFormat.getNumberInstance(Locale.US);
                                    List<StaffProductModel> products = (List<StaffProductModel>) request.getAttribute("productList");

                                    if (products == null || products.isEmpty()) {
                                %>
                                    <tr>
                                        <td colspan="7" class="text-center py-16 text-gray-400 bg-gray-50/50">
                                            <div class="flex flex-col items-center justify-center gap-2">
                                                <i class="fa-solid fa-box-open text-5xl text-gray-300 mb-1"></i>
                                                <span class="font-medium text-base text-gray-500">No products available</span>
                                                <p class="text-xs text-gray-400 max-w-xs">No product data has been recorded in the system yet.</p>
                                            </div>
                                        </td>
                                    </tr>
                                <%
                                    } else {
                                        for (StaffProductModel item : products) {
                                            String stockClass = item.getStockQuantity() > 0
                                                    ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                                                    : "bg-rose-50 text-rose-700 border-rose-200";
                                            String statusClass = "ACTIVE".equals(item.getStatus())
                                                    ? "bg-green-100 text-green-800"
                                                    : "bg-gray-100 text-gray-800";
                                %>
                                    <tr class="hover:bg-slate-50/70 transition-all">
                                        <td class="py-4 px-6">
                                            <div class="font-semibold text-slate-800 text-[14px]"><%= item.getProductName() %></div>
                                            <span class="text-xs font-medium text-indigo-600 bg-indigo-50/60 px-2 py-0.5 rounded mt-1 inline-block"><%= item.getBrandName() %></span>
                                        </td>

                                        <td class="py-4 px-6 font-mono text-xs text-gray-500 font-semibold"><%= item.getSku() %></td>

                                        <td class="py-4 px-6 text-right text-gray-500 font-medium"><%= numFormat.format(item.getCostPrice()) %> VND</td>
                                        <td class="py-4 px-6 text-right font-bold text-slate-900"><%= numFormat.format(item.getSalePrice()) %> VND</td>

                                        <td class="py-4 px-6 text-center">
                                            <span class="px-2.5 py-0.5 text-xs font-bold border rounded-md <%= stockClass %>">
                                                <%= item.getStockQuantity() %>
                                            </span>
                                        </td>

                                        <td class="py-4 px-6 text-center">
                                            <span class="px-2.5 py-0.5 text-xs font-semibold rounded-full <%= statusClass %>">
                                                <%= item.getStatus() %>
                                            </span>
                                        </td>

                                        <td class="py-4 px-6 text-center">
                                            <div class="flex items-center justify-center gap-1.5">
                                                <a href="StaffManageProducts?action=view&sku=<%= item.getSku() %>"
                                                   class="inline-flex items-center justify-center w-8 h-8 text-blue-600 hover:bg-blue-50 hover:text-blue-700 rounded-lg transition-colors border border-transparent hover:border-blue-100"
                                                   title="View details">
                                                    <i class="fa-regular fa-eye text-base"></i>
                                                </a>
                                                <a href="StaffManageProducts?action=edit&sku=<%= item.getSku() %>"
                                                   class="inline-flex items-center justify-center w-8 h-8 text-amber-600 hover:bg-amber-50 hover:text-amber-700 rounded-lg transition-colors border border-transparent hover:border-amber-100"
                                                   title="Update information">
                                                    <i class="fa-regular fa-pen-to-square text-base"></i>
                                                </a>
                                            </div>
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
        </main>
    </div>

    <script>
        function filterProducts() {
            const filter = document.getElementById("searchInput").value.toLowerCase().trim();
            const rows = document.getElementById("productTable").getElementsByTagName("tr");

            for (let i = 0; i < rows.length; i++) {
                const nameEl = rows[i].getElementsByClassName("font-semibold")[0];
                const skuEl  = rows[i].getElementsByClassName("font-mono")[0];

                if (nameEl && skuEl) {
                    const name = nameEl.textContent || nameEl.innerText;
                    const sku  = skuEl.textContent  || skuEl.innerText;
                    rows[i].style.display = (name.toLowerCase().includes(filter) || sku.toLowerCase().includes(filter)) ? "" : "none";
                }
            }
        }
    </script>
</body>
</html>
