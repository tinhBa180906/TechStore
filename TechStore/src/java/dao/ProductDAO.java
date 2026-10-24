package dao;

import dal.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Product;

/** Read-only public catalog. Create and close one DAO per request. */
public class ProductDAO extends DBContext implements AutoCloseable {

    private static final String COLUMNS = "ProductID, ProductName, BrandID, BrandName, "
            + "CategoryID, CategoryName, [Description], Price, StockQuantity, "
            + "WarrantyPeriod, ImageURL, IsFeatured, IsActive, CreatedAt, UnitsSold";
    private static final String CATALOG = " FROM dbo.vw_ProductCatalog WHERE IsActive = 1";

    public ProductDAO() throws SQLException {
        // DBContext logs connection failures and can leave connection null.
        if (connection == null) {
            throw new SQLException("The product data connection is unavailable.");
        }
    }

    public long countActiveProducts() throws SQLException {
        String sql = "SELECT COUNT_BIG(*) AS TotalProducts" + CATALOG;
        try (PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            if (!result.next()) {
                throw new SQLException("The catalog count was not returned.");
            }
            return result.getLong("TotalProducts");
        }
    }

    public List<Product> getProducts(long page, int pageSize) throws SQLException {
        validateLimit(pageSize);
        if (page < 1 || page - 1 > Long.MAX_VALUE / pageSize) {
            throw new IllegalArgumentException("Invalid catalog page.");
        }
        long offset = (page - 1) * pageSize;
        String sql = "SELECT " + COLUMNS + CATALOG
                + " ORDER BY CreatedAt DESC, ProductID DESC"
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, offset);
            statement.setInt(2, pageSize);
            try (ResultSet result = statement.executeQuery()) {
                return readProducts(result);
            }
        }
    }

    public List<Product> getFeaturedProducts(int limit) throws SQLException {
        return getTopProducts("SELECT TOP (?) " + COLUMNS + CATALOG
                + " AND IsFeatured = 1 ORDER BY ProductID ASC", limit);
    }

    public List<Product> getNewProducts(int limit) throws SQLException {
        return getTopProducts("SELECT TOP (?) " + COLUMNS + CATALOG
                + " ORDER BY CreatedAt DESC, ProductID DESC", limit);
    }

    public List<Product> getBestSellingProducts(int limit) throws SQLException {
        // The view already counts only COMPLETED orders; never fill with unsold items.
        return getTopProducts("SELECT TOP (?) " + COLUMNS + CATALOG
                + " AND UnitsSold > 0 ORDER BY UnitsSold DESC, ProductID ASC", limit);
    }

    private List<Product> getTopProducts(String sql, int limit) throws SQLException {
        validateLimit(limit);
        // sql comes only from the fixed queries above, never from request input.
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, limit);
            try (ResultSet result = statement.executeQuery()) {
                return readProducts(result);
            }
        }
    }

    private static void validateLimit(int limit) {
        if (limit < 1 || limit > 100) {
            throw new IllegalArgumentException("Product limit must be between 1 and 100.");
        }
    }

    private List<Product> readProducts(ResultSet result) throws SQLException {
        List<Product> products = new ArrayList<>();
        while (result.next()) {
            Product product = new Product();
            product.setProductId(result.getInt("ProductID"));
            product.setProductName(result.getString("ProductName"));
            product.setBrandId(result.getInt("BrandID"));
            product.setBrandName(result.getString("BrandName"));
            product.setCategoryId(result.getInt("CategoryID"));
            product.setCategoryName(result.getString("CategoryName"));
            product.setDescription(result.getString("Description"));
            product.setPrice(result.getBigDecimal("Price"));
            product.setStockQuantity(result.getInt("StockQuantity"));
            product.setWarrantyPeriod(result.getInt("WarrantyPeriod"));
            product.setImageUrl(result.getString("ImageURL"));
            product.setIsFeatured(result.getBoolean("IsFeatured"));
            product.setIsActive(result.getBoolean("IsActive"));
            Timestamp createdAt = result.getTimestamp("CreatedAt");
            product.setCreateAt(createdAt == null ? null : createdAt.toLocalDateTime());
            product.setUnitsSold(result.getInt("UnitsSold"));
            products.add(product);
        }
        return products;
    }

    @Override
    public void close() throws SQLException {
        if (connection != null) {
            connection.close();
        }
    }
}
