<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Thanh toán VietQR | TechStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/payment-qr.css?v=3">
</head>
<body class="orders-page qr-payment-page">
<fmt:setLocale value="vi_VN"/>
<c:set var="qrActive" value="${order.orderStatus != 'CANCELLED' and order.paymentStatus != 'PAID'}"/>
<svg class="qrpay-symbols" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <defs>
        <symbol id="qrpay-copy" viewBox="0 0 24 24"><rect x="8" y="8" width="12" height="12" rx="3"/><path d="M15 8V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h3"/></symbol>
        <symbol id="qrpay-check" viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></symbol>
        <symbol id="qrpay-arrow" viewBox="0 0 24 24"><path d="m9 5 7 7-7 7"/></symbol>
        <symbol id="qrpay-scan" viewBox="0 0 24 24"><path d="M8 3H5a2 2 0 0 0-2 2v3m13-5h3a2 2 0 0 1 2 2v3M3 16v3a2 2 0 0 0 2 2h3m13-5v3a2 2 0 0 1-2 2h-3M3 12h18"/></symbol>
    </defs>
</svg>
<header class="qrpay-header">
    <div class="qrpay-header-inner">
        <a class="qrpay-brand" href="${pageContext.request.contextPath}/home" aria-label="TechStore — Trang chủ"><span class="qrpay-brand-mark">T</span>TechStore<span class="qrpay-brand-dot">.</span></a>
        <span class="qrpay-header-caption">Thanh toán đơn hàng</span>
    </div>
