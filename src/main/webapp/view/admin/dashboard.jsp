<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <style>
            :root {
                --dashboard-bg: #f5f7fb;
                --dashboard-surface: #ffffff;
                --dashboard-border: #e5e7eb;
                --dashboard-text: #111827;
                --dashboard-muted: #6b7280;
                --dashboard-primary: #2563eb;
                --dashboard-success: #059669;
                --dashboard-warning: #d97706;
                --dashboard-danger: #dc2626;
                --dashboard-info: #0891b2;
                --dashboard-radius: 16px;
                --dashboard-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
            }

            body {
                background: var(--dashboard-bg);
                color: var(--dashboard-text);
            }

            .dashboard-page {
                padding: 28px 32px 40px;
            }

            .dashboard-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 20px;
                flex-wrap: wrap;
                margin-bottom: 24px;
            }

            .dashboard-title {
                margin: 0;
                font-size: 1.75rem;
                font-weight: 750;
                letter-spacing: -0.03em;
            }

            .dashboard-subtitle {
                margin: 7px 0 0;
                color: var(--dashboard-muted);
                font-size: 0.95rem;
            }

            .filter-panel {
                background: var(--dashboard-surface);
                border: 1px solid var(--dashboard-border);
                border-radius: 14px;
                padding: 12px;
                box-shadow: var(--dashboard-shadow);
            }

            .filter-form {
                display: flex;
                align-items: end;
                gap: 10px;
                flex-wrap: wrap;
            }

            .filter-field label {
                display: block;
                margin-bottom: 5px;
                color: var(--dashboard-muted);
                font-size: 0.72rem;
                font-weight: 700;
                letter-spacing: 0.06em;
                text-transform: uppercase;
            }

            .filter-field .form-select,
            .filter-field .form-control {
                min-width: 155px;
                height: 40px;
                border-color: var(--dashboard-border);
                font-size: 0.88rem;
            }

            .date-summary {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                margin-top: 10px;
                color: var(--dashboard-muted);
                font-size: 0.82rem;
            }

            .section-label {
                margin: 0 0 12px;
                color: #374151;
                font-size: 0.75rem;
                font-weight: 750;
                letter-spacing: 0.08em;
                text-transform: uppercase;
            }

            .metric-card,
            .operation-card,
            .dashboard-panel {
                background: var(--dashboard-surface);
                border: 1px solid var(--dashboard-border);
                border-radius: var(--dashboard-radius);
                box-shadow: var(--dashboard-shadow);
            }

            .metric-card {
                height: 100%;
                padding: 20px;
            }

            .metric-card-top {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 12px;
            }

            .metric-label {
                margin: 0;
                color: var(--dashboard-muted);
                font-size: 0.78rem;
                font-weight: 700;
                letter-spacing: 0.05em;
                text-transform: uppercase;
            }

            .metric-value {
                margin: 9px 0 0;
                font-size: clamp(1.45rem, 2.2vw, 2rem);
                font-weight: 760;
                letter-spacing: -0.04em;
                line-height: 1.15;
            }

            .metric-icon,
            .operation-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex: 0 0 auto;
                width: 44px;
                height: 44px;
                border-radius: 12px;
                font-size: 1rem;
            }

            .icon-blue {
                color: #1d4ed8;
                background: #eff6ff;
            }
            .icon-green {
                color: #047857;
                background: #ecfdf5;
            }
            .icon-violet {
                color: #6d28d9;
                background: #f5f3ff;
            }
            .icon-cyan {
                color: #0e7490;
                background: #ecfeff;
            }
            .icon-amber {
                color: #b45309;
                background: #fffbeb;
            }
            .icon-red {
                color: #b91c1c;
                background: #fef2f2;
            }

            .comparison {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                margin-top: 15px;
                color: var(--dashboard-muted);
                font-size: 0.78rem;
            }

            .trend {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                border-radius: 999px;
                padding: 4px 8px;
                font-weight: 700;
                white-space: nowrap;
            }

            .trend-up {
                color: #047857;
                background: #ecfdf5;
            }
            .trend-down {
                color: #b91c1c;
                background: #fef2f2;
            }
            .trend-flat {
                color: #4b5563;
                background: #f3f4f6;
            }

            .operation-card {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 14px;
                height: 100%;
                padding: 17px 18px;
                color: inherit;
                text-decoration: none;
                transition: transform 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease;
            }

            .operation-card:hover {
                color: inherit;
                transform: translateY(-2px);
                border-color: #cbd5e1;
                box-shadow: 0 12px 28px rgba(15, 23, 42, 0.08);
            }

            .operation-name {
                margin: 0;
                color: var(--dashboard-muted);
                font-size: 0.8rem;
                font-weight: 650;
            }

            .operation-value {
                margin: 4px 0 0;
                font-size: 1.55rem;
                font-weight: 750;
                line-height: 1;
            }

            .operation-action {
                margin-top: 7px;
                color: #64748b;
                font-size: 0.74rem;
            }

            .dashboard-panel {
                height: 100%;
                overflow: hidden;
            }

            .panel-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                padding: 18px 20px;
                border-bottom: 1px solid var(--dashboard-border);
            }

            .panel-title {
                margin: 0;
                font-size: 0.98rem;
                font-weight: 740;
            }

            .panel-subtitle {
                margin: 4px 0 0;
                color: var(--dashboard-muted);
                font-size: 0.78rem;
            }

            .panel-body {
                padding: 20px;
            }

            .chart-area {
                position: relative;
                height: 330px;
            }

            .compact-chart-area {
                position: relative;
                height: 330px;
            }

            .table-responsive {
                scrollbar-width: thin;
            }

            .dashboard-table {
                margin: 0;
                min-width: 680px;
                vertical-align: middle;
            }

            .dashboard-table thead th {
                padding: 12px 18px;
                border-bottom-color: var(--dashboard-border);
                background: #f8fafc;
                color: #64748b;
                font-size: 0.72rem;
                font-weight: 750;
                letter-spacing: 0.05em;
                text-transform: uppercase;
                white-space: nowrap;
            }

            .dashboard-table tbody td {
                padding: 14px 18px;
                border-bottom-color: #eef2f7;
                color: #374151;
                font-size: 0.84rem;
            }

            .dashboard-table tbody tr:last-child td {
                border-bottom: 0;
            }

            .primary-text {
                color: var(--dashboard-text);
                font-weight: 650;
            }

            .secondary-text {
                color: var(--dashboard-muted);
                font-size: 0.76rem;
            }

            .status-badge {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 78px;
                border-radius: 999px;
                padding: 5px 9px;
                font-size: 0.69rem;
                font-weight: 750;
                white-space: nowrap;
            }

            .status-success {
                color: #047857;
                background: #ecfdf5;
            }
            .status-warning {
                color: #b45309;
                background: #fffbeb;
            }
            .status-danger {
                color: #b91c1c;
                background: #fef2f2;
            }
            .status-info {
                color: #0369a1;
                background: #f0f9ff;
            }
            .status-neutral {
                color: #4b5563;
                background: #f3f4f6;
            }
            .status-violet {
                color: #6d28d9;
                background: #f5f3ff;
            }

            .empty-state {
                padding: 34px 20px;
                color: var(--dashboard-muted);
                text-align: center;
            }

            .empty-state i {
                display: block;
                margin-bottom: 10px;
                color: #cbd5e1;
                font-size: 1.8rem;
            }

            .rank-number {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 28px;
                height: 28px;
                border-radius: 8px;
                background: #f1f5f9;
                color: #475569;
                font-size: 0.76rem;
                font-weight: 750;
            }

            .panel-link {
                color: var(--dashboard-primary);
                font-size: 0.78rem;
                font-weight: 700;
                text-decoration: none;
            }

            .panel-link:hover {
                text-decoration: underline;
            }

            .alert-dashboard {
                border: 1px solid #fed7aa;
                border-radius: 14px;
                background: #fff7ed;
                color: #9a3412;
            }

            @media (max-width: 991.98px) {
                .dashboard-page {
                    padding: 22px 18px 32px;
                }

                .filter-panel,
                .filter-form {
                    width: 100%;
                }

                .filter-field {
                    flex: 1 1 160px;
                }

                .filter-field .form-select,
                .filter-field .form-control {
                    width: 100%;
                    min-width: 0;
                }
            }

            @media (max-width: 575.98px) {
                .dashboard-page {
                    padding: 18px 12px 28px;
                }

                .dashboard-title {
                    font-size: 1.45rem;
                }

                .filter-form .btn {
                    width: 100%;
                }

                .chart-area,
                .compact-chart-area {
                    height: 280px;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="dashboard"/>
        </jsp:include>

        <main class="dashboard-page admin-page">
            <div class="dashboard-header">
                <div>
                    <h1 class="dashboard-title">Business Dashboard</h1>
                    <p class="dashboard-subtitle">
                        Monitor sales performance, order operations, inventory risks, and customer activity.
                    </p>
                    <div class="date-summary">
                        <i class="fa-regular fa-calendar"></i>
                        <span>${dashboardData.rangeLabel}: ${dashboardData.startDate} to ${dashboardData.endDate}</span>
                    </div>
                </div>

                <div class="filter-panel">
                    <form class="filter-form" method="get"
                          action="${pageContext.request.contextPath}/admin/dashboard" id="dashboardFilterForm">
                        <div class="filter-field">
                            <label for="range">Reporting period</label>
                            <select class="form-select" name="range" id="range">
                                <option value="today" ${dashboardData.selectedRange == 'today' ? 'selected' : ''}>Today</option>
                                <option value="last_7_days" ${dashboardData.selectedRange == 'last_7_days' ? 'selected' : ''}>Last 7 Days</option>
                                <option value="last_30_days" ${dashboardData.selectedRange == 'last_30_days' ? 'selected' : ''}>Last 30 Days</option>
                                <option value="this_month" ${dashboardData.selectedRange == 'this_month' ? 'selected' : ''}>This Month</option>
                                <option value="last_month" ${dashboardData.selectedRange == 'last_month' ? 'selected' : ''}>Last Month</option>
                                <option value="custom" ${dashboardData.selectedRange == 'custom' ? 'selected' : ''}>Custom Range</option>
                            </select>
                        </div>

                        <div class="filter-field custom-date-field">
                            <label for="startDate">Start date</label>
                            <input class="form-control" type="date" id="startDate" name="startDate"
                                   value="${dashboardData.startDate}">
                        </div>

                        <div class="filter-field custom-date-field">
                            <label for="endDate">End date</label>
                            <input class="form-control" type="date" id="endDate" name="endDate"
                                   value="${dashboardData.endDate}">
                        </div>

                        <button class="btn btn-primary px-3" type="submit">
                            <i class="fa-solid fa-filter me-1"></i> Apply
                        </button>
                    </form>
                </div>
            </div>

            <c:if test="${not empty dashboardData.errorMessage}">
                <div class="alert alert-dashboard d-flex align-items-start gap-2 mb-4" role="alert">
                    <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                    <div>${dashboardData.errorMessage}</div>
                </div>
            </c:if>

            <p class="section-label">Sales performance</p>
            <div class="row g-3 mb-4">
                <div class="col-12 col-sm-6 col-xl-3">
                    <section class="metric-card">
                        <div class="metric-card-top">
                            <div>
                                <p class="metric-label">Net Revenue</p>
                                <p class="metric-value">
                                    <fmt:formatNumber value="${dashboardData.revenue}" pattern="#,##0"/> ₫
                                </p>
                            </div>
                            <span class="metric-icon icon-blue"><i class="fa-solid fa-chart-line"></i></span>
                        </div>
                        <div class="comparison">
                            <span>Compared with previous period</span>
                            <c:choose>
                                <c:when test="${dashboardData.revenueChangePercent > 0}">
                                    <span class="trend trend-up"><i class="fa-solid fa-arrow-up"></i>
                                        <fmt:formatNumber value="${dashboardData.revenueChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:when test="${dashboardData.revenueChangePercent < 0}">
                                    <span class="trend trend-down"><i class="fa-solid fa-arrow-down"></i>
                                        <fmt:formatNumber value="${-dashboardData.revenueChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="trend trend-flat"><i class="fa-solid fa-minus"></i> 0%</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <section class="metric-card">
                        <div class="metric-card-top">
                            <div>
                                <p class="metric-label">Completed Sales</p>
                                <p class="metric-value"><fmt:formatNumber value="${dashboardData.paidOrders}" pattern="#,##0"/></p>
                            </div>
                            <span class="metric-icon icon-green"><i class="fa-solid fa-bag-shopping"></i></span>
                        </div>
                        <div class="comparison">
                            <span>Paid or delivered orders</span>
                            <c:choose>
                                <c:when test="${dashboardData.paidOrdersChangePercent > 0}">
                                    <span class="trend trend-up"><i class="fa-solid fa-arrow-up"></i>
                                        <fmt:formatNumber value="${dashboardData.paidOrdersChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:when test="${dashboardData.paidOrdersChangePercent < 0}">
                                    <span class="trend trend-down"><i class="fa-solid fa-arrow-down"></i>
                                        <fmt:formatNumber value="${-dashboardData.paidOrdersChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="trend trend-flat"><i class="fa-solid fa-minus"></i> 0%</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <section class="metric-card">
                        <div class="metric-card-top">
                            <div>
                                <p class="metric-label">Average Order Value</p>
                                <p class="metric-value">
                                    <fmt:formatNumber value="${dashboardData.averageOrderValue}" pattern="#,##0"/> ₫
                                </p>
                            </div>
                            <span class="metric-icon icon-violet"><i class="fa-solid fa-receipt"></i></span>
                        </div>
                        <div class="comparison">
                            <span>Revenue per completed sale</span>
                            <span class="trend trend-flat"><i class="fa-solid fa-calculator"></i> AOV</span>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <section class="metric-card">
                        <div class="metric-card-top">
                            <div>
                                <p class="metric-label">New Customers</p>
                                <p class="metric-value"><fmt:formatNumber value="${dashboardData.newCustomers}" pattern="#,##0"/></p>
                            </div>
                            <span class="metric-icon icon-cyan"><i class="fa-solid fa-user-plus"></i></span>
                        </div>
                        <div class="comparison">
                            <span>New active customer accounts</span>
                            <c:choose>
                                <c:when test="${dashboardData.newCustomersChangePercent > 0}">
                                    <span class="trend trend-up"><i class="fa-solid fa-arrow-up"></i>
                                        <fmt:formatNumber value="${dashboardData.newCustomersChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:when test="${dashboardData.newCustomersChangePercent < 0}">
                                    <span class="trend trend-down"><i class="fa-solid fa-arrow-down"></i>
                                        <fmt:formatNumber value="${-dashboardData.newCustomersChangePercent}" maxFractionDigits="1"/>%
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="trend trend-flat"><i class="fa-solid fa-minus"></i> 0%</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>
            </div>

            <p class="section-label">Items requiring attention</p>
            <div class="row g-3 mb-4">
                <div class="col-12 col-sm-6 col-xl-3">
                    <a class="operation-card" href="${pageContext.request.contextPath}/admin/orders?status=PENDING">
                        <div>
                            <p class="operation-name">Pending Orders</p>
                            <p class="operation-value">${dashboardData.pendingOrders}</p>
                            <div class="operation-action">Review and confirm orders <i class="fa-solid fa-arrow-right ms-1"></i></div>
                        </div>
                        <span class="operation-icon icon-amber"><i class="fa-regular fa-clock"></i></span>
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <a class="operation-card" href="${pageContext.request.contextPath}/admin/orders?status=SHIPPING">
                        <div>
                            <p class="operation-name">Orders in Transit</p>
                            <p class="operation-value">${dashboardData.shippingOrders}</p>
                            <div class="operation-action">Track active deliveries <i class="fa-solid fa-arrow-right ms-1"></i></div>
                        </div>
                        <span class="operation-icon icon-blue"><i class="fa-solid fa-truck-fast"></i></span>
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <a class="operation-card" href="${pageContext.request.contextPath}/admin/inventory?action=list">
                        <div>
                            <p class="operation-name">Low Stock SKUs</p>
                            <p class="operation-value">${dashboardData.lowStockCount}</p>
                            <div class="operation-action">Stock level is 5 or below <i class="fa-solid fa-arrow-right ms-1"></i></div>
                        </div>
                        <span class="operation-icon icon-red"><i class="fa-solid fa-box-open"></i></span>
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <a class="operation-card" href="${pageContext.request.contextPath}/admin/feedback">
                        <div>
                            <p class="operation-name">Unanswered Feedback</p>
                            <p class="operation-value">${dashboardData.unansweredFeedbackCount}</p>
                            <div class="operation-action">Respond to customers <i class="fa-solid fa-arrow-right ms-1"></i></div>
                        </div>
                        <span class="operation-icon icon-violet"><i class="fa-regular fa-comments"></i></span>
                    </a>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-12 col-xl-8">
                    <section class="dashboard-panel">
                        <div class="panel-header">
                            <div>
                                <h2 class="panel-title">Revenue and Completed Sales</h2>
                                <p class="panel-subtitle">Payment performance across the selected reporting period.</p>
                            </div>
                            <span class="status-badge status-info">${dashboardData.rangeLabel}</span>
                        </div>
                        <div class="panel-body">
                            <div class="chart-area">
                                <canvas id="revenueChart" aria-label="Revenue and completed sales chart"></canvas>
                            </div>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-xl-4">
                    <section class="dashboard-panel">
                        <div class="panel-header">
                            <div>
                                <h2 class="panel-title">Order Status</h2>
                                <p class="panel-subtitle">Orders created during the selected period.</p>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="compact-chart-area">
                                <canvas id="orderStatusChart" aria-label="Order status distribution chart"></canvas>
                            </div>
                        </div>
                    </section>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-12 col-xl-7">
                    <section class="dashboard-panel">
                        <div class="panel-header">
                            <div>
                                <h2 class="panel-title">Top Selling Products</h2>
                                <p class="panel-subtitle">Ranked by sold quantity from completed sales.</p>
                            </div>
                            <a class="panel-link" href="${pageContext.request.contextPath}/admin/products">Manage products</a>
                        </div>

                        <c:choose>
                            <c:when test="${empty dashboardData.topProducts}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-chart-simple"></i>
                                    No paid product sales were recorded for this period.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table dashboard-table">
                                        <thead>
                                            <tr>
                                                <th>Rank</th>
                                                <th>Product</th>
                                                <th class="text-end">Units Sold</th>
                                                <th class="text-end">Orders</th>
                                                <th class="text-end">Product Revenue</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="product" items="${dashboardData.topProducts}" varStatus="status">
                                                <tr>
                                                    <td><span class="rank-number">${status.index + 1}</span></td>
                                                    <td class="primary-text"><c:out value="${product.productName}"/></td>
                                                    <td class="text-end">${product.soldQuantity}</td>
                                                    <td class="text-end">${product.orderCount}</td>
                                                    <td class="text-end primary-text">
                                                        <fmt:formatNumber value="${product.revenue}" pattern="#,##0"/> ₫
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </div>

                <div class="col-12 col-xl-5">
                    <section class="dashboard-panel">
                        <div class="panel-header">
                            <div>
                                <h2 class="panel-title">Inventory Alerts</h2>
                                <p class="panel-subtitle">Active SKUs with five units or fewer.</p>
                            </div>
                            <a class="panel-link" href="${pageContext.request.contextPath}/admin/inventory?action=IMPORT_PAGE">Import stock</a>
                        </div>

                        <c:choose>
                            <c:when test="${empty dashboardData.lowStockItems}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-circle-check"></i>
                                    Inventory levels are healthy.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table dashboard-table">
                                        <thead>
                                            <tr>
                                                <th>Product / SKU</th>
                                                <th class="text-end">Available</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${dashboardData.lowStockItems}">
                                                <tr>
                                                    <td>
                                                        <div class="primary-text"><c:out value="${item.productName}"/></div>
                                                        <div class="secondary-text"><c:out value="${item.sku}"/></div>
                                                    </td>
                                                    <td class="text-end primary-text">${item.stockQuantity}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.stockQuantity == 0}">
                                                                <span class="status-badge status-danger">Out of stock</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-warning">Low stock</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </div>
            </div>

            <section class="dashboard-panel">
                <div class="panel-header">
                    <div>
                        <h2 class="panel-title">Recent Orders</h2>
                        <p class="panel-subtitle">The eight most recently created orders across the system.</p>
                    </div>
                    <a class="panel-link" href="${pageContext.request.contextPath}/admin/orders">View all orders</a>
                </div>

                <c:choose>
                    <c:when test="${empty dashboardData.recentOrders}">
                        <div class="empty-state">
                            <i class="fa-solid fa-bag-shopping"></i>
                            No orders are available.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table dashboard-table">
                                <thead>
                                    <tr>
                                        <th>Order</th>
                                        <th>Customer</th>
                                        <th>Total</th>
                                        <th>Payment</th>
                                        <th>Order Status</th>
                                        <th>Shipping</th>
                                        <th>Created</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${dashboardData.recentOrders}">
                                        <tr>
                                            <td>
                                                <a class="panel-link"
                                                   href="${pageContext.request.contextPath}/admin/orders?action=view&id=${order.orderId}">
                                                    <c:out value="${order.orderCode}"/>
                                                </a>
                                            </td>
                                            <td class="primary-text"><c:out value="${order.customerName}"/></td>
                                            <td class="primary-text"><fmt:formatNumber value="${order.totalPayment}" pattern="#,##0"/> ₫</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.paymentStatus == 'PAID'}">
                                                        <span class="status-badge status-success">Paid</span>
                                                    </c:when>
                                                    <c:when test="${order.paymentStatus == 'FAILED' || order.paymentStatus == 'REFUNDED'}">
                                                        <span class="status-badge status-danger"><c:out value="${order.paymentStatus}"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge status-warning"><c:out value="${order.paymentStatus}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.orderStatus == 'DELIVERED'}">
                                                        <span class="status-badge status-success">Delivered</span>
                                                    </c:when>
                                                    <c:when test="${order.orderStatus == 'CANCELLED' || order.orderStatus == 'RETURNED'}">
                                                        <span class="status-badge status-danger"><c:out value="${order.orderStatus}"/></span>
                                                    </c:when>
                                                    <c:when test="${order.orderStatus == 'SHIPPING'}">
                                                        <span class="status-badge status-info">Shipping</span>
                                                    </c:when>
                                                    <c:when test="${order.orderStatus == 'CONFIRMED'}">
                                                        <span class="status-badge status-violet">Confirmed</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge status-warning">Pending</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.shippingStatus == 'DELIVERED'}">
                                                        <span class="status-badge status-success">Delivered</span>
                                                    </c:when>
                                                    <c:when test="${order.shippingStatus == 'FAILED'}">
                                                        <span class="status-badge status-danger">Failed</span>
                                                    </c:when>
                                                    <c:when test="${order.shippingStatus == 'SHIPPING'}">
                                                        <span class="status-badge status-info">Shipping</span>
                                                    </c:when>
                                                    <c:when test="${order.shippingStatus == 'PENDING_PICKUP'}">
                                                        <span class="status-badge status-warning">Pending pickup</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge status-neutral">Not created</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="secondary-text"><c:out value="${order.createdAt}"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const rangeSelect = document.getElementById('range');
                const customDateFields = document.querySelectorAll('.custom-date-field');
                const startDateInput = document.getElementById('startDate');
                const endDateInput = document.getElementById('endDate');

                function updateCustomDateVisibility() {
                    const customSelected = rangeSelect.value === 'custom';
                    customDateFields.forEach(function (field) {
                        field.classList.toggle('d-none', !customSelected);
                    });
                    startDateInput.required = customSelected;
                    endDateInput.required = customSelected;
                }

                rangeSelect.addEventListener('change', updateCustomDateVisibility);
                updateCustomDateVisibility();

                const revenueTrend = ${revenueTrendJson};
                const orderStatusData = ${orderStatusJson};
                const moneyFormatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'VND',
                    maximumFractionDigits: 0
                });

                const revenueCanvas = document.getElementById('revenueChart');
                if (revenueCanvas) {
                    new Chart(revenueCanvas, {
                        data: {
                            labels: revenueTrend.map(function (item) {
                                return item.label;
                            }),
                            datasets: [
                                {
                                    type: 'line',
                                    label: 'Revenue',
                                    data: revenueTrend.map(function (item) {
                                        return item.revenue;
                                    }),
                                    borderColor: '#2563eb',
                                    backgroundColor: 'rgba(37, 99, 235, 0.10)',
                                    borderWidth: 3,
                                    pointRadius: 3,
                                    pointHoverRadius: 5,
                                    tension: 0.32,
                                    fill: true,
                                    yAxisID: 'y'
                                },
                                {
                                    type: 'bar',
                                    label: 'Completed Sales',
                                    data: revenueTrend.map(function (item) {
                                        return item.orders;
                                    }),
                                    backgroundColor: 'rgba(5, 150, 105, 0.30)',
                                    borderColor: '#059669',
                                    borderWidth: 1,
                                    borderRadius: 5,
                                    maxBarThickness: 24,
                                    yAxisID: 'y1'
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            interaction: {mode: 'index', intersect: false},
                            plugins: {
                                legend: {
                                    position: 'top',
                                    align: 'end',
                                    labels: {usePointStyle: true, boxWidth: 8, padding: 18}
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            if (context.dataset.label === 'Revenue') {
                                                return ' Revenue: ' + moneyFormatter.format(context.parsed.y || 0);
                                            }
                                            return ' Completed Sales: ' + (context.parsed.y || 0).toLocaleString('en-US');
                                        }
                                    }
                                }
                            },
                            scales: {
                                x: {
                                    grid: {display: false},
                                    ticks: {maxRotation: 0, autoSkip: true, maxTicksLimit: 12}
                                },
                                y: {
                                    beginAtZero: true,
                                    position: 'left',
                                    grid: {color: '#eef2f7'},
                                    ticks: {
                                        callback: function (value) {
                                            if (value >= 1000000)
                                                return (value / 1000000) + 'M ₫';
                                            if (value >= 1000)
                                                return (value / 1000) + 'K ₫';
                                            return value + ' ₫';
                                        }
                                    }
                                },
                                y1: {
                                    beginAtZero: true,
                                    position: 'right',
                                    grid: {drawOnChartArea: false},
                                    ticks: {precision: 0}
                                }
                            }
                        }
                    });
                }

                const statusCanvas = document.getElementById('orderStatusChart');
                if (statusCanvas) {
                    const statusLabels = Object.keys(orderStatusData);
                    const statusValues = Object.values(orderStatusData);

                    new Chart(statusCanvas, {
                        type: 'doughnut',
                        data: {
                            labels: statusLabels,
                            datasets: [{
                                    data: statusValues,
                                    backgroundColor: ['#f59e0b', '#8b5cf6', '#0ea5e9', '#10b981', '#ef4444', '#64748b'],
                                    borderColor: '#ffffff',
                                    borderWidth: 3,
                                    hoverOffset: 5
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '68%',
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        usePointStyle: true,
                                        pointStyle: 'circle',
                                        boxWidth: 8,
                                        padding: 14,
                                        font: {size: 11}
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            return ' ' + context.label + ': ' + context.parsed.toLocaleString('en-US');
                                        }
                                    }
                                }
                            }
                        }
                    });
                }
            });
        </script>
    </body>
</html>