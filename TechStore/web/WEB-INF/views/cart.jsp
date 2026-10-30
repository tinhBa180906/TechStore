<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Giỏ hàng | TechStore</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cart.css?v=1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/order-experience.css?v=1"></head>
    <body class="orders-page cart-page">
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
    <symbol id="icon-bag" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M5 8h14l1 13H4L5 8Z"/>
        <path d="M8 8V6a4 4 0 0 1 8 0v2"/>
    </symbol>
    <symbol id="icon-trash" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="3 6 5 6 21 6"/>
        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
    </symbol>
    <symbol id="icon-plus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 5v14M5 12h14"/>
    </symbol>
    <symbol id="icon-arrow-right" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M5 12h14m-5-5 5 5-5 5"/>
    </symbol>
    <symbol id="icon-empty" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
        <line x1="1" y1="1" x2="23" y2="23" stroke-width="2"/>
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
                <a href="${pageContext.request.contextPath}/cart" class="is-active">
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

    <main class="ts-container cart-main">
        <nav class="breadcrumbs" aria-label="Đường dẫn"><a href="${pageContext.request.contextPath}/home">Trang chủ</a><span class="sep">/</span><span class="current">Giỏ hàng</span></nav>
        <div class="cart-heading">
            <div><span class="cart-eyebrow">TECHSTORE / GIỎ HÀNG CỦA BẠN</span><h1>Giỏ hàng<span class="cart-count">${cartItems.size()}</span></h1><p>Kiểm tra lựa chọn của bạn trước khi đặt hàng.</p></div>
            <ol class="cart-steps" aria-label="Các bước đặt hàng"><li class="active" aria-current="step"><span>01</span> Giỏ hàng</li><li><span>02</span> Đặt hàng</li><li><span>03</span> Hoàn tất</li></ol>
        </div>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error" role="alert"><c:out value="${errorMessage}"/></div></c:if>
        <c:choose>
            <c:when test="${empty cartItems}">
                <section class="cart-empty">
                    <div class="cart-empty-art" aria-hidden="true"><svg><use href="#icon-bag"/></svg><span>0</span></div>
                    <span class="cart-eyebrow">SẴN SÀNG CHO NÂNG CẤP TIẾP THEO?</span>
                    <h2>Giỏ hàng của bạn đang trống</h2>
                    <p>Khám phá sản phẩm công nghệ yêu thích và chọn món đồ phù hợp với bạn.</p>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Khám phá sản phẩm <svg width="18" height="18"><use href="#icon-arrow-right"/></svg></a>
                    <div class="cart-empty-note">Sản phẩm bạn chọn sẽ xuất hiện tại đây.</div>
                </section>
            </c:when>
            <c:otherwise>
                <div class="cart-layout">
                    <section class="cart-products" aria-labelledby="cart-products-title">
                        <div class="cart-section-heading"><h2 id="cart-products-title">Sản phẩm đã chọn</h2><span>${cartItems.size()} sản phẩm</span></div>
                        <c:forEach items="${cartItems}" var="item">
                            <article class="cart-product">
                                <a class="cart-product-visual" href="${pageContext.request.contextPath}/product-detail?id=${item.product.productId}" aria-label="Xem sản phẩm">
                                    <svg width="38" height="38" aria-hidden="true"><use href="#icon-bag"/></svg>
                                </a>
                                <div class="cart-product-info">
                                    <span class="cart-product-code">TECHSTORE · #${item.product.productId}</span>
                                    <a class="cart-product-name" href="${pageContext.request.contextPath}/product-detail?id=${item.product.productId}"><c:out value="${item.product.productName}"/></a>
                                    <p class="cart-unit-price">Đơn giá: <fmt:formatNumber value="${item.product.price}" type="number"/> ₫</p>
                                    <form method="post" action="${pageContext.request.contextPath}/cart" class="cart-quantity-form">
                                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="action" value="update"><input type="hidden" name="productId" value="${item.product.productId}">
                                        <div class="qty-group">
                                            <button type="button" class="qty-btn" aria-label="Giảm số lượng" ${item.quantity == 1 ? 'disabled' : ''} onclick="this.parentNode.querySelector('input').stepDown(); this.form.requestSubmit();">−</button>
                                            <input aria-label="Số lượng sản phẩm" type="number" name="quantity" value="${item.quantity}" min="1" required>
                                            <button type="button" class="qty-btn" aria-label="Tăng số lượng" onclick="this.parentNode.querySelector('input').stepUp(); this.form.requestSubmit();">+</button>
                                        </div>
                                        <button type="submit" class="cart-update">Cập nhật</button>
                                    </form>
                                </div>
                                <div class="cart-product-end"><strong><fmt:formatNumber value="${item.subtotal}" type="number"/> ₫</strong>
                                    <form method="post" action="${pageContext.request.contextPath}/cart">
                                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="action" value="remove"><input type="hidden" name="productId" value="${item.product.productId}">
                                        <button type="submit" class="cart-remove"><svg width="15" height="15"><use href="#icon-trash"/></svg> Xóa</button>
                                    </form>
                                </div>
                            </article>
                        </c:forEach>
                        <a class="cart-continue" href="${pageContext.request.contextPath}/home">← Tiếp tục mua sắm</a>
                    </section>
                    <aside class="cart-order-summary" aria-labelledby="cart-summary-title">
                        <span class="cart-eyebrow">ĐƠN HÀNG CỦA BẠN</span><h2 id="cart-summary-title">Tóm tắt giỏ hàng</h2>
                        <div class="cart-summary-line"><span>Sản phẩm</span><strong>${cartItems.size()}</strong></div>
                        <div class="cart-summary-line"><span>Tạm tính</span><strong><fmt:formatNumber value="${cartTotal}" type="number"/> ₫</strong></div>
                        <div class="cart-total"><span>Tổng tạm tính</span><strong><fmt:formatNumber value="${cartTotal}" type="number"/> ₫</strong></div>
                        <p class="cart-summary-note">Giá và tình trạng sản phẩm sẽ được xác nhận khi đặt hàng.</p>
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary cart-checkout">
                                    Tiến hành đặt hàng <svg width="18" height="18"><use href="#icon-arrow-right"/></svg>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary cart-checkout">
                                    Đăng nhập để đặt hàng <svg width="18" height="18"><use href="#icon-arrow-right"/></svg>
                                </a>
                                <p class="cart-login-note">Bạn cần <a href="${pageContext.request.contextPath}/login">đăng nhập</a> để hoàn tất đặt hàng.</p>
                            </c:otherwise>
                        </c:choose>

                        <div class="cart-payment"><span>PHƯƠNG THỨC THANH TOÁN</span><p>Thanh toán khi nhận hàng (COD)</p></div>
                    </aside>
                </div>
            </c:otherwise>
        </c:choose>
        <div class="cart-bottom-note"><svg width="20" height="20"><use href="#icon-bag"/></svg><div><strong>Lựa chọn công nghệ, theo cách của bạn.</strong><span>Xem lại sản phẩm và số lượng trước khi chuyển sang bước đặt hàng.</span></div></div>
    </main>
    <footer class="ts-container"><div class="module-footer">© TechStore <span>Công nghệ cho cuộc sống</span></div></footer>
</body>
</html>