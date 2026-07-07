package com.clothingsale.controller;

import com.clothingsale.model.StaffShipment;
import com.clothingsale.service.StaffShipmentManagementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffViewShipmentController", urlPatterns = { "/staff/shipments", "/admin/shipments" })
public class StaffViewShipmentController extends HttpServlet {

    private final StaffShipmentManagementService service = new StaffShipmentManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdmin(request, response))
            return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("confirmForm".equalsIgnoreCase(action)) {
            int id = parseId(request.getParameter("id"));
            StaffShipment shipment = service.getShipmentById(id);
            if (shipment == null) {
                request.getSession().setAttribute("errorMsg", "Shipment record not found.");
                response.sendRedirect(request.getContextPath() + "/staff/shipments");
                return;
            }
            request.setAttribute("shipment", shipment);
            request.getRequestDispatcher("/view/staff/StaffConfirmShipment.jsp").forward(request, response);
        } else {
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");

            List<StaffShipment> list = service.getShipments(keyword, status);
            request.setAttribute("shipments", list);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedStatus",
                    status == null || status.trim().isEmpty() ? "ALL" : status.toUpperCase());
            request.getRequestDispatcher("/view/staff/StaffViewShipment.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStaffOrAdmin(request, response))
            return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("confirmDelivery".equalsIgnoreCase(action)) {
            int id = parseId(request.getParameter("id"));
            String outcome = request.getParameter("outcome");
            String remarks = request.getParameter("remarks");

            String result = service.confirmDeliveryOutcome(id, outcome, remarks);

            if ("SUCCESS".equals(result)) {
                request.getSession().setAttribute("successMsg", "Delivery status updated successfully!");
                response.sendRedirect(request.getContextPath() + "/staff/shipments");
            } else {
                request.setAttribute("errorMsg", result);
                request.setAttribute("shipment", service.getShipmentById(id));
                request.getRequestDispatcher("/view/staff/StaffConfirmShipment.jsp").forward(request, response);
            }
        }
    }

    private boolean isStaffOrAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return false;
        }
        Object role = session.getAttribute("authRoleName");
        if (role == null
                || (!"ADMIN".equalsIgnoreCase(role.toString()) && !"STAFF".equalsIgnoreCase(role.toString()))) {
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
}
