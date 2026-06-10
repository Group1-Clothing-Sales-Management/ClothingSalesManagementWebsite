<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    java.util.Collection items = (java.util.Collection) request.getAttribute("items");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Cart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{padding:24px}</style>
</head>
<body>
<div class="container">
    <h2>Your Cart</h2>
    <% if (items == null || items.isEmpty()) { %>
        <div class="alert alert-info">Your cart is empty.</div>
    <% } %>

    <table class="table">
        <thead>
            <tr><th>Product</th><th>Attributes</th><th>Price</th><th>Quantity</th><th>Action</th></tr>
        </thead>
        <tbody>
        <% if (items != null) {
            for (Object o : items) {
                com.clothingsale.model.CartItem it = (com.clothingsale.model.CartItem) o;
        %>
            <tr>
                <td><%= it.getProductName() %></td>
                <td><%= it.getAttributes() %></td>
                <td><%= it.getPrice() != null ? it.getPrice() : "0" %></td>
                <td>
                    <form action="<%= request.getContextPath() %>/cart/update" method="post" style="display:inline-block">
                        <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                        <input type="number" name="quantity" value="<%= it.getQuantity() %>" min="0" style="width:80px"/>
                        <button class="btn btn-sm btn-primary">Update</button>
                    </form>
                </td>
                <td>
                    <form action="<%= request.getContextPath() %>/cart/remove" method="post" style="display:inline-block">
                        <input type="hidden" name="variantId" value="<%= it.getVariantId() %>">
                        <button class="btn btn-sm btn-danger">Remove</button>
                    </form>
                </td>
            </tr>
        <%   }
        } %>
        </tbody>
    </table>
    <a href="<%= request.getContextPath() %>/" class="btn btn-link">Continue shopping</a>
</div>
</body>
</html>
