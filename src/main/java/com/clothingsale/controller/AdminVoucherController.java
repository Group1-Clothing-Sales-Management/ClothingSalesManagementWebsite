package com.clothingsale.controller;

import com.clothingsale.model.Voucher;
import com.clothingsale.service.AdminVoucherService;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/voucher")
public class AdminVoucherController extends HttpServlet {

    private final AdminVoucherService voucherService = new AdminVoucherService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || "list".equals(action)) {
            String searchQuery = request.getParameter("search");
            String statusFilter = request.getParameter("status");

            List<Voucher> voucherList = voucherService.getAllVouchers(searchQuery, statusFilter);

            // Đọc thông báo lỗi/thành công chuyển tiếp từ Session (nếu có)
            String successMessage = (String) request.getSession().getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                request.getSession().removeAttribute("successMessage");
            }
            String errorMessage = (String) request.getSession().getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                request.getSession().removeAttribute("errorMessage");
            }

            request.setAttribute("voucherList", voucherList);
            request.getRequestDispatcher("/view/admin/admin_voucher_list.jsp").forward(request, response);
        } else if ("create".equals(action)) {
            request.getRequestDispatcher("/view/admin/admin_create_voucher.jsp").forward(request, response);
        } else if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Voucher voucher = voucherService.getVoucherById(id);
                if (voucher != null) {
                    // Lấy thêm số lượng khách đã thu thập từ DB
                    int totalSaved = voucherService.getTotalSavedCount(id);
                    
                    request.setAttribute("voucher", voucher);
                    request.setAttribute("totalSaved", totalSaved);
                    request.getRequestDispatcher("/view/admin/admin_voucher_detail.jsp").forward(request, response);
                } else {
                    request.getSession().setAttribute("errorMessage", "Voucher không tồn tại!");
                    response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            }
        }
        
        
        
        else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Voucher voucher = voucherService.getVoucherById(id);
                if (voucher != null) {
                    request.setAttribute("voucher", voucher);
                    request.getRequestDispatcher("/view/admin/admin_edit_voucher.jsp").forward(request, response);
                } else {
                    request.getSession().setAttribute("errorMessage", "Voucher not found!");
                    response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // NHÁNH XỬ LÝ: TIẾN TRÌNH DỪNG VOUCHER CÓ LỘ TRÌNH (GRACEFUL TERMINATION)
        if ("terminate".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                int daysLeft = Integer.parseInt(request.getParameter("daysLeft"));
                String reason = request.getParameter("reason");

                String result = voucherService.terminateVoucherEarly(id, daysLeft, reason);

                if ("SUCCESS".equals(result)) {
                    request.getSession().setAttribute("successMessage", "Voucher termination schedule updated successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", result);
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("errorMessage", "Error parsing termination payload values.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            return;
        }

        // NHÁNH XỬ LÝ: CREATE HOẶC UPDATE FORM THÔNG THƯỜNG
        String voucherIdStr = request.getParameter("id");
        boolean isUpdate = (voucherIdStr != null && !voucherIdStr.isEmpty());

        try {
            String code = request.getParameter("code");
            String title = request.getParameter("title");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            String minOrderValueStr = request.getParameter("minOrderValue");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String usageLimitStr = request.getParameter("usageLimit");

            BigDecimal discountValue = new BigDecimal(discountValueStr);
            BigDecimal minOrderValue = (minOrderValueStr == null || minOrderValueStr.isEmpty())
                    ? BigDecimal.ZERO : new BigDecimal(minOrderValueStr);

            BigDecimal maxDiscountAmount = null;
            if (maxDiscountAmountStr != null && !maxDiscountAmountStr.isEmpty()) {
                maxDiscountAmount = new BigDecimal(maxDiscountAmountStr);
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(sdf.parse(startDateStr).getTime());
            Timestamp endDate = new Timestamp(sdf.parse(endDateStr).getTime());
            int usageLimit = Integer.parseInt(usageLimitStr);

            Voucher voucher = new Voucher();
            voucher.setCode(code);
            voucher.setTitle(title);
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setMaxDiscountAmount(maxDiscountAmount);
            voucher.setMinOrderValue(minOrderValue);
            voucher.setStartDate(startDate);
            voucher.setEndDate(endDate);
            voucher.setUsageLimit(usageLimit);

            String result;
            if (isUpdate) {
                voucher.setId(Integer.parseInt(voucherIdStr));
                result = voucherService.updateVoucher(voucher);
            } else {
                result = voucherService.createVoucher(voucher);
            }

            if ("SUCCESS".equals(result)) {
                String msg = isUpdate ? "Voucher updated successfully!" : "Voucher created successfully!";
                request.getSession().setAttribute("successMessage", msg);
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            } else {
                request.setAttribute("errorMessage", result);
                if (isUpdate) {
                    request.setAttribute("voucher", voucher);
                    request.getRequestDispatcher("/view/admin/admin_edit_voucher.jsp").forward(request, response);
                } else {
                    request.setAttribute("oldVoucher", voucher);
                    request.getRequestDispatcher("/view/admin/admin_create_voucher.jsp").forward(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid format input patterns. Process rejected.");
            String path = isUpdate ? "/view/admin/admin_edit_voucher.jsp" : "/view/admin/admin_create_voucher.jsp";
            request.getRequestDispatcher(path).forward(request, response);
        }
    }
}
