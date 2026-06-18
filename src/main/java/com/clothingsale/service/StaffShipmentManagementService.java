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
        // BR3: Bắt buộc nhân viên phải chọn kết quả giao hàng (Thành công / Thất bại)
        if (outcome == null || (!"DELIVERED".equalsIgnoreCase(outcome) && !"FAILED".equalsIgnoreCase(outcome))) {
            return "Please select a valid delivery outcome (Success or Failure).";
        }

        StaffShipment shipment = dao.getShipmentById(shipmentId);
        if (shipment == null) {
            return "Shipment record not found.";
        }

        // E2: Chỉ cho phép xác nhận khi trạng thái hiện tại là 'SHIPPING' (In Transit)
        if (!"SHIPPING".equalsIgnoreCase(shipment.getShippingStatus())) {
            return "Only shipments with 'In Transit' status can be confirmed.";
        }

        boolean success = dao.updateDeliveryOutcome(shipmentId, outcome.toUpperCase(), remarks);
        if (success) {
            return "SUCCESS";
        } else {
            return "System connection error or data updated by another process.";
        }
    }
}