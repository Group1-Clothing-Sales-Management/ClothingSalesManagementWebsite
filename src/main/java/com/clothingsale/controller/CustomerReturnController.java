package com.clothingsale.controller;

import com.clothingsale.model.Order;
import com.clothingsale.model.ReturnRequestItem;
import com.clothingsale.service.ReturnRequestService;
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

/** Controller cho khách tạo và theo dõi yêu cầu đổi trả. */
@WebServlet("/customer/returns")
public class CustomerReturnController extends HttpServlet {

    private final ReturnRequestService service = new ReturnRequestService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isCustomer(session)) { response.sendRedirect(request.getContextPath() + "/customer/login"); return; }
        int userId = (Integer) session.getAttribute("authUserId");
        putFlash(request, session);
        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            // Luôn kiểm tra customerId trong service để khách không thể xem hồ sơ của người khác.
            request.setAttribute("returnRequest", service.getCustomerRequest(userId, parseId(request.getParameter("id"))));
            request.getRequestDispatcher("/view/customer/customer_return_detail.jsp").forward(request, response);
            return;
        }
        if ("create".equalsIgnoreCase(action)) {
            int orderId = parseId(request.getParameter("orderId"));
            Order order = service.getEligibleOrder(userId, orderId);
            if (order == null) { request.setAttribute("errorMsg", "This order is outside the return window or already has an active request."); }
            request.setAttribute("selectedOrder", order);
            request.setAttribute("returnItems", order == null ? java.util.Collections.emptyList() : service.getOrderItems(userId, orderId));
            request.setAttribute("refundBanks", service.getRefundBanks());
        }
        request.setAttribute("returnRequests", service.getCustomerRequests(userId));
        request.getRequestDispatcher("/view/customer/customer_returns.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (!isCustomer(session)) { response.sendRedirect(request.getContextPath() + "/customer/login"); return; }
        request.setCharacterEncoding("UTF-8");
        int userId = (Integer) session.getAttribute("authUserId");
        if ("supplement".equalsIgnoreCase(request.getParameter("action"))) {
            String result = service.supplementInfo(userId, parseId(request.getParameter("requestId")), request.getParameter("additionalNote"));
            session.setAttribute(result.startsWith("SUCCESS") ? "returnMessage" : "returnError", result.startsWith("SUCCESS") ? "Additional information sent successfully." : result);
            response.sendRedirect(request.getContextPath() + "/customer/returns");
            return;
        }
        Map<Integer, Integer> quantities = new LinkedHashMap<>();
        // Đọc trực tiếp các input quantity_<orderDetailId> để không phụ thuộc vào thứ tự
        // của các hidden input detailId trong bảng sản phẩm.
        for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
            String parameterName = entry.getKey();
            if (!parameterName.startsWith("quantity_")) continue;
            int id = parseId(parameterName.substring("quantity_".length()));
            String[] values = entry.getValue();
            int quantity = values == null || values.length == 0 ? 0 : parseId(values[0]);
            if (id > 0 && quantity > 0) quantities.put(id, quantity);
        }
        String result = service.createRequest(userId, parseId(request.getParameter("orderId")), request.getParameter("type"), request.getParameter("reason"), request.getParameter("customerNote"),
                request.getParameter("bankId"), request.getParameter("accountName"), request.getParameter("accountNumber"), quantities);
        session.setAttribute(result.startsWith("SUCCESS") ? "returnMessage" : "returnError", result.startsWith("SUCCESS") ? "Return request submitted successfully." : result);
        response.sendRedirect(request.getContextPath() + "/customer/returns");
    }

    private void putFlash(HttpServletRequest request, HttpSession session) { Object ok=session.getAttribute("returnMessage"); Object error=session.getAttribute("returnError"); if(ok!=null){request.setAttribute("successMsg",ok);session.removeAttribute("returnMessage");} if(error!=null){request.setAttribute("errorMsg",error);session.removeAttribute("returnError");} }
    private boolean isCustomer(HttpSession session) { return session != null && session.getAttribute("authUserId") != null; }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch(Exception e) { return 0; } }
}
