<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <svg class="ts-symbols" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false"
                    style="display:none;">
                    <defs>
                        <symbol id="ts-arrow" viewBox="0 0 24 24">
                            <path d="M5 12h14m-5-5 5 5-5 5" />
                        </symbol>
                        <symbol id="ts-search" viewBox="0 0 24 24">
                            <circle cx="10.5" cy="10.5" r="6.5" />
                            <path d="m16 16 4.5 4.5" />
                        </symbol>
                        <symbol id="ts-menu" viewBox="0 0 24 24">
                            <path d="M4 6h16M4 12h16M4 18h16" />
                        </symbol>
                        <symbol id="ts-close" viewBox="0 0 24 24">
                            <path d="m6 6 12 12M6 18 18 6" />
                        </symbol>
                        <symbol id="ts-shield" viewBox="0 0 24 24">
                            <path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Z" />
                            <path d="m8 12 3 3 5-6" />
                        </symbol>
                        <symbol id="ts-document" viewBox="0 0 24 24">
                            <rect x="5" y="3" width="14" height="18" rx="2" />
                            <path d="M9 7h6M9 11h6M9 15h4" />
                        </symbol>
                        <symbol id="ts-headset" viewBox="0 0 24 24">
                            <path d="M4 14v-3a8 8 0 0 1 16 0v3" />
                            <rect x="3" y="11" width="4" height="7" rx="2" />
                            <rect x="17" y="11" width="4" height="7" rx="2" />
                            <path d="M19 18c0 3-3 3-7 3" />
                        </symbol>
                        <symbol id="ts-bag" viewBox="0 0 24 24">
                            <path d="M5 8h14l1 13H4L5 8Z" />
                            <path d="M8 8V6a4 4 0 0 1 8 0v2M9 14h6" />
                        </symbol>
                        <symbol id="ts-image" viewBox="0 0 24 24">
                            <rect x="3" y="3" width="18" height="18" rx="2" />
                            <circle cx="8" cy="8" r="1.5" />
                            <path d="m3 17 5-5 4 4 3-3 6 6" />
                        </symbol>
                        <symbol id="ts-info" viewBox="0 0 24 24">
                            <circle cx="12" cy="12" r="9" />
                            <path d="M12 11v6m0-10v1" />
                        </symbol>
                        <symbol id="ts-chevron" viewBox="0 0 24 24">
                            <path d="m9 5 7 7-7 7" />
                        </symbol>
                        <symbol id="ts-plus" viewBox="0 0 24 24">
                            <path d="M12 5v14M5 12h14" />
                        </symbol>
                        <symbol id="ts-edit" viewBox="0 0 24 24">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                        </symbol>
                        <symbol id="ts-trash" viewBox="0 0 24 24">
                            <polyline points="3 6 5 6 21 6" />
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                            <line x1="10" y1="11" x2="10" y2="17" />
                            <line x1="14" y1="11" x2="14" y2="17" />
                        </symbol>
                        <symbol id="ts-check" viewBox="0 0 24 24">
                            <polyline points="20 6 9 17 4 12" />
                        </symbol>
                    </defs>
                </svg>

                <a class="ts-skip-link" href="#noi-dung">Đến nội dung chính</a>

                <div class="ts-topbar">
                    <div class="ts-container ts-topbar-inner">
                        <p><svg class="ts-icon" aria-hidden="true" focusable="false">
                                <use href="#ts-bag"></use>
                            </svg> Khám phá công nghệ cùng TechStore</p>
                        <div class="ts-topbar-links">
                            <a href="${pageContext.request.contextPath}/admin/products?dev_admin=1"
                                class="ts-topbar-admin-badge" title="Chuyển đến trang Quản lý sản phẩm"><svg
                                    class="ts-icon" aria-hidden="true" focusable="false">
                                    <use href="#ts-document"></use>
                                </svg> Quản lý sản phẩm (Admin)</a>
                            <span class="ts-topbar-divider" aria-hidden="true">|</span>
                            <span>Tiếng Việt <span class="ts-topbar-divider" aria-hidden="true">|</span> VND</span>
                        </div>
                    </div>
                </div>

                <header class="ts-header">
                    <div class="ts-container ts-header-inner">
                        <a class="ts-logo" href="${pageContext.request.contextPath}/home"
                            aria-label="TechStore — Trang chủ">
                            <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true">
                                <path
                                    d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26"
                                    stroke="currentColor" stroke-width="2.5" stroke-linecap="round" />
                            </svg>
                            <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
                        </a>
                        <nav class="ts-desktop-nav" aria-label="Điều hướng chính">
                            <a href="${pageContext.request.contextPath}/home"
                                class="${param.activePage == 'home' ? 'is-active' : ''}">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/home#san-pham"
                                class="${param.activePage == 'products' ? 'is-active' : ''}">Sản phẩm</a>
                            <a href="${pageContext.request.contextPath}/home#danh-muc">Danh mục</a>
                            <a href="${pageContext.request.contextPath}/home#thuong-hieu">Thương hiệu</a>
                            <a href="${pageContext.request.contextPath}/home#moi-nhat">Mới nhất</a>
                            <a href="${pageContext.request.contextPath}/admin/products?dev_admin=1"
                                class="ts-nav-admin-link ${param.activePage == 'admin' ? 'is-active' : ''}"><svg
                                    class="ts-icon" aria-hidden="true" focusable="false">
                                    <use href="#ts-edit"></use>
                                </svg> Admin CRUD</a>
                        </nav>
                        <div class="ts-header-actions">
                            <a class="ts-search-link" href="${pageContext.request.contextPath}/home#danh-sach"
                                aria-label="Đến khu vực tìm sản phẩm"><svg class="ts-icon" aria-hidden="true"
                                    focusable="false">
                                    <use href="#ts-search"></use>
                                </svg><span>Tìm sản phẩm</span></a>
                        </div>
                        <details class="ts-mobile-menu">
                            <summary aria-label="Mở hoặc đóng menu điều hướng"><svg class="ts-icon ts-menu-open"
                                    aria-hidden="true" focusable="false">
                                    <use href="#ts-menu"></use>
                                </svg><svg class="ts-icon ts-menu-close" aria-hidden="true" focusable="false">
                                    <use href="#ts-close"></use>
                                </svg></summary>
                            <nav aria-label="Điều hướng trên di động">
                                <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                                <a href="${pageContext.request.contextPath}/home#san-pham">Sản phẩm</a>
                                <a href="${pageContext.request.contextPath}/home#danh-muc">Danh mục</a>
                                <a href="${pageContext.request.contextPath}/home#thuong-hieu">Thương hiệu</a>
                                <a href="${pageContext.request.contextPath}/home#moi-nhat">Mới nhất</a>
                                <a href="${pageContext.request.contextPath}/admin/products?dev_admin=1">Admin CRUD Sản
                                    phẩm</a>
                            </nav>
                        </details>
                    </div>
                </header>