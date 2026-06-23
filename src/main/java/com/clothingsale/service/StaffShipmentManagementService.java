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
            return "Vui lòng lựa chọn trạng thái vận chuyển hợp lệ.";
        }

        StaffShipment shipment = dao.getShipmentById(shipmentId);
        if (shipment == null) {
            return "Không tìm thấy thông tin vận chuyển của đơn hàng này.";
        }

        boolean success = dao.updateDeliveryOutcome(shipmentId, outcome.toUpperCase(), remarks);
        if (success) {
            return "SUCCESS";
        } else {
            return "Lỗi kết nối hệ thống, không thể cập nhật trạng thái.";
        }
    }
}