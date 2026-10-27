<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Thống kê | TechStore</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/order-experience.css?v=1"></head>

            <body class="orders-page dashboard-page">
                <fmt:setLocale value="vi_VN" />

                <!-- SVG Symbols -->
                <svg style="display:none" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <symbol id="icon-cart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
                            stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="9" cy="21" r="1" />
                            <circle cx="20" cy="21" r="1" />
                            <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
                        </symbol>
                        <symbol id="icon-orders" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="18" height="18" rx="2" />
                            <path d="M9 7h6M9 11h6M9 15h4" />
                        </symbol>
                        <symbol id="icon-home" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
                            stroke-linecap="round" stroke-linejoin="round">
                            <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                            <polyline points="9 22 9 12 15 12 15 22" />
                        </symbol>
                        <symbol id="icon-dashboard" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="7" height="9" rx="1" />
                            <rect x="14" y="3" width="7" height="5" rx="1" />
                            <rect x="14" y="12" width="7" height="9" rx="1" />
                            <rect x="3" y="16" width="7" height="5" rx="1" />
                        </symbol>
                        <symbol id="icon-admin-orders" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M16 3h5v5M4 20 21 3M21 16v5h-5M15 15l6 6M4 4l5 5" />
                        </symbol>
                        <symbol id="icon-dollar" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="12" y1="1" x2="12" y2="23" />
                            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
                        </symbol>
                        <symbol id="icon-package" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <path
                                d="m12.89 1.45 8 4A2 2 0 0 1 22 7.24v9.53a2 2 0 0 1-1.11 1.79l-8 4a2 2 0 0 1-1.79 0l-8-4A2 2 0 0 1 2 16.76V7.24a2 2 0 0 1 1.11-1.79l8-4a2 2 0 0 1 1.78 0z" />
                            <polyline points="2.32 6.16 12 11 21.68 6.16" />
                            <line x1="12" y1="22.76" x2="12" y2="11" />
                        </symbol>
                        <symbol id="icon-check-circle" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                            <polyline points="22 4 12 14.01 9 11.01" />
                        </symbol>
                        <symbol id="icon-trophy" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6" />
                            <path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18" />
                            <path d="M4 22h16" />
                            <path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20 7 22" />
                            <path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20 17 22" />
                            <path d="M18 2H6v7a6 6 0 0 0 12 0V2Z" />
                        </symbol>
                    </defs>
                </svg>

                <!-- Header -->
                <header class="ts-header">
                    <div class="ts-container ts-header-inner">
                        <a class="ts-logo" href="${pageContext.request.contextPath}/home">
                            <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true">
                                <path
                                    d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26"
                                    stroke="currentColor" stroke-width="2.5" stroke-linecap="round" />
                            </svg>
                            <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
                        </a>
                        <nav class="module-nav" aria-label="Điều hướng module">
                            <a href="${pageContext.request.contextPath}/home">
                                <svg class="nav-icon">
                                    <use href="#icon-home" />
                                </svg> Trang chủ
                            </a>
                            <a href="${pageContext.request.contextPath}/cart">
                                <svg class="nav-icon">
                                    <use href="#icon-cart" />
                                </svg> Giỏ hàng
                            </a>
                            <c:if test="${sessionScope.user.role == 'CUSTOMER'}">
                                <a href="${pageContext.request.contextPath}/orders">
                                    <svg class="nav-icon">
                                        <use href="#icon-orders" />
                                    </svg> Đơn hàng của tôi
                                </a>
                            </c:if>
                            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                <a href="${pageContext.request.contextPath}/admin/orders">
                                    <svg class="nav-icon">
                                        <use href="#icon-admin-orders" />
                                    </svg> Quản lý đơn hàng
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/dashboard" class="is-active">
                                    <svg class="nav-icon">
                                        <use href="#icon-dashboard" />
                                    </svg> Thống kê
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
                        <span class="current">Thống kê bán hàng</span>
                    </div>

                    <!-- Page Header -->
                    <div class="page-header">
                        <div>
                            <span class="experience-eyebrow">TECHSTORE / TỔNG QUAN KINH DOANH</span><h1 class="page-title">Thống kê bán hàng</h1>
                            <p class="page-subtitle">Tổng quan doanh thu, đơn hàng và sản phẩm bán chạy</p>
                        </div>
                    </div>

                    <!-- Error Alert -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-error" role="alert">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10" />
                                <line x1="15" y1="9" x2="9" y2="15" />
                                <line x1="9" y1="9" x2="15" y2="15" />
                            </svg>
                            <c:out value="${errorMessage}" />
                        </div>
                    </c:if>

                    <c:if test="${not empty stats}">
                        <!-- Metrics Grid -->
                        <div class="metrics-grid">
                            <div class="metric-card metric-revenue">
                                <div class="metric-icon">
                                    <svg>
                                        <use href="#icon-dollar" />
                                    </svg>
                                </div>
                                <div class="metric-value">
                                    <fmt:formatNumber value="${stats.revenue}" type="number" /> ₫
                                </div>
                                <div class="metric-label">Doanh thu từ đơn hoàn tất</div><span class="metric-explanation">Không tính đơn chờ xử lý hoặc đã hủy</span>
                            </div>
                            <div class="metric-card metric-orders">
                                <div class="metric-icon">
                                    <svg>
                                        <use href="#icon-package" />
                                    </svg>
                                </div>
                                <div class="metric-value">${stats.totalOrders}</div>
                                <div class="metric-label">Tổng đơn hàng</div><span class="metric-explanation">Bao gồm tất cả trạng thái</span>
                            </div>
                            <div class="metric-card metric-completed">
                                <div class="metric-icon">
                                    <svg>
                                        <use href="#icon-check-circle" />
                                    </svg>
                                </div>
                                <div class="metric-value">${stats.completedOrders}</div>
                                <div class="metric-label">Đơn hoàn tất</div><span class="metric-explanation">Đã kết thúc quá trình mua hàng</span>
                            </div>
                        </div>

