<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Revenue Report - Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .app-container {
            display: flex;
            min-height: 100vh;
            background-color: #f8fafc;
        }
        .main-content {
            flex: 1;
            padding: 2rem;
            overflow-y: auto;
        }
        .stat-number {
            color: #000000 !important;
            font-weight: 700;
        }
    </style>
</head>
<body>

<div class="app-container">
    <jsp:include page="/view/admin/sidebar.jsp">
        <jsp:param name="activeTab" value="reports" />
    </jsp:include>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-dark"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Revenue Reports</h2>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger shadow-sm" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> ${errorMessage}
            </div>
        </c:if>

        <div class="card mb-4 border-0 shadow-sm">
            <div class="card-body p-4">
                <form method="GET" action="${pageContext.request.contextPath}/staff/reports" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold text-muted">Start Date</label>
                        <input type="date" name="startDate" class="form-control" value="${selectedStartDate}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold text-muted">End Date</label>
                        <input type="date" name="endDate" class="form-control" value="${selectedEndDate}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold text-muted">Time Period</label>
                        <select name="timePeriod" class="form-select">
                            <option value="daily" ${selectedTimePeriod == 'daily' ? 'selected' : ''}>Daily</option>
                            <option value="weekly" ${selectedTimePeriod == 'weekly' ? 'selected' : ''}>Weekly</option>
                            <option value="monthly" ${selectedTimePeriod == 'monthly' ? 'selected' : ''}>Monthly</option>
                            <option value="yearly" ${selectedTimePeriod == 'yearly' ? 'selected' : ''}>Yearly</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold text-muted">Product Category</label>
                        <select name="categoryId" class="form-select">
                            <option value="-1">-- All Categories --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.id}" ${selectedCategoryId == cat.id ? 'selected' : ''}>${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 d-flex gap-2 justify-content-end mt-4">
                        <a href="${pageContext.request.contextPath}/staff/reports" class="btn btn-light border px-4">Clear Filters</a>
                        <button type="submit" class="btn btn-primary px-4">Apply Filters</button>
                    </div>
                </form>
            </div>
        </div>

<div class="row mb-4 g-3">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm text-white" 
             style="background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;">
            <div class="card-body p-4">
                <h6 class="text-uppercase mb-2 fw-bold small" style="color: rgba(255,255,255,0.85);">Total Revenue</h6>
                <h2 class="mb-0 stat-number" style="color: #ffffff !important;">${reportData.totalRevenue} VND</h2>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card border-0 shadow-sm text-white" 
             style="background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%) !important;">
            <div class="card-body p-4">
                <h6 class="text-uppercase mb-2 fw-bold small" style="color: rgba(255,255,255,0.85);">Completed Orders</h6>
                <h2 class="mb-0 stat-number" style="color: #ffffff !important;">${reportData.completedOrdersCount} orders</h2>
            </div>
        </div>
    </div>
</div>

        <div class="row mb-4 g-3">
            <div class="col-md-8">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white border-0 py-3 fw-bold text-dark">Revenue Trend Chart</div>
                    <div class="card-body">
                        <canvas id="timeTrendChart" style="max-height: 320px;"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white border-0 py-3 fw-bold text-dark">Revenue Share by Category</div>
                    <div class="card-body d-flex align-items-center justify-content-center">
                        <canvas id="categoryShareChart" style="max-height: 260px;"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4 d-flex align-items-center justify-content-between">
                <div>
                    <h5 class="fw-bold mb-1">Export Report Data</h5>
                    <p class="text-muted small mb-0">Download a professionally formatted Excel spreadsheet containing all filtered statistics.</p>
                </div>
                <form method="POST" action="${pageContext.request.contextPath}/staff/reports">
                    <input type="hidden" name="startDate" value="${selectedStartDate}">
                    <input type="hidden" name="endDate" value="${selectedEndDate}">
                    <input type="hidden" name="timePeriod" value="${selectedTimePeriod}">
                    <input type="hidden" name="categoryId" value="${selectedCategoryId}">
                    <input type="hidden" name="format" value="excel">
                    <button type="submit" class="btn btn-success px-4 py-2 fw-bold">
                        <i class="fa-solid fa-file-excel me-2"></i> Export to Excel
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    const timeLabels = [];
    const timeData = [];
    <c:forEach items="${reportData.revenueBreakdownTime}" var="entry">
        timeLabels.push('${entry.key}');
        timeData.push(${entry.value});
    </c:forEach>

    new Chart(document.getElementById('timeTrendChart'), {
        type: 'line',
        data: {
            labels: timeLabels,
            datasets: [{
                label: 'Revenue (VND)',
                data: timeData,
                borderColor: '#10b981',
                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                fill: true,
                tension: 0.3
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    const catLabels = [];
    const catData = [];
    <c:forEach items="${reportData.revenueBreakdownCategory}" var="entry">
        catLabels.push('${entry.key}');
        catData.push(${entry.value});
    </c:forEach>

    new Chart(document.getElementById('categoryShareChart'), {
        type: 'pie',
        data: {
            labels: catLabels,
            datasets: [{
                data: catData,
                backgroundColor: ['#0ea5e9', '#3b82f6', '#f59e0b', '#ef4444', '#10b981']
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });
</script>
</body>
</html>