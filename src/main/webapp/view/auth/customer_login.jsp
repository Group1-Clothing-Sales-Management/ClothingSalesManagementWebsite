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
    <title>Customer Login | Clothing Sale</title>
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

        * { box-sizing: border-box; }

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

        .shell { min-height: 100vh; position: relative; overflow: hidden; }
        .brand-card, .login-card {
            position: relative; z-index: 1; backdrop-filter: blur(18px);
            background: var(--surface); border: 1px solid rgba(148,163,184,0.18);
            box-shadow: 0 24px 80px rgba(2,6,23,0.45);
        }

        .brand-mark { width:72px; height:72px; border-radius:22px; display:grid; place-items:center;
            background: linear-gradient(135deg,var(--accent),var(--accent-2));
            box-shadow: 0 16px 30px rgba(37,99,235,0.25);
        }

        .form-control, .form-select {
            background-color: #000; /* black background */
            border-color: rgba(148,163,184,0.22);
            color: #ffffff; /* white input text */
            height: 50px;
        }

        .form-control::placeholder { color: rgba(255,255,255,0.55); }

        .form-control:focus { background-color: #111; border-color: rgba(96,165,250,0.8); color: #fff; }
        .btn-login { height:50px; background: linear-gradient(135deg,#2563eb,#14b8a6); border:none; font-weight:700; }
        .alert { border:none; background: rgba(15,23,42,0.78); color:#f8fafc; }
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
                            <h1 class="display-6 fw-bold mb-3 text-white">Welcome back, Customer</h1>
                            <p class="text-white-50 mb-0">Sign in to view your cart, orders and manage your account.</p>
                        </div>
                        <div class="feature-list mt-4">
                            <div class="d-flex gap-3 mb-3">
                                <i class="fa-solid fa-lock mt-1"></i>
                                <div>
                                    <div class="fw-semibold text-white">Secure access</div>
                                    <div class="text-white-50 small">Your credentials are securely verified before access.</div>
                                </div>
                            </div>
                            <div class="d-flex gap-3">
                                <i class="fa-solid fa-truck mt-1"></i>
                                <div>
                                    <div class="fw-semibold text-white">Quick checkout</div>
                                    <div class="text-white-50 small">Sign in to speed up checkout and track orders.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-5">
                    <div class="login-card rounded-4 p-4 p-lg-5">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h2 class="h3 fw-bold text-white mb-2">Customer Sign in</h2>
                                <p class="text-white-50 mb-0">Enter your account to continue.</p>
                            </div>
                            <span class="badge rounded-pill text-bg-primary px-3 py-2">Customer</span>
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

                        <form action="<%= request.getContextPath() %>/customer/login" method="post" autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label text-white-50 fw-semibold">Username or email</label>
                                <input type="text" name="username" class="form-control" placeholder="Your username or email"
                                       value="<%= usernameValue != null ? usernameValue : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-white-50 fw-semibold">Password</label>
                                <div class="input-group">
                                    <input type="password" name="password" id="passwordField" class="form-control" placeholder="Enter your password" required>
                                    <button class="btn btn-outline-light" type="button" id="togglePassword">
                                        <i class="fa-regular fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div></div>
                                <a href="<%= request.getContextPath() %>/customer/register" class="link-info text-decoration-none small">Create account</a>
                            </div>

                            <button type="submit" class="btn btn-login w-100 text-white"><i class="fa-solid fa-right-to-bracket me-2"></i>Sign in</button>
                        </form>

                        <div class="mt-4 pt-3 border-top border-light border-opacity-10">
                            <div class="d-flex flex-wrap gap-2">
                                <span class="helper-badge"><i class="fa-solid fa-user"></i>Customer</span>
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
        togglePassword.addEventListener('click', function () {
            const showing = passwordField.type === 'text';
            passwordField.type = showing ? 'password' : 'text';
            this.innerHTML = showing ? '<i class="fa-regular fa-eye"></i>' : '<i class="fa-regular fa-eye-slash"></i>';
        });
    </script>
</body>
</html>
