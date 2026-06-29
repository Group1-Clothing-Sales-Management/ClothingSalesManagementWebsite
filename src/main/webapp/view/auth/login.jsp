<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String usernameValue = (String) request.getAttribute("username");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff / Admin Sign In | Clothing Sale</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --bg: #f4f7fb;
            --surface: rgba(255, 255, 255, 0.92);
            --surface-strong: #ffffff;
            --text: #102033;
            --muted: #667085;
            --line: #dbe3ee;
            --brand: #1d4ed8;
            --brand-2: #0f766e;
            --soft: #eef4ff;
            --shadow: 0 24px 80px rgba(16, 32, 51, 0.12);
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            min-height: 100svh;
            margin: 0;
            color: var(--text);
            background:
                radial-gradient(circle at 14% 12%, rgba(29, 78, 216, 0.14), transparent 28%),
                radial-gradient(circle at 88% 18%, rgba(15, 118, 110, 0.12), transparent 26%),
                linear-gradient(180deg, #f9fbfe 0%, var(--bg) 100%);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .auth-shell {
            min-height: 100vh;
            min-height: 100svh;
            padding: 24px clamp(16px, 4vw, 48px);
            display: flex;
            flex-direction: column;
        }

        .auth-topbar {
            width: 100%;
            max-width: 1120px;
            margin: 0 auto 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
        }

        .brand-link {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            color: var(--text);
            font-weight: 800;
            text-decoration: none;
        }

        .brand-mark {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            display: grid;
            place-items: center;
            color: #fff;
            background: linear-gradient(135deg, var(--brand), var(--brand-2));
            box-shadow: 0 14px 24px rgba(29, 78, 216, 0.18);
        }

        .top-note {
            color: var(--muted);
            font-size: 0.92rem;
        }

        .auth-layout {
            width: 100%;
            max-width: 1160px;
            margin: auto;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 24px;
            align-items: stretch;
        }

        .info-card,
        .login-card {
            position: relative;
            border: 1px solid rgba(16, 32, 51, 0.08);
            border-radius: 24px;
            box-shadow: var(--shadow);
        }

        .info-card {
            min-height: 620px;
            padding: 32px;
            overflow: hidden;
            color: #fff;
            background:
                linear-gradient(160deg, rgba(16, 32, 51, 0.98) 0%, rgba(27, 58, 102, 0.96) 100%);
        }

        .info-card::after {
            content: "";
            position: absolute;
            inset: auto -12% -18% 42%;
            height: 260px;
            border-radius: 999px;
            background: radial-gradient(circle, rgba(29, 78, 216, 0.45), transparent 68%);
            pointer-events: none;
        }

        .panel-label {
            position: relative;
            z-index: 1;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 18px;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.12);
            color: #dbeafe;
            font-size: 0.82rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }

        .panel-title {
            position: relative;
            z-index: 1;
            margin: 0;
            max-width: 12ch;
            font-size: clamp(1.8rem, 2.8vw, 2.7rem);
            line-height: 1.02;
            font-weight: 900;
        }

        .panel-text {
            position: relative;
            z-index: 1;
            max-width: 32rem;
            margin: 16px 0 0;
            color: rgba(255, 255, 255, 0.76);
            font-size: 0.98rem;
        }

        .benefits {
            position: relative;
            z-index: 1;
            display: grid;
            gap: 14px;
            margin-top: 30px;
        }

        .benefit-item {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            padding: 14px 16px;
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.05);
        }

        .benefit-item i {
            margin-top: 2px;
            color: #93c5fd;
        }

        .benefit-title {
            font-weight: 700;
            line-height: 1.2;
        }

        .benefit-copy {
            color: rgba(255, 255, 255, 0.72);
            font-size: 0.92rem;
            margin-top: 3px;
        }

        .login-card {
            min-height: 620px;
            padding: 32px;
            align-self: stretch;
            background: var(--surface);
            backdrop-filter: blur(16px);
        }

        .card-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 14px;
            padding: 8px 12px;
            border-radius: 999px;
            background: var(--soft);
            color: var(--brand);
            font-size: 0.82rem;
            font-weight: 800;
        }

        .auth-title {
            margin: 0;
            font-size: clamp(1.8rem, 2.4vw, 2.2rem);
            line-height: 1.08;
            font-weight: 900;
        }

        .auth-subtitle {
            margin: 10px 0 24px;
            color: var(--muted);
        }

        .alert {
            border: 0;
            border-radius: 14px;
            font-weight: 600;
        }

        .form-label {
            color: #344054;
            font-size: 0.92rem;
            font-weight: 800;
        }

        .field-control {
            position: relative;
        }

        .field-control .field-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #98a2b3;
            pointer-events: none;
        }

        .form-control {
            height: 52px;
            padding-left: 46px;
            border: 1px solid #d0d5dd;
            border-radius: 14px;
            background: #fff;
            color: var(--text);
            box-shadow: 0 1px 2px rgba(16, 24, 40, 0.04);
        }

        .form-control::placeholder {
            color: #98a2b3;
        }

        .form-control:focus {
            border-color: rgba(29, 78, 216, 0.55);
            box-shadow: 0 0 0 0.22rem rgba(29, 78, 216, 0.12);
        }

        .password-control .form-control {
            padding-right: 56px;
        }

        .password-toggle {
            position: absolute;
            right: 6px;
            top: 6px;
            width: 40px;
            height: 40px;
            border: 0;
            border-radius: 10px;
            color: #475467;
            background: transparent;
        }

        .password-toggle:hover,
        .password-toggle:focus {
            color: var(--brand);
            background: #edf4ff;
        }

        .helper-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-top: 16px;
            color: var(--muted);
            font-size: 0.92rem;
        }

        .login-hint {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-auth {
            min-height: 52px;
            border: 0;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--brand), #2563eb 55%, var(--brand-2));
            color: #fff;
            font-weight: 800;
            box-shadow: 0 16px 28px rgba(29, 78, 216, 0.2);
        }

        .btn-auth:hover,
        .btn-auth:focus {
            color: #fff;
            filter: brightness(0.98);
            box-shadow: 0 18px 30px rgba(15, 118, 110, 0.22);
        }

        .session-note {
            margin-top: 18px;
            padding: 14px 16px;
            border: 1px solid var(--line);
            border-radius: 14px;
            background: #f8fbff;
            color: var(--muted);
            font-size: 0.92rem;
        }

        @media (max-width: 991.98px) {
            .auth-layout {
                grid-template-columns: 1fr;
            }

            .info-card {
                min-height: auto;
            }
        }

        @media (max-width: 575.98px) {
            .auth-shell {
                padding: 16px 12px;
            }

            .auth-topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .info-card,
            .login-card {
                padding: 24px;
                border-radius: 20px;
                min-height: auto;
            }

            .helper-row {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <main class="auth-shell">
        <div class="auth-topbar">
            <a class="brand-link" href="<%= ctx %>/home">
                <span class="brand-mark"><i class="fa-solid fa-shirt"></i></span>
                <span>Clothing Sale</span>
            </a>
        </div>

        <div class="auth-layout">
            <section class="info-card" aria-label="Admin access overview">
                <div class="panel-label">
                    <i class="fa-solid fa-user-shield"></i>
                    Staff / Admin Portal
                </div>
                <h1 class="panel-title">Sign in to manage the store.</h1>
                <p class="panel-text">
                    This page is reserved for active admin and staff accounts to manage orders, products, shipments, and feedback.
                </p>

                <div class="benefits">
                    <div class="benefit-item">
                        <i class="fa-solid fa-gauge-high"></i>
                        <div>
                            <div class="benefit-title">Fast access</div>
                            <div class="benefit-copy">One login, then straight to the dashboard.</div>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <i class="fa-solid fa-boxes-stacked"></i>
                        <div>
                            <div class="benefit-title">Operational tools</div>
                            <div class="benefit-copy">Manage products, orders, shipments, and feedback in one place.</div>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <i class="fa-solid fa-shield-halved"></i>
                        <div>
                            <div class="benefit-title">Controlled access</div>
                            <div class="benefit-copy">Only active admin or staff accounts can continue.</div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="login-card">
                <div class="card-kicker">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    Sign in
                </div>
                <h2 class="auth-title">Welcome back</h2>
                <p class="auth-subtitle">Use your admin or staff account to continue.</p>

                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4" role="alert">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= errorMessage %></span>
                    </div>
                <% } %>
                <% if (successMessage != null) { %>
                    <div class="alert alert-success d-flex align-items-center gap-2 mb-4" role="alert">
                        <i class="fa-solid fa-circle-check"></i>
                        <span><%= successMessage %></span>
                    </div>
                <% } %>

                <form action="<%= ctx %>/admin/login" method="post" autocomplete="off">
                    <div class="mb-3">
                        <label class="form-label" for="usernameField">Username or email</label>
                        <div class="field-control">
                            <i class="fa-regular fa-user field-icon"></i>
                            <input type="text"
                                   name="username"
                                   id="usernameField"
                                   class="form-control"
                                   placeholder="admin01 or email@company.com"
                                   value="<%= usernameValue != null ? usernameValue : "" %>"
                                   autocomplete="username"
                                   required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="passwordField">Password</label>
                        <div class="field-control password-control">
                            <i class="fa-solid fa-lock field-icon"></i>
                            <input type="password"
                                   name="password"
                                   id="passwordField"
                                   class="form-control"
                                   placeholder="Enter your password"
                                   autocomplete="current-password"
                                   required>
                            <button class="password-toggle" type="button" id="togglePassword" aria-label="Show password">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="helper-row">
                        <span>Use only an active staff/admin account</span>
                    </div>

                    <button type="submit" class="btn btn-auth w-100 mt-3">
                        <i class="fa-solid fa-lock-open me-2"></i>
                        Sign in
                    </button>
                </form>

                <div class="session-note">
                    If you see an access error, confirm that the account role is <strong>ADMIN</strong> or <strong>STAFF</strong>.
                </div>
            </section>
        </div>
    </main>

    <script>
        const passwordField = document.getElementById('passwordField');
        const togglePassword = document.getElementById('togglePassword');

        togglePassword.addEventListener('click', function () {
            const showing = passwordField.type === 'text';
            passwordField.type = showing ? 'password' : 'text';
            this.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
            this.innerHTML = showing
                ? '<i class="fa-regular fa-eye"></i>'
                : '<i class="fa-regular fa-eye-slash"></i>';
        });
    </script>
</body>
</html>
