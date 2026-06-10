<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String infoMessage = (String) request.getAttribute("infoMessage");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{padding:40px}</style>
</head>
<body>
<div class="container">
    <h2>Verify your account</h2>
    <% if (infoMessage != null) { %>
        <div class="alert alert-info"><%= infoMessage %></div>
    <% } %>
    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/customer/verify-otp" method="post">
        <div class="mb-3">
            <label>Verification code</label>
            <input class="form-control" name="code" required>
        </div>
        <button class="btn btn-primary">Verify</button>
    </form>
    <form action="<%= request.getContextPath() %>/customer/resend-otp" method="post" style="margin-top:12px">
        <button class="btn btn-link">Resend code</button>
    </form>

    <% if (request.getAttribute("devOtp") != null) { %>
        <div class="mt-3 alert alert-warning">Dev OTP (visible for development): <strong><%= request.getAttribute("devOtp") %></strong></div>
    <% } %>
</div>
</body>
</html>
