package controller.admin;

import dao.AccountDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Account;

/**
 * Servlet quản lý tài khoản dành cho Admin
 */
@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Account currentUser = (Account) session.getAttribute("user");

        // Kiểm tra quyền Admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Lấy tham số tìm kiếm và lọc vai trò từ form (Fix 7)
        String search = req.getParameter("search");
        String role = req.getParameter("role");

        // Sử dụng try-with-resources để tự đóng kết nối DB (Fix 1)
        try (AccountDAO accountDao = new AccountDAO()) {
            List<Account> listUsers = accountDao.searchAccounts(search, role);
            req.setAttribute("listUsers", listUsers);
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Account currentUser = (Account) session.getAttribute("user");

        // Kiểm tra quyền Admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        // Xử lý Khóa / Mở khóa tài khoản
        if ("toggleStatus".equals(action)) {
            try {
                int accountID = Integer.parseInt(req.getParameter("accountId"));
                boolean currentStatus = Boolean.parseBoolean(req.getParameter("currentStatus"));

                // Chặn Admin tự khóa tài khoản của chính mình (Fix 10)
                if (currentUser.getAccountId() == accountID) {
                    session.setAttribute("errorMessage", "Bạn không thể tự khóa tài khoản của chính mình!");
                    resp.sendRedirect(req.getContextPath() + "/admin/users");
                    return;
                }

                // Sử dụng try-with-resources để tự đóng kết nối DB (Fix 1)
                try (AccountDAO accountDao = new AccountDAO()) {
                    boolean success = accountDao.updateAccountStatus(accountID, !currentStatus);
                    if (success) {
                        session.setAttribute("successMessage", "Cập nhật trạng thái tài khoản thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Cập nhật trạng thái thất bại!");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}