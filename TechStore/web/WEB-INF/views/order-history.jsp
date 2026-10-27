<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử mua hàng | TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/order-experience.css?v=1"></head>
<body class="orders-page history-page">
<fmt:setLocale value="vi_VN"/>

<!-- SVG Symbols -->
<svg style="display:none" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <symbol id="icon-cart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
            <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
        </symbol>
        <symbol id="icon-orders" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2"/>
            <path d="M9 7h6M9 11h6M9 15h4"/>
        </symbol>
        <symbol id="icon-home" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
        </symbol>
        <symbol id="icon-dashboard" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/>
            <rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/>
        </symbol>
        <symbol id="icon-admin-orders" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M16 3h5v5M4 20 21 3M21 16v5h-5M15 15l6 6M4 4l5 5"/>
        </symbol>
        <symbol id="icon-calendar" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
        </symbol>
        <symbol id="icon-user" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
        </symbol>
        <symbol id="icon-map-pin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
        </symbol>
        <symbol id="icon-phone" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
        </symbol>
        <symbol id="icon-x-circle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
        </symbol>
    </defs>
</svg>

<!-- Header -->
<header class="ts-header">
    <div class="ts-container ts-header-inner">
        <a class="ts-logo" href="${pageContext.request.contextPath}/home">
            <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true">
                <path d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
            </svg>
            <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
        </a>
        <nav class="module-nav" aria-label="Điều hướng module">
            <a href="${pageContext.request.contextPath}/home">
                <svg class="nav-icon"><use href="#icon-home"/></svg> Trang chủ
            </a>
            <a href="${pageContext.request.contextPath}/cart">
                <svg class="nav-icon"><use href="#icon-cart"/></svg> Giỏ hàng
            </a>
            <c:if test="${sessionScope.user.role == 'CUSTOMER'}">
                <a href="${pageContext.request.contextPath}/orders" class="is-active">
                    <svg class="nav-icon"><use href="#icon-orders"/></svg> Đơn hàng của tôi
                </a>
            </c:if>
            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/orders">
                    <svg class="nav-icon"><use href="#icon-admin-orders"/></svg> Quản lý đơn hàng
                </a>
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <svg class="nav-icon"><use href="#icon-dashboard"/></svg> Thống kê
                </a>
            </c:if>
        </nav>
    </div>
</header>

<div class="ts-container">
    <!-- Breadcrumbs -->
    <div class="breadcrumbs">
        <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
        <span class="sep">›</span>
        <span class="current">Đơn hàng của tôi</span>
    </div>

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <span class="experience-eyebrow">TÀI KHOẢN / LỊCH SỬ MUA HÀNG</span><h1 class="page-title">Đơn hàng của tôi</h1>
            <c:if test="${not empty orders}">
                <p class="page-subtitle">Theo dõi trạng thái và lịch sử mua hàng</p>
            </c:if>
        </div>
    </div>

    <!-- Error Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error" role="alert">
            <svg width="18" height="18"><use href="#icon-x-circle"/></svg>
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <!-- Empty State -->
    <c:if test="${empty orders and empty errorMessage}">
        <div class="card">
            <div class="empty-state">
                <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="18" height="18" rx="2"/>
                    <path d="M9 7h6M9 11h6M9 15h4"/>
                </svg>
                <p>Bạn chưa có đơn hàng nào</p>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Bắt đầu mua sắm</a>
            </div>
        </div>
    </c:if>

