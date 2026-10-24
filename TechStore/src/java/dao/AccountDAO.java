package dao;

import dal.DBContext;
import model.Account;
import java.sql.*;

public class AccountDAO extends DBContext {

    public Account getAccountByUsername(String username) {
        String sql = "SELECT AccountID, CustomerID, Username, Email, PasswordHash, Role, IsActive "
                + "FROM dbo.UserAccount WHERE Username = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            
            st.setString(1, username);
            try(ResultSet rs = st.executeQuery()) {
                Account acc = new Account();
                
                //gan dung accountID
                acc.setAccountId(rs.getInt("AccountID"));
                
                //xu ly CustomerID co the null voi admin
                int customerID = rs.getInt("CustomerID");
                if(!rs.wasNull()) {
                    acc.setCustomerId(customerID);
                }
                
                acc.setUserName(rs.getString("Username"));
                acc.setEmail(rs.getString("Email"));
                acc.setPassword(rs.getString("PasswordHash"));
                acc.setRole(rs.getString("Role"));
                acc.setIsActive(rs.getBoolean("IsActive"));
                return acc;
                
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return null;
    }
    
    public boolean checkUsernameOrEmailExists(String name, String email) {
        String sql = "SELECT 1 FROM dbo.UserAccount WHERE Username = ? OR Email = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, name);
            st.setString(1, email);
            try(ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return false;
    }
    
    
    
}
