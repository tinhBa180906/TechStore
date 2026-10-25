/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import controller.orders.OrderSupport;
import dao.OrderDAO;
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
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/checkout"})
public class OrderServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        OrderSupport.prepare(req, resp);
        Account user = OrderSupport.requireUser(req, resp, false);
        if (user == null) return;
        if ("/checkout".equals(req.getServletPath())) {
            OrderSupport.cartView(req);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
        } else {
            try (OrderDAO dao = new OrderDAO()) {
                req.setAttribute("orders", dao.getOrders(user.getCustomerId()));
            } catch (SQLException e) {
                getServletContext().log("Order history failed", e);
                resp.setStatus(503); req.setAttribute("errorMessage", "Chưa thể tải lịch sử đơn hàng.");
            }
            req.getRequestDispatcher("/WEB-INF/views/order-history.jsp").forward(req, resp);
        }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); OrderSupport.prepare(req, resp);
        Account user = OrderSupport.requireUser(req, resp, false);
        if (user == null || !OrderSupport.csrf(req, resp)) return;
        try {
            if ("/checkout".equals(req.getServletPath())) {
                // Serialize changes within this session; duplicate submits see an empty cart.
                synchronized (req.getSession()) {
                    Map<Integer, CartItem> cart = OrderSupport.cart(req.getSession());
                    try (OrderDAO dao = new OrderDAO()) {
                        dao.checkout(user.getCustomerId(), cart, req.getParameter("shippingName"),
                                req.getParameter("shippingPhone"), req.getParameter("shippingAddress"));
                        cart.clear();
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
