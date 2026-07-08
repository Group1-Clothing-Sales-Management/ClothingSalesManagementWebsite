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
    <title>Customer Login | Clothing Sale</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --ink:#172033;
            --muted:#667085;
            --line:#e4e7ec;
            --paper:#ffffff;
            --soft:#f5f7fb;
            --brand:#2563eb;
            --teal:#0f9b8e;
            --coral:#e8795b;
        }

        * { box-sizing:border-box; }

        body {
            min-height:100vh;
            min-height:100svh;
            margin:0;
            color:var(--ink);
            background:
                radial-gradient(circle at 10% 12%, rgba(232, 121, 91, .16), transparent 28%),
                radial-gradient(circle at 88% 18%, rgba(15, 155, 142, .16), transparent 30%),
                linear-gradient(135deg, #f7f9fc 0%, #edf6f3 48%, #fff6f1 100%);
            font-family:"Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .auth-shell {
            min-height:100vh;
            min-height:100svh;
            padding:28px clamp(16px, 4vw, 48px);
            display:flex;
            flex-direction:column;
        }

        .auth-topbar {
            width:100%;
            max-width:1160px;
            margin:0 auto 24px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:16px;
        }

        .brand-link {
            min-height:42px;
            display:inline-flex;
            align-items:center;
            gap:10px;
            text-decoration:none;
            font-weight:800;
            color:var(--ink);
        }

        .brand-logo {
            width:42px;
            height:42px;
            border-radius:8px;
            display:grid;
            place-items:center;
            color:#fff;
            background:linear-gradient(135deg, var(--brand), var(--teal));
            box-shadow:0 12px 24px rgba(37, 99, 235, .2);
        }

        .auth-layout {
            width:100%;
            max-width:1160px;
            margin:auto;
            display:grid;
            grid-template-columns:repeat(2, minmax(0, 1fr));
            gap:24px;
            align-items:stretch;
        }

        .visual-panel,
        .auth-card {
            border:1px solid rgba(23, 32, 51, .09);
            border-radius:8px;
            box-shadow:0 24px 70px rgba(23, 32, 51, .12);
        }

        .visual-panel {
            min-height:620px;
            position:relative;
            overflow:hidden;
            padding:36px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            color:#fff;
            background:
                linear-gradient(160deg, rgba(23, 32, 51, .96) 0%, rgba(18, 57, 65, .94) 100%);
        }

        .visual-panel::after {
            content:"";
            position:absolute;
            inset:auto -12% -20% 34%;
            height:260px;
            background:radial-gradient(circle, rgba(232, 121, 91, .36), transparent 66%);
            pointer-events:none;
        }

        .visual-copy,
        .lookbook,
        .benefit-row {
            position:relative;
            z-index:1;
        }

        .eyebrow {
            margin-bottom:12px;
            color:#a7f3d0;
            font-size:.8rem;
            font-weight:800;
            letter-spacing:.08em;
            text-transform:uppercase;
        }

        .visual-title {
            max-width:430px;
            margin:0;
            font-size:clamp(2rem, 4vw, 3.6rem);
            line-height:1.02;
            font-weight:900;
        }

        .visual-text {
            max-width:450px;
            margin:18px 0 0;
            color:rgba(255, 255, 255, .72);
            font-size:1.02rem;
        }

        .lookbook {
            display:grid;
            grid-template-columns:1.25fr .8fr;
            gap:14px;
            margin:34px 0;
        }

        .lookbook img {
            width:100%;
            height:100%;
            display:block;
            object-fit:cover;
            border-radius:8px;
            border:1px solid rgba(255, 255, 255, .16);
        }

        .lookbook-main {
            min-height:300px;
        }

        .lookbook-stack {
            display:grid;
            grid-template-rows:1fr 1fr;
            gap:14px;
        }

        .benefit-row {
            display:grid;
            grid-template-columns:repeat(3, minmax(0, 1fr));
            gap:12px;
            color:rgba(255, 255, 255, .82);
            font-size:.9rem;
        }

        .benefit-row span {
            display:flex;
            align-items:center;
            gap:8px;
        }

        .auth-card {
            padding:42px;
            min-height:620px;
            display:flex;
            flex-direction:column;
            justify-content:center;
            background:rgba(255, 255, 255, .9);
            backdrop-filter:blur(16px);
        }

        .card-kicker {
            width:max-content;
            margin-bottom:16px;
            padding:8px 12px;
            border-radius:999px;
            color:#0f766e;
            background:#dff7f1;
            font-size:.82rem;
            font-weight:800;
        }

        .auth-title {
            margin:0;
            font-size:clamp(2rem, 3vw, 2.6rem);
            line-height:1.1;
            font-weight:900;
        }

        .auth-subtitle {
            margin:12px 0 28px;
            color:var(--muted);
            font-size:1rem;
        }

        .alert {
            border:0;
            border-radius:8px;
            font-weight:600;
        }

        .form-label {
            color:#344054;
            font-size:.92rem;
            font-weight:800;
        }

        .field-control {
            position:relative;
        }

        .field-control .field-icon {
            position:absolute;
            left:16px;
            top:50%;
            transform:translateY(-50%);
            color:#98a2b3;
            pointer-events:none;
        }

        .form-control {
            height:52px;
            padding-left:46px;
            border:1px solid #d0d5dd;
            border-radius:8px;
            background:#fff;
            color:var(--ink);
            box-shadow:0 1px 2px rgba(16, 24, 40, .04);
        }

        .form-control::placeholder {
            color:#98a2b3;
        }

        .form-control:focus {
            border-color:var(--teal);
            box-shadow:0 0 0 .22rem rgba(15, 155, 142, .14);
        }

        .password-control .form-control {
            padding-right:54px;
        }

        .password-toggle {
            position:absolute;
            right:6px;
            top:6px;
            width:40px;
            height:40px;
            border:0;
            border-radius:8px;
            color:#475467;
            background:transparent;
        }

        .password-toggle:hover,
        .password-toggle:focus {
            color:var(--teal);
            background:#edf7f5;
        }

        .link-accent {
            color:#0f766e;
            font-weight:800;
            text-decoration:none;
        }

        .link-accent:hover {
            color:var(--brand);
        }

        .btn-auth {
            min-height:52px;
            border:0;
            border-radius:8px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            background:linear-gradient(135deg, var(--brand), var(--teal));
            color:#fff;
            font-weight:800;
            box-shadow:0 16px 26px rgba(37, 99, 235, .22);
        }

        .btn-auth:hover,
        .btn-auth:focus {
            color:#fff;
            filter:brightness(.98);
            box-shadow:0 18px 30px rgba(15, 155, 142, .26);
        }

        .switch-panel {
            margin-top:24px;
            padding-top:22px;
            border-top:1px solid var(--line);
            color:var(--muted);
            text-align:center;
        }

        @media (max-width: 991.98px) {
            .auth-layout {
                grid-template-columns:1fr;
            }

            .visual-panel {
                min-height:auto;
            }

            .auth-card {
                min-height:auto;
            }
        }

        @media (max-width: 575.98px) {
            .auth-shell {
                padding:18px 12px;
            }

            .auth-topbar {
                align-items:flex-start;
                flex-direction:column;
            }

            .visual-panel,
            .auth-card {
                padding:24px;
            }

            .lookbook,
            .benefit-row {
                grid-template-columns:1fr;
            }

            .lookbook-main {
                min-height:220px;
            }
        }
    </style>
</head>
<body>
    <main class="auth-shell">
        <div class="auth-topbar">
            <a class="brand-link" href="<%= ctx %>/home">
                <span class="brand-logo"><i class="fa-solid fa-shirt"></i></span>
                <span>Clothing Sale</span>
            </a>
        </div>

        <div class="auth-layout">
            <section class="visual-panel" aria-label="Clothing Sale">
                <div class="visual-copy">
                    <div class="eyebrow">Customer access</div>
                    <h1 class="visual-title">Shop faster. Track every order with ease.</h1>
                    <p class="visual-text">Sign in to return to your cart, review order status, and keep shopping your favorite styles.</p>
                </div>

                <div class="lookbook">
                    <img class="lookbook-main" src="<%= ctx %>/uploads/product/prod15-main.jpg" alt="Clothing Sale product">
                    <div class="lookbook-stack">
                        <img src="<%= ctx %>/uploads/product/prod16-main.jpg" alt="Clothing Sale product">
                        <img src="<%= ctx %>/uploads/product/prod17-main.jpg" alt="Clothing Sale product">
                    </div>
                </div>

                <div class="benefit-row">
                    <span><i class="fa-solid fa-lock"></i> Secure</span>
                    <span><i class="fa-solid fa-bag-shopping"></i> Cart</span>
                    <span><i class="fa-solid fa-truck-fast"></i> Orders</span>
                </div>
            </section>

            <section class="auth-card">
                <div class="card-kicker">Customer</div>
                <h2 class="auth-title">Welcome back</h2>
                <p class="auth-subtitle">Enter your account details to continue shopping.</p>

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

                <form action="<%= ctx %>/customer/login" method="post" autocomplete="off">
                    <div class="mb-3">
                        <label class="form-label" for="usernameField">Username or email</label>
                        <div class="field-control">
                            <i class="fa-regular fa-user field-icon"></i>
                            <input type="text"
                                   name="username"
                                   id="usernameField"
                                   class="form-control"
                                   placeholder="Enter username or email"
                                   value="<%= usernameValue != null ? usernameValue : "" %>"
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
                                   placeholder="Enter password"
                                   required>
                            <button class="password-toggle" type="button" data-toggle-password="passwordField" aria-label="Show password">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mb-4">
                        <a href="<%= ctx %>/customer/register" class="link-accent">Create account</a>
                    </div>

                    <button type="submit" class="btn btn-auth w-100">
                        <i class="fa-solid fa-right-to-bracket me-2"></i>
                        Sign in
                    </button>
                </form>

                <div class="switch-panel">
                    Do not have an account?
                    <a href="<%= ctx %>/customer/register" class="link-accent">Sign up now</a>
                </div>
            </section>
        </div>
    </main>

    <script>
        document.querySelectorAll('[data-toggle-password]').forEach(function(button) {
            button.addEventListener('click', function() {
                var input = document.getElementById(button.dataset.togglePassword);
                var icon = button.querySelector('i');
                var showing = input.type === 'text';
                input.type = showing ? 'password' : 'text';
                button.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
                icon.className = showing ? 'fa-regular fa-eye' : 'fa-regular fa-eye-slash';
            });
        });
    </script>
</body>
</html>
