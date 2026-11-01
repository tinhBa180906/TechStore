/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import controller.orders.OrderSupport;
import dao.OrderDAO;
import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import model.*;

/**
 *
 * @author Tinh Ba
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/checkout", "/payment-qr"})
public class OrderServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        OrderSupport.prepare(req, resp);
        boolean paymentPage = "/payment-qr".equals(req.getServletPath());
        Object sessionUser = req.getSession().getAttribute("user");
        boolean admin = paymentPage && sessionUser instanceof Account && "ADMIN".equals(((Account) sessionUser).getRole());
        Account user = OrderSupport.requireUser(req, resp, admin);
        if (user == null) return;
        if (paymentPage) {
            try (OrderDAO dao = new OrderDAO()) {
                Order order = dao.getOrder(OrderSupport.positiveInt(req.getParameter("orderId")), admin ? null : user.getCustomerId());
                if (order == null || !"QR".equals(order.getPaymentMethod())) {
                    resp.sendError(404); return;
                }
                req.setAttribute("order", order);
                req.setAttribute("transferContent", util.VietQRUtil.transferContent(order.getOrderId()));
                if (!"CANCELLED".equals(order.getOrderStatus()) && !"PAID".equals(order.getPaymentStatus())) {
                    try {
                        util.VietQRUtil config = util.VietQRUtil.load(getServletContext());
                        req.setAttribute("qrUrl", config.imageUrl(order.getOrderId(), order.getTotalAmount()));
                        req.setAttribute("vietqr", config);
                    } catch (IllegalArgumentException e) { req.setAttribute("qrError", e.getMessage()); }
                }
                req.getRequestDispatcher("/WEB-INF/views/payment-qr.jsp").forward(req, resp);
            } catch (IllegalArgumentException e) { resp.sendError(400); }
            catch (SQLException e) {
                getServletContext().log("QR order load failed", e);
                resp.sendError(503, "Chưa thể tải thông tin thanh toán. Vui lòng thử lại sau.");
            }
            return;
        }
        if ("/checkout".equals(req.getServletPath())) {
            synchronized (req.getSession()) {
                if (req.getSession().getAttribute("checkoutToken") == null)
                    req.getSession().setAttribute("checkoutToken", java.util.UUID.randomUUID().toString());
            }
            OrderSupport.cartView(req);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
        } else {
            java.util.List<Order> orders = java.util.List.of();
            try (OrderDAO dao = new OrderDAO()) {
                orders = dao.getOrders(user.getCustomerId());
                req.setAttribute("orders", orders);
            } catch (SQLException e) {
                getServletContext().log("Order history failed", e);
                resp.setStatus(503); req.setAttribute("errorMessage", "Chưa thể tải lịch sử đơn hàng.");
            }
            if (orders.stream().anyMatch(order -> "COMPLETED".equals(order.getOrderStatus()))) {
                try (ReviewDAO dao = new ReviewDAO()) {
                    req.setAttribute("reviewedProducts", dao.getReviewedProducts(user.getAccountId()));
                } catch (SQLException e) {
                    getServletContext().log("Unable to load review indicators for order history", e);
                    // Review links still work; the detail page rechecks ownership and loads the existing review.
                }
            }
            req.getRequestDispatcher("/WEB-INF/views/order-history.jsp").forward(req, resp);
        }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); OrderSupport.prepare(req, resp);
        Account user = OrderSupport.requireUser(req, resp, false);
        if (user == null || !OrderSupport.csrf(req, resp)) return;
        try {
            if ("/payment-qr".equals(req.getServletPath())) {
                if (!"transferred".equals(req.getParameter("action")))
                    throw new IllegalArgumentException("Thao tác thanh toán không hợp lệ.");
                int id = OrderSupport.positiveInt(req.getParameter("orderId"));
                try (OrderDAO dao = new OrderDAO()) {
                    dao.requestPaymentVerification(id, user.getCustomerId());
                }
                resp.sendRedirect(req.getContextPath() + "/payment-qr?orderId=" + id);
                return;
            } else if ("/checkout".equals(req.getServletPath())) {
                String paymentMethod = req.getParameter("paymentMethod");
                if (paymentMethod == null || paymentMethod.isEmpty()) paymentMethod = "COD";
                if (!"COD".equals(paymentMethod) && !"QR".equals(paymentMethod))
                    throw new IllegalArgumentException("Phương thức thanh toán không hợp lệ.");
                if ("QR".equals(paymentMethod)) util.VietQRUtil.load(getServletContext());
                // Serialize changes within this session; duplicate submits see an empty cart.
                synchronized (req.getSession()) {
                    Object checkoutToken = req.getSession().getAttribute("checkoutToken");
                    if (checkoutToken == null || !checkoutToken.equals(req.getParameter("checkoutToken")))
                        throw new IllegalArgumentException("Yêu cầu đặt hàng đã hết hạn hoặc đã được xử lý. Vui lòng kiểm tra đơn hàng.");
                    Map<Integer, CartItem> cart = OrderSupport.cart(req.getSession());
                    try (OrderDAO dao = new OrderDAO()) {
                        int orderId = dao.checkout(user.getCustomerId(), cart, req.getParameter("shippingName"),
                                req.getParameter("shippingPhone"), req.getParameter("shippingAddress"), paymentMethod);
                        cart.clear();
                        req.getSession().removeAttribute("checkoutToken");
                        resp.sendRedirect(req.getContextPath() + ("QR".equals(paymentMethod)
                                ? "/payment-qr?orderId=" + orderId : "/orders"));
                        return;
                    }
                }
            } else if ("cancel".equals(req.getParameter("action"))) {
                try (OrderDAO dao = new OrderDAO()) {
                    dao.cancelPending(OrderSupport.positiveInt(req.getParameter("orderId")), user.getCustomerId());
                }
            } else throw new IllegalArgumentException("Thao tác không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/orders");
        } catch (IllegalArgumentException e) {
            resp.setStatus(400); req.setAttribute("errorMessage", e.getMessage()); doGet(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Order write failed", e);
            resp.setStatus(e.getErrorCode() == 51001 ? 409 : 503);
            req.setAttribute("errorMessage", e.getErrorCode() == 51001
                    ? "Chỉ hủy được đơn PENDING của bạn; đơn có thể đã thay đổi."
                    : "Chưa thể xử lý đơn hàng. Vui lòng kiểm tra lịch sử trước khi thử lại.");
            doGet(req, resp);
        }
    }
}
