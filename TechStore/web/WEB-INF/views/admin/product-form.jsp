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
    <title>${formMode == 'edit' ? 'Chỉnh sửa' : 'Thêm mới'} sản phẩm — TechStore Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="techstore-home techstore-page ts-admin-body" id="admin-product-form">

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="activePage" value="admin"/>
    </jsp:include>

    <main class="ts-container ts-admin-container" id="noi-dung">
        <!-- Breadcrumbs -->
        <nav class="ts-breadcrumbs" aria-label="Đường dẫn điều hướng">
            <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li><span class="ts-breadcrumb-sep">/</span></li>
                <li><a href="${pageContext.request.contextPath}/admin/products">Quản trị sản phẩm</a></li>
                <li><span class="ts-breadcrumb-sep">/</span></li>
                <li aria-current="page"><strong>${formMode == 'edit' ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'}</strong></li>
            </ol>
        </nav>

        <div class="ts-admin-form-header">
            <h1 class="ts-admin-page-title">${formMode == 'edit' ? 'Chỉnh sửa thông tin sản phẩm' : 'Thêm sản phẩm mới vào hệ thống'}</h1>
            <p>Vui lòng điền đầy đủ các thông tin cần thiết. Các trường đánh dấu (<span style="color:#d93025;">*</span>) là bắt buộc.</p>
        </div>

        <!-- Error Messages Box -->
        <c:if test="${not empty errors}">
            <div class="ts-alert ts-alert-danger" role="alert">
                <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-close"></use></svg>
                <div>
                    <strong>Đã xảy ra lỗi vui lòng kiểm tra lại:</strong>
                    <ul style="margin: 6px 0 0 16px; padding: 0;">
                        <c:forEach var="err" items="${errors}">
                            <li><c:out value="${err}"/></li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </c:if>

        <!-- Product Form Card -->
        <div class="ts-admin-form-card">
            <form action="${pageContext.request.contextPath}/admin/products" method="post" class="ts-form-grid" novalidate>
                <input type="hidden" name="action" value="${formMode}">
                <c:if test="${formMode == 'edit'}">
                    <input type="hidden" name="productId" value="${product.productId}">
                </c:if>

                <div class="ts-form-layout">
                    <!-- Left Column: Main Info -->
                    <div class="ts-form-main-col">
                        <div class="ts-form-group">
                            <label for="productName" class="ts-form-label">Tên sản phẩm <span style="color:#d93025;">*</span></label>
                            <input type="text" id="productName" name="productName" class="ts-form-input" 
                                   placeholder="Ví dụ: iPhone 15 Pro Max 256GB..." 
                                   value="${fn:escapeXml(product.productName)}" required maxlength="150">
                            <small class="ts-form-hint">Tên sản phẩm phải là duy nhất, tối đa 150 ký tự.</small>
                        </div>

                        <div class="ts-form-row-2">
                            <div class="ts-form-group">
                                <label for="brandId" class="ts-form-label">Thương hiệu <span style="color:#d93025;">*</span></label>
                                <select id="brandId" name="brandId" class="ts-form-select" required>
                                    <option value="">-- Chọn thương hiệu --</option>
                                    <c:forEach var="b" items="${brands}">
                                        <option value="${b.brandId}" ${product.brandId == b.brandId ? 'selected' : ''}>
                                            <c:out value="${b.brandName}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="ts-form-group">
                                <label for="categoryId" class="ts-form-label">Danh mục <span style="color:#d93025;">*</span></label>
                                <select id="categoryId" name="categoryId" class="ts-form-select" required>
                                    <option value="">-- Chọn danh mục --</option>
                                    <c:forEach var="c" items="${categories}">
                                        <option value="${c.categoryId}" ${product.categoryId == c.categoryId ? 'selected' : ''}>
                                            <c:out value="${c.categoryName}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <div class="ts-form-row-3">
                            <div class="ts-form-group">
                                <label for="price" class="ts-form-label">Giá niêm yết (VND) <span style="color:#d93025;">*</span></label>
                                <input type="number" id="price" name="price" class="ts-form-input" 
                                       placeholder="29990000" min="1000" step="1000" 
                                       value="${product.price != null ? product.price.toBigInteger() : ''}" required>
                            </div>

                            <div class="ts-form-group">
                                <label for="stockQuantity" class="ts-form-label">Số lượng tồn kho <span style="color:#d93025;">*</span></label>
                                <input type="number" id="stockQuantity" name="stockQuantity" class="ts-form-input" 
                                       placeholder="10" min="0" step="1" 
                                       value="${product.stockQuantity}" required>
                            </div>

                            <div class="ts-form-group">
                                <label for="warrantyPeriod" class="ts-form-label">Bảo hành (tháng) <span style="color:#d93025;">*</span></label>
                                <input type="number" id="warrantyPeriod" name="warrantyPeriod" class="ts-form-input" 
                                       placeholder="12" min="0" step="1" 
                                       value="${product.warrantyPeriod}" required>
                            </div>
                        </div>

                        <div class="ts-form-group">
                            <label for="description" class="ts-form-label">Mô tả sản phẩm</label>
                            <textarea id="description" name="description" class="ts-form-textarea" rows="6" 
                                      placeholder="Mô tả tóm tắt tính năng, thông số nổi bật của thiết bị..." 
                                      maxlength="1000"><c:out value="${product.description}"/></textarea>
                            <small class="ts-form-hint">Tối đa 1000 ký tự.</small>
                        </div>
                    </div>

                    <!-- Right Column: Media & Status -->
                    <div class="ts-form-side-col">
                        <div class="ts-form-group">
                            <label for="imageUrl" class="ts-form-label">URL Hình ảnh</label>
                            <input type="url" id="imageUrl" name="imageUrl" class="ts-form-input" 
                                   placeholder="https://example.com/image.png" 
                                   value="${fn:escapeXml(product.imageUrl)}" oninput="updateImagePreview(this.value)">
                            <small class="ts-form-hint">Đường dẫn ảnh định dạng HTTPS / HTTP hoặc để trống.</small>
                        </div>

                        <!-- Image Live Preview -->
                        <div class="ts-form-image-preview-box">
                            <span class="ts-form-preview-label">Xem trước hình ảnh:</span>
                            <div class="ts-media ts-form-preview-media">
                                <img id="ts-live-preview-img" 
                                     src="${not empty product.imageUrl ? product.imageUrl : ''}" 
                                     alt="Xem trước hình ảnh" 
                                     style="${empty product.imageUrl ? 'display:none;' : ''}"
                                     onerror="handlePreviewError()">
                                <div id="ts-preview-placeholder" class="ts-image-fallback" style="${not empty product.imageUrl ? 'display:none;' : ''}">
                                    <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-image"></use></svg>
                                    <span>Chưa có ảnh</span>
                                </div>
                            </div>
                        </div>

                        <!-- Status & Flags -->
                        <div class="ts-form-options-card">
                            <span class="ts-form-preview-label">Cấu hình hiển thị:</span>

                            <label class="ts-checkbox-label">
                                <input type="checkbox" name="isFeatured" value="true" ${product.featured ? 'checked' : ''}>
                                <span>⭐ <strong>Sản phẩm nổi bật</strong> (Ưu tiên hiển thị ở banner trang chủ)</span>
                            </label>

                            <label class="ts-checkbox-label">
                                <input type="checkbox" name="isActive" value="true" ${product.active or empty product ? 'checked' : ''}>
                                <span>✅ <strong>Kích hoạt mở bán</strong> (Cho phép khách hàng xem và mua)</span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Form Action Buttons -->
                <div class="ts-form-actions">
                    <button type="submit" class="ts-button ts-button-primary">
                        <svg class="ts-icon" aria-hidden="true" focusable="false"><use href="#ts-check"></use></svg> ${formMode == 'edit' ? 'Lưu thay đổi' : 'Thêm sản phẩm'}
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/products" class="ts-button ts-button-outline">
                        Hủy &amp; Quay lại danh sách
                    </a>
                </div>
            </form>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

    <script>
        function updateImagePreview(url) {
            const img = document.getElementById('ts-live-preview-img');
            const placeholder = document.getElementById('ts-preview-placeholder');
            if (url && url.trim().length > 0) {
                img.src = url.trim();
                img.style.display = 'block';
                placeholder.style.display = 'none';
            } else {
                img.style.display = 'none';
                placeholder.style.display = 'flex';
            }
        }

        function handlePreviewError() {
            const img = document.getElementById('ts-live-preview-img');
            const placeholder = document.getElementById('ts-preview-placeholder');
            img.style.display = 'none';
            placeholder.style.display = 'flex';
        }
    </script>
</body>
</html>
