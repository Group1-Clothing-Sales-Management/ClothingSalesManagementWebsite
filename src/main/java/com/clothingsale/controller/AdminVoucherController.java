package com.clothingsale.controller;

import com.clothingsale.model.Voucher;
import com.clothingsale.model.Category;
import com.clothingsale.service.AdminVoucherService;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/admin/voucher")
public class AdminVoucherController extends HttpServlet {

    private final AdminVoucherService voucherService = new AdminVoucherService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        List<Category> categoryList = voucherService.getAllCategoriesSimple();
        request.setAttribute("categoryList", categoryList);

        if (action == null || "list".equals(action)) {
            String searchQuery = request.getParameter("search");
            String statusFilter = request.getParameter("status");
            List<Voucher> voucherList = voucherService.getAllVouchers(searchQuery, statusFilter);

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
        } else if ("edit".equals(action)) {
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

        if ("terminate".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                int daysLeft = Integer.parseInt(request.getParameter("daysLeft"));
                String reason = request.getParameter("reason");

                String result = voucherService.terminateVoucherEarly(id, daysLeft, reason);
                if ("SUCCESS".equals(result)) {
                    request.getSession().setAttribute("successMessage", "Voucher early termination scheduled successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", result);
                }
            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Invalid early termination payload data.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            return;
        }

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
            String limitPerUserStr = request.getParameter("limitPerUser");
            String categoryIdStr = request.getParameter("categoryId");

            BigDecimal discountValue = new BigDecimal(discountValueStr);
            BigDecimal minOrderValue = (minOrderValueStr == null || minOrderValueStr.isEmpty()) ? BigDecimal.ZERO : new BigDecimal(minOrderValueStr);
            BigDecimal maxDiscountAmount = (maxDiscountAmountStr != null && !maxDiscountAmountStr.isEmpty()) ? new BigDecimal(maxDiscountAmountStr) : null;

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(sdf.parse(startDateStr).getTime());
            Timestamp endDate = new Timestamp(sdf.parse(endDateStr).getTime());
            int usageLimit = Integer.parseInt(usageLimitStr);

            // XỬ LÝ FIX LỖI DATA CŨ: Nếu NULL hoặc <= 0, tự động ép về 1
            int limitPerUser = 1;
            if (limitPerUserStr != null && !limitPerUserStr.trim().isEmpty()) {
                limitPerUser = Integer.parseInt(limitPerUserStr);
                if (limitPerUser <= 0) {
                    limitPerUser = 1;
                }
            }

            Integer categoryId = (categoryIdStr == null || categoryIdStr.isEmpty() || "ALL".equals(categoryIdStr)) ? null : Integer.parseInt(categoryIdStr);

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
            voucher.setLimitPerUser(limitPerUser);
            voucher.setCategoryId(categoryId);

            String result;
            if (isUpdate) {
                voucher.setId(Integer.parseInt(voucherIdStr));
                result = voucherService.updateVoucher(voucher);
            } else {
                result = voucherService.createVoucher(voucher);
            }

            if ("SUCCESS".equals(result)) {
                String msg = isUpdate ? "Voucher configuration updated successfully!" : "New voucher campaign created successfully!";
                request.getSession().setAttribute("successMessage", msg);
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            } else {
                request.setAttribute("errorMessage", result);
                List<Category> categoryList = voucherService.getAllCategoriesSimple();
                request.setAttribute("categoryList", categoryList);

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
            request.setAttribute("errorMessage", "Invalid data format detected. Please review your inputs.");
            List<Category> categoryList = voucherService.getAllCategoriesSimple();
            request.setAttribute("categoryList", categoryList);
            String path = isUpdate ? "/view/admin/admin_edit_voucher.jsp" : "/view/admin/admin_create_voucher.jsp";
            request.getRequestDispatcher(path).forward(request, response);
        }
    }
}
