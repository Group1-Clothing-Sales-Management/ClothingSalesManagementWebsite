package com.clothingsale.controller;

import com.clothingsale.model.Feedback;
import com.clothingsale.service.CustomerFeedbackService;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
        name = "CustomerFeedbackController",
        urlPatterns = {"/customer/feedback"}
)
public class CustomerFeedbackController extends HttpServlet {

    private final CustomerFeedbackService feedbackService
            = new CustomerFeedbackService();

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Chưa đăng nhập
        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

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
                        userId
                );
                break;

            case "update":
                updateFeedback(
                        request,
                        response,
                        userId
                );
                break;

            default:

                response.sendRedirect(
                        request.getContextPath() + "/home"
                );
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

            int rating = Integer.parseInt(
                    request.getParameter("rating"));

            String comment =
                    request.getParameter("comment");

            if (!feedbackService.canCreateFeedback(
                    userId,
                    productId)) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/product/detail?id="
                        + productId
                        + "&feedbackError=permission");

                return;
            }

            Feedback feedback = new Feedback();

            feedback.setUserId(userId);
            feedback.setProductId(productId);
            feedback.setRating(rating);
            feedback.setComment(comment);

            boolean success =
                    feedbackService.createFeedback(
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

            String comment =
                    request.getParameter("comment");

            Feedback feedback = new Feedback();

            feedback.setUserId(userId);
            feedback.setProductId(productId);
            feedback.setRating(rating);
            feedback.setComment(comment);

            boolean success =
                    feedbackService.updateFeedback(
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