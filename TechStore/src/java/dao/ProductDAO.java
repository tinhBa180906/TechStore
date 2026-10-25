package dao;

import dal.DBContext;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;

/** Catalog and Product CRUD DAO. Create and close one DAO per request. */
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

    public Product getProductById(int productId) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM dbo.vw_ProductCatalog WHERE ProductID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet result = statement.executeQuery()) {
                List<Product> products = readProducts(result);
                return products.isEmpty() ? null : products.get(0);
            }
        }
    }

    public List<Product> getRelatedProducts(int categoryId, int excludeProductId, int limit) throws SQLException {
        validateLimit(limit);
        String sql = "SELECT TOP (?) " + COLUMNS + CATALOG
                + " AND CategoryID = ? AND ProductID <> ? ORDER BY UnitsSold DESC, ProductID DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, limit);
            statement.setInt(2, categoryId);
            statement.setInt(3, excludeProductId);
            try (ResultSet result = statement.executeQuery()) {
                return readProducts(result);
            }
        }
    }

    // ==========================================
    // Filter, Search, Sort & Pagination for Customer Catalog
    // ==========================================

    public long countFilteredProducts(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT_BIG(*) AS TotalProducts FROM dbo.vw_ProductCatalog WHERE IsActive = 1");
        List<Object> params = new ArrayList<>();

        buildFilterConditions(sql, params, keyword, categoryId, brandId, minPrice, maxPrice, null);

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            setStatementParams(statement, params);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("TotalProducts");
                }
                return 0L;
            }
        }
    }

    public List<Product> getFilteredProducts(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sort, long page, int pageSize) throws SQLException {
        validateLimit(pageSize);
        if (page < 1) page = 1;
        long offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder("SELECT ").append(COLUMNS)
                .append(" FROM dbo.vw_ProductCatalog WHERE IsActive = 1");
        List<Object> params = new ArrayList<>();

        buildFilterConditions(sql, params, keyword, categoryId, brandId, minPrice, maxPrice, null);

        // Sorting
        sql.append(" ORDER BY ");
        if ("price-asc".equalsIgnoreCase(sort)) {
            sql.append("Price ASC, ProductID DESC");
        } else if ("price-desc".equalsIgnoreCase(sort)) {
            sql.append("Price DESC, ProductID DESC");
        } else if ("bestselling".equalsIgnoreCase(sort)) {
            sql.append("UnitsSold DESC, ProductID DESC");
        } else if ("name-asc".equalsIgnoreCase(sort)) {
            sql.append("ProductName ASC");
        } else {
            // default: newest
            sql.append("CreatedAt DESC, ProductID DESC");
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            setStatementParams(statement, params);
            try (ResultSet result = statement.executeQuery()) {
                return readProducts(result);
            }
        }
    }

    // ==========================================
    // Categories and Brands
    // ==========================================

    public List<Category> getAllCategories() throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT CategoryID, CategoryName FROM dbo.Category ORDER BY CategoryName ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(new Category(rs.getInt("CategoryID"), rs.getString("CategoryName")));
            }
        }
        return list;
    }

    public List<Brand> getAllBrands() throws SQLException {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT BrandID, BrandName, Country, IsActive FROM dbo.Brand WHERE IsActive = 1 ORDER BY BrandName ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(new Brand(rs.getInt("BrandID"), rs.getString("BrandName"),
                        rs.getString("Country"), rs.getBoolean("IsActive")));
            }
        }
        return list;
    }

    // ==========================================
    // Admin CRUD & Product Management
    // ==========================================

    public long countAdminProducts(String keyword, Integer categoryId, Integer brandId, Boolean isActive) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT_BIG(*) AS TotalProducts FROM dbo.vw_ProductCatalog WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildFilterConditions(sql, params, keyword, categoryId, brandId, null, null, isActive);

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            setStatementParams(statement, params);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("TotalProducts");
                }
                return 0L;
            }
        }
    }

    public List<Product> getAdminProducts(String keyword, Integer categoryId, Integer brandId,
            Boolean isActive, long page, int pageSize) throws SQLException {
        validateLimit(pageSize);
        if (page < 1) page = 1;
        long offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder("SELECT ").append(COLUMNS)
                .append(" FROM dbo.vw_ProductCatalog WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildFilterConditions(sql, params, keyword, categoryId, brandId, null, null, isActive);

        sql.append(" ORDER BY CreatedAt DESC, ProductID DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            setStatementParams(statement, params);
            try (ResultSet result = statement.executeQuery()) {
                return readProducts(result);
            }
        }
    }

    public int addProduct(Product product) throws SQLException {
        String sql = "INSERT INTO dbo.Product (ProductName, BrandID, CategoryID, [Description], Price, "
                + "StockQuantity, WarrantyPeriod, ImageURL, IsFeatured, IsActive) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, product.getProductName());
            statement.setInt(2, product.getBrandId());
            statement.setInt(3, product.getCategoryId());
            statement.setString(4, product.getDescription());
            statement.setBigDecimal(5, product.getPrice());
            statement.setInt(6, product.getStockQuantity());
            statement.setInt(7, product.getWarrantyPeriod());
            statement.setString(8, product.getImageUrl());
            statement.setBoolean(9, product.isFeatured());
            statement.setBoolean(10, product.isActive());

            int affected = statement.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = statement.getGeneratedKeys()) {
                    if (rs.next()) {
                        int id = rs.getInt(1);
                        product.setProductId(id);
                        return id;
                    }
                }
            }
        }
        return 0;
    }

    public boolean updateProduct(Product product) throws SQLException {
        String sql = "UPDATE dbo.Product SET ProductName = ?, BrandID = ?, CategoryID = ?, "
                + "[Description] = ?, Price = ?, StockQuantity = ?, WarrantyPeriod = ?, "
                + "ImageURL = ?, IsFeatured = ?, IsActive = ? "
                + "WHERE ProductID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, product.getProductName());
            statement.setInt(2, product.getBrandId());
            statement.setInt(3, product.getCategoryId());
            statement.setString(4, product.getDescription());
            statement.setBigDecimal(5, product.getPrice());
            statement.setInt(6, product.getStockQuantity());
            statement.setInt(7, product.getWarrantyPeriod());
            statement.setString(8, product.getImageUrl());
            statement.setBoolean(9, product.isFeatured());
            statement.setBoolean(10, product.isActive());
            statement.setInt(11, product.getProductId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean toggleProductActive(int productId) throws SQLException {
        String sql = "UPDATE dbo.Product SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE ProductID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Deletes a product or deactivates it if it is already referenced in orders.
     * Returns true if either deleted or deactivated successfully.
     */
    public boolean deleteProduct(int productId) throws SQLException {
        // Check if product is in invoice history
        String checkSql = "SELECT COUNT(*) FROM dbo.InvoiceDetail WHERE ProductID = ?";
        try (PreparedStatement checkStmt = connection.prepareStatement(checkSql)) {
            checkStmt.setInt(1, productId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Safe soft-delete to protect order integrity
                    String softDeleteSql = "UPDATE dbo.Product SET IsActive = 0 WHERE ProductID = ?";
                    try (PreparedStatement softStmt = connection.prepareStatement(softDeleteSql)) {
                        softStmt.setInt(1, productId);
                        return softStmt.executeUpdate() > 0;
                    }
                }
            }
        }
        // No orders, perform hard delete
        String deleteSql = "DELETE FROM dbo.Product WHERE ProductID = ?";
        try (PreparedStatement deleteStmt = connection.prepareStatement(deleteSql)) {
            deleteStmt.setInt(1, productId);
            return deleteStmt.executeUpdate() > 0;
        }
    }

    public boolean isProductNameExists(String productName, int excludeProductId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.Product WHERE ProductName = ? AND ProductID <> ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, productName.trim());
            statement.setInt(2, excludeProductId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public long[] getAdminProductStats() throws SQLException {
        // [0] = total, [1] = active, [2] = inactive, [3] = out of stock
        long[] stats = new long[4];
        String sql = "SELECT "
                + "COUNT(*) AS Total, "
                + "SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveCount, "
                + "SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS InactiveCount, "
                + "SUM(CASE WHEN StockQuantity = 0 THEN 1 ELSE 0 END) AS OutOfStock "
                + "FROM dbo.Product";
        try (PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                stats[0] = rs.getLong("Total");
                stats[1] = rs.getLong("ActiveCount");
                stats[2] = rs.getLong("InactiveCount");
                stats[3] = rs.getLong("OutOfStock");
            }
        }
        return stats;
    }

    // ==========================================
    // Helper Methods
    // ==========================================

    private void buildFilterConditions(StringBuilder sql, List<Object> params,
            String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, Boolean isActive) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (ProductName LIKE ? OR [Description] LIKE ?)");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND CategoryID = ?");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND BrandID = ?");
            params.add(brandId);
        }
        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append(" AND Price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND Price <= ?");
            params.add(maxPrice);
        }
        if (isActive != null) {
            sql.append(" AND IsActive = ?");
            params.add(isActive ? 1 : 0);
        }
    }

    private void setStatementParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            int paramIndex = i + 1;
            if (param instanceof String) {
                statement.setString(paramIndex, (String) param);
            } else if (param instanceof Integer) {
                statement.setInt(paramIndex, (Integer) param);
            } else if (param instanceof Long) {
                statement.setLong(paramIndex, (Long) param);
            } else if (param instanceof BigDecimal) {
                statement.setBigDecimal(paramIndex, (BigDecimal) param);
            } else if (param instanceof Boolean) {
                statement.setBoolean(paramIndex, (Boolean) param);
            } else {
                statement.setObject(paramIndex, param);
            }
        }
    }

    private List<Product> getTopProducts(String sql, int limit) throws SQLException {
        validateLimit(limit);
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
        if (connection != null && !connection.isClosed()) {
            connection.close();
        }
    }
}
