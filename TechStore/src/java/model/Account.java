
package model;
import java.time.LocalDateTime;


public class Account {
    private int accountId;
    private Integer customerId;
    private String userName;
    private String email;
    private String password;
    private String role;
    private boolean isActive;

    private LocalDateTime createAt;

    public Account() {
    }

    public Account(int accountId, Integer customerId, String userName, String email, String password, String role, boolean isActive, LocalDateTime createAt) {
        this.accountId = accountId;
        this.customerId = customerId;
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.isActive = isActive;
        this.createAt = createAt;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getCreateAt() {
        return createAt;
    }

    public void setCreateAt(LocalDateTime createAt) {
        this.createAt = createAt;
    }
    
    
    
    
    
}
