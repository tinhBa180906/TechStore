/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.AccountDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Account;
import util.PasswordUtil;

/**
 *
 * @author Tinh Ba
 *
 */
@WebServlet(name = "AuthServlet", urlPatterns = {
    "/auth", "/login", "/login.jsp", "/register", "/register.jsp", "/profile", "/profile.jsp", "/update-profile", "/logout"
})
public class AuthServlet extends HttpServlet {

    private static final String LOGIN_VIEW = "/WEB-INF/views/login.jsp";
    private static final String REGISTER_VIEW = "/WEB-INF/views/register.jsp";
    private static final String PROFILE_VIEW = "/WEB-INF/views/profile.jsp";

//    private final AccountDAO accountDao = new AccountDAO();
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //cau hinh utf-8 de doc duoc tieng viet tu ten, ho ten
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String servletPath = req.getServletPath();
        String action = req.getParameter("action");

        if ("/update-profile".equalsIgnoreCase(servletPath) || "update-profile".equalsIgnoreCase(action)) {
            handleUpdateProfile(req, resp);
        } else if ("login".equalsIgnoreCase(action) || "/login".equalsIgnoreCase(servletPath)) {
            handleLogin(req, resp);
        } else if ("register".equalsIgnoreCase(action) || "/register".equalsIgnoreCase(servletPath)) {
            handleRegister(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String servletPath = req.getServletPath();
        String action = req.getParameter("action");

        if ("logout".equalsIgnoreCase(action) || "/logout".equalsIgnoreCase(servletPath)) {
            HttpSession session = req.getSession(false); // khong tao session moi neu chua co
            if (session != null) {
                session.invalidate(); // xoa toan bo du lieu trong session
            }
            resp.sendRedirect(req.getContextPath() + "/home");
        } else if ("register".equalsIgnoreCase(action)
                || "/register".equalsIgnoreCase(servletPath)
                || "/register.jsp".equalsIgnoreCase(servletPath)) {
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
        } else if ("profile".equalsIgnoreCase(action)
                || "/profile".equalsIgnoreCase(servletPath)
                || "/profile.jsp".equalsIgnoreCase(servletPath)) {
            HttpSession session = req.getSession(false);
            Account user = (session != null) ? (Account) session.getAttribute("user") : null;
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            req.getRequestDispatcher(PROFILE_VIEW).forward(req, resp);
        } else if ("login".equalsIgnoreCase(action)
                || "/login".equalsIgnoreCase(servletPath)
                || "/login.jsp".equalsIgnoreCase(servletPath)) {
            String errorParam = req.getParameter("error");
            if ("login_required".equals(req.getParameter("error")) && req.getAttribute("errorMessage") == null) {
                req.setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản Quản trị viên để tiếp tục!");
            } else if ("session_expired".equals(errorParam) && req.getAttribute("errorMessage") == null) {
                req.setAttribute("errorMessage", "Phiên đăng nhập đã hết hạn sau 7 ngày. Vui lòng đăng nhập lại!");
            }
            req.getRequestDispatcher(LOGIN_VIEW).forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String passwordRaw = req.getParameter("password");

        try (AccountDAO accountDao = new AccountDAO()) {
            Account acc = accountDao.getAccountByUsername(username);
            if (acc != null && acc.isIsActive() && PasswordUtil.verifyPassword(passwordRaw, acc.getPassword())) {
                HttpSession session = req.getSession();
                session.setAttribute("user", acc);

                // --- BỔ SUNG CẤU HÌNH LƯU PHIÊN 7 NGÀY ---
                int sevenDaysInSeconds = 7 * 24 * 60 * 60; // 604,800 giây
                session.setMaxInactiveInterval(sevenDaysInSeconds); // Gia hạn session server 7 ngày
                session.setAttribute("loginTime", System.currentTimeMillis()); // Lưu mốc thời gian đăng nhập

                // Tạo và gửi Cookie JSESSIONID sống 7 ngày trên trình duyệt
                jakarta.servlet.http.Cookie sessionCookie = new jakarta.servlet.http.Cookie("JSESSIONID", session.getId());
                sessionCookie.setMaxAge(sevenDaysInSeconds);
                sessionCookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                sessionCookie.setHttpOnly(true);
                resp.addCookie(sessionCookie);
                // ------------------------------------------

                // Chuyen huong ve trang chu (tren header bar se hien thi Profile va cac quyen tuong ung voi Role)
                resp.sendRedirect(req.getContextPath() + "/home");
            } else {
                // Dang nhap that bai (sai user, sai pass, hoac tai khoan bi khoa)
                req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
                req.getRequestDispatcher(LOGIN_VIEW).forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("Lỗi handleLogin: " + e.getMessage());
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            req.getRequestDispatcher(LOGIN_VIEW).forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String passwordRaw = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        String fullname = req.getParameter("fullname");
        String phone = req.getParameter("phone");
        String defaultAddress = req.getParameter("defaultAddress");

        // Kiem tra 2 mat khau co khop nhau hay khong
        if (passwordRaw == null || !passwordRaw.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
            return;
        }

        if (passwordRaw.length() < 8) {
            req.setAttribute("errorMessage", "Mật khẩu phải có ít nhất 8 ký tự!");
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
            return;
        }

        try (AccountDAO accountDao = new AccountDAO()) {
            // Kiem tra username hoac email ton tai
            if (accountDao.checkUsernameOrEmailExists(username, email)) {
                req.setAttribute("errorMessage", "Tên đăng nhập hoặc Email đã được sử dụng!");
                req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
                return;
            }

            // Hash password truoc khi luu vao db
            String hashPassword = PasswordUtil.hashPassword(passwordRaw);

            // Goi dao de insert vao db
            boolean isSuccess = accountDao.registerNewCustomer(username, email, hashPassword, fullname, phone, defaultAddress);
            if (isSuccess) {
                resp.sendRedirect(req.getContextPath() + "/login?success=1");
            } else {
                // Loi he thong sql
                req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
                req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("Lỗi handleRegister: " + e.getMessage());
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Account user = (Account) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullname = req.getParameter("fullname");
        String phone = req.getParameter("phone");
        String defaultAddress = req.getParameter("defaultAddress");

        // Validation cơ bản
        if (fullname == null || fullname.trim().length() < 2) {
            req.setAttribute("error", "Họ và tên phải có ít nhất 2 ký tự.");
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
            return;
        }

        boolean isUpdated = false;
        try (AccountDAO accountDao = new AccountDAO()) {
            if (user.getCustomerId() != null && user.getCustomerId() > 0) {
                isUpdated = accountDao.updateCustomerProfile(user.getCustomerId(), fullname, phone, defaultAddress);
            } else {
                // Đối với tài khoản Admin không có CustomerID
                isUpdated = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (isUpdated) {
            user.setFullname(fullname);
            user.setPhone(phone);
            user.setDefaultAddress(defaultAddress);
            session.setAttribute("user", user);
            req.setAttribute("message", "Cập nhật thông tin tài khoản thành công!");
        } else {
            req.setAttribute("error", "Cập nhật thất bại. Vui lòng kiểm tra lại thông tin!");
        }

        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }
}