<c:if test="${not empty orders}">
<section class="history-toolbar" aria-label="Tìm và lọc đơn hàng">
<div class="history-filters" role="group" aria-label="Trạng thái đơn hàng">
<button type="button" data-history-filter="ALL" aria-pressed="true" class="selected">Tất cả <span>0</span></button>
<button type="button" data-history-filter="PENDING" aria-pressed="false">Chờ xác nhận <span>0</span></button>
<button type="button" data-history-filter="CONFIRMED" aria-pressed="false">Đã xác nhận <span>0</span></button>
<button type="button" data-history-filter="COMPLETED" aria-pressed="false">Hoàn tất <span>0</span></button>
<button type="button" data-history-filter="CANCELLED" aria-pressed="false">Đã hủy <span>0</span></button>
</div>
<div class="history-search-row"><input type="search" id="history-search" aria-label="Tìm mã đơn hoặc tên sản phẩm" placeholder="Tìm mã đơn hoặc tên sản phẩm…"><span id="history-result" role="status" aria-live="polite"></span></div>
</section>
<div class="history-no-results" id="history-no-results" hidden><h2>Không tìm thấy đơn phù hợp</h2><p>Thử tên sản phẩm, mã đơn hoặc chọn trạng thái khác.</p><button type="button" class="btn btn-outline" id="history-reset">Xóa bộ lọc</button></div>
</c:if>
    <c:forEach items="${orders}" var="order">
        <div class="order-card" data-history-status="${order.orderStatus}">
            <div class="order-card-header">
                <div style="display:flex; align-items:center; gap:16px; flex-wrap:wrap;">
                    <span class="order-id">Đơn hàng #${order.orderId}</span>
                    <c:choose>
                        <c:when test="${order.orderStatus == 'PENDING'}"><span class="status-badge status-pending">Chờ xác nhận</span></c:when>
                        <c:when test="${order.orderStatus == 'CONFIRMED'}"><span class="status-badge status-confirmed">Đã xác nhận</span></c:when>
                        <c:when test="${order.orderStatus == 'COMPLETED'}"><span class="status-badge status-completed">Hoàn tất</span></c:when>
                        <c:when test="${order.orderStatus == 'CANCELLED'}"><span class="status-badge status-cancelled">Đã hủy</span></c:when>
                        <c:otherwise><span class="status-badge" style="background:var(--ts-surface);color:var(--ts-muted);"><c:out value="${order.orderStatus}"/></span></c:otherwise>
                    </c:choose>
                </div>
                <div class="order-meta">
                    <span class="order-meta-item">
                        <svg><use href="#icon-calendar"/></svg> <c:out value="${order.dateCreated}"/>
                    </span>
                </div>
            </div>
<div class="history-order-guide">
<c:choose>
<c:when test="${order.orderStatus == 'PENDING'}"><span class="history-stage">01 / CHỜ XÁC NHẬN</span><p>Đơn hàng đã được ghi nhận. Bạn có thể hủy trước khi được xác nhận.</p></c:when>
<c:when test="${order.orderStatus == 'CONFIRMED'}"><span class="history-stage">02 / ĐÃ XÁC NHẬN</span><p>TechStore đã xác nhận đơn hàng của bạn.</p></c:when>
<c:when test="${order.orderStatus == 'COMPLETED'}"><span class="history-stage">03 / HOÀN TẤT</span><p>Cảm ơn bạn đã mua sắm tại TechStore.</p></c:when>
<c:otherwise><span class="history-stage">ĐƠN HÀNG ĐÃ HỦY</span><p>Bạn có thể tiếp tục khám phá sản phẩm tại cửa hàng.</p></c:otherwise>
</c:choose>
</div>
<details class="history-details"><summary>Thông tin giao hàng <span aria-hidden="true">⌄</span></summary><div class="order-shipping">
<div><span class="order-shipping-label">Người nhận</span><div class="order-shipping-value"><c:out value="${order.shippingName}"/></div></div>
<div><span class="order-shipping-label">Điện thoại</span><div class="order-shipping-value"><c:out value="${order.shippingPhone}"/></div></div>
<div><span class="order-shipping-label">Địa chỉ</span><div class="order-shipping-value"><c:out value="${order.shippingAddress}"/></div></div>
<div><span class="order-shipping-label">Thanh toán</span><div class="order-shipping-value">COD</div></div>
</div></details>
<div class="order-card-body">
                <!-- Order Details Table -->
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th style="text-align:center;">Số lượng</th>
                                <th style="text-align:right;">Giá lúc mua</th>
                                <th style="text-align:right;">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${order.details}" var="detail">
                                <tr>
                                    <td class="td-product-name"><c:out value="${detail.product.productName}"/></td>
                                    <td style="text-align:center;">${detail.quantity}</td>
                                    <td class="td-price" style="text-align:right;"><fmt:formatNumber value="${detail.unitPrice}" type="number"/> ₫</td>
                                    <td class="td-price" style="text-align:right;"><fmt:formatNumber value="${detail.unitPrice * detail.quantity}" type="number"/> ₫</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="order-card-footer">
                <div class="order-total">
                    <span>Tổng cộng:</span> <fmt:formatNumber value="${order.totalAmount}" type="number"/> ₫
                </div>
                <c:if test="${order.orderStatus == 'PENDING'}">
                    <form method="post" action="${pageContext.request.contextPath}/orders" style="display:inline;">
                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Bạn có chắc muốn hủy đơn hàng #${order.orderId}?')">
                            <svg width="14" height="14"><use href="#icon-x-circle"/></svg> Hủy đơn hàng
                        </button>
                    </form>
                </c:if>
            </div>
        </div>
    </c:forEach>
</div>

<!-- Footer -->
<div class="ts-container">
    <div class="module-footer">
        TechStore · Dự án PRJ301 · FPT University · Nhóm 1
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/order-experience.js?v=1" defer></script></body>
</html>
