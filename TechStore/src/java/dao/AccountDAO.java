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
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            
            st.setString(1, name);
            st.setString(2, email);
            try(ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return false;
    }
    
    
    public boolean registerNewCustomer(String username, String email, String passwordHash,
                                    String fullname, String phone, String defaultAddress) {
        String sqlCustomer = "INSERT INTO dbo.Customer (FullName, Phone, DefaultAddress) VALUES (?, ?, ?)";
        String sqlAccount = "INSERT INTO dbo.UserAccount (CustomerID, Username, Email, PasswordHash, Role) VALUES (?, ?, ?, ?, 'CUSTOMER')";
        PreparedStatement stCustomer = null;
        PreparedStatement stAccount = null;
        ResultSet rsGeneratedKeys = null;
        boolean isSuccess = false;
        try {
            connection.setAutoCommit(false);
            
            stCustomer = connection.prepareStatement(sqlCustomer);
            stCustomer.setString(1, fullname);
            stCustomer.setString(2, phone);
            stCustomer.setString(3, defaultAddress);
            stCustomer.executeUpdate();
            rsGeneratedKeys = stCustomer.getGeneratedKeys();
            if(rsGeneratedKeys.next()) {
                int newCustomerID = rsGeneratedKeys.getInt(1);
                
                stAccount = connection.prepareStatement(sqlAccount);
                stAccount.setInt(1, newCustomerID);
                stAccount.setString(2, username);
                stAccount.setString(3, email);
                stAccount.setString(4, passwordHash);
                
                int rowAffected = stAccount.executeUpdate();
                if(rowAffected > 0) {
                    connection.commit();
                    isSuccess = true;
                } else {
                    connection.rollback();
                }
            } else {
                connection.rollback();
            }
        } catch (SQLException e) {
            System.out.println("Error rollback: " + e.getMessage());
        }
        finally{
            try {
                if(rsGeneratedKeys != null) rsGeneratedKeys.close();
                if(stCustomer != null) stCustomer.close();
                if(stAccount != null) stAccount.close();
                if(connection != null) connection.setAutoCommit(true);
            } catch (SQLException e) {
                System.out.println(e.getMessage());
            }
            
           
        }
        return isSuccess;
    }
    
}
