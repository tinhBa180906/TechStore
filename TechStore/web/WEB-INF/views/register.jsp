<%-- 
    Document   : register
    Created on : Oct 23, 2026, 11:46:09 AM
    Author     : Tinh Ba
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng ký - TechStore</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
        <div class="auth-wrapper">
            <div class="login-card">
                <h2 class="login-title">Đăng ký tài khoản</h2>

                <%-- Bắt lỗi từ AuthServlet khi trùng Username hoặc Email --%>
                <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("errorMessage") %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/auth" method="POST">
                    <!-- Tham số ẩn để báo cho Servlet biết đây là luồng đăng ký -->
                    <input type="hidden" name="action" value="register">

                    <div class="form-group">
                        <label for="username" class="form-label">Tên đăng nhập</label>
                        <input type="text" id="username" name="username" required class="form-control" 
                               value="${param.username != null ? param.username : ''}">
                    </div>

                    <div class="form-group">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" id="email" name="email" required class="form-control"
                               value="${param.email != null ? param.email : ''}">
                    </div>

                    <div class="form-group">
                        <label for="fullname" class="form-label">Họ và tên</label>
                        <input type="text" id="fullname" name="fullname" required class="form-control"
                               value="${param.fullname != null ? param.fullname : ''}">
                    </div>

                    <div class="form-group">
                        <label for="phone" class="form-label">Số điện thoại</label>
                        <input type="text" id="phone" name="phone" required class="form-control"
                               value="${param.phone != null ? param.phone : ''}">
                    </div>

                    <div class="form-group">
                        <label for="defaultAddress" class="form-label">Địa chỉ</label>
                        <input type="text" id="defaultAddress" name="defaultAddress" required class="form-control"
                               value="${param.defaultAddress != null ? param.defaultAddress : ''}">
                    </div>

                    <div class="form-group">
                        <label for="password" class="form-label">Mật khẩu</label>
                        <input type="password" id="password" name="password" required class="form-control">
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Xác nhận mật khẩu</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required class="form-control">
                    </div>

                    <button type="submit" class="btn-primary">Đăng ký</button>
                </form>

                <div class="login-footer">
                    <span>Đã có tài khoản?</span>
                    <a href="${pageContext.request.contextPath}/login.jsp">Đăng nhập ngay</a>
                </div>
            </div>
        </div>
    </body>
</html>