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
            <h1 class="hero-wordmark">Clothing Sale</h1>
            <p class="hero-copy">Your favorite clothing store<br>for styles you’ll love every day</p>
        </section>

        <section class="register-card" aria-label="Create a customer account">
            <div class="card-heading">
                <h1>Create account</h1>
            </div>

            <% if (errorMessage != null) { %>
                <div class="message message-error" role="alert"><%= errorMessage %></div>
            <% } %>

            <form action="<%= ctx %>/customer/register" method="post" autocomplete="off">
                <div class="field">
                    <input type="text"
                           name="username"
                           id="usernameField"
                           placeholder="Username"
                           value="<c:out value='${requestScope.username}' default='' />"
                           autocomplete="username"
                           required>
                </div>

                <div class="field password-field">
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
                    <input type="text"
                           name="fullName"
                           id="fullNameField"
                           placeholder="Full name"
                           value="<c:out value='${requestScope.fullName}' default='' />"
                           autocomplete="name"
                           required>
                </div>

                <div class="field">
                    <input type="email"
                           name="email"
                           id="emailField"
                           placeholder="Email"
                           value="<c:out value='${requestScope.email}' default='' />"
                           autocomplete="email"
                           required>
                </div>

                <div class="field">
                    <input type="tel"
                           name="phone"
                           id="phoneField"
                           placeholder="Phone number (optional)"
                           value="<c:out value='${requestScope.phone}' default='' />"
                           autocomplete="tel">
                </div>

                <button class="form-submit" type="submit">SIGN UP</button>
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
