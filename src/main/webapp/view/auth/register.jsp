<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up | Clothing Sale</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #c65b3d;
            --brand-orange-dark: #a9462d;
            --ink: #222;
            --muted: #999;
            --line: #dbdbdb;
        }

        * { box-sizing: border-box; }
        html, body { min-height: 100%; }

        body {
            margin: 0;
            color: var(--ink);
            background: var(--brand-orange);
            font-family: Arial, Helvetica, sans-serif;
        }

        a { color: inherit; }

        .site-header {
            height: 74px;
            background: #fff;
        }

        .header-inner {
            width: min(1160px, calc(100% - 48px));
            height: 100%;
            margin: 0 auto;
            display: flex;
            align-items: center;
        }

        .brand-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--brand-orange);
            text-decoration: none;
            white-space: nowrap;
        }

        .brand-mark {
            position: relative;
            width: 32px;
            height: 34px;
            display: grid;
            place-items: center;
            border-radius: 3px;
            background: var(--brand-orange);
            color: #fff;
        }

        .brand-mark::before {
            content: "";
            position: absolute;
            top: -8px;
            left: 8px;
            width: 14px;
            height: 13px;
            border: 2px solid var(--brand-orange);
            border-bottom: 0;
            border-radius: 10px 10px 0 0;
        }

        .brand-mark span {
            position: relative;
            z-index: 1;
            font-size: 23px;
            line-height: 1;
        }

        .brand-name {
            font-size: 24px;
            letter-spacing: -.5px;
        }

        .header-divider {
            width: 1px;
            height: 27px;
            margin: 0 14px 0 22px;
            background: #d8d8d8;
        }

        .page-title { color: #222; font-size: 22px; }

        .help-link {
            margin-left: auto;
            color: var(--brand-orange);
            font-size: 13px;
            text-decoration: none;
        }

        .help-link:hover,
        .text-link:hover { text-decoration: underline; }

        .register-stage {
            min-height: calc(100vh - 74px);
            min-height: calc(100svh - 74px);
            width: min(1160px, calc(100% - 48px));
            margin: 0 auto;
            display: grid;
            grid-template-columns: minmax(0, 620px) 400px;
            align-items: start;
            gap: 70px;
            padding: 58px 0 70px;
        }

        .brand-panel {
            min-width: 0;
            padding-top: 72px;
            color: #fff;
            text-align: center;
        }

        .hero-logo {
            position: relative;
            width: 178px;
            height: 158px;
            margin: 0 auto 12px;
            border-radius: 0 0 18px 18px;
            background: #fff;
        }

        .hero-logo::before {
            content: "";
            position: absolute;
            top: -49px;
            left: 46px;
            width: 86px;
            height: 91px;
            border: 12px solid #fff;
            border-bottom: 0;
            border-radius: 50px 50px 0 0;
        }

        .hero-logo::after {
            content: "C";
            position: absolute;
            inset: 13px 0 0;
            color: var(--brand-orange);
            font-family: Georgia, "Times New Roman", serif;
            font-size: 126px;
            font-weight: 400;
            line-height: 1;
        }

        .hero-wordmark {
            margin: 0;
            font-size: clamp(48px, 5.5vw, 66px);
            font-weight: 400;
            letter-spacing: -2px;
            white-space: nowrap;
        }

        .hero-copy {
            max-width: 520px;
            margin: 48px auto 0;
            font-size: clamp(21px, 2vw, 28px);
            line-height: 1.5;
        }

        .register-card {
            width: 100%;
            padding: 22px 30px 28px;
            border-radius: 4px;
            background: #fff;
            box-shadow: 0 3px 12px rgba(0, 0, 0, .16);
        }

        .card-heading {
            min-height: 46px;
            display: flex;
            align-items: flex-start;
        }

        .card-heading h1 {
            margin: 16px 0 0;
            font-size: 20px;
            font-weight: 400;
        }

        .message {
            margin: 0 0 14px;
            padding: 9px 11px;
            border-radius: 2px;
            font-size: 12px;
            line-height: 1.35;
        }

        .message-error { color: #b42318; background: #fff1f0; }

        .field {
            position: relative;
            display: flex;
            height: 40px;
            margin-top: 12px;
            border: 1px solid var(--line);
            background: #fff;
        }

        .field:focus-within { border-color: #999; }

        .field input {
            width: 100%;
            min-width: 0;
            border: 0;
            outline: 0;
            padding: 0 12px;
            color: #333;
            font-size: 14px;
        }

        .field input::placeholder { color: #b8b8b8; }

        .password-field input { padding-right: 46px; }

        .password-toggle {
            position: absolute;
            top: 0;
            right: 0;
            width: 42px;
            height: 38px;
            border: 0;
            color: #777;
            background: transparent;
            cursor: pointer;
        }

        .password-toggle:hover { color: var(--brand-orange); }

        .form-submit {
            width: 100%;
            height: 40px;
            margin-top: 26px;
            border: 0;
            border-radius: 2px;
            color: #fff;
            background: var(--brand-orange);
            font-size: 14px;
            cursor: pointer;
        }

        .form-submit:hover { background: var(--brand-orange-dark); }

        .terms {
            max-width: 285px;
            margin: 28px auto 0;
            color: #333;
            text-align: center;
            font-size: 12px;
            line-height: 1.25;
        }

        .terms a,
        .switch-link {
            color: var(--brand-orange);
            text-decoration: none;
        }

        .terms a:hover,
        .switch-link:hover { text-decoration: underline; }

        .switch-prompt {
            margin: 28px 0 0;
            color: #b5b5b5;
            text-align: center;
            font-size: 14px;
        }

        .switch-link { margin-left: 3px; }

        @media (max-width: 1100px) {
            .register-stage {
                grid-template-columns: 1fr;
                gap: 42px;
                padding: 64px 0;
            }

            .brand-panel {
                order: 2;
                padding-top: 0;
            }

            .register-card {
                max-width: 400px;
                margin: 0 auto;
            }

            .hero-copy { margin-top: 34px; }
        }

        @media (max-width: 520px) {
            .site-header { height: 64px; }

            .header-inner,
            .register-stage { width: calc(100% - 28px); }

            .page-title { font-size: 18px; }
            .brand-name { font-size: 21px; }
            .header-divider { margin-left: 14px; margin-right: 10px; }
            .help-link { font-size: 12px; }

            .register-stage {
                min-height: calc(100vh - 64px);
                min-height: calc(100svh - 64px);
                gap: 48px;
                padding: 48px 0;
            }

            .register-card { padding: 18px 20px 24px; }
            .hero-logo { transform: scale(.82); margin-bottom: -12px; }
            .hero-wordmark { font-size: 48px; }
            .hero-copy { margin-top: 30px; font-size: 21px; }
        }
        /* Modern customer auth redesign */
        :root {
            --auth-ink: #1f2937;
            --auth-muted: #61708a;
            --auth-line: #d7e1f5;
            --auth-coral: #8AAAE5;
            --auth-coral-dark: #5f84d6;
            --auth-forest: #8AAAE5;
            --auth-charcoal: #5f84d6;
        }

        body {
            color: var(--auth-ink);
            background:
                linear-gradient(135deg, rgba(138, 170, 229, .18) 0 25%, transparent 25% 100%),
                linear-gradient(180deg, #ffffff 0%, #eef4ff 100%);
            font-family: "Inter", "Segoe UI", Arial, Helvetica, sans-serif;
        }

        .site-header {
            height: 86px;
            border-bottom: 1px solid rgba(45, 49, 55, .08);
            background: rgba(255, 255, 255, .94);
            backdrop-filter: blur(12px);
        }

        .header-inner {
            width: min(1200px, calc(100% - 40px));
        }

        .brand-link {
            gap: 10px;
            color: var(--auth-ink);
            font-weight: 800;
        }

        .brand-mark {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: var(--auth-charcoal);
            box-shadow: 0 10px 20px rgba(45, 49, 55, .14);
        }

        .brand-mark::before {
            top: -8px;
            left: 10px;
            width: 18px;
            height: 14px;
            border-color: var(--auth-charcoal);
        }

        .brand-mark span {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 25px;
        }

        .brand-name {
            font-size: 22px;
            letter-spacing: 0;
        }

        .header-divider {
            background: var(--auth-line);
        }

        .page-title {
            color: var(--auth-muted);
            font-size: 16px;
            font-weight: 700;
        }

        .help-link {
            padding: 10px 14px;
            border: 1px solid var(--auth-line);
            border-radius: 8px;
            color: var(--auth-coral-dark);
            background: #fff;
            font-weight: 700;
        }

        .help-link:hover {
            border-color: rgba(138, 170, 229, .65);
            text-decoration: none;
        }

        .register-stage {
            min-height: calc(100vh - 86px);
            min-height: calc(100svh - 86px);
            width: min(1200px, calc(100% - 40px));
            grid-template-columns: minmax(0, 1.05fr) minmax(390px, .95fr);
            align-items: stretch;
            gap: 44px;
            padding: 44px 0;
        }

        .brand-panel {
            display: grid;
            align-content: center;
            gap: 24px;
            min-height: 690px;
            padding: 38px;
            border: 1px solid rgba(255, 255, 255, .18);
            border-radius: 8px;
            text-align: left;
            color: #fff;
            background:
                linear-gradient(135deg, rgba(74, 104, 165, .92), rgba(138, 170, 229, .80)),
                #8AAAE5;
            box-shadow: 0 24px 60px rgba(95, 132, 214, .20);
        }

        .hero-logo {
            display: none;
        }

        .panel-eyebrow {
            width: max-content;
            padding: 7px 10px;
            border: 1px solid rgba(255, 255, 255, .22);
            color: #ffffff;
            background: rgba(255, 255, 255, .14);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .hero-wordmark {
            max-width: 560px;
            margin: 0;
            font-size: clamp(42px, 4.8vw, 68px);
            line-height: .98;
            font-weight: 800;
            letter-spacing: 0;
            white-space: normal;
        }

        .hero-copy {
            max-width: 520px;
            margin: 0;
            color: rgba(255, 255, 255, .78);
            font-size: clamp(18px, 1.8vw, 24px);
            line-height: 1.45;
        }

        .lookbook-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.2fr) minmax(120px, .8fr);
            gap: 14px;
            margin-top: 8px;
        }

        .lookbook-grid img {
            width: 100%;
            height: 100%;
            min-height: 0;
            display: block;
            border-radius: 8px;
            object-fit: cover;
            background: #eef4ff;
        }

        .lookbook-main {
            height: 320px;
        }

        .lookbook-stack {
            display: grid;
            gap: 14px;
        }

        .lookbook-stack img {
            height: 153px;
        }

        .brand-notes {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .brand-notes span {
            padding: 9px 12px;
            border: 1px solid rgba(255, 255, 255, .18);
            border-radius: 8px;
            background: rgba(255, 255, 255, .08);
            color: rgba(255, 255, 255, .86);
            font-size: 13px;
            font-weight: 700;
        }

        .brand-notes + .hero-copy {
            display: none;
        }

        .register-card {
            align-self: stretch;
            min-height: 690px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 34px;
            border: 1px solid rgba(45, 49, 55, .10);
            border-radius: 8px;
            background: rgba(255, 255, 255, .96);
            box-shadow: 0 24px 64px rgba(95, 132, 214, .16);
        }

        .card-heading {
            min-height: 0;
            margin-bottom: 20px;
        }

        .card-heading h1 {
            margin: 0;
            color: var(--auth-ink);
            font-size: 34px;
            line-height: 1.05;
            font-weight: 850;
        }

        .form-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            color: var(--auth-coral-dark);
            font-size: 12px;
            font-weight: 900;
            letter-spacing: .08em;
            text-transform: uppercase;
        }

        .form-subtitle {
            margin: 9px 0 0;
            color: var(--auth-muted);
            font-size: 15px;
            line-height: 1.45;
        }

        .message {
            border-radius: 8px;
            font-size: 13px;
        }

        .field {
            height: 48px;
            margin-top: 12px;
            border: 1px solid var(--auth-line);
            border-radius: 8px;
            background: #fff;
            overflow: hidden;
            transition: border-color .18s ease, box-shadow .18s ease;
        }

        .field:focus-within {
            border-color: rgba(138, 170, 229, .78);
            box-shadow: 0 0 0 4px rgba(138, 170, 229, .20);
        }

        .field-icon {
            width: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #7e95c3;
            flex: 0 0 44px;
        }

        .field input {
            height: 100%;
            padding: 0 14px 0 0;
            font-size: 15px;
        }

        .password-field input {
            padding-right: 48px;
        }

        .password-toggle {
            top: 5px;
            right: 5px;
            width: 38px;
            height: 38px;
            border-radius: 8px;
        }

        .password-toggle:hover {
            color: var(--auth-coral-dark);
            background: #eef4ff;
        }

        .form-submit {
            height: 50px;
            margin-top: 22px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            background: var(--auth-charcoal);
            font-weight: 900;
            letter-spacing: .03em;
            transition: transform .18s ease, background .18s ease, box-shadow .18s ease;
        }

        .form-submit:hover {
            transform: translateY(-1px);
            background: var(--auth-coral-dark);
            box-shadow: 0 16px 28px rgba(95, 132, 214, .26);
        }

        .switch-prompt {
            margin-top: 24px;
            color: var(--auth-muted);
            font-size: 15px;
        }

        .switch-link {
            color: var(--auth-coral-dark);
            font-weight: 800;
        }

        @media (max-width: 1100px) {
            .register-stage {
                grid-template-columns: 1fr;
            }

            .brand-panel {
                order: 1;
                min-height: auto;
            }

            .register-card {
                order: 2;
                max-width: 540px;
            }
        }

        @media (max-width: 640px) {
            .site-header {
                height: auto;
            }

            .header-inner {
                width: calc(100% - 28px);
                min-height: 74px;
                flex-wrap: wrap;
                gap: 8px;
                padding: 10px 0;
            }

            .help-link {
                margin-left: 0;
            }

            .register-stage {
                width: calc(100% - 28px);
                min-height: auto;
                padding: 24px 0 40px;
            }

            .brand-panel,
            .register-card {
                padding: 24px;
            }

            .lookbook-grid {
                grid-template-columns: 1fr;
            }

            .lookbook-main,
            .lookbook-stack img {
                height: 190px;
            }
        }
    </style>
</head>
<body>
    <header class="site-header">
        <div class="header-inner">
            <a class="brand-link" href="<%= ctx %>/home" aria-label="Clothing Sale home">
                <span class="brand-mark"><span>C</span></span>
                <span class="brand-name">Clothing Sale</span>
            </a>
            <span class="header-divider" aria-hidden="true"></span>
            <span class="page-title">Sign Up</span>
            <a class="help-link" href="<%= ctx %>/home">Need help?</a>
        </div>
    </header>

    <main class="register-stage">
        <section class="brand-panel" aria-label="Clothing Sale introduction">
            <div class="hero-logo" aria-hidden="true"></div>
            <div class="panel-eyebrow">Join the edit</div>
            <h1 class="hero-wordmark">Build your closet faster.</h1>
            <p class="hero-copy">Create an account to save favorites, unlock vouchers, and keep every order in one clean place.</p>
            <div class="lookbook-grid" aria-hidden="true">
                <img class="lookbook-main" src="<%= ctx %>/uploads/product/prod12-main.jpg" alt="">
                <div class="lookbook-stack">
                    <img src="<%= ctx %>/uploads/product/prod18-main.jpg" alt="">
                    <img src="<%= ctx %>/uploads/product/prod22-main.jpg" alt="">
                </div>
            </div>
            <div class="brand-notes" aria-label="Account benefits">
                <span>Save wishlists</span>
                <span>Track orders</span>
                <span>Collect vouchers</span>
            </div>
        </section>

        <section class="register-card" aria-label="Create a customer account">
            <div class="card-heading">
                <div>
                    <span class="form-kicker"><i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i> New customer</span>
                    <h1>Create account</h1>
                    <p class="form-subtitle">Sign up once, then shop with your profile ready.</p>
                </div>
            </div>

            <% if (errorMessage != null) { %>
                <div class="message message-error" role="alert"><%= errorMessage %></div>
            <% } %>

            <form action="<%= ctx %>/customer/register" method="post" autocomplete="off">
                <div class="field">
                    <span class="field-icon"><i class="fa-regular fa-user" aria-hidden="true"></i></span>
                    <input type="text"
                           name="username"
                           id="usernameField"
                           placeholder="Username"
                           value="<c:out value='${requestScope.username}' default='' />"
                           autocomplete="username"
                           required>
                </div>

                <div class="field password-field">
                    <span class="field-icon"><i class="fa-solid fa-lock" aria-hidden="true"></i></span>
                    <input type="password"
                           name="password"
                           id="passwordField"
                           placeholder="Password"
                           autocomplete="new-password"
                           required>
                    <button class="password-toggle" type="button" data-password-target="passwordField" aria-label="Show password">
                        <i class="fa-regular fa-eye-slash" aria-hidden="true"></i>
                    </button>
                </div>

                <div class="field password-field">
                    <span class="field-icon"><i class="fa-solid fa-shield-halved" aria-hidden="true"></i></span>
                    <input type="password"
                           name="confirmPassword"
                           id="confirmPasswordField"
                           placeholder="Confirm password"
                           autocomplete="new-password"
                           required>
                    <button class="password-toggle" type="button" data-password-target="confirmPasswordField" aria-label="Show confirm password">
                        <i class="fa-regular fa-eye-slash" aria-hidden="true"></i>
                    </button>
                </div>

                <div class="field">
                    <span class="field-icon"><i class="fa-regular fa-id-card" aria-hidden="true"></i></span>
                    <input type="text"
                           name="fullName"
                           id="fullNameField"
                           placeholder="Full name"
                           value="<c:out value='${requestScope.fullName}' default='' />"
                           autocomplete="name"
                           required>
                </div>

                <div class="field">
                    <span class="field-icon"><i class="fa-regular fa-envelope" aria-hidden="true"></i></span>
                    <input type="email"
                           name="email"
                           id="emailField"
                           placeholder="Email"
                           value="<c:out value='${requestScope.email}' default='' />"
                           autocomplete="email"
                           required>
                </div>

                <div class="field">
                    <span class="field-icon"><i class="fa-solid fa-phone" aria-hidden="true"></i></span>
                    <input type="tel"
                           name="phone"
                           id="phoneField"
                           placeholder="Phone number (optional)"
                           value="<c:out value='${requestScope.phone}' default='' />"
                           autocomplete="tel">
                </div>

                <button class="form-submit" type="submit">
                    <i class="fa-solid fa-user-plus" aria-hidden="true"></i>
                    SIGN UP
                </button>
            </form>

            <p class="switch-prompt">Already have an account?<a class="switch-link" href="<%= ctx %>/customer/login">Log In</a></p>
        </section>
    </main>

    <script>
        document.querySelectorAll('[data-password-target]').forEach(function (toggle) {
            toggle.addEventListener('click', function () {
                var password = document.getElementById(toggle.dataset.passwordTarget);
                var icon = toggle.querySelector('i');
                var isVisible = password.type === 'text';

                password.type = isVisible ? 'password' : 'text';
                toggle.setAttribute('aria-label', isVisible ? 'Show password' : 'Hide password');
                icon.className = isVisible
                    ? 'fa-regular fa-eye-slash'
                    : 'fa-regular fa-eye';
            });
        });
    </script>
</body>
</html>
