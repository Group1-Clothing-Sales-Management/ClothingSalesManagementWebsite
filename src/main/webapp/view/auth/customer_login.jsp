<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{padding:40px}</style>
</head>
<body>
<div class="container">
    <h2>Customer Sign in</h2>
    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } %>
    <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
    <% } %>
    <form action="<%= request.getContextPath() %>/customer/login" method="post">
        <div class="mb-3">
            <label>Username or email</label>
            <input class="form-control" name="username" required>
        </div>
        <div class="mb-3">
            <label>Password</label>
            <input type="password" class="form-control" name="password" required>
        </div>
        <button class="btn btn-primary">Sign in</button>
        <a class="btn btn-link" href="<%= request.getContextPath() %>/customer/register">Register</a>
    </form>
</div>
</body>
</html>
