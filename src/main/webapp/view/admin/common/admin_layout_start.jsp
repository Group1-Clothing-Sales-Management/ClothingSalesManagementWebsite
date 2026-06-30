<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .admin-shell {
        display: flex;
        min-height: 100vh;
        width: 100%;
        overflow: hidden;
        background: #f5f7fb;
    }
    .admin-shell-sidebar {
        flex: 0 0 260px;
        width: 260px;
        max-width: 260px;
    }
    .admin-shell-content {
        flex: 1;
        min-width: 0;
        height: 100vh;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
    }
    @media (max-width: 767.98px) {
        .admin-shell {
            min-height: 100vh;
        }
        .admin-shell-sidebar {
            display: none;
        }
        .admin-shell-content {
            height: auto;
            min-height: 100vh;
        }
    }
</style>
<div class="admin-shell">
    <div class="admin-shell-sidebar">
        <jsp:include page="/view/admin/sidebar.jsp">
            <jsp:param name="activeTab" value="${param.activeTab}" />
        </jsp:include>
    </div>
    <div class="admin-shell-content">
