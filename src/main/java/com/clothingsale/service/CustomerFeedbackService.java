package com.clothingsale.service;

import com.clothingsale.dao.CustomerFeedbackDAO;
import com.clothingsale.model.Feedback;

import java.math.BigDecimal;
import java.util.List;

public class CustomerFeedbackService {

    private final CustomerFeedbackDAO feedbackDAO =
            new CustomerFeedbackDAO();

    /**
     * Lấy toàn bộ feedback của sản phẩm
     */
    public List<Feedback> getFeedbackByProduct(int productId) {

        return feedbackDAO.getFeedbackByProduct(productId);

    }

    /**
     * Lấy feedback của user đối với sản phẩm
     */
    public Feedback getUserFeedback(int userId, int productId) {

        return feedbackDAO.getUserFeedback(userId, productId);

    }

    /**
     * Điểm đánh giá trung bình
     */
    public BigDecimal getAverageRating(int productId) {

        return feedbackDAO.getAverageRating(productId);

    }

    /**
     * Kiểm tra user có được tạo feedback hay không
     */
    public boolean canCreateFeedback(int userId, int productId) {

        return feedbackDAO.canCreateFeedback(userId, productId);

    }

    /**
     * Kiểm tra đã mua và đã giao
     */
    public boolean hasPurchasedDeliveredProduct(int userId,
                                                int productId) {

        return feedbackDAO.hasPurchasedDeliveredProduct(
                userId,
                productId
        );

    }

    /**
     * Kiểm tra đã feedback chưa
     */
    public boolean hasFeedback(int userId,
                               int productId) {

        return feedbackDAO.hasFeedback(
                userId,
                productId
        );

    }

    /**
     * Tạo Feedback
     */
    public boolean createFeedback(Feedback feedback) {

        Integer orderId =
                feedbackDAO.getDeliveredOrderId(
                        feedback.getUserId(),
                        feedback.getProductId()
                );

        if (orderId == null) {

            return false;

        }

        feedback.setOrderId(orderId);

        // feedback mới luôn hiển thị
        feedback.setVisible(true);

        return feedbackDAO.createFeedback(feedback);

    }

    /**
     * Cập nhật Feedback
     */
    public boolean updateFeedback(Feedback feedback) {

        Feedback old =
                feedbackDAO.getUserFeedback(
                        feedback.getUserId(),
                        feedback.getProductId()
                );

        if (old == null) {

            return false;

        }

        feedback.setId(old.getId());

        return feedbackDAO.updateFeedback(feedback);

    }

}