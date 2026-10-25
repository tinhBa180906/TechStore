<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Lịch sử mua hàng | TechStore</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css"></head>
<body class="orders-page"><%@include file="orders-common.jspf"%><main><h1>Đơn hàng của tôi</h1>
<c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
<c:if test="${empty orders and empty errorMessage}"><section>Bạn chưa có đơn hàng nào.</section></c:if>
<c:forEach items="${orders}" var="order">
<article><h2>Đơn #${order.orderId}</h2><p>Ngày đặt: <c:out value="${order.dateCreated}"/> | Trạng thái: <strong><c:out value="${order.orderStatus}"/></strong></p>
<p>Người nhận: <c:out value="${order.shippingName}"/> — <c:out value="${order.shippingPhone}"/></p>
<p>Địa chỉ: <c:out value="${order.shippingAddress}"/> | Thanh toán: COD</p>
<%@include file="order-details.jspf"%>
<c:if test="${order.orderStatus == 'PENDING'}">
<form method="post" action="${pageContext.request.contextPath}/orders">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="action" value="cancel">
<input type="hidden" name="orderId" value="${order.orderId}"><button type="submit" class="danger">Hủy đơn hàng</button></form>
</c:if></article></c:forEach></main></body></html>
