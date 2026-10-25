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
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        OrderSupport.prepare(req, resp);
        if (OrderSupport.requireUser(req, resp, true) == null) return;
        try (OrderDAO dao = new OrderDAO()) {
            req.setAttribute("stats", dao.getStatistics());
        } catch (SQLException e) {
            getServletContext().log("Dashboard failed", e);
            resp.setStatus(503); req.setAttribute("errorMessage", "Chưa thể tải thống kê.");
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
