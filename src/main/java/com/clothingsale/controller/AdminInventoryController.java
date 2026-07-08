package com.clothingsale.controller;

import com.clothingsale.dao.AdminInventoryDAO;
import com.clothingsale.model.ProductBatch;
import com.clothingsale.model.ProductVariant;
import com.clothingsale.model.Supplier; // Cần import model Supplier
import com.clothingsale.model.User;
import java.io.IOException;
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
            action = "list";
        }

        if ("IMPORT_PAGE".equals(action)) {
            // Lấy danh sách biến thể
            List<ProductVariant> activeVariants = inventoryDAO.getAllActiveVariantsForImport();
            request.setAttribute("activeVariants", activeVariants);

            // TODO: Lấy danh sách nhà cung cấp (Giả định bạn đã thêm hàm getAllSuppliers trong DAO)
            // List<Supplier> supplierList = inventoryDAO.getAllSuppliers();
            // request.setAttribute("supplierList", supplierList);
            request.getRequestDispatcher("/view/admin/import_stock.jsp").forward(request, response);
        } else if ("list".equals(action)) {
            List<com.clothingsale.model.ProductBatch> history = inventoryDAO.adminGetImportHistory();
            request.setAttribute("importHistory", history);
            request.getRequestDispatcher("/view/admin/inventory_list.jsp").forward(request, response);
        } else {
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
                // Đọc thông tin Phiếu nhập tổng
                String supplierIdRaw = request.getParameter("supplierId");
                int supplierId = (supplierIdRaw != null && !supplierIdRaw.isEmpty()) ? Integer.parseInt(supplierIdRaw) : 1; // Mặc định 1 nếu trống
                String batchCode = request.getParameter("batchCode");
                String note = request.getParameter("note");

                // Đọc thông tin chi tiết Lô hàng
                String[] variantIds = request.getParameterValues("variantId[]");
                String[] quantities = request.getParameterValues("quantity[]");
                String[] costPrices = request.getParameterValues("costPrice[]");
                String[] salePrices = request.getParameterValues("salePrice[]");

                if (variantIds == null || variantIds.length == 0) {
                    response.sendRedirect(request.getContextPath() + "/admin/inventory?action=IMPORT_PAGE&status=invalid");
                    return;
                }

                java.util.List<ProductBatch> batchList = new java.util.ArrayList<>();
                double totalAmount = 0.0; // Tính tổng tiền phiếu nhập

                for (int i = 0; i < variantIds.length; i++) {
                    ProductBatch item = new ProductBatch();
                    item.setVariantId(Integer.parseInt(variantIds[i]));
                    item.setInitialQuantity(Integer.parseInt(quantities[i]));

                    double cost = Double.parseDouble(costPrices[i]);
                    item.setCostPrice(new java.math.BigDecimal(cost));
                    item.setSalePrice(new java.math.BigDecimal(salePrices[i]));
                    item.setBatchCode(batchCode);

                    batchList.add(item);

                    // Cộng dồn vào tổng tiền
                    totalAmount += (cost * item.getInitialQuantity());
                }

                // Gọi DAO với đầy đủ tham số mới
                boolean success = inventoryDAO.adminExecuteMultiStockImport(supplierId, adminUserId, totalAmount, note, batchList);

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
