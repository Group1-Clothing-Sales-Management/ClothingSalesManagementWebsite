package com.clothingsale.controller;

import com.clothingsale.model.Feedback;
import com.clothingsale.service.CustomerFeedbackService;
import com.clothingsale.model.OrderDetail;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerFeedbackController", urlPatterns = { "/customer/feedback", "/feedback/add",
                "/feedback/create" })
public class CustomerFeedbackController extends HttpServlet {

        private final CustomerFeedbackService feedbackService = new CustomerFeedbackService();

        @Override
        protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
                        throws ServletException, IOException {

                HttpSession session = request.getSession(false);

                // Chưa đăng nhập
                if (session == null
                                || session.getAttribute("authUserId") == null) {

                        response.sendRedirect(
                                        request.getContextPath() + "/login");

                        return;
                }

                int userId = (Integer) session.getAttribute("authUserId");

                String action = request.getParameter("action");

                if (action == null) {
                        action = "";
                }

                switch (action) {

                        case "create":
                                createFeedback(
                                                request,
                                                response,
                                                userId);
                                break;

                        case "update":
                                updateFeedback(
                                                request,
                                                response,
                                                userId);
                                break;

                        default:

                                response.sendRedirect(
                                                request.getContextPath() + "/home");
                }

        }

        /**
         * ==========================
         * CREATE FEEDBACK
         * ==========================
         */
        private void createFeedback(
                        HttpServletRequest request,
                        HttpServletResponse response,
                        int userId)
                        throws IOException {

                try {

                        int productId = Integer.parseInt(
                                        request.getParameter("productId"));

                        Integer orderDetailId = null;
                        String orderDetailIdParam = request.getParameter("orderDetailId");
                        if (orderDetailIdParam != null && !orderDetailIdParam.trim().isEmpty()) {
                                orderDetailId = Integer.parseInt(orderDetailIdParam);
                        }

                        int rating = Integer.parseInt(
                                        request.getParameter("rating"));

                        if (rating < 1 || rating > 5) {
                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackError=rating");
                                return;
                        }

                        String comment = request.getParameter("comment");

                        if (orderDetailId == null) {
                                orderDetailId = feedbackService.getLatestEligibleOrderDetailId(
                                                userId,
                                                productId);
                        }

                        if (orderDetailId == null
                                        || !feedbackService.canCreateFeedback(
                                                        userId,
                                                        productId,
                                                        orderDetailId)) {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackError=permission");

                                return;
                        }

                        final int selectedOrderDetailId = orderDetailId;

                        Feedback feedback = new Feedback();

                        feedback.setUserId(userId);
                        feedback.setProductId(productId);
                        feedback.setOrderDetailId(selectedOrderDetailId);
                        feedback.setRating(rating);
                        feedback.setComment(comment);

                        java.util.List<OrderDetail> eligibleDetails = feedbackService
                                        .getEligibleOrderDetailsForFeedback(userId, productId);
                        OrderDetail detail = eligibleDetails.stream()
                                        .filter(item -> item.getId() == selectedOrderDetailId)
                                        .findFirst()
                                        .orElse(null);

                        if (detail != null) {
                                feedback.setVariantId(detail.getVariantId());
                                feedback.setSize(com.clothingsale.dao.CustomerFeedbackDAO.extractVariantAttributeValue(
                                                detail.getVariantAttributesSnapshot(), "size"));
                                feedback.setColor(com.clothingsale.dao.CustomerFeedbackDAO.extractVariantAttributeValue(
                                                detail.getVariantAttributesSnapshot(), "color"));
                        }

                        boolean success = feedbackService.createFeedback(
                                        feedback);

                        if (success) {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackSuccess=1");

                        } else {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackError=create");

                        }

                } catch (Exception e) {

                        e.printStackTrace();

                        response.sendRedirect(
                                        request.getContextPath() + "/home");
                }

        }

        /**
         * ==========================
         * UPDATE FEEDBACK
         * ==========================
         */
        private void updateFeedback(
                        HttpServletRequest request,
                        HttpServletResponse response,
                        int userId)
                        throws IOException {

                try {

                        int productId = Integer.parseInt(
                                        request.getParameter("productId"));

                        int rating = Integer.parseInt(
                                        request.getParameter("rating"));

                        String comment = request.getParameter("comment");

                        Feedback feedback = new Feedback();

                        feedback.setUserId(userId);
                        feedback.setProductId(productId);
                        feedback.setRating(rating);
                        feedback.setComment(comment);

                        boolean success = feedbackService.updateFeedback(
                                        feedback);

                        if (success) {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackUpdated=1");

                        } else {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/product/detail?id="
                                                                + productId
                                                                + "&feedbackError=update");

                        }

                } catch (Exception e) {

                        e.printStackTrace();

                        response.sendRedirect(
                                        request.getContextPath()
                                                        + "/home");
                }

        }

        @Override
        public String getServletInfo() {

                return "Customer Feedback Controller";

        }

}