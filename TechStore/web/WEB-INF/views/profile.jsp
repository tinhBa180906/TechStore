<%-- 
    Document   : profile
    Created on : Oct 23, 2026, 11:47:11 AM
    Author     : Tinh Ba
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân - TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Bao bọc nội dung bằng profile-wrapper -->
    <div class="profile-wrapper">
        <div class="profile-card">
            <div class="profile-header">
                <h2>Thông tin tài khoản</h2>
                <p>Quản lý thông tin cá nhân và địa chỉ giao hàng của bạn</p>
            </div>

            <%-- Thông báo khi cập nhật thành công hoặc thất bại --%>
            <% if (request.getAttribute("message") != null) { %>
                <div class="alert alert-success">
                    <%= request.getAttribute("message") %>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/update-profile" method="POST">
                <div class="form-row-2">
                    <div class="form-group">
                        <label class="form-label">Tên đăng nhập</label>
                        <input type="text" class="form-control" value="${sessionScope.user.username}" disabled>
                        <small class="form-hint">Tên đăng nhập không thể thay đổi</small>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" value="${sessionScope.user.email}" disabled>
                        <small class="form-hint">Email không thể thay đổi</small>
                    </div>
                </div>

                <div class="form-group">
                    <label for="fullname" class="form-label">Họ và tên</label>
                    <input type="text" id="fullname" name="fullname" class="form-control" 
                           value="${sessionScope.user.fullname}" required>
                </div>

                <div class="form-group">
                    <label for="phone" class="form-label">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" class="form-control" 
                           value="${sessionScope.user.phone}" required>
                </div>

                <div class="form-group">
                    <label for="defaultAddress" class="form-label">Địa chỉ giao hàng mặc định</label>
                    <input type="text" id="defaultAddress" name="defaultAddress" class="form-control" 
                           value="${sessionScope.user.defaultAddress}" required>
                </div>

                <div class="profile-actions">
                    <button type="submit" class="btn-primary" style="width: auto;">Lưu thay đổi</button>
                    <a href="${pageContext.request.contextPath}/home" class="btn-outline">Quay lại trang chủ</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>