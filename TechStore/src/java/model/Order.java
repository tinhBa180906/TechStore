/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 *
 * @author Tinh Ba
 */
public class Order {
    private int orderId; // invoiceID
    private int customerId;
    private LocalDateTime dateCreated;
    private String orderStatus;
    private String paymentMethod;
    private String shippingName;
    private String shippingPhone;
    private String shippingAddress;
    private LocalDateTime completeAt;
    private BigDecimal totalAmount; // tong tien tu view vw_OrderTotals
    private List<OrderDetail> details; //danh sach cac san pham trong don hang nay

    public Order() {
    }

    public Order(int orderId, int customerId, LocalDateTime dateCreated, String orderStatus, String paymentMethod, String shippingName, String shippingPhone, String shippingAddress, LocalDateTime completeAt, BigDecimal totalAmount, List<OrderDetail> details) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.dateCreated = dateCreated;
        this.orderStatus = orderStatus;
        this.paymentMethod = paymentMethod;
        this.shippingName = shippingName;
        this.shippingPhone = shippingPhone;
        this.shippingAddress = shippingAddress;
        this.completeAt = completeAt;
        this.totalAmount = totalAmount;
        this.details = details;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public LocalDateTime getDateCreated() {
        return dateCreated;
    }

    public void setDateCreated(LocalDateTime dateCreated) {
        this.dateCreated = dateCreated;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getShippingName() {
        return shippingName;
    }

    public void setShippingName(String shippingName) {
        this.shippingName = shippingName;
    }

    public String getShippingPhone() {
        return shippingPhone;
    }

    public void setShippingPhone(String shippingPhone) {
        this.shippingPhone = shippingPhone;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public LocalDateTime getCompleteAt() {
        return completeAt;
    }

    public void setCompleteAt(LocalDateTime completeAt) {
        this.completeAt = completeAt;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public List<OrderDetail> getDetails() {
        return details;
    }

    public void setDetails(List<OrderDetail> details) {
        this.details = details;
    }
    
    
}
