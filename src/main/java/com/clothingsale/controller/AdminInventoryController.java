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

@WebServlet(name = "AdminInventoryController", urlPatterns = {"/AdminInventory","/admin/inventory"})
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
            case "IMPORT_PAGE": // Tải trang giao diện nhập kho lô hàng mới
                List<com.clothingsale.model.ProductVariant> activeVariants = inventoryDAO.getAllActiveVariantsForImport();
                List<ProductBatch> batchesLog = inventoryDAO.adminGetImportHistory();

                // Đồng bộ tên danh sách với vòng lặp trong file import_stock.jsp
                request.setAttribute("variants", activeVariants);
                request.setAttribute("batches", batchesLog);

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

        // Khớp 100% với thuộc tính action="... action=IMPORT" của Form import_stock.jsp
        if ("IMPORT".equals(action)) {
            HttpSession session = request.getSession();
            User loggedInUser = (User) session.getAttribute("user");

            // Lấy ID của Admin đang thực hiện tác vụ nhập hàng
            int adminUserId = (loggedInUser != null) ? loggedInUser.getId() : 1;

            try {
                // Trích xuất các tham số từ Form import_stock.jsp gửi lên
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int qty = Integer.parseInt(request.getParameter("initialQuantity"));
                BigDecimal costPrice = new BigDecimal(request.getParameter("costPrice"));
                String batchMemo = request.getParameter("batchMemo");

                // Tạo mã lô hàng tự động (Ví dụ: BATCH-171932312) để tránh việc Admin gõ tay trùng lặp
                String generatedBatchCode = "BATCH-" + System.currentTimeMillis();

                // Đóng gói mô hình đối tượng ProductBatch phục vụ mô hình FIFO
                ProductBatch newBatch = new ProductBatch();
                newBatch.setVariantId(variantId);
                newBatch.setBatchCode(generatedBatchCode);
                newBatch.setInitialQuantity(qty);
                newBatch.setCurrentQuantity(qty); // Ban đầu lượng hiện tại bằng lượng nhập gốc
                newBatch.setCostPrice(costPrice);

                // Thực thi ghi nhận lô hàng và kích hoạt nghiệp vụ tăng lũy tiến tồn kho tổng của Variant
                boolean success = inventoryDAO.adminExecuteStockImport(newBatch, adminUserId, batchMemo);

                if (success) {
                    // Thành công quay về chính trang nhập kho kèm theo trạng thái thông báo
                    response.sendRedirect(request.getContextPath() + "/AdminInventory?action=IMPORT_PAGE&status=success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/AdminInventory?action=IMPORT_PAGE&status=error");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/AdminInventory?action=IMPORT_PAGE&status=invalid");
            }
        }
    }
}
