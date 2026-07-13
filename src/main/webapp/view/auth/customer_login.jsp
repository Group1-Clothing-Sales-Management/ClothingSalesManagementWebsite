<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In | Clothing Sale</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #c65b3d;
            --button-coral: #c65b3d;
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

        .page-title {
            font-size: 22px;
            color: #222;
        }

        .help-link {
            margin-left: auto;
            color: var(--brand-orange);
            font-size: 13px;
            text-decoration: none;
        }

        .help-link:hover,
        .text-link:hover { text-decoration: underline; }

        .login-stage {
            min-height: calc(100vh - 74px);
            min-height: calc(100svh - 74px);
            width: min(1160px, calc(100% - 48px));
            margin: 0 auto;
            display: grid;
            grid-template-columns: minmax(0, 620px) 400px;
            align-items: center;
            gap: 70px;
            padding: 32px 0;
        }

        .brand-panel {
            min-width: 0;
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
            font-size: clamp(54px, 6vw, 68px);
            font-weight: 400;
            letter-spacing: -2px;
        }

        .hero-copy {
            max-width: 520px;
            margin: 48px auto 0;
            font-size: clamp(22px, 2.1vw, 28px);
            line-height: 1.5;
        }

        .login-card {
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
            justify-content: space-between;
            gap: 12px;
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
        .message-success { color: #087443; background: #ecfdf3; }

        .field {
            position: relative;
            display: flex;
            height: 40px;
            margin-top: 14px;
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

        .password-row {
            height: 40px;
            display: flex;
            align-items: center;
            margin-top: 14px;
            border: 1px solid var(--line);
        }

        .password-row .field { flex: 1; height: 38px; margin: 0; border: 0; }

        .forgot-link {
            flex: 0 0 auto;
            padding: 0 13px;
            border-left: 1px solid var(--line);
            color: #0055aa;
            font-size: 12px;
            text-decoration: none;
        }

        .forgot-link:hover { text-decoration: underline; }

        .login-button {
            width: 100%;
            height: 40px;
            margin-top: 34px;
            border: 0;
            border-radius: 2px;
            color: #fff;
            background: var(--button-coral);
            font-size: 14px;
            cursor: pointer;
        }

        .login-button:hover { background: #a9462d; }

        .stay-signed {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 11px;
            color: #555;
            font-size: 12px;
        }

        .stay-signed input {
            width: 18px;
            height: 18px;
            margin: 0;
            accent-color: var(--brand-orange);
        }

        .help-dot {
            width: 16px;
            height: 16px;
            display: inline-grid;
            place-items: center;
            margin-left: 3px;
            border: 1px solid #999;
            border-radius: 50%;
            color: #777;
            font-size: 11px;
        }

        .terms {
            max-width: 255px;
            margin: 34px auto 0;
            color: #333;
            text-align: center;
            font-size: 12px;
            line-height: 1.25;
        }

        .terms a { color: var(--brand-orange); text-decoration: none; }
        .terms a:hover { text-decoration: underline; }

        .signup-prompt {
            margin: 29px 0 0;
            color: #b5b5b5;
            text-align: center;
            font-size: 14px;
        }

        .signup-prompt a {
            margin-left: 3px;
            color: var(--brand-orange);
            text-decoration: none;
        }

        .signup-prompt a:hover { text-decoration: underline; }

        @media (max-width: 1100px) {
            .login-stage {
                grid-template-columns: 1fr;
                gap: 42px;
                padding: 64px 0;
            }

            .brand-panel { order: 2; }
            .login-card { max-width: 400px; margin: 0 auto; }
            .hero-copy { margin-top: 34px; }
        }

        @media (max-width: 520px) {
            .site-header { height: 64px; }
            .header-inner,
            .login-stage { width: calc(100% - 28px); }
            .page-title { font-size: 18px; }
            .brand-name { font-size: 21px; }
            .header-divider { margin-left: 14px; margin-right: 10px; }
            .help-link { font-size: 12px; }
            .login-stage {
                min-height: calc(100vh - 64px);
                min-height: calc(100svh - 64px);
                gap: 48px;
                padding: 48px 0;
            }
            .login-card { padding: 18px 20px 24px; }
            .hero-logo { transform: scale(.82); margin-bottom: -12px; }
            .hero-wordmark { font-size: 54px; }
            .hero-copy { margin-top: 30px; font-size: 21px; }
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
            <span class="page-title">Log In</span>
            <a class="help-link" href="<%= ctx %>/home">Need help?</a>
        </div>
    </header>

    <main class="login-stage">
        <section class="brand-panel" aria-label="Clothing Sale introduction">
            <div class="hero-logo" aria-hidden="true"></div>
            <h1 class="hero-wordmark">Clothing Sale</h1>
            <p class="hero-copy">Your favorite clothing store<br>for styles you’ll love every day</p>
        </section>

        <section class="login-card" aria-label="Customer login form">
            <div class="card-heading">
                <h2>Log In</h2>
            </div>

            <% if (errorMessage != null) { %>
                <div class="message message-error" role="alert"><%= errorMessage %></div>
            <% } %>
            <% if (successMessage != null) { %>
                <div class="message message-success" role="status"><%= successMessage %></div>
            <% } %>

            <form action="<%= ctx %>/customer/login" method="post" autocomplete="off">
                <div class="field">
                    <input type="text"
                           name="username"
                           id="usernameField"
                           placeholder="Phone number / Username / Email"
                           value="<c:out value='${requestScope.username}' default='' />"
                           autocomplete="username"
                           required>
                </div>

                <div class="password-row">
                    <div class="field password-field">
                        <input type="password"
                               name="password"
                               id="passwordField"
                               placeholder="Password"
                               autocomplete="current-password"
                               required>
                        <button class="password-toggle" type="button" aria-label="Show password">
                            <i class="fa-regular fa-eye-slash" aria-hidden="true"></i>
                        </button>
                    </div>
                    <a class="forgot-link" href="<%= ctx %>/customer/register">Forgot?</a>
                </div>

                <button class="login-button" type="submit">LOG IN</button>
            </form>

            <label class="stay-signed">
                <input type="checkbox" checked>
                <span>Stay Signed In</span>
                <span class="help-dot" title="Keep this device signed in">?</span>
            </label>

            <p class="terms">By logging in, you agree to Clothing Sale's <a href="<%= ctx %>/home">Terms of Service</a> &amp; <a href="<%= ctx %>/home">Privacy Policy</a></p>
            <p class="signup-prompt">New to Clothing Sale?<a href="<%= ctx %>/customer/register">Sign Up</a></p>
        </section>
    </main>

    <script>
        (function () {
            var toggle = document.querySelector('.password-toggle');
            var password = document.getElementById('passwordField');
            if (!toggle || !password) return;

            toggle.addEventListener('click', function () {
                var isVisible = password.type === 'text';
                password.type = isVisible ? 'password' : 'text';
                toggle.setAttribute('aria-label', isVisible ? 'Show password' : 'Hide password');
                toggle.innerHTML = isVisible
                    ? '<i class="fa-regular fa-eye-slash" aria-hidden="true"></i>'
                    : '<i class="fa-regular fa-eye" aria-hidden="true"></i>';
            });
        }());
    </script>
</body>
</html>
