package controller;

import controller.orders.OrderSupport;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import model.CartItem;
import model.Product;
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException, IOException {
        OrderSupport.prepare(req, resp);
        OrderSupport.cartView(req);
        try (OrderDAO dao = new OrderDAO()) {
            req.setAttribute("products", dao.getCartProducts());
        } catch (SQLException e) {
            getServletContext().log("Cannot load cart products", e);
            req.setAttribute("errorMessage", "Chưa thể tải sản phẩm. Vui lòng thử lại.");
        }
        req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        OrderSupport.prepare(req, resp);
        if (!OrderSupport.csrf(req, resp)) return;
        synchronized (req.getSession()) {
            try {
                String action = req.getParameter("action");
                int id = OrderSupport.positiveInt(req.getParameter("productId"));
                Map<Integer, CartItem> cart = OrderSupport.cart(req.getSession());
                if ("remove".equals(action)) cart.remove(id);
                else if ("add".equals(action) || "update".equals(action)) {
                    int quantity = OrderSupport.positiveInt(req.getParameter("quantity"));
                    if ("add".equals(action) && cart.containsKey(id))
                        quantity = Math.addExact(quantity, cart.get(id).getQuantity());
                    if ("update".equals(action) && !cart.containsKey(id))
                        throw new IllegalArgumentException("Sản phẩm chưa có trong giỏ hàng.");
                    try (OrderDAO dao = new OrderDAO()) {
                        Product product = dao.findCartProduct(id);
                        if (product == null || !product.isIsActive() || quantity > product.getStockQuantity())
                            throw new IllegalArgumentException("Sản phẩm đã ngừng bán hoặc không đủ tồn kho.");
                        cart.put(id, new CartItem(product, quantity));
                    }
                } else throw new IllegalArgumentException("Thao tác giỏ hàng không hợp lệ.");
            } catch (IllegalArgumentException | ArithmeticException e) {
                resp.setStatus(400); req.setAttribute("errorMessage", "Số lượng hoặc sản phẩm không hợp lệ. " + e.getMessage());
                doGet(req, resp); return;
            } catch (SQLException e) {
                getServletContext().log("Cart update failed", e);
                resp.setStatus(503); req.setAttribute("errorMessage", "Chưa thể cập nhật giỏ hàng. Vui lòng thử lại.");
                doGet(req, resp); return;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}
