package com.clothingsale.service;

import com.clothingsale.dao.StaffShipmentManagementDAO;
import com.clothingsale.model.DeliveryReturnInspectionItem;
import com.clothingsale.model.StaffShipment;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class StaffShipmentManagementService {

    private final StaffShipmentManagementDAO dao = new StaffShipmentManagementDAO();

    public List<StaffShipment> getShipments(String keyword, String statusFilter) {
        return dao.getAllShipments(keyword, statusFilter);
    }

    public StaffShipment getShipmentById(int shipmentId) {
        return dao.getShipmentById(shipmentId);
    }

    public List<DeliveryReturnInspectionItem> getReturnInspectionItems(int shipmentId) {
        return dao.getReturnInspectionItems(shipmentId);
    }

    public String confirmDeliveryOutcome(int shipmentId, String outcome,
            String remarks, int staffId) {
        if (shipmentId <= 0) {
            return "Invalid delivery record.";
        }
        if (staffId <= 0) {
            return "The current staff account could not be identified.";
        }
        if (outcome == null || outcome.trim().isEmpty()) {
            return "Please select a valid delivery status.";
        }

        String normalizedOutcome = outcome.trim().toUpperCase();
        if ("FAILURE".equals(normalizedOutcome)) {
            normalizedOutcome = "FAILED";
        }
        if (!"SHIPPING".equals(normalizedOutcome)
                && !"SUCCESS".equals(normalizedOutcome)
                && !"FAILED".equals(normalizedOutcome)) {
            return "The selected delivery status is not supported.";
        }
        if ("FAILED".equals(normalizedOutcome)
                && (remarks == null || remarks.trim().isEmpty())) {
            return "Please enter the reason for delivery failure.";
        }

        StaffShipment shipment = dao.getShipmentById(shipmentId);
        if (shipment == null) {
            return "Delivery record not found for this order.";
        }

        boolean success = dao.updateDeliveryOutcome(
                shipmentId,
                normalizedOutcome,
                remarks,
                staffId
        );
        return success
                ? "SUCCESS"
                : "The delivery status could not be updated because the order state has changed or the database operation failed.";
    }

    public String completeReturnInspection(int shipmentId, int staffId,
            Map<Integer, Integer> restockQuantities,
            Map<Integer, Integer> damagedQuantities,
            Map<Integer, String> itemNotes,
            String inspectionNote) {
        if (shipmentId <= 0 || staffId <= 0) {
            return "Invalid returned-goods inspection request.";
        }

        StaffShipment shipment = dao.getShipmentById(shipmentId);
        if (shipment == null || !"FAILED".equalsIgnoreCase(shipment.getShippingStatus())) {
            return "Only failed deliveries can be inspected for return to inventory.";
        }
        if (!StaffShipmentManagementDAO.INSPECTION_PENDING.equalsIgnoreCase(
                shipment.getReturnInspectionStatus())) {
            return "This returned shipment has already been processed or has no pending inspection.";
        }

        List<DeliveryReturnInspectionItem> items = dao.getReturnInspectionItems(shipmentId);
        if (items.isEmpty()) {
            return "No returned products were found for this delivery.";
        }

        for (DeliveryReturnInspectionItem item : items) {
            Integer restock = restockQuantities.get(item.getId());
            Integer damaged = damagedQuantities.get(item.getId());
            if (restock == null || damaged == null) {
                return "Please enter inspection quantities for every returned product.";
            }
            if (restock < 0 || damaged < 0) {
                return "Inspection quantities cannot be negative.";
            }
            if (restock + damaged != item.getReturnQuantity()) {
                return "For " + item.getProductNameSnapshot()
                        + ", restock quantity plus damaged quantity must equal "
                        + item.getReturnQuantity() + ".";
            }
            String itemNote = itemNotes.get(item.getId());
            if (damaged > 0 && (itemNote == null || itemNote.trim().isEmpty())) {
                return "Please describe the damage or missing condition for "
                        + item.getProductNameSnapshot() + ".";
            }
            if (restock > 0 && (item.getVariantId() == null || item.getVariantId() <= 0)) {
                return item.getProductNameSnapshot()
                        + " no longer has a valid variant and cannot be added back to inventory.";
            }
        }

        try {
            boolean success = dao.completeReturnInspection(
                    shipmentId,
                    staffId,
                    restockQuantities,
                    damagedQuantities,
                    itemNotes,
                    inspectionNote
            );
            return success
                    ? "SUCCESS"
                    : "The inspection could not be completed because it was already processed or changed by another user.";
        } catch (SQLException e) {
            e.printStackTrace();
            return e.getMessage() == null
                    ? "Could not complete the returned-goods inspection."
                    : e.getMessage();
        }
    }
}