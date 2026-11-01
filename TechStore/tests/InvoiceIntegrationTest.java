import dal.DBContext;
import dao.OrderDAO;
import dao.ReviewDAO;
import model.*;
import util.PasswordUtil;
import util.VietnameseMoneyUtil;
import java.math.BigDecimal;
import java.net.CookieManager;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

/** LOCAL fixtures only; no real bank transfer, schema changes or production-order writes. */
public class InvoiceIntegrationTest extends DBContext {
    private final String prefix = "invoicetest" + System.currentTimeMillis();
    private final String password = UUID.randomUUID() + "Aa1!";
    private final List<Integer> customers = new ArrayList<>(), accounts = new ArrayList<>(), products = new ArrayList<>();
    private String base = "http://localhost:8081/TechStore";
    private int customerA, customerB, accountA, productA, productB, cod, qr, pending, confirmed, cancelled, invalidQr, longInvoice, assertions;

    void check(boolean valid, String label) {
        if (!valid) throw new AssertionError(label);
        assertions++; System.out.println("PASS " + label);
    }
    static void bind(PreparedStatement s, Object... values) throws SQLException {
        for (int i=0;i<values.length;i++) s.setObject(i+1,values[i]);
    }
    int insert(String sql, Object... values) throws SQLException {
        try (PreparedStatement s=connection.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)) {
            bind(s,values); s.executeUpdate(); try (ResultSet r=s.getGeneratedKeys()) { r.next(); return r.getInt(1); }
        }
    }
    void execute(String sql, Object... values) throws SQLException {
        try (PreparedStatement s=connection.prepareStatement(sql)) { bind(s,values); s.executeUpdate(); }
    }
    int number(String sql, Object... values) throws SQLException {
        try (PreparedStatement s=connection.prepareStatement(sql)) {
            bind(s,values); try (ResultSet r=s.executeQuery()) { r.next(); return r.getInt(1); }
        }
    }
    int product(String name, int price) throws SQLException {
        int id=insert("INSERT dbo.Product(ProductName,BrandID,CategoryID,Price,StockQuantity) SELECT ?,"
                + "(SELECT MIN(BrandID) FROM dbo.Brand),(SELECT MIN(CategoryID) FROM dbo.Category),?,100",name,price);
        products.add(id); return id;
    }
    int order(String method, String status, Map<Integer,Integer> quantities) throws SQLException {
        try (OrderDAO dao=new OrderDAO()) {
            Map<Integer,CartItem> cart=new LinkedHashMap<>();
            for (Map.Entry<Integer,Integer> item:quantities.entrySet()) cart.put(item.getKey(),new CartItem(dao.findCartProduct(item.getKey()),item.getValue()));
            int id=dao.checkout(customerA,cart,"Người mua <script>alert(1)</script>","0900000000","Địa chỉ <img src=x onerror=alert(1)> LOCAL TEST",method);
            if ("CANCELLED".equals(status)) dao.cancelPending(id,customerA);
            else {
                if ("QR".equals(method) && ("PAID_ONLY".equals(status) || "COMPLETED".equals(status))) dao.confirmPayment(id);
                if ("CONFIRMED".equals(status) || "COMPLETED".equals(status)) dao.updateStatus(id,"CONFIRMED");
                if ("COMPLETED".equals(status)) dao.updateStatus(id,"COMPLETED");
            }
            return id;
        }
    }
    void setup() throws Exception {
        if (connection==null) throw new SQLException("Local DB unavailable");
        String hash=PasswordUtil.hashPassword(password);
        for (String role:new String[]{"A","B","ADMIN"}) {
            Integer customer=null;
            if (!role.equals("ADMIN")) { customer=insert("INSERT dbo.Customer(FullName) VALUES (?)",prefix+role); customers.add(customer); if (role.equals("A")) customerA=customer; else customerB=customer; }
            int account=insert("INSERT dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role) VALUES (?,?,?,?,?)",customer,prefix+role,prefix+role+"@example.invalid",hash,role.equals("ADMIN")?"ADMIN":"CUSTOMER");
            accounts.add(account); if (role.equals("A")) accountA=account;
        }
        productA=product(prefix+" Laptop <script>window.invoiceXss=1</script>",1590000);
        productB=product(prefix+" Phụ kiện",790000);
        cod=order("COD","COMPLETED",Map.of(productA,2,productB,3));
        qr=order("QR","COMPLETED",Map.of(productA,1));
        pending=order("COD","PENDING",Map.of(productB,1));
        confirmed=order("COD","CONFIRMED",Map.of(productB,1));
        cancelled=order("COD","CANCELLED",Map.of(productB,1));
        invalidQr=order("QR","PAID_ONLY",Map.of(productB,1));
        Map<Integer,Integer> many=new LinkedHashMap<>();
        for (int i=1;i<=38;i++) many.put(product(prefix+" Thiết bị kiểm thử nhiều trang "+i,10000+i),1);
        longInvoice=order("COD","COMPLETED",many);
        execute("UPDATE dbo.Invoice SET CompletedAt='2026-11-01T10:30:00' WHERE InvoiceID=?",cod);
        execute("UPDATE dbo.Product SET Price=999999 WHERE ProductID=?",productA); // Only fixture catalog price changes.
        execute("UPDATE dbo.Customer SET FullName=N'Tên hồ sơ mới',DefaultAddress=N'Địa chỉ hồ sơ mới' WHERE CustomerID=?",customerA);
    }
    void cleanup() throws SQLException {
        connection.setAutoCommit(false);
        try {
            for (int account:accounts) execute("DELETE dbo.ProductReview WHERE AccountID=?",account);
            for (int customer:customers) {
                execute("DELETE d FROM dbo.InvoiceDetail d JOIN dbo.Invoice i ON i.InvoiceID=d.InvoiceID WHERE i.CustomerID=?",customer);
                execute("DELETE dbo.Invoice WHERE CustomerID=?",customer);
            }
            for (int account:accounts) execute("DELETE dbo.UserAccount WHERE AccountID=?",account);
            for (int customer:customers) execute("DELETE dbo.Customer WHERE CustomerID=?",customer);
            for (int product:products) execute("DELETE dbo.Product WHERE ProductID=?",product);
            connection.commit(); System.out.println("CLEANUP PASS: only invoice fixtures removed; existing orders, stock and identities preserved.");
        } catch (SQLException e) { connection.rollback(); throw e; }
        finally { connection.close(); }
    }
    class Browser {
        final HttpClient client=HttpClient.newBuilder().cookieHandler(new CookieManager()).followRedirects(HttpClient.Redirect.NEVER).build();
        HttpResponse<String> get(String path) throws Exception {
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).GET().build(),HttpResponse.BodyHandlers.ofString());
        }
        HttpResponse<String> post(String path, Map<String,String> fields) throws Exception {
            StringJoiner form=new StringJoiner("&"); fields.forEach((k,v)->form.add(URLEncoder.encode(k,StandardCharsets.UTF_8)+"="+URLEncoder.encode(v,StandardCharsets.UTF_8)));
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).header("Content-Type","application/x-www-form-urlencoded").POST(HttpRequest.BodyPublishers.ofString(form.toString())).build(),HttpResponse.BodyHandlers.ofString());
        }
        void login(String role) throws Exception { check(post("/login",Map.of("username",prefix+role,"password",password)).statusCode()==302,"fixture login "+role); }
    }
    void moneyTests() {
        String[][] examples={{"0","Không đồng."},{"1","Một đồng."},{"15","Mười lăm đồng."},{"21","Hai mươi mốt đồng."},
                {"105","Một trăm lẻ năm đồng."},{"1001","Một nghìn không trăm lẻ một đồng."},{"1000001","Một triệu không trăm lẻ một đồng."},
                {"1590000","Một triệu năm trăm chín mươi nghìn đồng."},{"5550000.00","Năm triệu năm trăm năm mươi nghìn đồng."},
                {"1000000000000000000","Một tỷ tỷ đồng."}};
        for (String[] example:examples) check(VietnameseMoneyUtil.toWords(new BigDecimal(example[0])).equals(example[1]),"exact VND words "+example[0]);
        for (String invalid:new String[]{"-1","0.5"}) {
            boolean rejected=false; try { VietnameseMoneyUtil.toWords(new BigDecimal(invalid)); } catch (IllegalArgumentException e) { rejected=true; }
            check(rejected,"invalid/nonintegral VND not rounded: "+invalid);
        }
    }
    void tests() throws Exception {
        moneyTests();
        Browser owner=new Browser(), other=new Browser(), admin=new Browser(), guest=new Browser();
        owner.login("A"); other.login("B"); admin.login("ADMIN");
        check(guest.get("/invoice?orderId="+cod).statusCode()==302,"04 guest redirected to login");
        HttpResponse<String> foreign=other.get("/invoice?orderId="+cod);
        check(foreign.statusCode()==404 && !foreign.body().contains(prefix) && !foreign.body().contains("0900000000"),"02 non-owner cannot see invoice or private order details");
        HttpResponse<String> invoice=owner.get("/invoice?orderId="+cod+"&amount=1&customerId="+customerB);
        String html=invoice.body();
        check(invoice.statusCode()==200,"01 completed COD owner can view invoice");
        check(invoice.headers().firstValue("Cache-Control").orElse("").contains("no-store"),"private invoice is not cached");
        check(html.contains("TS-"+cod) && html.contains("01/11/2026 10:30"),"invoice number/date derive from stored order, not current view time");
        check(html.contains(prefix+" Laptop &lt;script&gt;window.invoiceXss=1&lt;/script&gt;") && html.contains(prefix+" Phụ kiện"),"05 actual product names escaped correctly");
        check(html.contains("invoice-quantity\">2</td>") && html.contains("invoice-quantity\">3</td>"),"06 stored quantities displayed");
        check(html.contains("1.590.000") && html.contains("790.000") && !html.contains("999.999"),"07 stored purchase prices used after catalog price changes");
        check(html.contains("3.180.000") && html.contains("2.370.000"),"08 exact line totals");
        check(html.contains("5.550.000") && html.contains("Năm triệu năm trăm năm mươi nghìn đồng."),"09 exact total and amount in words, amount query ignored");
        check(html.contains("Thanh toán khi nhận hàng (COD)"),"10 COD method displayed");
        check(html.contains("Chưa ghi nhận thanh toán") && html.contains("(UNPAID)"),"11 historical COD UNPAID is not falsely relabelled PAID");
        check(html.contains("(COMPLETED)"),"12 completed delivery state displayed");
        check(html.contains("Người mua &lt;script&gt;alert(1)&lt;/script&gt;") && !html.contains("Tên hồ sơ mới"),"buyer information comes from invoice shipping snapshot");
        check(html.contains("&lt;img src=x onerror=alert(1)&gt;") && !html.contains("<script>window.invoiceXss=1"),"HTML in shipping and product fields stays plain text");
        check(!html.contains(prefix+"A@example.invalid"),"buyer account email not disclosed unnecessarily");
        check(!html.contains("Mã số thuế:"),"missing seller tax ID is omitted, not fabricated");
        check(html.contains("window.print()") && !html.contains("ts-header") && !html.contains("ts-footer"),"13 standalone print action without website navigation/footer");
        check(admin.get("/invoice?orderId="+cod).statusCode()==200,"03 ADMIN can read owner's completed invoice");
        String qrHtml=owner.get("/invoice?orderId="+qr).body();
        check(qrHtml.contains("Chuyển khoản VietQR (QR)") && qrHtml.contains("Đã xác nhận nhận tiền") && qrHtml.contains("(PAID)"),"10/11 completed QR displays actual PAID status");
        for (int id:new int[]{pending,confirmed,cancelled,invalidQr}) check(owner.get("/invoice?orderId="+id).statusCode()==409,"ineligible order invoice blocked: "+id);
        execute("UPDATE dbo.Invoice SET OrderStatus='COMPLETED',CompletedAt=SYSDATETIME(),PaymentStatus='UNPAID' WHERE InvoiceID=?",invalidQr);
        check(owner.get("/invoice?orderId="+invalidQr).statusCode()==409,"inconsistent legacy COMPLETED QR without PAID also blocked");
        for (String id:new String[]{"bad","0","-1","1%20OR%201=1"}) check(owner.get("/invoice?orderId="+id).statusCode()==400,"malformed ID rejected without SQL injection: "+id);
        check(owner.get("/invoice?orderId=2147483647").statusCode()==404,"missing invoice handled safely");
        check(owner.post("/invoice",Map.of("orderId",""+cod)).statusCode()==405,"invoice POST not allowed; view cannot mutate payment");
        String history=owner.get("/orders").body(), adminOrders=admin.get("/admin/orders").body();
        check(history.contains("/invoice?orderId="+cod) && history.contains("/invoice?orderId="+qr),"customer history invoice links for eligible orders");
        check(!history.contains("/invoice?orderId="+pending) && !history.contains("/invoice?orderId="+invalidQr),"history hides invoice link for ineligible orders");
        check(adminOrders.contains("/invoice?orderId="+cod),"admin invoice link integrated without changing order actions");
        int invoiceCount=number("SELECT COUNT(*) FROM dbo.Invoice WHERE CustomerID=?",customerA);
        int stock=number("SELECT StockQuantity FROM dbo.Product WHERE ProductID=?",productA);
        owner.get("/invoice?orderId="+cod); owner.get("/invoice?orderId="+cod);
        check(invoiceCount==number("SELECT COUNT(*) FROM dbo.Invoice WHERE CustomerID=?",customerA) && stock==number("SELECT StockQuantity FROM dbo.Product WHERE ProductID=?",productA),"repeat invoice GET creates no order and never changes stock");
        try (OrderDAO dao=new OrderDAO()) {
            check("UNPAID".equals(dao.getOrder(cod,customerA).getPaymentStatus()) && "PAID".equals(dao.getOrder(qr,customerA).getPaymentStatus()),"17/18 invoice view leaves COD/QR payment statuses unchanged");
        }
        try (ReviewDAO dao=new ReviewDAO()) {
            ProductReview review=new ProductReview(); review.setAccountId(accountA); review.setProductId(productA); review.setRating(5); review.setComment("Invoice fixture review");
            dao.saveReview(review); check(dao.getReviewByUserAndProduct(accountA,productA)!=null,"19 completed purchase reviews still save and load");
        }
        check(owner.get("/product-detail?id="+productA).statusCode()==200 && owner.get("/payment-qr?orderId="+qr).statusCode()==200,"18/19 existing product/QR pages still load");
        System.out.println("ALL INVOICE INTEGRATION CHECKS PASSED: "+assertions);
    }
    void browserTests() throws Exception {
        ProcessBuilder browser=new ProcessBuilder("node","tests/InvoicePrintCheck.js");
        browser.environment().put("INVOICE_TEST_BASE",base);
        browser.environment().put("INVOICE_TEST_USERNAME",prefix+"A");
        browser.environment().put("INVOICE_TEST_PASSWORD",password);
        browser.environment().put("INVOICE_TEST_ORDER",String.valueOf(cod));
        browser.environment().put("INVOICE_TEST_LONG_ORDER",String.valueOf(longInvoice));
        check(browser.inheritIO().start().waitFor()==0,"real-browser A4/PDF checks");
    }
    public static void main(String[] args) throws Exception {
        InvoiceIntegrationTest test=new InvoiceIntegrationTest();
        if (args.length>0) test.base=args[0];
        try { test.setup(); test.tests(); if (args.length>1 && args[1].equals("--print")) test.browserTests(); }
        finally { test.cleanup(); }
    }
}
