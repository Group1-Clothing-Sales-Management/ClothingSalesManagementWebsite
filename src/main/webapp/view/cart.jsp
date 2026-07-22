<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
    java.util.Collection items = (java.util.Collection) request.getAttribute("items");
    java.util.Map variantsByProductId = (java.util.Map) request.getAttribute("variantsByProductId");
    String ctx = request.getContextPath();
    java.text.NumberFormat currencyFormat = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Cart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --cart-accent:#c65b3d;
            --cart-accent-dark:#a9462d;
            --cart-teal:#c65b3d;
            --cart-ink:#25211e;
            --cart-muted:#6f665e;
            --cart-line:#e5e5e5;
            --cart-page:#f5f5f5;
            --cart-soft:#fff3ef;
        }

        * { box-sizing:border-box; }

        body {
            min-height:100vh;
            margin:0;
            background:var(--cart-page);
            color:var(--cart-ink);
            font-family:Arial, Helvetica, sans-serif;
            padding-bottom:96px;
        }

        .cart-page .custom-navbar{
            display:block;
        }

        .cart-topbar{
            min-height:34px;
            background:#c65b3d;
            color:#fff;
            font-size:12px;
        }

        .cart-topbar-inner{
            max-width:1200px;
            min-height:34px;
            margin:0 auto;
            padding:0 4px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;
        }

        .cart-topbar-group{
            display:flex;
            align-items:center;
            gap:9px;
            white-space:nowrap;
        }

        .account-menu{
            position:relative;
        }

        .account-menu summary{
            display:flex;
            align-items:center;
            gap:6px;
            cursor:pointer;
            list-style:none;
        }

        .account-menu summary::-webkit-details-marker{
            display:none;
        }

        .account-avatar{
            width:20px;
            height:20px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            border-radius:50%;
            background:#087f68;
            color:#fff;
            font-size:11px;
            font-weight:700;
        }

        .account-dropdown{
            position:absolute;
            z-index:20;
            top:calc(100% + 10px);
            right:0;
            width:170px;
            padding:8px 0;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:6px;
            box-shadow:0 8px 22px rgba(37,33,30,.16);
        }

        .cart-topbar .account-dropdown a{
            display:block;
            padding:9px 14px;
            color:var(--cart-ink);
            font-size:13px;
        }

        .cart-topbar .account-dropdown a:hover{
            background:var(--cart-soft);
            color:var(--cart-accent);
        }

        .account-dropdown hr{
            margin:5px 0;
            border:0;
            border-top:1px solid var(--cart-line);
        }

        .cart-topbar a{
            color:#fff;
            text-decoration:none;
        }

        .cart-topbar-separator{
            opacity:.55;
        }

        .navbar {
            border-bottom:1px solid rgba(0, 0, 0, .06);
            box-shadow:none!important;
            background:#fff!important;
        }

        .cart-shell {
            max-width:1200px;
            margin:0 auto;
            padding:0 0 24px;
        }

        .cart-brand-row {
            display:flex;
            align-items:center;
            gap:14px;
            flex-wrap:nowrap;
            min-height:100px;
            margin:0 calc((1200px - 100vw) / 2) 20px;
            padding:0 max(16px, calc((100vw - 1200px) / 2));
            background:#fff;
            border-bottom:1px solid var(--cart-line);
        }

        .cart-brand-logo,
        .cart-brand-title-text {
            color:var(--cart-accent);
            text-decoration:none;
            white-space:nowrap;
        }

        .cart-brand-logo {
            display:flex;
            align-items:center;
            gap:8px;
            font-size:27px;
            font-weight:500;
        }

        .cart-brand-logo i {
            font-size:32px;
        }

        .cart-brand-title-text {
            padding-left:14px;
            border-left:1px solid var(--cart-accent);
            font-size:20px;
        }

        .cart-search {
            display:flex;
            width:min(620px, 52vw);
            height:40px;
            margin-left:auto;
        }

        .cart-search input {
            flex:1;
            min-width:0;
            border:2px solid var(--cart-accent);
            border-right:0;
            padding:0 12px;
            color:var(--cart-ink);
        }

        .cart-search button {
            width:82px;
            border:0;
            background:var(--cart-accent);
            color:#fff;
        }

        .cart-category-row{
            flex:0 0 100%;
            display:none;
            justify-content:center;
            gap:20px;
            overflow:hidden;
            color:#fff;
            font-size:12px;
            white-space:nowrap;
        }

        .cart-grid {
            display:grid;
            grid-template-columns:40px minmax(300px, 1fr) 190px 130px 140px 140px 100px;
            gap:14px;
            align-items:center;
        }

        .cart-head {
            min-height:58px;
            padding:0 20px;
            margin-bottom:12px;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
            color:var(--cart-muted);
            font-size:14px;
        }

        .cart-head .product-col {
            color:var(--cart-ink);
            font-size:16px;
        }

        .shop-card {
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
        }

        .shop-header {
            min-height:58px;
            display:flex;
            align-items:center;
            gap:12px;
            padding:0 20px;
            border-bottom:1px solid var(--cart-line);
            color:var(--cart-ink);
            font-size:15px;
        }

        .shop-header i {
            color:var(--cart-accent);
        }

        .shop-badge {
            padding:3px 5px;
            background:var(--cart-accent);
            color:#fff;
            font-size:11px;
        }

        .cart-item {
            min-height:132px;
            padding:20px;
            border-bottom:1px solid var(--cart-line);
        }

        .product-info {
            display:flex;
            align-items:flex-start;
            gap:14px;
            min-width:0;
        }

        .cart-image-frame {
            position:relative;
            width:80px;
            height:80px;
            flex:0 0 auto;
        }

        .cart-img {
            width:80px;
            height:80px;
            object-fit:cover;
            border:1px solid #eee;
            background:#f1f1f1;
        }

        .cart-image-placeholder {
            width:80px;
            height:80px;
            align-items:center;
            justify-content:center;
            border:1px solid #eee;
            background:#f1f1f1;
            color:#94a3b8;
            font-size:24px;
        }

        .product-name {
            display:-webkit-box;
            -webkit-line-clamp:2;
            -webkit-box-orient:vertical;
            overflow:hidden;
            color:var(--cart-ink);
            font-size:15px;
            line-height:1.35;
            text-decoration:none;
        }

        .product-name:hover {
            color:var(--cart-accent);
        }

        .stock-note {
            margin-top:8px;
            color:var(--cart-muted);
            font-size:13px;
            line-height:1.35;
        }

        .stock-note strong {
            color:var(--cart-accent);
            font-weight:700;
        }

        .variant-block {
            min-width:0;
            margin:0!important;
        }

        .variant-label {
            color:var(--cart-muted);
            font-size:14px;
            margin-bottom:6px;
        }

        .variant-select {
            width:100%;
            max-width:170px;
            border:0;
            color:#475569;
            font-size:14px;
            padding:0;
            background:transparent;
            box-shadow:none!important;
        }

        .cart-update-form {
            display:contents;
        }

        .variant-select:focus {
            outline:0;
        }

        .price-col,
        .amount-col,
        .action-col {
            text-align:center;
        }

        .variant-label {
            margin-bottom:3px;
        }

        .item-price {
            color:var(--cart-ink);
            font-size:15px;
        }

        .amount-col {
            color:var(--cart-accent);
            font-size:16px;
            font-weight:500;
        }

        .cart-update-form {
            margin:0;
        }

        .quantity-control {
            display:grid;
            grid-template-columns:36px 54px 36px;
            width:126px;
            height:34px;
            margin:0 auto;
            border:1px solid #ddd;
            background:#fff;
        }

        .quantity-control .btn {
            border:0;
            border-radius:0;
            background:#fff;
            color:#475569;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:16px;
            line-height:1;
        }

        .quantity-control .btn:hover:not(:disabled) {
            background:#f7f7f7;
            color:var(--cart-accent);
        }

        .quantity-control .btn:disabled {
            color:#cfcfcf;
        }

        .quantity-input {
            border:0;
            border-left:1px solid #ddd;
            border-right:1px solid #ddd;
            border-radius:0;
            text-align:center;
            min-width:0;
            box-shadow:none!important;
            -moz-appearance:textfield;
        }

        .quantity-input::-webkit-outer-spin-button,
        .quantity-input::-webkit-inner-spin-button {
            -webkit-appearance:none;
            margin:0;
        }

        .cart-remove-form {
            margin:0;
        }

        .cart-remove-btn {
            border:0;
            background:transparent;
            color:#475569;
            font-size:14px;
            padding:4px 0;
        }

        .cart-remove-btn:hover,
        .cart-remove-btn:focus {
            color:var(--cart-accent);
        }

        .checkout-bar {
            position:fixed;
            left:0;
            right:0;
            bottom:0;
            z-index:20;
            background:#fff;
            border-top:1px solid var(--cart-line);
            box-shadow:0 -4px 16px rgba(0, 0, 0, .08);
        }

        .checkout-inner {
            max-width:1200px;
            min-height:96px;
            margin:0 auto;
            padding:12px 16px;
            display:grid;
            grid-template-columns:auto auto 1fr auto auto;
            gap:22px;
            align-items:center;
        }

        .select-all-wrap {
            display:flex;
            align-items:center;
            gap:12px;
            white-space:nowrap;
            color:var(--cart-ink);
        }

        .selected-summary {
            justify-self:end;
            text-align:right;
        }

        .selected-summary-main {
            display:flex;
            align-items:baseline;
            gap:8px;
            justify-content:flex-end;
            color:var(--cart-ink);
        }

        .selected-summary-main strong {
            color:var(--cart-accent);
            font-size:28px;
            font-weight:500;
            line-height:1;
        }

        .saving-line {
            color:var(--cart-accent);
            font-size:13px;
            margin-top:4px;
        }

        .checkout-btn {
            width:210px;
            height:50px;
            border:0;
            border-radius:2px;
            background:var(--cart-accent);
            color:#fff;
            font-size:16px;
            font-weight:600;
        }

        .checkout-btn:hover,
        .checkout-btn:focus {
            background:var(--cart-accent-dark);
            color:#fff;
        }

        .checkout-btn:disabled {
            background:#94a3b8;
            color:#fff;
        }

        .continue-link {
            color:#333;
            text-decoration:none;
            white-space:nowrap;
        }

        .continue-link:hover {
            color:var(--cart-accent);
        }

        .cart-check {
            width:18px;
            height:18px;
            accent-color:var(--cart-accent);
            cursor:pointer;
        }

        .cart-toast {
            position:fixed;
            z-index:1080;
            top:50%;
            left:50%;
            transform:translate(-50%, -50%);
            width:min(360px, calc(100vw - 40px));
            min-height:180px;
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:center;
            gap:18px;
            padding:28px 30px;
            border:0;
            border-radius:3px;
            background:rgba(0, 0, 0, .68);
            color:#fff;
            text-align:center;
            box-shadow:0 16px 42px rgba(0,0,0,.18);
            animation:cart-toast-in .25s ease-out both;
        }

        .cart-toast > i {
            width:72px;
            height:72px;
            display:inline-flex;
            flex:0 0 72px;
            align-items:center;
            justify-content:center;
            border-radius:50%;
            background:#00bfa5;
            color:#fff;
            font-size:36px;
            box-shadow:0 8px 18px rgba(0,0,0,.18);
        }
        .cart-toast-message {
            max-width:100%;
            line-height:1.45;
            font-size:18px;
            font-weight:500;
            color:#fff;
        }
        .cart-toast-close {
            border:0;
            width:1px;
            height:1px;
            position:absolute;
            overflow:hidden;
            clip:rect(0 0 0 0);
            background:transparent;
        }
        .cart-toast.is-hiding { animation:cart-toast-out .2s ease-in both; }

        @keyframes cart-toast-in {
            from { opacity:0; transform:translate(-50%, -50%) scale(.94); }
            to { opacity:1; transform:translate(-50%, -50%) scale(1); }
        }
        @keyframes cart-toast-out {
            to { opacity:0; transform:translate(-50%, -50%) scale(.94); }
        }

        .empty-state {
            max-width:560px;
            margin:64px auto;
            padding:42px;
            text-align:center;
            background:#fff;
            border:1px solid var(--cart-line);
            border-radius:3px;
        }

        .empty-mark {
            width:76px;
            height:76px;
            margin:0 auto 16px;
            display:flex;
            align-items:center;
            justify-content:center;
            border-radius:50%;
            background:var(--cart-soft);
            color:var(--cart-accent);
            font-size:30px;
        }

        @media (max-width: 992px) {
            body {
                padding-bottom:136px;
            }

            .cart-toast {
                width:min(320px, calc(100vw - 32px));
                min-height:160px;
                padding:24px 22px;
            }

            .cart-brand-row {
                display:block;
                padding:18px 0;
                margin:0 -16px 16px;
                min-height:0;
            }

            .cart-topbar-inner{
                padding:0 16px;
                overflow:hidden;
            }

            .cart-topbar-group:last-child{
                display:flex;
            }

            .cart-topbar-group:last-child > span{
                display:none;
            }

            .cart-brand-logo,
            .cart-brand-title-text {
                margin-left:16px;
            }

            .cart-search {
                width:auto;
                margin:14px 16px 0;
            }

            .cart-category-row{
                display:none;
            }

            .cart-head {
                display:none;
            }

            .cart-item {
                padding-left:16px;
                padding-right:16px;
            }

            .cart-grid {
                grid-template-columns:34px minmax(0, 1fr);
                gap:12px;
            }

            .variant-block,
            .price-col,
            .quantity-control,
            .amount-col,
            .action-col {
                grid-column:2;
                text-align:left;
            }

            .cart-update-form {
                display:contents;
            }

            .quantity-control {
                margin:0;
            }

            .checkout-inner {
                grid-template-columns:1fr 1fr;
                gap:12px;
            }

            .selected-summary {
                grid-column:1 / -1;
                justify-self:stretch;
            }

            .selected-summary-main {
                justify-content:space-between;
            }

            .checkout-btn {
                width:100%;
            }
        }

        /* Home-aligned cart refresh */
        :root {
            --cart-accent:#8AAAE5;
            --cart-accent-dark:#5f84d6;
            --cart-teal:#8AAAE5;
            --cart-ink:#1f2937;
            --cart-muted:#61708a;
            --cart-line:#d7e1f5;
            --cart-page:#eef4ff;
            --cart-soft:#eef4ff;
        }

        body.cart-page {
            background:
                linear-gradient(135deg, rgba(138,170,229,.14) 0 24%, transparent 24% 100%),
                linear-gradient(180deg, #ffffff 0%, #eef4ff 100%);
            color:var(--cart-ink);
            font-family:"Segoe UI", Arial, Helvetica, sans-serif;
        }

        .cart-shell {
            max-width:1220px;
            padding:30px 16px 28px;
        }

        .cart-page-title {
            min-height:96px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:18px;
            margin-bottom:18px;
            padding:22px 24px;
            border:1px solid rgba(138,170,229,.38);
            border-radius:8px;
            background:rgba(255,255,255,.96);
            box-shadow:0 18px 42px rgba(95,132,214,.14);
        }

        .cart-page-kicker {
            display:inline-flex;
            align-items:center;
            gap:8px;
            margin-bottom:7px;
            color:#5f84d6;
            font-size:.8rem;
            font-weight:900;
            letter-spacing:.08em;
            text-transform:uppercase;
        }

        .cart-page-title h1 {
            margin:0;
            color:var(--cart-ink);
            font-size:1.65rem;
            font-weight:850;
        }

        .cart-title-link {
            flex:0 0 auto;
            color:#365b9f;
            font-weight:800;
            text-decoration:none;
        }

        .cart-title-link:hover {
            color:#5f84d6;
            text-decoration:underline;
            text-underline-offset:4px;
        }

        .cart-head,
        .shop-card,
        .empty-state {
            border:1px solid rgba(138,170,229,.34);
            border-radius:8px;
            background:#fff;
            box-shadow:0 12px 32px rgba(95,132,214,.12);
        }

        .cart-head {
            min-height:62px;
            margin-bottom:14px;
            color:var(--cart-muted);
            font-weight:700;
        }

        .cart-head .product-col {
            color:var(--cart-ink);
            font-weight:850;
        }

        .shop-header {
            min-height:62px;
            border-bottom:1px solid var(--cart-line);
            font-weight:850;
        }

        .shop-header i {
            color:#5f84d6;
        }

        .shop-badge {
            padding:5px 8px;
            border-radius:8px;
            background:#eef4ff;
            color:#365b9f;
            font-weight:800;
        }

        .cart-item {
            min-height:146px;
            border-bottom:1px solid var(--cart-line);
        }

        .cart-image-frame,
        .cart-img,
        .cart-image-placeholder {
            width:92px;
            height:92px;
        }

        .cart-img,
        .cart-image-placeholder {
            border:1px solid var(--cart-line);
            border-radius:8px;
            background:#eef4ff;
        }

        .product-name {
            color:var(--cart-ink);
            font-weight:800;
        }

        .product-name:hover,
        .cart-remove-btn:hover,
        .cart-remove-btn:focus,
        .continue-link:hover {
            color:#5f84d6;
        }

        .stock-note {
            color:var(--cart-muted);
        }

        .stock-note strong,
        .amount-col,
        .selected-summary-main strong,
        .saving-line {
            color:#365b9f;
        }

        .item-price {
            color:var(--cart-ink);
            font-weight:700;
        }

        .variant-label {
            color:var(--cart-muted);
            font-weight:700;
        }

        .variant-select {
            max-width:190px;
            color:#365b9f;
            font-weight:700;
        }

        .variant-block {
            position:relative;
            z-index:6;
        }

        .variant-block.is-open {
            z-index:90;
        }

        .variant-select {
            display:none;
        }

        .variant-trigger {
            width:min(210px, 100%);
            min-height:42px;
            display:grid;
            grid-template-columns:1fr auto;
            gap:4px 8px;
            align-items:center;
            padding:7px 11px;
            border:1px solid var(--cart-line);
            border-radius:8px;
            background:#fff;
            color:var(--cart-ink);
            text-align:left;
            box-shadow:0 8px 18px rgba(95,132,214,.10);
        }

        .variant-trigger:hover,
        .variant-trigger[aria-expanded="true"] {
            border-color:#8AAAE5;
            box-shadow:0 0 0 3px rgba(138,170,229,.18);
        }

        .variant-trigger-label {
            color:var(--cart-muted);
            font-size:12px;
            font-weight:800;
            text-transform:uppercase;
            letter-spacing:.04em;
        }

        .variant-trigger-value {
            grid-column:1;
            min-width:0;
            overflow:hidden;
            color:#365b9f;
            font-weight:800;
            text-overflow:ellipsis;
            white-space:nowrap;
        }

        .variant-trigger i {
            grid-column:2;
            grid-row:1 / span 2;
            color:#5f84d6;
        }

        .variant-popover {
            position:absolute;
            z-index:50;
            top:calc(100% + 14px);
            left:0;
            width:min(520px, calc(100vw - 56px));
            padding:24px 24px 0;
            border:1px solid var(--cart-line);
            border-radius:8px;
            background:#fff;
            box-shadow:0 26px 70px rgba(31,41,55,.18);
        }

        .variant-popover-arrow {
            position:absolute;
            top:-9px;
            left:36px;
            width:18px;
            height:18px;
            border-left:1px solid var(--cart-line);
            border-top:1px solid var(--cart-line);
            background:#fff;
            transform:rotate(45deg);
        }

        .variant-choice-row {
            display:grid;
            grid-template-columns:110px 1fr;
            gap:12px;
            align-items:start;
        }

        .variant-choice-label {
            padding-top:8px;
            color:var(--cart-muted);
            font-size:18px;
        }

        .variant-choice-list {
            display:flex;
            flex-wrap:wrap;
            gap:10px;
        }

        .variant-choice {
            min-height:42px;
            border:1px solid var(--cart-line);
            border-radius:4px;
            padding:8px 16px;
            background:#fff;
            color:var(--cart-ink);
            font-size:15px;
            font-weight:700;
        }

        .variant-choice:hover:not(:disabled) {
            border-color:#8AAAE5;
            color:#365b9f;
        }

        .variant-choice.is-selected {
            border-color:#5f84d6;
            color:#365b9f;
            background:#eef4ff;
            box-shadow:inset 0 0 0 1px #5f84d6;
        }

        .variant-choice:disabled {
            cursor:not-allowed;
            opacity:.45;
        }

        .variant-stock-line {
            margin-top:22px;
            color:var(--cart-muted);
            font-size:16px;
        }

        .variant-stock-line strong {
            color:var(--cart-ink);
        }

        .variant-static {
            color:#365b9f;
            font-weight:800;
        }

        .quantity-control {
            border-color:var(--cart-line);
            border-radius:8px;
            overflow:hidden;
            box-shadow:0 8px 18px rgba(95,132,214,.10);
        }

        .quantity-control .btn:hover:not(:disabled) {
            background:#eef4ff;
            color:#5f84d6;
        }

        .quantity-input {
            border-color:var(--cart-line);
        }

        .cart-check {
            accent-color:#5f84d6;
        }

        .cart-remove-btn {
            color:#61708a;
            font-weight:700;
        }

        .checkout-bar {
            border-top:1px solid rgba(138,170,229,.36);
            background:rgba(255,255,255,.96);
            box-shadow:0 -12px 34px rgba(95,132,214,.14);
            backdrop-filter:blur(12px);
        }

        .checkout-inner {
            max-width:1220px;
        }

        .continue-link {
            color:var(--cart-ink);
            font-weight:700;
        }

        .checkout-btn {
            height:54px;
            border-radius:8px;
            background:#8AAAE5;
            box-shadow:0 14px 28px rgba(95,132,214,.24);
            font-weight:850;
        }

        .checkout-btn:hover,
        .checkout-btn:focus {
            background:#5f84d6;
        }

        .checkout-btn:disabled {
            background:#aab7cc;
            box-shadow:none;
        }

        .cart-toast {
            border-radius:8px;
            background:rgba(31,41,55,.82);
            box-shadow:0 22px 54px rgba(31,41,55,.24);
        }

        .cart-toast > i {
            background:#8AAAE5;
        }

        .empty-state {
            border-radius:8px;
        }

        .empty-mark {
            background:#eef4ff;
            color:#5f84d6;
        }

        .empty-state .btn-dark {
            border-color:#8AAAE5;
            background:#8AAAE5;
            color:#fff;
            font-weight:800;
        }

        .empty-state .btn-dark:hover {
            border-color:#5f84d6;
            background:#5f84d6;
        }

        @media (max-width: 992px) {
            .cart-shell {
                padding-top:22px;
            }

            .cart-page-title {
                align-items:flex-start;
                flex-direction:column;
            }
        }
    </style>
</head>
<body class="cart-page">
    <jsp:include page="/view/customer/common/header.jsp"/>

    <div class="cart-shell">
        <div class="cart-page-title">
            <div>
                <span class="cart-page-kicker"><i class="fa-solid fa-cart-shopping"></i> Shopping Cart</span>
                <h1>Your selected items</h1>
            </div>
            <a href="<%= ctx %>/products" class="cart-title-link">Browse products</a>
        </div>

        <% if (request.getAttribute("cartMessage") != null) { %>
            <div id="cartFlashMessage" class="cart-toast" role="status" aria-live="polite">
                <i class="fa-solid fa-check"></i>
                <span class="cart-toast-message"><c:out value="${cartMessage}"/></span>
                <button type="button" class="cart-toast-close" aria-label="Close notification">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        <% } %>

        <% if (items == null || items.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-mark">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>
                <h4>Your cart is empty</h4>
                <p class="text-muted">Add items you like to start shopping.</p>
                <a href="<%= ctx %>/home" class="btn btn-dark">Continue Shopping</a>
            </div>
        <% } else { %>
            <div class="cart-head cart-grid">
                <div>
                    <input type="checkbox" class="cart-check" id="cartSelectAllTop" checked>
                </div>
                <div class="product-col">Product</div>
                <div class="text-center">Unit Price</div>
                <div class="text-center">Variation</div>
                <div class="text-center">Quantity</div>
                <div class="text-center">Subtotal</div>
                <div class="text-center">Action</div>
            </div>

            <div class="shop-card">
                <div class="shop-header">
                    <input type="checkbox" class="cart-check" id="cartSelectAllShop" checked>
                    <i class="fa-solid fa-store"></i>
                    <span>Clothing Sale</span>
                    <span class="shop-badge">Featured shop</span>
                </div>
                <% java.math.BigDecimal total = java.math.BigDecimal.ZERO; int totalQuantity = 0; %>
                <% for (Object o : items) {
                       com.clothingsale.model.CartItem it = (com.clothingsale.model.CartItem) o;
                       java.math.BigDecimal price = it.getPrice() != null ? it.getPrice() : java.math.BigDecimal.ZERO;
                       int qty = it.getQuantity();
                       java.math.BigDecimal itemTotal = price.multiply(new java.math.BigDecimal(qty));
                       total = total.add(itemTotal);
                       totalQuantity += qty;

                       String rawImageUrl = it.getImageUrl();
                       String imageUrl = "";
                       if (rawImageUrl != null && !rawImageUrl.trim().isEmpty()) {
                           String cleanImageUrl = rawImageUrl.trim().replace('\\', '/');
                           if (cleanImageUrl.startsWith("http://")
                                   || cleanImageUrl.startsWith("https://")) {
                               imageUrl = cleanImageUrl;
                           } else {
                               int queryIndex = cleanImageUrl.indexOf('?');
                               if (queryIndex >= 0) {
                                   cleanImageUrl = cleanImageUrl.substring(0, queryIndex);
                               }
                               String imageFileName = cleanImageUrl.substring(
                                       cleanImageUrl.lastIndexOf('/') + 1
                               );
                               imageUrl = ctx + "/media/product/" + imageFileName
                                       + "?v=" + System.currentTimeMillis();
                           }
                       }

                       String attributes = it.getAttributes();
                       if (attributes == null || attributes.trim().isEmpty()) {
                           attributes = "Standard";
                       }
                       java.util.List variants = variantsByProductId != null
                               ? (java.util.List) variantsByProductId.get(it.getProductId())
                               : null;
                       int currentStock = qty;
                       if (variants != null && !variants.isEmpty()) {
                           for (Object stockObject : variants) {
                               com.clothingsale.model.ProductVariant stockVariant = (com.clothingsale.model.ProductVariant) stockObject;
                               if (stockVariant.getId() == it.getVariantId()) {
                                   currentStock = stockVariant.getStockQuantity();
                                   break;
                               }
                           }
                       }
                %>
                    <div class="cart-item cart-grid">
                        <div>
                            <input type="checkbox"
                                   class="cart-check cart-select-input"
                                   name="selectedVariantId"
                                   value="<%= it.getVariantId() %>"
                                   form="cartCheckoutForm"
                                   data-line-quantity="<%= qty %>"
                                   data-line-total="<%= itemTotal %>"
                                   checked>
                        </div>

                        <div class="product-info">
                            <div class="cart-image-frame">
                                <img src="<%= imageUrl %>"
                                     alt="<%= it.getProductName() %>"
                                     class="cart-img"
                                     <%= imageUrl.isEmpty() ? "style=\"display:none;\"" : "" %>
                                     onerror="this.onerror=null;this.style.display='none';this.nextElementSibling.style.display='flex';">
                                <span class="cart-image-placeholder"
                                      <%= imageUrl.isEmpty() ? "" : "style=\"display:none;\"" %>>
                                    <i class="fa-regular fa-image"></i>
                                </span>
                            </div>
                            <div>
                                <a class="product-name" href="<%= ctx %>/product/detail?id=<%= it.getProductId() %>">
                                    <%= it.getProductName() %>
                                </a>
                                <div class="stock-note">
                                    In stock: <strong><%= currentStock %></strong>
                                </div>
                            </div>
                        </div>

                        <div class="price-col">
                            <div class="item-price"><%= currencyFormat.format(price) %></div>
                        </div>

                        <form action="<%= ctx %>/cart/update" method="post" class="cart-update-form">
                            <input type="hidden"
                                   name="variantId"
                                   value="<%= it.getVariantId() %>">

                            <div class="variant-block mb-3">
                                <% if (variants != null && !variants.isEmpty()) { %>
                                    <select name="newVariantId" class="variant-select">
                                       <% for (Object vo : variants) {
                                               com.clothingsale.model.ProductVariant v = (com.clothingsale.model.ProductVariant) vo;
                                               String detail = v.getAttributeDetails() != null ? v.getAttributeDetails() : "Standard";
                                               java.math.BigDecimal variantPrice = v.getSalePrice() != null ? v.getSalePrice() : java.math.BigDecimal.ZERO;
                                               boolean selected = v.getId() == it.getVariantId();
                                               String variantImage = v.getImageUrl() != null ? v.getImageUrl() : "";
                                               long variantImageVersion = v.getImageUpdatedAt() != null
                                                       ? v.getImageUpdatedAt().getTime()
                                                       : 0L;
                                        %>
                                            <option value="<%= v.getId() %>"
                                                    data-price="<%= variantPrice %>"
                                                    data-attributes="<%= detail %>"
                                                    data-stock="<%= v.getStockQuantity() %>"
                                                    data-image="<%= variantImage %>"
                                                    data-image-version="<%= variantImageVersion %>"
                                                    <%= (v.getStockQuantity() <= 0 && !selected) ? "disabled" : "" %>
                                                    <%= selected ? "selected" : "" %>>
                                                <%= detail %>
                                            </option>
                                        <% } %>
                                    </select>
                                    <button type="button" class="variant-trigger" aria-expanded="false">
                                        <span class="variant-trigger-label">Variant</span>
                                        <span class="variant-trigger-value"><%= attributes %></span>
                                        <i class="fa-solid fa-caret-down"></i>
                                    </button>
                                    <div class="variant-popover" hidden>
                                        <span class="variant-popover-arrow" aria-hidden="true"></span>
                                        <div class="variant-choice-row">
                                            <div class="variant-choice-label">Options:</div>
                                            <div class="variant-choice-list">
                                                <% for (Object vo : variants) {
                                                        com.clothingsale.model.ProductVariant v = (com.clothingsale.model.ProductVariant) vo;
                                                        String detail = v.getAttributeDetails() != null ? v.getAttributeDetails() : "Standard";
                                                        java.math.BigDecimal variantPrice = v.getSalePrice() != null ? v.getSalePrice() : java.math.BigDecimal.ZERO;
                                                        boolean selected = v.getId() == it.getVariantId();
                                                        String variantImage = v.getImageUrl() != null ? v.getImageUrl() : "";
                                                        long variantImageVersion = v.getImageUpdatedAt() != null
                                                                ? v.getImageUpdatedAt().getTime()
                                                                : 0L;
                                                %>
                                                    <button type="button"
                                                            class="variant-choice <%= selected ? "is-selected" : "" %>"
                                                            data-value="<%= v.getId() %>"
                                                            data-price="<%= variantPrice %>"
                                                            data-attributes="<%= detail %>"
                                                            data-stock="<%= v.getStockQuantity() %>"
                                                            data-image="<%= variantImage %>"
                                                            data-image-version="<%= variantImageVersion %>"
                                                            <%= (v.getStockQuantity() <= 0 && !selected) ? "disabled" : "" %>>
                                                        <%= detail %>
                                                    </button>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="variant-stock-line">
                                            Stock: <strong class="variant-stock-value"><%= currentStock %></strong>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <input type="hidden" name="newVariantId" value="<%= it.getVariantId() %>">
                                    <div class="variant-static"><%= attributes %></div>
                                <% } %>
                            </div>

                            <div class="quantity-control">
                                <button type="button"
                                        class="btn quantity-step"
                                        data-step="-1"
                                        aria-label="Decrease quantity"
                                        <%= qty <= 1 ? "disabled" : "" %>>
                                    -
                                </button>
                                <input type="number"
                                       name="quantity"
                                       value="<%= qty %>"
                                       min="1"
                                       max="<%= currentStock %>"
                                       data-stock="<%= currentStock %>"
                                       class="form-control quantity-input">
                                <button type="button"
                                        class="btn quantity-step"
                                        data-step="1"
                                        aria-label="Increase quantity"
                                        <%= currentStock <= 0 || qty >= currentStock ? "disabled" : "" %>>
                                    +
                                </button>
                            </div>
                        </form>

                        <div class="amount-col">
                            <%= currencyFormat.format(itemTotal) %>
                        </div>

                        <div class="action-col">
                            <form action="<%= ctx %>/cart/remove" method="post" class="cart-remove-form">
                                <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                <button type="submit" class="cart-remove-btn">
                                    Remove
                                </button>
                            </form>
                        </div>
                    </div>
                <% } %>

            </div>

            <form id="cartCheckoutForm" action="<%= ctx %>/customer/checkout" method="get">
                <input type="hidden" name="selectionMode" value="1">
            </form>

            <div class="checkout-bar">
                <div class="checkout-inner">
                    <label class="select-all-wrap">
                        <input type="checkbox" class="cart-check" id="cartSelectAllBottom" checked>
                        <span>Select All (<%= items.size() %>)</span>
                    </label>

                    <a href="<%= ctx %>/home" class="continue-link">Continue Shopping</a>

                    <div class="selected-summary">
                        <div class="selected-summary-main">
                            <span>Total (<span id="selectedQuantity"><%= totalQuantity %></span> item(s)):</span>
                            <strong id="selectedTotal"><%= currencyFormat.format(total) %></strong>
                        </div>
                        <div class="saving-line">
                            Shipping and payment are handled at checkout.
                        </div>
                    </div>

                    <button id="checkoutSelectedButton"
                            type="submit"
                            form="cartCheckoutForm"
                            class="checkout-btn">
                        Checkout
                    </button>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        function submitCartForm(form) {
            if (form.requestSubmit) {
                form.requestSubmit();
            } else {
                form.submit();
            }
        }

        function getCurrentStock(form) {
            var select = form.querySelector('.variant-select');
            if (select && select.selectedIndex >= 0) {
                var option = select.options[select.selectedIndex];
                var optionStock = parseInt(option.dataset.stock, 10);
                if (!isNaN(optionStock)) {
                    return optionStock;
                }
            }

            var input = form.querySelector('.quantity-input');
            if (!input) {
                return 0;
            }

            var inputStock = parseInt(input.dataset.stock || input.getAttribute('max'), 10);
            return isNaN(inputStock) ? 0 : inputStock;
        }

        function normalizeQuantity(input, stock) {
            var value = parseInt(input.value, 10);
            if (isNaN(value) || value < 1) {
                value = 1;
            }

            if (stock > 0 && value > stock) {
                value = stock;
            }

            input.value = value;
            return value;
        }

        function updateQuantityButtons(form) {
            var input = form.querySelector('.quantity-input');
            var buttons = form.querySelectorAll('.quantity-step');
            if (!input || buttons.length < 2) {
                return;
            }

            var stock = getCurrentStock(form);
            var value = normalizeQuantity(input, stock);
            buttons[0].disabled = value <= 1;
            buttons[1].disabled = stock <= 0 || value >= stock;
        }

        function buildCartImageUrl(fileName, version) {
            if (!fileName) {
                return "";
            }

            var normalized = String(fileName).replace(/\\/g, "/");
            if (/^https?:\/\//i.test(normalized)) {
                return normalized;
            }

            var queryIndex = normalized.indexOf("?");
            if (queryIndex >= 0) {
                normalized = normalized.substring(0, queryIndex);
            }

            var imageName = normalized.substring(
                    normalized.lastIndexOf("/") + 1
            );

            var cacheVersion = version && version !== "0"
                    ? "?v=" + encodeURIComponent(version)
                    : "?v=" + Date.now();

            return "<%= ctx %>/media/product/"
                    + encodeURIComponent(imageName)
                    + cacheVersion;
        }

        function previewSelectedVariantImage(form, option) {
            var itemRow = form.closest(".cart-item");
            if (!itemRow) {
                return;
            }

            var image = itemRow.querySelector(".cart-img");
            var placeholder = itemRow.querySelector(
                    ".cart-image-placeholder"
            );

            if (!image || !placeholder) {
                return;
            }

            var imageUrl = buildCartImageUrl(
                    option.dataset.image,
                    option.dataset.imageVersion
            );

            if (!imageUrl) {
                image.style.display = "none";
                placeholder.style.display = "flex";
                return;
            }

            image.onerror = function () {
                image.style.display = "none";
                placeholder.style.display = "flex";
            };

            image.src = imageUrl;
            image.style.display = "block";
            placeholder.style.display = "none";
        }

        function syncVariantSelect(select) {
            var form = select.closest('.cart-update-form');
            var option = select.options[select.selectedIndex];
            if (!form || !option) {
                return;
            }

            var triggerValue = form.querySelector('.variant-trigger-value');
            if (triggerValue) {
                triggerValue.textContent = option.dataset.attributes || option.textContent.trim() || 'Standard';
            }

            var stock = parseInt(option.dataset.stock, 10);
            var stockValue = form.querySelector('.variant-stock-value');
            if (stockValue && !isNaN(stock)) {
                stockValue.textContent = stock;
            }

            var input = form.querySelector('.quantity-input');
            if (input && !isNaN(stock)) {
                input.max = stock;
                input.dataset.stock = stock;
                normalizeQuantity(input, stock);
            }

            previewSelectedVariantImage(form, option);
            updateQuantityButtons(form);
        }

        function markVariantChoice(popover, value) {
            popover.querySelectorAll('.variant-choice').forEach(function(choice) {
                choice.classList.toggle('is-selected', choice.dataset.value === String(value));
            });
        }

        function closeVariantPopover(popover) {
            if (!popover) {
                return;
            }

            var form = popover.closest('.cart-update-form');
            var block = popover.closest('.variant-block');
            var trigger = form ? form.querySelector('.variant-trigger') : null;
            var select = form ? form.querySelector('.variant-select') : null;

            popover.hidden = true;
            if (block) {
                block.classList.remove('is-open');
            }
            if (trigger) {
                trigger.setAttribute('aria-expanded', 'false');
            }

            if (select) {
                markVariantChoice(popover, select.value);
                syncVariantSelect(select);
            }
        }

        function closeAllVariantPopovers(except) {
            document.querySelectorAll('.variant-popover').forEach(function(popover) {
                if (popover !== except) {
                    closeVariantPopover(popover);
                }
            });
        }

        document.querySelectorAll('.variant-select').forEach(function(select) {
            var form = select.closest('.cart-update-form');
            var trigger = form ? form.querySelector('.variant-trigger') : null;
            var popover = form ? form.querySelector('.variant-popover') : null;

            syncVariantSelect(select);

            if (!form || !trigger || !popover) {
                return;
            }

            trigger.addEventListener('click', function(event) {
                event.stopPropagation();
                var shouldOpen = popover.hidden;
                var block = trigger.closest('.variant-block');
                closeAllVariantPopovers(popover);
                popover.hidden = !shouldOpen;
                trigger.setAttribute('aria-expanded', shouldOpen ? 'true' : 'false');
                if (block) {
                    block.classList.toggle('is-open', shouldOpen);
                }
                if (shouldOpen) {
                    markVariantChoice(popover, select.value);
                }
            });

            popover.querySelectorAll('.variant-choice').forEach(function(choice) {
                choice.addEventListener('click', function(event) {
                    event.stopPropagation();
                    if (choice.disabled) {
                        return;
                    }

                    if (choice.dataset.value === select.value) {
                        closeVariantPopover(popover);
                        return;
                    }

                    select.value = choice.dataset.value;
                    markVariantChoice(popover, choice.dataset.value);
                    syncVariantSelect(select);
                    closeVariantPopover(popover);
                    submitCartForm(form);
                });
            });
        });

        document.addEventListener('click', function(event) {
            if (!event.target.closest('.variant-block')) {
                closeAllVariantPopovers();
            }
        });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeAllVariantPopovers();
            }
        });

        document.querySelectorAll('.cart-update-form').forEach(updateQuantityButtons);

        document.querySelectorAll('.quantity-step').forEach(function(button) {
            button.addEventListener('click', function() {
                if (button.disabled) {
                    return;
                }

                var form = button.closest('.cart-update-form');
                var input = form.querySelector('.quantity-input');
                var current = parseInt(input.value, 10);
                var step = parseInt(button.dataset.step, 10);
                var stock = getCurrentStock(form);
                var next = (isNaN(current) ? 1 : current) + (isNaN(step) ? 0 : step);

                if (next < 1) {
                    return;
                }

                if (stock <= 0 || next > stock) {
                    updateQuantityButtons(form);
                    return;
                }

                input.value = next;
                updateQuantityButtons(form);
                submitCartForm(form);
            });
        });

        document.querySelectorAll('.quantity-input').forEach(function(input) {
            input.addEventListener('change', function() {
                var form = input.closest('.cart-update-form');
                normalizeQuantity(input, getCurrentStock(form));
                updateQuantityButtons(form);
                submitCartForm(form);
            });
        });

        var cartFlashMessage = document.getElementById('cartFlashMessage');
        if (cartFlashMessage) {
            var cartFlashTimer;
            function closeCartFlashMessage() {
                clearTimeout(cartFlashTimer);
                cartFlashMessage.classList.add('is-hiding');
                setTimeout(function() {
                    cartFlashMessage.remove();
                }, 220);
            }
            cartFlashMessage.querySelector('.cart-toast-close')
                    .addEventListener('click', closeCartFlashMessage);
            cartFlashTimer = setTimeout(closeCartFlashMessage, 3000);
        }

        var cartSelectInputs = document.querySelectorAll('.cart-select-input');
        var selectAllInputs = document.querySelectorAll('#cartSelectAllTop, #cartSelectAllShop, #cartSelectAllBottom');
        var selectedQuantity = document.getElementById('selectedQuantity');
        var selectedTotal = document.getElementById('selectedTotal');
        var checkoutSelectedButton = document.getElementById('checkoutSelectedButton');
        var cartCheckoutForm = document.getElementById('cartCheckoutForm');

        function formatVnd(value) {
            try {
                return new Intl.NumberFormat('vi-VN', {
                    style: 'currency',
                    currency: 'VND'
                }).format(value);
            } catch (error) {
                return value.toLocaleString('vi-VN') + ' \u20ab';
            }
        }

        function updateSelectedSummary() {
            var quantity = 0;
            var total = 0;
            var checkedLines = 0;

            cartSelectInputs.forEach(function(input) {
                if (!input.checked) {
                    return;
                }

                checkedLines += 1;
                quantity += Number(input.dataset.lineQuantity || 0);
                total += Number(input.dataset.lineTotal || 0);
            });

            if (selectedQuantity) {
                selectedQuantity.textContent = quantity;
            }

            if (selectedTotal) {
                selectedTotal.textContent = formatVnd(total);
            }

            if (checkoutSelectedButton) {
                checkoutSelectedButton.disabled = quantity === 0;
            }

            selectAllInputs.forEach(function(input) {
                input.checked = cartSelectInputs.length > 0 && checkedLines === cartSelectInputs.length;
                input.indeterminate = checkedLines > 0 && checkedLines < cartSelectInputs.length;
            });
        }

        cartSelectInputs.forEach(function(input) {
            input.addEventListener('change', updateSelectedSummary);
        });

        selectAllInputs.forEach(function(input) {
            input.addEventListener('change', function() {
                var shouldSelect = input.checked;
                cartSelectInputs.forEach(function(itemInput) {
                    itemInput.checked = shouldSelect;
                });
                updateSelectedSummary();
            });
        });

        if (cartCheckoutForm) {
            cartCheckoutForm.addEventListener('submit', function(event) {
                var hasSelectedItem = false;

                cartSelectInputs.forEach(function(input) {
                    if (input.checked) {
                        hasSelectedItem = true;
                    }
                });

                if (!hasSelectedItem) {
                    event.preventDefault();
                }
            });
        }

        updateSelectedSummary();
    </script>
    <script>
        (function () {
            document.querySelectorAll('.account-menu').forEach(function (account) {
                var summary = account.querySelector('summary');

                if (!summary) {
                    return;
                }

                account.addEventListener('toggle', function () {
                    summary.setAttribute('aria-expanded', account.open ? 'true' : 'false');
                });
                summary.setAttribute('aria-expanded', account.open ? 'true' : 'false');

                document.addEventListener('click', function (event) {
                    if (!account.contains(event.target)) {
                        account.removeAttribute('open');
                        summary.setAttribute('aria-expanded', 'false');
                    }
                });

                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && account.open) {
                        account.removeAttribute('open');
                        summary.setAttribute('aria-expanded', 'false');
                        summary.focus();
                    }
                });
            });
        }());
    </script>
    <jsp:include page="/view/customer/common/footer.jsp"/>
</body>
</html>