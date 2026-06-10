<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String roleName = (session != null) ? (String) session.getAttribute("authRoleName") : null;
    String displayRole = "STAFF".equalsIgnoreCase(roleName) ? "Nhân viên kho" : "Quản trị viên";
    String badgeClass = "STAFF".equalsIgnoreCase(roleName) ? "bg-emerald-400" : "bg-primary";
%>
<div class="col-md-2 px-0 sidebar d-none d-md-block shadow">
    <div class="p-3 text-center border-bottom border-secondary">
        <h4 class="text-white mb-0 fw-bold"><i class="fa-solid fa-shirt me-2"></i>Clothing Sale</h4>
    </div>
    <div class="py-2 flex-grow-1">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="${param.activeTab == 'dashboard' ? 'active' : ''}">
            <i class="fa-solid fa-chart-line me-2"></i>Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/admin/dashboard?tab=products" class="${param.activeTab == 'products' ? 'active' : ''}">
            <i class="fa-solid fa-box me-2"></i>Manage Products
        </a>
        <a href="#"><i class="fa-solid fa-receipt me-2"></i>Orders</a>

        <a href="${pageContext.request.contextPath}/staff/customers" class="${param.activeTab == 'customers' ? 'active' : ''}">
            <i class="fa-solid fa-users me-2"></i>Customers
        </a>

        <a href="#"><i class="fa-solid fa-ticket me-2"></i>Discount Codes</a>
    </div>

    <div class="p-3 border-top border-secondary bg-dark text-white" style="position: absolute; bottom: 0; width: 100%;">
        <div class="d-flex align-items-center gap-3">
            <div class="rounded-circle bg-indigo flex-shrink-0 d-flex align-items-center justify-center text-white font-bold"
                 style="width: 40px; height: 40px; background-color: #6366f1; justify-content: center;">
                ${not empty sessionScope.authUsername ? sessionScope.authUsername.substring(0,2).toUpperCase() : 'US'}
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
                <div class="text-xs text-muted d-flex align-items-center gap-1 mt-1">
                    <span class="rounded-circle inline-block <%= badgeClass%>" style="width: 6px; height: 6px; display: inline-block;"></span>
                    <%= displayRole%>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/logout" class="text-danger fs-5 ms-auto" title="Đăng xuất">
                <i class="fa-solid fa-right-from-bracket"></i>
            </a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-outline-danger d-flex align-items-center gap-2" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Đăng xuất</span>
            </a>
        </div>
    </div>
</div>