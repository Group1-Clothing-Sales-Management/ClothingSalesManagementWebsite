<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // This sidebar is shared by multiple pages, so it keeps its own styles.
    // That way it does not depend on the parent page CSS.
    String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : null;
    String displayRole = "STAFF".equalsIgnoreCase(roleName) ? "Warehouse Staff" : "Administrator";
    String badgeClass = "STAFF".equalsIgnoreCase(roleName) ? "bg-success" : "bg-primary";
    String username = (session != null) ? (String) session.getAttribute("authUsername") : null;
    String userInitials = "US";
    if (username != null && !username.isBlank()) {
        userInitials = username.length() >= 2 ? username.substring(0, 2) : username.substring(0, 1);
        userInitials = userInitials.toUpperCase();
    }
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
<style>
    /* Shared sidebar styling for all admin/staff pages */
    .sidebar-shell {
        min-height: 100vh;
        height: 100vh;
        background: linear-gradient(180deg, #111827 0%, #0f172a 100%);
        color: #e5e7eb;
        display: flex;
        flex-direction: column;
        position: relative;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
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

    /* Small utility helpers used only inside the sidebar */
    .text-sm {
        font-size: .875rem;
    }

    .text-xs {
        font-size: .75rem;
    }

    .min-w-0 {
        min-width: 0;
    }
</style>

<div class="col-md-2 px-0 sidebar-shell d-none d-md-flex shadow">
    <div class="sidebar-brand">
        <h4 class="sidebar-brand-title mb-0"><i class="fa-solid fa-shirt me-2"></i>Clothing Sale</h4>
    </div>
    <div class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="${param.activeTab == 'dashboard' ? 'active' : ''}">
            <i class="fa-solid fa-chart-line me-2"></i>Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/staff/products" class="${param.activeTab == 'products' ? 'active' : ''}">
            <i class="fa-solid fa-box me-2"></i>Manage Products
        </a>
        <a href="${pageContext.request.contextPath}/staff/orders" class="${param.activeTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-receipt me-2"></i>Orders
        </a>

        <a href="${pageContext.request.contextPath}/staff/customers" class="${param.activeTab == 'customers' ? 'active' : ''}">
            <i class="fa-solid fa-users me-2"></i>Customers
        </a>

        <a href="#"><i class="fa-solid fa-ticket me-2"></i>Discount Codes</a>
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
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-outline-danger d-flex align-items-center gap-2" onclick="return confirm('Are you sure you want to sign out?');">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Sign out</span>
            </a>
        </div>
    </div>
</div>
