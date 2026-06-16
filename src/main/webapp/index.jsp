<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    // Lấy trạng thái đăng nhập để đổi CTA theo đúng vai trò người dùng.
    jakarta.servlet.http.HttpSession sess = request.getSession(false);
    Object authId = sess != null ? sess.getAttribute("authUserId") : null;
    String role = sess != null && sess.getAttribute("authRoleName") != null ? sess.getAttribute("authRoleName").toString() : null;

    String ctx = request.getContextPath();
    NumberFormat moneyFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));

    String primaryLabel = "Khám phá ngay";
    String primaryHref = ctx + "/customer/login";
    String secondaryLabel = "Xem giỏ hàng";
    String secondaryHref = ctx + "/view/cart.jsp";
    String dashboardHref = ctx + "/admin/dashboard";

    if (authId != null && "CUSTOMER".equalsIgnoreCase(role)) {
        primaryLabel = "Mở giỏ hàng";
        primaryHref = ctx + "/cart";
        secondaryLabel = "Đăng xuất";
        secondaryHref = ctx + "/customer/logout";
    } else if (authId != null && ("ADMIN".equalsIgnoreCase(role) || "STAFF".equalsIgnoreCase(role))) {
        primaryLabel = "Mở bảng điều khiển";
        primaryHref = dashboardHref;
        secondaryLabel = "Đăng xuất";
        secondaryHref = ctx + "/admin/logout";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clothing Sale | Trang chủ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #f6f2ea;
            --bg-1: #fffaf4;
            --text: #172033;
            --muted: #6b7280;
            --primary: #1f6feb;
            --primary-2: #0f9b8e;
            --surface: rgba(255, 255, 255, 0.82);
            --border: rgba(15, 23, 42, 0.08);
            --shadow: 0 24px 70px rgba(15, 23, 42, 0.10);
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            color: var(--text);
            background:
                radial-gradient(circle at top left, rgba(31, 111, 235, 0.14), transparent 30%),
                radial-gradient(circle at right 20%, rgba(15, 155, 142, 0.10), transparent 24%),
                linear-gradient(180deg, var(--bg-1), var(--bg-0));
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .page-shell {
            position: relative;
            overflow: clip;
        }

        .page-shell::before,
        .page-shell::after {
            content: "";
            position: absolute;
            border-radius: 999px;
            pointer-events: none;
            filter: blur(8px);
            opacity: 0.65;
        }

        .page-shell::before {
            width: 22rem;
            height: 22rem;
            background: rgba(31, 111, 235, 0.10);
            top: -7rem;
            left: -6rem;
        }

        .page-shell::after {
            width: 18rem;
            height: 18rem;
            background: rgba(15, 155, 142, 0.10);
            right: -5rem;
            top: 24rem;
        }

        .glass-nav {
            background: rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(15, 23, 42, 0.06);
        }

        .brand-mark {
            width: 44px;
            height: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            color: #fff;
            background: linear-gradient(135deg, var(--primary), var(--primary-2));
            box-shadow: 0 12px 24px rgba(31, 111, 235, 0.25);
        }

        .hero {
            position: relative;
            z-index: 1;
            padding: 4.5rem 0 2rem;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            padding: .45rem .85rem;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.82);
            border: 1px solid var(--border);
            color: var(--primary);
            font-weight: 700;
            box-shadow: 0 8px 30px rgba(15, 23, 42, 0.05);
        }

        .hero-title {
            font-size: clamp(2.4rem, 5vw, 4.9rem);
            line-height: 0.98;
            letter-spacing: -0.05em;
            font-weight: 900;
        }

        .hero-copy {
            max-width: 44rem;
            color: var(--muted);
            font-size: 1.05rem;
        }

        .hero-actions .btn {
            min-height: 52px;
            padding-inline: 1.2rem;
            border-radius: 999px;
            font-weight: 700;
        }

        .btn-primary-soft {
            border: none;
            color: #fff;
            background: linear-gradient(135deg, var(--primary), var(--primary-2));
            box-shadow: 0 16px 32px rgba(31, 111, 235, 0.24);
        }

        .btn-primary-soft:hover {
            color: #fff;
            filter: brightness(1.03);
        }

        .metric-card,
        .showcase-card,
        .feature-card,
        .category-card,
        .product-card {
            background: var(--surface);
            border: 1px solid var(--border);
            backdrop-filter: blur(12px);
            box-shadow: var(--shadow);
        }

        .metric-card {
            border-radius: 22px;
            padding: 1rem;
        }

        .metric-label {
            color: var(--muted);
            font-size: .85rem;
            text-transform: uppercase;
            letter-spacing: .08em;
        }

        .showcase-card {
            border-radius: 30px;
            overflow: hidden;
            position: relative;
        }

        .showcase-image {
            min-height: 28rem;
            object-fit: cover;
            width: 100%;
        }

        .showcase-badge {
            position: absolute;
            left: 1.25rem;
            top: 1.25rem;
            padding: .55rem .9rem;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.92);
            font-weight: 700;
            color: var(--text);
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.10);
        }

        .floating-info {
            position: absolute;
            right: 1rem;
            bottom: 1rem;
            padding: 1rem;
            border-radius: 22px;
            min-width: 14rem;
            background: rgba(15, 23, 42, 0.88);
            color: #fff;
        }

        .section-title {
            font-size: clamp(1.65rem, 2.5vw, 2.25rem);
            letter-spacing: -0.03em;
            font-weight: 800;
        }

        .section-lead {
            color: var(--muted);
            max-width: 42rem;
        }

        .category-card {
            border-radius: 24px;
            overflow: hidden;
            transition: transform .25s ease, box-shadow .25s ease;
        }

        .category-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.14);
        }

        .category-image {
            height: 12rem;
            object-fit: cover;
        }

        .product-card {
            border-radius: 26px;
            overflow: hidden;
            transition: transform .25s ease, box-shadow .25s ease;
            height: 100%;
        }

        .product-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.16);
        }

        .product-image {
            aspect-ratio: 4 / 5;
            width: 100%;
            object-fit: cover;
            background: #e2e8f0;
        }

        .product-pill {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            padding: .35rem .75rem;
            border-radius: 999px;
            background: rgba(31, 111, 235, 0.10);
            color: var(--primary);
            font-weight: 700;
            font-size: .82rem;
        }

        .feature-card {
            border-radius: 24px;
            height: 100%;
        }

        .feature-icon {
            width: 54px;
            height: 54px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 18px;
            color: #fff;
            background: linear-gradient(135deg, var(--primary), var(--primary-2));
        }

        .footer {
            color: var(--muted);
        }

        .soft-divider {
            border-top: 1px solid rgba(15, 23, 42, 0.08);
        }

        @media (max-width: 991.98px) {
            .hero {
                padding-top: 2.5rem;
            }

            .showcase-image {
                min-height: 22rem;
            }
        }
    </style>
    <style>
        .icon-add-cart{
            width:46px;height:46px;border-radius:10px;border:2px solid #f1f1f1;background:#fff;display:inline-flex;align-items:center;justify-content:center;color:#e74c3c;font-size:20px;box-shadow:0 6px 18px rgba(231,76,60,0.08);transition:transform .12s,box-shadow .12s}
        .icon-add-cart:hover{transform:translateY(-2px);box-shadow:0 10px 26px rgba(231,76,60,0.12)}
        .icon-add-cart i{pointer-events:none}
    </style>
</head>
<body>
    <div class="page-shell">
        <!-- Thanh điều hướng nổi để tạo cảm giác cao cấp và gọn mắt hơn. -->
        <nav class="navbar navbar-expand-lg navbar-light glass-nav sticky-top">
            <div class="container py-2">
                <a class="navbar-brand d-flex align-items-center gap-3 fw-bold text-dark" href="<%= ctx %>/">
                    <span class="brand-mark"><i class="fa-solid fa-shirt"></i></span>
                    <span>
                        Clothing Sale
                        <small class="d-block text-secondary fw-semibold" style="font-size:.75rem;">Style that fits every day</small>
                    </span>
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="mainNav">
                    <ul class="navbar-nav mx-auto mb-2 mb-lg-0 gap-lg-2">
                        <li class="nav-item"><a class="nav-link fw-semibold" href="#danhmuc">Danh mục</a></li>
                        <li class="nav-item"><a class="nav-link fw-semibold" href="#sanpham">Sản phẩm</a></li>
                        <li class="nav-item"><a class="nav-link fw-semibold" href="#lydo">Vì sao chọn chúng tôi</a></li>
                    </ul>

                    <div class="d-flex gap-2">
                        <a class="btn btn-outline-secondary rounded-pill px-3" href="<%= secondaryHref %>">
                            <i class="fa-solid fa-bag-shopping me-2"></i><%= secondaryLabel %>
                        </a>
                        <a class="btn btn-primary-soft rounded-pill px-3" href="<%= primaryHref %>">
                            <i class="fa-solid fa-arrow-right me-2"></i><%= primaryLabel %>
                        </a>
                    </div>
                </div>
            </div>
        </nav>

        <main>
            <section class="hero">
                <div class="container position-relative">
                    <div class="row align-items-center g-4 g-lg-5">
                        <div class="col-12 col-lg-6">
                            <span class="eyebrow mb-4">
                                <i class="fa-solid fa-sparkles"></i>
                                Bộ sưu tập mới mùa này
                            </span>
                            <h1 class="hero-title mb-4">
                                Mặc đẹp hơn mỗi ngày với phong cách tối giản, hiện đại.
                            </h1>
                            <p class="hero-copy mb-4">
                                Clothing Sale mang đến trang phục dễ phối, form đẹp và giá hợp lý.
                                Chọn nhanh những item nổi bật cho công việc, dạo phố và những buổi hẹn cuối tuần.
                            </p>

                            <div class="hero-actions d-flex flex-wrap gap-3 mb-4">
                                <a class="btn btn-primary-soft" href="<%= primaryHref %>">
                                    <i class="fa-solid fa-bolt me-2"></i><%= primaryLabel %>
                                </a>
                                <a class="btn btn-outline-dark" href="#sanpham">
                                    Xem sản phẩm nổi bật
                                </a>
                            </div>

                            <div class="row g-3 mt-1">
                                <div class="col-6 col-md-4">
                                    <div class="metric-card h-100">
                                        <div class="metric-label">Mẫu mới</div>
                                        <div class="fs-3 fw-bold">120+</div>
                                        <div class="text-secondary small">Liên tục cập nhật</div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-4">
                                    <div class="metric-card h-100">
                                        <div class="metric-label">Khách hài lòng</div>
                                        <div class="fs-3 fw-bold">98%</div>
                                        <div class="text-secondary small">Trải nghiệm mua sắm tốt</div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-4">
                                    <div class="metric-card h-100">
                                        <div class="metric-label">Giao hàng</div>
                                        <div class="fs-3 fw-bold">24h</div>
                                        <div class="text-secondary small">Nhanh và rõ ràng</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12 col-lg-6">
                            <div class="showcase-card">
                                <span class="showcase-badge">
                                    <i class="fa-solid fa-fire text-warning me-2"></i>Best seller tuần này
                                </span>
                                <img src="<%= ctx %>/uploads/product/prod22-main.jpg" class="showcase-image" alt="Bộ sưu tập thời trang">
                                <div class="floating-info">
                                    <div class="small text-white-50">Gợi ý hôm nay</div>
                                    <div class="fw-bold fs-5">Mix & match theo phong cách riêng</div>
                                    <div class="mt-2 d-flex align-items-center gap-2">
                                        <span class="badge rounded-pill text-bg-light">New Arrival</span>
                                        <span class="badge rounded-pill text-bg-success">Trending</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="danhmuc" class="py-5">
                <div class="container">
                    <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
                        <div>
                            <p class="text-uppercase text-secondary fw-bold small mb-2">Danh mục nổi bật</p>
                            <h2 class="section-title mb-2">Chọn nhanh theo nhu cầu</h2>
                            <p class="section-lead mb-0">Các nhóm sản phẩm được sắp xếp rõ ràng để khách hàng tìm đúng item cần mua chỉ trong vài cú nhấp.</p>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-12 col-md-4">
                            <div class="category-card h-100">
                                <img src="<%= ctx %>/uploads/product/prod21-main.jpg" class="category-image w-100" alt="Áo thun">
                                <div class="p-4">
                                    <div class="product-pill mb-3"><i class="fa-solid fa-shirt"></i>Áo thun</div>
                                    <h3 class="h5 fw-bold mb-2">Tối giản, dễ phối, mặc hằng ngày</h3>
                                    <p class="text-secondary mb-0">Form thoải mái, hợp đi làm, đi học hoặc dạo phố cuối tuần.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="category-card h-100">
                                <img src="<%= ctx %>/uploads/product/prod20-main.jpg" class="category-image w-100" alt="Quần jeans">
                                <div class="p-4">
                                    <div class="product-pill mb-3"><i class="fa-solid fa-person-walking"></i>Quần jeans</div>
                                    <h3 class="h5 fw-bold mb-2">Phom chuẩn, bền vải, dễ lên đồ</h3>
                                    <p class="text-secondary mb-0">Tạo cảm giác chỉn chu nhưng vẫn rất thoải mái cho cả ngày dài.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="category-card h-100">
                                <img src="<%= ctx %>/uploads/product/prod19-main.jpg" class="category-image w-100" alt="Áo khoác">
                                <div class="p-4">
                                    <div class="product-pill mb-3"><i class="fa-solid fa-wind"></i>Áo khoác</div>
                                    <h3 class="h5 fw-bold mb-2">Layer đẹp, đủ ấm, vẫn gọn gàng</h3>
                                    <p class="text-secondary mb-0">Hoàn thiện outfit theo kiểu tinh tế, trẻ trung và hiện đại.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="sanpham" class="py-5">
                <div class="container">
                    <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
                        <div>
                            <p class="text-uppercase text-secondary fw-bold small mb-2">Sản phẩm nổi bật</p>
                            <h2 class="section-title mb-2">Mới, đẹp và dễ bán</h2>
                            <p class="section-lead mb-0">Các thẻ sản phẩm được thiết kế rộng rãi hơn, có nhãn giá và CTA rõ ràng để nhìn là muốn bấm ngay.</p>
                        </div>
                        <a href="<%= primaryHref %>" class="btn btn-outline-dark rounded-pill px-3">
                            <i class="fa-solid fa-arrow-up-right-from-square me-2"></i><%= primaryLabel %>
                        </a>
                    </div>

                    <div class="row g-4">
                        <div class="col-12 col-sm-6 col-xl-3">
                            <div class="product-card">
                                <img src="<%= ctx %>/uploads/product/prod22-main.jpg" class="product-image" alt="Áo thun basic">
                                <div class="p-4">
                                    <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                                        <div>
                                            <div class="product-pill mb-2">New</div>
                                            <h3 class="h5 fw-bold mb-1">Áo thun basic</h3>
                                        </div>
                                        <span class="text-secondary fw-semibold small">4.9/5</span>
                                    </div>
                                    <p class="text-secondary small mb-3">Chất vải mềm, form gọn, phối được với nhiều phong cách.</p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold fs-5 text-dark">₫<%= moneyFormat.format(150000) %></span>
                                        <div class="d-flex align-items-center" style="gap:8px">
                                            <a class="btn btn-sm btn-primary-soft rounded-pill" href="<%= primaryHref %>">Mua ngay</a>
                                            <form action="<%= ctx %>/cart/add" method="post" style="margin:0">
                                                <input type="hidden" name="variantId" value="22" />
                                                <input type="hidden" name="productId" value="22" />
                                                <input type="hidden" name="productName" value="Áo thun basic" />
                                                <input type="hidden" name="attributes" value="" />
                                                <input type="hidden" name="price" value="150000" />
                                                <input type="hidden" name="quantity" value="1" />
                                                <input type="hidden" name="imageUrl" value="<%= ctx %>/uploads/product/prod22-main.jpg" />
                                                <button type="submit" class="icon-add-cart" title="Thêm vào giỏ"><i class="fa-solid fa-cart-plus"></i></button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12 col-sm-6 col-xl-3">
                            <div class="product-card">
                                <img src="<%= ctx %>/uploads/product/prod17-main.jpg" class="product-image" alt="Quần jeans">
                                <div class="p-4">
                                    <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                                        <div>
                                            <div class="product-pill mb-2">Hot</div>
                                            <h3 class="h5 fw-bold mb-1">Quần jeans</h3>
                                        </div>
                                        <span class="text-secondary fw-semibold small">4.8/5</span>
                                    </div>
                                    <p class="text-secondary small mb-3">Dáng đẹp, dễ mặc, phù hợp đi làm lẫn đi chơi.</p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold fs-5 text-dark">₫<%= moneyFormat.format(350000) %></span>
                                        <div class="d-flex align-items-center" style="gap:8px">
                                            <a class="btn btn-sm btn-primary-soft rounded-pill" href="<%= primaryHref %>">Mua ngay</a>
                                            <form action="<%= ctx %>/cart/add" method="post" style="margin:0">
                                                <input type="hidden" name="variantId" value="17" />
                                                <input type="hidden" name="productId" value="17" />
                                                <input type="hidden" name="productName" value="Quần jeans" />
                                                <input type="hidden" name="attributes" value="" />
                                                <input type="hidden" name="price" value="350000" />
                                                <input type="hidden" name="quantity" value="1" />
                                                <input type="hidden" name="imageUrl" value="<%= ctx %>/uploads/product/prod17-main.jpg" />
                                                <button type="submit" class="icon-add-cart" title="Thêm vào giỏ"><i class="fa-solid fa-cart-plus"></i></button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12 col-sm-6 col-xl-3">
                            <div class="product-card">
                                <img src="<%= ctx %>/uploads/product/prod16-main.jpg" class="product-image" alt="Áo khoác nhẹ">
                                <div class="p-4">
                                    <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                                        <div>
                                            <div class="product-pill mb-2">Best pick</div>
                                            <h3 class="h5 fw-bold mb-1">Áo khoác nhẹ</h3>
                                        </div>
                                        <span class="text-secondary fw-semibold small">4.9/5</span>
                                    </div>
                                    <p class="text-secondary small mb-3">Thiết kế tối giản, dễ layer, hợp thời tiết chuyển mùa.</p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold fs-5 text-dark">₫<%= moneyFormat.format(420000) %></span>
                                        <div class="d-flex align-items-center" style="gap:8px">
                                            <a class="btn btn-sm btn-primary-soft rounded-pill" href="<%= primaryHref %>">Mua ngay</a>
                                            <form action="<%= ctx %>/cart/add" method="post" style="margin:0">
                                                <input type="hidden" name="variantId" value="16" />
                                                <input type="hidden" name="productId" value="16" />
                                                <input type="hidden" name="productName" value="Áo khoác nhẹ" />
                                                <input type="hidden" name="attributes" value="" />
                                                <input type="hidden" name="price" value="420000" />
                                                <input type="hidden" name="quantity" value="1" />
                                                <input type="hidden" name="imageUrl" value="<%= ctx %>/uploads/product/prod16-main.jpg" />
                                                <button type="submit" class="icon-add-cart" title="Thêm vào giỏ"><i class="fa-solid fa-cart-plus"></i></button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12 col-sm-6 col-xl-3">
                            <div class="product-card">
                                <img src="<%= ctx %>/uploads/product/prod15-main.jpg" class="product-image" alt="Váy nữ">
                                <div class="p-4">
                                    <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                                        <div>
                                            <div class="product-pill mb-2">Trending</div>
                                            <h3 class="h5 fw-bold mb-1">Váy nữ</h3>
                                        </div>
                                        <span class="text-secondary fw-semibold small">4.7/5</span>
                                    </div>
                                    <p class="text-secondary small mb-3">Mềm mại, tôn dáng, phù hợp đi tiệc nhẹ hoặc hẹn hò.</p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold fs-5 text-dark">₫<%= moneyFormat.format(280000) %></span>
                                        <div class="d-flex align-items-center" style="gap:8px">
                                            <a class="btn btn-sm btn-primary-soft rounded-pill" href="<%= primaryHref %>">Mua ngay</a>
                                            <form action="<%= ctx %>/cart/add" method="post" style="margin:0">
                                                <input type="hidden" name="variantId" value="15" />
                                                <input type="hidden" name="productId" value="15" />
                                                <input type="hidden" name="productName" value="Váy nữ" />
                                                <input type="hidden" name="attributes" value="" />
                                                <input type="hidden" name="price" value="280000" />
                                                <input type="hidden" name="quantity" value="1" />
                                                <input type="hidden" name="imageUrl" value="<%= ctx %>/uploads/product/prod15-main.jpg" />
                                                <button type="submit" class="icon-add-cart" title="Thêm vào giỏ"><i class="fa-solid fa-cart-plus"></i></button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="lydo" class="py-5">
                <div class="container">
                    <div class="row align-items-end mb-4">
                        <div class="col-12 col-lg-7">
                            <p class="text-uppercase text-secondary fw-bold small mb-2">Vì sao chọn chúng tôi</p>
                            <h2 class="section-title mb-2">Trải nghiệm mua sắm gọn, đẹp và đáng tin</h2>
                            <p class="section-lead mb-0">Trang chủ được thiết kế để vừa trông sang hơn, vừa giúp khách nhìn thấy giá trị của shop ngay từ giây đầu tiên.</p>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-12 col-md-4">
                            <div class="feature-card p-4">
                                <div class="feature-icon mb-3">
                                    <i class="fa-solid fa-wand-magic-sparkles"></i>
                                </div>
                                <h3 class="h5 fw-bold">Giao diện rõ ràng</h3>
                                <p class="text-secondary mb-0">Bố cục thoáng, nhấn mạnh hình ảnh và CTA để khách dễ ra quyết định.</p>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="feature-card p-4">
                                <div class="feature-icon mb-3">
                                    <i class="fa-solid fa-bag-shopping"></i>
                                </div>
                                <h3 class="h5 fw-bold">Mua sắm nhanh</h3>
                                <p class="text-secondary mb-0">Nút hành động nổi bật, phù hợp cả khách mới lẫn khách quay lại mua tiếp.</p>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="feature-card p-4">
                                <div class="feature-icon mb-3">
                                    <i class="fa-solid fa-truck-fast"></i>
                                </div>
                                <h3 class="h5 fw-bold">Tối ưu chuyển đổi</h3>
                                <p class="text-secondary mb-0">Nhấn mạnh lợi ích, giá và tính tiện dụng để tăng tỷ lệ bấm vào sản phẩm.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer class="py-4">
            <div class="container">
                <div class="soft-divider pt-4 d-flex flex-column flex-md-row justify-content-between align-items-center gap-3 footer">
                    <div>© 2026 Clothing Sale</div>
                    <div class="d-flex flex-wrap gap-3">
                        <a class="text-decoration-none text-secondary" href="<%= primaryHref %>"><%= primaryLabel %></a>
                        <a class="text-decoration-none text-secondary" href="<%= secondaryHref %>"><%= secondaryLabel %></a>
                    </div>
                </div>
            </div>
        </footer>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
