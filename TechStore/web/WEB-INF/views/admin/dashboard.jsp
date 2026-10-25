<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thống kê | TechStore</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/orders.css"></head>
<body class="orders-page"><%@include file="../orders-common.jspf"%><main><h1>Thống kê bán hàng</h1>
<c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
<c:if test="${not empty stats}">
<div class="metrics"><section><h2>Doanh thu</h2><p class="total"><fmt:formatNumber value="${stats.revenue}" type="number"/> ₫</p><p>Đơn COMPLETED</p></section>
<section><h2>Tổng đơn hàng</h2><p class="total">${stats.totalOrders}</p><p>Tất cả trạng thái</p></section>
<section><h2>Đơn hoàn tất</h2><p class="total">${stats.completedOrders}</p></section></div>
<section><h2>10 sản phẩm bán chạy</h2><p>Chỉ tính các đơn COMPLETED, bao gồm sản phẩm đã ngừng bán.</p>
<c:choose><c:when test="${empty stats.bestSelling}"><p>Chưa có sản phẩm bán ra từ đơn hoàn tất.</p></c:when><c:otherwise>
<div class="table-wrap"><table><thead><tr><th>Sản phẩm</th><th>Số lượng bán</th><th>Doanh thu</th></tr></thead><tbody>
<c:forEach items="${stats.bestSelling}" var="item"><tr><td><c:out value="${item.productName}"/></td><td>${item.unitsSold}</td>
<td><fmt:formatNumber value="${item.revenue}" type="number"/> ₫</td></tr></c:forEach>
</tbody></table></div></c:otherwise></c:choose></section></c:if></main></body></html>
