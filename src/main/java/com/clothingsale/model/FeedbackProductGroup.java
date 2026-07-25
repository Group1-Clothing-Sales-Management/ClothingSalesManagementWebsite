package com.clothingsale.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * View model used by the Staff/Admin feedback page.
 * A group represents one product and all feedback submitted for that product.
 */
public class FeedbackProductGroup {

    private final int productId;
    private final String productName;
    private final String productSlug;
    private final String productImageUrl;
    private final List<Feedback> feedbacks = new ArrayList<>();

    public FeedbackProductGroup(Feedback firstFeedback) {
        this.productId = firstFeedback.getProductId();
        this.productName = firstFeedback.getProductName();
        this.productSlug = firstFeedback.getProductSlug();
        this.productImageUrl = firstFeedback.getProductImageUrl();
    }

    public void addFeedback(Feedback feedback) {
        feedbacks.add(feedback);
    }

    public int getProductId() {
        return productId;
    }

    public String getProductName() {
        return productName;
    }

    public String getProductSlug() {
        return productSlug;
    }

    public String getProductImageUrl() {
        return productImageUrl;
    }

    public List<Feedback> getFeedbacks() {
        return feedbacks;
    }

    public int getFeedbackCount() {
        return feedbacks.size();
    }

    public int getRepliedCount() {
        int count = 0;
        for (Feedback feedback : feedbacks) {
            if (feedback.getAdminResponse() != null && !feedback.getAdminResponse().trim().isEmpty()) {
                count++;
            }
        }
        return count;
    }

    public int getPendingCount() {
        return getFeedbackCount() - getRepliedCount();
    }

    public double getAverageRating() {
        if (feedbacks.isEmpty()) {
            return 0;
        }
        int total = 0;
        for (Feedback feedback : feedbacks) {
            total += feedback.getRating();
        }
        return (double) total / feedbacks.size();
    }

    public Timestamp getLatestCreatedAt() {
        return feedbacks.isEmpty() ? null : feedbacks.get(0).getCreatedAt();
    }
}
