<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - System Overview</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .sidebar { min-height: 100vh; background: #212529; color: #fff; }
        .sidebar a { color: #adb5bd; text-decoration: none; display: block; padding: 12px 20px; transition: 0.2s; }
        .sidebar a:hover, .sidebar a.active { background: #343a40; color: #fff; border-left: 4px solid #0d6efd; }
        .stat-card { border: none; border-radius: 10px; transition: transform 0.2s; }
        .stat-card:hover { transform: translateY(-5px); }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 px-0 sidebar d-none d-md-block shadow">
            <div class="p-3 text-center border-bottom border-secondary">
                <h4 class="text-white mb-0 fw-bold"><i class="fa-solid fa-shirt me-2"></i>Clothing Sale</h4>
            </div>
            <div class="py-2">
                <a href="${pageContext.request.contextPath}/AdminDashboard" class="active"><i class="fa-solid fa-chart-line me-2"></i>Overview</a>
                <a href="${pageContext.request.contextPath}/admin/manage-product"><i class="fa-solid fa-box me-2"></i>Product Management</a>
                <a href="#"><i class="fa-solid fa-receipt me-2"></i>Orders</a>
                <a href="#"><i class="fa-solid fa-users me-2"></i>Customers</a>
                <a href="#"><i class="fa-solid fa-ticket me-2"></i>Discount Codes</a>
            </div>
        </div>

        <div class="col-md-10 p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                <h2 class="fw-bold text-dark mb-0">Overview Dashboard</h2>
                <div class="text-muted fw-semibold">
                    <i class="fa-regular fa-calendar-days me-2"></i>Today: <span id="currentDate"></span>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card stat-card shadow-sm bg-primary text-white p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50 text-uppercase fw-bold small">Monthly Revenue</h6>
                                <h3 class="mb-0 fw-bold">45,240,000 VND</h3>
                            </div>
                            <div class="bg-white bg-opacity-25 p-3 rounded-circle">
                                <i class="fa-solid fa-money-bill-wave fa-2x"></i>
                            </div>
                        </div>
                        <div class="mt-3 text-white-50 small">
                            <i class="fa-solid fa-arrow-up me-1"></i> 12% vs. last month
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card shadow-sm bg-success text-white p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50 text-uppercase fw-bold small">New Orders</h6>
                                <h3 class="mb-0 fw-bold">128</h3>
                            </div>
                            <div class="bg-white bg-opacity-25 p-3 rounded-circle">
                                <i class="fa-solid fa-cart-shopping fa-2x"></i>
                            </div>
                        </div>
                        <div class="mt-3 text-white-50 small">
                            <i class="fa-solid fa-arrow-up me-1"></i> 5% vs. yesterday
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card shadow-sm bg-warning text-white p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50 text-uppercase fw-bold small">Total Products</h6>
                                <h3 class="mb-0 fw-bold">1,420</h3>
                            </div>
                            <div class="bg-white bg-opacity-25 p-3 rounded-circle">
                                <i class="fa-solid fa-box fa-2x"></i>
                            </div>
                        </div>
                        <div class="mt-3 text-white-50 small">
                            <span>Business is active</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card shadow-sm bg-danger text-white p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50 text-uppercase fw-bold small">Customers</h6>
                                <h3 class="mb-0 fw-bold">856</h3>
                            </div>
                            <div class="bg-white bg-opacity-25 p-3 rounded-circle">
                                <i class="fa-solid fa-users fa-2x"></i>
                            </div>
                        </div>
                        <div class="mt-3 text-white-50 small">
                            <i class="fa-solid fa-arrow-up me-1"></i> 24 new accounts this week
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-md-8">
                    <div class="card border-0 shadow-sm p-4">
                        <h5 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-chart-area me-2 text-primary"></i>Revenue trend over the last 6 months</h5>
                        <canvas id="revenueChart" style="max-height: 320px;"></canvas>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm p-4">
                        <h5 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-chart-pie me-2 text-success"></i>Category share</h5>
                        <canvas id="categoryChart" style="max-height: 320px;"></canvas>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    // Display the current date in the user's locale.
    const now = new Date();
    document.getElementById('currentDate').innerText = now.toLocaleDateString('en-US');

    // 1. Revenue chart configuration.
    const ctxRevenue = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctxRevenue, {
        type: 'line',
        data: {
            labels: ['Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5', 'Month 6'],
            datasets: [{
                label: 'Revenue (VND)',
                data: [15000000, 22000000, 18000000, 29000000, 35000000, 45240000],
                backgroundColor: 'rgba(13, 110, 253, 0.1)',
                borderColor: '#0d6efd',
                borderWidth: 3,
                tension: 0.3,
                fill: true
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } } }
    });

    // 2. Product category doughnut chart configuration.
    const ctxCategory = document.getElementById('categoryChart').getContext('2d');
    new Chart(ctxCategory, {
        type: 'doughnut',
        data: {
            labels: ['T-shirts', 'Shirts', 'Jeans', 'Dresses'],
            datasets: [{
                data: [40, 25, 20, 15],
                backgroundColor: ['#0d6efd', '#198754', '#ffc107', '#dc3545']
            }]
        },
        options: { responsive: true }
    });
</script>
</body>
</html>
