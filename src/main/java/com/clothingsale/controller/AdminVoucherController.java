package com.clothingsale.controller;

import com.clothingsale.model.Category;
import com.clothingsale.model.Voucher;
import com.clothingsale.service.AdminVoucherService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/admin/voucher")
public class AdminVoucherController extends HttpServlet {

    private static final String LIST_VIEW = "/view/admin/admin_voucher_list.jsp";
    private static final String CREATE_VIEW = "/view/admin/admin_create_voucher.jsp";
    private static final String EDIT_VIEW = "/view/admin/admin_edit_voucher.jsp";

    private final AdminVoucherService voucherService = new AdminVoucherService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = normalize(request.getParameter("action"));

        if (action.isEmpty() || "list".equals(action)) {
            showVoucherList(request, response);
            return;
        }

        if ("create".equals(action)) {
            request.setAttribute("categoryList", voucherService.getAllCategoriesSimple());
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            showEditForm(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = normalize(request.getParameter("action"));

        if ("terminate".equals(action)) {
            terminateVoucher(request, response);
            return;
        }

        saveVoucher(request, response);
    }

    private void showVoucherList(
            HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        String searchQuery = request.getParameter("search");
        String statusFilter = request.getParameter("status");

        request.setAttribute(
                "voucherList",
                voucherService.getAllVouchers(searchQuery, statusFilter)
        );

        moveFlashMessage(request, "successMessage");
        moveFlashMessage(request, "errorMessage");

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showEditForm(
            HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        Integer voucherId = parsePositiveInteger(request.getParameter("id"));
        Voucher voucher = voucherId == null
                ? null
                : voucherService.getVoucherById(voucherId);

        if (voucher == null) {
            request.getSession().setAttribute("errorMessage", "Voucher not found!");
            response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            return;
        }

        request.setAttribute("voucher", voucher);
        request.setAttribute("categoryList", voucherService.getAllCategoriesSimple());
        request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
    }

    private void terminateVoucher(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int daysLeft = Integer.parseInt(request.getParameter("daysLeft"));
            String reason = request.getParameter("reason");

            String result = voucherService.terminateVoucherEarly(id, daysLeft, reason);
            if ("SUCCESS".equals(result)) {
                request.getSession().setAttribute(
                        "successMessage",
                        "Voucher early termination scheduled successfully!"
                );
            } else {
                request.getSession().setAttribute("errorMessage", result);
            }
        } catch (Exception ex) {
            request.getSession().setAttribute(
                    "errorMessage",
                    "Invalid early termination payload data."
            );
        }

        response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
    }

    private void saveVoucher(
            HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        String requestedAction = normalize(request.getParameter("action"));
        String voucherIdValue = normalize(request.getParameter("id"));
        boolean isUpdate = "update".equals(requestedAction)
                || !voucherIdValue.isEmpty();
        Integer voucherId = parsePositiveInteger(voucherIdValue);

        if (isUpdate && voucherId == null) {
            request.getSession().setAttribute(
                    "errorMessage",
                    "Invalid voucher identifier."
            );
            response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
            return;
        }

        Voucher submittedVoucher = null;

        try {
            submittedVoucher = buildVoucherFromRequest(request);
            if (isUpdate) {
                submittedVoucher.setId(voucherId);
            }

            String result = isUpdate
                    ? voucherService.updateVoucher(submittedVoucher)
                    : voucherService.createVoucher(submittedVoucher);

            if ("SUCCESS".equals(result)) {
                request.getSession().setAttribute(
                        "successMessage",
                        isUpdate
                                ? "Voucher configuration updated successfully!"
                                : "New voucher campaign created successfully!"
                );
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
                return;
            }

            forwardVoucherForm(
                    request,
                    response,
                    submittedVoucher,
                    isUpdate,
                    result
            );
        } catch (Exception ex) {
            ex.printStackTrace();

            if (isUpdate && submittedVoucher == null) {
                submittedVoucher = voucherService.getVoucherById(voucherId);
            }

            forwardVoucherForm(
                    request,
                    response,
                    submittedVoucher,
                    isUpdate,
                    "Invalid data format detected. Please review your inputs."
            );
        }
    }

    private Voucher buildVoucherFromRequest(HttpServletRequest request) throws Exception {
        Voucher voucher = new Voucher();
        voucher.setCode(normalize(request.getParameter("code")).toUpperCase());
        voucher.setTitle(normalize(request.getParameter("title")));
        voucher.setDiscountType(normalize(request.getParameter("discountType")));
        voucher.setDiscountValue(parseRequiredMoney(request.getParameter("discountValue")));
        voucher.setMaxDiscountAmount(parseOptionalMoney(request.getParameter("maxDiscountAmount")));

        BigDecimal minimumEligibleSpend
                = parseOptionalMoney(request.getParameter("minOrderValue"));
        voucher.setMinOrderValue(
                minimumEligibleSpend == null
                        ? BigDecimal.ZERO
                        : minimumEligibleSpend
        );

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        dateFormat.setLenient(false);
        voucher.setStartDate(new Timestamp(
                dateFormat.parse(request.getParameter("startDate")).getTime()
        ));
        voucher.setEndDate(new Timestamp(
                dateFormat.parse(request.getParameter("endDate")).getTime()
        ));

        voucher.setUsageLimit(Integer.parseInt(request.getParameter("usageLimit")));

        Integer perUserLimit = parsePositiveInteger(request.getParameter("limitPerUser"));
        voucher.setLimitPerUser(perUserLimit == null ? 1 : perUserLimit);

        String scopeType = normalize(request.getParameter("scopeType"));
        if ("CATEGORY".equalsIgnoreCase(scopeType)) {
            voucher.setCategoryId(
                    parsePositiveInteger(request.getParameter("parentCategoryId"))
            );
            voucher.setSelectedCategoryIds(
                    parseCategoryIds(request.getParameterValues("categoryIds"))
            );
        } else {
            voucher.setCategoryId(null);
            voucher.setSelectedCategoryIds(new ArrayList<>());
        }

        return voucher;
    }

    private List<Integer> parseCategoryIds(String[] values) {
        Set<Integer> uniqueIds = new LinkedHashSet<>();
        if (values == null) {
            return new ArrayList<>();
        }

        for (String value : values) {
            Integer id = parsePositiveInteger(value);
            if (id != null) {
                uniqueIds.add(id);
            }
        }

        return new ArrayList<>(uniqueIds);
    }

    private void forwardVoucherForm(
            HttpServletRequest request,
            HttpServletResponse response,
            Voucher submittedVoucher,
            boolean isUpdate,
            String errorMessage) throws ServletException, IOException {

        List<Category> categoryList = voucherService.getAllCategoriesSimple();
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("errorMessage", errorMessage);

        if (isUpdate) {
            Voucher voucherForForm = enrichEditVoucher(
                    submittedVoucher,
                    categoryList
            );

            if (voucherForForm == null) {
                request.getSession().setAttribute("errorMessage", errorMessage);
                response.sendRedirect(request.getContextPath() + "/admin/voucher?action=list");
                return;
            }

            request.setAttribute("voucher", voucherForForm);
            request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
            return;
        }

        request.setAttribute(
                "oldVoucher",
                submittedVoucher == null ? new Voucher() : submittedVoucher
        );
        request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
    }

    private Voucher enrichEditVoucher(
            Voucher submittedVoucher,
            List<Category> categoryList) {

        if (submittedVoucher == null || submittedVoucher.getId() <= 0) {
            return null;
        }

        Voucher storedVoucher = voucherService.getVoucherById(submittedVoucher.getId());
        if (storedVoucher == null) {
            return null;
        }

        submittedVoucher.setUsedCount(storedVoucher.getUsedCount());
        submittedVoucher.setTerminateReason(storedVoucher.getTerminateReason());
        submittedVoucher.setUserUsedCount(storedVoucher.getUserUsedCount());

        if (submittedVoucher.getCategoryId() == null) {
            submittedVoucher.setCategoryName(null);
            submittedVoucher.setCategoryParentId(null);
            submittedVoucher.setCategoryHasChildren(false);
            submittedVoucher.setCategoryScopeActive(true);
            return submittedVoucher;
        }

        Category selectedParent = findRootCategory(
                categoryList,
                submittedVoucher.getCategoryId()
        );

        if (selectedParent != null) {
            submittedVoucher.setCategoryName(selectedParent.getCategoryName());
            submittedVoucher.setCategoryParentId(null);
            submittedVoucher.setCategoryHasChildren(selectedParent.isHasChildren());
            submittedVoucher.setCategoryScopeActive(selectedParent.getStatus() == 1);
            submittedVoucher.setSelectedCategoryNames(
                    resolveSelectedCategoryNames(
                            categoryList,
                            submittedVoucher.getSelectedCategoryIds()
                    )
            );
        } else {
            submittedVoucher.setCategoryName(storedVoucher.getCategoryName());
            submittedVoucher.setCategoryParentId(storedVoucher.getCategoryParentId());
            submittedVoucher.setCategoryHasChildren(storedVoucher.isCategoryHasChildren());
            submittedVoucher.setCategoryScopeActive(storedVoucher.isCategoryScopeActive());
        }

        return submittedVoucher;
    }

    private List<String> resolveSelectedCategoryNames(
            List<Category> roots,
            List<Integer> selectedIds) {

        List<String> names = new ArrayList<>();
        if (roots == null || selectedIds == null || selectedIds.isEmpty()) {
            return names;
        }

        Set<Integer> selectedSet = new LinkedHashSet<>(selectedIds);
        for (Category root : roots) {
            if (selectedSet.contains(root.getId())) {
                names.add(root.getCategoryName());
            }
            for (Category child : root.getChildren()) {
                if (selectedSet.contains(child.getId())) {
                    names.add(child.getCategoryName());
                }
            }
        }
        return names;
    }

    private Category findRootCategory(List<Category> roots, int categoryId) {
        if (roots == null) {
            return null;
        }

        for (Category root : roots) {
            if (root.getId() == categoryId) {
                return root;
            }
        }

        return null;
    }

    private BigDecimal parseRequiredMoney(String value) {
        return new BigDecimal(normalize(value));
    }

    private BigDecimal parseOptionalMoney(String value) {
        String normalized = normalize(value);
        return normalized.isEmpty() ? null : new BigDecimal(normalized);
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsed = Integer.parseInt(normalize(value));
            return parsed > 0 ? parsed : null;
        } catch (Exception ex) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private void moveFlashMessage(HttpServletRequest request, String attributeName) {
        Object message = request.getSession().getAttribute(attributeName);
        if (message != null) {
            request.setAttribute(attributeName, message);
            request.getSession().removeAttribute(attributeName);
        }
    }
}