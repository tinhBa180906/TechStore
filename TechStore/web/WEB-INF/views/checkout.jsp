<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng | TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/order-experience.css?v=1"></head>
<body class="orders-page checkout-page">
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
        <symbol id="icon-shield" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Z"/>
            <path d="m8 12 3 3 5-6"/>
        </symbol>
        <symbol id="icon-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12"/>
        </symbol>
        <symbol id="icon-info" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/>
            <path d="M12 16v-4m0-4h.01"/>
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
        <a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
        <span class="sep">›</span>
        <span class="current">Đặt hàng</span>
    </div>

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <span class="experience-eyebrow">HOÀN TẤT LỰA CHỌN CỦA BẠN</span><h1 class="page-title">Thông tin đặt hàng</h1>
            <p class="page-subtitle">Kiểm tra đơn hàng và điền thông tin giao hàng</p>
        </div>
    </div>

<nav class="purchase-steps" aria-label="Tiến trình đặt hàng"><a href="${pageContext.request.contextPath}/cart"><span>01</span> Giỏ hàng</a><strong aria-current="step"><span>02</span> Thông tin đặt hàng</strong><span class="purchase-step-last"><span>03</span> Hoàn tất</span></nav>
<!-- Error Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error" role="alert">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty cartItems}">
            <div class="card">
                <div class="empty-state">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
                        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
                    </svg>
                    <p>Giỏ hàng đang trống</p>
                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline">Quay lại giỏ hàng</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="checkout-layout">
                <!-- Left: Shipping Form -->
                <div>
                    <div class="checkout-form-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <svg width="20" height="20" style="vertical-align: -3px; margin-right: 6px;"><use href="#icon-shield"/></svg>
                                Thông tin giao hàng
                            </h2>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/checkout">
                            <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                            <div class="form-group">
                                <label class="form-label" for="shippingName">Họ tên người nhận <span class="required-mark">*</span></label>
                                <input id="shippingName" name="shippingName" required minlength="2" maxlength="100" autocomplete="name" class="form-control" placeholder="Nhập họ tên đầy đủ" value="<c:out value='${param.shippingName}'/>">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="shippingPhone">Số điện thoại <span class="required-mark">*</span></label>
                                <input id="shippingPhone" name="shippingPhone" type="tel" required minlength="8" maxlength="15" autocomplete="tel" class="form-control" placeholder="VD: 0912 345 678" value="<c:out value='${param.shippingPhone}'/>">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="shippingAddress">Địa chỉ nhận hàng <span class="required-mark">*</span></label>
                                <textarea id="shippingAddress" name="shippingAddress" required maxlength="255" rows="3" autocomplete="street-address" class="form-control" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố"><c:out value="${param.shippingAddress}"/></textarea>
                            </div>
                            <div class="checkout-payment-note">
                                <svg><use href="#icon-info"/></svg>
                                <div><strong>Thanh toán khi nhận hàng (COD)</strong><span>Kiểm tra thông tin giao hàng trước khi xác nhận đơn.</span></div>
                            </div>
                            <button type="submit" class="btn btn-primary" style="width:100%; padding: 14px;">
                                <svg width="18" height="18"><use href="#icon-check"/></svg> Xác nhận đặt hàng
                            </button>
<p class="checkout-submit-hint">Đơn hàng sẽ được gửi đến TechStore sau khi bạn xác nhận.</p></form>
                    </div>
                </div>

                <!-- Right: Order Summary -->
                <div>
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Tóm tắt đơn hàng</h2>
                            <span class="form-hint">${cartItems.size()} sản phẩm</span>
                        </div>
                        <div class="checkout-items">
                            <c:forEach items="${cartItems}" var="item">
                                <div class="checkout-item">
                                    <span class="checkout-item-name"><c:out value="${item.product.productName}"/></span>
                                    <span class="checkout-item-qty">× ${item.quantity}</span>
                                    <span class="checkout-item-price"><fmt:formatNumber value="${item.subtotal}" type="number"/> ₫</span>
                                </div>
                            </c:forEach>
                        </div>
                        <a class="experience-back-link" href="${pageContext.request.contextPath}/cart">← Chỉnh sửa giỏ hàng</a><div class="checkout-total-box">
                            <div class="checkout-total-row is-total">
                                <span>Tổng cộng</span>
                                <span><fmt:formatNumber value="${cartTotal}" type="number"/> ₫</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Footer -->
<div class="ts-container">
    <div class="module-footer">
        TechStore · Dự án PRJ301 · FPT University · Nhóm 1
    </div>
</div>

</body>
</html>
