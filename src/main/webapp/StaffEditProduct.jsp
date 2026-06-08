<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clothingsale.model.StaffProductModel" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật sản phẩm</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased text-gray-900">

    <%
        StaffProductModel product = (StaffProductModel) request.getAttribute("product");
        if (product == null) {
            response.sendRedirect("StaffManageProducts");
            return;
        }
        String statusClass = "ACTIVE".equals(product.getStatus()) ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-800";
    %>

    <div class="min-h-screen flex">

        <!-- Sidebar -->
        <aside class="w-64 bg-slate-900 text-white flex flex-col shadow-xl flex-shrink-0">
            <a href="StaffManageProducts" class="p-5 text-xl font-bold border-b border-slate-800 flex items-center gap-2 tracking-wide hover:bg-slate-800 transition-colors block">
                <i class="fa-solid fa-shirt text-indigo-400"></i>
                <span>ClothesShop</span>
            </a>
            <nav class="flex-1 p-4 space-y-1.5">
                <a href="StaffManageProducts" class="flex items-center gap-3 px-4 py-3 bg-indigo-600 text-white rounded-lg font-medium shadow-md transition-all text-sm">
                    <i class="fa-solid fa-box w-5 text-base"></i>
                    <span>Quản lý sản phẩm</span>
                </a>
                <a href="#" class="flex items-center gap-3 px-4 py-3 text-gray-400 hover:bg-slate-800 hover:text-white rounded-lg transition-all text-sm font-medium">
                    <i class="fa-solid fa-receipt w-5 text-base"></i>
                    <span>Quản lý đơn hàng</span>
                </a>
            </nav>
            <!-- Staff account -->
            <div class="p-4 border-t border-slate-800">
                <div class="flex items-center gap-3 px-2 py-2">
                    <div class="w-9 h-9 rounded-full bg-indigo-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                        ST
                    </div>
                    <div class="min-w-0">
                        <div class="text-sm font-semibold text-white truncate">staff01</div>
                        <div class="text-xs text-emerald-400 flex items-center gap-1">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block"></span>
                            Nhân viên kho
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main content -->
        <main class="flex-1 flex flex-col min-w-0">
            <header class="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-8 shadow-sm flex-shrink-0">
                <div class="text-gray-800 font-bold text-lg tracking-wide">
                    Kho Sản Phẩm
                </div>
            </header>

            <!-- Back link sát trái -->
            <div class="px-8 pt-6">
                <a href="StaffManageProducts" class="inline-flex items-center gap-2 text-sm font-semibold text-gray-600 hover:text-indigo-600 transition-colors">
                    <i class="fa-solid fa-arrow-left"></i> Hủy bỏ và quay lại
                </a>
            </div>

            <!-- Form căn giữa -->
            <div class="flex-1 overflow-y-auto flex flex-col items-center justify-start px-8 pb-8 pt-4">

                <form action="StaffManageProducts" method="POST" class="w-full max-w-2xl bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">

                    <input type="hidden" name="sku" value="<%= product.getSku() %>" />

                    <div class="p-6 border-b border-gray-100 bg-gray-50/50 flex justify-between items-center">
                        <div>
                            <h2 class="text-xl font-bold text-slate-800">Cập nhật thông tin sản phẩm</h2>
                            <p class="text-xs text-gray-500 mt-1">Chỉnh sửa nội dung các trường thông tin được phép phân quyền</p>
                        </div>
                        <span class="px-3 py-1 text-xs font-semibold rounded-full <%= statusClass %>">
                            Trạng thái: <%= product.getStatus() %>
                        </span>
                    </div>

                    <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="space-y-4">
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-500 mb-1">Tên sản phẩm *</label>
                                <input type="text" name="productName" value="<%= product.getProductName() %>" required
                                       class="w-full p-3 border border-gray-200 rounded-lg focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 font-semibold text-slate-800 transition-all bg-white" />
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-1">Mã SKU (Không được sửa)</label>
                                <div class="p-3 bg-gray-100 border border-gray-200 rounded-lg font-mono text-sm text-gray-500 font-bold select-none">
                                    <%= product.getSku() %>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-1">Thương hiệu</label>
                                <div class="p-3 bg-gray-100 border border-gray-200 rounded-lg text-sm text-gray-500 font-semibold select-none">
                                    <%= product.getBrandName() %>
                                </div>
                            </div>
                        </div>

                        <div class="space-y-4">
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-1">Giá vốn nhập hàng</label>
                                <div class="p-3 bg-gray-100 border border-gray-200 rounded-lg text-sm text-gray-500 font-semibold select-none">
                                    <%= (long)product.getCostPrice().doubleValue() %> đ
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-500 mb-1">Giá niêm yết bán ra (đ) *</label>
                                <input type="number" name="salePrice" value="<%= (long)product.getSalePrice().doubleValue() %>" min="0" required
                                       class="w-full p-3 border border-gray-200 rounded-lg focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 font-bold text-slate-900 transition-all bg-white" />
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-wider text-gray-500 mb-1">Số lượng tồn kho *</label>
                                <input type="number" name="stockQuantity" value="<%= product.getStockQuantity() %>" min="0" required
                                       class="w-full p-3 border border-gray-200 rounded-lg focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 font-bold text-indigo-600 transition-all bg-white" />
                            </div>
                        </div>
                    </div>

                    <div class="px-6 py-4 border-t border-gray-100 bg-gray-50/50 flex justify-end gap-3">
                        <a href="StaffManageProducts" class="px-4 py-2 border border-gray-200 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-all">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-semibold shadow-md transition-all flex items-center gap-1.5">
                            <i class="fa-solid fa-cloud-arrow-up"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>

            </div>
        </main>
    </div>

</body>
</html>
