package com.clothingsale.controller;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.UserAddress;
import com.clothingsale.service.CustomerOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/customer/checkout")
public class CustomerOrderController extends HttpServlet {

    private final CustomerOrderService service = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        int userId = (Integer) session.getAttribute("authUserId");

        boolean selectionMode = "1".equals(request.getParameter("selectionMode"));

        Set<Integer> selectedVariantIds
                = selectionMode
                        ? parseSelectedVariantIds(request.getParameterValues("selectedVariantId"))
                        : getCheckoutSelectedVariantIds(session);

        List<CartItem> cartItems
                = service.getCartItems(userId, selectedVariantIds);

        if (cartItems.isEmpty()) {
            session.removeAttribute("checkoutSelectedVariantIds");
            session.setAttribute("cartMessage",
                    "Please select at least one product to check out.");

            response.sendRedirect(request.getContextPath() + "/cart?skipMerge=1");
            return;
        }

        if (selectionMode) {
            session.setAttribute("checkoutSelectedVariantIds", selectedVariantIds);
        }
        List<UserAddress> addresses
                = service.getAddressesByUserId(userId);

        BigDecimal total
                = service.getCartTotal(userId, selectedVariantIds);

        BigDecimal shippingFee = BigDecimal.valueOf(30000);
        BigDecimal discount = BigDecimal.ZERO;
        String voucherCode = request.getParameter("voucherCode");

        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            var voucher = service.getAvailableVoucherForUser(userId, voucherCode.trim());

            if (voucher == null) {
                request.setAttribute("voucherError",
                        "Voucher không tồn tại, đã hết hạn hoặc đã được sử dụng.");
                request.setAttribute("voucherCode", voucherCode.trim());
            } else if (total.compareTo(voucher.getMinOrderValue()) < 0) {
                request.setAttribute("voucherError",
                        "Đơn hàng chưa đủ điều kiện áp dụng voucher này.");
                request.setAttribute("voucherCode", voucherCode.trim());
            } else {
                discount = service.calculateDiscount(total, voucher);
                request.setAttribute("voucherCode", voucherCode.trim());
                request.setAttribute("discountAmount", discount);
                request.setAttribute("voucher", voucher);
            }
        }

        BigDecimal totalPayment = total.subtract(discount).add(shippingFee);

        request.setAttribute("addresses", addresses);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", total);
        request.setAttribute("shippingFee", shippingFee);
        request.setAttribute("discountAmount", discount);
        request.setAttribute("totalPayment", totalPayment);
        request.setAttribute("customerVouchers", service.getVouchersForUser(userId));
        request.setAttribute("suggestedVouchers", service.getEligibleVouchers(userId, total));

        request.getRequestDispatcher(
                "/view/customer/customer_checkout.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        int userId = (Integer) session.getAttribute("authUserId");

        Set<Integer> selectedVariantIds
                = getCheckoutSelectedVariantIds(session);

        List<CartItem> cartItems
                = service.getCartItems(userId, selectedVariantIds);

        BigDecimal cartTotal
                = service.getCartTotal(userId, selectedVariantIds);

        List<UserAddress> addresses
                = service.getAddressesByUserId(userId);

        String action = request.getParameter("action");

        // ================= APPLY VOUCHER =================
        if ("applyVoucher".equals(action)) {

            String voucherCode = request.getParameter("voucherCode");

            BigDecimal discount = BigDecimal.ZERO;

            if (voucherCode != null && !voucherCode.trim().isEmpty()) {

                var voucher = service.getAvailableVoucherForUser(userId, voucherCode.trim());

                if (voucher == null) {

                    request.setAttribute("voucherError",
                            "Voucher không tồn tại, đã hết hạn hoặc đã được sử dụng.");
                    request.setAttribute("voucherCode", voucherCode.trim());

                } else if (cartTotal.compareTo(voucher.getMinOrderValue()) < 0) {

                    request.setAttribute("voucherError",
                            "Đơn hàng chưa đủ điều kiện áp dụng voucher này.");
                    request.setAttribute("voucherCode", voucherCode.trim());

                } else {

                    discount
                            = service.calculateDiscount(cartTotal, voucher);

                    request.setAttribute("voucherCode", voucherCode);
                    request.setAttribute("discountAmount", discount);
                    request.setAttribute("voucher", voucher);
                }
            }

            request.setAttribute("addresses", addresses);
            request.setAttribute("cartItems", cartItems);
            request.setAttribute("cartTotal", cartTotal);
            request.setAttribute("shippingFee", BigDecimal.valueOf(30000));
            request.setAttribute("totalPayment",
                    cartTotal.subtract(discount)
                            .add(BigDecimal.valueOf(30000)));
            request.setAttribute("customerVouchers", service.getVouchersForUser(userId));
            request.setAttribute("suggestedVouchers", service.getEligibleVouchers(userId, cartTotal));

            request.getRequestDispatcher(
                    "/view/customer/customer_checkout.jsp")
                    .forward(request, response);

            return;
        }

        // ================= PLACE ORDER =================
        int addressId;

        try {
            addressId
                    = Integer.parseInt(request.getParameter("addressId"));
        } catch (Exception e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid_address");

            return;
        }

        if (!service.validateCheckout(userId, selectedVariantIds)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid_checkout");

            return;
        }

        String voucherCode
                = request.getParameter("voucherCode");

        String note
                = request.getParameter("note");

        String paymentMethod
                = request.getParameter("paymentMethod");

        String carrierName
                = request.getParameter("carrierName");

        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = "COD";
        }

        if (carrierName == null || carrierName.isEmpty()) {
            carrierName = "GHN";
        }

        boolean success
                = service.placeOrder(
                        userId,
                        addressId,
                        voucherCode,
                        note,
                        paymentMethod,
                        carrierName,
                        selectedVariantIds);

        if (success) {

            pruneSessionCart(session, selectedVariantIds);

            session.removeAttribute("checkoutSelectedVariantIds");

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders");

        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=failed");
        }
    }

    // ===== HELPERS =====
    private Set<Integer> parseSelectedVariantIds(String[] values) {
        Set<Integer> ids = new HashSet<>();
        if (values == null) {
            return ids;
        }

        for (String v : values) {
            try {
                int id = Integer.parseInt(v);
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

        for (Object o : (Iterable<?>) value) {
            try {
                ids.add(Integer.parseInt(o.toString()));
            } catch (Exception ignored) {
            }
        }

        return ids;
    }

    private void pruneSessionCart(HttpSession session,
            Set<Integer> selectedVariantIds) {

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
}
