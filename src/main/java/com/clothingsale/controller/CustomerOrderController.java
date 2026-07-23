package com.clothingsale.controller;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Voucher;
import com.clothingsale.service.CustomerOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/customer/checkout")
public class CustomerOrderController extends HttpServlet {

    private static final String CHECKOUT_VIEW = "/view/customer/customer_checkout.jsp";
    private static final BigDecimal SHIPPING_FEE = BigDecimal.valueOf(30000);

    private final CustomerOrderService service = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAuthenticated(session)) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        int userId = (Integer) session.getAttribute("authUserId");
        boolean buyNow = "1".equals(request.getParameter("buyNow"));
        boolean selectionMode = "1".equals(request.getParameter("selectionMode"));

        if (buyNow) {
            session.setAttribute("checkoutBuyNow", Boolean.TRUE);
        } else {
            session.removeAttribute("checkoutBuyNow");
        }

        Set<Integer> selectedVariantIds = selectionMode
                ? parseSelectedVariantIds(request.getParameterValues("selectedVariantId"))
                : getCheckoutSelectedVariantIds(session);

        if (selectionMode) {
            session.setAttribute("checkoutSelectedVariantIds", selectedVariantIds);
        }

        List<CartItem> cartItems = loadCheckoutItems(
                session,
                userId,
                buyNow,
                selectedVariantIds
        );

        if (cartItems.isEmpty()) {
            redirectEmptyCheckout(request, response, session);
            return;
        }

        BigDecimal cartTotal = calculateCartTotal(cartItems);

        renderCheckoutPage(
                request,
                response,
                userId,
                cartItems,
                cartTotal,
                request.getParameter("voucherCode"),
                null,
                null,
                null,
                null,
                null
        );
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAuthenticated(session)) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        int userId = (Integer) session.getAttribute("authUserId");
        boolean buyNow = Boolean.TRUE.equals(
                session.getAttribute("checkoutBuyNow")
        );

        Set<Integer> selectedVariantIds = buyNow
                ? null
                : getCheckoutSelectedVariantIds(session);

        List<CartItem> cartItems = loadCheckoutItems(
                session,
                userId,
                buyNow,
                selectedVariantIds
        );

        if (cartItems.isEmpty()) {
            redirectEmptyCheckout(request, response, session);
            return;
        }

        BigDecimal cartTotal = calculateCartTotal(cartItems);
        String action = trimToEmpty(request.getParameter("action"));

        String selectedAddressId = trimToNull(request.getParameter("selectedAddressId"));
        String selectedCarrierName = trimToNull(request.getParameter("selectedCarrierName"));
        String selectedPaymentMethod = trimToNull(request.getParameter("selectedPaymentMethod"));
        String checkoutNote = request.getParameter("checkoutNote");

        if ("applyVoucher".equals(action)) {
            renderCheckoutPage(
                    request,
                    response,
                    userId,
                    cartItems,
                    cartTotal,
                    request.getParameter("voucherCode"),
                    selectedAddressId,
                    selectedCarrierName,
                    selectedPaymentMethod,
                    checkoutNote,
                    null
            );
            return;
        }

        if (!"placeOrder".equals(action)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid checkout action."
            );
            return;
        }

        int addressId;
        try {
            addressId = Integer.parseInt(request.getParameter("addressId"));
        } catch (Exception ex) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid_address"
            );
            return;
        }

        UserAddress selectedAddress = service.getAddressById(addressId);
        if (selectedAddress == null || selectedAddress.getUserId() != userId) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid_address"
            );
            return;
        }

        if (cartTotal.compareTo(BigDecimal.ZERO) <= 0) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid_checkout"
            );
            return;
        }

        String voucherCode = trimToNull(request.getParameter("voucherCode"));
        String voucherError = validateVoucher(userId, voucherCode, cartTotal);

        if (voucherError != null) {
            request.setAttribute("voucherError", voucherError);
            renderCheckoutPage(
                    request,
                    response,
                    userId,
                    cartItems,
                    cartTotal,
                    voucherCode,
                    String.valueOf(addressId),
                    request.getParameter("carrierName"),
                    request.getParameter("paymentMethod"),
                    request.getParameter("note"),
                    null
            );
            return;
        }

        String note = request.getParameter("note");
        String paymentMethod = defaultIfBlank(
                request.getParameter("paymentMethod"),
                "COD"
        );
        String carrierName = defaultIfBlank(
                request.getParameter("carrierName"),
                "GHN"
        );

        boolean success;
        if (buyNow) {
            success = service.placeBuyNowOrder(
                    userId,
                    addressId,
                    voucherCode,
                    note,
                    paymentMethod,
                    carrierName,
                    cartItems
            );
        } else {
            success = service.placeOrder(
                    userId,
                    addressId,
                    voucherCode,
                    note,
                    paymentMethod,
                    carrierName,
                    selectedVariantIds
            );
        }

        if (success) {
            if (buyNow) {
                session.removeAttribute("buyNowItems");
                session.removeAttribute("checkoutBuyNow");
            } else {
                pruneSessionCart(session, selectedVariantIds);
                session.removeAttribute("checkoutSelectedVariantIds");
            }

            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        renderCheckoutPage(
                request,
                response,
                userId,
                cartItems,
                cartTotal,
                voucherCode,
                String.valueOf(addressId),
                carrierName,
                paymentMethod,
                note,
                "Unable to place the order. Stock, voucher, or checkout data may have changed. Please review and try again."
        );
    }

    private void renderCheckoutPage(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId,
            List<CartItem> cartItems,
            BigDecimal cartTotal,
            String requestedVoucherCode,
            String selectedAddressId,
            String selectedCarrierName,
            String selectedPaymentMethod,
            String checkoutNote,
            String checkoutError)
            throws ServletException, IOException {

        BigDecimal discount = BigDecimal.ZERO;
        String voucherCode = trimToNull(requestedVoucherCode);
        Voucher voucher = null;

        if (voucherCode != null) {
            voucher = service.getAvailableVoucherForUser(userId, voucherCode);

            if (voucher == null) {
                if (request.getAttribute("voucherError") == null) {
                    request.setAttribute(
                            "voucherError",
                            "Voucher does not exist, has expired, reached its limit, or has already been used."
                    );
                }
            } else if (cartTotal.compareTo(safeMoney(voucher.getMinOrderValue())) < 0) {
                if (request.getAttribute("voucherError") == null) {
                    request.setAttribute(
                            "voucherError",
                            "The order value does not meet this voucher's minimum spending requirement."
                    );
                }
                voucher = null;
            } else {
                discount = service.calculateDiscount(cartTotal, voucher);
                request.setAttribute("voucher", voucher);
            }
        }

        BigDecimal totalPayment = cartTotal
                .subtract(discount)
                .add(SHIPPING_FEE)
                .max(BigDecimal.ZERO);

        request.setAttribute("addresses", service.getAddressesByUserId(userId));
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("shippingFee", SHIPPING_FEE);
        request.setAttribute("discountAmount", discount);
        request.setAttribute("totalPayment", totalPayment);
        request.setAttribute("voucherCode", voucher != null ? voucher.getCode() : null);
        request.setAttribute("customerVouchers", service.getVouchersForUser(userId));
        request.setAttribute("suggestedVouchers", service.getEligibleVouchers(userId, cartTotal));

        request.setAttribute("selectedAddressId", selectedAddressId);
        request.setAttribute(
                "selectedCarrierName",
                defaultIfBlank(selectedCarrierName, "GHN")
        );
        request.setAttribute(
                "selectedPaymentMethod",
                defaultIfBlank(selectedPaymentMethod, "COD")
        );
        request.setAttribute("checkoutNote", checkoutNote == null ? "" : checkoutNote);

        if (checkoutError != null && !checkoutError.trim().isEmpty()) {
            request.setAttribute("checkoutError", checkoutError);
        }

        request.getRequestDispatcher(CHECKOUT_VIEW).forward(request, response);
    }

    private String validateVoucher(int userId, String voucherCode, BigDecimal cartTotal) {
        if (voucherCode == null) {
            return null;
        }

        Voucher voucher = service.getAvailableVoucherForUser(userId, voucherCode);
        if (voucher == null) {
            return "The selected voucher is no longer available. Please choose another voucher.";
        }

        if (cartTotal.compareTo(safeMoney(voucher.getMinOrderValue())) < 0) {
            return "The order value does not meet this voucher's minimum spending requirement.";
        }

        return null;
    }

    private boolean isAuthenticated(HttpSession session) {
        return session != null && session.getAttribute("authUserId") instanceof Integer;
    }

    private List<CartItem> loadCheckoutItems(
            HttpSession session,
            int userId,
            boolean buyNow,
            Set<Integer> selectedVariantIds) {

        if (!buyNow) {
            List<CartItem> items = service.getCartItems(userId, selectedVariantIds);
            return items == null ? Collections.emptyList() : items;
        }

        Object value = session.getAttribute("buyNowItems");
        if (!(value instanceof List<?>)) {
            return Collections.emptyList();
        }

        List<CartItem> items = new ArrayList<>();
        for (Object item : (List<?>) value) {
            if (item instanceof CartItem) {
                items.add((CartItem) item);
            }
        }
        return items;
    }

    private BigDecimal calculateCartTotal(List<CartItem> cartItems) {
        BigDecimal total = BigDecimal.ZERO;

        if (cartItems == null) {
            return total;
        }

        for (CartItem item : cartItems) {
            if (item == null || item.getPrice() == null || item.getQuantity() <= 0) {
                continue;
            }

            total = total.add(
                    item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))
            );
        }

        return total;
    }

    private void redirectEmptyCheckout(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session) throws IOException {

        session.removeAttribute("checkoutSelectedVariantIds");
        session.setAttribute(
                "cartMessage",
                "Please select at least one product to check out."
        );
        response.sendRedirect(request.getContextPath() + "/cart?skipMerge=1");
    }

    private Set<Integer> parseSelectedVariantIds(String[] values) {
        Set<Integer> ids = new HashSet<>();
        if (values == null) {
            return ids;
        }

        for (String value : values) {
            try {
                int id = Integer.parseInt(value);
                if (id > 0) {
                    ids.add(id);
                }
            } catch (Exception ignored) {
            }
        }
        return ids;
    }

    private Set<Integer> getCheckoutSelectedVariantIds(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("checkoutSelectedVariantIds");
        if (!(value instanceof Iterable<?>)) {
            return null;
        }

        Set<Integer> ids = new HashSet<>();
        for (Object item : (Iterable<?>) value) {
            try {
                ids.add(Integer.parseInt(item.toString()));
            } catch (Exception ignored) {
            }
        }
        return ids;
    }

    private void pruneSessionCart(HttpSession session, Set<Integer> selectedVariantIds) {
        if (session == null) {
            return;
        }

        Object cartObj = session.getAttribute("cart");
        if (!(cartObj instanceof Map<?, ?>)) {
            return;
        }

        Map<?, ?> cart = (Map<?, ?>) cartObj;
        if (selectedVariantIds == null) {
            cart.clear();
            return;
        }

        for (Integer id : selectedVariantIds) {
            cart.remove(id);
        }
    }

    private String defaultIfBlank(String value, String defaultValue) {
        return value == null || value.trim().isEmpty()
                ? defaultValue
                : value.trim();
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String trimToNull(String value) {
        String normalized = trimToEmpty(value);
        return normalized.isEmpty() ? null : normalized;
    }

    private BigDecimal safeMoney(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}