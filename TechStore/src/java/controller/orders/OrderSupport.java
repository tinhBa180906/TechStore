package controller.orders;

import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;
import model.*;

/** Integration helpers private to the cart/order module. */
public final class OrderSupport {
    private OrderSupport() { }

    @SuppressWarnings("unchecked")
    public static Map<Integer, CartItem> cart(HttpSession session) {
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new LinkedHashMap<>(); session.setAttribute("cart", cart);
        }
        return cart;
    }

    public static void prepare(HttpServletRequest req, HttpServletResponse resp) {
        resp.setContentType("text/html;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        HttpSession session = req.getSession();
        synchronized (session) {
            if (session.getAttribute("orderCsrf") == null)
                session.setAttribute("orderCsrf", UUID.randomUUID().toString());
        }
    }

    public static boolean csrf(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Object expected = req.getSession().getAttribute("orderCsrf");
        if (expected != null && expected.equals(req.getParameter("csrf"))) return true;
        resp.sendError(403, "Biểu mẫu hết hạn. Vui lòng tải lại trang."); return false;
    }

    public static Account requireUser(HttpServletRequest req, HttpServletResponse resp, boolean admin) throws IOException {
        Object value = req.getSession().getAttribute("user");
        Account user = value instanceof Account ? (Account) value : null;
        if (user == null || !user.isIsActive()) {
            resp.sendError(401, "Vui lòng đăng nhập bằng tài khoản đang hoạt động."); return null;
        }
        if (admin ? !"ADMIN".equals(user.getRole()) :
                (!"CUSTOMER".equals(user.getRole()) || user.getCustomerId() == null || user.getCustomerId() < 1)) {
            resp.sendError(403, "Bạn không có quyền truy cập chức năng này."); return null;
        }
        return user;
    }

    public static int positiveInt(String value) {
        try {
            int number = Integer.parseInt(value);
            if (number > 0) return number;
        } catch (NumberFormatException ignored) { }
        throw new IllegalArgumentException("ID và số lượng phải là số nguyên dương hợp lệ.");
    }

    public static void cartView(HttpServletRequest req) {
        synchronized (req.getSession()) {
            List<CartItem> items = new ArrayList<>();
            BigDecimal total = BigDecimal.ZERO;
            for (CartItem item : cart(req.getSession()).values()) {
                items.add(new CartItem(item.getProduct(), item.getQuantity()));
                total = total.add(item.getSubtotal());
            }
            req.setAttribute("cartItems", items); req.setAttribute("cartTotal", total);
        }
    }
}
