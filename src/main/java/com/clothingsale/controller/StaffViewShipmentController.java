package com.clothingsale.controller;

import com.clothingsale.model.DeliveryReturnInspectionItem;
import com.clothingsale.model.StaffShipment;
import com.clothingsale.service.StaffShipmentManagementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "StaffViewShipmentController", urlPatterns = { "/staff/shipments", "/admin/shipments" })
public class StaffViewShipmentController extends HttpServlet {

    private final StaffShipmentManagementService service = new StaffShipmentManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("confirmForm".equalsIgnoreCase(action)) {
            showConfirmForm(request, response);
        } else if ("inspectReturn".equalsIgnoreCase(action)) {
            showReturnInspection(request, response);
        } else {
            showShipmentList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        int staffId = (Integer) request.getSession().getAttribute("authUserId");

        if ("confirmDelivery".equalsIgnoreCase(action)) {
            confirmDelivery(request, response, staffId);
        } else if ("confirmReturnInspection".equalsIgnoreCase(action)) {
            confirmReturnInspection(request, response, staffId);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
        }
    }

    private void showShipmentList(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        List<StaffShipment> list = service.getShipments(keyword, status);
        request.setAttribute("shipments", list);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus",
                status == null || status.trim().isEmpty()
                        ? "ALL"
                        : status.toUpperCase());
        request.getRequestDispatcher("/view/staff/staff_view_shipment.jsp")
                .forward(request, response);
    }

    private void showConfirmForm(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        StaffShipment shipment = service.getShipmentById(id);
        if (shipment == null) {
            request.getSession().setAttribute("errorMsg", "Delivery record not found.");
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
            return;
        }
        request.setAttribute("shipment", shipment);
        request.getRequestDispatcher("/view/staff/staff_confirm_shipment.jsp")
                .forward(request, response);
    }

    private void showReturnInspection(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        int shipmentId = parseId(request.getParameter("id"));
        StaffShipment shipment = service.getShipmentById(shipmentId);
        if (shipment == null || !"FAILED".equalsIgnoreCase(shipment.getShippingStatus())) {
            request.getSession().setAttribute("errorMsg",
                    "Returned-goods inspection is only available for failed deliveries.");
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
            return;
        }

        List<DeliveryReturnInspectionItem> items
                = service.getReturnInspectionItems(shipmentId);
        if (items.isEmpty()) {
            request.getSession().setAttribute("errorMsg",
                    "No returned products were found for this delivery. Run the database migration before testing this flow.");
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
            return;
        }

        request.setAttribute("shipment", shipment);
        request.setAttribute("inspectionItems", items);
        request.getRequestDispatcher("/view/staff/staff_inspect_delivery_return.jsp")
                .forward(request, response);
    }

    private void confirmDelivery(HttpServletRequest request,
            HttpServletResponse response, int staffId)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        String outcome = request.getParameter("outcome");
        String remarks = request.getParameter("remarks");

        String result = service.confirmDeliveryOutcome(id, outcome, remarks, staffId);
        if ("SUCCESS".equals(result)) {
            String message = "FAILED".equalsIgnoreCase(outcome)
                    || "FAILURE".equalsIgnoreCase(outcome)
                            ? "Delivery failure recorded. Stock was not changed. Inspect the returned goods before adding eligible quantities back to inventory."
                            : "Delivery status updated successfully!";
            request.getSession().setAttribute("successMsg", message);
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
        } else {
            request.setAttribute("errorMsg", result);
            request.setAttribute("shipment", service.getShipmentById(id));
            request.getRequestDispatcher("/view/staff/staff_confirm_shipment.jsp")
                    .forward(request, response);
        }
    }

    private void confirmReturnInspection(HttpServletRequest request,
            HttpServletResponse response, int staffId)
            throws ServletException, IOException {
        int shipmentId = parseId(request.getParameter("id"));
        List<DeliveryReturnInspectionItem> items
                = service.getReturnInspectionItems(shipmentId);

        Map<Integer, Integer> restockQuantities = new LinkedHashMap<>();
        Map<Integer, Integer> damagedQuantities = new LinkedHashMap<>();
        Map<Integer, String> itemNotes = new LinkedHashMap<>();

        for (DeliveryReturnInspectionItem item : items) {
            int itemId = item.getId();
            Integer restock = parseNonNegativeInteger(
                    request.getParameter("restock_" + itemId));
            Integer damaged = parseNonNegativeInteger(
                    request.getParameter("damaged_" + itemId));
            if (restock != null) {
                restockQuantities.put(itemId, restock);
            }
            if (damaged != null) {
                damagedQuantities.put(itemId, damaged);
            }
            itemNotes.put(itemId, request.getParameter("itemNote_" + itemId));
        }

        String result = service.completeReturnInspection(
                shipmentId,
                staffId,
                restockQuantities,
                damagedQuantities,
                itemNotes,
                request.getParameter("inspectionNote")
        );

        if ("SUCCESS".equals(result)) {
            request.getSession().setAttribute("successMsg",
                    "Returned goods inspected successfully. Only eligible quantities were added back to inventory.");
            response.sendRedirect(request.getContextPath() + "/staff/shipments");
            return;
        }

        request.setAttribute("errorMsg", result);
        request.setAttribute("shipment", service.getShipmentById(shipmentId));
        request.setAttribute("inspectionItems", items);
        request.setAttribute("submittedRestock", restockQuantities);
        request.setAttribute("submittedDamaged", damagedQuantities);
        request.setAttribute("submittedItemNotes", itemNotes);
        request.setAttribute("submittedInspectionNote", request.getParameter("inspectionNote"));
        request.getRequestDispatcher("/view/staff/staff_inspect_delivery_return.jsp")
                .forward(request, response);
    }

    private boolean isStaffOrAdmin(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/login?error=unauthorized");
            return false;
        }
        Object role = session.getAttribute("authRoleName");
        if (role == null
                || (!"ADMIN".equalsIgnoreCase(role.toString())
                && !"STAFF".equalsIgnoreCase(role.toString()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return false;
        }
        return true;
    }

    private int parseId(String idStr) {
        try {
            return Integer.parseInt(idStr);
        } catch (Exception e) {
            return 0;
        }
    }

    private Integer parseNonNegativeInteger(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed < 0 ? null : parsed;
        } catch (Exception e) {
            return null;
        }
    }
}