<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) request.getAttribute("username");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{padding:40px}</style>
</head>
<body>
<div class="container">
    <h2>Create account</h2>
    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } %>
    <form action="<%= request.getContextPath() %>/customer/register" method="post">
        <div class="mb-3">
            <label>Username</label>
            <input class="form-control" name="username" value="<%= username != null ? username : "" %>" required>
        </div>
        <div class="mb-3">
            <label>Password</label>
            <input type="password" class="form-control" name="password" required>
        </div>
        <div class="mb-3">
            <label>Full name</label>
            <input class="form-control" name="fullName" required>
        </div>
        <div class="mb-3">
            <label>Email</label>
            <input type="email" class="form-control" name="email" required>
        </div>
        <div class="mb-3">
            <label>Phone</label>
            <input class="form-control" name="phone">
        </div>
        <button class="btn btn-primary">Register</button>
        <a class="btn btn-link" href="<%= request.getContextPath() %>/customer/login">Sign in</a>
    </form>
</div>
</body>
</html>
