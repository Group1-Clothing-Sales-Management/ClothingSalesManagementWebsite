<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Clothing Sale | Home</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

        <c:url var="customerThemeUrl" value="/assets/customer-theme.css"/>
        <link href="${customerThemeUrl}" rel="stylesheet">

        <style>
            :root {
                --home-page-bg: #f4f7fc;
                --home-surface: #ffffff;
                --home-surface-soft: #eef4ff;
                --home-primary: #5f84d6;
                --home-primary-dark: #365b9f;
                --home-primary-light: #dce8fb;
                --home-ink: #17233d;
                --home-text: #283750;
                --home-muted: #6b7890;
                --home-border: #dbe4f3;
                --home-danger: #d9485f;
                --home-warning: #dc8a15;
                --home-success: #16805b;
                --home-shadow-sm: 0 5px 18px rgba(49, 78, 130, .08);
                --home-shadow-md: 0 16px 38px rgba(49, 78, 130, .13);
                --home-container: 1320px;
            }

            * {
                box-sizing: border-box;
            }

            body {
                min-width: 320px;
                margin: 0;
                background: var(--home-page-bg);
                color: var(--home-text);
                font-family: "Inter", "Segoe UI", Arial, sans-serif;
            }

            .home-page {
                flex: 1 0 auto;
                width: 100%;
                padding-bottom: 64px;
            }

            .home-container {
                width: min(var(--home-container), calc(100% - 48px));
                margin: 0 auto;
            }

            .home-hero {
                padding: 32px 0 0;
            }

            .home-hero-panel {
                position: relative;
                min-height: 410px;
                overflow: hidden;
                border: 1px solid var(--home-border);
                border-radius: 26px;
                background:
                    radial-gradient(circle at 82% 24%, rgba(255, 255, 255, .9) 0 9%, transparent 10%),
                    radial-gradient(circle at 91% 74%, rgba(255, 255, 255, .55) 0 15%, transparent 16%),
                    linear-gradient(120deg, #dce8fb 0%, #eef4ff 42%, #a9c0ea 100%);
                box-shadow: var(--home-shadow-md);
            }

            .home-hero-panel::before {
                content: "";
                position: absolute;
                top: -110px;
                right: -80px;
                width: 380px;
                height: 380px;
                border: 74px solid rgba(255, 255, 255, .28);
                border-radius: 50%;
            }

            .home-hero-inner {
                position: relative;
                z-index: 1;
                min-height: 410px;
                display: grid;
                grid-template-columns: minmax(0, 1.05fr) minmax(360px, .95fr);
                align-items: center;
                gap: 42px;
                padding: 54px 60px;
            }

            .home-kicker {
                display: inline-flex;
                align-items: center;
                gap: 9px;
                margin-bottom: 16px;
                color: var(--home-primary-dark);
                font-size: .78rem;
                font-weight: 800;
                letter-spacing: .12em;
                text-transform: uppercase;
            }

            .home-kicker::before {
                content: "";
                width: 30px;
                height: 3px;
                border-radius: 99px;
                background: var(--home-primary);
            }

            .home-hero-title {
                max-width: 720px;
                margin: 0;
                color: var(--home-ink);
                font-size: clamp(2.65rem, 5.2vw, 5rem);
                font-weight: 850;
                letter-spacing: -.055em;
                line-height: .98;
            }

            .home-hero-copy {
                max-width: 620px;
                margin: 22px 0 0;
                color: #4f607c;
                font-size: 1.02rem;
                line-height: 1.75;
            }

            .home-hero-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
                margin-top: 28px;
            }

            .home-btn-primary,
            .home-btn-secondary {
                min-height: 46px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 9px;
                padding: 11px 20px;
                border: 1px solid transparent;
                border-radius: 11px;
                font-size: .9rem;
                font-weight: 750;
                text-decoration: none;
                transition: transform .2s ease, background-color .2s ease,
                    border-color .2s ease, color .2s ease, box-shadow .2s ease;
            }

            .home-btn-primary {
                color: #fff;
                background: var(--home-primary-dark);
                box-shadow: 0 10px 22px rgba(54, 91, 159, .22);
            }

            .home-btn-primary:hover {
                color: #fff;
                background: #284b89;
                transform: translateY(-2px);
            }

            .home-btn-secondary {
                color: var(--home-primary-dark);
                border-color: rgba(54, 91, 159, .28);
                background: rgba(255, 255, 255, .72);
            }

            .home-btn-secondary:hover {
                color: var(--home-primary-dark);
                border-color: var(--home-primary);
                background: #fff;
                transform: translateY(-2px);
            }

            .home-hero-stats {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 14px;
            }

            .home-stat-card {
                min-height: 122px;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 20px;
                border: 1px solid rgba(255, 255, 255, .76);
                border-radius: 18px;
                background: rgba(255, 255, 255, .7);
                box-shadow: 0 13px 32px rgba(54, 91, 159, .12);
                backdrop-filter: blur(12px);
            }

            .home-stat-card.is-wide {
                grid-column: 1 / -1;
                min-height: 112px;
            }

            .home-stat-icon {
                width: 38px;
                height: 38px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 11px;
                color: #fff;
                background: linear-gradient(135deg, var(--home-primary), var(--home-primary-dark));
            }

            .home-stat-value {
                margin-top: 14px;
                color: var(--home-ink);
                font-size: 1.7rem;
                font-weight: 850;
                line-height: 1;
            }

            .home-stat-label {
                margin-top: 6px;
                color: var(--home-muted);
                font-size: .78rem;
                font-weight: 650;
            }

            .home-section {
                padding-top: 64px;
            }

            .home-section-header {
                display: flex;
                align-items: flex-end;
                justify-content: space-between;
                gap: 24px;
                margin-bottom: 22px;
            }

            .home-section-kicker {
                display: block;
                margin-bottom: 7px;
                color: var(--home-primary);
                font-size: .72rem;
                font-weight: 800;
                letter-spacing: .11em;
                text-transform: uppercase;
            }

            .home-section-title {
                margin: 0;
                color: var(--home-ink);
                font-size: clamp(1.65rem, 2.8vw, 2.2rem);
                font-weight: 820;
                letter-spacing: -.035em;
            }

            .home-section-description {
                max-width: 680px;
                margin: 7px 0 0;
                color: var(--home-muted);
                font-size: .92rem;
                line-height: 1.65;
            }

            .home-section-link {
                flex: 0 0 auto;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: var(--home-primary-dark);
                font-size: .86rem;
                font-weight: 750;
                text-decoration: none;
            }

            .home-section-link:hover {
                color: var(--home-primary);
            }

            .home-category-grid {
                display: grid;
                grid-template-columns: repeat(6, minmax(0, 1fr));
                gap: 14px;
            }

            .home-category-card {
                min-height: 150px;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 18px;
                overflow: hidden;
                border: 1px solid var(--home-border);
                border-radius: 17px;
                color: var(--home-text);
                background: var(--home-surface);
                box-shadow: var(--home-shadow-sm);
                text-decoration: none;
                transition: transform .2s ease, border-color .2s ease,
                    box-shadow .2s ease;
            }

            .home-category-card:hover {
                color: var(--home-text);
                border-color: #afc4e8;
                box-shadow: var(--home-shadow-md);
                transform: translateY(-4px);
            }

            .home-category-icon {
                width: 46px;
                height: 46px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 14px;
                color: var(--home-primary-dark);
                background: var(--home-primary-light);
                font-size: 1.15rem;
            }

            .home-category-name {
                display: block;
                margin-top: 19px;
                overflow: hidden;
                color: var(--home-ink);
                font-size: .94rem;
                font-weight: 760;
                line-height: 1.35;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .home-category-meta {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 8px;
                margin-top: 6px;
                color: var(--home-muted);
                font-size: .73rem;
                font-weight: 600;
            }

            .home-product-grid {
                display: grid;
                grid-template-columns: repeat(4, minmax(0, 1fr));
                gap: 20px;
            }

            .home-product-card {
                min-width: 0;
                display: flex;
                flex-direction: column;
                overflow: hidden;
                border: 1px solid var(--home-border);
                border-radius: 17px;
                background: var(--home-surface);
                box-shadow: var(--home-shadow-sm);
                transition: transform .22s ease, border-color .22s ease,
                    box-shadow .22s ease;
            }

            .home-product-card:hover {
                border-color: #afc4e8;
                box-shadow: var(--home-shadow-md);
                transform: translateY(-5px);
            }

            .home-product-media {
                position: relative;
                display: block;
                aspect-ratio: 4 / 4.35;
                overflow: hidden;
                background: #edf2f9;
            }

            .home-product-image {
                width: 100%;
                height: 100%;
                display: block;
                object-fit: contain;
                background: #fff;
                transition: transform .28s ease;
            }

            .home-product-card:hover .home-product-image {
                transform: scale(1.035);
            }

            .home-product-placeholder {
                width: 100%;
                height: 100%;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 10px;
                color: #8a97aa;
                background:
                    linear-gradient(135deg, #edf2f9 0%, #f8fafd 100%);
            }

            .home-product-placeholder i {
                font-size: 2.1rem;
            }

            .home-product-placeholder span {
                font-size: .76rem;
                font-weight: 650;
            }

            .home-product-badge {
                position: absolute;
                top: 13px;
                left: 13px;
                z-index: 2;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                min-height: 28px;
                padding: 5px 9px;
                border-radius: 999px;
                color: #fff;
                font-size: .68rem;
                font-weight: 800;
                letter-spacing: .02em;
                box-shadow: 0 6px 16px rgba(23, 35, 61, .16);
            }

            .home-product-badge.is-featured {
                background: linear-gradient(135deg, #5f84d6, #365b9f);
            }

            .home-product-badge.is-best {
                background: linear-gradient(135deg, #f2a630, #cf7710);
            }

            .home-product-badge.is-sale {
                background: linear-gradient(135deg, #e45c70, #c93950);
            }

            .home-wishlist-form {
                position: absolute;
                top: 12px;
                right: 12px;
                z-index: 3;
                margin: 0;
            }

            .home-wishlist-button {
                width: 38px;
                height: 38px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid rgba(219, 228, 243, .92);
                border-radius: 50%;
                color: var(--home-primary-dark);
                background: rgba(255, 255, 255, .94);
                box-shadow: 0 7px 18px rgba(49, 78, 130, .14);
                transition: color .2s ease, background-color .2s ease,
                    transform .2s ease;
            }

            .home-wishlist-button:hover,
            .home-wishlist-button.is-active {
                color: #fff;
                background: var(--home-danger);
                transform: scale(1.06);
            }

            .home-product-content {
                flex: 1 1 auto;
                display: flex;
                flex-direction: column;
                padding: 17px 17px 15px;
            }

            .home-product-title {
                min-height: 44px;
                margin: 0;
                display: -webkit-box;
                overflow: hidden;
                color: var(--home-ink);
                font-size: .96rem;
                font-weight: 760;
                line-height: 1.45;
                text-overflow: ellipsis;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
            }

            .home-product-title a {
                color: inherit;
                text-decoration: none;
            }

            .home-product-title a:hover {
                color: var(--home-primary);
            }

            .home-product-description {
                min-height: 39px;
                margin: 8px 0 0;
                display: -webkit-box;
                overflow: hidden;
                color: var(--home-muted);
                font-size: .76rem;
                line-height: 1.5;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
            }

            .home-price-row {
                min-height: 48px;
                display: flex;
                align-items: flex-end;
                flex-wrap: wrap;
                gap: 6px 9px;
                margin-top: 13px;
            }

            .home-current-price {
                color: var(--home-primary-dark);
                font-size: 1.12rem;
                font-weight: 850;
                line-height: 1.1;
            }

            .home-list-price {
                color: #9aa5b5;
                font-size: .78rem;
                font-weight: 650;
                text-decoration: line-through;
            }

            .home-discount {
                padding: 3px 6px;
                border-radius: 6px;
                color: #bd2f46;
                background: #fff0f3;
                font-size: .67rem;
                font-weight: 800;
            }

            .home-product-meta {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                margin-top: 10px;
                color: var(--home-muted);
                font-size: .72rem;
                font-weight: 650;
            }

            .home-product-meta span {
                min-width: 0;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .home-stock {
                flex: 0 0 auto;
                color: var(--home-success);
            }

            .home-product-purchase {
                display: grid;
                grid-template-columns: minmax(0, 1fr) auto;
                gap: 8px;
                margin-top: auto;
                padding-top: 14px;
            }

            .home-variant-select {
                min-width: 0;
                height: 39px;
                border: 1px solid var(--home-border);
                border-radius: 9px;
                padding: 6px 30px 6px 10px;
                color: var(--home-text);
                background-color: #fff;
                font-size: .74rem;
                font-weight: 600;
            }

            .home-variant-select:focus {
                border-color: var(--home-primary);
                outline: 0;
                box-shadow: 0 0 0 .18rem rgba(95, 132, 214, .14);
            }

            .home-add-cart-button {
                width: 42px;
                height: 39px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid var(--home-primary-dark);
                border-radius: 9px;
                color: #fff;
                background: var(--home-primary-dark);
                transition: background-color .2s ease, border-color .2s ease,
                    transform .2s ease;
            }

            .home-add-cart-button:hover:not(:disabled) {
                border-color: #284b89;
                background: #284b89;
                transform: translateY(-1px);
            }

            .home-add-cart-button:disabled {
                cursor: not-allowed;
                opacity: .55;
            }

            .home-detail-link {
                min-height: 39px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-top: 14px;
                padding: 8px 12px;
                border: 1px solid var(--home-border);
                border-radius: 9px;
                color: var(--home-primary-dark);
                font-size: .78rem;
                font-weight: 750;
                text-decoration: none;
            }

            .home-detail-link:hover {
                color: #fff;
                border-color: var(--home-primary-dark);
                background: var(--home-primary-dark);
            }

            .home-empty-state {
                padding: 36px 24px;
                border: 1px dashed #b9c8df;
                border-radius: 17px;
                color: var(--home-muted);
                background: rgba(255, 255, 255, .62);
                text-align: center;
            }

            .home-empty-state i {
                display: block;
                margin-bottom: 12px;
                color: var(--home-primary);
                font-size: 1.8rem;
            }

            .home-benefit-grid {
                display: grid;
                grid-template-columns: repeat(4, minmax(0, 1fr));
                gap: 14px;
            }

            .home-benefit-card {
                display: flex;
                align-items: center;
                gap: 14px;
                min-height: 100px;
                padding: 18px;
                border: 1px solid var(--home-border);
                border-radius: 16px;
                background: var(--home-surface);
                box-shadow: var(--home-shadow-sm);
            }

            .home-benefit-icon {
                flex: 0 0 46px;
                width: 46px;
                height: 46px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 14px;
                color: var(--home-primary-dark);
                background: var(--home-primary-light);
                font-size: 1.05rem;
            }

            .home-benefit-title {
                margin: 0;
                color: var(--home-ink);
                font-size: .88rem;
                font-weight: 760;
            }

            .home-benefit-text {
                margin: 4px 0 0;
                color: var(--home-muted);
                font-size: .72rem;
                line-height: 1.45;
            }

            .home-alert {
                margin-top: 24px;
                border: 1px solid #f1c2c9;
                border-radius: 13px;
                color: #9e2739;
                background: #fff3f5;
            }

            .home-toast {
                position: fixed;
                top: 92px;
                right: 22px;
                z-index: 1080;
                min-width: 270px;
                max-width: 390px;
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 14px 16px;
                border-radius: 12px;
                color: #fff;
                background: var(--home-ink);
                box-shadow: 0 18px 42px rgba(23, 35, 61, .22);
                opacity: 0;
                pointer-events: none;
                transform: translateY(-12px);
                transition: opacity .25s ease, transform .25s ease;
            }

            .home-toast.show {
                opacity: 1;
                transform: translateY(0);
            }

            .home-toast.is-error {
                background: #a53244;
            }

            @media (max-width: 1199.98px) {
                .home-hero-inner {
                    grid-template-columns: 1fr .8fr;
                    padding: 46px 42px;
                }

                .home-category-grid {
                    grid-template-columns: repeat(3, minmax(0, 1fr));
                }

                .home-product-grid {
                    grid-template-columns: repeat(3, minmax(0, 1fr));
                }

                .home-benefit-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 991.98px) {
                .home-container {
                    width: min(var(--home-container), calc(100% - 40px));
                }

                .home-hero-panel,
                .home-hero-inner {
                    min-height: 0;
                }

                .home-hero-inner {
                    grid-template-columns: 1fr;
                    gap: 30px;
                    padding: 42px 34px;
                }

                .home-hero-stats {
                    max-width: 640px;
                }

                .home-product-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 767.98px) {
                .home-page {
                    padding-bottom: 48px;
                }

                .home-container {
                    width: calc(100% - 32px);
                }

                .home-hero {
                    padding-top: 20px;
                }

                .home-hero-panel {
                    border-radius: 20px;
                }

                .home-hero-inner {
                    padding: 34px 24px;
                }

                .home-hero-title {
                    font-size: clamp(2.25rem, 12vw, 3.35rem);
                }

                .home-section {
                    padding-top: 48px;
                }

                .home-section-header {
                    align-items: flex-start;
                    flex-direction: column;
                    gap: 12px;
                }

                .home-category-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                    gap: 10px;
                }

                .home-category-card {
                    min-height: 132px;
                    padding: 15px;
                }

                .home-benefit-grid {
                    grid-template-columns: 1fr;
                }
            }

            @media (max-width: 479.98px) {
                .home-hero-actions {
                    flex-direction: column;
                }

                .home-btn-primary,
                .home-btn-secondary {
                    width: 100%;
                }

                .home-hero-stats {
                    grid-template-columns: 1fr;
                }

                .home-stat-card.is-wide {
                    grid-column: auto;
                }

                .home-product-grid {
                    grid-template-columns: 1fr;
                }
            }
        
            /* Homepage product cards use the same structure as Product List. */
            .home-product-grid {
                display: grid;
                grid-template-columns: repeat(6, minmax(0, 1fr));
                gap: 16px;
            }

            .home-product-card {
                min-width: 0;
                display: flex;
                flex-direction: column;
                overflow: hidden;
                border: 1px solid rgba(138, 170, 229, .30);
                border-radius: 8px;
                background: #ffffff;
                box-shadow: 0 8px 26px rgba(31, 41, 55, .08);
                transition: transform .2s ease, border-color .2s ease,
                    box-shadow .2s ease;
            }

            .home-product-card:hover {
                border-color: rgba(138, 170, 229, .78);
                box-shadow: 0 20px 38px rgba(95, 132, 214, .20);
                transform: translateY(-4px);
            }

            .home-product-media {
                position: relative;
                display: block;
                aspect-ratio: 1 / 1;
                overflow: hidden;
                background: #eef4ff;
            }

            .home-product-image {
                width: 100%;
                height: 100%;
                display: block;
                object-fit: contain;
                background: #ffffff;
                transition: transform .25s ease;
            }

            .home-product-card:hover .home-product-image {
                transform: scale(1.03);
            }

            .home-product-badge {
                position: absolute;
                z-index: 2;
                top: 8px;
                left: 0;
                min-height: 28px;
                display: inline-flex;
                align-items: center;
                gap: 5px;
                padding: 6px 8px;
                border-radius: 0 8px 8px 0;
                color: #ffffff;
                font-size: .68rem;
                font-weight: 800;
                line-height: 1;
                box-shadow: none;
            }

            .home-product-stock-badge {
                position: absolute;
                z-index: 2;
                top: 8px;
                right: 8px;
                min-height: 28px;
                display: inline-flex;
                align-items: center;
                padding: 6px 8px;
                border-radius: 8px;
                color: #365b9f;
                background: #ffffff;
                box-shadow: 0 8px 18px rgba(31, 41, 55, .10);
                font-size: .68rem;
                font-weight: 800;
                line-height: 1;
            }

            .home-product-content {
                flex: 1 1 auto;
                display: flex;
                flex-direction: column;
                padding: 11px 12px 8px;
            }

            .home-product-title {
                min-height: 40px;
                margin: 0 0 4px;
                display: -webkit-box;
                overflow: hidden;
                color: var(--home-ink);
                font-size: .86rem;
                font-weight: 760;
                line-height: 1.35;
                text-overflow: ellipsis;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
            }

            .home-price-row {
                min-height: 44px;
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 5px 8px;
                margin-top: 6px;
            }

            .home-current-price {
                color: var(--home-primary-dark);
                font-size: 1.05rem;
                font-weight: 850;
                line-height: 1.2;
            }

            .home-list-price {
                color: #9aa5b5;
                font-size: .74rem;
                font-weight: 650;
                text-decoration: line-through;
            }

            .home-discount {
                padding: 3px 6px;
                border-radius: 6px;
                color: #bd2f46;
                background: #fff0f3;
                font-size: .66rem;
                font-weight: 800;
            }

            .home-wishlist-form {
                position: static;
                display: block;
                margin: 8px 0 2px;
            }

            .home-wishlist-button {
                width: 34px;
                height: 34px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid #d7e1f5;
                border-radius: 50%;
                color: var(--home-primary-dark);
                background: #ffffff;
                box-shadow: 0 8px 18px rgba(95, 132, 214, .14);
                transition: color .2s ease, background-color .2s ease,
                    border-color .2s ease, transform .2s ease;
            }

            .home-wishlist-button:hover,
            .home-wishlist-button.is-active {
                border-color: var(--home-primary);
                color: #ffffff;
                background: var(--home-primary);
                transform: scale(1.04);
            }

            @media (max-width: 1199.98px) {
                .home-product-grid {
                    grid-template-columns: repeat(4, minmax(0, 1fr));
                }
            }

            @media (max-width: 991.98px) {
                .home-product-grid {
                    grid-template-columns: repeat(3, minmax(0, 1fr));
                }
            }

            @media (max-width: 767.98px) {
                .home-product-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 479.98px) {
                .home-product-grid {
                    grid-template-columns: 1fr;
                }
            }

        </style>
    </head>

    <body>
        <jsp:include page="/view/customer/common/header.jsp"/>

        <main class="home-page">
            <section class="home-hero">
                <div class="home-container">
                    <div class="home-hero-panel">
                        <div class="home-hero-inner">
                            <div>
                                <span class="home-kicker">Style made simple</span>
                                <h1 class="home-hero-title">
                                    Discover pieces made for every day.
                                </h1>
                                <p class="home-hero-copy">
                                    Shop Admin-curated favourites, proven best sellers,
                                    and live sale prices in one consistent shopping experience.
                                </p>

                                <div class="home-hero-actions">
                                    <a href="${pageContext.request.contextPath}/products"
                                       class="home-btn-primary">
                                        Shop all products
                                        <i class="fa-solid fa-arrow-right"></i>
                                    </a>

                                    <a href="${pageContext.request.contextPath}/products?promotion=sale"
                                       class="home-btn-secondary">
                                        Explore sale
                                        <i class="fa-solid fa-tag"></i>
                                    </a>
                                </div>
                            </div>

                            <div class="home-hero-stats" aria-label="Homepage collections">
                                <div class="home-stat-card">
                                    <span class="home-stat-icon">
                                        <i class="fa-solid fa-star"></i>
                                    </span>
                                    <div>
                                        <div class="home-stat-value">
                                            ${fn:length(featuredProducts)}
                                        </div>
                                        <div class="home-stat-label">Featured products</div>
                                    </div>
                                </div>

                                <div class="home-stat-card">
                                    <span class="home-stat-icon">
                                        <i class="fa-solid fa-ranking-star"></i>
                                    </span>
                                    <div>
                                        <div class="home-stat-value">
                                            ${fn:length(bestSellerProducts)}
                                        </div>
                                        <div class="home-stat-label">Current best sellers</div>
                                    </div>
                                </div>

                                <div class="home-stat-card is-wide">
                                    <span class="home-stat-icon">
                                        <i class="fa-solid fa-percent"></i>
                                    </span>
                                    <div>
                                        <div class="home-stat-value">
                                            ${fn:length(onSaleProducts)}
                                        </div>
                                        <div class="home-stat-label">
                                            Products currently offered at a lower sale price
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert home-alert mb-0" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <c:out value="${errorMessage}"/>
                        </div>
                    </c:if>
                </div>
            </section>

            <section class="home-section" id="featuredProducts"
                     aria-labelledby="featuredProductsTitle">
                <div class="home-container">
                    <div class="home-section-header">
                        <div>
                            <span class="home-section-kicker">Selected by Admin</span>
                            <h2 class="home-section-title" id="featuredProductsTitle">
                                Featured products
                            </h2>
                            <p class="home-section-description">
                                A curated selection chosen directly from Product Management.
                            </p>
                        </div>

                        <a href="${pageContext.request.contextPath}/products"
                           class="home-section-link">
                            View all
                            <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>

                    <c:choose>
                        <c:when test="${not empty featuredProducts}">
                            <div class="home-product-grid">
                                <c:forEach items="${featuredProducts}"
                                           var="p"
                                           varStatus="productStatus">
                                    <c:set var="displayVariant" value="${null}"/>
                                    <c:forEach items="${p.variants}" var="v">
                                        <c:if test="${v.stockQuantity > 0
                                                      and (empty displayVariant
                                                           or v.salePrice < displayVariant.salePrice)}">
                                            <c:set var="displayVariant" value="${v}"/>
                                        </c:if>
                                    </c:forEach>

                                    <c:set var="isWishlisted"
                                           value="${wishlistProductIds.contains(p.id)}"/>

                                                                        <article class="home-product-card">
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                           class="home-product-media">
                                            <span class="home-product-badge is-featured">Featured</span>

                                            <c:if test="${not empty displayVariant}">
                                                <span class="home-product-stock-badge">In stock</span>
                                            </c:if>

                                            <c:choose>
                                                <c:when test="${not empty p.mainImageUrl}">
                                                    <c:url var="featuredImageUrl"
                                                           value="/media/product/${p.mainImageUrl}"/>
                                                    <img src="${featuredImageUrl}"
                                                         class="home-product-image"
                                                         alt="${fn:escapeXml(p.productName)}"
                                                         loading="lazy"
                                                         decoding="async"
                                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                    <div class="home-product-placeholder"
                                                         style="display:none;">
                                                        <i class="fa-regular fa-image"></i>
                                                        <span>Image unavailable</span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="home-product-placeholder">
                                                        <i class="fa-regular fa-image"></i>
                                                        <span>No product image</span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </a>

                                        <div class="home-product-content">
                                            <h3 class="home-product-title">
                                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                                                    <c:out value="${p.productName}"/>
                                                </a>
                                            </h3>

                                            <c:if test="${not empty displayVariant}">
                                                <div class="home-price-row">
                                                    <span class="home-current-price">
                                                        <fmt:formatNumber value="${displayVariant.salePrice}"
                                                                          pattern="#,##0"/>
                                                        &#8363;
                                                    </span>

                                                    <c:if test="${displayVariant.listPrice > displayVariant.salePrice}">
                                                        <span class="home-list-price">
                                                            <fmt:formatNumber value="${displayVariant.listPrice}"
                                                                              pattern="#,##0"/>
                                                            &#8363;
                                                        </span>
                                                        <span class="home-discount">
                                                            -<fmt:formatNumber
                                                                value="${(displayVariant.listPrice - displayVariant.salePrice)
                                                                         * 100 / displayVariant.listPrice}"
                                                                maxFractionDigits="0"/>%
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </c:if>

                                            <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                                  method="post"
                                                  class="home-wishlist-form">
                                                <input type="hidden" name="productId" value="${p.id}">
                                                <input type="hidden"
                                                       name="variantId"
                                                       value="${not empty displayVariant ? displayVariant.id : ''}">
                                                <input type="hidden"
                                                       name="wishlisted"
                                                       value="${isWishlisted}">
                                                <button type="submit"
                                                        class="home-wishlist-button ${isWishlisted ? 'is-active' : ''}"
                                                        title="${isWishlisted
                                                                 ? 'Remove from wishlist'
                                                                 : 'Add to wishlist'}">
                                                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="home-empty-state">
                                <i class="fa-regular fa-star"></i>
                                No Featured Products have been selected yet.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <c:if test="${not empty bestSellerProducts}">
                <section class="home-section" id="bestSellerProducts"
                         aria-labelledby="bestSellerProductsTitle">
                    <div class="home-container">
                        <div class="home-section-header">
                            <div>
                                <span class="home-section-kicker">Customer favourites</span>
                                <h2 class="home-section-title" id="bestSellerProductsTitle">
                                    Best sellers
                                </h2>
                                <p class="home-section-description">
                                    Ranked from quantities sold in successfully delivered orders.
                                </p>
                            </div>

                            <a href="${pageContext.request.contextPath}/products?sort=best-selling"
                               class="home-section-link">
                                View all best sellers
                                <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>

                        <div class="home-product-grid">
                            <c:forEach items="${bestSellerProducts}"
                                       var="p"
                                       varStatus="productStatus">
                                <c:set var="displayVariant" value="${null}"/>
                                <c:forEach items="${p.variants}" var="v">
                                    <c:if test="${v.stockQuantity > 0
                                                  and (empty displayVariant
                                                       or v.salePrice < displayVariant.salePrice)}">
                                        <c:set var="displayVariant" value="${v}"/>
                                    </c:if>
                                </c:forEach>

                                <c:set var="isWishlisted"
                                       value="${wishlistProductIds.contains(p.id)}"/>

                                                                <article class="home-product-card">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                       class="home-product-media">
                                        <span class="home-product-badge is-best">Best seller</span>

                                        <c:if test="${not empty displayVariant}">
                                            <span class="home-product-stock-badge">In stock</span>
                                        </c:if>

                                        <c:choose>
                                            <c:when test="${not empty p.mainImageUrl}">
                                                <c:url var="bestSellerImageUrl"
                                                       value="/media/product/${p.mainImageUrl}"/>
                                                <img src="${bestSellerImageUrl}"
                                                     class="home-product-image"
                                                     alt="${fn:escapeXml(p.productName)}"
                                                     loading="lazy"
                                                     decoding="async"
                                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                <div class="home-product-placeholder"
                                                     style="display:none;">
                                                    <i class="fa-regular fa-image"></i>
                                                    <span>Image unavailable</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="home-product-placeholder">
                                                    <i class="fa-regular fa-image"></i>
                                                    <span>No product image</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>

                                    <div class="home-product-content">
                                        <h3 class="home-product-title">
                                            <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                                                <c:out value="${p.productName}"/>
                                            </a>
                                        </h3>

                                        <c:if test="${not empty displayVariant}">
                                            <div class="home-price-row">
                                                <span class="home-current-price">
                                                    <fmt:formatNumber value="${displayVariant.salePrice}"
                                                                      pattern="#,##0"/>
                                                    &#8363;
                                                </span>

                                                <c:if test="${displayVariant.listPrice > displayVariant.salePrice}">
                                                    <span class="home-list-price">
                                                        <fmt:formatNumber value="${displayVariant.listPrice}"
                                                                          pattern="#,##0"/>
                                                        &#8363;
                                                    </span>
                                                    <span class="home-discount">
                                                        -<fmt:formatNumber
                                                            value="${(displayVariant.listPrice - displayVariant.salePrice)
                                                                     * 100 / displayVariant.listPrice}"
                                                            maxFractionDigits="0"/>%
                                                    </span>
                                                </c:if>
                                            </div>
                                        </c:if>

                                        <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                              method="post"
                                              class="home-wishlist-form">
                                            <input type="hidden" name="productId" value="${p.id}">
                                            <input type="hidden"
                                                   name="variantId"
                                                   value="${not empty displayVariant ? displayVariant.id : ''}">
                                            <input type="hidden"
                                                   name="wishlisted"
                                                   value="${isWishlisted}">
                                            <button type="submit"
                                                    class="home-wishlist-button ${isWishlisted ? 'is-active' : ''}"
                                                    title="${isWishlisted
                                                             ? 'Remove from wishlist'
                                                             : 'Add to wishlist'}">
                                                <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                            </button>
                                        </form>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </div>
                </section>
            </c:if>

            <c:if test="${not empty onSaleProducts}">
                <section class="home-section" id="onSaleProducts"
                         aria-labelledby="onSaleProductsTitle">
                    <div class="home-container">
                        <div class="home-section-header">
                            <div>
                                <span class="home-section-kicker">Live Admin pricing</span>
                                <h2 class="home-section-title" id="onSaleProductsTitle">
                                    On sale now
                                </h2>
                                <p class="home-section-description">
                                    Products appear here automatically when an active Variant has
                                    a Sale Price lower than its List Price.
                                </p>
                            </div>

                            <a href="${pageContext.request.contextPath}/products?promotion=sale"
                               class="home-section-link">
                                View all sale products
                                <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>

                        <div class="home-product-grid">
                            <c:forEach items="${onSaleProducts}"
                                       var="p"
                                       varStatus="productStatus">
                                <c:set var="displayVariant" value="${null}"/>
                                <c:set var="bestDiscountRatio" value="-1"/>

                                <c:forEach items="${p.variants}" var="v">
                                    <c:if test="${v.stockQuantity > 0
                                                  and v.listPrice > v.salePrice}">
                                        <c:set var="variantDiscountRatio"
                                               value="${(v.listPrice - v.salePrice) / v.listPrice}"/>
                                        <c:if test="${empty displayVariant
                                                      or variantDiscountRatio > bestDiscountRatio}">
                                            <c:set var="displayVariant" value="${v}"/>
                                            <c:set var="bestDiscountRatio"
                                                   value="${variantDiscountRatio}"/>
                                        </c:if>
                                    </c:if>
                                </c:forEach>

                                <c:set var="isWishlisted"
                                       value="${wishlistProductIds.contains(p.id)}"/>

                                                                <article class="home-product-card">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}"
                                       class="home-product-media">
                                        <span class="home-product-badge is-sale">
                                            <c:choose>
                                                <c:when test="${not empty displayVariant}">
                                                    Sale
                                                    <fmt:formatNumber
                                                        value="${(displayVariant.listPrice - displayVariant.salePrice)
                                                                 * 100 / displayVariant.listPrice}"
                                                        maxFractionDigits="0"/>%
                                                </c:when>
                                                <c:otherwise>
                                                    On sale
                                                </c:otherwise>
                                            </c:choose>
                                        </span>

                                        <c:if test="${not empty displayVariant}">
                                            <span class="home-product-stock-badge">In stock</span>
                                        </c:if>

                                        <c:choose>
                                            <c:when test="${not empty p.mainImageUrl}">
                                                <c:url var="saleImageUrl"
                                                       value="/media/product/${p.mainImageUrl}"/>
                                                <img src="${saleImageUrl}"
                                                     class="home-product-image"
                                                     alt="${fn:escapeXml(p.productName)}"
                                                     loading="lazy"
                                                     decoding="async"
                                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                <div class="home-product-placeholder"
                                                     style="display:none;">
                                                    <i class="fa-regular fa-image"></i>
                                                    <span>Image unavailable</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="home-product-placeholder">
                                                    <i class="fa-regular fa-image"></i>
                                                    <span>No product image</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>

                                    <div class="home-product-content">
                                        <h3 class="home-product-title">
                                            <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                                                <c:out value="${p.productName}"/>
                                            </a>
                                        </h3>

                                        <c:if test="${not empty displayVariant}">
                                            <div class="home-price-row">
                                                <span class="home-current-price">
                                                    <fmt:formatNumber value="${displayVariant.salePrice}"
                                                                      pattern="#,##0"/>
                                                    &#8363;
                                                </span>
                                                <span class="home-list-price">
                                                    <fmt:formatNumber value="${displayVariant.listPrice}"
                                                                      pattern="#,##0"/>
                                                    &#8363;
                                                </span>
                                                <span class="home-discount">
                                                    -<fmt:formatNumber
                                                        value="${(displayVariant.listPrice - displayVariant.salePrice)
                                                                 * 100 / displayVariant.listPrice}"
                                                        maxFractionDigits="0"/>%
                                                </span>
                                            </div>
                                        </c:if>

                                        <form action="${pageContext.request.contextPath}/wishlist/toggle"
                                              method="post"
                                              class="home-wishlist-form">
                                            <input type="hidden" name="productId" value="${p.id}">
                                            <input type="hidden"
                                                   name="variantId"
                                                   value="${not empty displayVariant ? displayVariant.id : ''}">
                                            <input type="hidden"
                                                   name="wishlisted"
                                                   value="${isWishlisted}">
                                            <button type="submit"
                                                    class="home-wishlist-button ${isWishlisted ? 'is-active' : ''}"
                                                    title="${isWishlisted
                                                             ? 'Remove from wishlist'
                                                             : 'Add to wishlist'}">
                                                <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                            </button>
                                        </form>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </div>
                </section>
            </c:if>

            <section class="home-section" aria-labelledby="homeBenefitsTitle">
                <div class="home-container">
                    <div class="home-section-header">
                        <div>
                            <span class="home-section-kicker">Shop with confidence</span>
                            <h2 class="home-section-title" id="homeBenefitsTitle">
                                A smoother shopping experience
                            </h2>
                        </div>
                    </div>

                    <div class="home-benefit-grid">
                        <article class="home-benefit-card">
                            <span class="home-benefit-icon">
                                <i class="fa-solid fa-box-open"></i>
                            </span>
                            <div>
                                <h3 class="home-benefit-title">Live availability</h3>
                                <p class="home-benefit-text">
                                    Available Variants and stock are loaded from current inventory.
                                </p>
                            </div>
                        </article>

                        <article class="home-benefit-card">
                            <span class="home-benefit-icon">
                                <i class="fa-solid fa-tags"></i>
                            </span>
                            <div>
                                <h3 class="home-benefit-title">Current pricing</h3>
                                <p class="home-benefit-text">
                                    List Price and Sale Price reflect Admin Price Management.
                                </p>
                            </div>
                        </article>

                        <article class="home-benefit-card">
                            <span class="home-benefit-icon">
                                <i class="fa-solid fa-heart"></i>
                            </span>
                            <div>
                                <h3 class="home-benefit-title">Save favourites</h3>
                                <p class="home-benefit-text">
                                    Keep products in your Wishlist and return to them later.
                                </p>
                            </div>
                        </article>

                        <article class="home-benefit-card">
                            <span class="home-benefit-icon">
                                <i class="fa-solid fa-truck-fast"></i>
                            </span>
                            <div>
                                <h3 class="home-benefit-title">Clear order flow</h3>
                                <p class="home-benefit-text">
                                    Review Cart, Checkout and Order History in one consistent flow.
                                </p>
                            </div>
                        </article>
                    </div>
                </div>
            </section>
        </main>

        <div class="home-toast" id="homeWishlistToast" role="status" aria-live="polite">
            <i class="fa-solid fa-heart"></i>
            <span id="homeWishlistToastText"></span>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                "use strict";

                function formatCurrency(value) {
                    var numericValue = Number(value || 0);
                    return new Intl.NumberFormat("vi-VN", {
                        maximumFractionDigits: 0
                    }).format(numericValue) + " ₫";
                }

                document.querySelectorAll(".home-add-cart-form").forEach(function (form) {
                    var select = form.querySelector(".home-variant-select");
                    var card = form.closest(".home-product-card");
                    var button = form.querySelector(".home-add-cart-button");

                    if (!select || !card || !button) {
                        return;
                    }

                    var currentPrice = card.querySelector(".home-current-price");
                    var listPrice = card.querySelector(".home-list-price");
                    var discount = card.querySelector(".home-discount");
                    var variantLabel = card.querySelector(".home-variant-label");
                    var stockLabel = card.querySelector(".home-stock");

                    function syncVariant() {
                        var option = select.options[select.selectedIndex];

                        if (!option) {
                            button.disabled = true;
                            return;
                        }

                        var salePrice = Number(option.dataset.price || 0);
                        var originalPrice = Number(option.dataset.listPrice || salePrice);
                        var stock = Number(option.dataset.stock || 0);
                        var cartQuantity = Number(option.dataset.cartQuantity || 0);
                        var remaining = Math.max(0, stock - cartQuantity);
                        var attributes = option.dataset.attributes || "Standard";

                        if (currentPrice) {
                            currentPrice.textContent = formatCurrency(salePrice);
                        }

                        if (listPrice) {
                            listPrice.textContent = formatCurrency(originalPrice);
                            listPrice.style.display = originalPrice > salePrice ? "" : "none";
                        }

                        if (discount) {
                            if (originalPrice > salePrice && originalPrice > 0) {
                                discount.textContent = "-"
                                        + Math.round((originalPrice - salePrice) * 100 / originalPrice)
                                        + "%";
                                discount.style.display = "";
                            } else {
                                discount.style.display = "none";
                            }
                        }

                        if (variantLabel) {
                            variantLabel.innerHTML = '<i class="fa-solid fa-layer-group me-1"></i>'
                                    + attributes;
                        }

                        if (stockLabel) {
                            stockLabel.innerHTML = '<i class="fa-solid fa-box me-1"></i>'
                                    + stock + " in stock";
                        }

                        button.disabled = remaining <= 0;
                        button.title = remaining > 0
                                ? "Add selected variant to cart"
                                : "Maximum available quantity is already in your cart";
                    }

                    select.addEventListener("change", syncVariant);

                    form.addEventListener("submit", function (event) {
                        if (button.disabled) {
                            event.preventDefault();
                            return;
                        }

                        sessionStorage.setItem(
                                "homeScrollY",
                                String(window.scrollY || 0)
                        );
                    });

                    syncVariant();
                });

                var toast = document.getElementById("homeWishlistToast");
                var toastText = document.getElementById("homeWishlistToastText");
                var params = new URLSearchParams(window.location.search);

                function showToast(message, isError) {
                    if (!toast || !toastText) {
                        return;
                    }

                    toast.classList.toggle("is-error", Boolean(isError));
                    toastText.textContent = message;
                    toast.classList.add("show");

                    clearTimeout(toast.hideTimer);
                    toast.hideTimer = setTimeout(function () {
                        toast.classList.remove("show");
                    }, 2600);
                }

                if (params.has("wishlistAdded")
                        || params.has("wishlistRemoved")
                        || params.has("wishlistError")) {

                    var message = "Added to your Wishlist.";
                    var isError = false;

                    if (params.has("wishlistRemoved")) {
                        message = "Removed from your Wishlist.";
                    }

                    if (params.has("wishlistError")) {
                        message = "Unable to update your Wishlist.";
                        isError = true;
                    }

                    showToast(message, isError);
                }

                document.querySelectorAll(".home-wishlist-form").forEach(function (form) {
                    form.addEventListener("submit", function () {
                        sessionStorage.setItem(
                                "homeScrollY",
                                String(window.scrollY || 0)
                        );
                    });
                });

                var savedScrollY = sessionStorage.getItem("homeScrollY");

                if (savedScrollY !== null) {
                    sessionStorage.removeItem("homeScrollY");
                    requestAnimationFrame(function () {
                        window.scrollTo(0, Number(savedScrollY) || 0);
                    });
                }
            })();
        </script>

         <jsp:include page="/view/customer/common/footer.jsp"/>
    </body>
</html>