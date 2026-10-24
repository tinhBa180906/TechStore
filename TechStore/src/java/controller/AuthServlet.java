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
        super.doPost(req, resp); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/OverriddenMethodBody
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doGet(req, resp); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/OverriddenMethodBody
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
}
