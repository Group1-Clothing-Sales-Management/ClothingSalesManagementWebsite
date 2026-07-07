package com.clothingsale.controller;

import com.clothingsale.model.Feedback;
import com.clothingsale.service.FeedbackManagementService;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet dùng chung cho Staff/Admin để xem, phản hồi và xóa feedback.
 * Chúng ta giữ mọi thao tác trong một controller để luồng đi đơn giản:
 * list -> detail -> respond/delete.
 */
@WebServlet(name = "FeedbackManagementController", urlPatterns = {"/admin/feedback", "/staff/feedback"})
public class FeedbackManagementController extends HttpServlet {

    private final FeedbackManagementService feedbackService = new FeedbackManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isStaffOrAdminLoggedIn(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("view".equalsIgnoreCase(action)) {
            showDetail(request, response);
        } else {
            showList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isStaffOrAdminLoggedIn(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        if ("respond".equalsIgnoreCase(action)) {
            handleRespond(request, response);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(buildFeedbackBasePath(request));
        }
    }

    /**
     * Hiển thị danh sách feedback mới nhất.
     */
    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Feedback> feedbacks = feedbackService.getAllFeedbacks();
            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/StaffManageFeedback.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "System error while loading feedback list.");
            request.setAttribute("feedbacks", Collections.emptyList());
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/StaffManageFeedback.jsp").forward(request, response);
        }
    }

    /**
     * Hiển thị chi tiết một feedback để Staff/Admin xem đầy đủ ngữ cảnh.
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int feedbackId = parseId(request.getParameter("id"));

        try {
            Feedback feedback = feedbackService.getFeedbackById(feedbackId);
            if (feedback == null) {
                request.getSession().setAttribute("errorMsg", "Feedback not found.");
                response.sendRedirect(buildFeedbackBasePath(request));
                return;
            }

            request.setAttribute("feedback", feedback);
            request.setAttribute("pageMode", "detail");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/StaffManageFeedback.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "System error while loading feedback detail.");
            request.setAttribute("feedbacks", Collections.emptyList());
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/StaffManageFeedback.jsp").forward(request, response);
        }
    }

    /**
     * Lưu phản hồi của Staff/Admin rồi quay lại trang chi tiết.
     */
    private void handleRespond(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int feedbackId = parseId(request.getParameter("id"));
        String responseText = trimToEmpty(request.getParameter("adminResponse"));
        int responderId = getCurrentUserId(request);

        String result = feedbackService.respondToFeedback(feedbackId, responseText, responderId);
        HttpSession session = request.getSession();

        if ("SUCCESS".equals(result)) {
            session.setAttribute("successMsg", "Feedback response saved successfully.");
        } else {
            session.setAttribute("errorMsg", result);
        }

        response.sendRedirect(buildFeedbackBasePath(request) + "?action=view&id=" + feedbackId);
    }

    /**
     * Xóa feedback rồi quay về danh sách.
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int feedbackId = parseId(request.getParameter("id"));
        String result = feedbackService.deleteFeedback(feedbackId);
        HttpSession session = request.getSession();

        if ("SUCCESS".equals(result)) {
            session.setAttribute("successMsg", "Feedback deleted successfully.");
        } else {
            session.setAttribute("errorMsg", result);
        }

        response.sendRedirect(buildFeedbackBasePath(request));
    }

    /**
     * Chỉ cho Staff/Admin đã đăng nhập truy cập màn hình này.
     */
    private boolean isStaffOrAdminLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
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

    /**
     * Chuyển chuỗi sang số nguyên an toàn để tránh lỗi nhập liệu.
     */
    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Loại bỏ khoảng trắng thừa để lưu dữ liệu sạch hơn.
     */
    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Tự giữ đúng URL gốc của trang feedback để redirect không bị lệch staff/admin.
     */
    private String buildFeedbackBasePath(HttpServletRequest request) {
        String servletPath = request.getServletPath();
        if ("/staff/feedback".equals(servletPath)) {
            return request.getContextPath() + "/staff/feedback";
        }
        return request.getContextPath() + "/admin/feedback";
    }

    /**
     * Lấy id người đang đăng nhập từ session, dùng để ghi nhận ai đã phản hồi.
     */
    private int getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object userId = session.getAttribute("authUserId");
            if (userId instanceof Integer) {
                return (Integer) userId;
            }
        }
        return 0;
    }
}
