/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dao.AccountDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Account;

/**
 *
 * @author Tinh Ba
 */
public class AdminUserServlet extends HttpServlet{
    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doGet(req, resp); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/OverriddenMethodBody
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //kiem tra quyen  ham post de chong hack gui request gia
        HttpSession session = req.getSession();
        Account currentUser = (Account) session.getAttribute("user");
        
        if(currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        
        //logic khoa/ mo khoa tai khoan
        if("toggleStatus".equals(action)) {
            try {
                int accountID = Integer.parseInt(req.getParameter("accountId"));
                boolean currentStatus = Boolean.parseBoolean(req.getParameter("currentStatus"));
                
                //cap nhat trang thai dao nguoc
                accountDAO.updateAccountStatus(accountID, !currentStatus);
            } catch (NumberFormatException e) {
                System.out.println(e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
    
    
    
    
}
