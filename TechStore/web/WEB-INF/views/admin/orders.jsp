<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quản lý đơn hàng | TechStore</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css"></head>
<body class="orders-page"><%@include file="../orders-common.jspf"%><main><h1>Quản lý đơn hàng</h1>
<c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
<c:if test="${empty orders and empty errorMessage}"><section>Chưa có đơn hàng.</section></c:if>
<c:forEach items="${orders}" var="order"><article><h2>Đơn #${order.orderId} — Khách #${order.customerId}</h2>
<p>Ngày đặt: <c:out value="${order.dateCreated}"/> | <strong><c:out value="${order.orderStatus}"/></strong></p>
<p>Người nhận: <c:out value="${order.shippingName}"/> — <c:out value="${order.shippingPhone}"/></p>
<p>Địa chỉ: <c:out value="${order.shippingAddress}"/> | Thanh toán: COD</p>
<c:if test="${not empty order.completeAt}"><p>Hoàn tất: <c:out value="${order.completeAt}"/></p></c:if>
<%@include file="../order-details.jspf"%>
<c:if test="${order.orderStatus == 'PENDING' or order.orderStatus == 'CONFIRMED'}">
<form method="post" action="${pageContext.request.contextPath}/admin/orders">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="orderId" value="${order.orderId}">
<label>Chuyển trạng thái <select name="status" required>
<c:if test="${order.orderStatus == 'PENDING'}"><option value="CONFIRMED">Xác nhận đơn</option><option value="CANCELLED">Hủy đơn và hoàn kho</option></c:if>
<c:if test="${order.orderStatus == 'CONFIRMED'}"><option value="COMPLETED">Hoàn tất đơn hàng</option></c:if>
</select></label><button type="submit">Cập nhật trạng thái</button></form>
</c:if></article></c:forEach></main></body></html>
