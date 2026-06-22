<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hệ Thống Quản Lý - Dashboard Tổng Quan</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">

        <style>
            body {
                font-family: 'Inter', sans-serif;
                background-color: #f4f6f9;
                color: #333;
                overflow-x: hidden;
            }

            /* Cấu trúc Layout cân xứng */
            .main-content {
                margin-left: 260px; /* Khớp với độ rộng chuẩn của Sidebar */
                padding: 40px;
                min-height: 100vh;
                transition: all 0.3s ease;
            }

            /* Thẻ Thống Kê Cao Cấp (Gradients & Shadows) */
            .stat-card {
                border: none;
                border-radius: 16px;
                padding: 24px;
                position: relative;
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08) !important;
            }
            .card-icon-wrapper {
                width: 56px;
                height: 56px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                background: rgba(255, 255, 255, 0.2);
            }

            /* Định nghĩa các tone màu Gradient sang trọng */
            .bg-gradient-primary {
                background: linear-gradient(135deg, #4f46e5, #6366f1);
            }
            .bg-gradient-success {
                background: linear-gradient(135deg, #10b981, #059669);
            }
            .bg-gradient-warning {
                background: linear-gradient(135deg, #f59e0b, #d97706);
            }
            .bg-gradient-danger  {
                background: linear-gradient(135deg, #ef4444, #dc2626);
            }

            /* Khu vực chứa Biểu đồ */
            .chart-wrapper {
                background: #ffffff;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
                border: 1px solid #eef2f6;
                height: 100%;
            }

            .chart-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
            }
        </style>
    </head>
    <body>

        <div class="container-fluid p-0">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeTab" value="dashboard" />
            </jsp:include>

            <div class="main-content">

                <div class="d-flex justify-content-between align-items-center mb-5">
                    <div>
                        <h2 class="fw-bold text-dark m-0 tracking-tight">Overview Dashboard</h2>
                        <p class="text-muted m-0 mt-1">Dữ liệu thống kê hoạt động kinh doanh thực tế toàn hệ thống.</p>
                    </div>
                    <div class="bg-white px-4 py-2 border rounded-3 text-muted fw-semibold shadow-sm text-sm">
                        <i class="fa-regular fa-calendar-days me-2 text-primary"></i>Hôm nay: <span id="currentDate"></span>
                    </div>
                </div>

                <div class="row g-4 mb-5">

                    <div class="col-md-3">
                        <div class="card stat-card bg-gradient-primary text-white shadow-sm">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <p class="text-white-50 text-uppercase fw-bold small mb-2">Monthly Revenue</p>
                                    <h3 class="mb-0 fw-bold">
                                        <fmt:formatNumber value="${dashboardData.monthlyRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                    </h3>
                                </div>
                                <div class="card-icon-wrapper">
                                    <i class="fa-solid fa-money-bill-wave fa-xl"></i>
                                </div>
                            </div>
                            <div class="mt-4 text-white-50 small">
                                <i class="fa-solid fa-circle-check me-1"></i> Đơn hàng thành công
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card bg-gradient-success text-white shadow-sm">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <p class="text-white-50 text-uppercase fw-bold small mb-2">New Orders</p>
                                    <h3 class="mb-0 fw-bold">${dashboardData.newOrdersCount}</h3>
                                </div>
                                <div class="card-icon-wrapper">
                                    <i class="fa-solid fa-cart-shopping fa-xl"></i>
                                </div>
                            </div>
                            <div class="mt-4 text-white-50 small">
                                <i class="fa-solid fa-clock me-1"></i> Trạng thái chờ xử lý (PENDING)
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card bg-gradient-warning text-white shadow-sm">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <p class="text-white-50 text-uppercase fw-bold small mb-2">Active Variants</p>
                                    <h3 class="mb-0 fw-bold">${dashboardData.totalProductsCount}</h3>
                                </div>
                                <div class="card-icon-wrapper">
                                    <i class="fa-solid fa-box fa-xl"></i>
                                </div>
                            </div>
                            <div class="mt-4 text-white-50 small">
                                <i class="fa-solid fa-boxes-stacked me-1"></i> Sản phẩm đang mở bán
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card bg-gradient-danger text-white shadow-sm">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <p class="text-white-50 text-uppercase fw-bold small mb-2">Customers</p>
                                    <h3 class="mb-0 fw-bold">${dashboardData.totalCustomersCount}</h3>
                                </div>
                                <div class="card-icon-wrapper">
                                    <i class="fa-solid fa-users fa-xl"></i>
                                </div>
                            </div>
                            <div class="mt-4 text-white-50 small">
                                <i class="fa-solid fa-user-shield me-1"></i> Tài khoản vai trò CUSTOMER
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4">

                    <div class="col-lg-8">
                        <div class="chart-wrapper">
                            <div class="chart-header">
                                <h5 class="fw-bold text-dark m-0"><i class="fa-solid fa-chart-area me-2 text-primary"></i>Revenue Trend</h5>
                                <span class="badge bg-light text-primary border border-primary-subtle px-2.5 py-1">6 Tháng gần nhất</span>
                            </div>
                            <div style="position: relative; height: 340px;">
                                <canvas id="revenueChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="chart-wrapper">
                            <div class="chart-header">
                                <h5 class="fw-bold text-dark m-0"><i class="fa-solid fa-chart-pie me-2 text-success"></i>Category Share</h5>
                            </div>
                            <div style="position: relative; height: 340px; display: flex; align-items: center; justify-content: center;">
                                <canvas id="categoryChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
            // Tự động gán ngày tháng hôm nay chuẩn xác lên UI
            const now = new Date();
            if (document.getElementById('currentDate')) {
            document.getElementById('currentDate').innerText = now.toLocaleDateString('en-US');
            }

            // --- 1. CONFIG BIỂU ĐỒ XU HƯỚNG DOANH THU ĐỘNG ---
            const ctxRevenue = document.getElementById('revenueChart');
            if (ctxRevenue) {
            new Chart(ctxRevenue.getContext('2d'), {
            type: 'line',
                    data: {
                    labels: [
            <c:forEach var="entry" items="${dashboardData.revenueTrend}" varStatus="status">
                    '${entry.key}'${!status.last ? ',' : ''}
            </c:forEach>
                    ],
                            datasets: [{
                            label: 'Revenue (VND)',
                                    data: [
            <c:forEach var="entry" items="${dashboardData.revenueTrend}" varStatus="status">
                ${entry.value}${!status.last ? ',' : ''}
            </c:forEach>
                                    ],
                                    backgroundColor: 'rgba(79, 70, 229, 0.06)',
                                    borderColor: '#4f46e5',
                                    borderWidth: 3,
                                    pointBackgroundColor: '#4f46e5',
                                    pointBorderColor: '#ffffff',
                                    pointBorderWidth: 2,
                                    pointRadius: 5,
                                    pointHoverRadius: 7,
                                    tension: 0.38,
                                    fill: true
                            }]
                    },
                    options: {
                    responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                            legend: { display: false }
                            },
                            scales: {
                            y: {
                            beginAtZero: true,
                                    grid: { color: '#f3f4f6' },
                                    ticks: {
                                    callback: function(value) { return value.toLocaleString('vi-VN') + ' đ'; }
                                    }
                            },
                                    x: { grid: { display: false } }
                            }
                    }
            });
            }

            // --- 2. CONFIG BIỂU ĐỒ TRÒN THỊ PHẦN DANH MỤC ĐỘNG ---
            const ctxCategory = document.getElementById('categoryChart');
            if (ctxCategory) {
            new Chart(ctxCategory.getContext('2d'), {
            type: 'doughnut',
                    data: {
                    labels: [
            <c:forEach var="entry" items="${dashboardData.categoryShare}" varStatus="status">
                    '${entry.key}'${!status.last ? ',' : ''}
            </c:forEach>
                    ],
                            datasets: [{
                            data: [
            <c:forEach var="entry" items="${dashboardData.categoryShare}" varStatus="status">
                ${entry.value}${!status.last ? ',' : ''}
            </c:forEach>
                            ],
                                    backgroundColor: ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#a855f7', '#ec4899', '#06b6d4'],
                                    borderWidth: 3,
                                    borderColor: '#ffffff',
                                    hoverOffset: 6
                            }]
                    },
                    options: {
                    responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                            legend: {
                            position: 'bottom',
                                    labels: { padding: 20, font: { size: 12, weight: 500 } }
                            }
                            }
                    }
            });
            }
            });
        </script>
    </body>
</html>