/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import controller.orders.OrderSupport;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 *
 * @author Tinh Ba
 */
@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders"})
public class AdminOrderServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        OrderSupport.prepare(req, resp);
        if (OrderSupport.requireUser(req, resp, true) == null) return;
        try (OrderDAO dao = new OrderDAO()) {
            req.setAttribute("orders", dao.getOrders(null));
        } catch (SQLException e) {
            getServletContext().log("Admin orders failed", e);
            resp.setStatus(503); req.setAttribute("errorMessage", "Chưa thể tải danh sách đơn hàng.");
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/orders.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); OrderSupport.prepare(req, resp);
        if (OrderSupport.requireUser(req, resp, true) == null || !OrderSupport.csrf(req, resp)) return;
        try (OrderDAO dao = new OrderDAO()) {
            dao.updateStatus(OrderSupport.positiveInt(req.getParameter("orderId")), req.getParameter("status"));
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        } catch (IllegalArgumentException e) {
            resp.setStatus(409); req.setAttribute("errorMessage", e.getMessage()); doGet(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Admin status update failed", e);
            resp.setStatus(e.getErrorCode() == 51001 ? 409 : 503);
            req.setAttribute("errorMessage", "Không thể cập nhật. Hãy kiểm tra lại trạng thái đơn hàng."); doGet(req, resp);
        }
    }
}