</header>
<main class="qrpay-shell">
    <div class="qrpay-heading">
        <div><p class="qrpay-eyebrow">BANK TRANSFER / VIETQR</p><h1>Thanh toán đơn hàng</h1></div>
        <span class="qrpay-order-id">Đơn #${order.orderId}</span>
    </div>
    <c:if test="${not empty errorMessage}"><p class="qrpay-alert" role="alert"><c:out value="${errorMessage}"/></p></c:if>
    <c:if test="${order.paymentStatus == 'PENDING_VERIFY' and qrActive and empty errorMessage}">
        <div class="qrpay-received" role="status" tabindex="-1" id="qrpay-received">
            <span class="qrpay-received-icon"><svg><use href="#qrpay-check"/></svg></span>
            <div><strong>Đã ghi nhận thông báo chuyển khoản</strong><p>TechStore sẽ đối chiếu giao dịch và xác nhận thanh toán.</p></div>
        </div>
    </c:if>
    <section class="qrpay-card" aria-label="Thông tin thanh toán">
        <div class="qrpay-scan-panel">
            <c:choose>
                <c:when test="${qrActive and not empty qrUrl and order.paymentStatus != 'PENDING_VERIFY'}">
                    <span class="qrpay-scan-label"><svg><use href="#qrpay-scan"/></svg>Quét bằng app ngân hàng</span>
                    <div class="qrpay-image-frame">
                        <img class="qrpay-image" src="<c:out value='${qrUrl}'/>" alt="VietQR cho đơn hàng ${order.orderId}" referrerpolicy="no-referrer"
                             onerror="this.hidden=true;document.getElementById('qrpay-image-error').hidden=false;">
                        <div id="qrpay-image-error" class="qrpay-image-error" role="alert" hidden>
                            <svg><use href="#qrpay-scan"/></svg><strong>Chưa tải được mã QR</strong><span>Dùng thông tin bên cạnh để chuyển khoản thủ công.</span>
                        </div>
                    </div>
                    <span class="qrpay-scan-footnote">VietQR <span>·</span> Chuyển khoản ngân hàng</span>
                </c:when>
                <c:otherwise>
                    <div class="qrpay-state-icon ${order.paymentStatus == 'PAID' ? 'qrpay-state-icon-paid' : ''}">
                        <svg><c:choose><c:when test="${(order.paymentStatus == 'PAID' or order.paymentStatus == 'PENDING_VERIFY') and order.orderStatus != 'CANCELLED'}"><use href="#qrpay-check"/></c:when><c:otherwise><use href="#qrpay-scan"/></c:otherwise></c:choose></svg>
                    </div>
                    <strong class="qrpay-state-label"><c:choose><c:when test="${order.orderStatus == 'CANCELLED'}">Đơn hàng đã hủy</c:when><c:when test="${order.paymentStatus == 'PAID'}">Đã nhận thanh toán</c:when><c:when test="${order.paymentStatus == 'PENDING_VERIFY'}">Đang chờ xác minh</c:when><c:otherwise>VietQR chưa sẵn sàng</c:otherwise></c:choose></strong>
                    <span class="qrpay-scan-footnote">TechStore · Đơn #${order.orderId}</span>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="qrpay-info">
            <div class="qrpay-amount-heading"><span>Tổng thanh toán</span>
                <c:choose>
                    <c:when test="${order.orderStatus == 'CANCELLED'}"><span class="qrpay-badge qrpay-badge-cancelled">Đã hủy</span></c:when>
                    <c:when test="${order.paymentStatus == 'PAID'}"><span class="qrpay-badge qrpay-badge-paid">Đã thanh toán</span></c:when>
                    <c:when test="${order.paymentStatus == 'PENDING_VERIFY'}"><span class="qrpay-badge qrpay-badge-pending">Chờ xác minh</span></c:when>
                    <c:otherwise><span class="qrpay-badge">Chờ thanh toán</span></c:otherwise>
                </c:choose>
            </div>
            <p class="qrpay-amount"><fmt:formatNumber value="${order.totalAmount}" type="number"/> <span>₫</span></p>
            <c:choose>
                <c:when test="${order.orderStatus == 'CANCELLED'}"><p class="qrpay-status-note">Không chuyển khoản cho đơn hàng này.</p></c:when>
                <c:when test="${order.paymentStatus == 'PAID'}"><p class="qrpay-status-note">TechStore đã xác nhận nhận tiền. Không chuyển khoản thêm.</p></c:when>
                <c:when test="${order.paymentStatus == 'PENDING_VERIFY'}"><p class="qrpay-status-note">Đang chờ TechStore đối chiếu giao dịch. Không chuyển khoản thêm nếu đã chuyển đủ.</p></c:when>
                <c:otherwise><p class="qrpay-status-note">Đơn đã được tạo. Chuyển khoản và chờ xác nhận.</p></c:otherwise>
            </c:choose>
            <c:if test="${qrActive}">
                <c:choose>
                    <c:when test="${not empty qrError}"><p class="qrpay-alert" role="alert"><c:out value="${qrError}"/></p></c:when>
                    <c:otherwise>
                        <dl class="qrpay-bank-details">
                            <div class="qrpay-detail-row"><dt>Ngân hàng</dt><dd><c:choose><c:when test="${vietqr.bankId == 'TCB'}">Techcombank</c:when><c:otherwise><c:out value="${vietqr.bankId}"/></c:otherwise></c:choose></dd></div>
                            <div class="qrpay-detail-row"><dt>Số tài khoản</dt><dd><span id="qrpay-account"><c:out value="${vietqr.accountNo}"/></span><button class="qrpay-copy" type="button" data-qrpay-copy="qrpay-account" aria-label="Sao chép số tài khoản" title="Sao chép số tài khoản"><svg><use href="#qrpay-copy"/></svg></button></dd></div>
                            <div class="qrpay-detail-row"><dt>Chủ tài khoản</dt><dd><c:out value="${vietqr.accountName}"/></dd></div>
                            <div class="qrpay-detail-row qrpay-reference-row"><dt>Nội dung</dt><dd><span id="qrpay-reference"><c:out value="${transferContent}"/></span><button class="qrpay-copy" type="button" data-qrpay-copy="qrpay-reference" aria-label="Sao chép nội dung chuyển khoản" title="Sao chép nội dung"><svg><use href="#qrpay-copy"/></svg></button></dd></div>
                        </dl>
                        <p class="qrpay-transfer-hint">Chuyển đúng số tiền và giữ nguyên nội dung.</p>
                    </c:otherwise>
                </c:choose>
            </c:if>
            <div class="qrpay-actions">
                <c:if test="${sessionScope.user.role == 'CUSTOMER' and order.paymentStatus == 'UNPAID' and qrActive}">
                    <form method="post" action="${pageContext.request.contextPath}/payment-qr" data-qrpay-transfer-form>
                        <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <input type="hidden" name="action" value="transferred">
                        <button type="submit" class="qrpay-button qrpay-button-primary"><svg class="qrpay-submit-check"><use href="#qrpay-check"/></svg><span class="qrpay-submit-spinner" aria-hidden="true"></span><span data-qrpay-submit-label>Tôi đã chuyển khoản</span></button>
                    </form>
                </c:if>
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'ADMIN'}"><a class="qrpay-button qrpay-button-secondary" href="${pageContext.request.contextPath}/admin/orders">Quản lý đơn hàng<svg><use href="#qrpay-arrow"/></svg></a></c:when>
                    <c:otherwise><a class="qrpay-button qrpay-button-secondary" href="${pageContext.request.contextPath}/orders">Xem đơn hàng<svg><use href="#qrpay-arrow"/></svg></a></c:otherwise>
                </c:choose>
            </div>
            <p id="qrpay-copy-result" class="qrpay-copy-result" role="status" aria-live="polite"></p>
        </div>
    </section>
    <details class="qrpay-order-summary">
        <summary><span>Chi tiết đơn hàng <span class="qrpay-item-count">${order.details.size()} sản phẩm</span></span><svg><use href="#qrpay-arrow"/></svg></summary>
        <ul><c:forEach var="detail" items="${order.details}">
            <li><span><c:out value="${detail.product.productName}"/><small>Số lượng: ${detail.quantity}</small></span><strong><fmt:formatNumber value="${detail.unitPrice * detail.quantity}" type="number"/> ₫</strong></li>
        </c:forEach></ul>
    </details>
    <p class="qrpay-footer-note">Thanh toán được xác nhận sau khi TechStore đối chiếu giao dịch.</p>
