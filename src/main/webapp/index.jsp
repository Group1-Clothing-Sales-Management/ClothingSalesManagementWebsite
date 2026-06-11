<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    jakarta.servlet.http.HttpSession sess = request.getSession(false);
    Object authId = sess != null ? sess.getAttribute("authUserId") : null;
    String role = sess != null && sess.getAttribute("authRoleName") != null ? sess.getAttribute("authRoleName").toString() : null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clothing Sale - Trang chủ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{background:#f8fafc}</style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="<%= request.getContextPath() %>/">Clothing Sale</a>
            <div class="d-flex gap-2">
                <% if (authId != null && "CUSTOMER".equalsIgnoreCase(role)) { %>
                    <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/cart">Giỏ hàng</a>
                    <a class="btn btn-danger" href="<%= request.getContextPath() %>/customer/logout">Đăng xuất</a>
                <% } else { %>
                    <a class="btn btn-primary" href="<%= request.getContextPath() %>/customer/login">Đăng nhập</a>
                <% } %>
            </div>
        </div>
    </nav>

    <main class="container py-5">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h1 class="h3">Sản phẩm nổi bật</h1>
            <a href="<%= request.getContextPath() %>/cart" class="btn btn-outline-secondary">Giỏ hàng</a>
        </div>

        <div class="row gy-4">
            <!-- Example product cards with add-to-cart forms -->
            <div class="col-6 col-md-4 col-lg-3">
                <div class="card h-100">
                    <img src="uploads/product/placeholder.png" class="card-img-top" alt="Product">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">Áo thun basic</h5>
                        <p class="card-text text-muted">Mô tả ngắn về sản phẩm.</p>
                        <form action="<%= request.getContextPath() %>/cart/add" method="post" class="mt-auto d-flex justify-content-between align-items-center">
                            <input type="hidden" name="variantId" value="101">
                            <input type="hidden" name="productId" value="10">
                            <input type="hidden" name="productName" value="Áo thun basic">
                            <input type="hidden" name="attributes" value="M,L,XL">
                            <input type="hidden" name="price" value="150000">
                            <input type="hidden" name="imageUrl" value="uploads/product/placeholder.png">
                            <strong>₫150,000</strong>
                            <button class="btn btn-sm btn-primary">Mua</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Duplicate / other product cards -->
            <div class="col-6 col-md-4 col-lg-3">
                <div class="card h-100">
                    <img src="uploads/product/placeholder.png" class="card-img-top" alt="Product">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">Quần jeans</h5>
                        <p class="card-text text-muted">Mô tả ngắn về sản phẩm.</p>
                        <form action="<%= request.getContextPath() %>/cart/add" method="post" class="mt-auto d-flex justify-content-between align-items-center">
                            <input type="hidden" name="variantId" value="102">
                            <input type="hidden" name="productId" value="11">
                            <input type="hidden" name="productName" value="Quần jeans">
                            <input type="hidden" name="attributes" value="32,34">
                            <input type="hidden" name="price" value="350000">
                            <input type="hidden" name="imageUrl" value="uploads/product/placeholder.png">
                            <strong>₫350,000</strong>
                            <button class="btn btn-sm btn-primary">Mua</button>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <footer class="bg-light py-4 mt-auto">
        <div class="container text-center text-muted">&copy; 2026 Clothing Sale</div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
