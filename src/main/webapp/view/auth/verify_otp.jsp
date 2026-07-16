<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String infoMessage = (String) request.getAttribute("infoMessage");
    String pendingEmail = (String) request.getAttribute("pendingEmail");
    String verificationContext = (String) request.getAttribute("verificationContext");
    Boolean verificationAllowed = (Boolean) request.getAttribute("verificationAllowed");
    boolean canVerify = verificationAllowed == null || verificationAllowed.booleanValue();
    boolean loginFlow = "LOGIN".equalsIgnoreCase(verificationContext);
    String ctx = request.getContextPath();
    String pageTitle = loginFlow ? "Verify to sign in" : "Verify your account";
    String pageSubtitle = loginFlow
            ? "Enter the 6-digit code we sent to your email to continue signing in."
            : "Enter the 6-digit code we sent to your email to activate the account.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> | Clothing Sale</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --ink:#172033;
            --muted:#667085;
            --line:#e4e7ec;
            --paper:#ffffff;
            --brand:#2563eb;
            --teal:#0f9b8e;
            --coral:#e8795b;
            --warning:#f59e0b;
        }

        * { box-sizing:border-box; }

        body {
            min-height:100vh;
            min-height:100svh;
            margin:0;
            color:var(--ink);
            background:
                linear-gradient(120deg, rgba(255, 255, 255, .86) 0 42%, rgba(240, 253, 250, .72) 42% 68%, rgba(255, 247, 237, .82) 68% 100%),
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

        .verify-layout {
            width:100%;
            max-width:1160px;
            margin:auto;
            display:grid;
            grid-template-columns:minmax(0, .92fr) minmax(420px, 1fr);
            gap:24px;
            align-items:stretch;
        }

        .visual-panel,
        .verify-card {
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
            background:linear-gradient(160deg, rgba(23, 32, 51, .96) 0%, rgba(44, 66, 70, .94) 100%);
        }

        .visual-panel::before {
            content:"";
            position:absolute;
            inset:0;
            background:linear-gradient(135deg, rgba(255,255,255,.08), transparent 32%, rgba(232,121,91,.16) 100%);
            pointer-events:none;
        }

        .visual-copy,
        .security-strip,
        .lookbook {
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
            font-size:clamp(2rem, 4vw, 3.45rem);
            line-height:1.04;
            font-weight:900;
        }

        .visual-text {
            max-width:450px;
            margin:18px 0 0;
            color:rgba(255, 255, 255, .74);
            font-size:1.02rem;
        }

        .lookbook {
            display:grid;
            grid-template-columns:1.05fr .78fr;
            gap:14px;
            margin:32px 0;
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
            min-height:320px;
        }

        .lookbook-stack {
            display:grid;
            grid-template-rows:1fr 1fr;
            gap:14px;
        }

        .security-strip {
            display:grid;
            grid-template-columns:repeat(3, minmax(0, 1fr));
            gap:12px;
            color:rgba(255, 255, 255, .82);
            font-size:.9rem;
        }

        .security-strip span {
            display:flex;
            align-items:center;
            gap:8px;
        }

        .verify-card {
            min-height:620px;
            padding:42px;
            display:flex;
            flex-direction:column;
            justify-content:center;
            background:rgba(255, 255, 255, .94);
            backdrop-filter:blur(16px);
        }

        .status-mark {
            width:58px;
            height:58px;
            margin-bottom:18px;
            border-radius:8px;
            display:grid;
            place-items:center;
            color:#fff;
            background:linear-gradient(135deg, var(--brand), var(--teal));
            box-shadow:0 18px 32px rgba(15, 155, 142, .24);
            font-size:1.55rem;
        }

        .card-kicker {
            width:max-content;
            margin-bottom:16px;
            padding:8px 12px;
            border-radius:999px;
            color:#0f766e;
            background:#dff7f3;
            font-size:.82rem;
            font-weight:800;
        }

        .verify-title {
            margin:0;
            font-size:clamp(1.95rem, 3vw, 2.65rem);
            line-height:1.1;
            font-weight:900;
        }

        .verify-subtitle {
            margin:12px 0 24px;
            color:var(--muted);
            font-size:1rem;
        }

        .email-chip {
            width:100%;
            margin-bottom:22px;
            padding:13px 14px;
            border:1px solid #cfe9e5;
            border-radius:8px;
            display:flex;
            align-items:center;
            gap:12px;
            color:#0f766e;
            background:#f0fdfa;
            font-weight:800;
            overflow-wrap:anywhere;
        }

        .email-chip i {
            flex:0 0 auto;
        }

        .alert {
            border:0;
            border-radius:8px;
            font-weight:650;
        }

        .form-label {
            color:#344054;
            font-size:.92rem;
            font-weight:800;
        }

        .otp-control {
            position:relative;
        }

        .otp-control i {
            position:absolute;
            left:17px;
            top:50%;
            transform:translateY(-50%);
            color:#98a2b3;
            pointer-events:none;
        }

        .otp-input {
            height:62px;
            width:100%;
            padding:0 18px 0 50px;
            border:1px solid #d0d5dd;
            border-radius:8px;
            background:#fff;
            color:var(--ink);
            font-size:1.55rem;
            font-weight:900;
            letter-spacing:.28em;
            box-shadow:0 1px 2px rgba(16, 24, 40, .04);
        }

        .otp-input::placeholder {
            color:#b8c0cc;
            letter-spacing:.2em;
        }

        .otp-input:focus {
            border-color:var(--teal);
            box-shadow:0 0 0 .22rem rgba(15, 155, 142, .14);
            outline:0;
        }

        .helper-row {
            margin-top:9px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;
            color:var(--muted);
            font-size:.88rem;
        }

        .btn-verify,
        .btn-resend {
            min-height:52px;
            border-radius:8px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            font-weight:800;
        }

        .btn-verify {
            border:0;
            background:linear-gradient(135deg, var(--brand), var(--teal));
            color:#fff;
            box-shadow:0 16px 26px rgba(37, 99, 235, .22);
        }

        .btn-verify:hover,
        .btn-verify:focus {
            color:#fff;
            filter:brightness(.98);
            box-shadow:0 18px 30px rgba(15, 155, 142, .26);
        }

        .btn-resend {
            border:1px solid #cfd7e6;
            background:#fff;
            color:#344054;
        }

        .btn-resend:hover,
        .btn-resend:focus {
            border-color:#b8d8d1;
            color:#0f766e;
            background:#f3fbf9;
        }

        .divider {
            margin:18px 0;
            display:flex;
            align-items:center;
            gap:14px;
            color:#98a2b3;
            font-size:.82rem;
            font-weight:700;
        }

        .divider::before,
        .divider::after {
            content:"";
            height:1px;
            flex:1;
            background:var(--line);
        }

        @media (max-width: 991.98px) {
            .verify-layout {
                grid-template-columns:1fr;
            }

            .visual-panel,
            .verify-card {
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
            .verify-card {
                padding:24px;
            }

            .lookbook,
            .security-strip {
                grid-template-columns:1fr;
            }

            .lookbook-main {
                min-height:220px;
            }

            .helper-row {
                align-items:flex-start;
                flex-direction:column;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/view/customer/common/header.jsp"/>

    <main class="auth-shell">
        <div class="auth-topbar">
            <a class="brand-link" href="<%= ctx %>/home">
                <span class="brand-logo"><i class="fa-solid fa-shirt"></i></span>
                <span>Clothing Sale</span>
            </a>
        </div>

        <div class="verify-layout">
            <section class="visual-panel" aria-label="Clothing Sale account security">
                <div class="visual-copy">
                    <div class="eyebrow">Secure checkout access</div>
                    <h1 class="visual-title">One quick code, then back to shopping.</h1>
                    <p class="visual-text">
                        We use OTP verification to protect your account details, saved addresses, and orders.
                    </p>
                </div>

                <div class="lookbook">
                    <img class="lookbook-main" src="<%= ctx %>/uploads/product/prod21-main.jpg" alt="Clothing Sale product">
                    <div class="lookbook-stack">
                        <img src="<%= ctx %>/uploads/product/prod18-main.jpg" alt="Clothing Sale product">
                        <img src="<%= ctx %>/uploads/product/prod20-main.jpg" alt="Clothing Sale product">
                    </div>
                </div>

                <div class="security-strip">
                    <span><i class="fa-solid fa-shield-halved"></i> Protected account</span>
                    <span><i class="fa-solid fa-envelope-circle-check"></i> Email check</span>
                    <span><i class="fa-solid fa-bag-shopping"></i> Fast return</span>
                </div>
            </section>

            <section class="verify-card">
                <div class="status-mark">
                    <i class="fa-solid fa-key"></i>
                </div>
                <div class="card-kicker"><%= loginFlow ? "Customer sign in" : "New account" %></div>
                <h2 class="verify-title"><%= pageTitle %></h2>
                <p class="verify-subtitle"><%= pageSubtitle %></p>

                <% if (pendingEmail != null && !pendingEmail.trim().isEmpty()) { %>
                    <div class="email-chip">
                        <i class="fa-regular fa-envelope"></i>
                        <span><%= pendingEmail %></span>
                    </div>
                <% } %>

                <% if (infoMessage != null) { %>
                    <div class="alert alert-info d-flex align-items-center gap-2 mb-3" role="alert">
                        <i class="fa-solid fa-circle-info"></i>
                        <span><%= infoMessage %></span>
                    </div>
                <% } %>

                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" role="alert">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= errorMessage %></span>
                    </div>
                <% } %>

                <% if (canVerify) { %>
                    <form action="<%= ctx %>/customer/verify-otp" method="post" autocomplete="off" id="verifyOtpForm">
                        <div class="mb-4">
                            <label class="form-label" for="codeField">Verification code</label>
                            <div class="otp-control">
                                <i class="fa-solid fa-lock"></i>
                                <input class="otp-input"
                                       id="codeField"
                                       name="code"
                                       inputmode="numeric"
                                       maxlength="6"
                                       pattern="[0-9]{6}"
                                       placeholder="******"
                                       aria-describedby="otpHelp"
                                       required>
                            </div>
                            <div class="helper-row" id="otpHelp">
                                <span>Use the latest 6-digit code from your inbox.</span>
                                <span id="codeCounter">0/6</span>
                            </div>
                        </div>

                        <button class="btn btn-verify w-100" type="submit">
                            <i class="fa-solid fa-circle-check me-2"></i>
                            Verify account
                        </button>
                    </form>

                    <div class="divider">or</div>

                    <form action="<%= ctx %>/customer/resend-otp" method="post">
                        <button class="btn btn-resend w-100" type="submit">
                            <i class="fa-solid fa-paper-plane me-2"></i>
                            Resend code
                        </button>
                    </form>
                <% } %>
            </section>
        </div>
    </main>

    <script>
        (function () {
            var codeField = document.getElementById('codeField');
            var codeCounter = document.getElementById('codeCounter');

            if (!codeField || !codeCounter) {
                return;
            }

            function syncCode() {
                codeField.value = codeField.value.replace(/\D/g, '').slice(0, 6);
                codeCounter.textContent = codeField.value.length + '/6';
            }

            codeField.addEventListener('input', syncCode);
            codeField.addEventListener('paste', function () {
                window.setTimeout(syncCode, 0);
            });
            syncCode();
        })();
    </script>
</body>
</html>
