<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<footer class="ts-footer">
    <div class="ts-container ts-footer-main">
        <div>
            <a class="ts-logo" href="${pageContext.request.contextPath}/home"
                aria-label="TechStore — Về đầu trang">
                <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true">
                    <path
                        d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26"
                        stroke="currentColor" stroke-width="2.5" stroke-linecap="round" />
                </svg>
                <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
            </a>
            <p>Điện thoại, laptop, linh kiện và giải pháp công nghệ mỗi ngày.</p>
        </div>
        <nav aria-label="Điều hướng cuối trang">
            <a href="${pageContext.request.contextPath}/home#danh-muc">Danh mục</a>
            <a href="${pageContext.request.contextPath}/home#san-pham">Sản phẩm</a>
            <a href="${pageContext.request.contextPath}/home#thuong-hieu">Thương hiệu</a>
            <c:if test="${not empty sessionScope.user and sessionScope.user.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/products">Admin CRUD Sản phẩm</a>
            </c:if>
        </nav>
    </div>
    <div class="ts-container ts-footer-bottom">
        <p>TechStore · Dự án PRJ301 · FPT University · Nhóm 1 · Khuất Bá Tình</p>
        <p>Ảnh sản phẩm: <a href="https://www.apple.com/" rel="noopener noreferrer" target="_blank">Apple</a>,
            <a href="https://www.sony.jp/headphone/" rel="noopener noreferrer" target="_blank">Sony</a>, <a
                href="https://www.mi.com/global/" rel="noopener noreferrer" target="_blank">Xiaomi</a>.</p>
    </div>
</footer>

<script>
    // Universal image fallback, mobile drawer & profile dropdown handler
    (() => {
        const showFallback = (img) => {
            if (img.dataset.failed) return;
            img.dataset.failed = 'true';
            img.hidden = true;
            const fallback = img.parentElement ? img.parentElement.querySelector('.ts-image-fallback') : null;
            if (fallback) fallback.hidden = false;
        };
        document.querySelectorAll('.ts-media img').forEach((img) => {
            img.addEventListener('error', () => showFallback(img), { once: true });
            if (img.complete && img.naturalWidth === 0) showFallback(img);
        });

        const menu = document.querySelector('.ts-mobile-menu');
        if (menu) {
            const summary = menu.querySelector('summary');
            menu.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
                menu.open = false;
            }));
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape' && menu.open) {
                    menu.open = false;
                    if (summary) summary.focus();
                }
            });
            document.addEventListener('click', (event) => {
                if (menu.open && !menu.contains(event.target)) {
                    menu.open = false;
                }
            });
        }

        const profileDropdown = document.querySelector('.ts-profile-dropdown');
        if (profileDropdown) {
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape' && profileDropdown.open) {
                    profileDropdown.open = false;
                }
            });
            document.addEventListener('click', (event) => {
                if (profileDropdown.open && !profileDropdown.contains(event.target)) {
                    profileDropdown.open = false;
                }
            });
        }
    })();
</script>
