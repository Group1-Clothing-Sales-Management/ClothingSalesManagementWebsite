package com.clothingsale.service;

import com.clothingsale.dao.StaffShipmentManagementDAO;
import com.clothingsale.model.StaffShipment;
import java.util.List;

public class StaffShipmentManagementService {
    private final StaffShipmentManagementDAO dao = new StaffShipmentManagementDAO();

    public List<StaffShipment> getShipments(String keyword, String statusFilter) {
        return dao.getAllShipments(keyword, statusFilter);
    }

    public StaffShipment getShipmentById(int shipmentId) {
        return dao.getShipmentById(shipmentId);
    }

    public String confirmDeliveryOutcome(int shipmentId, String outcome, String remarks) {
        if (outcome == null || outcome.trim().isEmpty()) {
            return "Please select a valid shipment status.";
        }

        StaffShipment shipment = dao.getShipmentById(shipmentId);
        if (shipment == null) {
            return "Shipment record not found for this order.";
        }

        boolean success = dao.updateDeliveryOutcome(shipmentId, outcome.trim().toUpperCase(), remarks);
        if (success) {
            return "SUCCESS";
        } else {
            return "System connection error, unable to update status.";
        }
    }
}
