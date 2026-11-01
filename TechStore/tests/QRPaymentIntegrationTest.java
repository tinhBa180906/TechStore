import dao.OrderDAO;
import dal.DBContext;
import model.CartItem;
import model.Order;
import model.Product;
import util.PasswordUtil;
import util.VietQRUtil;
import java.math.BigDecimal;
import java.net.CookieManager;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.regex.*;

/** LOCAL integration checks only. Creates and removes its own uniquely named fixtures.
 * No real transfer and no remote QR-image request. Run after migration and local deployment.
 */
public class QRPaymentIntegrationTest extends DBContext {
    private int customerA, customerB, productId;
    private String prefix = "qrtest" + System.currentTimeMillis();
    private String password = UUID.randomUUID() + "Aa1!";
    private String base = "http://localhost:8081/TechStore";
    private int checks;

    interface Action { void run() throws Exception; }
    void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++; System.out.println("PASS " + message);
    }
    void rejects(Action action, String message) throws Exception {
        boolean rejected = false;
        try { action.run(); } catch (SQLException | IllegalArgumentException e) { rejected = true; }
        check(rejected, message);
    }
    int insert(String sql, Object... values) throws SQLException {
        try (PreparedStatement s = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(s, values); s.executeUpdate();
            try (ResultSet r = s.getGeneratedKeys()) { r.next(); return r.getInt(1); }
        }
    }
    void execute(String sql, Object... values) throws SQLException {
        try (PreparedStatement s = connection.prepareStatement(sql)) { bind(s, values); s.executeUpdate(); }
    }
    static void bind(PreparedStatement s, Object... values) throws SQLException {
        for (int i=0; i<values.length; i++) s.setObject(i+1, values[i]);
    }
    int number(String sql, Object... values) throws SQLException {
        try (PreparedStatement s = connection.prepareStatement(sql)) {
            bind(s, values); try (ResultSet r = s.executeQuery()) { r.next(); return r.getInt(1); }
        }
    }
    int stock() throws SQLException { return number("SELECT StockQuantity FROM dbo.Product WHERE ProductID=?", productId); }
    int count() throws SQLException { return number("SELECT COUNT(*) FROM dbo.Invoice WHERE CustomerID=?", customerA); }
    Map<Integer, CartItem> cart(OrderDAO dao, int quantity) throws SQLException {
        Map<Integer, CartItem> result = new LinkedHashMap<>();
        result.put(productId, new CartItem(dao.findCartProduct(productId), quantity)); return result;
    }
    int checkout(OrderDAO dao, String method) throws SQLException {
        return dao.checkout(customerA, cart(dao, 2), "QR Test Fixture", "0900000000", "LOCAL TEST ONLY", method);
    }
    Order order(int id) throws SQLException {
        try (OrderDAO dao = new OrderDAO()) { return dao.getOrder(id, customerA); }
    }
    void setup() throws Exception {
        if (connection == null) throw new SQLException("Local database unavailable");
        customerA = insert("INSERT dbo.Customer(FullName) VALUES (?)", prefix + " A");
        customerB = insert("INSERT dbo.Customer(FullName) VALUES (?)", prefix + " B");
        String hash = PasswordUtil.hashPassword(password);
        for (String role : new String[]{"A", "B", "ADMIN"}) {
            execute("INSERT dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role) VALUES (?,?,?,?,?)",
                    "ADMIN".equals(role) ? null : ("A".equals(role) ? customerA : customerB),
                    prefix+role, prefix+role+"@example.invalid", hash, "ADMIN".equals(role) ? "ADMIN" : "CUSTOMER");
        }
        productId = insert("INSERT dbo.Product(ProductName,BrandID,CategoryID,Price,StockQuantity) "
                + "SELECT ?, (SELECT MIN(BrandID) FROM dbo.Brand), (SELECT MIN(CategoryID) FROM dbo.Category),1590000,100", prefix);
    }
    void cleanup() throws SQLException {
        // Only fixture IDs/unique usernames are touched; no seed/member data or existing stock is changed.
        connection.setAutoCommit(false);
        try {
            execute("DELETE d FROM dbo.InvoiceDetail d JOIN dbo.Invoice i ON i.InvoiceID=d.InvoiceID WHERE i.CustomerID IN (?,?)", customerA, customerB);
            execute("DELETE dbo.Invoice WHERE CustomerID IN (?,?)", customerA, customerB);
            execute("DELETE dbo.UserAccount WHERE Username IN (?,?,?)", prefix+"A", prefix+"B", prefix+"ADMIN");
            execute("DELETE dbo.Customer WHERE CustomerID IN (?,?)", customerA, customerB);
            if (productId != 0) execute("DELETE dbo.Product WHERE ProductID=?", productId);
            connection.commit();
            System.out.println("CLEANUP PASS: only temporary fixture records removed; identity gaps expected.");
        } catch (SQLException e) { connection.rollback(); throw e; }
        finally { connection.close(); }
    }

    class Browser {
        HttpClient client = HttpClient.newBuilder().cookieHandler(new CookieManager())
                .followRedirects(HttpClient.Redirect.NEVER).build();
        HttpResponse<String> get(String path) throws Exception {
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        }
        HttpResponse<String> post(String path, Map<String,String> fields) throws Exception {
            StringJoiner body = new StringJoiner("&");
            fields.forEach((key,value)->body.add(URLEncoder.encode(key,StandardCharsets.UTF_8)+"="+URLEncoder.encode(value,StandardCharsets.UTF_8)));
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).header("Content-Type","application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString())).build(), HttpResponse.BodyHandlers.ofString());
        }
        void login(String role) throws Exception {
            check(post("/login", Map.of("username",prefix+role,"password",password)).statusCode()==302,"HTTP login fixture " + role);
        }
    }
    static String hidden(String html, String name) {
        Matcher m=Pattern.compile("name=\""+name+"\" value=\"([^\"]*)\"").matcher(html);
        if (!m.find()) throw new AssertionError("Missing hidden field " + name);
        return m.group(1);
    }
    Map<String,String> checkoutFields(String page, String method) {
        Map<String,String> fields=new HashMap<>();
        fields.put("csrf",hidden(page,"csrf")); fields.put("checkoutToken",hidden(page,"checkoutToken"));
        fields.put("shippingName","QR Test Fixture"); fields.put("shippingPhone","0900000000");
        fields.put("shippingAddress","LOCAL TEST ONLY");
        if (method != null) fields.put("paymentMethod",method);
        return fields;
    }
    @SuppressWarnings("unchecked")
    static <T> T proxy(Class<T> type, java.lang.reflect.InvocationHandler handler) {
        return (T) java.lang.reflect.Proxy.newProxyInstance(type.getClassLoader(),new Class<?>[]{type},handler);
    }
    /** Run real checkout controller with an in-memory receiving config only. Never deploy/render it. */
    void qrControllerCheckout() throws Exception {
        Map<String,Object> sessionValues=new HashMap<>();
        model.Account user=new model.Account(); user.setCustomerId(customerA); user.setRole("CUSTOMER"); user.setIsActive(true);
        sessionValues.put("user",user); sessionValues.put("orderCsrf","test-csrf"); sessionValues.put("checkoutToken","test-once");
        try (OrderDAO dao=new OrderDAO()) { sessionValues.put("cart",cart(dao,1)); }
        jakarta.servlet.http.HttpSession session=proxy(jakarta.servlet.http.HttpSession.class,(p,m,args)-> {
            if (m.getName().equals("getAttribute")) return sessionValues.get(args[0]);
            if (m.getName().equals("setAttribute")) { sessionValues.put((String)args[0],args[1]); return null; }
            if (m.getName().equals("removeAttribute")) { sessionValues.remove(args[0]); return null; }
            return null;
        });
        Map<String,String> params=new HashMap<>(Map.of("csrf","test-csrf","checkoutToken","test-once","paymentMethod","QR",
                "paymentStatus","PAID","shippingName","QR Test Fixture","shippingPhone","0900000000","shippingAddress","LOCAL ONLY"));
        jakarta.servlet.http.HttpServletRequest request=proxy(jakarta.servlet.http.HttpServletRequest.class,(p,m,args)-> {
            if (m.getName().equals("getSession")) return session;
            if (m.getName().equals("getParameter")) return params.get(args[0]);
            if (m.getName().equals("getServletPath")) return "/checkout";
            if (m.getName().equals("getContextPath")) return "/TechStore";
            return null;
        });
        List<String> redirect=new ArrayList<>();
        jakarta.servlet.http.HttpServletResponse response=proxy(jakarta.servlet.http.HttpServletResponse.class,(p,m,args)-> {
            if (m.getName().equals("sendRedirect")) redirect.add((String)args[0]);
            return null;
        });
        jakarta.servlet.ServletContext context=proxy(jakarta.servlet.ServletContext.class,(p,m,args)-> {
            if (m.getName().equals("getResourceAsStream")) return new java.io.ByteArrayInputStream(
                    "vietqr.bankId=TESTBANK\nvietqr.accountNo=TESTONLY0001\nvietqr.accountName=TEST ONLY\n".getBytes(StandardCharsets.UTF_8));
            return null;
        });
        jakarta.servlet.ServletConfig servletConfig=proxy(jakarta.servlet.ServletConfig.class,(p,m,args)->m.getName().equals("getServletContext")?context:null);
        class CheckoutController extends controller.OrderServlet {
            void submit() throws Exception { super.doPost(request,response); }
        }
        CheckoutController controller=new CheckoutController(); controller.init(servletConfig);
        int before=count(), beforeStock=stock(); controller.submit();
        check(count()==before+1 && redirect.size()==1 && redirect.get(0).startsWith("/TechStore/payment-qr?orderId="),"02 real QR checkout controller creates one invoice and PRG redirect (in-memory config, no fake image rendered)");
        int id=Integer.parseInt(redirect.get(0).substring(redirect.get(0).lastIndexOf('=')+1));
        check("QR".equals(order(id).getPaymentMethod()) && "UNPAID".equals(order(id).getPaymentStatus()),"03/04 QR controller ignores client PAID, persists QR/UNPAID");
        check(stock()==beforeStock-1 && ((Map<?,?>)sessionValues.get("cart")).isEmpty() && !sessionValues.containsKey("checkoutToken"),"02/14 QR controller clears cart/token only after commit; one stock debit");
    }
    void runChecks() throws Exception {
        // Pure URL test data is deliberately fictional and NEVER rendered or sent to VietQR.
        VietQRUtil config=new VietQRUtil("TESTBANK", "TESTONLY0001", "TEST & UTF8 Đ");
        String url=config.imageUrl(128,new BigDecimal("1590000.00"));
        check(url.contains("TESTBANK-TESTONLY0001-compact2.svg?amount=1590000&addInfo=TECHSTORE128&accountName=TEST+%26+UTF8+%C4%90"),"05 exact URL construction and UTF-8 encoding (offline only)");
        check(config.imageUrl(128,new BigDecimal("1590000")).equals(url),"05 stable reference/amount, no random QR values");
        rejects(()->VietQRUtil.amountVnd(new BigDecimal("1.01")),"05 fractional VND rejected without rounding");
        rejects(()->VietQRUtil.amountVnd(BigDecimal.ZERO),"05 zero amount rejected");
        rejects(()->VietQRUtil.amountVnd(new BigDecimal("10000000000000")),"05 amount over 13 digits rejected");
        rejects(()->new VietQRUtil("", "", ""),"17 missing receiving config rejected");
        rejects(()->new VietQRUtil("../bad", "1", "Name"),"17 unsafe bank path rejected");
        qrControllerCheckout();

        int qr, cancelled;
        try (OrderDAO dao=new OrderDAO()) {
            int before=stock(), invoices=count();
            int cod=checkout(dao,"COD");
            check("COD".equals(order(cod).getPaymentMethod()) && stock()==before-2,"01 COD creates PENDING invoice and debits stock once");
            dao.cancelPending(cod,customerA);
            check(stock()==before,"01 COD cancellation restores stock once");
            rejects(()->dao.cancelPending(cod,customerA),"14 repeated cancellation rejected");
            check(stock()==before,"14 repeated cancellation does not restore twice");
            invoices=count(); qr=checkout(dao,"QR");
            check(count()==invoices+1 && order(qr).getDetails().size()==1,"02 QR DAO creates exactly one complete invoice");
            check("QR".equals(order(qr).getPaymentMethod()),"03 QR persisted");
            check("UNPAID".equals(order(qr).getPaymentStatus()),"04 UNPAID persisted");
            check(order(qr).getTotalAmount().compareTo(new BigDecimal("3180000"))==0,"05 amount from stored details");
            check(dao.getOrder(qr,customerB)==null,"09 DAO excludes other customer invoice");
            int qrStock=stock();
            rejects(()->dao.requestPaymentVerification(qr,customerB),"09 foreign customer declaration rejected");
            cancelled=checkout(dao,"QR"); dao.cancelPending(cancelled,customerA);
            rejects(()->dao.confirmPayment(cancelled),"12 cancelled QR confirmation rejected");
            rejects(()->dao.requestPaymentVerification(cancelled,customerA),"12 cancelled QR declaration rejected");
            check(stock()==qrStock,"14 cancelled second QR restores only its reserved stock");
            rejects(()->dao.confirmPayment(cod),"10 COD excluded from QR payment confirmation");
            int beforeFailure=stock(), beforeCount=count();
            rejects(()->dao.checkout(customerA,cart(dao,101),"QR Test", "0900000000","LOCAL", "QR"),"15 insufficient stock rejects checkout");
            check(count()==beforeCount && stock()==beforeFailure,"15 stock failure rolls back invoice and stock");
            rejects(()->checkout(dao,"PAID"),"16 forged payment method rejected by DAO");
            // Force a real InvoiceDetail constraint failure AFTER Invoice insertion, without adding a DB trigger.
            try (OrderDAO failing=new OrderDAO() {
                @Override public Product findCartProduct(int id) throws SQLException {
                    Product product=super.findCartProduct(id); product.setPrice(new BigDecimal("-1")); return product;
                }
            }) {
                rejects(()->checkout(failing,"COD"),"15 injected negative detail price fails SQL constraint after Invoice insertion");
            }
            check(count()==beforeCount && stock()==beforeFailure,"15 detail SQL failure rolls back Invoice, InvoiceDetail and stock");
            check(dao.getStatistics().containsKey("revenue"),"13 existing statistics query still works");
        }

        Browser a=new Browser(), b=new Browser(), admin=new Browser(), anonymous=new Browser();
        a.login("A"); b.login("B"); admin.login("ADMIN");
        check(anonymous.get("/payment-qr?orderId="+qr).statusCode()==302,"09 anonymous QR access redirects login");
        check(b.get("/payment-qr?orderId="+qr).statusCode()==404,"09 HTTP customer B cannot read A invoice");
        HttpResponse<String> page=a.get("/payment-qr?orderId="+qr+"&amount=1");
        check(page.statusCode()==200 && page.body().contains("3.180.000"),"05 QR page uses DB amount, ignores amount query");
        check(page.body().contains("VietQR chưa được cấu hình") && !page.body().contains("img.vietqr.io/image/"),"17 blank config displays explicit error without fake QR");
        int beforeRefresh=count(), beforeStock=stock();
        a.get("/payment-qr?orderId="+qr); a.get("/payment-qr?orderId="+qr);
        check(count()==beforeRefresh && stock()==beforeStock && "UNPAID".equals(order(qr).getPaymentStatus()),"06 refreshing QR creates no invoice and changes no state/stock");
        String csrf=hidden(page.body(),"csrf");
        check(a.post("/payment-qr",Map.of("orderId",""+qr,"action","transferred")).statusCode()==403,"08 customer mutation requires CSRF");
        check(a.get("/payment-qr?orderId="+qr+"&action=transferred").statusCode()==200 && "UNPAID".equals(order(qr).getPaymentStatus()),"08 GET cannot change payment status");
        b.get("/checkout"); // Existing empty-cart checkout intentionally has no form.
        String bpage=b.get("/product-detail?id="+productId).body(), bcsrf=hidden(bpage,"csrf");
        check(b.post("/payment-qr",Map.of("orderId",""+qr,"action","transferred","csrf",bcsrf)).statusCode()>=400,"09 HTTP foreign owner cannot declare transfer");
        check(a.post("/admin/orders",Map.of("orderId",""+qr,"action","confirmPayment","csrf",csrf)).statusCode()==403,"08 CUSTOMER direct admin POST forbidden");
        check(a.post("/payment-qr",Map.of("orderId",""+qr,"action","transferred","csrf",csrf,"paymentStatus","PAID")).statusCode()==302
                && "PENDING_VERIFY".equals(order(qr).getPaymentStatus()),"07/08 customer POST can only set PENDING_VERIFY despite forged PAID");
        a.post("/payment-qr",Map.of("orderId",""+qr,"action","transferred","csrf",csrf));
        check("PENDING_VERIFY".equals(order(qr).getPaymentStatus()) && stock()==beforeStock,"07 repeat declaration idempotent, stock unchanged");
        HttpResponse<String> adminPage=admin.get("/admin/orders");
        check(adminPage.statusCode()==200 && adminPage.body().contains("admin-payment-panel") && adminPage.body().contains("Xác nhận đã nhận tiền"),"13 admin orders JSP renders payment panel and confirmation dialog");
        String adminCsrf=hidden(adminPage.body(),"csrf");
        check(admin.get("/admin/orders?orderId="+qr+"&action=confirmPayment").statusCode()==200 && "PENDING_VERIFY".equals(order(qr).getPaymentStatus()),"10 GET admin cannot confirm payment");
        check(admin.post("/admin/orders",Map.of("orderId",""+qr,"action","confirmPayment","csrf",adminCsrf)).statusCode()==302
                && "PAID".equals(order(qr).getPaymentStatus()) && "PENDING".equals(order(qr).getOrderStatus()),"10 ADMIN POST marks PAID without completing order");
        check(admin.post("/admin/orders",Map.of("orderId",""+qr,"action","confirmPayment","csrf",adminCsrf)).statusCode()==302 && stock()==beforeStock,"11/14 repeated confirmation idempotent with no inventory change");
        check(a.get("/payment-qr?orderId="+qr).body().contains("Không chuyển khoản thêm"),"11 PAID page discourages repeat transfer");
        check(admin.post("/admin/orders",Map.of("orderId",""+cancelled,"action","confirmPayment","csrf",adminCsrf)).statusCode()==409,"12 HTTP cancelled invoice confirmation rejected");
        check(!a.get("/payment-qr?orderId="+cancelled).body().contains("img.vietqr.io/image/"),"12 cancelled QR image hidden");
        try (OrderDAO dao=new OrderDAO()) {
            rejects(()->dao.cancelPending(qr,customerA),"14 paid QR cancellation blocked by stored procedure");
        }
        a.post("/payment-qr",Map.of("orderId",""+qr,"action","transferred","csrf",csrf));
        check("PAID".equals(order(qr).getPaymentStatus()),"11 stale customer declaration cannot downgrade PAID");
        for (String status: new String[]{"CONFIRMED","COMPLETED"})
            check(admin.post("/admin/orders",Map.of("orderId",""+qr,"status",status,"csrf",adminCsrf)).statusCode()==302,"13 existing ADMIN transition " + status);

        a.post("/cart",Map.of("csrf",csrf,"action","add","productId",""+productId,"quantity","1"));
        String checkoutPage=a.get("/checkout").body();
        Map<String,String> fields=checkoutFields(checkoutPage,"FORGED");
        int beforeCheckout=count();
        check(a.post("/checkout",fields).statusCode()==400 && count()==beforeCheckout,"16 invalid paymentMethod creates no order");
        fields.put("paymentMethod","QR");
        check(a.post("/checkout",fields).statusCode()==400 && count()==beforeCheckout,"17 QR missing config rejected BEFORE creating invoice");
        fields.remove("paymentMethod");
        List<HttpResponse<String>> replay=Collections.synchronizedList(new ArrayList<>());
        ExecutorService executor=Executors.newFixedThreadPool(2);
        try {
            Future<?> first=executor.submit(()-> { try { replay.add(a.post("/checkout",fields)); } catch (Exception e) { throw new RuntimeException(e); } });
            Future<?> second=executor.submit(()-> { try { replay.add(a.post("/checkout",fields)); } catch (Exception e) { throw new RuntimeException(e); } });
            first.get(); second.get();
        } finally { executor.shutdown(); }
        check(count()==beforeCheckout+1 && replay.stream().filter(r->r.statusCode()==302).count()==1,"01/02/16 simultaneous checkout replay creates exactly ONE COD invoice; missing method defaults COD");
        check(a.post("/checkout",fields).statusCode()==400 && count()==beforeCheckout+1,"02 one-use token replay creates no second invoice");
        for (String path:new String[]{"/home","/products","/cart","/checkout","/orders","/login","/register","/profile","/product-detail?id="+productId})
            check(a.get(path).statusCode()==200,"18 mapping/JSP " + path);
        check(admin.get("/payment-qr?orderId="+qr).statusCode()==200,"09 ADMIN can read QR status page");

        // Exercise payment/cancel race on a fresh fixture order; either legal final state is accepted.
        int raceOrder; try (OrderDAO dao=new OrderDAO()) { raceOrder=checkout(dao,"QR"); }
        int raceStock=stock();
        ExecutorService race=Executors.newFixedThreadPool(2);
        CountDownLatch start=new CountDownLatch(1);
        try {
            Future<?> confirm=race.submit(()-> { try (OrderDAO dao=new OrderDAO()) { start.await(); dao.confirmPayment(raceOrder); } catch (Exception expected) { if (!(expected instanceof IllegalArgumentException)) throw new RuntimeException(expected); } });
            Future<?> cancel=race.submit(()-> { try (OrderDAO dao=new OrderDAO()) { start.await(); dao.cancelPending(raceOrder,customerA); } catch (Exception expected) { if (!(expected instanceof SQLException && ((SQLException) expected).getErrorCode()==51001)) throw new RuntimeException(expected); } });
            start.countDown(); confirm.get(); cancel.get();
        } finally { race.shutdown(); }
        Order raceResult=order(raceOrder);
        check(("PAID".equals(raceResult.getPaymentStatus()) && "PENDING".equals(raceResult.getOrderStatus()) && stock()==raceStock)
                || ("UNPAID".equals(raceResult.getPaymentStatus()) && "CANCELLED".equals(raceResult.getOrderStatus()) && stock()==raceStock+2),"12/14 concurrent confirm/cancel ends consistently with one stock outcome");
        System.out.println("CHECKS PASSED: " + checks);
    }
    public static void main(String[] args) throws Exception {
        QRPaymentIntegrationTest test=new QRPaymentIntegrationTest();
        if (args.length>0) test.base=args[0];
        try { test.setup(); test.runChecks(); }
        finally { test.cleanup(); }
    }
}
