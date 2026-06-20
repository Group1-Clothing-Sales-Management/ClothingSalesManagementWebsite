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
public class CustomerOrderController
        extends HttpServlet {

    private final CustomerOrderService service
            = new CustomerOrderService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");

            return;
        }

        int userId
                = (Integer) session.getAttribute(
                        "authUserId");

        boolean selectionMode
                = "1".equals(
                        request.getParameter(
                                "selectionMode"));

        Set<Integer> selectedVariantIds
                = selectionMode
                        ? parseSelectedVariantIds(
                                request.getParameterValues(
                                        "selectedVariantId"))
                        : getCheckoutSelectedVariantIds(session);

        List<CartItem> cartItems
                = service.getCartItems(
                        userId,
                        selectedVariantIds);

        if (cartItems.isEmpty()) {
            session.removeAttribute(
                    "checkoutSelectedVariantIds");
            session.setAttribute(
                    "cartMessage",
                    "Vui lòng chọn ít nhất một sản phẩm để thanh toán.");
            response.sendRedirect(
                    request.getContextPath()
                    + "/cart?skipMerge=1");

            return;
        }

        if (selectionMode) {
            session.setAttribute(
                    "checkoutSelectedVariantIds",
                    selectedVariantIds);
        }

        BigDecimal total
                = service.getCartTotal(
                        userId,
                        selectedVariantIds);

        List<UserAddress> addresses
                = service.getAddressesByUserId(userId);

        request.setAttribute(
                "addresses",
                addresses);
        request.setAttribute(
                "cartItems",
                cartItems);

        request.setAttribute(
                "cartTotal",
                total);

        request.getRequestDispatcher(
                "/view/customer/CustomerCheckout.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);
        if (session == null
                || session.getAttribute("authUserId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login");
            return;
        }

        int userId
                = (Integer) session.getAttribute(
                        "authUserId");

        int addressId;

        try {
            addressId = Integer.parseInt(
                    request.getParameter(
                            "addressId"));
        } catch (Exception ex) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid");

            return;
        }

        Set<Integer> selectedVariantIds
                = getCheckoutSelectedVariantIds(session);

        if (!service.validateCheckout(
                userId,
                selectedVariantIds)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=invalid");

            return;
        }

        String voucherCode
                = request.getParameter("voucherCode");

        String note
                = request.getParameter("note");

        boolean success
                = service.placeOrder(
                        userId,
                        addressId,
                        voucherCode,    
                        note,
                        selectedVariantIds);

        if (success) {
            pruneSessionCart(
                    session,
                    selectedVariantIds);
            session.removeAttribute(
                    "checkoutSelectedVariantIds");

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/orders");
        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/checkout?error=1");
        }
    }

    private Set<Integer> parseSelectedVariantIds(
            String[] values) {

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
            } catch (NumberFormatException ex) {
                // Ignore malformed checkbox values.
            }
        }

        return ids;
    }

    private Set<Integer> getCheckoutSelectedVariantIds(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object value = session.getAttribute(
                "checkoutSelectedVariantIds");

        if (!(value instanceof Iterable<?>)) {
            return null;
        }

        Set<Integer> ids = new HashSet<>();

        for (Object item : (Iterable<?>) value) {
            if (item instanceof Integer) {
                ids.add((Integer) item);
                continue;
            }

            if (item != null) {
                try {
                    ids.add(
                            Integer.parseInt(
                                    item.toString()));
                } catch (NumberFormatException ex) {
                    // Ignore malformed session values.
                }
            }
        }

        return ids;
    }

    private void pruneSessionCart(
            HttpSession session,
            Set<Integer> selectedVariantIds) {

        if (session == null) {
            return;
        }

        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof Map<?, ?>)) {
            return;
        }

        Map<?, ?> cart = (Map<?, ?>) cartObject;

        if (selectedVariantIds == null) {
            cart.clear();
            return;
        }

        for (Integer variantId : selectedVariantIds) {
            cart.remove(variantId);
        }
    }
}
