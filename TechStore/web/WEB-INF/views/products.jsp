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
    <meta name="description" content="Khám phá và tìm kiếm sản phẩm điện thoại, laptop, phụ kiện và màn hình tại TechStore.">
    <title>Khám phá & Tìm kiếm sản phẩm — TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="techstore-home techstore-page" id="tim-kiem-san-pham">

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="activePage" value="products"/>
    </jsp:include>

    <main class="ts-container" id="noi-dung" tabindex="-1">
        <!-- Breadcrumb Navigation -->
        <nav class="ts-breadcrumbs" aria-label="Đường dẫn điều hướng" style="margin-top: 18px;">
            <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li><span class="ts-breadcrumb-sep">/</span></li>
                <li aria-current="page"><span>Khám phá sản phẩm</span></li>
            </ol>
        </nav>

        <section class="ts-section ts-catalog-section" id="danh-sach" aria-labelledby="ts-catalog-title" style="border-top: none; padding-top: 14px;">
            <div class="ts-section-heading">
                <div>
                    <h1 id="ts-catalog-title" style="font-size: 26px; font-weight: 700; color: var(--ts-navy); margin-bottom: 4px;">Khám phá sản phẩm</h1>
                    <p style="color: var(--ts-muted); font-size: 14px;">Tìm thiết bị phù hợp với cách bạn sống và làm việc.</p>
                </div>
                <c:if test="${empty dataLoadError}">
                    <span class="ts-preview-label">
                        <fmt:formatNumber value="${totalProducts}" maxFractionDigits="0" /> sản phẩm
                    </span>
                </c:if>
            </div>

            <!-- Active Search & Filter Toolbar -->
            <c:if test="${empty dataLoadError}">
                <form class="ts-filters" id="ts-filter-form" action="${pageContext.request.contextPath}/products" method="get">
                    <div class="ts-filter ts-filter-search">
                        <label for="ts-search-input">Tên sản phẩm</label>
                        <div class="ts-input-icon">
                            <svg class="ts-icon" aria-hidden="true" focusable="false">
                                <use href="#ts-search"></use>
                            </svg>
                            <input id="ts-search-input" name="q" type="search"
                                placeholder="Bạn đang tìm gì?" value="${fn:escapeXml(currentKeyword)}" autofocus>
                        </div>
                    </div>
                    <div class="ts-filter">
                        <label for="ts-category">Danh mục</label>
                        <select id="ts-category" name="category" onchange="this.form.submit()">
                            <option value="0">Tất cả danh mục</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${selectedCategory == cat.categoryId ? 'selected' : ''}>
                                    <c:out value="${cat.categoryName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="ts-filter">
                        <label for="ts-brand">Thương hiệu</label>
                        <select id="ts-brand" name="brand" onchange="this.form.submit()">
                            <option value="0">Tất cả thương hiệu</option>
                            <c:forEach var="br" items="${brands}">
                                <option value="${br.brandId}" ${selectedBrand == br.brandId ? 'selected' : ''}>
                                    <c:out value="${br.brandName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="ts-filter">
                        <label for="ts-price">Khoảng giá</label>
                        <select id="ts-price" name="price" onchange="this.form.submit()">
                            <option value="all" ${selectedPrice == 'all' ? 'selected' : ''}>Tất cả mức giá</option>
                            <option value="under10" ${selectedPrice == 'under10' ? 'selected' : ''}>Dưới 10 triệu</option>
                            <option value="10to20" ${selectedPrice == '10to20' ? 'selected' : ''}>10–20 triệu</option>
                            <option value="above20" ${selectedPrice == 'above20' ? 'selected' : ''}>Trên 20 triệu</option>
                        </select>
                    </div>
                    <div class="ts-filter">
                        <label for="ts-sort">Sắp xếp</label>
                        <select id="ts-sort" name="sort" onchange="this.form.submit()">
                            <option value="newest" ${selectedSort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="price-asc" ${selectedSort == 'price-asc' ? 'selected' : ''}>Giá tăng dần</option>
                            <option value="price-desc" ${selectedSort == 'price-desc' ? 'selected' : ''}>Giá giảm dần</option>
                            <option value="bestselling" ${selectedSort == 'bestselling' ? 'selected' : ''}>Bán chạy nhất</option>
                            <option value="name-asc" ${selectedSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
                        </select>
                    </div>
                    <div class="ts-filter-actions-row">
                        <button type="submit" class="ts-button ts-button-primary"><svg class="ts-icon"
                                aria-hidden="true" focusable="false">
                                <use href="#ts-search"></use>
                            </svg> Tìm kiếm</button>
                        <c:if test="${not empty currentKeyword or selectedCategory > 0 or selectedBrand > 0 or (not empty selectedPrice and selectedPrice != 'all')}">
                            <a href="${pageContext.request.contextPath}/products"
                                class="ts-button ts-button-outline">Xóa bộ lọc</a>
                        </c:if>
                    </div>
                </form>
            </c:if>

            <c:choose>
                <c:when test="${not empty dataLoadError}">
                    <p class="ts-empty-state"><c:out value="${dataLoadError}"/></p>
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${not empty products}">
                            <div class="ts-product-grid ts-catalog-grid">
                                <c:forEach var="product" items="${products}">
                                    <article class="ts-product" data-product-id="${product.productId}">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${product.productId}" class="ts-product-card-link"
                                           aria-label="Xem chi tiết ${fn:escapeXml(product.productName)}">
                                            <span class="ts-media">
                                                <c:set var="imagePath" value="${fn:trim(product.imageUrl)}" />
                                                <c:set var="imageScheme" value="${fn:toLowerCase(imagePath)}" />
                                                <c:choose>
                                                    <c:when test="${not empty imagePath and (fn:startsWith(imageScheme, 'https://') or fn:startsWith(imageScheme, 'http://') or (not fn:contains(imagePath, ':') and not fn:startsWith(imagePath, '//')))}">
                                                        <c:url var="productImageUrl" value="${imagePath}" />
                                                        <img src="${productImageUrl}" alt="${fn:escapeXml(product.productName)}" width="500"
                                                             height="500" loading="lazy" decoding="async">
                                                        <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false">
                                                            <use href="#ts-image"></use>
                                                        </svg><span>Ảnh đang cập nhật</span></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false">
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
                            <p class="ts-empty-state">Hiện không có sản phẩm nào phù hợp với bộ lọc tìm kiếm của bạn.</p>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty products}">
                        <p class="ts-catalog-summary" role="status">Hiển thị
                            <fmt:formatNumber value="${firstProduct}" maxFractionDigits="0" />–<fmt:formatNumber value="${lastProduct}" maxFractionDigits="0" /> trong
                            <fmt:formatNumber value="${totalProducts}" maxFractionDigits="0" /> sản phẩm
                            · Trang
                            <fmt:formatNumber value="${currentPage}" maxFractionDigits="0" />/<fmt:formatNumber value="${totalPages}" maxFractionDigits="0" />
                        </p>
                    </c:if>
                    <c:if test="${totalPages gt 1}">
                        <nav class="ts-pagination" aria-label="Phân trang sản phẩm">
                            <c:choose>
                                <c:when test="${currentPage gt 1}">
                                    <c:url var="firstPageUrl" value="/products">
                                        <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}" /></c:if>
                                        <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}" /></c:if>
                                        <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}" /></c:if>
                                        <c:if test="${not empty selectedPrice and selectedPrice != 'all'}"><c:param name="price" value="${selectedPrice}" /></c:if>
                                        <c:if test="${not empty selectedSort and selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}" /></c:if>
                                        <c:param name="page" value="1" />
                                    </c:url>
                                    <c:url var="previousPageUrl" value="/products">
                                        <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}" /></c:if>
                                        <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}" /></c:if>
                                        <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}" /></c:if>
                                        <c:if test="${not empty selectedPrice and selectedPrice != 'all'}"><c:param name="price" value="${selectedPrice}" /></c:if>
                                        <c:if test="${not empty selectedSort and selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}" /></c:if>
                                        <c:param name="page" value="${currentPage - 1}" />
                                    </c:url>
                                    <a class="ts-page-link" href="${firstPageUrl}" aria-label="Trang đầu">Đầu</a>
                                    <a class="ts-page-link" href="${previousPageUrl}" aria-label="Trang trước" rel="prev">Trước</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-page-link is-disabled" aria-disabled="true">Đầu</span>
                                    <span class="ts-page-link is-disabled" aria-disabled="true">Trước</span>
                                </c:otherwise>
                            </c:choose>
                            <c:forEach var="pageNumber" items="${pageNumbers}">
                                <c:choose>
                                    <c:when test="${pageNumber eq currentPage}">
                                        <span class="ts-page-link is-current" aria-current="page" aria-label="Trang ${pageNumber}"><c:out value="${pageNumber}" /></span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:url var="pageUrl" value="/products">
                                            <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}" /></c:if>
                                            <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}" /></c:if>
                                            <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}" /></c:if>
                                            <c:if test="${not empty selectedPrice and selectedPrice != 'all'}"><c:param name="price" value="${selectedPrice}" /></c:if>
                                            <c:if test="${not empty selectedSort and selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}" /></c:if>
                                            <c:param name="page" value="${pageNumber}" />
                                        </c:url>
                                        <a class="ts-page-link" href="${pageUrl}" aria-label="Trang ${pageNumber}"><c:out value="${pageNumber}" /></a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:choose>
                                <c:when test="${currentPage lt totalPages}">
                                    <c:url var="nextPageUrl" value="/products">
                                        <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}" /></c:if>
                                        <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}" /></c:if>
                                        <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}" /></c:if>
                                        <c:if test="${not empty selectedPrice and selectedPrice != 'all'}"><c:param name="price" value="${selectedPrice}" /></c:if>
                                        <c:if test="${not empty selectedSort and selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}" /></c:if>
                                        <c:param name="page" value="${currentPage + 1}" />
                                    </c:url>
                                    <c:url var="lastPageUrl" value="/products">
                                        <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}" /></c:if>
                                        <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}" /></c:if>
                                        <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}" /></c:if>
                                        <c:if test="${not empty selectedPrice and selectedPrice != 'all'}"><c:param name="price" value="${selectedPrice}" /></c:if>
                                        <c:if test="${not empty selectedSort and selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}" /></c:if>
                                        <c:param name="page" value="${totalPages}" />
                                    </c:url>
                                    <a class="ts-page-link" href="${nextPageUrl}" aria-label="Trang tiếp" rel="next">Tiếp</a>
                                    <a class="ts-page-link" href="${lastPageUrl}" aria-label="Trang cuối">Cuối</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="ts-page-link is-disabled" aria-disabled="true">Tiếp</span>
                                    <span class="ts-page-link is-disabled" aria-disabled="true">Cuối</span>
                                </c:otherwise>
                            </c:choose>
                        </nav>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>

