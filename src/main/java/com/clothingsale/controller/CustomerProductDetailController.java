package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.CustomerProductService;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.clothingsale.model.Feedback;
import com.clothingsale.service.CustomerFeedbackService;
import java.util.List;

@WebServlet(name = "CustomerProductDetailController",
        urlPatterns = {"/product/detail"})
public class CustomerProductDetailController extends HttpServlet {

    private CustomerProductService productService
            = new CustomerProductService();
    private CustomerFeedbackService feedbackService
            = new CustomerFeedbackService();

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

            request.setAttribute("feedbacks", feedbacks);
            // Gửi dữ liệu sang JSP
            request.setAttribute("product", product);

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
}
