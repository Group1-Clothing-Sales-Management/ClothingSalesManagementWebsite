package com.clothingsale.controller;

import com.clothingsale.model.Feedback;
import com.clothingsale.model.FeedbackProductGroup;
import com.clothingsale.service.FeedbackManagementService;
import java.io.IOException;
import java.util.Collections;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Shared servlet for Staff/Admin to view, respond to, and delete feedback.
 * Delete is restricted to ADMIN only.
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
     * Show products that have received feedback. The list returned by the DAO is
     * newest-first, so the LinkedHashMap also keeps products with recent activity
     * at the top of the page.
     */
    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Feedback> feedbacks = feedbackService.getAllFeedbacks();
            request.setAttribute("productGroups", new ArrayList<>(groupByProduct(feedbacks).values()));
            request.setAttribute("totalFeedbackCount", feedbacks.size());
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/staff_manage_feedback.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "System error while loading feedback list.");
            request.setAttribute("productGroups", Collections.emptyList());
            request.setAttribute("totalFeedbackCount", 0);
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/staff_manage_feedback.jsp").forward(request, response);
        }
    }

    /**
     * Show every feedback for one product.
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int productId = parseId(request.getParameter("productId"));

        try {
            List<Feedback> feedbacks = feedbackService.getFeedbacksByProduct(productId);
            if (feedbacks.isEmpty()) {
                HttpSession session = request.getSession();
                if (session.getAttribute("successMsg") == null) {
                    session.setAttribute("errorMsg", "No feedback found for this product.");
                }
                response.sendRedirect(buildFeedbackBasePath(request));
                return;
            }

            request.setAttribute("productGroup", groupByProduct(feedbacks).values().iterator().next());
            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("pageMode", "detail");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/staff_manage_feedback.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "System error while loading feedback detail.");
            request.setAttribute("productGroups", Collections.emptyList());
            request.setAttribute("totalFeedbackCount", 0);
            request.setAttribute("pageMode", "list");
            request.setAttribute("feedbackBasePath", buildFeedbackBasePath(request));
            request.getRequestDispatcher("/view/staff/staff_manage_feedback.jsp").forward(request, response);
        }
    }

    /**
     * Save a response and return to the detail page.
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

        int productId = parseId(request.getParameter("productId"));
        String redirect = buildFeedbackBasePath(request) + "?action=view&productId=" + productId;
        response.sendRedirect(redirect);
    }

    /**
     * Delete feedback. ADMIN only.
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminLoggedIn(request, response)) {
            return;
        }

        int feedbackId = parseId(request.getParameter("id"));
        String result = feedbackService.deleteFeedback(feedbackId);
        HttpSession session = request.getSession();

        if ("SUCCESS".equals(result)) {
            session.setAttribute("successMsg", "Feedback deleted successfully.");
        } else {
            session.setAttribute("errorMsg", result);
        }

        int productId = parseId(request.getParameter("productId"));
        if (productId > 0) {
            response.sendRedirect(buildFeedbackBasePath(request) + "?action=view&productId=" + productId);
        } else {
            response.sendRedirect(buildFeedbackBasePath(request));
        }
    }

    /**
     * Allow only logged-in Staff/Admin to access this servlet.
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
     * Allow only ADMIN to delete feedback.
     */
    private boolean isAdminLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return false;
        }

        Object role = session.getAttribute("authRoleName");
        if (role == null || !"ADMIN".equalsIgnoreCase(role.toString())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only ADMIN can delete feedback.");
            return false;
        }

        return true;
    }

    /**
     * Parse an int safely.
     */
    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Trim blank input safely.
     */
    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Keep redirects on the original feedback path.
     */
    private String buildFeedbackBasePath(HttpServletRequest request) {
        String servletPath = request.getServletPath();
        if ("/staff/feedback".equals(servletPath)) {
            return request.getContextPath() + "/staff/feedback";
        }
        return request.getContextPath() + "/admin/feedback";
    }

    /**
     * Read the current user id from the session.
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

    private Map<Integer, FeedbackProductGroup> groupByProduct(List<Feedback> feedbacks) {
        Map<Integer, FeedbackProductGroup> groups = new LinkedHashMap<>();
        for (Feedback feedback : feedbacks) {
            FeedbackProductGroup group = groups.get(feedback.getProductId());
            if (group == null) {
                group = new FeedbackProductGroup(feedback);
                groups.put(feedback.getProductId(), group);
            }
            group.addFeedback(feedback);
        }
        return groups;
    }
}
