package controller;

import controller.orders.OrderSupport;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import model.Account;
import model.Order;
import model.OrderDetail;
import util.VietnameseMoneyUtil;

/** Private, read-only internal purchase confirmation. No payment/order mutation or PDF service. */
@WebServlet(name = "InvoiceServlet", urlPatterns = {"/invoice"})
public class InvoiceServlet extends HttpServlet {
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        OrderSupport.prepare(request, response);
        response.setHeader("Cache-Control", "no-store, private");
        response.setHeader("X-Robots-Tag", "noindex, nofollow");
        response.setHeader("Referrer-Policy", "same-origin");
        Object value = request.getSession().getAttribute("user");
        boolean admin = value instanceof Account && "ADMIN".equals(((Account) value).getRole());
        Account account = OrderSupport.requireUser(request, response, admin);
        if (account == null) return;

        int id;
        try { id = OrderSupport.positiveInt(request.getParameter("orderId")); }
        catch (IllegalArgumentException e) { reject(request, response, 400, "Mã đơn hàng không hợp lệ.", admin); return; }
        try (OrderDAO dao = new OrderDAO()) {
            Order order = dao.getOrder(id, admin ? null : account.getCustomerId());
            if (order == null) { reject(request, response, 404, "Không tìm thấy hóa đơn của bạn.", admin); return; }
            if (!order.isInvoiceAvailable()) {
                reject(request, response, 409, "Hóa đơn chỉ có khi đơn đã hoàn tất. Đơn VietQR cần được xác nhận nhận tiền.", admin); return;
            }
            BigDecimal itemTotal = BigDecimal.ZERO;
            for (OrderDetail detail : order.getDetails())
                itemTotal = itemTotal.add(detail.getUnitPrice().multiply(BigDecimal.valueOf(detail.getQuantity())));
            if (order.getDetails().isEmpty() || itemTotal.signum() <= 0 || itemTotal.compareTo(order.getTotalAmount()) != 0)
                throw new SQLException("Invoice detail totals are inconsistent.");

            request.setAttribute("order", order);
            request.setAttribute("invoiceNumber", "TS-" + order.getOrderId());
            request.setAttribute("invoiceDate", DATE.format(order.getCompleteAt() != null ? order.getCompleteAt() : order.getDateCreated()));
            request.setAttribute("orderDate", DATE.format(order.getDateCreated()));
            request.setAttribute("amountInWords", VietnameseMoneyUtil.toWords(order.getTotalAmount()));
            request.setAttribute("seller", loadSeller());
            request.setAttribute("invoiceAdmin", admin);
            request.getRequestDispatcher("/WEB-INF/views/invoice.jsp").forward(request, response);
        } catch (SQLException | IllegalArgumentException e) {
            getServletContext().log("Unable to load sales invoice", e);
            reject(request, response, 503, "Chưa thể tải hóa đơn. Vui lòng thử lại sau.", admin);
        }
    }

    /** Reuse protected shop/VietQR properties; missing contact details are omitted, never fabricated. */
    private Map<String, String> loadSeller() {
        Properties properties = new Properties();
        try (InputStream stream = getServletContext().getResourceAsStream("/WEB-INF/vietqr.properties")) {
            if (stream != null) properties.load(new InputStreamReader(stream, StandardCharsets.UTF_8));
        } catch (IOException e) { getServletContext().log("Unable to load seller presentation settings", e); }
        Map<String, String> seller = new HashMap<>();
        seller.put("name", properties.getProperty("shop.name", "TechStore").trim());
        for (String field : new String[]{"address", "phone", "email", "taxCode"})
            seller.put(field, properties.getProperty("shop." + field, "").trim());
        String bank = properties.getProperty("vietqr.bankId", "").trim();
        seller.put("bankName", properties.getProperty("shop.bankName", "TCB".equals(bank) ? "Techcombank" : bank).trim());
        seller.put("bankAccount", properties.getProperty("shop.bankAccount", properties.getProperty("vietqr.accountNo", "")).trim());
        seller.put("bankOwner", properties.getProperty("shop.bankOwner", properties.getProperty("vietqr.accountName", "")).trim());
        return seller;
    }

    private void reject(HttpServletRequest request, HttpServletResponse response, int status, String message, boolean admin) throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("invoiceError", message);
        request.setAttribute("invoiceAdmin", admin);
        request.getRequestDispatcher("/WEB-INF/views/invoice.jsp").forward(request, response);
    }
}
