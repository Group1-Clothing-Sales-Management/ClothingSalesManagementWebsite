package com.clothingsale.model;

import java.math.BigDecimal;
import java.util.Date;

public class Shipment {

    private int id;
    private String carrierName;
    private String shippingStatus;
    private String trackingCode;
    private BigDecimal shippingCost;
    private Date estimatedDeliveryTime;

    public Shipment() {}

    public Shipment(int id, String carrierName, String shippingStatus,
                    String trackingCode, BigDecimal shippingCost,
                    Date estimatedDeliveryTime) {
        this.id = id;
        this.carrierName = carrierName;
        this.shippingStatus = shippingStatus;
        this.trackingCode = trackingCode;
        this.shippingCost = shippingCost;
        this.estimatedDeliveryTime = estimatedDeliveryTime;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCarrierName() { return carrierName; }
    public void setCarrierName(String carrierName) { this.carrierName = carrierName; }

    public String getShippingStatus() { return shippingStatus; }
    public void setShippingStatus(String shippingStatus) { this.shippingStatus = shippingStatus; }

    public String getTrackingCode() { return trackingCode; }
    public void setTrackingCode(String trackingCode) { this.trackingCode = trackingCode; }

    public BigDecimal getShippingCost() { return shippingCost; }
    public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }

    public Date getEstimatedDeliveryTime() { return estimatedDeliveryTime; }
    public void setEstimatedDeliveryTime(Date estimatedDeliveryTime) { this.estimatedDeliveryTime = estimatedDeliveryTime; }
}