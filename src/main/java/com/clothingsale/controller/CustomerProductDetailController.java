package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.clothingsale.model.Feedback;
import com.clothingsale.service.CustomerFeedbackService;
import com.clothingsale.service.WishlistService;
import java.util.List;
import java.util.Set;

@WebServlet(name = "CustomerProductDetailController",
        urlPatterns = {"/product/detail"})
public class CustomerProductDetailController extends HttpServlet {

    private CustomerProductService productService
            = new CustomerProductService();
    private CustomerFeedbackService feedbackService
            = new CustomerFeedbackService();
    private WishlistService wishlistService
            = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Kiểm tra ID hợp lệ
        if (idParam == null || idParam.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath() + "/home"
            );

            return;
        }

        try {

            int id = Integer.parseInt(idParam);

            Product product = productService.getProductById(id);

            // Không tìm thấy sản phẩm
            if (product == null) {

                response.sendRedirect(
                        request.getContextPath() + "/home"
                );

                return;
            }
            List<Feedback> feedbacks
                    = feedbackService.getFeedbackByProduct(id);

            int[] ratingCounts = new int[6];
            int commentsCount = 0;
            for (Feedback feedback : feedbacks) {
                if (feedback.getRating() >= 1 && feedback.getRating() <= 5) {
                    ratingCounts[feedback.getRating()]++;
                }
                if (feedback.getComment() != null
                        && !feedback.getComment().trim().isEmpty()) {
                    commentsCount++;
                }
            }

            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("averageRating", feedbackService.getAverageRating(id));
            request.setAttribute("ratingCounts", ratingCounts);
            request.setAttribute("commentsCount", commentsCount);
            // Gửi dữ liệu sang JSP
            request.setAttribute("product", product);
            populateWishlistState(request, id);

            request.getRequestDispatcher(
                    "/view/customer/customer_view_product_detail.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath() + "/home"
            );
        }
    }

    @Override
    public String getServletInfo() {

        return "Customer Product Detail Controller";
    }

    private void populateWishlistState(HttpServletRequest request, int productId) {
        HttpSession session = request.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("authUserId") : null;

        if (userIdObj instanceof Integer) {
            int userId = (Integer) userIdObj;
            Set<Integer> productIds = wishlistService.getWishlistProductIds(userId);
            request.setAttribute("isWishlisted", productIds.contains(productId));
            session.setAttribute("wishlistCount", productIds.size());
        } else {
            request.setAttribute("isWishlisted", false);
        }
    }
}
