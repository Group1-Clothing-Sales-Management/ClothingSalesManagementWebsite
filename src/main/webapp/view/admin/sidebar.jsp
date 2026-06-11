<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : null;
    String displayRole = "STAFF".equalsIgnoreCase(roleName) ? "Warehouse Staff" : "Administrator";
    String badgeColor  = "STAFF".equalsIgnoreCase(roleName) ? "#10b981" : "#6366f1";
%>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
<style>
    .sidebar {
        width: 230px;
        min-width: 230px;
        background: #0f172a;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        position: relative;
        flex-shrink: 0;
    }
    .sidebar .sidebar-brand {
        padding: 18px 20px;
        font-size: 1.1rem;
        font-weight: 700;
        color: #fff;
        border-bottom: 1px solid #1e293b;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        letter-spacing: .02em;
    }
    .sidebar .sidebar-brand:hover { background: #1e293b; }
    .sidebar .sidebar-brand i { color: #818cf8; }

    .sidebar nav { flex: 1; padding: 12px 10px; display: flex; flex-direction: column; gap: 4px; }
    .sidebar nav a {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 14px;
        border-radius: 8px;
        font-size: .875rem;
        font-weight: 500;
        color: #94a3b8;
        text-decoration: none;
        transition: background .15s, color .15s;
    }
    .sidebar nav a:hover  { background: #1e293b; color: #fff; }
    .sidebar nav a.active { background: #4f46e5; color: #fff; font-weight: 600; box-shadow: 0 2px 8px rgba(79,70,229,.35); }
    .sidebar nav a i { width: 18px; text-align: center; font-size: .95rem; }

    .sidebar .sidebar-footer {
        padding: 14px 16px;
        border-top: 1px solid #1e293b;
        background: #0f172a;
    }
    .sidebar .sidebar-footer .user-avatar {
        width: 38px; height: 38px;
        border-radius: 50%;
        background: #6366f1;
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: .85rem; color: #fff;
        flex-shrink: 0;
    }
    .sidebar .sidebar-footer .user-name {
        font-size: .85rem; font-weight: 600; color: #fff;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        max-width: 110px;
    }
    .sidebar .sidebar-footer .user-role {
        font-size: .75rem; color: #94a3b8;
        display: flex; align-items: center; gap: 5px; margin-top: 2px;
    }
    .sidebar .sidebar-footer .role-dot {
        width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
    }
    .sidebar .sidebar-footer .btn-logout {
        background: transparent;
        border: 1px solid #ef4444;
        color: #ef4444;
        border-radius: 7px;
        padding: 5px 10px;
        font-size: .8rem;
        font-weight: 600;
        text-decoration: none;
        white-space: nowrap;
        transition: background .15s, color .15s;
    }
    .sidebar .sidebar-footer .btn-logout:hover { background: #ef4444; color: #fff; }
</style>

<div class="sidebar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-brand">
        <i class="fa-solid fa-shirt"></i>
        <span>Clothing Sale</span>
    </a>

    <nav>
        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="${param.activeTab == 'dashboard' ? 'active' : ''}">
            <i class="fa-solid fa-chart-line"></i>Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/admin/dashboard?tab=products"
           class="${param.activeTab == 'products' ? 'active' : ''}">
            <i class="fa-solid fa-box"></i>Manage Products
        </a>
        <a href="#" class="${param.activeTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-receipt"></i>Orders
        </a>
        <a href="${pageContext.request.contextPath}/staff/customers"
           class="${param.activeTab == 'customers' ? 'active' : ''}">
            <i class="fa-solid fa-users"></i>Customers
        </a>
        <a href="#" class="${param.activeTab == 'discounts' ? 'active' : ''}">
            <i class="fa-solid fa-ticket"></i>Discount Codes
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="d-flex align-items-center gap-2">
            <div class="user-avatar">
                ${not empty sessionScope.authUsername ? sessionScope.authUsername.substring(0,2).toUpperCase() : 'US'}
            </div>
            <div style="flex:1; min-width:0;">
                <div class="user-name">
                    <c:choose>
                        <c:when test="${not empty sessionScope.authFullName}">
                            <c:out value="${sessionScope.authFullName}"/>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${sessionScope.authUsername}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="user-role">
                    <span class="role-dot" style="background-color: <%= badgeColor %>;"></span>
                    <%= displayRole %>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/logout"
               class="btn-logout"
               onclick="return confirm('Are you sure you want to sign out?');">
                <i class="fa-solid fa-right-from-bracket me-1"></i>Sign out
            </a>
        </div>
    </div>
</div>
