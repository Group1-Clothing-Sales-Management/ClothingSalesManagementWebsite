package com.clothingsale.controller;

import com.clothingsale.dao.AdminInventoryDAO;
import com.clothingsale.model.ProductBatch;
import com.clothingsale.model.ProductVariant;
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

@WebServlet(name = "AdminInventoryController", urlPatterns = {"/AdminInventory", "/admin/inventory"})
public class AdminInventoryController extends HttpServlet {

    private final AdminInventoryDAO inventoryDAO = new AdminInventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Thiết lập mặc định nếu tham số trống
        }

        if ("IMPORT_PAGE".equals(action)) {
            // Tải dữ liệu tích hợp từ DAO để hiển thị lên Form nhập hàng
            List<ProductVariant> activeVariants = inventoryDAO.getAllActiveVariantsForImport();
            request.setAttribute("activeVariants", activeVariants);

            request.getRequestDispatcher("/view/admin/import_stock.jsp").forward(request, response);
        } else if ("list".equals(action)) {
            // Lấy lịch sử nhập kho để hiển thị ra trang danh sách (Khớp chuẩn logic gốc của bạn)
            List<com.clothingsale.model.ProductBatch> history = inventoryDAO.adminGetImportHistory();
            request.setAttribute("importHistory", history);

            request.getRequestDispatcher("/view/admin/inventory_list.jsp").forward(request, response);
        } else {
            // Trường hợp Admin gõ sai action, chuyển hướng an toàn về trang danh sách chuẩn để tránh lỗi lặp
            response.sendRedirect(request.getContextPath() + "/admin/inventory?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("IMPORT".equals(action)) {
            HttpSession session = request.getSession();
            User loggedInUser = (User) session.getAttribute("user");
            int adminUserId = (loggedInUser != null) ? loggedInUser.getId() : 1;

            try {
                // Read form parallel arrays from dynamic table inputs
                String[] variantIds = request.getParameterValues("variantId[]");
                String[] quantities = request.getParameterValues("quantity[]");
                String[] costPrices = request.getParameterValues("costPrice[]");
                String[] salePrices = request.getParameterValues("salePrice[]");

                String batchCode = request.getParameter("batchCode");
                String note = request.getParameter("note");

                // Guard clause against empty checklist submit
                if (variantIds == null || variantIds.length == 0) {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?action=IMPORT_PAGE&status=invalid");
                    return;
                }

                java.util.List<ProductBatch> batchList = new java.util.ArrayList<>();

                // Loop and build objects list
                for (int i = 0; i < variantIds.length; i++) {
                    ProductBatch item = new ProductBatch();
                    item.setVariantId(Integer.parseInt(variantIds[i]));
                    item.setInitialQuantity(Integer.parseInt(quantities[i]));
                    item.setCostPrice(new java.math.BigDecimal(costPrices[i]));
                    item.setSalePrice(new java.math.BigDecimal(salePrices[i]));
                    item.setBatchCode(batchCode); // All rows share the same Batch Header reference

                    batchList.add(item);
                }

                // Trigger safe batch transaction service call
                boolean success = inventoryDAO.adminExecuteMultiStockImport(batchList, adminUserId, note);

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?action=list&status=success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?action=IMPORT_PAGE&status=error");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/inventory?action=IMPORT_PAGE&status=invalid");
            }
        }
    }
}
