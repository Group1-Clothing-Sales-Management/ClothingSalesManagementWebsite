<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String usernameValue = (String) request.getAttribute("username");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Clothing Sale</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-1: #0f172a;
            --bg-2: #111827;
            --accent: #2563eb;
            --accent-2: #14b8a6;
            --surface: rgba(15, 23, 42, 0.72);
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            color: #e5eefc;
            background:
                radial-gradient(circle at top left, rgba(37, 99, 235, 0.35), transparent 30%),
                radial-gradient(circle at bottom right, rgba(20, 184, 166, 0.24), transparent 26%),
                linear-gradient(135deg, var(--bg-1), var(--bg-2));
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .shell {
            min-height: 100vh;
            position: relative;
            overflow: hidden;
        }

        .shell::before,
        .shell::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            filter: blur(12px);
            opacity: 0.8;
            pointer-events: none;
        }

        .shell::before {
            width: 18rem;
            height: 18rem;
            background: rgba(37, 99, 235, 0.16);
            top: -4rem;
            right: -5rem;
        }

        .shell::after {
            width: 14rem;
            height: 14rem;
            background: rgba(20, 184, 166, 0.14);
            left: -3rem;
            bottom: -3rem;
        }

        .brand-card,
        .login-card {
            position: relative;
            z-index: 1;
            backdrop-filter: blur(18px);
            background: var(--surface);
            border: 1px solid rgba(148, 163, 184, 0.18);
            box-shadow: 0 24px 80px rgba(2, 6, 23, 0.45);
        }

        .brand-mark {
            width: 72px;
            height: 72px;
            border-radius: 22px;
            display: grid;
            place-items: center;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            box-shadow: 0 16px 30px rgba(37, 99, 235, 0.25);
        }

        .feature-list i {
            color: #7dd3fc;
        }

        .form-control,
        .form-select {
            background-color: rgba(15, 23, 42, 0.5);
            border-color: rgba(148, 163, 184, 0.22);
            color: #f8fafc;
            height: 50px;
        }

        .form-control:focus {
            background-color: rgba(15, 23, 42, 0.7);
            border-color: rgba(96, 165, 250, 0.8);
            box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.18);
            color: #fff;
        }

        .form-control::placeholder {
            color: rgba(226, 232, 240, 0.55);
        }

        .btn-login {
            height: 50px;
            background: linear-gradient(135deg, #2563eb, #14b8a6);
            border: none;
            font-weight: 700;
            letter-spacing: 0.02em;
        }

        .btn-login:hover {
            filter: brightness(1.03);
        }

        .helper-badge {
            display: inline-flex;
            align-items: center;
            gap: .45rem;
            padding: .45rem .8rem;
            border-radius: 999px;
            background: rgba(148, 163, 184, 0.12);
            color: #dbeafe;
            font-size: .875rem;
        }

        .alert {
            border: none;
            background: rgba(15, 23, 42, 0.78);
            color: #f8fafc;
        }
    </style>
</head>
<body>
    <div class="shell">
        <div class="container py-4 py-lg-5">
            <div class="row align-items-center justify-content-center min-vh-100 g-4">
                <div class="col-12 col-lg-5">
                    <div class="brand-card rounded-4 p-4 p-lg-5 h-100">
                        <div class="brand-mark mb-4">
                            <i class="fa-solid fa-shirt fa-2x text-white"></i>
                        </div>
                        <div class="mb-3">
                            <span class="helper-badge mb-3">
                                <i class="fa-solid fa-shield-halved"></i>
                                Internal system
                            </span>
                            <h1 class="display-6 fw-bold mb-3 text-white">Admin & Staff Login</h1>
                            <p class="text-white-50 mb-0">
                                For administrator and warehouse staff accounts. Customer accounts are not allowed to access this area.
                            </p>
                        </div>

                        <div class="feature-list mt-4">
                            <div class="d-flex gap-3 mb-3">
                                <i class="fa-solid fa-lock mt-1"></i>
                                <div>
                                    <div class="fw-semibold text-white">Automatic role detection</div>
                                    <div class="text-white-50 small">The system detects `ADMIN` or `STAFF` after login.</div>
                                </div>
                            </div>
                            <div class="d-flex gap-3 mb-3">
                                <i class="fa-solid fa-chart-line mt-1"></i>
                                <div>
                                    <div class="fw-semibold text-white">Direct navigation</div>
                                    <div class="text-white-50 small">Admins go to the dashboard, staff go to the product management screen.</div>
                                </div>
                            </div>
                            <div class="d-flex gap-3">
                                <i class="fa-solid fa-clock-rotate-left mt-1"></i>
                                <div>
                                    <div class="fw-semibold text-white">30-minute session</div>
                                    <div class="text-white-50 small">The session expires automatically after prolonged inactivity.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-5">
                    <div class="login-card rounded-4 p-4 p-lg-5">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h2 class="h3 fw-bold text-white mb-2">Sign in</h2>
                                <p class="text-white-50 mb-0">Enter an internal account to continue.</p>
                            </div>
                            <span class="badge rounded-pill text-bg-primary px-3 py-2">Admin / Staff</span>
                        </div>

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

                        <form action="<%= request.getContextPath() %>/admin-staff-login" method="post" autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label text-white-50 fw-semibold">Username</label>
                                <input type="text"
                                       name="username"
                                       class="form-control"
                                       placeholder="Example: admin01"
                                       value="<%= usernameValue != null ? usernameValue : "" %>"
                                       required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-white-50 fw-semibold">Password</label>
                                <div class="input-group">
                                    <input type="password"
                                           name="password"
                                           id="passwordField"
                                           class="form-control"
                                           placeholder="Enter your password"
                                           required>
                                    <button class="btn btn-outline-light" type="button" id="togglePassword">
                                        <i class="fa-regular fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" value="1" id="rememberMe" disabled>
                                    <label class="form-check-label text-white-50" for="rememberMe">
                                        Remember this session
                                    </label>
                                </div>
                                <a href="<%= request.getContextPath() %>/admin/logout" class="link-info text-decoration-none small">
                                    Sign out another account
                                </a>
                            </div>

                            <button type="submit" class="btn btn-login w-100 text-white">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Sign in
                            </button>
                        </form>

                        <div class="mt-4 pt-3 border-top border-light border-opacity-10">
                            <div class="d-flex flex-wrap gap-2">
                                <span class="helper-badge"><i class="fa-solid fa-user-shield"></i>Admin</span>
                                <span class="helper-badge"><i class="fa-solid fa-user-gear"></i>Staff</span>
                                <span class="helper-badge"><i class="fa-solid fa-circle-info"></i>Customer not supported</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const passwordField = document.getElementById('passwordField');
        const togglePassword = document.getElementById('togglePassword');

        // Toggle password visibility without affecting form submission.
        togglePassword.addEventListener('click', function () {
            const showing = passwordField.type === 'text';
            passwordField.type = showing ? 'password' : 'text';
            this.innerHTML = showing
                ? '<i class="fa-regular fa-eye"></i>'
                : '<i class="fa-regular fa-eye-slash"></i>';
        });
    </script>
</body>
</html>
