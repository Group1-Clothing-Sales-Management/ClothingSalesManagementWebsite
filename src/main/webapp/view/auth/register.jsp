<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) request.getAttribute("username");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create account | Clothing Sale</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        :root { --bg-1:#0f172a; --bg-2:#111827; --accent:#2563eb; --accent-2:#14b8a6; --surface: rgba(15,23,42,0.72);} 
        body { min-height:100vh; margin:0; color:#e5eefc; background: linear-gradient(135deg,var(--bg-1),var(--bg-2)); font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }
        .shell { min-height:100vh; position:relative; overflow:hidden; }
        .brand-card, .auth-card { position:relative; z-index:1; backdrop-filter: blur(12px); background:var(--surface); border:1px solid rgba(148,163,184,0.18); box-shadow:0 24px 80px rgba(2,6,23,0.45); }
        .brand-mark { width:72px; height:72px; border-radius:22px; display:grid; place-items:center; background: linear-gradient(135deg,var(--accent),var(--accent-2)); }
        .form-control { background:#000; color:#fff; border-color: rgba(148,163,184,0.22); height:50px; }
        .form-control::placeholder { color: rgba(255,255,255,0.6); }
        .btn-primary { background: linear-gradient(135deg,#2563eb,#14b8a6); border:none; }
    </style>
</head>
<body>
    <div class="shell">
        <div class="container py-5">
            <div class="row align-items-center justify-content-center min-vh-100 g-4">
                <div class="col-12 col-lg-5">
                    <div class="brand-card rounded-4 p-4 p-lg-5 h-100">
                        <div class="brand-mark mb-4">
                            <i class="fa-solid fa-shirt fa-2x text-white"></i>
                        </div>
                        <h2 class="fw-bold">Chào mừng</h2>
                        <p class="text-white-50">Tạo tài khoản để mua hàng nhanh hơn và quản lý đơn hàng.</p>
                    </div>
                </div>

                <div class="col-12 col-lg-5">
                    <div class="auth-card rounded-4 p-4 p-lg-5">
                        <div class="mb-4">
                            <h3 class="h4 fw-bold text-white mb-1">Đăng ký</h3>
                            <p class="text-white-50 mb-0">Nhập thông tin của bạn để tạo tài khoản.</p>
                        </div>
                        <% if (errorMessage != null) { %>
                            <div class="alert alert-danger d-flex align-items-center gap-2 mb-4" role="alert">
                                <i class="fa-solid fa-circle-exclamation"></i>
                                <span><%= errorMessage %></span>
                            </div>
                        <% } %>
                        <form action="<%= request.getContextPath() %>/customer/register" method="post" autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label text-white-50">Username</label>
                                <input class="form-control" name="username" value="<%= username != null ? username : "" %>" placeholder="Tên đăng nhập" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-white-50">Password</label>
                                <input type="password" class="form-control" name="password" placeholder="Mật khẩu" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-white-50">Full name</label>
                                <input class="form-control" name="fullName" placeholder="Họ và tên" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-white-50">Email</label>
                                <input type="email" class="form-control" name="email" placeholder="email@domain.com" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-white-50">Phone</label>
                                <input class="form-control" name="phone" placeholder="Số điện thoại">
                            </div>
                            <div class="d-flex gap-2">
                                <button class="btn btn-primary w-100">Create account</button>
                                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/customer/login">Sign in</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
