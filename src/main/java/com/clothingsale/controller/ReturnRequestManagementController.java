package com.clothingsale.controller;

import com.clothingsale.service.ReturnRequestService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Màn hình chung cho Staff và Admin.
 * Staff xử lý hồ sơ và xác nhận hàng; Admin duyệt bước hoàn tiền cuối cùng.
 */
@WebServlet(name = "ReturnRequestManagementController", urlPatterns = {"/staff/returns", "/admin/returns"})
public class ReturnRequestManagementController extends HttpServlet {

    private final ReturnRequestService service = new ReturnRequestService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!checkStaffOrAdmin(request, response)) return;
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            int id = parseId(request.getParameter("id"));
            request.setAttribute("returnRequest", service.getRequest(id));
            request.setAttribute("pageMode", "detail");
        } else {
            request.setAttribute("returnRequests", service.getStaffRequests(request.getParameter("keyword"), request.getParameter("status")));
            request.setAttribute("statusCounts", service.getStatusCounts());
            request.setAttribute("totalRefunded", service.getTotalRefunded());
            request.setAttribute("reportRows", service.getReportRows());
            request.setAttribute("pageMode", "list");
        }
        request.setAttribute("returnsBasePath", getBasePath(request));
        request.setAttribute("statusOptions", service.getStatusOptions());
        putFlash(request);
        request.getRequestDispatcher("/view/staff/staff_manage_returns.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!checkStaffOrAdmin(request, response)) return;
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        int userId = (Integer) session.getAttribute("authUserId");
        int requestId = parseId(request.getParameter("id"));
        String action = request.getParameter("action");
        String note = request.getParameter("note");
        String result;
        boolean admin = "ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("authRoleName")));

        // Staff dùng các action này để kiểm tra hồ sơ và xác nhận hàng đã về kho.
        if ("review".equalsIgnoreCase(action)) result = service.review(requestId, userId, request.getParameter("status"), note);
        else if ("receive".equalsIgnoreCase(action)) result = service.receive(requestId, userId, note);
        else if ("requestRefund".equalsIgnoreCase(action)) result = service.requestRefund(requestId, userId, note);
        // Chỉ Admin mới được ghi nhận tiền hoàn thành công hoặc từ chối khoản hoàn.
        else if (admin && "approveRefund".equalsIgnoreCase(action)) result = service.approveRefund(requestId, userId, note);
        else if (admin && "rejectRefund".equalsIgnoreCase(action)) result = service.rejectRefund(requestId, userId, note);
        else result = "You do not have permission for this action.";

        if (result.startsWith("SUCCESS:")) session.setAttribute("successMsg", result.substring("SUCCESS:".length()));
        else session.setAttribute("errorMsg", result);
        String returnMode = request.getParameter("returnMode");
        response.sendRedirect(getBasePath(request) + ("detail".equalsIgnoreCase(returnMode) ? "?action=view&id=" + requestId : ""));
    }

    private boolean checkStaffOrAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) { response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized"); return false; }
        String role = String.valueOf(session.getAttribute("authRoleName"));
        if (!"STAFF".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied."); return false; }
        return true;
    }

    private void putFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false); if (session == null) return;
        Object ok=session.getAttribute("successMsg"); Object error=session.getAttribute("errorMsg");
        if(ok!=null){request.setAttribute("successMsg",ok);session.removeAttribute("successMsg");}
        if(error!=null){request.setAttribute("errorMsg",error);session.removeAttribute("errorMsg");}
    }
    private String getBasePath(HttpServletRequest request) { return request.getContextPath() + (request.getServletPath().startsWith("/admin") ? "/admin/returns" : "/staff/returns"); }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch(Exception e) { return 0; } }
}
