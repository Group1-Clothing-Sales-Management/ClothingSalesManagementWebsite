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

        // Đồng bộ hóa chuỗi action khớp 100% với hidden input của Form
        if ("IMPORT".equals(action)) {
            HttpSession session = request.getSession();
            User loggedInUser = (User) session.getAttribute("user");
            int adminUserId = (loggedInUser != null) ? loggedInUser.getId() : 1;

            try {
                // Đọc chính xác bộ tham số tiếng Anh từ JSP gửi lên
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                BigDecimal costPrice = new BigDecimal(request.getParameter("costPrice"));
                BigDecimal salePrice = new BigDecimal(request.getParameter("salePrice"));
                String batchCode = request.getParameter("batchCode");
                String note = request.getParameter("note");

                ProductBatch newBatch = new ProductBatch();
                newBatch.setVariantId(variantId);
                newBatch.setBatchCode(batchCode);
                newBatch.setInitialQuantity(quantity);
                newBatch.setCostPrice(costPrice);
                newBatch.setSalePrice(salePrice);

                boolean success = inventoryDAO.adminExecuteStockImport(newBatch, adminUserId, note);

                // Tìm đoạn cuối của phương thức doPost trong AdminInventoryController.java
                if (success) {
                    // SỬA: Thay /admin/inventory thành /AdminInventory để đồng bộ
                    response.sendRedirect(request.getContextPath() + "/AdminInventory?action=list&status=success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/AdminInventory?action=IMPORT_PAGE&status=error");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/inventory?action=IMPORT_PAGE&status=invalid");
            }
        }
    }
}
