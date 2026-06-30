<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    :root {
        --admin-bg: #f5f7fb;
        --admin-surface: #ffffff;
        --admin-surface-soft: #f8fbff;
        --admin-border: #e5e7eb;
        --admin-border-soft: #eef2f7;
        --admin-text: #111827;
        --admin-muted: #6b7280;
        --admin-primary: #2563eb;
        --admin-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
        --admin-shadow-soft: 0 2px 12px rgba(0, 0, 0, 0.07);
        --admin-radius: 16px;
    }

    body {
        background: var(--admin-bg);
        color: var(--admin-text);
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    .admin-shell {
        display: flex;
        min-height: 100vh;
        width: 100%;
        overflow: hidden;
        background: var(--admin-bg);
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

    .admin-page,
    .main-content,
    .content-area {
        min-width: 0;
        padding: 28px 32px 36px;
    }

    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 24px;
    }

    .page-title {
        font-size: 1.5rem;
        font-weight: 800;
        color: var(--admin-text) !important;
        margin: 0;
        line-height: 1.2;
    }

    .page-title .bi,
    .page-title .fa,
    .page-title .fas,
    .page-title .fa-solid {
        color: var(--admin-primary) !important;
        margin-right: 10px;
    }

    .page-subtitle,
    .subtext {
        color: var(--admin-muted);
        font-size: .95rem;
    }

    .card-main,
    .admin-card {
        border: none;
        border-radius: var(--admin-radius);
        box-shadow: var(--admin-shadow);
        overflow: hidden;
        background: var(--admin-surface);
    }

    .admin-page .card,
    .main-content .card,
    .content-area .card {
        border: none;
        border-radius: var(--admin-radius);
        box-shadow: var(--admin-shadow);
        background: var(--admin-surface);
    }

    .card-main .card-header,
    .admin-card .card-header,
    .admin-card-header,
    .admin-page .card-header {
        background: var(--admin-surface) !important;
        color: var(--admin-text) !important;
        border-bottom: 1px solid var(--admin-border-soft) !important;
        padding: 18px 24px;
    }

    .card-main .card-footer,
    .admin-card .card-footer,
    .admin-card-footer {
        background: var(--admin-surface-soft);
        border-top: 1px solid var(--admin-border-soft);
        padding: 16px 24px;
    }

    .card-main .table,
    .admin-table {
        margin-bottom: 0;
    }

    .card-main .table thead th,
    .admin-table thead th,
    .admin-page .table thead th {
        background: #1f2937 !important;
        color: #ffffff !important;
        font-weight: 700;
        font-size: .85rem;
        white-space: nowrap;
        border: none;
    }

    .card-main .table tbody tr:hover,
    .admin-table tbody tr:hover,
    .admin-page .table tbody tr:hover {
        background: #f8fbff;
    }

    .admin-table td {
        vertical-align: middle;
    }

    .badge-soft,
    .admin-badge-soft {
        background: #f3f4f6;
        color: #374151;
        border: 1px solid #e5e7eb;
    }

    .admin-empty-state,
    .empty-state {
        padding: 64px 20px;
        text-align: center;
        color: #9ca3af;
    }

    .admin-empty-state i,
    .admin-empty-state .bi,
    .empty-state i,
    .empty-state .bi {
        font-size: 2.75rem;
        display: block;
        margin-bottom: 12px;
    }

    .admin-field-label,
    .detail-label,
    .field-label {
        font-size: .78rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: .04em;
        color: var(--admin-muted);
        margin-bottom: 6px;
    }

    .admin-field-value,
    .detail-box,
    .field-value,
    .field-readonly {
        background: #f9fafb;
        border: 1px solid var(--admin-border);
        border-radius: 12px;
        padding: 10px 14px;
        color: var(--admin-text);
    }

    .admin-detail-box {
        background: #f9fafb;
        border: 1px solid var(--admin-border);
        border-radius: 14px;
        padding: 16px;
    }

    .admin-pill,
    .status-pill,
    .rating-pill {
        border-radius: 999px;
        padding: .35rem .75rem;
        font-size: .78rem;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        border: 1px solid transparent;
    }

    .admin-pill--success,
    .status-replied {
        background: #ecfdf5;
        color: #047857;
        border-color: #a7f3d0;
    }

    .admin-pill--warning,
    .status-pending {
        background: #fff7ed;
        color: #9a3412;
        border-color: #fed7aa;
    }

    .admin-pill--info {
        background: #eff6ff;
        color: #1d4ed8;
        border-color: #bfdbfe;
    }

    .admin-pill--danger {
        background: #fef2f2;
        color: #b91c1c;
        border-color: #fecaca;
    }

    .admin-search-bar,
    .search-bar-wrapper {
        background: var(--admin-surface);
        border: 1px solid var(--admin-border);
        border-radius: 16px;
        padding: 16px;
        box-shadow: var(--admin-shadow-soft);
    }

    .admin-breadcrumb,
    .breadcrumb {
        font-size: .82rem;
        margin-bottom: 6px;
    }

    .admin-breadcrumb a,
    .breadcrumb a {
        color: var(--admin-primary);
        text-decoration: none;
    }

    .admin-breadcrumb a:hover,
    .breadcrumb a:hover {
        text-decoration: underline;
    }

    .admin-toast-stack {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1080;
        display: flex;
        flex-direction: column;
        gap: 12px;
        width: min(380px, calc(100vw - 32px));
        pointer-events: none;
    }

    .admin-toast {
        pointer-events: auto;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 14px 16px;
        border-radius: 16px;
        box-shadow: var(--admin-shadow);
        border: 1px solid transparent;
        background: #ffffff;
        color: var(--admin-text);
        animation: admin-toast-in 160ms ease-out both;
    }

    .admin-toast--success {
        background: #ecfdf5;
        border-color: #a7f3d0;
    }

    .admin-toast--error {
        background: #fef2f2;
        border-color: #fecaca;
    }

    .admin-toast--warning {
        background: #fff7ed;
        border-color: #fed7aa;
    }

    .admin-toast--info {
        background: #eff6ff;
        border-color: #bfdbfe;
    }

    .admin-toast__icon {
        width: 32px;
        height: 32px;
        flex: 0 0 auto;
        border-radius: 999px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        font-weight: 800;
        line-height: 1;
    }

    .admin-toast--success .admin-toast__icon {
        background: #d1fae5;
        color: #047857;
    }

    .admin-toast--error .admin-toast__icon {
        background: #fee2e2;
        color: #b91c1c;
    }

    .admin-toast--warning .admin-toast__icon {
        background: #ffedd5;
        color: #9a3412;
    }

    .admin-toast--info .admin-toast__icon {
        background: #dbeafe;
        color: #1d4ed8;
    }

    .admin-toast__content {
        min-width: 0;
        flex: 1;
    }

    .admin-toast__title {
        margin: 0;
        font-size: .92rem;
        font-weight: 800;
        line-height: 1.35;
    }

    .admin-toast__message {
        margin-top: 2px;
        font-size: .9rem;
        line-height: 1.45;
        color: #374151;
        word-break: break-word;
    }

    .admin-toast__close {
        margin-left: auto;
        padding: 0;
        border: 0;
        background: transparent;
        color: inherit;
        opacity: .55;
        font-size: 1.15rem;
        line-height: 1;
        cursor: pointer;
    }

    .admin-toast__close:hover {
        opacity: 1;
    }

    @keyframes admin-toast-in {
        from {
            transform: translateY(-8px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
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

        .admin-page,
        .main-content,
        .content-area {
            padding: 20px 16px 28px;
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
