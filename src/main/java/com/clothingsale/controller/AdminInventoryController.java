package com.clothingsale.controller;

import com.clothingsale.dao.InventoryDAO;
import com.clothingsale.model.ProductBatch;
import com.clothingsale.model.User;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/inventory")
public class AdminInventoryController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("import".equals(action)) {
            HttpSession session = request.getSession();
            User loggedInUser = (User) session.getAttribute("user");
            
            // Bảo vệ quyền kiểm tra đăng nhập hệ thống
            if (loggedInUser == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            try {
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                BigDecimal costPrice = new BigDecimal(request.getParameter("costPrice"));
                BigDecimal salePrice = new BigDecimal(request.getParameter("salePrice"));
                String note = request.getParameter("note");

                // Tự động sinh mã lô hàng theo thời gian thực tế
                String timeStamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date());
                String batchCode = "BATCH-" + timeStamp;

                ProductBatch batch = new ProductBatch();
                batch.setVariantId(variantId);
                batch.setBatchCode(batchCode);
                batch.setCostPrice(costPrice);
                batch.setSalePrice(salePrice);
                batch.setInitialQuantity(quantity);

                InventoryDAO inventoryDAO = new InventoryDAO();
                boolean isSuccess = inventoryDAO.importGoods(batch, loggedInUser.getId(), note);

                if (isSuccess) {
                    response.sendRedirect(request.getContextPath() + "/view/admin/admin_product.jsp?status=success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/view/admin/admin_product.jsp?status=error");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/view/admin/admin_product.jsp?status=error");
            }
        }
    }
}