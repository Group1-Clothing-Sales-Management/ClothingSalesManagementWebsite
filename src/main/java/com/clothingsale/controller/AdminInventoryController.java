package com.clothingsale.controller;

import com.clothingsale.model.ImportReceipt;
import com.clothingsale.model.ImportReceiptDetail;
import com.clothingsale.model.User;
import com.clothingsale.service.AdminInventoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(
        name = "AdminInventoryController",
        urlPatterns = {
            "/AdminInventory",
            "/admin/inventory"
        }
)
public class AdminInventoryController extends HttpServlet {

    private final AdminInventoryService inventoryService
            = new AdminInventoryService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        Integer authenticatedUserId
                = requireAuthenticatedUser(request, response);

        if (authenticatedUserId == null) {
            return;
        }

        moveFlashMessageToRequest(request);

        String action = normalizeAction(
                request.getParameter("action"),
                "list"
        );

        try {
            switch (action) {
                case "IMPORT_PAGE":
                    showCreateReceiptPage(
                            request,
                            response
                    );
                    break;

                case "DETAIL":
                    showReceiptDetail(
                            request,
                            response
                    );
                    break;

                case "list":
                    showReceiptList(
                            request,
                            response
                    );
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/inventory?action=list"
                    );
                    break;
            }

        } catch (IllegalArgumentException exception) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    exception.getMessage()
            );

        } catch (RuntimeException exception) {
            log(
                    "Unable to load inventory page.",
                    exception
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load inventory data."
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer authenticatedUserId
                = requireAuthenticatedUser(request, response);

        if (authenticatedUserId == null) {
            return;
        }

        String action = normalizeAction(
                request.getParameter("action"),
                ""
        );

        try {
            switch (action) {
                case "CREATE_DRAFT":
                    createDraftReceipt(
                            request,
                            response,
                            authenticatedUserId
                    );
                    break;

                case "CONFIRM_RECEIPT":
                    confirmReceipt(
                            request,
                            response,
                            authenticatedUserId
                    );
                    break;

                case "CANCEL_DRAFT":
                    cancelDraft(
                            request,
                            response
                    );
                    break;

                default:
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Unsupported inventory action."
                    );
                    break;
            }

        } catch (IllegalArgumentException
                | IllegalStateException exception) {
            setFlashMessage(
                    request,
                    "error",
                    exception.getMessage()
            );

            redirectBackToReceiptContext(
                    request,
                    response
            );

        } catch (Exception exception) {
            log(
                    "Inventory operation failed.",
                    exception
            );

            setFlashMessage(
                    request,
                    "error",
                    "The inventory operation could not "
                    + "be completed. No partial update was saved."
            );

            redirectBackToReceiptContext(
                    request,
                    response
            );
        }
    }

    private void showCreateReceiptPage(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute(
                "activeVariants",
                inventoryService.getImportableVariants()
        );

        request.setAttribute(
                "supplierList",
                inventoryService.getActiveSuppliers()
        );

        request.getRequestDispatcher(
                "/view/admin/import_stock.jsp"
        ).forward(request, response);
    }

    private void showReceiptList(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute(
                "receipts",
                inventoryService.getReceipts()
        );

        request.getRequestDispatcher(
                "/view/admin/inventory_list.jsp"
        ).forward(request, response);
    }

    private void showReceiptDetail(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        int receiptId = parsePositiveInt(
                request.getParameter("id"),
                "Receipt ID"
        );

        ImportReceipt receipt
                = inventoryService.getReceipt(receiptId);

        if (receipt == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Stock receipt not found."
            );
            return;
        }

        request.setAttribute("receipt", receipt);

        request.setAttribute(
                "receiptDetails",
                inventoryService.getReceiptDetails(receiptId)
        );

        request.getRequestDispatcher(
                "/view/admin/inventory_receipt_detail.jsp"
        ).forward(request, response);
    }

    private void createDraftReceipt(
            HttpServletRequest request,
            HttpServletResponse response,
            int authenticatedUserId
    ) throws Exception {

        int supplierId = parsePositiveInt(
                request.getParameter("supplierId"),
                "Supplier"
        );

        String vendorReference
                = request.getParameter("vendorReference");

        String note
                = request.getParameter("note");

        String[] variantIds
                = request.getParameterValues("variantId[]");

        String[] quantities
                = request.getParameterValues("quantity[]");

        String[] unitCosts
                = request.getParameterValues("unitCost[]");

        validateParallelArrays(
                variantIds,
                quantities,
                unitCosts
        );

        List<ImportReceiptDetail> details
                = new ArrayList<>();

        for (int index = 0;
                index < variantIds.length;
                index++) {

            ImportReceiptDetail detail
                    = new ImportReceiptDetail();

            detail.setVariantId(
                    parsePositiveInt(
                            variantIds[index],
                            "Product variant"
                    )
            );

            detail.setQuantity(
                    parsePositiveInt(
                            quantities[index],
                            "Quantity"
                    )
            );

            detail.setUnitCost(
                    parseMoney(
                            unitCosts[index],
                            "Unit cost"
                    )
            );

            details.add(detail);
        }

        int receiptId = inventoryService.createDraft(
                supplierId,
                authenticatedUserId,
                vendorReference,
                note,
                details
        );

        setFlashMessage(
                request,
                "success",
                "Draft receipt created. Review the "
                + "details before posting inventory."
        );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/inventory?action=DETAIL&id="
                + receiptId
        );
    }

    private void confirmReceipt(
            HttpServletRequest request,
            HttpServletResponse response,
            int authenticatedUserId
    ) throws Exception {

        int receiptId = parsePositiveInt(
                request.getParameter("receiptId"),
                "Receipt ID"
        );

        inventoryService.confirmReceipt(
                receiptId,
                authenticatedUserId
        );

        setFlashMessage(
                request,
                "success",
                "Receipt confirmed. Product batches were "
                + "created and inventory was increased."
        );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/inventory?action=DETAIL&id="
                + receiptId
        );
    }

    private void cancelDraft(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws Exception {

        int receiptId = parsePositiveInt(
                request.getParameter("receiptId"),
                "Receipt ID"
        );

        inventoryService.cancelDraft(receiptId);

        setFlashMessage(
                request,
                "success",
                "Draft receipt cancelled. "
                + "Inventory was not changed."
        );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/inventory?action=DETAIL&id="
                + receiptId
        );
    }

    private Integer requireAuthenticatedUser(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/login?error=unauthorized"
            );
            return null;
        }

        Object userIdObject
                = session.getAttribute("authUserId");

        Object roleObject
                = session.getAttribute("authRoleName");

        if (userIdObject == null || roleObject == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/login?error=unauthorized"
            );
            return null;
        }

        String roleName = roleObject.toString();

        if (!"ADMIN".equalsIgnoreCase(roleName)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/login?error=forbidden"
            );
            return null;
        }

        try {
            if (userIdObject instanceof Number) {
                return ((Number) userIdObject).intValue();
            }

            return Integer.valueOf(userIdObject.toString());

        } catch (NumberFormatException exception) {
            session.invalidate();

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/login?error=unauthorized"
            );

            return null;
        }
    }

    private void redirectBackToReceiptContext(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        String receiptId
                = request.getParameter("receiptId");

        if (receiptId != null
                && receiptId.matches("\\d+")) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/inventory?action=DETAIL&id="
                    + receiptId
            );

        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/inventory?action=IMPORT_PAGE"
            );
        }
    }

    private static void validateParallelArrays(
            String[] variantIds,
            String[] quantities,
            String[] unitCosts
    ) {
        if (variantIds == null
                || quantities == null
                || unitCosts == null
                || variantIds.length == 0
                || variantIds.length != quantities.length
                || variantIds.length != unitCosts.length) {

            throw new IllegalArgumentException(
                    "The receipt item data is incomplete."
            );
        }
    }

    private static int parsePositiveInt(
            String rawValue,
            String fieldName
    ) {
        try {
            int value = Integer.parseInt(
                    rawValue == null
                            ? ""
                            : rawValue.trim()
            );

            if (value <= 0) {
                throw new NumberFormatException();
            }

            return value;

        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(
                    fieldName + " is invalid."
            );
        }
    }

    private static BigDecimal parseMoney(
            String rawValue,
            String fieldName
    ) {
        try {
            return new BigDecimal(
                    rawValue == null
                            ? ""
                            : rawValue.trim()
            );

        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(
                    fieldName + " is invalid."
            );
        }
    }

    private static String normalizeAction(
            String action,
            String defaultAction
    ) {
        if (action == null || action.trim().isEmpty()) {
            return defaultAction;
        }

        return action.trim();
    }

    private static void setFlashMessage(
            HttpServletRequest request,
            String type,
            String message
    ) {
        HttpSession session = request.getSession();

        session.setAttribute(
                "inventoryFlashType",
                type
        );

        session.setAttribute(
                "inventoryFlashMessage",
                message
        );
    }

    private static void moveFlashMessageToRequest(
            HttpServletRequest request
    ) {
        HttpSession session
                = request.getSession(false);

        if (session == null) {
            return;
        }

        Object type
                = session.getAttribute(
                        "inventoryFlashType"
                );

        Object message
                = session.getAttribute(
                        "inventoryFlashMessage"
                );

        if (type != null && message != null) {
            request.setAttribute(
                    "inventoryFlashType",
                    type
            );

            request.setAttribute(
                    "inventoryFlashMessage",
                    message
            );

            session.removeAttribute(
                    "inventoryFlashType"
            );

            session.removeAttribute(
                    "inventoryFlashMessage"
            );
        }
    }
}
