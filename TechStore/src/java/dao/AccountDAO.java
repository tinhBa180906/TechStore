package dao;

import dal.DBContext;
import model.Account;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO extends DBContext {

    public Account getAccountByUsername(String username) {
        String sql = "SELECT ua.AccountID, ua.CustomerID, ua.Username, ua.Email, ua.PasswordHash, ua.Role, ua.IsActive, "
                + "c.FullName, c.Phone, c.DefaultAddress "
                + "FROM dbo.UserAccount ua "
                + "LEFT JOIN dbo.Customer c ON ua.CustomerID = c.CustomerID "
                + "WHERE ua.Username = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setString(1, username);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Account acc = new Account();

                    //gan dung accountID
                    acc.setAccountId(rs.getInt("AccountID"));

                    //xu ly CustomerID co the null voi admin
                    int customerID = rs.getInt("CustomerID");
                    if (!rs.wasNull()) {
                        acc.setCustomerId(customerID);
                    }

                    acc.setUserName(rs.getString("Username"));
                    acc.setEmail(rs.getString("Email"));
                    acc.setPassword(rs.getString("PasswordHash"));
                    acc.setRole(rs.getString("Role"));
                    acc.setIsActive(rs.getBoolean("IsActive"));
                    acc.setFullname(rs.getNString("FullName"));
                    acc.setPhone(rs.getString("Phone"));
                    acc.setDefaultAddress(rs.getNString("DefaultAddress"));
                    return acc;
                }

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
            try (ResultSet rs = st.executeQuery()) {
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

            stCustomer = connection.prepareStatement(sqlCustomer, Statement.RETURN_GENERATED_KEYS);
            stCustomer.setNString(1, fullname);
            stCustomer.setString(2, phone);
            stCustomer.setNString(3, defaultAddress);
            stCustomer.executeUpdate();
            rsGeneratedKeys = stCustomer.getGeneratedKeys();
            if (rsGeneratedKeys.next()) {
                int newCustomerID = rsGeneratedKeys.getInt(1);

                stAccount = connection.prepareStatement(sqlAccount);
                stAccount.setInt(1, newCustomerID);
                stAccount.setString(2, username);
                stAccount.setString(3, email);
                stAccount.setString(4, passwordHash);

                int rowAffected = stAccount.executeUpdate();
                if (rowAffected > 0) {
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
        } finally {
            try {
                if (rsGeneratedKeys != null) {
                    rsGeneratedKeys.close();
                }
                if (stCustomer != null) {
                    stCustomer.close();
                }
                if (stAccount != null) {
                    stAccount.close();
                }
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
            } catch (SQLException e) {
                System.out.println(e.getMessage());
            }

        }
        return isSuccess;
    }

    public List<Account> getAllAccount() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT ua.AccountID, ua.CustomerID, ua.Username, ua.Email, ua.Role, ua.IsActive, "
                + "c.FullName, c.Phone, c.DefaultAddress "
                + "FROM dbo.UserAccount ua "
                + "LEFT JOIN dbo.Customer c ON ua.CustomerID = c.CustomerID";

        try (PreparedStatement st = connection.prepareStatement(sql); ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Account acc = new Account();
                acc.setAccountId(rs.getInt("AccountID"));

                int customerId = rs.getInt("CustomerID");
                if (!rs.wasNull()) {
                    acc.setCustomerId(customerId);
                }

                acc.setUserName(rs.getString("Username"));
                acc.setEmail(rs.getString("Email"));
                acc.setRole(rs.getString("Role"));
                acc.setIsActive(rs.getBoolean("IsActive"));
                acc.setFullname(rs.getNString("FullName"));
                acc.setPhone(rs.getString("Phone"));
                acc.setDefaultAddress(rs.getNString("DefaultAddress"));

                list.add(acc);
            }
        } catch (SQLException e) {
            System.out.println("Lỗi getAllAccounts: " + e.getMessage());
        }
        return list;
    }

    public boolean updateAccountStatus(int accountId, boolean isActive) {
        String sql = "UPDATE dbo.UserAccount SET IsActive = ? WHERE AccountID = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setBoolean(1, isActive);
            st.setInt(2, accountId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Lỗi updateAccountStatus: " + e.getMessage());
        }
        return false;
    }

    public boolean updateCustomerProfile(int customerId, String fullname, String phone, String defaultAddress) {
        String sql = "UPDATE dbo.Customer SET FullName = ?, Phone = ?, DefaultAddress = ? WHERE CustomerID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setNString(1, fullname);
            st.setString(2, phone);
            st.setNString(3, defaultAddress);
            st.setInt(4, customerId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Lỗi updateCustomerProfile: " + e.getMessage());
        }
        return false;
    }

}
