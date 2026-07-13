<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Thành phần Sidebar dùng chung hệ thống
    String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : null;
    String displayRole = "STAFF".equalsIgnoreCase(roleName) ? "Warehouse Staff" : "Administrator";
    String badgeClass = "STAFF".equalsIgnoreCase(roleName) ? "bg-success" : "bg-primary";

    // Tạo tiền tố URL động dựa trên Role để dùng cho các tính năng chung
    String rolePrefix = "STAFF".equalsIgnoreCase(roleName) ? "/staff" : "/admin";
    request.setAttribute("rolePrefix", rolePrefix);

    String username = (session != null) ? (String) session.getAttribute("authUsername") : null;
    String userInitials = "US";
    if (username != null && !username.isBlank()) {
        userInitials = username.length() >= 2 ? username.substring(0, 2) : username.substring(0, 1);
        userInitials = userInitials.toUpperCase();
    }

    // Tự xác định mục đang mở nếu trang cha chưa truyền activeTab.
    String activeTab = request.getParameter("activeTab");
    if (activeTab == null || activeTab.isBlank()) {
        String path = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (path != null && contextPath != null && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }

        if (path != null) {
            if (path.startsWith("/admin/dashboard") || path.startsWith("/dashboard")) {
                activeTab = "products".equalsIgnoreCase(request.getParameter("tab")) ? "products" : "dashboard";
            } else if (path.startsWith("/admin/manage-product")
                    || path.startsWith("/admin/products")
                    || path.startsWith("/AdminManageProduct")
                    || path.startsWith("/product-detail")) {
                activeTab = "products";
            } else if (path.startsWith("/admin/inventory")) {
                activeTab = "inventory";
            } else if (path.startsWith("/admin/manage-category")
                    || path.startsWith("/admin/categories")
                    || path.startsWith("/view/admin/admin_category.jsp")) {
                activeTab = "categories";
            } else if (path.startsWith("/admin/discounts")) {
                activeTab = "discounts";
            } else if (path.startsWith("/admin/voucher")
                    || path.startsWith("/view/admin/admin_voucher_list.jsp")
                    || path.startsWith("/view/admin/admin_create_voucher.jsp")
                    || path.startsWith("/view/admin/admin_edit_voucher.jsp")) {
                activeTab = "discounts";
            } else if (path.startsWith("/admin/orders") || path.startsWith("/staff/orders")) {
                activeTab = "orders";
            } else if (path.startsWith("/admin/shipments") || path.startsWith("/staff/shipments")) {
                // BỔ SUNG: Tự động nhận diện highlight mục vận chuyển
                activeTab = "shipments";
            } else if (path.startsWith("/admin/customers") || path.startsWith("/staff/customers")) {
                activeTab = "customers";
            } else if (path.startsWith("/admin/feedback") || path.startsWith("/staff/feedback")) {
                activeTab = "feedback";
            } else if (path.startsWith("/staff/products")) {
                activeTab = "products";
            } else if (path.startsWith("/admin/staffs")) {
                activeTab = "staffs";
            }
        }
    }
    request.setAttribute("sidebarActiveTab", activeTab);
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
<style>
    .sidebar-shell {
        flex: 0 0 260px;
        width: 260px;
        max-width: 260px;
        min-height: 100vh;
        height: 100vh;
        background: linear-gradient(180deg, #111827 0%, #0f172a 100%);
        color: #e5e7eb;
        font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        line-height: 1.35;
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        z-index: 20;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
        box-shadow: 0 20px 45px rgba(15, 23, 42, 0.22);
    }
    .sidebar-brand {
        padding: 1.15rem 1rem;
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }
    .sidebar-brand-title {
        color: #fff;
        font-size: 1.15rem;
        font-weight: 800;
        margin: 0;
        letter-spacing: .01em;
    }
    .sidebar-brand-title i {
        color: #60a5fa;
    }
    .sidebar-nav {
        padding: .75rem 0;
        display: flex;
        flex-direction: column;
        gap: .15rem;
    }
    .sidebar-nav a {
        color: #cbd5e1;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: .75rem;
        padding: .85rem 1.15rem;
        font-weight: 600;
        border-left: 4px solid transparent;
        transition: background-color .2s ease, color .2s ease, border-color .2s ease;
    }
    .sidebar-nav a:hover,
    .sidebar-nav a.active {
        background: rgba(255, 255, 255, 0.06);
        color: #fff;
        border-left-color: #3b82f6;
    }
    .sidebar-nav i {
        width: 1.2rem;
        text-align: center;
        flex-shrink: 0;
    }
    .sidebar-icon {
        margin-right: 0.15rem;
    }
    .sidebar-link {
        width: 100%;
    }
    .sidebar-footer {
        margin-top: auto;
        padding: 1rem;
        border-top: 1px solid rgba(255, 255, 255, 0.08);
        background: rgba(15, 23, 42, 0.96);
    }
    .sidebar-user-pill {
        width: 40px;
        height: 40px;
        border-radius: 999px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-weight: 800;
        flex-shrink: 0;
    }
    .sidebar-user-role {
        font-size: .78rem;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: .35rem;
        margin-top: .2rem;
    }
    .sidebar-user-dot {
        width: 6px;
        height: 6px;
        border-radius: 999px;
        display: inline-block;
    }
    .sidebar-logout {
        width: 34px;
        height: 34px;
        border: 1px solid #ef4444;
        border-radius: 8px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #ef4444;
        background: transparent;
        text-decoration: none;
        flex-shrink: 0;
        transition: background-color .2s ease, color .2s ease, border-color .2s ease;
    }
    .sidebar-logout:hover {
        background: rgba(239, 68, 68, 0.12);
        color: #fecaca;
        border-color: #f87171;
    }
    .text-sm {
        font-size: .875rem;
    }
    .text-xs {
        font-size: .75rem;
    }
    .min-w-0 {
        min-width: 0;
    }
    @media (max-width: 767.98px) {
        .sidebar-shell {
            display: none;
        }
    }
    @media (min-width: 768px) {
        .sidebar-shell {
            display: flex;
        }
    }
</style>

<div class="sidebar-shell">
    <div class="sidebar-brand">
        <h4 class="sidebar-brand-title mb-0"><i class="fa-solid fa-shirt sidebar-icon"></i>Clothing Sale</h4>
    </div>
    <div class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link ${requestScope.sidebarActiveTab == 'dashboard' ? 'active' : ''}">
            <i class="fa-solid fa-chart-line sidebar-icon"></i>Dashboard
        </a>

        <c:choose>
            <c:when test="${sessionScope.authRoleName == 'STAFF'}">
                <a href="${pageContext.request.contextPath}/staff/products" class="sidebar-link ${requestScope.sidebarActiveTab == 'products' ? 'active' : ''}">
                    <i class="fa-solid fa-box sidebar-icon"></i>Products
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}${rolePrefix}/products" class="sidebar-link ${requestScope.sidebarActiveTab == 'products' ? 'active' : ''}">
                    <i class="fa-solid fa-box sidebar-icon"></i>Products
                </a>
                <a href="${pageContext.request.contextPath}/admin/inventory" class="sidebar-link ${requestScope.sidebarActiveTab == 'inventory' ? 'active' : ''}">
                    <i class="fa-solid fa-warehouse sidebar-icon"></i>Inventory
                </a>
                <a href="${pageContext.request.contextPath}/admin/manage-category" class="sidebar-link ${requestScope.sidebarActiveTab == 'categories' ? 'active' : ''}">
                    <i class="fa-solid fa-tags sidebar-icon"></i>Categories
                </a>
                <a class="sidebar-link ${requestScope.sidebarActiveTab == 'discounts' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/voucher?action=list">
                    <i class="fas fa-ticket-alt sidebar-icon"></i> 
                    <span>Vouchers</span>
                </a>
                <%-- Mục này chỉ dành cho ADMIN nên cần active riêng khi đang ở trang quản lý staff. --%>
                <a href="${pageContext.request.contextPath}/admin/staffs" class="sidebar-link ${requestScope.sidebarActiveTab == 'staffs' ? 'active' : ''}">
                    <i class="fa-solid fa-user-tie sidebar-icon"></i> Manage Staff
                </a>
            </c:otherwise>
        </c:choose>

        <a href="${pageContext.request.contextPath}${rolePrefix}/orders" class="sidebar-link ${requestScope.sidebarActiveTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-receipt sidebar-icon"></i>Orders
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/shipments" class="sidebar-link ${requestScope.sidebarActiveTab == 'shipments' ? 'active' : ''}">
            <i class="fa-solid fa-truck sidebar-icon"></i>Shipments
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/customers" class="sidebar-link ${requestScope.sidebarActiveTab == 'customers' ? 'active' : ''}">
            <i class="fa-solid fa-users sidebar-icon"></i>Customers
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/feedback" class="sidebar-link ${requestScope.sidebarActiveTab == 'feedback' ? 'active' : ''}">
            <i class="fa-solid fa-comments sidebar-icon"></i>Feedback
        </a>
        <a href="${pageContext.request.contextPath}/staff/reports" class="sidebar-link ${requestScope.sidebarActiveTab == 'reports' ? 'active' : ''}">
            <i class="fa-solid fa-chart-pie sidebar-icon"></i>Revenue Reports
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="d-flex align-items-center gap-3">
            <div class="sidebar-user-pill" style="background-color: #6366f1;">
                <c:out value="${userInitials}"/>
            </div>
            <div class="min-w-0 flex-grow-1">
                <div class="text-sm fw-bold text-white text-truncate">
                    <c:choose>
                        <c:when test="${not empty sessionScope.authFullName}">
                            <c:out value="${sessionScope.authFullName}"/>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${sessionScope.authUsername}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="sidebar-user-role">
                    <span class="sidebar-user-dot <%= badgeClass%>"></span>
                    <%= displayRole%>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/logout" class="sidebar-logout" onclick="return confirm('Are you sure you want to sign out?');" title="Sign out">
                <i class="fa-solid fa-right-from-bracket"></i>
            </a>
        </div>
    </div>
</div>
