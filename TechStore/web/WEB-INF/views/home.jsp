<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <fmt:setLocale value="vi_VN" scope="page" />
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <meta name="description"
                        content="Khám phá điện thoại, laptop, phụ kiện và màn hình tại TechStore. Danh sách sản phẩm được cập nhật từ TechStore.">
                    <title>TechStore — Công nghệ cho cuộc sống</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                </head>

                <body class="techstore-home" id="trang-chu">
                    <jsp:include page="/WEB-INF/views/common/header.jsp">
                        <jsp:param name="activePage" value="home"/>
                    </jsp:include>
                    <main class="ts-container" id="noi-dung" tabindex="-1">
                        <section class="ts-hero" aria-labelledby="ts-hero-title">
                            <div class="ts-hero-copy">
                                <p class="ts-eyebrow">THẾ GIỚI CÔNG NGHỆ CỦA BẠN</p>
                                <h1 id="ts-hero-title">Công nghệ cho<br><span>cuộc sống tốt hơn.</span></h1>
                                <p class="ts-hero-description">Khám phá thiết bị thông minh và phụ kiện<br
                                        class="ts-desktop-break"> cho công việc, kết nối và những điều bạn yêu.</p>
                                <a class="ts-button" href="#san-pham">Khám phá ngay <svg class="ts-icon "
                                        aria-hidden="true" focusable="false">
                                        <use href="#ts-arrow"></use>
                                    </svg></a>
                            </div>
                            <div class="ts-hero-art" role="group" aria-label="Bộ sưu tập MacBook, iPhone và AirPods">
                                <div class="ts-hero-plinth" aria-hidden="true"></div>
                                <span class="ts-media ts-hero-laptop"><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha"
                                        alt="MacBook Air M2 màu xanh đen" width="500" height="500" fetchpriority="high"
                                        decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon "
                                            aria-hidden="true" focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span>
                                <span class="ts-media ts-hero-phone"><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha"
                                        alt="iPhone 15 Pro Max màu titan xanh" width="500" height="500"
                                        fetchpriority="high" decoding="async"><span class="ts-image-fallback"
                                        hidden><svg class="ts-icon " aria-hidden="true" focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span>
                                <span class="ts-media ts-hero-airpods"><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha"
                                        alt="AirPods Pro 2 với hộp sạc" width="500" height="500" fetchpriority="high"
                                        decoding="async"><span class="ts-image-fallback" hidden><svg class="ts-icon "
                                            aria-hidden="true" focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span>
                            </div>
                        </section>
                        <div class="ts-services" aria-label="Thông tin mua sắm">
                            <div><svg class="ts-icon " aria-hidden="true" focusable="false">
                                    <use href="#ts-document"></use>
                                </svg><span>Thông tin sản phẩm</span></div>
                            <div><svg class="ts-icon " aria-hidden="true" focusable="false">
                                    <use href="#ts-shield"></use>
                                </svg><span>Bảo hành rõ ràng</span></div>
                            <div><svg class="ts-icon " aria-hidden="true" focusable="false">
                                    <use href="#ts-headset"></use>
                                </svg><span>Hỗ trợ mua hàng</span></div>
                            <div><svg class="ts-icon " aria-hidden="true" focusable="false">
                                    <use href="#ts-bag"></use>
                                </svg><span>Thanh toán COD</span></div>
                        </div>
                        <nav class="ts-quick-categories" aria-label="Khám phá nhanh danh mục">
                            <a href="${pageContext.request.contextPath}/products?category=1"><span class="ts-media "><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha"
                                        alt="Điện thoại" width="500" height="500" loading="lazy" decoding="async"><span
                                        class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Điện
                                        thoại</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></small></span></a>
                            <a href="${pageContext.request.contextPath}/products?category=2"><span class="ts-media "><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha"
                                        alt="Laptop" width="500" height="500" loading="lazy" decoding="async"><span
                                        class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập
                                            nhật</span></span></span><span><strong>Laptop</strong><small>Khám phá <svg
                                            class="ts-icon " aria-hidden="true" focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></small></span></a>
                            <a href="${pageContext.request.contextPath}/products?category=3"><span class="ts-media "><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha"
                                        alt="Phụ kiện" width="500" height="500" loading="lazy" decoding="async"><span
                                        class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Phụ
                                        kiện</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></small></span></a>
                            <a href="${pageContext.request.contextPath}/products?category=4"><span class="ts-media "><img
                                        src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/studio-display-gallery-1-202203?wid=600&amp;hei=600&amp;fmt=png-alpha"
                                        alt="Màn hình" width="500" height="500" loading="lazy" decoding="async"><span
                                        class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-image"></use>
                                        </svg><span>Ảnh đang cập nhật</span></span></span><span><strong>Màn
                                        hình</strong><small>Khám phá <svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></small></span></a>
                        </nav>

                        <section class="ts-section ts-category-section" id="danh-muc"
                            aria-labelledby="ts-categories-title">
                            <div class="ts-section-heading">
                                <h2 id="ts-categories-title">Danh mục phổ biến</h2><a class="ts-text-link" href="${pageContext.request.contextPath}/products">Xem sản phẩm <svg class="ts-icon " aria-hidden="true"
                                        focusable="false">
                                        <use href="#ts-arrow"></use>
                                    </svg></a>
                            </div>
                            <div class="ts-category-grid">
                                <a class="ts-category-tile" href="${pageContext.request.contextPath}/products?category=1">
                                    <span class="ts-media "><img
                                            src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&amp;hei=500&amp;fmt=png-alpha"
                                            alt="Điện thoại" width="500" height="500" loading="lazy"
                                            decoding="async"><span class="ts-image-fallback" hidden><svg
                                                class="ts-icon " aria-hidden="true" focusable="false">
                                                <use href="#ts-image"></use>
                                            </svg><span>Ảnh đang cập nhật</span></span></span>
                                    <span class="ts-category-caption"><span><strong>Điện thoại</strong><small>Kết nối
                                                mỗi ngày</small></span><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></span>
                                </a>
                                <a class="ts-category-tile" href="${pageContext.request.contextPath}/products?category=2">
                                    <span class="ts-media "><img
                                            src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&amp;hei=616&amp;fmt=png-alpha"
                                            alt="Laptop" width="500" height="500" loading="lazy" decoding="async"><span
                                            class="ts-image-fallback" hidden><svg class="ts-icon " aria-hidden="true"
                                                focusable="false">
                                                <use href="#ts-image"></use>
                                            </svg><span>Ảnh đang cập nhật</span></span></span>
                                    <span class="ts-category-caption"><span><strong>Laptop</strong><small>Làm việc &
                                                sáng tạo</small></span><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></span>
                                </a>
                                <a class="ts-category-tile" href="${pageContext.request.contextPath}/products?category=3">
                                    <span class="ts-media "><img
                                            src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&amp;hei=400&amp;fmt=png-alpha"
                                            alt="Phụ kiện" width="500" height="500" loading="lazy"
                                            decoding="async"><span class="ts-image-fallback" hidden><svg
                                                class="ts-icon " aria-hidden="true" focusable="false">
                                                <use href="#ts-image"></use>
                                            </svg><span>Ảnh đang cập nhật</span></span></span>
                                    <span class="ts-category-caption"><span><strong>Phụ kiện</strong><small>Trọn vẹn
                                                trải nghiệm</small></span><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></span>
                                </a>
                                <a class="ts-category-tile" href="${pageContext.request.contextPath}/products?category=4">
                                    <span class="ts-media "><img
                                            src="https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/studio-display-gallery-1-202203?wid=600&amp;hei=600&amp;fmt=png-alpha"
                                            alt="Màn hình" width="500" height="500" loading="lazy"
                                            decoding="async"><span class="ts-image-fallback" hidden><svg
                                                class="ts-icon " aria-hidden="true" focusable="false">
                                                <use href="#ts-image"></use>
                                            </svg><span>Ảnh đang cập nhật</span></span></span>
                                    <span class="ts-category-caption"><span><strong>Màn hình</strong><small>Mở rộng góc
                                                nhìn</small></span><svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-arrow"></use>
                                        </svg></span>
                                </a>
                            </div>
                        </section>

                        <div id="san-pham" class="ts-products-area">
                            <c:if test="${not empty dataLoadError}">
                                <section class="ts-data-error" role="alert" aria-labelledby="ts-data-error-title">
                                    <h2 id="ts-data-error-title">Chưa thể tải sản phẩm</h2>
                                    <p>
                                        <c:out value="${dataLoadError}" />
                                    </p>
                                    <c:url var="retryUrl" value="/home" />
                                    <a class="ts-button" href="<c:out value=" ${retryUrl}" />#san-pham">Tải lại sản
                                    phẩm</a>
                                </section>
                            </c:if>
                            <c:if test="${empty dataLoadError}">
                                <section class="ts-section" id="ban-chay" aria-labelledby="ts-bestsellers-title">
                                    <div class="ts-section-heading">
                                        <div>
                                            <h2 id="ts-bestsellers-title">Sản phẩm bán chạy</h2>
                                            <p>Được lựa chọn qua các đơn hàng đã hoàn thành.</p>
                                        </div>
                                        <a class="ts-text-link" href="${pageContext.request.contextPath}/products?sort=bestselling">Xem tất cả <svg class="ts-icon "
                                                aria-hidden="true" focusable="false">
                                                <use href="#ts-arrow"></use>
                                            </svg></a>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty bestSellingProducts}">
                                            <div class="ts-product-grid ts-scroll-row" role="region"
                                                aria-label="Sản phẩm bán chạy, có thể cuộn ngang trên điện thoại"
                                                tabindex="0">
                                                <c:forEach var="product" items="${bestSellingProducts}">
                                                    <article class="ts-product" data-product-id="${product.productId}">
                                                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productId}" class="ts-product-card-link"
                                                    aria-label="Xem chi tiết ${fn:escapeXml(product.productName)}">
                                                    <span class="ts-media">
                                                        <c:set var="imagePath" value="${fn:trim(product.imageUrl)}" />
                                                        <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}" />
                                                        <c:choose>
                                                            <c:when
                                                                test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                                                <c:url var="productImageUrl" value="${imagePath}" />
                                                                <img src="${productImageUrl}" alt="${fn:escapeXml(product.productName)}" width="500"
                                                                height="500" loading="lazy" decoding="async">
                                                                <span class="ts-image-fallback" hidden><svg
                                                                        class="ts-icon" aria-hidden="true"
                                                                        focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="ts-image-fallback"><svg class="ts-icon"
                                                                        aria-hidden="true" focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <div class="ts-product-body">
                                                        <p class="ts-product-brand">
                                                            <c:out value="${product.brandName}" />
                                                        </p>
                                                        <h3>
                                                            <c:out value="${product.productName}" />
                                                        </h3>
                                                        <p class="ts-price">
                                                            <fmt:formatNumber value="${product.price}" type="currency"
                                                                currencyCode="VND" minFractionDigits="0"
                                                                maxFractionDigits="0" />
                                                        </p>
                                                    </div>
                                                    </a>
                                                    </article>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="ts-empty-state">Chưa có sản phẩm bán chạy từ các đơn hàng đã hoàn
                                                thành.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </section>
                                <section class="ts-section" id="noi-bat" aria-labelledby="ts-featured-title">
                                    <div class="ts-section-heading">
                                        <div>
                                            <h2 id="ts-featured-title">Lựa chọn nổi bật</h2>
                                            <p>Thiết bị cho những ý tưởng và trải nghiệm mới.</p>
                                        </div>
                                        <a class="ts-text-link" href="${pageContext.request.contextPath}/products">Khám phá thêm <svg class="ts-icon "
                                                aria-hidden="true" focusable="false">
                                                <use href="#ts-arrow"></use>
                                            </svg></a>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty featuredProducts}">
                                            <div class="ts-featured-grid">
                                                <c:forEach var="product" items="${featuredProducts}">
                                                    <article class="ts-product" data-product-id="${product.productId}">
                                                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productId}" class="ts-product-card-link"
                                                    aria-label="Xem chi tiết ${fn:escapeXml(product.productName)}">
                                                    <span class="ts-media">
                                                        <c:set var="imagePath" value="${fn:trim(product.imageUrl)}" />
                                                        <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}" />
                                                        <c:choose>
                                                            <c:when
                                                                test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                                                <c:url var="productImageUrl" value="${imagePath}" />
                                                                <img src="${productImageUrl}" alt="${fn:escapeXml(product.productName)}" width="500"
                                                                height="500" loading="lazy" decoding="async">
                                                                <span class="ts-image-fallback" hidden><svg
                                                                        class="ts-icon" aria-hidden="true"
                                                                        focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="ts-image-fallback"><svg class="ts-icon"
                                                                        aria-hidden="true" focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <div class="ts-product-body">
                                                        <p class="ts-product-brand">
                                                            <c:out value="${product.brandName}" />
                                                        </p>
                                                        <h3>
                                                            <c:out value="${product.productName}" />
                                                        </h3>
                                                        <p class="ts-price">
                                                            <fmt:formatNumber value="${product.price}" type="currency"
                                                                currencyCode="VND" minFractionDigits="0"
                                                                maxFractionDigits="0" />
                                                        </p>
                                                    </div>
                                                    </a>
                                                    </article>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="ts-empty-state">Chưa có sản phẩm nổi bật.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </section>
                                <section class="ts-section" id="moi-nhat" aria-labelledby="ts-newest-title">
                                    <div class="ts-section-heading">
                                        <div>
                                            <h2 id="ts-newest-title">Mới nhất</h2>
                                            <p>Các sản phẩm được thêm gần đây nhất.</p>
                                        </div>
                                        <a class="ts-text-link" href="${pageContext.request.contextPath}/products?sort=newest">Xem bộ sưu tập <svg class="ts-icon "
                                                aria-hidden="true" focusable="false">
                                                <use href="#ts-arrow"></use>
                                            </svg></a>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty newProducts}">
                                            <div class="ts-newest-grid">
                                                <c:forEach var="product" items="${newProducts}">
                                                    <article class="ts-product" data-product-id="${product.productId}">
                                                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productId}" class="ts-product-card-link"
                                                    aria-label="Xem chi tiết ${fn:escapeXml(product.productName)}">
                                                    <span class="ts-media">
                                                        <c:set var="imagePath" value="${fn:trim(product.imageUrl)}" />
                                                        <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}" />
                                                        <c:choose>
                                                            <c:when
                                                                test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                                                <c:url var="productImageUrl" value="${imagePath}" />
                                                                <img src="${productImageUrl}" alt="${fn:escapeXml(product.productName)}" width="500"
                                                                height="500" loading="lazy" decoding="async">
                                                                <span class="ts-image-fallback" hidden><svg
                                                                        class="ts-icon" aria-hidden="true"
                                                                        focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="ts-image-fallback"><svg class="ts-icon"
                                                                        aria-hidden="true" focusable="false">
                                                                        <use href="#ts-image"></use>
                                                                    </svg><span>Ảnh đang cập nhật</span></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <div class="ts-product-body">
                                                        <p class="ts-product-brand">
                                                            <c:out value="${product.brandName}" />
                                                        </p>
                                                        <h3>
                                                            <c:out value="${product.productName}" />
                                                        </h3>
                                                        <p class="ts-price">
                                                            <fmt:formatNumber value="${product.price}" type="currency"
                                                                currencyCode="VND" minFractionDigits="0"
                                                                maxFractionDigits="0" />
                                                        </p>
                                                    </div>
                                                    </a>
                                                    </article>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="ts-empty-state">Chưa có sản phẩm mới đang được bán.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </section>
                            </c:if>
                        </div>
                        <section class="ts-brands ts-section" id="thuong-hieu" aria-labelledby="ts-brands-title">
                            <div class="ts-section-heading">
                                <h2 id="ts-brands-title">Thương hiệu trong bộ sưu tập</h2>
                            </div>
                            <ul>
                                <li>Apple</li>
                                <li>SAMSUNG</li>
                                <li>DELL</li>
                                <li>ASUS</li>
                                <li>SONY</li>
                                <li>HP</li>
                                <li>Lenovo</li>
                                <li>Xiaomi</li>
                                <li>LG</li>
                                <li>acer</li>
                            </ul>
                        </section>
                        <section class="ts-support ts-section" id="ho-tro" aria-labelledby="ts-support-title">
                            <div>
                                <p class="ts-eyebrow">THÔNG TIN HỮU ÍCH</p>
                                <h2 id="ts-support-title">Cùng bạn khám phá công nghệ.</h2>
                                <p>Tìm hiểu sản phẩm và thông tin mua sắm tại TechStore.</p>
                            </div>
                            <div class="ts-support-questions">
                                <details>
                                    <summary>Thông tin bảo hành xem ở đâu? <svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-chevron"></use>
                                        </svg></summary>
                                    <p>Thời hạn bảo hành được ghi theo từng sản phẩm. Bạn có thể nhấn vào sản phẩm để
                                        xem chi tiết.</p>
                                </details>
                                <details>
                                    <summary>TechStore hỗ trợ thanh toán gì? <svg class="ts-icon " aria-hidden="true"
                                            focusable="false">
                                            <use href="#ts-chevron"></use>
                                        </svg></summary>
                                    <p>Dự án sử dụng hình thức thanh toán khi nhận hàng (COD).</p>
                                </details>
                            </div>
                        </section>
                    </main>
                    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
                </body>
                </html>
