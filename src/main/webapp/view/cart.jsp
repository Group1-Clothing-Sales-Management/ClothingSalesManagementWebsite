<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    java.util.Collection items = (java.util.Collection) request.getAttribute("items");
    jakarta.servlet.http.HttpSession sess = request.getSession(false);
    Object authId = sess != null ? sess.getAttribute("authUserId") : null;
    String role = sess != null && sess.getAttribute("authRoleName") != null ? sess.getAttribute("authRoleName").toString() : null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giỏ hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{background:#f8fafc;}</style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="<%= request.getContextPath() %>/">Clothing Sale</a>
            <div class="d-flex gap-2">
                <% if (authId != null && "CUSTOMER".equalsIgnoreCase(role)) { %>
                    <a class="btn btn-danger" href="<%= request.getContextPath() %>/customer/logout">Đăng xuất</a>
                <% } else { %>
                    <a class="btn btn-primary" href="<%= request.getContextPath() %>/customer/login">Đăng nhập</a>
                <% } %>
            </div>
        </div>
    </nav>

    <div class="container py-4">
        <h2 class="mb-4">Giỏ hàng của bạn</h2>
        <% if (items == null || items.isEmpty()) { %>
            <div class="text-center my-5">
                <div class="mb-3">
                    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="currentColor" class="bi bi-cart4 text-muted" viewBox="0 0 16 16">
                        <path d="M0 1.5A.5.5 0 0 1 .5 1h1a.5.5 0 0 1 .485.379L2.89 5H14.5a.5.5 0 0 1 .49.598l-1.5 6A.5.5 0 0 1 13 12H4a.5.5 0 0 1-.491-.408L1.01 2H.5a.5.5 0 0 1-.5-.5zM5 12a1 1 0 1 0 0 2 1 1 0 0 0 0-2zm7 1a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/>
                    </svg>
                </div>
                <h4 class="text-muted">Giỏ hàng trống</h4>
                <p class="text-muted">Bạn chưa có sản phẩm nào trong giỏ.
                </p>
                <a href="<%= request.getContextPath() %>/" class="btn btn-primary">Quay lại mua sắm</a>
            </div>
        <% } else { %>
            <div class="row">
                <div class="col-12 col-lg-8">
                    <div class="list-group">
                        <% java.math.BigDecimal total = java.math.BigDecimal.ZERO; %>
                        <% for (Object o : items) {
                               com.clothingsale.model.CartItem it = (com.clothingsale.model.CartItem) o;
                               java.math.BigDecimal price = it.getPrice() != null ? it.getPrice() : java.math.BigDecimal.ZERO;
                               int qty = it.getQuantity();
                               total = total.add(price.multiply(new java.math.BigDecimal(qty)));
                        %>
                        <div class="list-group-item d-flex gap-3 align-items-center">
                            <img src="<%= it.getImageUrl() != null ? it.getImageUrl() : (request.getContextPath()+"/uploads/product/placeholder.png") %>" alt="" style="width:80px;height:80px;object-fit:cover;border-radius:6px">
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <div class="fw-semibold"><%= it.getProductName() %></div>
                                        <div class="text-muted small"><%= it.getAttributes() %></div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-semibold">₫<%= price %></div>
                                        <div class="text-muted small">x <%= qty %></div>
                                    </div>
                                </div>
                                <div class="mt-2 d-flex gap-2">
                                    <form action="<%= request.getContextPath() %>/cart/update" method="post" class="d-flex" style="gap:8px;">
                                        <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                        <input type="number" name="quantity" value="<%= it.getQuantity() %>" min="0" style="width:80px" class="form-control form-control-sm">
                                        <button class="btn btn-sm btn-primary">Update</button>
                                    </form>
                                    <form action="<%= request.getContextPath() %>/cart/remove" method="post">
                                        <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                                        <button class="btn btn-sm btn-outline-danger">Remove</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <div class="col-12 col-lg-4">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between">
                            <div class="text-muted">Tổng</div>
                            <div class="fw-bold">₫<%= total %></div>
                        </div>
                        <div class="mt-3">
                            <a href="<%= request.getContextPath() %>/checkout" class="btn btn-primary w-100">Mua hàng</a>
                        </div>
                        <div class="mt-2">
                            <a href="<%= request.getContextPath() %>/" class="btn btn-link w-100">Tiếp tục mua sắm</a>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>
