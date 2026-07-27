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
        --admin-control-radius: 10px;
        --admin-sidebar-width: 260px;
        --admin-page-padding-top: 28px;
        --admin-page-padding-x: 32px;
        --admin-page-padding-bottom: 36px;
        --admin-section-gap: 24px;
        --admin-control-height: 42px;
    }

    html {
        background: var(--admin-bg);
    }

    body {
        margin: 0;
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

    .admin-shell,
    .admin-shell * {
        box-sizing: border-box;
    }

    .admin-shell-sidebar {
        flex: 0 0 var(--admin-sidebar-width);
        width: var(--admin-sidebar-width);
        max-width: var(--admin-sidebar-width);
    }
    .admin-shell-content {
        flex: 1;
        min-width: 0;
        height: 100vh;
        overflow-y: auto;
        overflow-x: hidden;
        scrollbar-gutter: stable;
        -webkit-overflow-scrolling: touch;
    }

    .admin-page,
    .main-content,
    .content-area {
        min-width: 0;
        padding: var(--admin-page-padding-top) var(--admin-page-padding-x) var(--admin-page-padding-bottom);
    }

    .admin-shell-content > .admin-page,
    .admin-shell-content > .main-content,
    .admin-shell-content > .content-area {
        width: 100%;
        max-width: none;
        min-height: 100%;
        margin: 0 !important;
        padding: var(--admin-page-padding-top) var(--admin-page-padding-x) var(--admin-page-padding-bottom) !important;
        box-sizing: border-box;
    }

    .admin-page.container,
    .admin-page.container-fluid,
    .admin-page > .container,
    .admin-page > .container-fluid,
    .main-content > .container,
    .main-content > .container-fluid,
    .content-area > .container,
    .content-area > .container-fluid {
        width: 100%;
        max-width: none;
        padding: 0 !important;
        margin: 0 !important;
        box-sizing: border-box;
    }

    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        flex-wrap: nowrap;
        min-height: 64px;
        margin-bottom: 24px;
    }

    .page-header > div:first-child {
        min-width: 0;
    }

    .page-header > :not(.page-heading-block) {
        flex: 0 0 auto;
    }

    .page-heading-block {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        flex: 1 1 auto;
        min-width: 0;
    }

    .page-title-icon {
        width: 42px;
        height: 42px;
        flex: 0 0 42px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid #bfdbfe;
        border-radius: 12px;
        color: var(--admin-primary);
        background: #eff6ff;
        font-size: 1.05rem;
        line-height: 1;
    }

    .page-heading-copy {
        flex: 1 1 auto;
        min-width: 0;
        max-width: 100%;
        padding-top: 1px;
    }

    .page-title {
        font-size: 1.5rem;
        font-weight: 800;
        color: var(--admin-text) !important;
        margin: 0;
        line-height: 1.2;
        letter-spacing: -.015em;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .page-subtitle {
        color: var(--admin-muted);
        font-size: .95rem;
        line-height: 1.45;
        margin: 5px 0 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .card-main,
    .admin-card {
        border: none;
        border-radius: var(--admin-radius);
        box-shadow: var(--admin-shadow);
        overflow: hidden;
        background: var(--admin-surface);
    }

    .admin-page .card:not(.stat-card),
    .main-content .card:not(.stat-card),
    .content-area .card:not(.stat-card) {
        border: 1px solid var(--admin-border-soft) !important;
        border-radius: var(--admin-radius) !important;
        box-shadow: var(--admin-shadow) !important;
        background: var(--admin-surface) !important;
        width: 100%;
        max-width: none !important;
        margin-left: 0 !important;
        margin-right: 0 !important;
    }

    .card-main .card-header,
    .admin-card .card-header,
    .admin-card-header,
    .admin-page .card-header {
        background: var(--admin-surface) !important;
        color: var(--admin-text) !important;
        border-bottom: 1px solid var(--admin-border-soft) !important;
        padding: 18px 24px !important;
        min-height: 60px;
    }

    .admin-page .card-header h1,
    .admin-page .card-header h2,
    .admin-page .card-header h3,
    .admin-page .card-header h4,
    .admin-page .card-header h5,
    .admin-page .card-header h6,
    .main-content .card-header h1,
    .main-content .card-header h2,
    .main-content .card-header h3,
    .main-content .card-header h4,
    .main-content .card-header h5,
    .main-content .card-header h6 {
        color: var(--admin-text) !important;
        font-weight: 750;
        font-size: 1rem !important;
        line-height: 1.3;
        margin: 0 !important;
    }

    .admin-page .card-body,
    .main-content .card-body,
    .content-area .card-body {
        padding: 24px;
    }

    .admin-page .card-body:not(.p-0),
    .main-content .card-body:not(.p-0),
    .content-area .card-body:not(.p-0) {
        padding: 24px !important;
    }

    .card-main .card-footer,
    .admin-card .card-footer,
    .admin-card-footer {
        background: var(--admin-surface-soft);
        border-top: 1px solid var(--admin-border-soft);
        padding: 16px 24px !important;
    }

    .card-main .table,
    .admin-table {
        margin-bottom: 0;
    }

    .card-main .table thead th,
    .admin-table thead th,
    .admin-page .table thead th,
    .main-content .table thead th,
    .content-area .table thead th {
        background: #1f2937 !important;
        color: #ffffff !important;
        font-weight: 700;
        font-size: .85rem;
        white-space: nowrap;
        border: none;
        padding: 13px 16px;
        vertical-align: middle;
    }

    .card-main .table tbody tr:hover,
    .admin-table tbody tr:hover,
    .admin-page .table tbody tr:hover,
    .main-content .table tbody tr:hover,
    .content-area .table tbody tr:hover {
        background: #f8fbff;
    }

    .admin-table td,
    .admin-page .table td,
    .main-content .table td,
    .content-area .table td {
        vertical-align: middle;
        padding: 14px 16px;
        border-color: var(--admin-border-soft);
        font-size: .9rem;
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

    .admin-stat-card {
        min-height: 112px;
    }

    .admin-stat-card .card-body {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .admin-stat-icon {
        width: 44px;
        height: 44px;
        flex: 0 0 44px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 12px;
        color: var(--admin-primary);
        background: #eff6ff;
        font-size: 1rem;
    }

    .admin-stat-label {
        margin-bottom: 4px;
        color: var(--admin-muted);
        font-size: .78rem;
        font-weight: 800;
        letter-spacing: .04em;
        text-transform: uppercase;
    }

    .admin-stat-value {
        margin: 0;
        color: var(--admin-text);
        font-size: 1.5rem;
        font-weight: 800;
        line-height: 1.2;
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

    .admin-page .form-label,
    .admin-page label,
    .main-content .form-label,
    .main-content label,
    .content-area .form-label,
    .content-area label {
        color: #374151;
        font-weight: 650;
    }

    .admin-page .form-control,
    .admin-page .form-select,
    .main-content .form-control,
    .main-content .form-select,
    .content-area .form-control,
    .content-area .form-select {
        width: 100%;
        height: 42px !important;
        min-height: 42px;
        padding: 9px 13px !important;
        font-size: .9rem !important;
        line-height: 1.25;
        color: var(--admin-text);
        background-color: #ffffff;
        border: 1px solid #d7dde7;
        border-radius: var(--admin-control-radius);
        box-shadow: none;
    }

    .admin-page textarea.form-control,
    .main-content textarea.form-control,
    .content-area textarea.form-control {
        height: auto !important;
        min-height: 110px;
    }

    .admin-page .form-control:focus,
    .admin-page .form-select:focus,
    .main-content .form-control:focus,
    .main-content .form-select:focus,
    .content-area .form-control:focus,
    .content-area .form-select:focus {
        border-color: #93b4f8;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, .12);
    }

    .admin-page .btn,
    .main-content .btn,
    .content-area .btn {
        height: 40px;
        min-height: 40px;
        padding: 8px 14px;
        border-radius: var(--admin-control-radius);
        font-size: .875rem;
        line-height: 1.2;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 7px;
    }

    .admin-page .btn-sm,
    .main-content .btn-sm,
    .content-area .btn-sm {
        height: 34px;
        min-height: 34px;
        padding: 6px 11px;
        border-radius: 8px;
    }

    .admin-page .row {
        --bs-gutter-x: 24px !important;
        --bs-gutter-y: 24px !important;
    }

    .admin-page .btn-primary,
    .main-content .btn-primary,
    .content-area .btn-primary {
        background: var(--admin-primary);
        border-color: var(--admin-primary);
    }

    .admin-page .pagination,
    .main-content .pagination,
    .content-area .pagination {
        gap: 4px;
    }

    .admin-page .page-link,
    .main-content .page-link,
    .content-area .page-link {
        min-width: 38px;
        min-height: 38px;
        border-radius: 9px !important;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #374151;
        border-color: var(--admin-border);
    }

    .admin-page .alert,
    .main-content .alert,
    .content-area .alert {
        border: 1px solid transparent;
        border-radius: 12px;
        box-shadow: none !important;
    }

    .admin-page .modal-content,
    .main-content .modal-content,
    .content-area .modal-content {
        border: 0;
        border-radius: var(--admin-radius);
        box-shadow: 0 24px 70px rgba(15, 23, 42, .2);
    }

    .admin-page .modal-header,
    .main-content .modal-header,
    .content-area .modal-header {
        border-bottom-color: var(--admin-border-soft);
        padding: 20px 24px;
    }

    .admin-page .modal-footer,
    .main-content .modal-footer,
    .content-area .modal-footer {
        border-top-color: var(--admin-border-soft);
        padding: 16px 24px;
    }

    .admin-mobile-header {
        display: none;
    }

    .admin-sidebar-backdrop {
        display: none;
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
            display: block;
            overflow: visible;
        }
        body.admin-sidebar-open {
            overflow: hidden;
        }
        .admin-shell-sidebar {
            display: none;
            position: fixed;
            inset: 0 auto 0 0;
            z-index: 1050;
        }
        .admin-shell.is-sidebar-open .admin-shell-sidebar {
            display: block;
        }
        .admin-shell.is-sidebar-open .sidebar-shell {
            display: flex;
        }
        .admin-sidebar-backdrop {
            position: fixed;
            inset: 0;
            z-index: 1040;
            border: 0;
            background: rgba(15, 23, 42, .52);
            backdrop-filter: blur(2px);
        }
        .admin-shell.is-sidebar-open .admin-sidebar-backdrop {
            display: block;
        }
        .admin-shell-content {
            height: auto;
            min-height: 100vh;
        }

        .admin-mobile-header {
            position: sticky;
            top: 0;
            z-index: 1030;
            min-height: 62px;
            padding: 10px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            color: #ffffff;
            background: #111827;
            box-shadow: 0 8px 24px rgba(15, 23, 42, .16);
        }

        .admin-mobile-brand {
            display: flex;
            align-items: center;
            gap: 9px;
            min-width: 0;
            font-weight: 800;
        }

        .admin-mobile-brand i {
            color: #60a5fa;
        }

        .admin-mobile-menu {
            width: 42px;
            height: 42px;
            flex: 0 0 42px;
            padding: 0;
            border: 1px solid rgba(255, 255, 255, .22);
            border-radius: 10px;
            color: #ffffff;
            background: rgba(255, 255, 255, .08);
        }

        .admin-page,
        .main-content,
        .content-area {
            padding: 20px 16px 28px;
        }

        .admin-shell-content > .admin-page,
        .admin-shell-content > .main-content,
        .admin-shell-content > .content-area {
            padding: 20px 16px 28px !important;
        }

        .page-header {
            min-height: 0;
            margin-bottom: 18px;
        }

        .page-title {
            font-size: 1.3rem;
        }

        .page-title-icon {
            width: 38px;
            height: 38px;
            flex-basis: 38px;
            border-radius: 10px;
        }

        .admin-page .card-body,
        .main-content .card-body,
        .content-area .card-body {
            padding: 18px;
        }

        .admin-page .card-body:not(.p-0),
        .main-content .card-body:not(.p-0),
        .content-area .card-body:not(.p-0) {
            padding: 18px !important;
        }

        .admin-page .table td,
        .admin-page .table th,
        .main-content .table td,
        .main-content .table th,
        .content-area .table td,
        .content-area .table th {
            padding-left: 12px;
            padding-right: 12px;
        }
    }

    /* =========================================================
       Unified Admin UI
       All modules start from the same top and left coordinates.
       ========================================================= */
    body {
        overflow-x: hidden;
    }

    .admin-shell-content > .admin-page {
        display: block;
    }

    .admin-page > .container-fluid,
    .admin-page > .container {
        min-height: 100%;
    }

    .admin-page .page-header {
        width: 100%;
    }

    .admin-page .page-header > .btn,
    .admin-page .page-header > a.btn,
    .admin-page .page-header > form,
    .admin-page .page-header > .page-header-actions {
        flex: 0 0 auto;
    }

    .admin-page .page-header > form {
        margin: 0;
    }

    .admin-page .page-header .btn {
        white-space: nowrap;
    }

    .admin-page .card + .card,
    .admin-page .card + .row,
    .admin-page .row + .card {
        margin-top: var(--admin-section-gap);
    }

    .admin-page .table-responsive {
        width: 100%;
        max-width: 100%;
        overflow-x: auto;
        overflow-y: hidden;
        scrollbar-gutter: stable;
    }

    .admin-page .form-group {
        margin-bottom: 0;
    }

    .modal .form-group {
        margin-bottom: 16px;
    }

    .modal .form-group:last-child {
        margin-bottom: 0;
    }

    .admin-page .form-label,
    .admin-page .form-group > label,
    .admin-page .filter-label,
    .admin-page .product-filter-label {
        display: block;
        min-height: 20px;
        margin-bottom: 7px !important;
        color: #475569;
        font-size: .84rem;
        font-weight: 700;
        line-height: 1.35;
    }

    .admin-page .form-control,
    .admin-page .form-select,
    .admin-page .input-group-text {
        min-height: var(--admin-control-height);
    }

    .admin-page .input-group {
        width: 100%;
        flex-wrap: nowrap;
    }

    .admin-page .input-group > .form-control,
    .admin-page .input-group > .form-select {
        min-width: 0;
    }

    .admin-page .admin-filter-surface,
    .admin-page .product-filter-panel,
    .admin-page .category-toolbar,
    .admin-page .voucher-filter-panel,
    .admin-page .price-filter-panel {
        width: 100%;
        padding: 18px 20px;
        border: 1px solid var(--admin-border);
        border-radius: 14px;
        background: #f8fafc;
    }

    /* Product filters: the search field is intentionally wider. */
    .product-filter-grid {
        display: grid;
        grid-template-columns: minmax(320px, 2.2fr) repeat(3, minmax(145px, 1fr)) minmax(150px, .9fr);
        gap: 16px;
        align-items: end;
    }

    .product-filter-field,
    .product-filter-actions,
    .category-filter-search,
    .category-filter-status,
    .voucher-filter-field,
    .price-filter-search,
    .price-filter-status,
    .price-filter-actions {
        min-width: 0;
    }

    .product-filter-actions .btn,
    .voucher-filter-actions .btn,
    .price-filter-actions .btn {
        width: 100%;
    }

    /* Category: balanced search and status widths. */
    .category-filter-grid {
        display: grid;
        grid-template-columns: minmax(320px, 2fr) minmax(220px, 1fr);
        gap: 16px;
        align-items: end;
    }

    /* Voucher: search wider than lifecycle status, compact action. */
    .voucher-filter-grid {
        display: grid;
        grid-template-columns: minmax(340px, 1.65fr) minmax(250px, 1fr) minmax(160px, .55fr);
        gap: 16px;
        align-items: end;
    }

    /* Price: avoid an excessively long search field on wide screens. */
    .price-filter-grid {
        display: grid;
        grid-template-columns: minmax(340px, 1.55fr) minmax(260px, 1fr) minmax(140px, .45fr);
        gap: 16px;
        align-items: end;
    }

    .variant-search-input-group {
        width: 100%;
        max-width: 760px;
    }

    .admin-form-actions {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
    }

    /* Bootstrap 4 compatibility names retained by a few legacy fragments. */
    .admin-page .fw-bold {
        font-weight: 700 !important;
    }

    @media (max-width: 1399.98px) {
        .product-filter-grid {
            grid-template-columns: minmax(300px, 2fr) repeat(2, minmax(150px, 1fr));
        }

        .product-filter-actions {
            grid-column: auto;
        }
    }

    @media (max-width: 991.98px) {
        .page-header {
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .page-header > .btn,
        .page-header > a.btn,
        .page-header > .page-header-actions {
            margin-left: 54px;
        }

        .product-filter-grid,
        .category-filter-grid,
        .voucher-filter-grid,
        .price-filter-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .product-filter-search,
        .category-filter-search,
        .voucher-filter-search,
        .price-filter-search {
            grid-column: 1 / -1;
        }
    }

    @media (max-width: 575.98px) {
        .page-header > .btn,
        .page-header > a.btn,
        .page-header > .page-header-actions {
            width: 100%;
            margin-left: 0;
        }

        .page-header > .btn,
        .page-header > a.btn {
            justify-content: center;
        }

        .product-filter-grid,
        .category-filter-grid,
        .voucher-filter-grid,
        .price-filter-grid {
            grid-template-columns: 1fr;
        }

        .product-filter-search,
        .category-filter-search,
        .voucher-filter-search,
        .price-filter-search {
            grid-column: auto;
        }
    }

</style>
<div class="admin-shell" id="adminShell">
    <div class="admin-shell-sidebar">
        <jsp:include page="/view/admin/sidebar.jsp">
            <jsp:param name="activeTab" value="${param.activeTab}" />
        </jsp:include>
    </div>
    <button type="button"
            class="admin-sidebar-backdrop"
            data-admin-sidebar-close
            aria-label="Close navigation"></button>
    <div class="admin-shell-content">
        <header class="admin-mobile-header">
            <div class="admin-mobile-brand">
                <i class="fa-solid fa-shirt" aria-hidden="true"></i>
                <span>Clothing Sale Management</span>
            </div>
            <button type="button"
                    class="admin-mobile-menu"
                    data-admin-sidebar-toggle
                    aria-label="Open navigation"
                    aria-controls="adminSidebarNavigation"
                    aria-expanded="false">
                <i class="fa-solid fa-bars" aria-hidden="true"></i>
            </button>
        </header>