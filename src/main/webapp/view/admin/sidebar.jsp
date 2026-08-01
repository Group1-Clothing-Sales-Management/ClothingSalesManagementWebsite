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
            } else if (path.startsWith("/admin/prices") || path.startsWith("/AdminPrice")) {
                activeTab = "prices";
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
            } else if (path.startsWith("/admin/returns") || path.startsWith("/staff/returns")) {
                activeTab = "returns";
            } else if (path.startsWith("/staff/reports")) {
                activeTab = "reports";
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
        flex: 0 0 var(--admin-sidebar-width, 224px);
        width: var(--admin-sidebar-width, 224px);
        max-width: var(--admin-sidebar-width, 224px);
        min-height: 100vh;
        height: 100vh;
        background: linear-gradient(180deg, #121b2c 0%, #0d1626 100%);
        color: #e5e7eb;
        font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        line-height: 1.35;
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        z-index: 20;
        overflow-y: auto;
        scrollbar-gutter: stable;
        -webkit-overflow-scrolling: touch;
        box-shadow: 4px 0 24px rgba(15, 23, 42, 0.12);
    }
    .sidebar-brand {
        min-height: 58px;
        padding: .75rem .8rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: .55rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }
    .sidebar-brand-title {
        min-width: 0;
        display: inline-flex;
        align-items: center;
        gap: .55rem;
        color: #fff;
        font-size: 1rem;
        font-weight: 800;
        margin: 0;
        letter-spacing: .01em;
        white-space: nowrap;
    }
    .sidebar-brand-title i {
        color: #60a5fa;
    }
    .sidebar-collapse {
        width: 30px;
        height: 30px;
        flex: 0 0 30px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid rgba(255, 255, 255, .12);
        border-radius: 8px;
        color: #94a3b8;
        background: rgba(255, 255, 255, .04);
        transition: color .2s ease, background-color .2s ease, transform .2s ease;
    }
    .sidebar-collapse:hover,
    .sidebar-collapse:focus-visible {
        color: #ffffff;
        background: rgba(255, 255, 255, .1);
        outline: none;
    }
    .sidebar-nav {
        padding: .45rem;
        display: flex;
        flex-direction: column;
        gap: .08rem;
    }
    .sidebar-nav a {
        color: #cbd5e1;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: .65rem;
        min-height: 39px;
        padding: .62rem .75rem;
        border-radius: 8px;
        font-size: .84rem;
        font-weight: 600;
        border: 1px solid transparent;
        transition: background-color .2s ease, color .2s ease, border-color .2s ease;
    }
    .sidebar-nav a:hover,
    .sidebar-nav a.active {
        background: rgba(96, 165, 250, .11);
        color: #fff;
        border-color: rgba(96, 165, 250, .16);
    }
    .sidebar-nav a.active {
        color: #ffffff;
        background: linear-gradient(90deg, rgba(37, 99, 235, .28), rgba(37, 99, 235, .12));
        box-shadow: inset 3px 0 0 #60a5fa;
    }
    .sidebar-nav i {
        width: 1rem;
        text-align: center;
        flex-shrink: 0;
        color: #94a3b8;
    }
    .sidebar-nav a:hover i,
    .sidebar-nav a.active i {
        color: #93c5fd;
    }
    .sidebar-icon {
        margin-right: 0;
    }
    .sidebar-link {
        width: 100%;
    }
    .sidebar-footer {
        margin-top: auto;
        padding: .7rem .75rem;
        border-top: 1px solid rgba(255, 255, 255, 0.08);
        background: rgba(15, 23, 42, 0.96);
    }
    .sidebar-user {
        display: flex;
        align-items: center;
        gap: .65rem;
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
    .admin-shell.is-sidebar-collapsed .sidebar-brand {
        justify-content: center;
        padding-inline: .45rem;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-brand-title {
        display: none;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-collapse i {
        transform: rotate(180deg);
    }
    .admin-shell.is-sidebar-collapsed .sidebar-nav {
        padding-inline: .45rem;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-nav a {
        justify-content: center;
        min-height: 42px;
        padding: .65rem .45rem;
        box-shadow: none;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-nav a.active {
        box-shadow: inset 0 -3px 0 #60a5fa;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-label,
    .admin-shell.is-sidebar-collapsed .sidebar-user-copy {
        display: none;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-footer {
        padding-inline: .45rem;
    }
    .admin-shell.is-sidebar-collapsed .sidebar-user {
        justify-content: center;
    }
    @media (max-width: 767.98px) {
        .sidebar-shell {
            display: none;
            width: 224px;
            max-width: 224px;
            flex-basis: 224px;
        }
        .sidebar-collapse {
            display: none;
        }
        .admin-shell.is-sidebar-collapsed .sidebar-brand {
            justify-content: space-between;
        }
        .admin-shell.is-sidebar-collapsed .sidebar-brand-title {
            display: inline-flex;
        }
        .admin-shell.is-sidebar-collapsed .sidebar-nav a {
            justify-content: flex-start;
            min-height: 39px;
            padding: .62rem .75rem;
        }
        .admin-shell.is-sidebar-collapsed .sidebar-label,
        .admin-shell.is-sidebar-collapsed .sidebar-user-copy {
            display: block;
        }
    }
    @media (min-width: 768px) {
        .sidebar-shell {
            display: flex;
        }
    }
</style>

<div class="sidebar-shell" id="adminSidebarNavigation">
    <div class="sidebar-brand">
        <h4 class="sidebar-brand-title mb-0">
            <i class="fa-solid fa-shirt sidebar-icon"></i>
            <span class="sidebar-label">Clothing Sale</span>
        </h4>
        <button type="button"
                class="sidebar-collapse"
                data-admin-sidebar-collapse
                aria-label="Collapse navigation"
                aria-expanded="true"
                title="Collapse navigation">
            <i class="fa-solid fa-chevron-left" aria-hidden="true"></i>
        </button>
    </div>
    <div class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'dashboard' ? 'active' : ''}"
           title="Dashboard">
            <i class="fa-solid fa-chart-line sidebar-icon"></i>
            <span class="sidebar-label">Dashboard</span>
        </a>

        <c:choose>
            <c:when test="${sessionScope.authRoleName == 'STAFF'}">
                <a href="${pageContext.request.contextPath}/staff/products"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'products' ? 'active' : ''}"
                   title="Products">
                    <i class="fa-solid fa-box sidebar-icon"></i>
                    <span class="sidebar-label">Products</span>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}${rolePrefix}/products"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'products' ? 'active' : ''}"
                   title="Products">
                    <i class="fa-solid fa-box sidebar-icon"></i>
                    <span class="sidebar-label">Products</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/inventory"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'inventory' ? 'active' : ''}"
                   title="Inventory">
                    <i class="fa-solid fa-warehouse sidebar-icon"></i>
                    <span class="sidebar-label">Inventory</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/prices"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'prices' ? 'active' : ''}"
                   title="Price Management">
                    <i class="fa-solid fa-coins sidebar-icon"></i>
                    <span class="sidebar-label">Price Management</span>
                </a>
                
                <a href="${pageContext.request.contextPath}/admin/manage-category"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'categories' ? 'active' : ''}"
                   title="Categories">
                    <i class="fa-solid fa-tags sidebar-icon"></i>
                    <span class="sidebar-label">Categories</span>
                </a>
                <a class="sidebar-link ${requestScope.sidebarActiveTab == 'discounts' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/admin/voucher?action=list"
                   title="Vouchers">
                    <i class="fas fa-ticket-alt sidebar-icon"></i> 
                    <span class="sidebar-label">Vouchers</span>
                </a>
                <%-- Mục này chỉ dành cho ADMIN nên cần active riêng khi đang ở trang quản lý staff. --%>
                <a href="${pageContext.request.contextPath}/admin/staffs"
                   class="sidebar-link ${requestScope.sidebarActiveTab == 'staffs' ? 'active' : ''}"
                   title="Manage Staff">
                    <i class="fa-solid fa-user-tie sidebar-icon"></i>
                    <span class="sidebar-label">Manage Staff</span>
                </a>
            </c:otherwise>
        </c:choose>

        <a href="${pageContext.request.contextPath}${rolePrefix}/orders"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'orders' ? 'active' : ''}"
           title="Orders">
            <i class="fa-solid fa-receipt sidebar-icon"></i>
            <span class="sidebar-label">Orders</span>
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/shipments"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'shipments' ? 'active' : ''}"
           title="Shipments">
            <i class="fa-solid fa-truck sidebar-icon"></i>
            <span class="sidebar-label">Shipments</span>
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/customers"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'customers' ? 'active' : ''}"
           title="Customers">
            <i class="fa-solid fa-users sidebar-icon"></i>
            <span class="sidebar-label">Customers</span>
        </a>

        <a href="${pageContext.request.contextPath}${rolePrefix}/feedback"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'feedback' ? 'active' : ''}"
           title="Feedback">
            <i class="fa-solid fa-comments sidebar-icon"></i>
            <span class="sidebar-label">Feedback</span>
        </a>
        <%-- Link này dùng rolePrefix để Staff và Admin đi vào đúng URL của mình. --%>
        <a href="${pageContext.request.contextPath}${rolePrefix}/returns"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'returns' ? 'active' : ''}"
           title="Returns &amp; Refunds">
            <i class="fa-solid fa-rotate-left sidebar-icon"></i>
            <span class="sidebar-label">Returns &amp; Refunds</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/reports"
           class="sidebar-link ${requestScope.sidebarActiveTab == 'reports' ? 'active' : ''}"
           title="Revenue Reports">
            <i class="fa-solid fa-chart-pie sidebar-icon"></i>
            <span class="sidebar-label">Revenue Reports</span>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="sidebar-user-copy min-w-0 flex-grow-1">
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
            <a href="${pageContext.request.contextPath}/admin/logout"
               class="sidebar-logout"
               data-confirm="Are you sure you want to sign out?"
               data-confirm-title="Sign out"
               data-confirm-label="Sign out"
               title="Sign out">
                <i class="fa-solid fa-right-from-bracket"></i>
            </a>
        </div>
    </div>
</div>
