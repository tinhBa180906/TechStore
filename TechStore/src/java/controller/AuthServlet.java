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

    private final AccountDAO accountDao = new AccountDAO();

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
            if ("login_required".equals(req.getParameter("error")) && req.getAttribute("errorMessage") == null) {
                req.setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản Quản trị viên để tiếp tục!");
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

        Account acc = accountDao.getAccountByUsername(username);
        if (acc != null && acc.isIsActive() && PasswordUtil.verifyPassword(passwordRaw, acc.getPassword())) {
            HttpSession session = req.getSession();
            session.setAttribute("user", acc);

            // Chuyen huong ve trang chu (tren header bar se hien thi Profile va cac quyen tuong ung voi Role)
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            //dang nhap that bai (sai user, sai pass, hoac tai khoan bi khoa)
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
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

        //kiem tra 2 mat khau co khop nhau hay khong
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

        //kiem tra username hoac email ton tai
        if (accountDao.checkUsernameOrEmailExists(username, email)) {
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc Email đã được sử dụng!");
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
            return;
        }

        //hash password truoc khi luu vao db
        String hashPassword = PasswordUtil.hashPassword(passwordRaw);

        //goi dao de insert vao db
        boolean isSuccess = accountDao.registerNewCustomer(username, email, hashPassword, fullname, phone, defaultAddress);
        if (isSuccess) {
            resp.sendRedirect(req.getContextPath() + "/login?success=1");
        } else {
            //loi he thong sql
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            req.getRequestDispatcher(REGISTER_VIEW).forward(req, resp);
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullname = req.getParameter("fullname");
        String phone = req.getParameter("phone");
        String defaultAddress = req.getParameter("defaultAddress");

        if (user.getCustomerId() != null && user.getCustomerId() > 0) {
            accountDao.updateCustomerProfile(user.getCustomerId(), fullname, phone, defaultAddress);
        }

        user.setFullname(fullname);
        user.setPhone(phone);
        user.setDefaultAddress(defaultAddress);
        session.setAttribute("user", user);

        req.setAttribute("message", "Cập nhật thông tin tài khoản thành công!");
        req.getRequestDispatcher(PROFILE_VIEW).forward(req, resp);
    }
}
