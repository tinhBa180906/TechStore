/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dal.DBContext;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import model.*;

/**
 *
 * @author Tinh Ba
 */
public class OrderDAO extends DBContext implements AutoCloseable {
    public OrderDAO() throws SQLException {
        if (connection == null) throw new SQLException("Order database unavailable.");
    }

    public Product findCartProduct(int id) throws SQLException {
        try (PreparedStatement s = connection.prepareStatement(
                "SELECT ProductID,ProductName,Price,StockQuantity,IsActive FROM dbo.Product WHERE ProductID=?")) {
            s.setInt(1, id);
            try (ResultSet r = s.executeQuery()) {
                if (!r.next()) return null;
                Product p = new Product();
                p.setProductId(r.getInt("ProductID"));
                p.setProductName(r.getString("ProductName"));
                p.setPrice(r.getBigDecimal("Price"));
                p.setStockQuantity(r.getInt("StockQuantity"));
                p.setIsActive(r.getBoolean("IsActive"));
                return p;
            }
        }
    }

    public List<Product> getCartProducts() throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT ProductID,ProductName FROM dbo.Product WHERE IsActive=1 AND StockQuantity>0 ORDER BY ProductName";
        try (PreparedStatement s = connection.prepareStatement(sql);
                ResultSet r = s.executeQuery()) {
            while (r.next()) {
                Product product = new Product();
                product.setProductId(r.getInt("ProductID"));
                product.setProductName(r.getString("ProductName"));
                products.add(product);
            }
        }
        return products;
    }

    public int checkout(int customerId, Map<Integer, CartItem> cart, String name,
            String phone, String address) throws SQLException {
        if (customerId < 1 || cart == null || cart.isEmpty())
            throw new IllegalArgumentException("Giỏ hàng trống hoặc tài khoản không hợp lệ.");
        if (name == null || name.trim().length() < 2 || name.length() > 100
                || phone == null || !phone.matches("[+0-9][0-9 .()-]{7,14}")
                || address == null || address.trim().isEmpty() || address.length() > 255)
            throw new IllegalArgumentException("Thông tin nhận hàng không hợp lệ.");
        boolean autoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            Map<Integer, BigDecimal> prices = new HashMap<>();
            // Roll back the whole order if any product has insufficient stock.
            for (Map.Entry<Integer, CartItem> entry : cart.entrySet()) {
                int quantity = entry.getValue().getQuantity();
                if (quantity < 1) throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
                try (PreparedStatement s = connection.prepareStatement(
                        "UPDATE dbo.Product SET StockQuantity=StockQuantity-? "
                        + "WHERE ProductID=? AND IsActive=1 AND StockQuantity>=?")) {
                    s.setInt(1, quantity); s.setInt(2, entry.getKey()); s.setInt(3, quantity);
                    if (s.executeUpdate() != 1) throw new IllegalArgumentException(
                                "Sản phẩm #" + entry.getKey() + " đã ngừng bán hoặc không đủ tồn kho.");
                    Product product = findCartProduct(entry.getKey());
                    prices.put(entry.getKey(), product.getPrice());
                }
            }
            int orderId;
            try (PreparedStatement s = connection.prepareStatement(
                    "INSERT INTO dbo.Invoice(CustomerID,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress) "
                    + "VALUES (?,'PENDING','COD',?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
                s.setInt(1, customerId); s.setNString(2, name.trim());
                s.setString(3, phone); s.setNString(4, address.trim()); s.executeUpdate();
                try (ResultSet r = s.getGeneratedKeys()) {
                    if (!r.next()) throw new SQLException("Missing invoice key.");
                    orderId = r.getInt(1);
                }
            }
            try (PreparedStatement s = connection.prepareStatement(
                    "INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice) VALUES (?,?,?,?)")) {
                for (Map.Entry<Integer, BigDecimal> price : prices.entrySet()) {
                    s.setInt(1, orderId); s.setInt(2, price.getKey());
                    s.setInt(3, cart.get(price.getKey()).getQuantity()); s.setBigDecimal(4, price.getValue());
                    s.executeUpdate();
                }
            }
            connection.commit();
            return orderId;
        } catch (SQLException | RuntimeException e) {
            try { connection.rollback(); } catch (SQLException rollback) { e.addSuppressed(rollback); }
            throw e;
        } finally {
            connection.setAutoCommit(autoCommit);
        }
    }

    public List<Order> getOrders(Integer customerId) throws SQLException {
        String sql = "SELECT * FROM dbo.vw_OrderTotals"
                + (customerId == null ? "" : " WHERE CustomerID=?") + " ORDER BY InvoiceID DESC";
        List<Order> orders = new ArrayList<>();
        try (PreparedStatement s = connection.prepareStatement(sql)) {
            if (customerId != null) s.setInt(1, customerId);
            try (ResultSet r = s.executeQuery()) {
                while (r.next()) orders.add(readOrder(r));
            }
        }
        for (Order order : orders) order.setDetails(getDetails(order.getOrderId()));
        return orders;
    }

    private Order readOrder(ResultSet r) throws SQLException {
        Order o = new Order();
        o.setOrderId(r.getInt("InvoiceID")); o.setCustomerId(r.getInt("CustomerID"));
        o.setDateCreated(r.getTimestamp("DateCreated").toLocalDateTime());
        o.setOrderStatus(r.getString("OrderStatus")); o.setPaymentMethod(r.getString("PaymentMethod"));
        o.setShippingName(r.getString("ShippingName")); o.setShippingPhone(r.getString("ShippingPhone"));
        o.setShippingAddress(r.getString("ShippingAddress"));
        Timestamp completed = r.getTimestamp("CompletedAt");
        o.setCompleteAt(completed == null ? null : completed.toLocalDateTime());
        o.setTotalAmount(r.getBigDecimal("TotalAmount"));
        return o;
    }

    private List<OrderDetail> getDetails(int id) throws SQLException {
        List<OrderDetail> details = new ArrayList<>();
        try (PreparedStatement s = connection.prepareStatement(
                "SELECT d.*,p.ProductName FROM dbo.InvoiceDetail d JOIN dbo.Product p ON p.ProductID=d.ProductID WHERE d.InvoiceID=? ORDER BY d.ProductID")) {
            s.setInt(1, id);
            try (ResultSet r = s.executeQuery()) {
                while (r.next()) {
                    Product p = new Product(); p.setProductId(r.getInt("ProductID"));
                    p.setProductName(r.getString("ProductName"));
                    details.add(new OrderDetail(r.getInt("InvoiceDetailID"), id, p.getProductId(),
                            r.getInt("Quantity"), r.getBigDecimal("UnitPrice"), p));
                }
            }
        }
        return details;
    }

    public void cancelPending(int id, int customerId) throws SQLException {
        try (CallableStatement s = connection.prepareCall("{call dbo.sp_CancelPendingOrder(?,?)}")) {
            s.setInt(1, id); s.setInt(2, customerId); s.execute();
        }
    }

    /** PENDING -> CONFIRMED -> COMPLETED; cancellation is PENDING only. */
    public void updateStatus(int id, String status) throws SQLException {
        if ("CANCELLED".equals(status)) {
            int customerId;
            try (PreparedStatement s = connection.prepareStatement("SELECT CustomerID FROM dbo.Invoice WHERE InvoiceID=?")) {
                s.setInt(1, id);
                try (ResultSet r = s.executeQuery()) {
                    if (!r.next()) throw new IllegalArgumentException("Không tìm thấy đơn hàng.");
                    customerId = r.getInt(1);
                }
            }
            cancelPending(id, customerId);
            return;
        }
        String previous;
        if ("CONFIRMED".equals(status)) previous = "PENDING";
        else if ("COMPLETED".equals(status)) previous = "CONFIRMED";
        else throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        try (PreparedStatement s = connection.prepareStatement(
                "UPDATE dbo.Invoice SET OrderStatus=?,CompletedAt="
                + ("COMPLETED".equals(status) ? "SYSDATETIME()" : "NULL")
                + " WHERE InvoiceID=? AND OrderStatus=?")) {
            s.setString(1, status); s.setInt(2, id); s.setString(3, previous);
            if (s.executeUpdate() != 1) throw new IllegalArgumentException("Đơn hàng đã thay đổi hoặc không thể chuyển trạng thái này.");
        }
    }

    public Map<String, Object> getStatistics() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        try (PreparedStatement s = connection.prepareStatement(
                "SELECT COUNT_BIG(*) TotalOrders,COALESCE(SUM(CASE WHEN OrderStatus='COMPLETED' THEN TotalAmount ELSE 0 END),0) Revenue,"
                + "COUNT_BIG(CASE WHEN OrderStatus='COMPLETED' THEN 1 END) CompletedOrders FROM dbo.vw_OrderTotals");
                ResultSet r = s.executeQuery()) {
            r.next(); stats.put("totalOrders", r.getLong("TotalOrders"));
            stats.put("completedOrders", r.getLong("CompletedOrders")); stats.put("revenue", r.getBigDecimal("Revenue"));
        }
        List<Map<String, Object>> best = new ArrayList<>();
        try (PreparedStatement s = connection.prepareStatement(
                "SELECT TOP (10) p.ProductID,p.ProductName,SUM(CAST(d.Quantity AS BIGINT)) UnitsSold,"
                + "SUM(d.UnitPrice*CAST(d.Quantity AS DECIMAL(18,0))) Revenue FROM dbo.InvoiceDetail d "
                + "JOIN dbo.Invoice i ON i.InvoiceID=d.InvoiceID JOIN dbo.Product p ON p.ProductID=d.ProductID "
                + "WHERE i.OrderStatus='COMPLETED' GROUP BY p.ProductID,p.ProductName ORDER BY UnitsSold DESC,p.ProductID");
                ResultSet r = s.executeQuery()) {
            while (r.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("productName", r.getString("ProductName")); row.put("unitsSold", r.getLong("UnitsSold"));
                row.put("revenue", r.getBigDecimal("Revenue")); best.add(row);
            }
        }
        stats.put("bestSelling", best);
        return stats;
    }

    @Override public void close() throws SQLException { connection.close(); }
}
