package controller;

import controller.orders.OrderSupport;
import dao.ProductDAO;
import dao.ReviewDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import model.Account;
import model.Product;
import model.ProductReview;

/** Add/update only the signed-in customer's review, followed by a product-detail redirect. */
@WebServlet(name = "ReviewServlet", urlPatterns = {"/review"})
public class ReviewServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        OrderSupport.prepare(request, response);
        Account account = OrderSupport.requireUser(request, response, false);
        if (account == null || !OrderSupport.csrf(request, response)) return;

        int productId;
        try { productId = OrderSupport.positiveInt(request.getParameter("productId")); }
        catch (IllegalArgumentException e) {
            response.sendError(400, "Mã sản phẩm không hợp lệ."); return;
        }

        String ratingText = request.getParameter("rating");
        String comment = request.getParameter("comment");
        comment = comment == null ? "" : comment.strip();
        String error = null;
        boolean saved = false;
        try {
            if (ratingText == null || !ratingText.matches("[1-5]"))
                throw new IllegalArgumentException("Vui lòng chọn số sao từ 1 đến 5.");
            if (comment.isEmpty() || comment.length() > ReviewDAO.MAX_COMMENT_LENGTH)
                throw new IllegalArgumentException("Bình luận cần từ 1 đến 500 ký tự.");
            try (ProductDAO dao = new ProductDAO()) {
                Product product = dao.getProductById(productId);
                if (product == null || !product.isActive()) {
                    response.sendError(404, "Không tìm thấy sản phẩm."); return;
                }
            }
            ProductReview review = new ProductReview();
            review.setAccountId(account.getAccountId()); // Never read accountId/customerId/reviewId from form.
            review.setProductId(productId);
            review.setRating(Integer.parseInt(ratingText));
            review.setComment(comment);
            try (ReviewDAO dao = new ReviewDAO()) { dao.saveReview(review); }
            saved = true;
        } catch (IllegalArgumentException e) { error = e.getMessage(); }
        catch (SQLException e) {
            getServletContext().log("Unable to save product review", e);
            error = "Chưa thể lưu đánh giá. Vui lòng tải lại sản phẩm và thử lại sau.";
        }

        // One-use, product-scoped flash data; an error never leaks into a different product/account.
        HttpSession session = request.getSession();
        synchronized (session) {
            session.setAttribute("reviewFlashAccountId", account.getAccountId());
            session.setAttribute("reviewFlashProductId", productId);
            session.setAttribute("reviewFlashSuccess", saved);
            if (saved) {
                session.removeAttribute("reviewFlashError");
                session.removeAttribute("reviewFlashComment");
                session.removeAttribute("reviewFlashRating");
            } else {
                session.setAttribute("reviewFlashError", error);
                // Bound the text kept in session even when a forged POST submits a huge comment.
                session.setAttribute("reviewFlashComment", comment.substring(0, Math.min(comment.length(), ReviewDAO.MAX_COMMENT_LENGTH)));
                session.setAttribute("reviewFlashRating", ratingText != null && ratingText.matches("[1-5]") ? Integer.parseInt(ratingText) : 0);
            }
        }
        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "#product-reviews");
    }
}
