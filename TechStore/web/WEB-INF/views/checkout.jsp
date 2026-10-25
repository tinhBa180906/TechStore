<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Đặt hàng | TechStore</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css"></head>
<body class="orders-page"><fmt:setLocale value="vi_VN"/>
<%-- Module-local navigation; shared product header/footer remain owned by Quang. --%>
<nav aria-label="Điều hướng">
    <a href="${pageContext.request.contextPath}/home">TechStore</a>
    <a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
    <c:if test="${sessionScope.user.role == 'CUSTOMER'}"><a href="${pageContext.request.contextPath}/orders">Đơn hàng của tôi</a></c:if>
    <c:if test="${sessionScope.user.role == 'ADMIN'}">
        <a href="${pageContext.request.contextPath}/admin/orders">Quản lý đơn hàng</a>
        <a href="${pageContext.request.contextPath}/admin/dashboard">Thống kê</a>
    </c:if>
</nav>
<main><h1>Thông tin đặt hàng</h1>
<c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
<c:choose><c:when test="${empty cartItems}"><section>Giỏ hàng đang trống. <a href="${pageContext.request.contextPath}/cart">Quay lại giỏ hàng</a></section></c:when>
<c:otherwise><section>
<c:forEach items="${cartItems}" var="item"><p><c:out value="${item.product.productName}"/> × ${item.quantity} — <fmt:formatNumber value="${item.subtotal}" type="number"/> ₫</p></c:forEach>
<p class="total">Tạm tính: <fmt:formatNumber value="${cartTotal}" type="number"/> ₫</p>
<p>Thanh toán khi nhận hàng (COD). Giá và tồn kho được xác nhận từ hệ thống khi đặt hàng.</p>
<form method="post" action="${pageContext.request.contextPath}/checkout">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
<label>Họ tên người nhận<input name="shippingName" required minlength="2" maxlength="100" autocomplete="name" value="<c:out value='${param.shippingName}'/>"></label>
<label>Số điện thoại<input name="shippingPhone" type="tel" required minlength="8" maxlength="15" autocomplete="tel" value="<c:out value='${param.shippingPhone}'/>"></label>
<label>Địa chỉ nhận hàng<textarea name="shippingAddress" required maxlength="255" rows="3" autocomplete="street-address"><c:out value="${param.shippingAddress}"/></textarea></label>
<button type="submit">Xác nhận đặt hàng</button></form>
</section></c:otherwise></c:choose></main></body></html>
