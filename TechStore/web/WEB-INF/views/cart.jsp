<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Giỏ hàng | TechStore</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css"></head>
<body class="orders-page">
<%@include file="orders-common.jspf"%>
<main><h1>Giỏ hàng</h1>
<c:if test="${not empty products}">
<section><h2>Thêm sản phẩm</h2>
<form method="post" action="${pageContext.request.contextPath}/cart">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
<input type="hidden" name="action" value="add">
<label>Sản phẩm<select name="productId" required>
<c:forEach items="${products}" var="product">
<option value="${product.productId}"><c:out value="${product.productName}"/></option>
</c:forEach></select></label>
<label>Số lượng<input type="number" name="quantity" value="1" min="1" required></label>
<button type="submit">Thêm vào giỏ</button>
</form></section>
</c:if>
<c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
<c:choose><c:when test="${empty cartItems}"><section>Giỏ hàng đang trống. <a href="${pageContext.request.contextPath}/home">Tiếp tục mua sắm</a></section></c:when>
<c:otherwise><section><div class="table-wrap"><table>
<thead><tr><th>Sản phẩm</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th><th>Thao tác</th></tr></thead><tbody>
<c:forEach items="${cartItems}" var="item"><tr>
<td><c:out value="${item.product.productName}"/></td>
<td><fmt:formatNumber value="${item.product.price}" type="number"/> ₫</td>
<td><form method="post" action="${pageContext.request.contextPath}/cart">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="action" value="update">
<input type="hidden" name="productId" value="${item.product.productId}">
<input aria-label="Số lượng" type="number" name="quantity" value="${item.quantity}" min="1" required>
<button type="submit">Cập nhật</button></form></td>
<td><fmt:formatNumber value="${item.subtotal}" type="number"/> ₫</td>
<td><form method="post" action="${pageContext.request.contextPath}/cart">
<input type="hidden" name="csrf" value="${sessionScope.orderCsrf}"><input type="hidden" name="action" value="remove">
<input type="hidden" name="productId" value="${item.product.productId}"><button type="submit" class="danger">Xóa</button></form></td>
</tr></c:forEach></tbody></table></div>
<p class="total">Tạm tính: <fmt:formatNumber value="${cartTotal}" type="number"/> ₫</p>
<p class="muted">Giá và tồn kho được kiểm tra lại khi đặt hàng.</p>
<a class="button" href="${pageContext.request.contextPath}/checkout">Tiến hành đặt hàng</a>
<c:if test="${empty sessionScope.user}"><p>Vui lòng đăng nhập trước khi đặt hàng.</p></c:if>
</section></c:otherwise></c:choose></main></body></html>
