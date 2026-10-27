<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<fmt:setLocale value="vi_VN" scope="page"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Chi tiết sản phẩm <c:out value="${product.productName}"/> chính hãng tại TechStore. Mua sắm an tâm với chính sách bảo hành rõ ràng.">
    <title><c:out value="${product.productName}"/> — TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="techstore-home techstore-page" id="chi-tiet-san-pham">

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="activePage" value="products"/>
    </jsp:include>

    <main class="ts-container" id="noi-dung" tabindex="-1">
        <!-- Breadcrumb Navigation -->
        <nav class="ts-breadcrumbs" aria-label="Đường dẫn điều hướng">
            <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li><span class="ts-breadcrumb-sep">/</span></li>
                <li><a href="${pageContext.request.contextPath}/home?category=${product.categoryId}#danh-sach"><c:out value="${product.categoryName}"/></a></li>
                <li><span class="ts-breadcrumb-sep">/</span></li>
                <li aria-current="page"><span><c:out value="${product.productName}"/></span></li>
            </ol>
        </nav>

        <!-- Main Product Detail Section -->
        <section class="ts-detail-section" aria-labelledby="ts-detail-heading">
            <div class="ts-detail-grid">
                <!-- Product Gallery / Media Column -->
                <div class="ts-detail-gallery">
                    <div class="ts-detail-media-wrap">
                        <c:if test="${product.featured}">
                            <span class="ts-detail-featured-badge">⭐ Nổi bật</span>
                        </c:if>
                        <span class="ts-media ts-detail-media">
                            <c:set var="imagePath" value="${fn:trim(product.imageUrl)}"/>
                            <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}"/>
                            <c:choose>
                                <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                    <c:url var="productImageUrl" value="${imagePath}"/>
                                    <img src="${productImageUrl}" alt="${fn:escapeXml(product.productName)}" width="600" height="600" fetchpriority="high" decoding="async">
                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <!-- Product Information Column -->
                <div class="ts-detail-info">
                    <div class="ts-detail-badges">
                        <span class="ts-badge ts-badge-brand"><c:out value="${product.brandName}"/></span>
                        <span class="ts-badge ts-badge-category"><c:out value="${product.categoryName}"/></span>
                        <c:if test="${product.unitsSold > 0}">
                            <span class="ts-badge ts-badge-sold">Đã bán: <fmt:formatNumber value="${product.unitsSold}" maxFractionDigits="0"/></span>
                        </c:if>
                    </div>

                    <h1 id="ts-detail-heading" class="ts-detail-title"><c:out value="${product.productName}"/></h1>

                    <div class="ts-detail-price-box">
                        <div class="ts-detail-price">
                            <fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/>
                        </div>
                        <div class="ts-detail-stock-status">
                            <c:choose>
                                <c:when test="${product.stockQuantity > 0}">
                                    <span class="ts-stock-tag is-in-stock"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-check"></use></svg> Còn hàng (${product.stockQuantity} sản phẩm sẵn có)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-stock-tag is-out-of-stock">Tạm hết hàng</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Warranty & Guarantees -->
                    <div class="ts-detail-guarantees">
                        <div class="ts-guarantee-item">
                            <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-shield"></use></svg>
                            <div>
                                <strong>Bảo hành chính hãng</strong>
                                <p><c:out value="${product.warrantyPeriod}"/> tháng theo tiêu chuẩn nhà sản xuất</p>
                            </div>
                        </div>
                        <div class="ts-guarantee-item">
                            <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-bag"></use></svg>
                            <div>
                                <strong>Thanh toán khi nhận hàng</strong>
                                <p>Hỗ trợ kiểm tra hàng trước khi thanh toán (COD)</p>
                            </div>
                        </div>
                    </div>

                    <!-- Purchasing Action Form -->
                    <form action="${pageContext.request.contextPath}/cart" method="post" class="ts-purchase-form">
                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="productId" value="${product.productId}">

                        <div class="ts-quantity-selector">
                            <label for="ts-qty-input"><strong>Số lượng:</strong></label>
                            <div class="ts-qty-group">
                                <button type="button" class="ts-qty-btn" onclick="decreaseQty()" aria-label="Giảm số lượng">-</button>
                                <input type="number" id="ts-qty-input" name="quantity" value="1" min="1" max="${product.stockQuantity > 0 ? product.stockQuantity : 1}" readonly>
                                <button type="button" class="ts-qty-btn" onclick="increaseQty(${product.stockQuantity})" aria-label="Tăng số lượng">+</button>
                            </div>
                        </div>

                        <div class="ts-purchase-actions">
                            <c:choose>
                                <c:when test="${product.stockQuantity > 0}">
                                    <button type="submit" class="ts-button ts-button-cart">
                                        <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-bag"></use></svg> Thêm vào giỏ hàng
                                    </button>
                                    <button type="submit" name="buyNow" value="true" class="ts-button ts-button-buynow">
                                        Mua ngay
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="ts-button" disabled style="opacity:0.6; cursor:not-allowed;">
                                        Tạm thời hết hàng
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${product.productId}" class="ts-button ts-button-outline" title="Chỉnh sửa sản phẩm với tư cách Admin">
                                    <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-edit"></use></svg> Sửa sản phẩm
                                </a>
                            </c:if>
                        </div>
                    </form>

                    <!-- Overview snippet -->
                    <c:if test="${not empty product.description}">
                        <div class="ts-detail-overview">
                            <h3>Điểm nổi bật</h3>
                            <p><c:out value="${product.description}"/></p>
                        </div>
                    </c:if>
                </div>
            </div>
        </section>

        <!-- Technical Specification Section -->
        <section class="ts-section ts-specs-section" aria-labelledby="ts-specs-heading">
            <div class="ts-section-heading">
                <h2 id="ts-specs-heading">Thông số & Chi tiết sản phẩm</h2>
            </div>
            <div class="ts-specs-table-wrap">
                <table class="ts-specs-table">
                    <tbody>
                        <tr>
                            <th scope="row">Mã sản phẩm (ID)</th>
                            <td>#<c:out value="${product.productId}"/></td>
                        </tr>
                        <tr>
                            <th scope="row">Tên sản phẩm</th>
                            <td><c:out value="${product.productName}"/></td>
                        </tr>
                        <tr>
                            <th scope="row">Thương hiệu</th>
                            <td><c:out value="${product.brandName}"/></td>
                        </tr>
                        <tr>
                            <th scope="row">Danh mục</th>
                            <td><c:out value="${product.categoryName}"/></td>
                        </tr>
                        <tr>
                            <th scope="row">Thời hạn bảo hành</th>
                            <td><c:out value="${product.warrantyPeriod}"/> tháng</td>
                        </tr>
                        <tr>
                            <th scope="row">Tình trạng kho</th>
                            <td>
                                <c:choose>
                                    <c:when test="${product.stockQuantity > 0}">Còn hàng (<c:out value="${product.stockQuantity}"/> cái)</c:when>
                                    <c:otherwise>Hết hàng</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row">Mô tả chi tiết</th>
                            <td><c:out value="${not empty product.description ? product.description : 'Đang cập nhật nội dung chi tiết...'}"/></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Related Products Section -->
        <c:if test="${not empty relatedProducts}">
            <section class="ts-section ts-related-section" aria-labelledby="ts-related-heading">
                <div class="ts-section-heading">
                    <div>
                        <h2 id="ts-related-heading">Sản phẩm tương tự</h2>
                        <p>Các thiết bị cùng danh mục <c:out value="${product.categoryName}"/> bạn có thể quan tâm.</p>
                    </div>
                    <a class="ts-text-link" href="${pageContext.request.contextPath}/home?category=${product.categoryId}#danh-sach">Xem tất cả <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-arrow"></use></svg></a>
                </div>
                <div class="ts-product-grid ts-scroll-row">
                    <c:forEach var="rel" items="${relatedProducts}">
                        <article class="ts-product" data-product-id="${rel.productId}">
                            <a href="${pageContext.request.contextPath}/product-detail?id=${rel.productId}" class="ts-product-card-link" aria-label="Xem chi tiết ${fn:escapeXml(rel.productName)}">
                                <span class="ts-media">
                                    <c:set var="relImg" value="${fn:trim(rel.imageUrl)}"/>
                                    <c:set var="relScheme" value="${fn:toLowerCase(relImg)}"/>
                                    <c:choose>
                                        <c:when test="${not empty relImg and (fn:startsWith(relScheme, 'https://') or fn:startsWith(relScheme, 'http://') or (not fn:contains(relImg, ':') and not fn:startsWith(relImg, '//')))}">
                                            <c:url var="relImgUrl" value="${relImg}"/>
                                            <img src="${relImgUrl}" alt="${fn:escapeXml(rel.productName)}" width="500" height="500" loading="lazy" decoding="async">
                                            <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg><span>Ảnh đang cập nhật</span></span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <div class="ts-product-body">
                                    <p class="ts-product-brand"><c:out value="${rel.brandName}"/></p>
                                    <h3><c:out value="${rel.productName}"/></h3>
                                    <p class="ts-price"><fmt:formatNumber value="${rel.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></p>
                                </div>
                            </a>
                        </article>
                    </c:forEach>
                </div>
            </section>
        </c:if>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

    <script>
        function decreaseQty() {
            const input = document.getElementById('ts-qty-input');
            let val = parseInt(input.value, 10) || 1;
            if (val > 1) {
                input.value = val - 1;
            }
        }
        function increaseQty(maxStock) {
            const input = document.getElementById('ts-qty-input');
            let val = parseInt(input.value, 10) || 1;
            if (maxStock > 0 && val < maxStock) {
                input.value = val + 1;
            } else if (maxStock <= 0) {
                input.value = 1;
            }
        }
    </script>
</body>
</html>
