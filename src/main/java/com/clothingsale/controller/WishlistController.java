package com.clothingsale.controller;

import com.clothingsale.model.WishlistItem;
import com.clothingsale.service.WishlistService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "WishlistController", urlPatterns = {"/wishlist", "/wishlist/*"})
public class WishlistController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer userId = requireCustomer(request, response);
        if (userId == null) {
            return;
        }

        HttpSession session = request.getSession(false);
        List<WishlistItem> items = wishlistService.getWishlist(userId);
        request.setAttribute("wishlistItems", items);
        session.setAttribute("wishlistCount", items.size());

        moveFlash(session, request);

        request.getRequestDispatcher("/view/customer/customer_wishlist.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer userId = requireCustomer(request, response);
        if (userId == null) {
            return;
        }

        HttpSession session = request.getSession(false);
        String path = request.getPathInfo();
        String action = (path == null || "/".equals(path)) ? "add" : path.substring(1);

        boolean ok;
        switch (action) {
            case "add": {
                int productId = parsePositiveInt(request.getParameter("productId"));
                Integer variantId = parseNullablePositiveInt(request.getParameter("variantId"));
                ok = productId > 0 && wishlistService.addProduct(userId, productId, variantId);
                session.setAttribute("wishlistCount", wishlistService.countByUserId(userId));
                response.sendRedirect(buildReturnUrl(request,
                        ok ? "wishlistAdded=1" : "wishlistError=1"));
                return;
            }

            case "remove": {
                int productId = parsePositiveInt(request.getParameter("productId"));
                ok = productId > 0 && wishlistService.deleteProduct(userId, productId);
                session.setAttribute("wishlistCount", wishlistService.countByUserId(userId));
                response.sendRedirect(buildReturnUrl(request,
                        ok ? "wishlistRemoved=1" : "wishlistError=1"));
                return;
            }

            case "toggle": {
                int productId = parsePositiveInt(request.getParameter("productId"));
                Integer variantId = parseNullablePositiveInt(request.getParameter("variantId"));
                boolean wishlisted = "true".equalsIgnoreCase(request.getParameter("wishlisted"));

                if (wishlisted) {
                    ok = productId > 0 && wishlistService.deleteProduct(userId, productId);
                    session.setAttribute("wishlistCount", wishlistService.countByUserId(userId));
                    response.sendRedirect(buildReturnUrl(request,
                            ok ? "wishlistRemoved=1" : "wishlistError=1"));
                } else {
                    ok = productId > 0 && wishlistService.addProduct(userId, productId, variantId);
                    session.setAttribute("wishlistCount", wishlistService.countByUserId(userId));
                    response.sendRedirect(buildReturnUrl(request,
                            ok ? "wishlistAdded=1" : "wishlistError=1"));
                }
                return;
            }

            case "update": {
                int productId = parsePositiveInt(request.getParameter("productId"));
                int variantId = parsePositiveInt(request.getParameter("variantId"));
                ok = productId > 0 && variantId > 0
                        && wishlistService.updateProduct(userId, productId, variantId);
                setFlash(session, ok,
                        "Wishlist item updated.",
                        "Could not update this wishlist item.");
                break;
            }

            case "delete": {
                int productId = parsePositiveInt(request.getParameter("productId"));
                ok = productId > 0 && wishlistService.deleteProduct(userId, productId);
                setFlash(session, ok,
                        "Product removed from wishlist.",
                        "Could not remove this product from wishlist.");
                break;
            }

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
        }

        session.setAttribute("wishlistCount", wishlistService.countByUserId(userId));
        response.sendRedirect(request.getContextPath() + "/wishlist");
    }

    private Integer requireCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("authUserId") : null;
        Object roleObj = session != null ? session.getAttribute("authRoleName") : null;

        if (!(userIdObj instanceof Integer)) {
            response.sendRedirect(request.getContextPath()
                    + "/customer/login?error=unauthorized");
            return null;
        }

        String roleName = roleObj != null ? roleObj.toString() : "";
        if (!"CUSTOMER".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return (Integer) userIdObj;
    }

    private int parsePositiveInt(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : 0;
        } catch (Exception ex) {
            return 0;
        }
    }

    private Integer parseNullablePositiveInt(String value) {
        int parsed = parsePositiveInt(value);
        return parsed > 0 ? parsed : null;
    }

    private void setFlash(HttpSession session, boolean success,
            String successMessage, String errorMessage) {
        session.setAttribute("wishlistMessage", success ? successMessage : errorMessage);
        session.setAttribute("wishlistMessageType", success ? "success" : "danger");
    }

    private String buildReturnUrl(HttpServletRequest request, String statusParam) {
        String referer = request.getHeader("Referer");
        String contextPath = request.getContextPath();
        String fallback = contextPath + "/home";

        if (referer == null || referer.trim().isEmpty()) {
            return fallback + "?" + statusParam;
        }

        String localPrefix = request.getScheme() + "://"
                + request.getServerName()
                + (isDefaultPort(request) ? "" : ":" + request.getServerPort())
                + contextPath;

        if (!referer.startsWith(localPrefix)) {
            return fallback + "?" + statusParam;
        }

        int fragmentIndex = referer.indexOf('#');
        String fragment = fragmentIndex >= 0 ? referer.substring(fragmentIndex) : "";
        String base = fragmentIndex >= 0 ? referer.substring(0, fragmentIndex) : referer;
        String separator = base.contains("?") ? "&" : "?";

        return base + separator + statusParam + fragment;
    }

    private boolean isDefaultPort(HttpServletRequest request) {
        int port = request.getServerPort();
        return ("http".equalsIgnoreCase(request.getScheme()) && port == 80)
                || ("https".equalsIgnoreCase(request.getScheme()) && port == 443);
    }

    private void moveFlash(HttpSession session, HttpServletRequest request) {
        Object message = session.getAttribute("wishlistMessage");
        Object type = session.getAttribute("wishlistMessageType");

        if (message != null) {
            request.setAttribute("wishlistMessage", message.toString());
            request.setAttribute("wishlistMessageType",
                    type != null ? type.toString() : "info");
            session.removeAttribute("wishlistMessage");
            session.removeAttribute("wishlistMessageType");
        }
    }
}
