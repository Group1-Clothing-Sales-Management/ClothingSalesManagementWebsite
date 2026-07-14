package com.clothingsale.controller;

import com.clothingsale.model.PriceManagementItem;
import com.clothingsale.service.AdminPriceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Locale;

@WebServlet(name = "AdminPriceController", urlPatterns = {"/AdminPrice", "/admin/prices"})
public class AdminPriceController extends HttpServlet {

    private final AdminPriceService priceService = new AdminPriceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (requireAdmin(request, response) == null) {
            return;
        }

        moveFlashMessageToRequest(request);
        String action = normalizeAction(request.getParameter("action"), "list");

        try {
            switch (action) {
                case "edit":
                    showEditPage(request, response);
                    break;
                case "list":
                    showPriceList(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/prices");
                    break;
            }
        } catch (IllegalArgumentException | IllegalStateException exception) {
            setFlashMessage(request, "error", exception.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/prices");
        } catch (RuntimeException exception) {
            log("Unable to load price management page.", exception);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load price data.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer adminId = requireAdmin(request, response);
        if (adminId == null) {
            return;
        }

        String action = normalizeAction(request.getParameter("action"), "");
        String rawVariantId = request.getParameter("variantId");

        try {
            if (!"update".equals(action)) {
                throw new IllegalArgumentException("Unsupported price action.");
            }

            updatePrice(request, response, adminId);

        } catch (IllegalArgumentException | IllegalStateException exception) {
            setFlashMessage(request, "error", exception.getMessage());
            redirectAfterUpdate(request, response, rawVariantId);

        } catch (RuntimeException exception) {
            log("Unable to update product price.", exception);
            setFlashMessage(request, "error", "The price could not be updated. No partial change was saved.");
            redirectAfterUpdate(request, response, rawVariantId);
        }
    }

    private void showPriceList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String priceStatus = request.getParameter("priceStatus");

        request.setAttribute("priceItems", priceService.searchPrices(keyword, priceStatus));
        request.setAttribute("keyword", keyword == null ? "" : keyword.trim());
        request.setAttribute("selectedPriceStatus", normalizePriceStatus(priceStatus));

        request.getRequestDispatcher("/view/admin/price_management.jsp").forward(request, response);
    }

    private void showEditPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int variantId = parsePositiveInt(request.getParameter("id"), "Product variant");
        PriceManagementItem priceItem = priceService.getPriceByVariantId(variantId);

        request.setAttribute("priceItem", priceItem);
        request.setAttribute("priceHistory", priceService.getPriceHistory(variantId));

        request.getRequestDispatcher("/view/admin/price_edit.jsp").forward(request, response);
    }

    private void updatePrice(HttpServletRequest request, HttpServletResponse response, int adminId)
            throws IOException {

        int variantId = parsePositiveInt(request.getParameter("variantId"), "Product variant");
        BigDecimal listPrice = parseMoney(request.getParameter("listPrice"), "List price");
        BigDecimal salePrice = parseMoney(request.getParameter("salePrice"), "Sale price");
        String reason = request.getParameter("reason");

        priceService.updatePrice(variantId, listPrice, salePrice, reason, adminId);

        setFlashMessage(request, "success", "Product price updated successfully.");
        response.sendRedirect(request.getContextPath() + "/admin/prices?action=edit&id=" + variantId);
    }

    private Integer requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return null;
        }

        Object userIdObject = session.getAttribute("authUserId");
        Object roleObject = session.getAttribute("authRoleName");

        if (userIdObject == null || roleObject == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return null;
        }

        if (!"ADMIN".equalsIgnoreCase(roleObject.toString())) {
            response.sendRedirect(request.getContextPath() + "/admin/login?error=forbidden");
            return null;
        }

        try {
            if (userIdObject instanceof Number) {
                return ((Number) userIdObject).intValue();
            }

            return Integer.parseInt(userIdObject.toString());
        } catch (NumberFormatException exception) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized");
            return null;
        }
    }

    private int parsePositiveInt(String rawValue, String fieldName) {
        try {
            int value = Integer.parseInt(rawValue == null ? "" : rawValue.trim());

            if (value <= 0) {
                throw new NumberFormatException();
            }

            return value;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }

    private BigDecimal parseMoney(String rawValue, String fieldName) {
        String value = rawValue == null ? "" : rawValue.trim();

        if (!value.matches("\\d+(\\.\\d{1,2})?")) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }

        try {
            return new BigDecimal(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }

    private String normalizeAction(String action, String defaultAction) {
        if (action == null || action.trim().isEmpty()) {
            return defaultAction;
        }

        return action.trim().toLowerCase(Locale.ROOT);
    }

    private String normalizePriceStatus(String priceStatus) {
        if (priceStatus == null || priceStatus.trim().isEmpty()) {
            return "ALL";
        }

        String value = priceStatus.trim().toUpperCase(Locale.ROOT);

        switch (value) {
            case "UNPRICED":
            case "BELOW_COST":
            case "DISCOUNTED":
            case "REGULAR":
                return value;
            default:
                return "ALL";
        }
    }

    private void redirectAfterUpdate(HttpServletRequest request, HttpServletResponse response, String rawVariantId)
            throws IOException {

        if (rawVariantId != null && rawVariantId.matches("\\d+") && Integer.parseInt(rawVariantId) > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/prices?action=edit&id=" + rawVariantId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/prices");
    }

    private void setFlashMessage(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("priceFlashType", type);
        session.setAttribute("priceFlashMessage", message);
    }

    private void moveFlashMessageToRequest(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return;
        }

        Object type = session.getAttribute("priceFlashType");
        Object message = session.getAttribute("priceFlashMessage");

        if (type != null && message != null) {
            request.setAttribute("priceFlashType", type);
            request.setAttribute("priceFlashMessage", message);
            session.removeAttribute("priceFlashType");
            session.removeAttribute("priceFlashMessage");
        }
    }
}