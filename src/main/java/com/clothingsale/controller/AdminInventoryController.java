package com.clothingsale.controller;

import com.clothingsale.dao.AdminInventoryDAO;
import com.clothingsale.model.ProductBatch;
import com.clothingsale.model.User;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminInventoryController", urlPatterns = {"/admin/inventory"})
public class AdminInventoryController extends HttpServlet {

    private final AdminInventoryDAO inventoryDAO = new AdminInventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                // Chuyển tới form nhập kho tiếng Anh độc lập của admin
                request.getRequestDispatcher("/view/admin/import_stock.jsp").forward(request, response);
                break;
            case "list":
            default:
                List<ProductBatch> history = inventoryDAO.adminGetImportHistory();
                request.setAttribute("importHistory", history);
                request.getRequestDispatcher("/view/admin/inventory_list.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            HttpSession session = request.getSession();
            User loggedInUser = (User) session.getAttribute("user");

            // Phòng ngừa lỗi và lấy ID của Admin đang thực hiện tác vụ
            int adminUserId = (loggedInUser != null) ? loggedInUser.getId() : 1;

            try {
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                String batchCode = request.getParameter("batchCode");
                int qty = Integer.parseInt(request.getParameter("quantity"));
                BigDecimal cost = new BigDecimal(request.getParameter("costPrice"));
                BigDecimal sale = new BigDecimal(request.getParameter("salePrice"));
                String note = request.getParameter("note");

                ProductBatch newBatch = new ProductBatch();
                newBatch.setVariantId(variantId);
                newBatch.setBatchCode(batchCode);
                newBatch.setInitialQuantity(qty);
                newBatch.setCostPrice(cost);
                newBatch.setSalePrice(sale);

                boolean success = inventoryDAO.adminExecuteStockImport(newBatch, adminUserId, note);

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?status=success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?action=new&status=error");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/inventory?action=new&status=invalid");
            }
        }
    }
}
