import dal.DBContext;
import dao.OrderDAO;
import dao.ReviewDAO;
import model.CartItem;
import model.ProductReview;
import util.PasswordUtil;
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

/** LOCAL SQL Server/Tomcat integration test. Only its own fixtures are removed in finally.
 * No real transfer, external QR-image request, production records or schema changes.
 */
public class ReviewIntegrationTest extends DBContext {
    private final String prefix = "reviewtest" + System.currentTimeMillis();
    private final String password = UUID.randomUUID() + "Aa1!";
    private final Map<String,Integer> customers = new LinkedHashMap<>(), accounts = new LinkedHashMap<>();
    private final List<Integer> products = new ArrayList<>();
    private String base = "http://localhost:8081/TechStore";
    private int product, raceProduct, emptyProduct, qrProduct, assertions;

    void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
        assertions++; System.out.println("PASS " + message);
    }
    static void bind(PreparedStatement s, Object... values) throws SQLException {
        for (int i=0; i<values.length; i++) s.setObject(i+1,values[i]);
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
    String string(String sql, Object... values) throws SQLException {
        try (PreparedStatement s=connection.prepareStatement(sql)) {
            bind(s,values); try (ResultSet r=s.executeQuery()) { if (!r.next()) return null; return r.getString(1); }
        }
    }
    int createProduct(String suffix) throws SQLException {
        int id=insert("INSERT dbo.Product(ProductName,BrandID,CategoryID,Price,StockQuantity) "
                + "SELECT ?, (SELECT MIN(BrandID) FROM dbo.Brand),(SELECT MIN(CategoryID) FROM dbo.Category),1590000,100",prefix+suffix);
        products.add(id); return id;
    }
    void completePurchase(String role, int productId) throws SQLException {
        try (OrderDAO dao=new OrderDAO()) {
            Map<Integer,CartItem> cart=new LinkedHashMap<>(); cart.put(productId,new CartItem(dao.findCartProduct(productId),1));
            int id=dao.checkout(customers.get(role),cart,"Review Fixture","0900000000","LOCAL TEST ONLY");
            dao.updateStatus(id,"CONFIRMED"); dao.updateStatus(id,"COMPLETED");
        }
    }
    void setup() throws Exception {
        if (connection==null) throw new SQLException("Local database unavailable.");
        String hash=PasswordUtil.hashPassword(password);
        for (String role:new String[]{"A","B","C","P","Q","ADMIN"}) {
            Integer customer=null;
            if (!role.equals("ADMIN")) {
                String name=role.equals("A") ? "Nguyễn Review A" : role.equals("B") ? "<b>Review B</b>" : "Review "+role;
                customer=insert("INSERT dbo.Customer(FullName) VALUES (?)",name); customers.put(role,customer);
            }
            int account=insert("INSERT dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role) VALUES (?,?,?,?,?)",
                    customer,prefix+role,prefix+role+"@example.invalid",hash,role.equals("ADMIN")?"ADMIN":"CUSTOMER");
            accounts.put(role,account);
        }
        product=createProduct("Main"); raceProduct=createProduct("Race"); emptyProduct=createProduct("Empty"); qrProduct=createProduct("QR");
        completePurchase("A",product); completePurchase("B",product); completePurchase("A",raceProduct);
        completePurchase("A",emptyProduct); // Eligible zero-review product for optional real-browser UI checks.
    }
    void cleanup() throws SQLException {
        connection.setAutoCommit(false);
        try {
            for (int account:accounts.values()) execute("DELETE dbo.ProductReview WHERE AccountID=?",account);
            for (int customer:customers.values()) {
                execute("DELETE d FROM dbo.InvoiceDetail d JOIN dbo.Invoice i ON i.InvoiceID=d.InvoiceID WHERE i.CustomerID=?",customer);
                execute("DELETE dbo.Invoice WHERE CustomerID=?",customer);
            }
            for (int account:accounts.values()) execute("DELETE dbo.UserAccount WHERE AccountID=?",account);
            for (int customer:customers.values()) execute("DELETE dbo.Customer WHERE CustomerID=?",customer);
            for (int id:products) execute("DELETE dbo.Product WHERE ProductID=?",id);
            connection.commit();
            System.out.println("CLEANUP PASS: only temporary review fixtures removed; existing data preserved, no identity reseed.");
        } catch (SQLException e) { connection.rollback(); throw e; }
        finally { connection.close(); }
    }
    class Browser {
        final HttpClient client=HttpClient.newBuilder().cookieHandler(new CookieManager()).followRedirects(HttpClient.Redirect.NEVER).build();
        HttpResponse<String> get(String path) throws Exception {
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).GET().build(),HttpResponse.BodyHandlers.ofString());
        }
        HttpResponse<String> post(String path, Map<String,String> fields) throws Exception {
            StringJoiner body=new StringJoiner("&");
            fields.forEach((k,v)->body.add(URLEncoder.encode(k,StandardCharsets.UTF_8)+"="+URLEncoder.encode(v,StandardCharsets.UTF_8)));
            return client.send(HttpRequest.newBuilder(URI.create(base+path)).header("Content-Type","application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString())).build(),HttpResponse.BodyHandlers.ofString());
        }
        void login(String role) throws Exception {
            check(post("/login",Map.of("username",prefix+role,"password",password)).statusCode()==302,"fixture login "+role);
        }
        String detail(int id) throws Exception {
            HttpResponse<String> page=get("/product-detail?id="+id);
            check(page.statusCode()==200,"product detail HTTP 200"); return page.body();
        }
        HttpResponse<String> review(int id, String rating, String comment) throws Exception {
            return post("/review",Map.of("csrf",hidden(detail(id),"csrf"),"productId",""+id,"rating",rating,"comment",comment));
        }
        int checkout(int id, String method) throws Exception {
            String csrf=hidden(detail(id),"csrf");
            check(post("/cart",Map.of("csrf",csrf,"action","add","productId",""+id,"quantity","1")).statusCode()==302,"20 add-to-cart POST unchanged");
            String checkout=get("/checkout").body();
            Map<String,String> fields=new HashMap<>(Map.of("csrf",hidden(checkout,"csrf"),"checkoutToken",hidden(checkout,"checkoutToken"),
                    "shippingName","Review Fixture","shippingPhone","0900000000","shippingAddress","LOCAL TEST ONLY","paymentMethod",method));
            HttpResponse<String> result=post("/checkout",fields);
            check(result.statusCode()==302,"checkout "+method+" PRG");
            if (method.equals("QR")) {
                String location=result.headers().firstValue("Location").orElseThrow();
                check(location.contains("/payment-qr?orderId="),"22 QR checkout redirects to actual invoice");
                return Integer.parseInt(location.substring(location.lastIndexOf('=')+1));
            }
            return number("SELECT MAX(InvoiceID) FROM dbo.Invoice WHERE CustomerID=?",customers.get("P"));
        }
    }
    static String hidden(String page,String name) {
        Matcher match=Pattern.compile("name=\""+name+"\"[^>]*value=\"([^\"]*)\"").matcher(page);
        if (!match.find()) throw new AssertionError("Missing hidden field "+name);
        return match.group(1);
    }
    ProductReview own(String role,int id) throws SQLException {
        try (ReviewDAO dao=new ReviewDAO()) { return dao.getReviewByUserAndProduct(accounts.get(role),id); }
    }
    int reviewCount(int id) throws SQLException { try (ReviewDAO dao=new ReviewDAO()) { return (int)dao.countReviews(id); } }
    void tests() throws Exception {
        Browser guest=new Browser(), a=new Browser(), b=new Browser(), c=new Browser(), p=new Browser(), q=new Browser(), admin=new Browser();
        String empty=guest.detail(emptyProduct);
        check(empty.contains("Chưa có đánh giá nào") && !empty.contains("class=\"ts-review-overview\""),"02 empty product has designed empty state without fabricated statistics");
        check(guest.post("/review",Map.of("productId",""+product,"rating","5","comment","Guest attempt")).statusCode()==302 && reviewCount(product)==0,"03 guest POST cannot insert review");
        check(guest.get("/review").statusCode()==405,"review GET cannot mutate");
        a.login("A"); b.login("B"); c.login("C"); p.login("P"); q.login("Q"); admin.login("ADMIN");
        String historyBefore=a.get("/orders").body();
        check(historyBefore.contains("class=\"history-review-invite\"") && historyBefore.contains("Gửi đánh giá"),"completed order history has a prominent review entry point");
        check(historyBefore.contains("/product-detail?id="+product+"#review-form") && historyBefore.contains("/product-detail?id="+raceProduct+"#review-form"),"history review links target each purchased product's form");
        check(a.detail(product).contains("id=\"review-form\"") && a.detail(product).contains("Lịch sử mua hàng"),"history destination has anchored feedback form and return link");
        check(!c.get("/orders").body().contains("class=\"history-review-invite\""),"no review invitation without completed orders");
        check(!c.detail(product).contains("id=\"ts-review-comment-input\""),"04 non-buyer has no review form");
        check(c.review(product,"5","Not purchased").statusCode()==302 && own("C",product)==null,"04 non-buyer forged POST rejected by DAO");
        String permissionError=c.detail(product);
        check(permissionError.contains("Bạn cần mua và hoàn tất đơn hàng"),"04 permission error shown after PRG");

        int pending=p.checkout(product,"COD");
        check("COD".equals(string("SELECT PaymentMethod FROM dbo.Invoice WHERE InvoiceID=?",pending)),"21 COD checkout persists COD");
        check(!p.get("/orders").body().contains("class=\"history-review-invite\""),"pending order history does not invite product review");
        check(p.review(product,"5","Pending order").statusCode()==302 && own("P",product)==null,"05 PENDING purchase cannot review");
        try (OrderDAO dao=new OrderDAO()) { dao.updateStatus(pending,"CONFIRMED"); }
        p.review(product,"5","Confirmed only"); check(own("P",product)==null,"05 CONFIRMED purchase cannot review");

        check(a.review(product,"1","Trải nghiệm một sao").statusCode()==302,"06/07 completed buyer submits 1 star with PRG");
        ProductReview first=own("A",product);
        check(first!=null && first.getRating()==1 && first.getComment().equals("Trải nghiệm một sao"),"11 review persisted with Unicode text");
        check(first.getAccountId()==accounts.get("A") && first.getProductId()==product,"11 correct AccountID/product ownership stored");
        String oneReview=guest.detail(product);
        check(oneReview.contains("data-review-level=\"1\" data-review-count=\"1\"") && oneReview.contains("1 lượt đánh giá"),"single-review overview derives distribution from the loaded review");
        String historyAfter=a.get("/orders").body();
        check(Pattern.compile("product-detail\\?id="+product+"#review-form\">Sửa đánh giá").matcher(historyAfter).find(),"reviewed product history button becomes Edit Review for the owner");
        check(Pattern.compile("product-detail\\?id="+raceProduct+"#review-form\">Gửi đánh giá").matcher(historyAfter).find(),"other unreviewed purchased product retains Send Review button");
        check(b.review(product,"5","Sản phẩm rất tốt").statusCode()==302 && own("B",product).getRating()==5,"08 completed second buyer submits 5 stars");
        try (ReviewDAO dao=new ReviewDAO()) {
            check(dao.getAverageRating(product).compareTo(new BigDecimal("3"))==0,"14 average of 1 and 5 is exactly 3");
            check(dao.countReviews(product)==2,"15 total reviews is 2");
            List<ProductReview> list=dao.getReviewsByProduct(product);
            check(list.get(0).getAccountId()==accounts.get("B"),"newest first by CreatedAt and ReviewID");
            check(list.get(1).getReviewerName().equals("Nguyễn Review A"),"13 actual customer name joined");
        }
        String publicPage=guest.detail(product);
        check(publicPage.contains("Sản phẩm rất tốt") && publicPage.contains("Trải nghiệm một sao"),"01 guest reads DB comments");
        check(publicPage.contains("3,0") && publicPage.contains("2 lượt đánh giá"),"02 guest sees true average and count");
        check(publicPage.contains("data-review-level=\"5\" data-review-count=\"1\"") && publicPage.contains("data-review-level=\"1\" data-review-count=\"1\"") && publicPage.contains("data-review-level=\"3\" data-review-count=\"0\""),"real 1-star and 5-star distribution with zero middle ratings");
        check(publicPage.contains("ts-review-avatar") && !publicPage.contains("data-review-form"),"public review avatars render without exposing a guest submit form");
        check(publicPage.contains("Nguyễn Review A") && publicPage.contains("&lt;b&gt;Review B&lt;/b&gt;"),"13 names escaped including HTML-like customer name");
        check(c.detail(product).contains("Sản phẩm rất tốt"),"12 another customer sees reviews");
        int firstId=first.getReviewId();
        check(a.review(product,"5","Đã cập nhật đánh giá").statusCode()==302,"16 owner updates old review");
        check(own("A",product).getReviewId()==firstId && own("A",product).getRating()==5 && reviewCount(product)==2,"16 update keeps same ReviewID and row count");
        String formPage=a.detail(product);
        check(formPage.contains("Cập nhật đánh giá") && formPage.contains("Đã cập nhật đánh giá") && formPage.contains("value=\"5\" checked"),"16 own form prefills saved rating/comment");
        for (String rating:new String[]{"0","6","1.5","abc",""}) {
            a.review(product,rating,"Invalid rating");
            check(own("A",product).getRating()==5 && own("A",product).getComment().equals("Đã cập nhật đánh giá"),"09 invalid rating rejected: "+rating);
        }
        a.review(product,"2"," \n\t ");
        check(own("A",product).getRating()==5,"10 blank comment rejected");
        a.review(product,"2","x".repeat(501));
        check(own("A",product).getRating()==5,"comment length 501 rejected");
        a.review(product,"2","x".repeat(500));
        check(own("A",product).getComment().length()==500,"comment length 500 accepted");

        Map<String,String> attack=new HashMap<>(Map.of("csrf",hidden(c.detail(product),"csrf"),"productId",""+product,"rating","1","comment","Steal review",
                "accountId",""+accounts.get("A"),"customerId",""+customers.get("A"),"reviewId",""+firstId));
        c.post("/review",attack);
        check(own("A",product).getComment().length()==500 && own("C",product)==null,"18 forged account/customer/review IDs cannot edit another review");
        attack.put("csrf",hidden(b.detail(product),"csrf")); attack.put("comment","Only B can change B");
        b.post("/review",attack);
        check(own("B",product).getComment().equals("Only B can change B") && own("A",product).getComment().length()==500,"18 eligible B's forged ReviewID only changes B's own pair");
        check(admin.post("/review",Map.of("csrf",hidden(admin.detail(product),"csrf"),"productId",""+product,"rating","5","comment","Admin edit")).statusCode()==403,"ADMIN cannot submit/edit customer reviews");
        check(a.post("/review",Map.of("productId",""+product,"rating","1","comment","Missing CSRF")).statusCode()==403,"CSRF missing rejected");
        check(a.post("/review",Map.of("csrf",hidden(a.detail(product),"csrf"),"productId","bad","rating","5","comment","Bad product")).statusCode()==400,"invalid product ID rejected");
        check(a.post("/review",Map.of("csrf",hidden(a.detail(product),"csrf"),"productId",""+Integer.MAX_VALUE,"rating","5","comment","Missing product")).statusCode()==404,"missing product ID rejected");

        String xss="</textarea><script>window.reviewXss=1</script><img src=x onerror=alert(1)>";
        a.review(product,"4",xss);
        String escaped=guest.detail(product), escapedOwner=a.detail(product);
        check(own("A",product).getComment().equals(xss),"19 DB stores plain original comment text");
        check(escaped.contains("&lt;script&gt;window.reviewXss=1&lt;/script&gt;") && !escaped.contains("<script>window.reviewXss=1"),"19 guest HTML escapes stored script");
        check(!escapedOwner.contains("</textarea><script>window.reviewXss") && escapedOwner.contains("&lt;/textarea&gt;"),"19 edit textarea cannot be broken out of");
        check(!escaped.contains(prefix+"A@example.invalid") && !escaped.contains("PasswordHash"),"review output does not expose private account fields");

        String raceCsrf=hidden(a.detail(raceProduct),"csrf");
        ExecutorService executor=Executors.newFixedThreadPool(2);
        try {
            Future<HttpResponse<String>> one=executor.submit(()->a.post("/review",Map.of("csrf",raceCsrf,"productId",""+raceProduct,"rating","1","comment","Concurrent one")));
            Future<HttpResponse<String>> two=executor.submit(()->a.post("/review",Map.of("csrf",raceCsrf,"productId",""+raceProduct,"rating","5","comment","Concurrent two")));
            check(one.get().statusCode()==302 && two.get().statusCode()==302,"17 simultaneous POSTs both complete via PRG");
        } finally { executor.shutdown(); }
        check(reviewCount(raceProduct)==1,"17 unique account/product review after simultaneous inserts");
        int afterRaceId=own("A",raceProduct).getReviewId();
        a.review(raceProduct,"3","Repeat review"); a.detail(raceProduct); a.detail(raceProduct);
        check(reviewCount(raceProduct)==1 && own("A",raceProduct).getReviewId()==afterRaceId,"17 repeated submit and refresh do not create duplicates");

        int qr=q.checkout(qrProduct,"QR");
        check("QR".equals(string("SELECT PaymentMethod FROM dbo.Invoice WHERE InvoiceID=?",qr)),"22 live QR checkout persists method");
        String qrPage=q.get("/payment-qr?orderId="+qr).body();
        check(qrPage.contains("img.vietqr.io/image/TCB-") && qrPage.contains("TECHSTORE"+qr),"22 QR page retains configured bank and actual invoice reference");
        q.post("/payment-qr",Map.of("csrf",hidden(qrPage,"csrf"),"orderId",""+qr,"action","transferred"));
        check("PENDING_VERIFY".equals(string("SELECT PaymentStatus FROM dbo.Invoice WHERE InvoiceID=?",qr)),"22 customer transfer declaration unchanged");
        String adminCsrf=hidden(admin.get("/admin/orders").body(),"csrf");
        check(admin.post("/admin/orders",Map.of("csrf",adminCsrf,"orderId",""+qr,"action","confirmPayment")).statusCode()==302,"22 admin payment confirmation unchanged for fixture only");
        check("PAID".equals(string("SELECT PaymentStatus FROM dbo.Invoice WHERE InvoiceID=?",qr)),"22 fixture QR is PAID after admin confirmation");
        q.review(qrProduct,"5","Paid but not completed");
        check(own("Q",qrProduct)==null,"05 QR PAID without COMPLETED cannot review");
        for (String state:new String[]{"CONFIRMED","COMPLETED"})
            check(admin.post("/admin/orders",Map.of("csrf",adminCsrf,"orderId",""+qr,"status",state)).statusCode()==302,"22 existing admin order transition "+state);
        q.review(qrProduct,"5","Completed QR purchase");
        check(own("Q",qrProduct)!=null,"06 COMPLETED QR buyer can review");

        for (String path:new String[]{"/home","/products?q=reviewtest","/search?q=reviewtest","/cart","/checkout","/orders","/login","/register","/profile"})
            check(a.get(path).statusCode()==200,"20 existing mapping "+path);
        check(guest.detail(product).contains("/cart") && guest.detail(product).contains("ts-detail-price"),"20 original product/cart markup retained");
        System.out.println("ALL REVIEW INTEGRATION CHECKS PASSED: "+assertions);
    }
    public static void main(String[] args) throws Exception {
        ReviewIntegrationTest test=new ReviewIntegrationTest();
        if (args.length>0) test.base=args[0];
        try {
            test.setup(); test.tests();
            if (args.length > 1 && "--ui".equals(args[1])) {
                ProcessBuilder browserCheck = new ProcessBuilder("node", "tests/ReviewUiCheck.js");
                browserCheck.environment().put("REVIEW_TEST_BASE", test.base);
                browserCheck.environment().put("REVIEW_TEST_PREFIX", test.prefix);
                browserCheck.environment().put("REVIEW_TEST_PASSWORD", test.password);
                browserCheck.environment().put("REVIEW_TEST_PRODUCT", String.valueOf(test.product));
                browserCheck.environment().put("REVIEW_TEST_EMPTY_PRODUCT", String.valueOf(test.emptyProduct));
                int code = browserCheck.inheritIO().start().waitFor();
                test.check(code == 0, "real-browser premium review UI checks");
            }
        } finally { test.cleanup(); }
    }
}
