package com.clothingsale.service;

import com.clothingsale.dao.FeedbackManagementDAO;
import com.clothingsale.model.Feedback;
import java.util.List;

/**
 * Lớp service giữ logic nghiệp vụ mỏng.
 * Mục tiêu là để controller không phải gọi DAO trực tiếp và vẫn dễ đọc.
 */
public class FeedbackManagementService {

    private final FeedbackManagementDAO feedbackDAO = new FeedbackManagementDAO();

    public List<Feedback> getAllFeedbacks() throws Exception {
        return feedbackDAO.getAllFeedbacks();
    }

    public Feedback getFeedbackById(int id) throws Exception {
        return feedbackDAO.getFeedbackById(id);
    }

    public String respondToFeedback(int feedbackId, String response, int responderId) {
        // Kiểm tra input tối thiểu để tránh lưu phản hồi rỗng.
        if (feedbackId <= 0) {
            return "Invalid feedback id.";
        }
        if (response == null || response.trim().isEmpty()) {
            return "Response content is required.";
        }
        if (responderId <= 0) {
            return "The current account information is invalid.";
        }

        try {
            boolean updated = feedbackDAO.updateResponse(feedbackId, response.trim(), responderId);
            if (updated) {
                return "SUCCESS";
            }
            return "Feedback not found or could not be updated.";
        } catch (Exception e) {
            e.printStackTrace();
            return "System error while saving response.";
        }
    }

    public String deleteFeedback(int feedbackId) {
        if (feedbackId <= 0) {
            return "Invalid feedback id.";
        }

        try {
            boolean deleted = feedbackDAO.deleteFeedback(feedbackId);
            if (deleted) {
                return "SUCCESS";
            }
            return "Feedback not found or could not be deleted.";
        } catch (Exception e) {
            e.printStackTrace();
            return "System error while deleting feedback.";
        }
    }
}
