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
    <title>Quản lý sản phẩm (Admin CRUD) — TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="techstore-home techstore-page ts-admin-body" id="admin-san-pham">

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="activePage" value="admin"/>
    </jsp:include>

    <main class="ts-container ts-admin-container" id="noi-dung">
        <!-- Admin Header / Breadcrumbs -->
        <div class="ts-admin-header-bar">
            <div>
                <nav class="ts-breadcrumbs" aria-label="Đường dẫn điều hướng">
                    <ol>
                        <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                        <li><span class="ts-breadcrumb-sep">/</span></li>
                        <li><span>Quản trị</span></li>
                        <li><span class="ts-breadcrumb-sep">/</span></li>
                        <li aria-current="page"><strong>Quản lý sản phẩm (CRUD)</strong></li>
                    </ol>
                </nav>
                <h1 class="ts-admin-page-title">Quản lý kho hàng &amp; Sản phẩm</h1>
            </div>
            <div class="ts-admin-header-actions">
                <a href="${pageContext.request.contextPath}/admin/products?action=create" class="ts-button ts-button-primary ts-btn-add">
                    <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-plus"></use></svg> Thêm sản phẩm mới
                </a>
            </div>
        </div>

        <!-- Notification Alerts -->
        <c:if test="${not empty msg}">
            <div class="ts-alert ts-alert-success" role="alert">
                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-check"></use></svg>
                <span>
                    <c:choose>
                        <c:when test="${msg eq 'create_success'}">Thêm mới sản phẩm thành công!</c:when>
                        <c:when test="${msg eq 'update_success'}">Cập nhật sản phẩm thành công!</c:when>
                        <c:when test="${msg eq 'delete_success'}">Đã xóa hoặc ngưng kinh doanh sản phẩm an toàn!</c:when>
                        <c:when test="${msg eq 'toggle_success'}">Đã thay đổi trạng thái kích hoạt của sản phẩm!</c:when>
                        <c:otherwise><c:out value="${msg}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="ts-alert ts-alert-danger" role="alert">
                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-close"></use></svg>
                <span>
                    <c:choose>
                        <c:when test="${error eq 'not_found'}">Không tìm thấy sản phẩm yêu cầu!</c:when>
                        <c:when test="${error eq 'invalid_id'}">Mã sản phẩm không hợp lệ!</c:when>
                        <c:when test="${error eq 'db_error'}">Lỗi kết nối cơ sở dữ liệu khi thao tác!</c:when>
                        <c:otherwise><c:out value="${error}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </c:if>

        <!-- Stats Overview Cards -->
        <div class="ts-admin-stats-grid">
            <div class="ts-admin-stat-card">
                <span class="ts-stat-number"><fmt:formatNumber value="${stats[0]}" maxFractionDigits="0"/></span>
                <span class="ts-stat-label">Tổng sản phẩm</span>
            </div>
            <div class="ts-admin-stat-card ts-stat-active">
                <span class="ts-stat-number"><fmt:formatNumber value="${stats[1]}" maxFractionDigits="0"/></span>
                <span class="ts-stat-label">Đang kinh doanh</span>
            </div>
            <div class="ts-admin-stat-card ts-stat-inactive">
                <span class="ts-stat-number"><fmt:formatNumber value="${stats[2]}" maxFractionDigits="0"/></span>
                <span class="ts-stat-label">Ngừng kinh doanh</span>
            </div>
            <div class="ts-admin-stat-card ts-stat-stock">
                <span class="ts-stat-number"><fmt:formatNumber value="${stats[3]}" maxFractionDigits="0"/></span>
                <span class="ts-stat-label">Hết hàng tồn</span>
            </div>
        </div>

        <!-- Filter and Search Toolbar -->
        <div class="ts-admin-toolbar">
            <form action="${pageContext.request.contextPath}/admin/products" method="get" class="ts-admin-filter-form">
                <div class="ts-admin-search-box">
                    <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-search"></use></svg>
                    <input type="search" name="q" placeholder="Tìm theo tên hoặc mô tả sản phẩm..." value="${fn:escapeXml(currentKeyword)}">
                </div>
                <div class="ts-admin-filter-selects">
                    <select name="category" onchange="this.form.submit()" aria-label="Lọc theo danh mục">
                        <option value="0">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}" ${selectedCategory == cat.categoryId ? 'selected' : ''}><c:out value="${cat.categoryName}"/></option>
                        </c:forEach>
                    </select>

                    <select name="brand" onchange="this.form.submit()" aria-label="Lọc theo thương hiệu">
                        <option value="0">Tất cả thương hiệu</option>
                        <c:forEach var="b" items="${brands}">
                            <option value="${b.brandId}" ${selectedBrand == b.brandId ? 'selected' : ''}><c:out value="${b.brandName}"/></option>
                        </c:forEach>
                    </select>

                    <select name="status" onchange="this.form.submit()" aria-label="Lọc theo trạng thái">
                        <option value="all" ${selectedStatus == 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="active" ${selectedStatus == 'active' ? 'selected' : ''}>Đang kinh doanh</option>
                        <option value="inactive" ${selectedStatus == 'inactive' ? 'selected' : ''}>Ngừng kinh doanh</option>
                    </select>

                    <button type="submit" class="ts-button ts-button-secondary">Lọc dữ liệu</button>
                    <c:if test="${not empty currentKeyword or selectedCategory > 0 or selectedBrand > 0 or selectedStatus != 'all'}">
                        <a href="${pageContext.request.contextPath}/admin/products" class="ts-button ts-button-outline">Xóa lọc</a>
                    </c:if>
                </div>
            </form>
        </div>

        <!-- Product Table -->
        <div class="ts-admin-table-container">
            <table class="ts-admin-table" aria-label="Bảng danh sách sản phẩm quản trị">
                <thead>
                    <tr>
                        <th scope="col" style="width: 60px;">ID</th>
                        <th scope="col" style="width: 80px;">Hình ảnh</th>
                        <th scope="col">Tên sản phẩm</th>
                        <th scope="col">Danh mục</th>
                        <th scope="col">Giá niêm yết</th>
                        <th scope="col" style="text-align: center;">Tồn kho</th>
                        <th scope="col" style="text-align: center;">Đã bán</th>
                        <th scope="col" style="text-align: center;">Nổi bật</th>
                        <th scope="col" style="text-align: center;">Trạng thái</th>
                        <th scope="col" style="text-align: right; width: 170px;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty products}">
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td><strong>#<c:out value="${p.productId}"/></strong></td>
                                    <td>
                                        <div class="ts-table-thumb">
                                            <c:set var="thumbPath" value="${fn:trim(p.imageUrl)}"/>
                                            <c:set var="thumbScheme" value="${fn:toLowerCase(thumbPath)}"/>
                                            <c:choose>
                                                <c:when test="${not empty thumbPath and (fn:startsWith(thumbScheme, 'https://') or fn:startsWith(thumbScheme, 'http://') or (not fn:contains(thumbPath, ':') and not fn:startsWith(thumbPath, '//')))}">
                                                    <c:url var="thumbUrl" value="${thumbPath}"/>
                                                    <img src="${thumbUrl}" alt="${fn:escapeXml(p.productName)}" width="50" height="50" loading="lazy">
                                                    <span class="ts-image-fallback" hidden><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="ts-image-fallback"><svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="ts-table-product-info">
                                            <a href="${pageContext.request.contextPath}/product-detail?id=${p.productId}" target="_blank" class="ts-table-product-name" title="Xem chi tiết trên cửa hàng">
                                                <c:out value="${p.productName}"/>
                                            </a>
                                            <span class="ts-table-brand-tag"><c:out value="${p.brandName}"/> · BH: <c:out value="${p.warrantyPeriod}"/> tháng</span>
                                        </div>
                                    </td>
                                    <td><span class="ts-badge ts-badge-category"><c:out value="${p.categoryName}"/></span></td>
                                    <td><strong class="ts-table-price"><fmt:formatNumber value="${p.price}" type="currency" currencyCode="VND" minFractionDigits="0" maxFractionDigits="0"/></strong></td>
                                    <td style="text-align: center;">
                                        <c:choose>
                                            <c:when test="${p.stockQuantity > 5}">
                                                <span class="ts-badge ts-badge-stock-ok"><c:out value="${p.stockQuantity}"/></span>
                                            </c:when>
                                            <c:when test="${p.stockQuantity > 0}">
                                                <span class="ts-badge ts-badge-stock-low">Ít: <c:out value="${p.stockQuantity}"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ts-badge ts-badge-stock-out">Hết hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: center;"><fmt:formatNumber value="${p.unitsSold}" maxFractionDigits="0"/></td>
                                    <td style="text-align: center;">
                                        <c:if test="${p.featured}">
                                            <span class="ts-badge ts-badge-featured" title="Sản phẩm nổi bật">⭐ Có</span>
                                        </c:if>
                                        <c:if test="${not p.featured}">
                                            <span style="color:var(--ts-muted); font-size:12px;">—</span>
                                        </c:if>
                                    </td>
                                    <td style="text-align: center;">
                                        <c:choose>
                                            <c:when test="${p.active}">
                                                <span class="ts-status-badge is-active">Đang bán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ts-status-badge is-inactive">Ngừng bán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <div class="ts-table-actions">
                                            <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.productId}" class="ts-action-btn ts-btn-edit" title="Chỉnh sửa sản phẩm">
                                                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-edit"></use></svg>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/products?action=toggle&id=${p.productId}" class="ts-action-btn ts-btn-toggle" title="${p.active ? 'Tắt kích hoạt (Ngừng bán)' : 'Bật kích hoạt (Mở bán)'}">
                                                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-check"></use></svg>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.productId}" onclick="return confirm('Bạn có chắc chắn muốn xóa/ngưng kinh doanh sản phẩm \'${p.productName}\'?')" class="ts-action-btn ts-btn-delete" title="Xóa hoặc ngưng kinh doanh">
                                                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-trash"></use></svg>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="10" class="ts-table-empty">
                                    <p>Không có sản phẩm nào phù hợp với bộ lọc tìm kiếm.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages gt 1}">
            <nav class="ts-pagination" aria-label="Phân trang sản phẩm quản trị">
                <c:choose>
                    <c:when test="${currentPage gt 1}">
                        <c:url var="prevAdminUrl" value="/admin/products">
                            <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}"/></c:if>
                            <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}"/></c:if>
                            <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                            <c:if test="${selectedStatus != 'all'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                            <c:param name="page" value="${currentPage - 1}"/>
                        </c:url>
                        <a class="ts-page-link" href="${prevAdminUrl}">Trước</a>
                    </c:when>
                    <c:otherwise><span class="ts-page-link is-disabled">Trước</span></c:otherwise>
                </c:choose>

                <c:forEach var="pNum" items="${pageNumbers}">
                    <c:choose>
                        <c:when test="${pNum eq currentPage}">
                            <span class="ts-page-link is-current"><c:out value="${pNum}"/></span>
                        </c:when>
                        <c:otherwise>
                            <c:url var="pUrl" value="/admin/products">
                                <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}"/></c:if>
                                <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}"/></c:if>
                                <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                                <c:if test="${selectedStatus != 'all'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                                <c:param name="page" value="${pNum}"/>
                            </c:url>
                            <a class="ts-page-link" href="${pUrl}"><c:out value="${pNum}"/></a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:choose>
                    <c:when test="${currentPage lt totalPages}">
                        <c:url var="nextAdminUrl" value="/admin/products">
                            <c:if test="${not empty currentKeyword}"><c:param name="q" value="${currentKeyword}"/></c:if>
                            <c:if test="${selectedCategory > 0}"><c:param name="category" value="${selectedCategory}"/></c:if>
                            <c:if test="${selectedBrand > 0}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                            <c:if test="${selectedStatus != 'all'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                            <c:param name="page" value="${currentPage + 1}"/>
                        </c:url>
                        <a class="ts-page-link" href="${nextAdminUrl}">Tiếp</a>
                    </c:when>
                    <c:otherwise><span class="ts-page-link is-disabled">Tiếp</span></c:otherwise>
                </c:choose>
            </nav>
        </c:if>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