<section class="dashboard-insight" aria-label="Tình hình đơn hàng">
<div><span class="experience-eyebrow">HIỆU QUẢ ĐƠN HÀNG</span><h2>Tỷ lệ đơn hoàn tất</h2><p>${stats.completedOrders} / ${stats.totalOrders} đơn hàng đã hoàn tất</p></div>
<div class="dashboard-completion"><strong><fmt:formatNumber value="${stats.totalOrders > 0 ? stats.completedOrders * 100.0 / stats.totalOrders : 0}" maxFractionDigits="1"/>%</strong><progress value="${stats.completedOrders}" max="${stats.totalOrders > 0 ? stats.totalOrders : 1}" aria-label="Tỷ lệ đơn hoàn tất"></progress></div>
<a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-primary">Quản lý đơn hàng →</a>
</section>
<div class="dashboard-section-label"><div><span class="experience-eyebrow">SẢN PHẨM NỔI BẬT</span><h2>Hiệu quả bán hàng</h2></div><span>Toàn bộ thời gian</span></div>
<!-- Best Selling Products -->
                        <div class="card">
                            <div class="card-header">
                                <div>
                                    <h2 class="card-title">
                                        <svg width="20" height="20" style="vertical-align:-3px; margin-right:6px;">
                                            <use href="#icon-trophy" />
                                        </svg>
                                        Top 10 sản phẩm bán chạy
                                    </h2>
                                    <p class="form-hint" style="margin-top:4px;">Chỉ tính các đơn hoàn tất, bao gồm sản
                                        phẩm đã ngừng bán.</p>
                                </div>
                            </div>
                            <c:choose>
                                <c:when test="${empty stats.bestSelling}">
                                    <div class="empty-state" style="padding: 32px;">
                                        <p>Chưa có sản phẩm bán ra từ đơn hoàn tất.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-container" style="border: none; border-radius: 0;">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th style="width:60px; text-align:center;">#</th>
                                                    <th>Sản phẩm</th>
                                                    <th style="text-align:center;">Số lượng bán</th>
                                                    <th style="text-align:right;">Doanh thu</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${stats.bestSelling}" var="item" varStatus="loop">
                                                    <tr>
                                                        <td style="text-align:center;">
                                                            <c:choose>
                                                                <c:when test="${loop.index == 0}"><span
                                                                        class="rank-badge rank-1">1</span></c:when>
                                                                <c:when test="${loop.index == 1}"><span
                                                                        class="rank-badge rank-2">2</span></c:when>
                                                                <c:when test="${loop.index == 2}"><span
                                                                        class="rank-badge rank-3">3</span></c:when>
                                                                <c:otherwise><span
                                                                        class="rank-badge rank-other">${loop.index +
                                                                        1}</span></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="td-product-name">
                                                            <c:out value="${item.productName}" />
                                                        </td>
                                                        <td style="text-align:center; font-weight:600;">
                                                            <div class="sales-volume"><strong>${item.unitsSold}</strong><meter min="0" max="${stats.bestSelling[0].unitsSold > 0 ? stats.bestSelling[0].unitsSold : 1}" value="${item.unitsSold}" aria-label="Số lượng sản phẩm đã bán">${item.unitsSold}</meter></div></td>
                                                        <td class="td-price" style="text-align:right;">
                                                            <fmt:formatNumber value="${item.revenue}" type="number" /> ₫
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>

                <!-- Footer -->
                <div class="ts-container">
                    <div class="module-footer">
                        TechStore · Dự án PRJ301 · FPT University · Nhóm 1
                    </div>
                </div>

            </body>

            </html>