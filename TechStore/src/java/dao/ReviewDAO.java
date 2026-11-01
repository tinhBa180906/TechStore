package dao;

import dal.DBContext;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ProductReview;

/** One connection per DAO; callers close it with try-with-resources. */
public class ReviewDAO extends DBContext implements AutoCloseable {
    public static final int MAX_COMMENT_LENGTH = 500;
    private static final String REVIEW_SELECT =
            "SELECT r.ReviewID,r.ProductID,r.AccountID,r.Rating,r.Comment,r.CreatedAt,"
            + "COALESCE(NULLIF(LTRIM(RTRIM(c.FullName)),N''),a.Username) AS ReviewerName "
            + "FROM dbo.ProductReview r JOIN dbo.UserAccount a ON a.AccountID=r.AccountID "
            + "LEFT JOIN dbo.Customer c ON c.CustomerID=a.CustomerID ";

    public ReviewDAO() throws SQLException {
        if (connection == null) throw new SQLException("Review database unavailable.");
    }

    public List<ProductReview> getReviewsByProduct(int productId) throws SQLException {
        List<ProductReview> reviews = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(REVIEW_SELECT
                + "WHERE r.ProductID=? ORDER BY r.CreatedAt DESC,r.ReviewID DESC")) {
            statement.setInt(1, productId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) reviews.add(readReview(result));
            }
        }
        return reviews;
    }

    /** Fetch both aggregate values in one query; no fabricated average on an empty product. */
    public Map<String, Object> getRatingSummary(int productId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT COUNT_BIG(*) ReviewCount,COALESCE(AVG(CAST(Rating AS DECIMAL(10,4))),0) AverageRating "
                + "FROM dbo.ProductReview WHERE ProductID=?")) {
            statement.setInt(1, productId);
            try (ResultSet result = statement.executeQuery()) {
                result.next();
                Map<String, Object> summary = new HashMap<>();
                summary.put("reviewCount", result.getLong("ReviewCount"));
                summary.put("averageRating", result.getBigDecimal("AverageRating"));
                return summary;
            }
        }
    }

    public BigDecimal getAverageRating(int productId) throws SQLException {
        return (BigDecimal) getRatingSummary(productId).get("averageRating");
    }

    public long countReviews(int productId) throws SQLException {
        return (Long) getRatingSummary(productId).get("reviewCount");
    }

    public ProductReview getReviewByUserAndProduct(int accountId, int productId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(REVIEW_SELECT
                + "WHERE r.AccountID=? AND r.ProductID=?")) {
            statement.setInt(1, accountId);
            statement.setInt(2, productId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? readReview(result) : null;
            }
        }
    }

    /** One history query, rather than querying separately for every product in every order. */
    public Map<Integer, Boolean> getReviewedProducts(int accountId) throws SQLException {
        Map<Integer, Boolean> products = new HashMap<>();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT ProductID FROM dbo.ProductReview WHERE AccountID=?")) {
            statement.setInt(1, accountId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) products.put(result.getInt("ProductID"), Boolean.TRUE);
            }
        }
        return products;
    }

    /** AccountID is resolved through UserAccount.CustomerID, never confused with CustomerID. */
    public boolean hasPurchasedProduct(int accountId, int productId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT TOP (1) 1 FROM dbo.UserAccount a "
                + "JOIN dbo.Invoice i ON i.CustomerID=a.CustomerID "
                + "JOIN dbo.InvoiceDetail d ON d.InvoiceID=i.InvoiceID "
                + "JOIN dbo.Product p ON p.ProductID=d.ProductID "
                + "WHERE a.AccountID=? AND a.Role='CUSTOMER' AND a.IsActive=1 "
                + "AND p.ProductID=? AND p.IsActive=1 AND i.OrderStatus='COMPLETED'")) {
            statement.setInt(1, accountId);
            statement.setInt(2, productId);
            try (ResultSet result = statement.executeQuery()) { return result.next(); }
        }
    }

    /** Return true for insert, false for update. Update always targets the account/product pair. */
    public boolean saveReview(ProductReview review) throws SQLException {
        if (review == null || review.getAccountId() < 1 || review.getProductId() < 1
                || review.getRating() < 1 || review.getRating() > 5)
            throw new IllegalArgumentException("Vui lòng chọn số sao từ 1 đến 5.");
        String comment = review.getComment() == null ? "" : review.getComment().strip();
        if (comment.isEmpty() || comment.length() > MAX_COMMENT_LENGTH)
            throw new IllegalArgumentException("Bình luận cần từ 1 đến 500 ký tự.");

        boolean autoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            if (!hasPurchasedProduct(review.getAccountId(), review.getProductId()))
                throw new IllegalArgumentException("Bạn cần mua và hoàn tất đơn hàng trước khi đánh giá sản phẩm này.");

            boolean exists;
            // Lock the existing key or its unique-index gap until commit: parallel submits cannot insert duplicates.
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT ReviewID FROM dbo.ProductReview WITH (UPDLOCK,HOLDLOCK) WHERE AccountID=? AND ProductID=?")) {
                statement.setInt(1, review.getAccountId());
                statement.setInt(2, review.getProductId());
                try (ResultSet result = statement.executeQuery()) { exists = result.next(); }
            }
            String sql = exists
                    ? "UPDATE dbo.ProductReview SET Rating=?,Comment=? WHERE AccountID=? AND ProductID=?"
                    : "INSERT dbo.ProductReview(Rating,Comment,AccountID,ProductID) VALUES (?,?,?,?)";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, review.getRating());
                statement.setNString(2, comment);
                statement.setInt(3, review.getAccountId());
                statement.setInt(4, review.getProductId());
                if (statement.executeUpdate() != 1) throw new SQLException("Review write did not affect exactly one row.");
            }
            connection.commit();
            return !exists;
        } catch (SQLException | RuntimeException e) {
            try { connection.rollback(); } catch (SQLException rollback) { e.addSuppressed(rollback); }
            throw e;
        } finally { connection.setAutoCommit(autoCommit); }
    }

    private ProductReview readReview(ResultSet result) throws SQLException {
        ProductReview review = new ProductReview();
        review.setReviewId(result.getInt("ReviewID"));
        review.setProductId(result.getInt("ProductID"));
        review.setAccountId(result.getInt("AccountID"));
        review.setRating(result.getInt("Rating"));
        review.setComment(result.getNString("Comment"));
        review.setCreatedAt(result.getTimestamp("CreatedAt"));
        review.setReviewerName(result.getNString("ReviewerName"));
        return review;
    }

    @Override public void close() throws SQLException {
        if (connection != null && !connection.isClosed()) connection.close();
    }
}
