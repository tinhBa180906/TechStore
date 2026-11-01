<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="robots" content="noindex,nofollow">
    <title><c:choose><c:when test="${not empty invoiceError}">Hóa đơn</c:when><c:otherwise>Hóa đơn <c:out value="${invoiceNumber}"/></c:otherwise></c:choose> | TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/invoice.css?v=1">
</head>
<body class="invoice-page">
<c:set var="invoiceBackUrl" value="${invoiceAdmin ? '/admin/orders' : '/orders'}"/>
<nav class="invoice-toolbar" aria-label="Thao tác hóa đơn">
    <a class="invoice-back" href="${pageContext.request.contextPath}${invoiceBackUrl}">← ${invoiceAdmin ? 'Quản lý đơn hàng' : 'Lịch sử mua hàng'}</a>
    <c:if test="${empty invoiceError}"><button class="invoice-print-button" type="button" onclick="window.print()"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 8V3h12v5M6 17H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2M6 14h12v7H6v-7Z"/><path d="M17 11h2"/></svg>In hóa đơn</button></c:if>
</nav>
<c:choose>
    <c:when test="${not empty invoiceError}">
        <main class="invoice-error" role="alert"><span>TECHSTORE / HÓA ĐƠN</span><h1>Không thể mở hóa đơn</h1><p><c:out value="${invoiceError}"/></p><a href="${pageContext.request.contextPath}${invoiceBackUrl}">Quay lại đơn hàng →</a></main>
    </c:when>
    <c:otherwise>
        <p class="invoice-print-hint">Để lưu PDF, chọn “Lưu thành PDF” trong cửa sổ in của trình duyệt.</p>
        <main class="invoice-document" aria-labelledby="invoice-title" data-invoice-id="${order.orderId}">
            <header class="invoice-document-header">
                <div class="invoice-brand"><svg viewBox="0 0 40 40" aria-hidden="true"><path d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26"/></svg><div><strong><c:out value="${seller.name}"/></strong><span>CÔNG NGHỆ CHO CUỘC SỐNG</span></div></div>
                <div class="invoice-code"><span>SỐ HÓA ĐƠN</span><strong><c:out value="${invoiceNumber}"/></strong><span>Đơn hàng #${order.orderId}</span></div>
            </header>
            <div class="invoice-title-block"><p>PHIẾU XÁC NHẬN MUA HÀNG NỘI BỘ</p><h1 id="invoice-title">HÓA ĐƠN BÁN HÀNG</h1><span>Ngày lập: <c:out value="${invoiceDate}"/></span></div>
            <section class="invoice-parties" aria-label="Thông tin người bán và người mua">
                <div class="invoice-party"><h2>01 / NGƯỜI BÁN</h2><strong><c:out value="${seller.name}"/></strong>
                    <c:if test="${not empty seller.address}"><p><c:out value="${seller.address}"/></p></c:if>
                    <c:if test="${not empty seller.phone}"><p><span>Điện thoại:</span> <c:out value="${seller.phone}"/></p></c:if>
                    <c:if test="${not empty seller.email}"><p><span>Email:</span> <c:out value="${seller.email}"/></p></c:if>
                    <c:if test="${not empty seller.taxCode}"><p><span>Mã số thuế:</span> <c:out value="${seller.taxCode}"/></p></c:if>
                    <c:if test="${order.paymentMethod == 'QR' and not empty seller.bankAccount}"><div class="invoice-bank"><p><c:out value="${seller.bankName}"/> · <c:out value="${seller.bankAccount}"/></p><p><c:out value="${seller.bankOwner}"/></p></div></c:if>
                </div>
                <div class="invoice-party"><h2>02 / NGƯỜI MUA</h2><strong><c:out value="${order.shippingName}"/></strong><p class="invoice-address"><c:out value="${order.shippingAddress}"/></p><p><span>Điện thoại:</span> <c:out value="${order.shippingPhone}"/></p><p><span>Mã khách hàng:</span> #${order.customerId}</p></div>
            </section>
            <dl class="invoice-order-meta">
                <div><dt>Ngày đặt hàng</dt><dd><c:out value="${orderDate}"/></dd></div>
                <div><dt>Phương thức</dt><dd><c:choose><c:when test="${order.paymentMethod == 'QR'}">Chuyển khoản VietQR (QR)</c:when><c:otherwise>Thanh toán khi nhận hàng (COD)</c:otherwise></c:choose></dd></div>
                <div><dt>Thanh toán</dt><dd><c:choose><c:when test="${order.paymentStatus == 'PAID'}">Đã xác nhận nhận tiền</c:when><c:when test="${order.paymentStatus == 'PENDING_VERIFY'}">Đang chờ xác minh</c:when><c:otherwise>Chưa ghi nhận thanh toán</c:otherwise></c:choose> <span class="invoice-state-code">(<c:out value="${order.paymentStatus}"/>)</span></dd></div>
                <div><dt>Đơn hàng</dt><dd>Đã hoàn tất <span class="invoice-state-code">(COMPLETED)</span></dd></div>
            </dl>
            <div class="invoice-table-scroll" role="region" aria-label="Chi tiết sản phẩm" tabindex="0">
                <table class="invoice-items"><caption>Chi tiết hàng hóa · Đơn vị tiền tệ: VND</caption><colgroup><col class="invoice-col-number"><col class="invoice-col-name"><col class="invoice-col-unit"><col class="invoice-col-quantity"><col class="invoice-col-price"><col class="invoice-col-total"></colgroup>
                    <thead><tr><th scope="col">STT</th><th scope="col">Tên sản phẩm</th><th scope="col">ĐVT</th><th scope="col" class="invoice-number">SL</th><th scope="col" class="invoice-number">Đơn giá (₫)</th><th scope="col" class="invoice-number">Thành tiền (₫)</th></tr></thead>
                    <tbody><c:forEach var="detail" items="${order.details}" varStatus="line"><tr data-invoice-line="${line.count}"><td class="invoice-line-number">${line.count}</td><td><strong><c:out value="${detail.product.productName}"/></strong><small>Mã SP: ${detail.productId}</small></td><td class="invoice-unit">Cái</td><td class="invoice-number invoice-quantity">${detail.quantity}</td><td class="invoice-number invoice-unit-price"><fmt:formatNumber value="${detail.unitPrice}" type="number" maxFractionDigits="0"/></td><td class="invoice-number invoice-line-total"><fmt:formatNumber value="${detail.unitPrice * detail.quantity}" type="number" maxFractionDigits="0"/></td></tr></c:forEach></tbody>
                </table>
            </div>
            <section class="invoice-closing" aria-label="Tổng tiền và xác nhận">
                <dl class="invoice-totals"><div><dt>Tổng tiền hàng</dt><dd><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/> ₫</dd></div><div class="invoice-grand-total"><dt>TỔNG THANH TOÁN</dt><dd><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/> ₫</dd></div></dl>
                <p class="invoice-amount-in-words"><strong>Số tiền bằng chữ:</strong> <c:out value="${amountInWords}"/></p>
                <div class="invoice-signatures"><div><strong>Người mua hàng</strong><span>(Ký, ghi rõ họ tên khi cần)</span><p><c:out value="${order.shippingName}"/></p></div><div><strong>Người bán hàng</strong><span>Xác nhận từ hệ thống TechStore</span><p><c:out value="${seller.name}"/></p></div></div>
                <footer class="invoice-document-footer"><strong>Cảm ơn quý khách đã tin tưởng TechStore.</strong><p>Đây là phiếu xác nhận mua hàng điện tử nội bộ, không phải hóa đơn GTGT.</p><p>Tra cứu đơn hàng: <c:out value="${invoiceNumber}"/> · techstore / prj301</p></footer>
            </section>
        </main>
    </c:otherwise>
</c:choose>
</body>
</html>
