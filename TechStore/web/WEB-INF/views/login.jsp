<%-- 
    Document   : login
    Created on : Oct 23, 2026, 11:45:24 AM
    Author     : Tinh Ba
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - TechStore</title>
    <!-- Nhúng file style.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="login-card">
        <h2 class="login-title">Đăng nhập TechStore</h2>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <% if ("1".equals(request.getParameter("success"))) { %>
            <div class="alert alert-success">
                Đăng ký thành công! Vui lòng đăng nhập.
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/auth" method="POST">
            <input type="hidden" name="action" value="login">
            
            <div class="form-group">
                <label for="username" class="form-label">Tên đăng nhập</label>
                <input type="text" id="username" name="username" required class="form-control">
            </div>
            
            <div class="form-group">
                <label for="password" class="form-label">Mật khẩu</label>
                <input type="password" id="password" name="password" required class="form-control">
            </div>
            
            <button type="submit" class="btn-primary">Đăng nhập</button>
        </form>
        
        <div class="login-footer">
            <span>Chưa có tài khoản?</span>
            <a href="${pageContext.request.contextPath}/register.jsp">Đăng ký ngay</a>
        </div>
    </div>
</body>
</html>