<%-- 
    Document   : users
    Created on : Oct 23, 2026, 11:59:24 AM
    Author     : Tinh Ba
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản - TechStore Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="ts-admin-body">
    <div class="ts-container ts-admin-container">
        
        <%-- Header Bar --%>
        <div class="ts-admin-header-bar">
            <div>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="ts-topbar-admin-badge">
                    &larr; Quay lại Dashboard
                </a>
                <h1 class="ts-admin-page-title">Quản lý tài khoản</h1>
            </div>
            <a href="${pageContext.request.contextPath}/admin/users?action=create" class="ts-btn-add">+ Thêm tài khoản</a>
        </div>

        <%-- Hiển thị thông báo --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="ts-alert ts-alert-success">
                ${sessionScope.successMessage}
                <c:remove var="successMessage" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="ts-alert ts-alert-danger">
                ${sessionScope.errorMessage}
                <c:remove var="errorMessage" scope="session"/>
            </div>
        </c:if>

        <%-- Toolbar: Tìm kiếm & Lọc --%>
        <div class="ts-admin-toolbar">
            <form action="${pageContext.request.contextPath}/admin/users" method="GET" class="ts-admin-filter-form">
                <div class="ts-admin-search-box">
                    <svg class="ts-icon" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                    <input type="text" name="search" placeholder="Tìm kiếm theo username, email..." value="${param.search}">
                </div>
                <div class="ts-admin-filter-selects">
                    <select name="role">
                        <option value="">Tất cả vai trò</option>
                        <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>Quản trị viên (ADMIN)</option>
                        <option value="CUSTOMER" ${param.role == 'CUSTOMER' ? 'selected' : ''}>Khách hàng (CUSTOMER)</option>
                    </select>
                    <button type="submit" class="ts-button-outline">Lọc dữ liệu</button>
                </div>
            </form>
        </div>

        <%-- Bảng Dữ liệu --%>
        <div class="ts-admin-table-container">
            <table class="ts-admin-table">
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Họ và tên</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th style="text-align: right;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <%-- Đã sửa thành listUsers --%>
                        <c:when test="${empty listUsers}">
                            <tr>
                                <td colspan="6" class="ts-table-empty">Không tìm thấy tài khoản nào.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <%-- Đã sửa thành listUsers --%>
                            <c:forEach var="u" items="${listUsers}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/users?action=edit&accountId=${u.accountId}" class="ts-table-product-name">
                                            ${u.username}
                                        </a>
                                    </td>
                                    <td>${u.fullname != null && u.fullname != '' ? u.fullname : '<span style="color:#a0aab8; font-size:12px;">Chưa cập nhật</span>'}</td>
                                    <td>${u.email}</td>
                                    <td>
                                        <span style="font-weight: 600; color: ${u.role == 'ADMIN' ? '#0757ce' : '#626b78'}">
                                            ${u.role}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.isActive}">
                                                <span class="ts-status-badge is-active">Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ts-status-badge is-inactive">Đã khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="ts-table-actions">
                                            <%-- Nút Chỉnh sửa --%>
                                            <a href="${pageContext.request.contextPath}/admin/users?action=edit&accountId=${u.accountId}" class="ts-action-btn ts-btn-edit" title="Chỉnh sửa">
                                                <svg class="ts-icon" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                            </a>
                                            
                                            <%-- Form Khóa / Mở Khóa Tài khoản --%>
                                            <form action="${pageContext.request.contextPath}/admin/users" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="toggleStatus">
                                                <!-- Tham số accountId và currentStatus gửi về doPost -->
                                                <input type="hidden" name="accountId" value="${u.accountId}">
                                                <input type="hidden" name="currentStatus" value="${u.isActive}">
                                                
                                                <button type="submit" class="ts-action-btn ts-btn-toggle" title="${u.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}" onclick="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái tài khoản này?');">
                                                    <c:choose>
                                                        <c:when test="${u.isActive}">
                                                            <svg class="ts-icon" viewBox="0 0 24 24"><path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <svg class="ts-icon" viewBox="0 0 24 24"><path d="M8 11V7a4 4 0 118 0m-4 8v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z"></path></svg>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>