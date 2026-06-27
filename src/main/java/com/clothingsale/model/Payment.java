package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payment {

    private int id;
    private int orderId;
    private String paymentMethod; // COD, VNPAY
    private String paymentStatus; // UNPAID, PAID
    private BigDecimal amount;
    private String transactionReference;
    private Timestamp paymentDate;

    public Payment() {}

    public void setId(int id) {
        this.id = id;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public void setTransactionReference(String transactionReference) {
        this.transactionReference = transactionReference;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    // getters + setters

    public int getId() {
        return id;
    }

    public int getOrderId() {
        return orderId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getTransactionReference() {
        return transactionReference;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }
}