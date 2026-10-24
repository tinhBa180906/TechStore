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
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet{
    private final AccountDAO accountDao = new AccountDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            //cau hinh utf-8 de doc duoc tineg viet tu ten, ho ten
            req.setCharacterEncoding("UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            String action = req.getParameter("action");
            if("login".equals(action)) {
                handleLogin(req, resp);
            } else if("register".equals(action)) {
                handleRegister(req, resp);
            }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if("logout".equals(action)) {
            HttpSession session = req.getSession(false); // khong tao session moi neu chua co
            if(session != null) {
                session.invalidate();//xoa toan bo du lieu trong session
            }
            resp.sendRedirect(req.getContextPath() + "/logout.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }
    
    
    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String passwordRaw = req.getParameter("password");
        
        Account acc = accountDao.getAccountByUsername(username);
        if(acc == null && acc.isIsActive() && 
                PasswordUtil.verifyPassword(passwordRaw, acc.getPassword())) {
            HttpSession session = req.getSession();
            session.setAttribute("user", acc);
            
            //phan luong theo addmin hat customer
            if("ADMIN".equals(acc.getRole())) {
                //neu la admin vao trang quan tri
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                //neu la customer, chuyen huong ve trang chu
                resp.sendRedirect(req.getContextPath() + "/home");
            }
        }
        else {
            //dang nhap that bai (sai user, sai pass, hoac tai khoan bi khoa)
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
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
        
        //kien tra 2 mat khau co khop nhau hay khong
        if(!passwordRaw.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        //kiem tra user name hoaawcj password tồn tại
        if(accountDao.checkUsernameOrEmailExists(username, email)) {
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc Email đã được sử dụng!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        //hash pasword truoc khi luu vao db
        String hashPassword = PasswordUtil.hashPassword(passwordRaw);
        
        //goi dao de insert vao db
        boolean isSuccess = accountDao.registerNewCustomer(username, email, hashPassword, fullname, phone, defaultAddress);
        if(isSuccess) {
           resp.sendRedirect(req.getContextPath() + ".login.jsp?success=1");
        } else {
            //loi he thong sql
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }
}