</main>
<script>
(function () {
    var result = document.getElementById('qrpay-copy-result');
    var transferForm = document.querySelector('[data-qrpay-transfer-form]');
    if (transferForm) {
        var submitButton = transferForm.querySelector('button[type="submit"]');
        var submitLabel = transferForm.querySelector('[data-qrpay-submit-label]');
        transferForm.addEventListener('submit', function (event) {
            if (transferForm.dataset.submitting === 'true') { event.preventDefault(); return; }
            transferForm.dataset.submitting = 'true';
            transferForm.setAttribute('aria-busy', 'true');
            submitButton.disabled = true;
            submitLabel.textContent = 'Đang gửi thông báo…';
            result.textContent = 'Đang gửi yêu cầu xác minh đến TechStore.';
        });
        window.addEventListener('pageshow', function () {
            delete transferForm.dataset.submitting;
            transferForm.removeAttribute('aria-busy');
            submitButton.disabled = false;
            submitLabel.textContent = 'Tôi đã chuyển khoản';
            result.textContent = '';
        });
    }
    var receivedNotice = document.getElementById('qrpay-received');
    if (receivedNotice) receivedNotice.focus({preventScroll: true});
    document.querySelectorAll('.qr-payment-page [data-qrpay-copy]').forEach(function (button) {
        button.addEventListener('click', function () {
            if (!navigator.clipboard) { result.textContent = 'Hãy chọn và sao chép thông tin thủ công.'; return; }
            navigator.clipboard.writeText(document.getElementById(button.dataset.qrpayCopy).textContent).then(function () {
                result.textContent = 'Đã sao chép.';
            }, function () { result.textContent = 'Hãy chọn và sao chép thông tin thủ công.'; });
        });
    });
})();
</script>
</body>
</html>
