<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<fmt:setLocale value="vi_VN" scope="page"/>
<%-- ProductServlet supplies request-scoped catalog data; this view never accesses JDBC.
     Product image URLs come from SQL. Hero/category imagery is illustrative only. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Khám phá điện thoại, laptop, phụ kiện và màn hình tại TechStore. Danh sách sản phẩm được cập nhật từ TechStore.">
    <title>TechStore — Công nghệ cho cuộc sống</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="techstore-home" id="trang-chu">
    <svg class="ts-symbols" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
        <defs>
            <symbol id="ts-arrow" viewBox="0 0 24 24"><path d="M5 12h14m-5-5 5 5-5 5"/></symbol>
            <symbol id="ts-search" viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 4.5 4.5"/></symbol>
            <symbol id="ts-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
            <symbol id="ts-close" viewBox="0 0 24 24"><path d="m6 6 12 12M6 18 18 6"/></symbol>
            <symbol id="ts-shield" viewBox="0 0 24 24"><path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Z"/><path d="m8 12 3 3 5-6"/></symbol>
            <symbol id="ts-document" viewBox="0 0 24 24"><rect x="5" y="3" width="14" height="18" rx="2"/><path d="M9 7h6M9 11h6M9 15h4"/></symbol>
            <symbol id="ts-headset" viewBox="0 0 24 24"><path d="M4 14v-3a8 8 0 0 1 16 0v3"/><rect x="3" y="11" width="4" height="7" rx="2"/><rect x="17" y="11" width="4" height="7" rx="2"/><path d="M19 18c0 3-3 3-7 3"/></symbol>
            <symbol id="ts-bag" viewBox="0 0 24 24"><path d="M5 8h14l1 13H4L5 8Z"/><path d="M8 8V6a4 4 0 0 1 8 0v2M9 14h6"/></symbol>
            <symbol id="ts-image" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8" cy="8" r="1.5"/><path d="m3 17 5-5 4 4 3-3 6 6"/></symbol>
            <symbol id="ts-info" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-10v1"/></symbol>
            <symbol id="ts-chevron" viewBox="0 0 24 24"><path d="m9 5 7 7-7 7"/></symbol>
        </defs>
    </svg>
    <a class="ts-skip-link" href="#noi-dung">Đến nội dung chính</a>
    <div class="ts-topbar">
        <div class="ts-container ts-topbar-inner">
            <p><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-bag"></use></svg>Khám phá công nghệ cùng TechStore</p>
            <span>Tiếng Việt <span class="ts-topbar-divider" aria-hidden="true">|</span> VND</span>
        </div>
    </div>
    <header class="ts-header">
        <div class="ts-container ts-header-inner">
            <a class="ts-logo" href="#trang-chu" aria-label="TechStore — Trang chủ">
                <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true"><path d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/></svg>
                <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
            </a>
            <nav class="ts-desktop-nav" aria-label="Điều hướng chính">
                    <a href="#trang-chu" class="is-active" aria-current="page">Trang chủ</a>
                    <a href="#san-pham">Sản phẩm</a>
                    <a href="#danh-muc">Danh mục</a>
                    <a href="#thuong-hieu">Thương hiệu</a>
                    <a href="#moi-nhat">Mới nhất</a>
                    <a href="#ho-tro">Hỗ trợ</a>
            </nav>
            <a class="ts-search-link" href="#danh-sach" aria-label="Đến khu vực tìm sản phẩm"><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-search"></use></svg><span>Tìm sản phẩm</span></a>
            <details class="ts-mobile-menu">
                <summary aria-label="Mở hoặc đóng menu điều hướng"><svg class="ts-icon ts-menu-open" aria-hidden="true" focusable="false"><use href="#ts-menu"></use></svg><svg class="ts-icon ts-menu-close" aria-hidden="true" focusable="false"><use href="#ts-close"></use></svg></summary>
                <nav aria-label="Điều hướng trên di động">
                    <a href="#trang-chu" class="is-active" aria-current="page">Trang chủ</a>
                    <a href="#san-pham">Sản phẩm</a>
                    <a href="#danh-muc">Danh mục</a>
                    <a href="#thuong-hieu">Thương hiệu</a>
                    <a href="#moi-nhat">Mới nhất</a>
                    <a href="#ho-tro">Hỗ trợ</a>
                    <p>Khám phá sản phẩm theo từng danh mục.</p>
                </nav>
            </details>
        </div>
    </header>

    <main class="ts-container" id="noi-dung" tabindex="-1">
        <section class="ts-hero" aria-labelledby="ts-hero-title">
            <div class="ts-hero-copy">
                <p class="ts-eyebrow">THẾ GIỚI CÔNG NGHỆ CỦA BẠN</p>
                <h1 id="ts-hero-title">Công nghệ cho<br><span>cuộc sống tốt hơn.</span></h1>
                <p class="ts-hero-description">Khám phá thiết bị thông minh và phụ kiện<br class="ts-desktop-break"> cho công việc, kết nối và những điều bạn yêu.</p>
                <a class="ts-button" href="#san-pham">Khám phá ngay <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a>
            </div>
            <div class="ts-hero-art" role="group" aria-label="Bộ sưu tập MacBook, iPhone và AirPods">
                <div class="ts-hero-plinth" aria-hidden="true"></div>
                <span class="ts-media ts-hero-laptop"><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha" alt="MacBook Air M2 màu xanh đen" width="500" height="500" fetchpriority="high" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                <span class="ts-media ts-hero-phone"><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha" alt="iPhone 15 Pro Max màu titan xanh" width="500" height="500" fetchpriority="high" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                <span class="ts-media ts-hero-airpods"><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha" alt="AirPods Pro 2 với hộp sạc" width="500" height="500" fetchpriority="high" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
            </div>
        </section>
        <div class="ts-services" aria-label="Thông tin mua sắm">
            <div><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-document"></use></svg><span>Thông tin sản phẩm</span></div>
            <div><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-shield"></use></svg><span>Bảo hành rõ ràng</span></div>
            <div><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-headset"></use></svg><span>Hỗ trợ mua hàng</span></div>
            <div><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-bag"></use></svg><span>Thanh toán COD</span></div>
        </div>
        <nav class="ts-quick-categories" aria-label="Khám phá nhanh danh mục">
            <a href="#danh-sach"><span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha" alt="Điện thoại" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Điện thoại</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></small></span></a>
            <a href="#danh-sach"><span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha" alt="Laptop" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Laptop</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></small></span></a>
            <a href="#danh-sach"><span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha" alt="Phụ kiện" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Phụ kiện</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></small></span></a>
            <a href="#danh-sach"><span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/studio-display-gallery-1-202203?wid=600&amp;hei=600&amp;fmt=png-alpha" alt="Màn hình" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Màn hình</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></small></span></a>
        </nav>

        <section class="ts-section ts-category-section" id="danh-muc" aria-labelledby="ts-categories-title">
            <div class="ts-section-heading"><h2 id="ts-categories-title">Danh mục phổ biến</h2><a class="ts-text-link" href="#danh-sach">Xem sản phẩm <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a></div>
            <div class="ts-category-grid">
                <a class="ts-category-tile" href="#danh-sach">
                    <span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha" alt="Điện thoại" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                    <span class="ts-category-caption"><span><strong>Điện thoại</strong><small>Kết nối mỗi ngày</small></span><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></span>
                </a>
                <a class="ts-category-tile" href="#danh-sach">
                    <span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha" alt="Laptop" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                    <span class="ts-category-caption"><span><strong>Laptop</strong><small>Làm việc & sáng tạo</small></span><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></span>
                </a>
                <a class="ts-category-tile" href="#danh-sach">
                    <span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha" alt="Phụ kiện" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                    <span class="ts-category-caption"><span><strong>Phụ kiện</strong><small>Trọn vẹn trải nghiệm</small></span><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></span>
                </a>
                <a class="ts-category-tile" href="#danh-sach">
                    <span class="ts-media "><img src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/studio-display-gallery-1-202203?wid=600&amp;hei=600&amp;fmt=png-alpha" alt="Màn hình" width="500" height="500" loading="lazy" decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span></span>
                    <span class="ts-category-caption"><span><strong>Màn hình</strong><small>Mở rộng góc nhìn</small></span><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></span>
                </a>
            </div>
        </section>

        <div id="san-pham" class="ts-products-area">
            <c:if test="${not empty dataLoadError}">
                <section class="ts-data-error" role="alert" aria-labelledby="ts-data-error-title">
                    <h2 id="ts-data-error-title">Chưa thể tải sản phẩm</h2>
                    <p><c:out value="${dataLoadError}"/></p>
                    <c:url var="retryUrl" value="/home"/>
                    <a class="ts-button" href="<c:out value="${retryUrl}"/>#san-pham">Tải lại sản phẩm</a>
                </section>
            </c:if>
            <c:if test="${empty dataLoadError}">
            <section class="ts-section" id="ban-chay" aria-labelledby="ts-bestsellers-title">
                <div class="ts-section-heading">
                    <div><h2 id="ts-bestsellers-title">Sản phẩm bán chạy</h2><p>Được lựa chọn qua các đơn hàng đã hoàn thành.</p></div>
                    <a class="ts-text-link" href="#danh-sach">Xem tất cả <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a>
                </div>
                <c:choose>
                    <c:when test="${not empty bestSellingProducts}">
                        <div class="ts-product-grid ts-scroll-row" role="region" aria-label="Sản phẩm bán chạy, có thể cuộn ngang trên điện thoại" tabindex="0">
                            <c:forEach var="product" items="${bestSellingProducts}">
                    <article class="ts-product" data-product-id="<c:out value="${product.productId}"/>">
                        <span class="ts-media">
                            <c:set var="imagePath" value="${fn:trim(product.imageUrl)}"/>
                            <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}"/>
                            <c:choose>
                                <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                    <c:url var="productImageUrl" value="${imagePath}"/>
                                    <img src="<c:out value="${productImageUrl}"/>" alt="<c:out value="${product.productName}"/>" width="500" height="500" loading="lazy" decoding="async">
                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <div class="ts-product-body">
                            <p class="ts-product-brand"><c:out value="${product.brandName}"/></p>
                            <h3><c:out value="${product.productName}"/></h3>
                            <p class="ts-price"><fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></p>
                        </div>
                    </article>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise><p class="ts-empty-state">Chưa có sản phẩm bán chạy từ các đơn hàng đã hoàn thành.</p></c:otherwise>
                </c:choose>
            </section>
            <section class="ts-section" id="noi-bat" aria-labelledby="ts-featured-title">
                <div class="ts-section-heading">
                    <div><h2 id="ts-featured-title">Lựa chọn nổi bật</h2><p>Thiết bị cho những ý tưởng và trải nghiệm mới.</p></div>
                    <a class="ts-text-link" href="#danh-sach">Khám phá thêm <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a>
                </div>
                <c:choose>
                    <c:when test="${not empty featuredProducts}">
                        <div class="ts-featured-grid">
                            <c:forEach var="product" items="${featuredProducts}">
                    <article class="ts-product" data-product-id="<c:out value="${product.productId}"/>">
                        <span class="ts-media">
                            <c:set var="imagePath" value="${fn:trim(product.imageUrl)}"/>
                            <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}"/>
                            <c:choose>
                                <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                    <c:url var="productImageUrl" value="${imagePath}"/>
                                    <img src="<c:out value="${productImageUrl}"/>" alt="<c:out value="${product.productName}"/>" width="500" height="500" loading="lazy" decoding="async">
                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <div class="ts-product-body">
                            <p class="ts-product-brand"><c:out value="${product.brandName}"/></p>
                            <h3><c:out value="${product.productName}"/></h3>
                            <p class="ts-price"><fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></p>
                        </div>
                    </article>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise><p class="ts-empty-state">Chưa có sản phẩm nổi bật.</p></c:otherwise>
                </c:choose>
            </section>
            <section class="ts-section" id="moi-nhat" aria-labelledby="ts-newest-title">
                <div class="ts-section-heading">
                    <div><h2 id="ts-newest-title">Mới nhất</h2><p>Các sản phẩm được thêm gần đây nhất.</p></div>
                    <a class="ts-text-link" href="#danh-sach">Xem bộ sưu tập <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a>
                </div>
                <c:choose>
                    <c:when test="${not empty newProducts}">
                        <div class="ts-newest-grid">
                            <c:forEach var="product" items="${newProducts}">
                    <article class="ts-product" data-product-id="<c:out value="${product.productId}"/>">
                        <span class="ts-media">
                            <c:set var="imagePath" value="${fn:trim(product.imageUrl)}"/>
                            <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}"/>
                            <c:choose>
                                <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                    <c:url var="productImageUrl" value="${imagePath}"/>
                                    <img src="<c:out value="${productImageUrl}"/>" alt="<c:out value="${product.productName}"/>" width="500" height="500" loading="lazy" decoding="async">
                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <div class="ts-product-body">
                            <p class="ts-product-brand"><c:out value="${product.brandName}"/></p>
                            <h3><c:out value="${product.productName}"/></h3>
                            <p class="ts-price"><fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></p>
                        </div>
                    </article>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise><p class="ts-empty-state">Chưa có sản phẩm mới đang được bán.</p></c:otherwise>
                </c:choose>
            </section>
            </c:if>
        </div>

        <section class="ts-section ts-catalog-section" id="danh-sach" aria-labelledby="ts-catalog-title">
            <div class="ts-section-heading">
                <div><h2 id="ts-catalog-title">Khám phá sản phẩm</h2><p>Tìm thiết bị phù hợp với cách bạn sống và làm việc.</p></div>
                <c:if test="${empty dataLoadError}"><span class="ts-preview-label"><fmt:formatNumber value="${totalProducts}" maxFractionDigits="0"/> sản phẩm</span></c:if>
            </div>
            <p class="ts-catalog-notice" id="ts-search-notice">Tìm kiếm và bộ lọc chưa khả dụng. Bạn có thể xem sản phẩm theo từng trang bên dưới.</p>
            <fieldset class="ts-filters" disabled aria-describedby="ts-search-notice">
                <legend class="ts-sr-only">Tìm kiếm và lọc sản phẩm — chưa khả dụng</legend>
                <div class="ts-filter ts-filter-search"><label for="ts-search-input">Tên sản phẩm</label><div class="ts-input-icon"><svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-search"></use></svg><input id="ts-search-input" type="search" placeholder="Bạn đang tìm gì?"></div></div>
                <div class="ts-filter"><label for="ts-category">Danh mục</label><select id="ts-category"><option>Tất cả danh mục</option><option>Điện thoại</option><option>Laptop</option><option>Phụ kiện</option><option>Màn hình</option></select></div>
                <div class="ts-filter"><label for="ts-brand">Thương hiệu</label><select id="ts-brand"><option>Tất cả thương hiệu</option><option>Apple</option><option>Samsung</option><option>Dell</option><option>ASUS</option><option>Sony</option><option>HP</option><option>Lenovo</option><option>Xiaomi</option><option>LG</option><option>Acer</option></select></div>
                <div class="ts-filter"><label for="ts-price">Khoảng giá</label><select id="ts-price"><option>Tất cả mức giá</option><option>Dưới 10 triệu</option><option>10–20 triệu</option><option>Trên 20 triệu</option></select></div>
                <div class="ts-filter"><label for="ts-sort">Sắp xếp</label><select id="ts-sort"><option>Mới nhất</option><option>Giá tăng dần</option><option>Giá giảm dần</option></select></div>
            </fieldset>
            <c:choose>
                <c:when test="${not empty dataLoadError}"><p class="ts-empty-state">Danh sách sản phẩm tạm thời chưa khả dụng. Vui lòng tải lại sản phẩm ở phía trên.</p></c:when>
                <c:otherwise>
                <c:choose>
                    <c:when test="${not empty products}">
                        <div class="ts-product-grid ts-catalog-grid">
                            <c:forEach var="product" items="${products}">
                    <article class="ts-product" data-product-id="<c:out value="${product.productId}"/>">
                        <span class="ts-media">
                            <c:set var="imagePath" value="${fn:trim(product.imageUrl)}"/>
                            <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}"/>
                            <c:choose>
                                <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                    <c:url var="productImageUrl" value="${imagePath}"/>
                                    <img src="<c:out value="${productImageUrl}"/>" alt="<c:out value="${product.productName}"/>" width="500" height="500" loading="lazy" decoding="async">
                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <div class="ts-product-body">
                            <p class="ts-product-brand"><c:out value="${product.brandName}"/></p>
                            <h3><c:out value="${product.productName}"/></h3>
                            <p class="ts-price"><fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></p>
                        </div>
                    </article>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise><p class="ts-empty-state">Hiện chưa có sản phẩm đang được bán.</p></c:otherwise>
                </c:choose>
            <c:if test="${not empty products}">
                <p class="ts-catalog-summary" role="status">Hiển thị <fmt:formatNumber value="${firstProduct}" maxFractionDigits="0"/>–<fmt:formatNumber value="${lastProduct}" maxFractionDigits="0"/> trong <fmt:formatNumber value="${totalProducts}" maxFractionDigits="0"/> sản phẩm · Trang <fmt:formatNumber value="${currentPage}" maxFractionDigits="0"/>/<fmt:formatNumber value="${totalPages}" maxFractionDigits="0"/></p>
            </c:if>
            <c:if test="${totalPages gt 1}">
                <nav class="ts-pagination" aria-label="Phân trang sản phẩm">
                    <c:choose>
                        <c:when test="${currentPage gt 1}">
                            <c:url var="firstPageUrl" value="/home"><c:param name="page" value="1"/></c:url>
                            <c:url var="previousPageUrl" value="/home"><c:param name="page" value="${currentPage - 1}"/></c:url>
                            <a class="ts-page-link" href="<c:out value="${firstPageUrl}"/>#danh-sach" aria-label="Trang đầu">Đầu</a>
                            <a class="ts-page-link" href="<c:out value="${previousPageUrl}"/>#danh-sach" aria-label="Trang trước" rel="prev">Trước</a>
                        </c:when>
                        <c:otherwise><span class="ts-page-link is-disabled" aria-disabled="true">Đầu</span><span class="ts-page-link is-disabled" aria-disabled="true">Trước</span></c:otherwise>
                    </c:choose>
                    <c:forEach var="pageNumber" items="${pageNumbers}">
                        <c:choose>
                            <c:when test="${pageNumber eq currentPage}"><span class="ts-page-link is-current" aria-current="page" aria-label="Trang <c:out value="${pageNumber}"/>"><c:out value="${pageNumber}"/></span></c:when>
                            <c:otherwise>
                                <c:url var="pageUrl" value="/home"><c:param name="page" value="${pageNumber}"/></c:url>
                                <a class="ts-page-link" href="<c:out value="${pageUrl}"/>#danh-sach" aria-label="Trang <c:out value="${pageNumber}"/>"><c:out value="${pageNumber}"/></a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:choose>
                        <c:when test="${currentPage lt totalPages}">
                            <c:url var="nextPageUrl" value="/home"><c:param name="page" value="${currentPage + 1}"/></c:url>
                            <c:url var="lastPageUrl" value="/home"><c:param name="page" value="${totalPages}"/></c:url>
                            <a class="ts-page-link" href="<c:out value="${nextPageUrl}"/>#danh-sach" aria-label="Trang tiếp" rel="next">Tiếp</a>
                            <a class="ts-page-link" href="<c:out value="${lastPageUrl}"/>#danh-sach" aria-label="Trang cuối">Cuối</a>
                        </c:when>
                        <c:otherwise><span class="ts-page-link is-disabled" aria-disabled="true">Tiếp</span><span class="ts-page-link is-disabled" aria-disabled="true">Cuối</span></c:otherwise>
                    </c:choose>
                </nav>
            </c:if>
                </c:otherwise>
            </c:choose>
        </section>
        <section class="ts-brands ts-section" id="thuong-hieu" aria-labelledby="ts-brands-title">
            <div class="ts-section-heading"><h2 id="ts-brands-title">Thương hiệu trong bộ sưu tập</h2></div>
            <ul><li>Apple</li><li>SAMSUNG</li><li>DELL</li><li>ASUS</li><li>SONY</li><li>HP</li><li>Lenovo</li><li>Xiaomi</li><li>LG</li><li>acer</li></ul>
        </section>
        <section class="ts-support ts-section" id="ho-tro" aria-labelledby="ts-support-title">
            <div><p class="ts-eyebrow">THÔNG TIN HỮU ÍCH</p><h2 id="ts-support-title">Cùng bạn khám phá công nghệ.</h2><p>Tìm hiểu sản phẩm và thông tin mua sắm tại TechStore.</p></div>
            <div class="ts-support-questions">
                <details><summary>Thông tin bảo hành xem ở đâu? <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-chevron"></use></svg></summary><p>Thời hạn bảo hành được ghi theo từng sản phẩm. Trang chi tiết sản phẩm hiện chưa khả dụng.</p></details>
                <details><summary>TechStore hỗ trợ thanh toán gì? <svg class="ts-icon " aria-hidden="true" focusable="false"><use href="#ts-chevron"></use></svg></summary><p>Dự án sử dụng hình thức thanh toán khi nhận hàng (COD). Chức năng đặt hàng hiện chưa khả dụng.</p></details>
            </div>
        </section>
    </main>
    <footer class="ts-footer">
        <div class="ts-container ts-footer-main">
            <div><a class="ts-logo" href="#trang-chu" aria-label="TechStore — Về đầu trang"><svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true"><path d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/></svg><span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span></a><p>Điện thoại, laptop và những kết nối mỗi ngày.</p></div>
            <nav aria-label="Điều hướng cuối trang"><a href="#danh-muc">Danh mục</a><a href="#san-pham">Sản phẩm</a><a href="#thuong-hieu">Thương hiệu</a><a href="#ho-tro">Hỗ trợ</a></nav>
        </div>
        <div class="ts-container ts-footer-bottom">
            <p>TechStore · Dự án PRJ301 · FPT University · Nhóm 1</p>
            <p>Ảnh sản phẩm: <a href="https://www.apple.com/" rel="noopener noreferrer" target="_blank">Apple</a>, <a href="https://www.sony.jp/headphone/" rel="noopener noreferrer" target="_blank">Sony</a>, <a href="https://www.mi.com/global/" rel="noopener noreferrer" target="_blank">Xiaomi</a>.</p>
        </div>
    </footer>
    <script>
        // Presentation only: one-way image fallback and native mobile navigation.
        (() => {
            const root = document.querySelector('.techstore-home');
            const showFallback = (img) => {
                if (img.dataset.failed) return;
                img.dataset.failed = 'true';
                img.hidden = true;
                const fallback = img.parentElement.querySelector('.ts-image-fallback');
                if (fallback) fallback.hidden = false;
            };
            root.querySelectorAll('.ts-media img').forEach((img) => {
                img.addEventListener('error', () => showFallback(img), { once: true });
                if (img.complete && img.naturalWidth === 0) showFallback(img);
            });
            const menu = root.querySelector('.ts-mobile-menu');
            const summary = menu.querySelector('summary');
            menu.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
                menu.open = false;
                const target = document.getElementById(link.hash.slice(1));
                if (target) {
                    if (!target.hasAttribute('tabindex')) target.setAttribute('tabindex', '-1');
                    target.focus({ preventScroll: true });
                }
            }));
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape' && menu.open) {
                    menu.open = false;
                    summary.focus();
                }
            });
            document.addEventListener('click', (event) => {
                if (menu.open && !menu.contains(event.target)) {
                    const restoreFocus = menu.contains(document.activeElement);
                    menu.open = false;
                    if (restoreFocus) summary.focus();
                }
            });
            const desktop = window.matchMedia('(min-width: 1280px)');
            desktop.addEventListener('change', () => {
                if (desktop.matches && menu.open) {
                    const restoreFocus = menu.contains(document.activeElement);
                    menu.open = false;
                    if (restoreFocus) root.querySelector('.ts-logo').focus();
                }
            });
        })();
    </script>
</body>
</html>
