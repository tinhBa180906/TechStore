<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý đơn hàng | TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-orders.css?v=1"><link rel="stylesheet" href="${pageContext.request.contextPath}/css/order-experience.css?v=1"></head>
<body class="orders-page admin-orders-page">
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
        <symbol id="icon-check-circle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
        </symbol>
        <symbol id="icon-refresh" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>
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
                <a href="${pageContext.request.contextPath}/orders">
                    <svg class="nav-icon"><use href="#icon-orders"/></svg> Đơn hàng của tôi
                </a>
            </c:if>
            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/orders" class="is-active">
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
        <span class="current">Quản lý đơn hàng</span>
    </div>

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <span class="admin-eyebrow">TECHSTORE / QUẢN TRỊ</span><h1 class="page-title">Quản lý đơn hàng</h1>
            <p class="page-subtitle">Theo dõi đơn hàng, kiểm tra thông tin và xử lý ngay tại một nơi.</p>
        </div>
    </div>

    <!-- Error Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error" role="alert">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
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
                <p>Chưa có đơn hàng nào trong hệ thống</p>
            </div>
        </div>
    </c:if>

<section class="admin-toolbar" aria-label="Tìm kiếm và lọc đơn hàng">
<div class="admin-filter-tabs" role="group" aria-label="Lọc trạng thái">
<button type="button" class="selected" data-filter="ALL" aria-pressed="true">Tất cả <span>0</span></button>
<button type="button" data-filter="PENDING" aria-pressed="false">Chờ xác nhận <span>0</span></button>
<button type="button" data-filter="CONFIRMED" aria-pressed="false">Đã xác nhận <span>0</span></button>
<button type="button" data-filter="COMPLETED" aria-pressed="false">Hoàn tất <span>0</span></button>
<button type="button" data-filter="CANCELLED" aria-pressed="false">Đã hủy <span>0</span></button>
</div>
<div class="admin-search-row"><label class="admin-search"><span aria-hidden="true">⌕</span><input type="search" id="order-search" placeholder="Tìm mã đơn, người nhận, số điện thoại…" aria-label="Tìm đơn hàng"></label><span id="order-result-count" role="status" aria-live="polite"></span></div>
</section>
<div id="order-no-results" class="admin-no-results" hidden><strong>Không tìm thấy đơn hàng phù hợp</strong><p>Thử từ khóa khác hoặc chọn trạng thái khác.</p><button type="button" id="reset-order-filter" class="btn btn-outline">Xóa bộ lọc</button></div>
    <c:forEach items="${orders}" var="order">
        <article class="order-card" data-order-status="${order.orderStatus}" data-order-id="${order.orderId}">
            <div class="order-card-header">
                <div style="display:flex; align-items:center; gap:16px; flex-wrap:wrap;">
                    <span class="order-id">Đơn #${order.orderId}</span>
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
                        <svg><use href="#icon-user"/></svg> Khách #${order.customerId}
                    </span>
                    <span class="order-meta-item">
                        <svg><use href="#icon-calendar"/></svg> <c:out value="${order.dateCreated}"/>
                    </span>
                </div>
            </div>
<div class="admin-order-preview"><div><span>NGƯỜI NHẬN</span><strong><c:out value="${order.shippingName}"/></strong></div><div><span>ĐIỆN THOẠI</span><strong><c:out value="${order.shippingPhone}"/></strong></div><div class="admin-preview-address"><span>ĐỊA CHỈ GIAO HÀNG</span><strong><c:out value="${order.shippingAddress}"/></strong></div><div><span>THANH TOÁN</span><strong>COD</strong></div></div>
<details class="admin-order-details"><summary><span>Xem sản phẩm &amp; chi tiết đơn hàng</span><span class="admin-details-chevron" aria-hidden="true">⌄</span></summary>
<div class="order-card-body">
                <!-- Shipping Info -->
                <div class="order-shipping">
                    <div>
                        <div class="order-shipping-label">Người nhận</div>
                        <div class="order-shipping-value"><c:out value="${order.shippingName}"/></div>
                    </div>
                    <div>
                        <div class="order-shipping-label">Số điện thoại</div>
                        <div class="order-shipping-value"><c:out value="${order.shippingPhone}"/></div>
                    </div>
                    <div>
                        <div class="order-shipping-label">Địa chỉ</div>
                        <div class="order-shipping-value"><c:out value="${order.shippingAddress}"/></div>
                    </div>
                    <div>
                        <div class="order-shipping-label">Thanh toán</div>
                        <div class="order-shipping-value">COD</div>
                    </div>
                </div>
                <c:if test="${not empty order.completeAt}">
                    <div class="alert alert-success" style="margin-bottom: 18px;">
                        <svg width="18" height="18"><use href="#icon-check-circle"/></svg>
                        Hoàn tất lúc: <c:out value="${order.completeAt}"/>
                    </div>
                </c:if>

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
</details><div class="order-card-footer">
                <div class="order-total">
                    <span>Tổng cộng:</span> <fmt:formatNumber value="${order.totalAmount}" type="number"/> ₫
                </div>

                <!-- Status Update Form -->
                <c:if test="${order.orderStatus == 'PENDING' or order.orderStatus == 'CONFIRMED'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/orders" class="status-update-form">
                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                        <input type="hidden" name="orderId" value="${order.orderId}">
<c:if test="${order.orderStatus == 'PENDING'}">
<button type="submit" name="status" value="CANCELLED" class="btn admin-cancel" onclick="return confirm('Hủy đơn #${order.orderId} và hoàn lại số lượng sản phẩm vào kho?');">Hủy đơn</button>
<button type="submit" name="status" value="CONFIRMED" class="btn btn-primary"><svg width="16" height="16"><use href="#icon-check-circle"/></svg> Xác nhận đơn</button>
</c:if>
<c:if test="${order.orderStatus == 'CONFIRMED'}">
<button type="submit" name="status" value="COMPLETED" class="btn btn-primary" onclick="return confirm('Xác nhận đơn #${order.orderId} đã giao và thanh toán đầy đủ?');"><svg width="16" height="16"><use href="#icon-check-circle"/></svg> Đánh dấu hoàn tất</button>
</c:if>                    </form>
                </c:if>
            </div>
        </article></c:forEach></div>

<!-- Footer -->
<div class="ts-container">
    <div class="module-footer">
        TechStore · Dự án PRJ301 · FPT University · Nhóm 1
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/admin-orders.js?v=1" defer></script></body>
</html>
