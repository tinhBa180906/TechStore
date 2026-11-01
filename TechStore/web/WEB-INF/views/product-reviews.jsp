<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<fmt:setLocale value="vi_VN" scope="page"/>
<%-- Presentation statistics use the same loaded list as the comments. No additional database query. --%>
<c:set var="reviewUiCount" value="${fn:length(reviews)}"/>
<c:set var="reviewUiSum" value="0"/>
<c:forEach var="entry" items="${reviews}"><c:set var="reviewUiSum" value="${reviewUiSum + entry.rating}"/></c:forEach>
<c:set var="reviewUiAverage" value="${reviewUiCount > 0 ? reviewUiSum / reviewUiCount : 0}"/>
<section class="ts-reviews ${reviewUiCount == 0 ? 'ts-reviews--empty' : ''}" id="product-reviews" aria-labelledby="ts-reviews-heading" data-review-section>
    <svg class="ts-review-symbols" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><defs>
        <symbol id="ts-review-icon-star" viewBox="0 0 24 24"><path d="m12 2.8 2.9 5.88 6.49.95-4.7 4.58 1.11 6.46L12 17.62l-5.8 3.05 1.11-6.46-4.7-4.58 6.49-.95L12 2.8Z"/></symbol>
        <symbol id="ts-review-icon-send" viewBox="0 0 24 24"><path d="m21 3-7 18-4-7-7-4 18-7Zm0 0L10 14"/></symbol>
        <symbol id="ts-review-icon-check" viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></symbol>
        <symbol id="ts-review-icon-bag" viewBox="0 0 24 24"><path d="M5 8h14l1 13H4L5 8Zm3 0V6a4 4 0 0 1 8 0v2"/></symbol>
        <symbol id="ts-review-icon-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></symbol>
    </defs></svg>
    <header class="ts-reviews-heading">
        <div><span class="ts-reviews-eyebrow">THE TECHSTORE EXPERIENCE</span><h2 id="ts-reviews-heading">Trải nghiệm thật. Góc nhìn thật.</h2><p>Những chia sẻ giúp bạn chọn đúng sản phẩm mình cần.</p></div>
        <c:choose><c:when test="${canReview}"><a class="ts-review-write-link" href="#review-form">${not empty ownReview ? 'Sửa đánh giá của bạn' : 'Viết đánh giá'} <span aria-hidden="true">↗</span></a></c:when><c:otherwise><span class="ts-review-section-label">ĐÁNH GIÁ KHÁCH HÀNG</span></c:otherwise></c:choose>
    </header>
    <c:choose>
        <c:when test="${reviewsUnavailable}"><p class="ts-review-message ts-review-error" role="alert">Chưa thể tải đánh giá. Bạn vẫn có thể xem sản phẩm và mua hàng bình thường.</p></c:when>
        <c:otherwise>
            <c:if test="${reviewSuccess}"><p class="ts-review-message ts-review-success" role="status"><svg><use href="#ts-review-icon-check"/></svg><span>Đánh giá của bạn đã được lưu. Cảm ơn bạn đã chia sẻ!</span></p></c:if>
            <c:if test="${not empty reviewError}"><p class="ts-review-message ts-review-error" role="alert"><c:out value="${reviewError}"/></p></c:if>
            <c:if test="${reviewUiCount > 0}">
                <div class="ts-review-overview" aria-label="Tổng quan đánh giá sản phẩm">
                    <div class="ts-review-overview-score">
                        <span class="ts-review-overline">ĐIỂM ĐÁNH GIÁ</span>
                        <div class="ts-review-score"><strong><fmt:formatNumber value="${reviewUiAverage}" minFractionDigits="1" maxFractionDigits="1"/></strong><span>/ 5</span></div>
                        <span class="ts-review-average-stars" aria-hidden="true"><span><c:forEach begin="1" end="5"><svg><use href="#ts-review-icon-star"/></svg></c:forEach></span><span class="ts-review-average-fill" style="--ts-review-fill:${reviewUiAverage * 20}%;"><c:forEach begin="1" end="5"><svg><use href="#ts-review-icon-star"/></svg></c:forEach></span></span>
                        <p>Dựa trên <strong>${reviewUiCount} lượt đánh giá</strong></p>
                    </div>
                    <div class="ts-review-distribution" aria-label="Phân bố số sao từ đánh giá thực tế">
                        <c:forEach begin="1" end="5" var="row"><c:set var="ratingLevel" value="${6 - row}"/><c:set var="ratingCount" value="0"/>
                            <c:forEach var="entry" items="${reviews}"><c:if test="${entry.rating == ratingLevel}"><c:set var="ratingCount" value="${ratingCount + 1}"/></c:if></c:forEach>
                            <div class="ts-review-distribution-row" data-review-level="${ratingLevel}" data-review-count="${ratingCount}"><span>${ratingLevel}<svg aria-hidden="true"><use href="#ts-review-icon-star"/></svg></span><progress max="${reviewUiCount}" value="${ratingCount}" aria-label="${ratingLevel} sao: ${ratingCount} lượt đánh giá"></progress><span>${ratingCount}</span></div>
                        </c:forEach>
                    </div>
                    <div class="ts-review-overview-note"><svg aria-hidden="true"><use href="#ts-review-icon-star"/></svg><strong>Mỗi trải nghiệm đều có giá trị.</strong><p>Đọc những góc nhìn khác nhau trước khi đưa ra lựa chọn.</p></div>
                </div>
            </c:if>
            <div class="ts-reviews-layout">
                <c:choose>
                    <c:when test="${reviewUiCount == 0}">
                        <div class="ts-review-empty">
                            <div class="ts-review-empty-art" aria-hidden="true"><svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="42"/><path d="m50 23 8 16 18 3-13 13 3 18-16-9-16 9 3-18-13-13 18-3 8-16Z"/><path d="M16 19v10m-5-5h10m59 48v10m-5-5h10M78 15l3 3m-3 0 3-3"/></svg></div>
                            <div><span class="ts-review-overline">CÂU CHUYỆN ĐẦU TIÊN</span><h3>Chưa có đánh giá nào</h3><p>Hãy chia sẻ trải nghiệm của bạn để giúp những khách hàng khác lựa chọn tốt hơn.</p></div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="ts-review-list" aria-label="Bình luận của khách hàng">
                            <div class="ts-review-list-heading"><h3>Khách hàng chia sẻ</h3><span>${reviewUiCount} đánh giá</span></div>
                            <c:forEach var="review" items="${reviews}" varStatus="reviewIndex">
                                <c:set var="reviewDisplayName" value="${empty fn:trim(review.reviewerName) ? 'Khách hàng' : fn:trim(review.reviewerName)}"/>
                                <c:set var="reviewNameParts" value="${fn:split(reviewDisplayName, ' ')}"/>
                                <article class="ts-review-item">
                                    <div class="ts-review-item-heading">
                                        <span class="ts-review-avatar ts-review-avatar--${reviewIndex.index % 3}" aria-hidden="true"><c:out value="${fn:toUpperCase(fn:substring(reviewDisplayName, 0, 1))}"/><c:if test="${fn:length(reviewNameParts) > 1}"><c:out value="${fn:toUpperCase(fn:substring(reviewNameParts[fn:length(reviewNameParts) - 1], 0, 1))}"/></c:if></span>
                                        <div class="ts-review-author"><h4><c:out value="${reviewDisplayName}"/></h4><span class="ts-review-stars" role="img" aria-label="${review.rating} trên 5 sao"><c:forEach begin="1" end="5" var="star"><svg class="${star <= review.rating ? 'ts-review-star-filled' : ''}" aria-hidden="true"><use href="#ts-review-icon-star"/></svg></c:forEach></span></div>
                                        <time><fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy HH:mm"/></time>
                                    </div>
                                    <p class="ts-review-comment"><c:out value="${review.comment}"/></p>
                                    <c:if test="${reviewCustomer and review.accountId == sessionScope.user.accountId}"><span class="ts-review-own-label">Đánh giá của bạn</span></c:if>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
                <aside class="ts-review-compose" id="review-form" tabindex="-1" aria-labelledby="ts-review-form-heading">
                    <c:choose>
                        <c:when test="${empty sessionScope.user}">
                            <span class="ts-review-access-icon"><svg aria-hidden="true"><use href="#ts-review-icon-user"/></svg></span><h3 id="ts-review-form-heading">Bạn muốn chia sẻ trải nghiệm?</h3><p class="ts-review-compose-subtitle">Đăng nhập để đánh giá sản phẩm.</p><a class="ts-review-button" href="${pageContext.request.contextPath}/login">Đăng nhập<svg aria-hidden="true"><use href="#ts-review-icon-send"/></svg></a>
                        </c:when>
                        <c:when test="${not reviewCustomer or not canReview}">
                            <span class="ts-review-access-icon"><svg aria-hidden="true"><use href="#ts-review-icon-bag"/></svg></span><h3 id="ts-review-form-heading">Trải nghiệm rồi hãy chia sẻ</h3><p class="ts-review-compose-subtitle">Bạn có thể đánh giá sản phẩm sau khi đơn hàng được hoàn tất.</p>
                        </c:when>
                        <c:otherwise>
                            <span class="ts-review-overline">${not empty ownReview ? 'GÓC NHÌN CỦA BẠN' : 'VIẾT ĐÁNH GIÁ'}</span>
                            <h3 id="ts-review-form-heading">${not empty ownReview ? 'Đánh giá của bạn' : 'Chia sẻ trải nghiệm của bạn'}</h3>
                            <p class="ts-review-compose-subtitle">Đánh giá của bạn sẽ giúp những khách hàng khác đưa ra lựa chọn tốt hơn.</p>
                            <p class="ts-review-product-context"><c:out value="${product.productName}"/></p>
                            <form method="post" action="${pageContext.request.contextPath}/review" data-review-form>
                                <input type="hidden" name="csrf" value="${sessionScope.orderCsrf}">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <fieldset class="ts-review-rating-field"><legend>Đánh giá chất lượng sản phẩm</legend>
                                    <div class="ts-review-rating-inputs">
                                        <c:forEach begin="1" end="5" var="score">
                                            <label class="ts-review-rating-option" for="ts-review-rating-${score}"><input type="radio" name="rating" id="ts-review-rating-${score}" value="${score}" ${reviewFormRating == score ? 'checked' : ''} required aria-describedby="ts-review-rating-feedback"><svg aria-hidden="true"><use href="#ts-review-icon-star"/></svg><span class="ts-review-sr-only">${score} sao</span></label>
                                        </c:forEach>
                                    </div>
                                    <p class="ts-review-rating-feedback" id="ts-review-rating-feedback" aria-live="polite"><c:choose><c:when test="${reviewFormRating == 1}">Rất tệ</c:when><c:when test="${reviewFormRating == 2}">Chưa tốt</c:when><c:when test="${reviewFormRating == 3}">Bình thường</c:when><c:when test="${reviewFormRating == 4}">Tốt</c:when><c:when test="${reviewFormRating == 5}">Tuyệt vời</c:when><c:otherwise>Chạm vào sao để chọn mức đánh giá</c:otherwise></c:choose></p>
                                </fieldset>
                                <label class="ts-review-comment-label" for="ts-review-comment-input">Nhận xét của bạn</label>
                                <textarea id="ts-review-comment-input" name="comment" rows="5" maxlength="500" required placeholder="Sản phẩm có đáp ứng kỳ vọng của bạn không? Hãy chia sẻ trải nghiệm thực tế..." aria-describedby="ts-review-comment-hint ts-review-counter"><c:out value="${reviewFormComment}"/></textarea>
                                <div class="ts-review-textarea-meta"><span id="ts-review-comment-hint">Chia sẻ chân thật, hữu ích.</span><span id="ts-review-counter" data-review-counter>${fn:length(reviewFormComment)} / 500 ký tự</span></div>
                                <p class="ts-review-form-validation" data-review-validation role="alert" hidden></p>
                                <button class="ts-review-button" type="submit"><span data-review-submit-label>${not empty ownReview ? 'Cập nhật đánh giá' : 'Gửi đánh giá'}</span><svg aria-hidden="true"><use href="#ts-review-icon-send"/></svg></button>
                                <p class="ts-review-submit-status" data-review-submit-status role="status" aria-live="polite"></p>
                            </form>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${reviewCustomer}"><a class="ts-review-back-orders" href="${pageContext.request.contextPath}/orders">← Lịch sử mua hàng</a></c:if>
                </aside>
            </div>
        </c:otherwise>
    </c:choose>
</section>
