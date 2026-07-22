package com.clothingsale.controller;

import com.clothingsale.dao.CartDAO;
import com.clothingsale.dao.CustomerProductDAO;
import com.clothingsale.model.CartItem;
import com.clothingsale.model.ProductVariant;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.StringJoiner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.URLEncoder;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CartController", urlPatterns = {"/cart", "/cart/*"})
public class CartController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CartController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        LOGGER.log(Level.FINE, "[CartController] doGet - sessionId={0}, requestURI={1}", new Object[]{session != null ? session.getId() : "null", request.getRequestURI()});
        String path = request.getPathInfo(); // null or /action
        String action = (path == null || "/".equals(path)) ? "view" : path.replaceFirst("/", "");

        // Only 'view' is supported via GET for now
        if ("view".equalsIgnoreCase(action)) {
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            if (cart == null) {
                cart = new HashMap<>();
                session.setAttribute("cart", cart);
            }
            CartDAO cartDAO = new CartDAO();

            LOGGER.log(Level.FINE, "[CartController] GET view - session cart before merge: {0}", cartSummary(cart));

            // merge persisted cart for authenticated users (skip when immediate redirect after POST)
            Object authUserIdObj = session.getAttribute("authUserId");
            String skipMerge = request.getParameter("skipMerge");
            boolean shouldSkipMerge = "1".equals(skipMerge) || "true".equalsIgnoreCase(skipMerge);
            if (authUserIdObj instanceof Integer) {
                int userId = (Integer) authUserIdObj;
                try {
                    Map<Integer, CartItem> dbCart = cartDAO.loadCart(userId);
                    LOGGER.log(Level.FINE, "[CartController] Loaded persisted cart for user {0}: {1}", new Object[]{userId, cartSummary(dbCart)});
                    if (!shouldSkipMerge && dbCart != null && !dbCart.isEmpty()) {
                        for (CartItem dbItem : dbCart.values()) {
                            CartItem existing = cart.get(dbItem.getVariantId());
                            if (existing == null) {
                                cart.put(dbItem.getVariantId(), dbItem);
                            } else {
                                // if both session and DB have same item, avoid double-counting by taking the max
                                int mergedQty = Math.max(existing.getQuantity(), dbItem.getQuantity());
                                existing.setQuantity(mergedQty);
                            }
                        }
                        try {
                            cartDAO.saveCart(userId, cart);
                            LOGGER.log(Level.FINE, "[CartController] Persisted merged cart for user {0}: {1}", new Object[]{userId, cartSummary(cart)});
                        } catch (Exception ex) {
                            LOGGER.log(Level.WARNING, "[CartController] Failed saving merged cart for user " + userId, ex);
                        }
                        session.setAttribute("cart", cart);
                    }
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "[CartController] Error loading persisted cart for user " + userId, ex);
                }
            }

            boolean refreshedFromDatabase = refreshCartItems(cart, cartDAO);
            boolean adjustedToStock = syncCartWithStock(cart, cartDAO);

            if (refreshedFromDatabase || adjustedToStock) {
                persistCart(session, response, cart, authUserIdObj);

                if (adjustedToStock
                        && session.getAttribute("cartMessage") == null) {

                    session.setAttribute("cartMessage",
                            "Some cart quantities were adjusted to match available stock.");
                }

                session.setAttribute("cart", cart);
            }

            // flash message support: move from session to request
            HttpSession sess = request.getSession(false);
            if (sess != null) {
                Object msg = sess.getAttribute("cartMessage");
                if (msg != null) {
                    request.setAttribute("cartMessage", msg.toString());
                    sess.removeAttribute("cartMessage");
                }
            }
            Collection<CartItem> items = cart.values();
            Set<Integer> productIds = new HashSet<>();
            CustomerProductDAO productDAO = new CustomerProductDAO();
            for (CartItem item : items) {
                if (item != null && item.getProductId() > 0) {
                    productIds.add(item.getProductId());
                }
            }
            Map<Integer, List<ProductVariant>> variantsByProductId
                    = productDAO.getVariantsByProductIds(new ArrayList<>(productIds));
            request.setAttribute("items", items);
            request.setAttribute("variantsByProductId", variantsByProductId);
            request.getRequestDispatcher("/view/cart.jsp").forward(request, response);
            return;
        }

        // fallback redirect to view
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        LOGGER.log(Level.FINE, "[CartController] doPost - sessionId={0}, requestURI={1}", new Object[]{session != null ? session.getId() : "null", request.getRequestURI()});
        String path = request.getPathInfo();
        String action = (path == null || "/".equals(path)) ? "add" : path.replaceFirst("/", "");

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
            session.setAttribute("cart", cart);
        }

        // log incoming action and parameters
        LOGGER.log(Level.FINE, "[CartController] POST action={0}", action);
        StringJoiner paramsJoiner = new StringJoiner(", ");
        for (Map.Entry<String, String[]> e : request.getParameterMap().entrySet()) {
            String key = e.getKey();
            String[] vals = e.getValue();
            paramsJoiner.add(key + "=" + (vals == null ? "null" : java.util.Arrays.toString(vals)));
        }
        LOGGER.log(Level.FINE, "[CartController] Request params: {0}", paramsJoiner.toString());
        LOGGER.log(Level.FINE, "[CartController] Session cart before modification: {0}", cartSummary(cart));

        Object authUserIdObj = null;

        switch (action) {
            case "add": {
                int variantId = parsePositiveInt(
                        request.getParameter("variantId")
                );

                int quantity = parsePositiveInt(
                        request.getParameter("quantity")
                );

                if (quantity <= 0) {
                    quantity = 1;
                }

                if (variantId <= 0) {
                    session.setAttribute(
                            "cartMessage",
                            "Please select a valid product variant."
                    );

                    response.sendRedirect(
                            buildAddToCartRedirect(request, false)
                    );
                    return;
                }

                CartDAO dao = new CartDAO();
                CartItem databaseItem
                        = dao.getActiveVariantCartItem(variantId);

                int stock = dao.getAvailableStock(variantId);

                if (databaseItem == null || stock <= 0) {
                    session.setAttribute(
                            "cartMessage",
                            "This item is unavailable or out of stock."
                    );

                    response.sendRedirect(
                            buildAddToCartRedirect(request, false)
                    );
                    return;
                }

                CartItem existingItem = cart.get(variantId);
                int newQuantity = quantity;

                if (existingItem != null) {
                    newQuantity = Math.max(
                            0,
                            existingItem.getQuantity()
                    ) + quantity;
                }

                if (newQuantity > stock) {
                    session.setAttribute(
                            "cartMessage",
                            "Only " + stock
                            + " item(s) are available in stock."
                    );

                    response.sendRedirect(
                            buildAddToCartRedirect(request, false)
                    );
                    return;
                }

                if (existingItem == null) {
                    databaseItem.setQuantity(newQuantity);
                    cart.put(variantId, databaseItem);
                } else {
                    copyAuthoritativeData(
                            existingItem,
                            databaseItem
                    );
                    existingItem.setQuantity(newQuantity);
                }

                session.setAttribute(
                        "cartMessage",
                        "Item added to your cart."
                );

                LOGGER.log(
                        Level.FINE,
                        "[CartController] Cart after add: {0}",
                        cartSummary(cart)
                );

                authUserIdObj = session.getAttribute("authUserId");

                if (authUserIdObj instanceof Integer) {
                    int userId = (Integer) authUserIdObj;

                    try {
                        dao.saveCart(userId, cart);

                        LOGGER.log(
                                Level.FINE,
                                "[CartController] Persisted cart for user {0} after add: {1}",
                                new Object[]{userId, cartSummary(cart)}
                        );
                    } catch (Exception ex) {
                        LOGGER.log(
                                Level.WARNING,
                                "[CartController] Failed saving cart for user "
                                + userId + " after add",
                                ex
                        );
                    }
                } else {
                    writeAnonCartCookie(response, cart);
                }

                response.sendRedirect(
                        buildAddToCartRedirect(request, true)
                );
                break;
            }

            case "buyNow": {
                int variantId = parsePositiveInt(
                        request.getParameter("variantId")
                );

                int quantity = parsePositiveInt(
                        request.getParameter("quantity")
                );

                if (quantity <= 0) {
                    quantity = 1;
                }

                if (variantId <= 0) {
                    session.setAttribute(
                            "cartMessage",
                            "Please select a valid product variant."
                    );

                    response.sendRedirect(
                            buildAddToCartRedirect(request, false)
                    );
                    return;
                }

                CartDAO dao = new CartDAO();
                CartItem databaseItem
                        = dao.getActiveVariantCartItem(variantId);

                int stock = dao.getAvailableStock(variantId);

                if (databaseItem == null || stock <= 0) {
                    session.setAttribute(
                            "cartMessage",
                            "This item is unavailable or out of stock."
                    );

                    response.sendRedirect(
                            buildAddToCartRedirect(request, false)
                    );
                    return;
                }

                if (quantity > stock) {
                    quantity = stock;
                }

                databaseItem.setQuantity(quantity);

                List<CartItem> buyNowItems
                        = new ArrayList<>();

                buyNowItems.add(databaseItem);
                session.setAttribute(
                        "buyNowItems",
                        buyNowItems
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/customer/checkout?buyNow=1"
                );
                return;
            }

            case "update": {
                int variantId = parsePositiveInt(
                        request.getParameter("variantId")
                );

                String newVariantIdRaw
                        = request.getParameter("newVariantId");

                int newVariantId = parsePositiveInt(
                        newVariantIdRaw == null
                        || newVariantIdRaw.isBlank()
                        ? request.getParameter("variantId")
                        : newVariantIdRaw
                );

                int quantity = parseInteger(
                        request.getParameter("quantity"),
                        1
                );

                CartItem currentItem = cart.get(variantId);

                if (currentItem == null) {
                    session.setAttribute(
                            "cartMessage",
                            "The cart item no longer exists."
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/cart?skipMerge=1"
                    );
                    return;
                }

                if (quantity <= 0) {
                    cart.remove(variantId);

                    session.setAttribute(
                            "cartMessage",
                            "Item removed from your cart."
                    );
                } else {
                    CartDAO dao = new CartDAO();

                    CartItem databaseItem
                            = dao.getActiveVariantCartItem(
                                    newVariantId
                            );

                    int stock = dao.getAvailableStock(
                            newVariantId
                    );

                    if (databaseItem == null || stock <= 0) {
                        session.setAttribute(
                                "cartMessage",
                                "The selected variant is unavailable."
                        );

                        response.sendRedirect(
                                request.getContextPath()
                                + "/cart"
                        );
                        return;
                    }

                    if (newVariantId != variantId
                            && cart.containsKey(newVariantId)) {

                        CartItem target
                                = cart.get(newVariantId);

                        int mergedQuantity
                                = Math.max(
                                        0,
                                        target.getQuantity()
                                ) + quantity;

                        if (mergedQuantity > stock) {
                            session.setAttribute(
                                    "cartMessage",
                                    "Only " + stock
                                    + " item(s) are available in stock."
                            );

                            response.sendRedirect(
                                    request.getContextPath()
                                    + "/cart"
                            );
                            return;
                        }

                        copyAuthoritativeData(
                                target,
                                databaseItem
                        );

                        target.setQuantity(mergedQuantity);
                        cart.remove(variantId);
                    } else {
                        if (quantity > stock) {
                            session.setAttribute(
                                    "cartMessage",
                                    "Only " + stock
                                    + " item(s) are available in stock."
                            );

                            response.sendRedirect(
                                    request.getContextPath()
                                    + "/cart"
                            );
                            return;
                        }

                        databaseItem.setQuantity(quantity);

                        if (newVariantId != variantId) {
                            cart.remove(variantId);
                        }

                        cart.put(
                                newVariantId,
                                databaseItem
                        );
                    }

                    session.setAttribute(
                            "cartMessage",
                            "Cart updated successfully."
                    );
                }

                LOGGER.log(
                        Level.FINE,
                        "[CartController] Cart after update: {0}",
                        cartSummary(cart)
                );

                authUserIdObj = session.getAttribute("authUserId");

                if (authUserIdObj instanceof Integer) {
                    int userId = (Integer) authUserIdObj;

                    try {
                        new CartDAO().saveCart(userId, cart);

                        LOGGER.log(
                                Level.FINE,
                                "[CartController] Persisted cart for user {0} after update: {1}",
                                new Object[]{userId, cartSummary(cart)}
                        );
                    } catch (Exception ex) {
                        LOGGER.log(
                                Level.WARNING,
                                "[CartController] Failed saving cart for user "
                                + userId + " after update",
                                ex
                        );
                    }
                } else {
                    writeAnonCartCookie(response, cart);
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/cart?skipMerge=1"
                );
                break;
            }

            case "remove": {
                String variantIdStr = request.getParameter("variantId");
                int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
                cart.remove(variantId);

                session.setAttribute("cartMessage",
                        "Item removed from your cart.");

                LOGGER.log(Level.FINE, "[CartController] Cart after remove: {0}", cartSummary(cart));

                authUserIdObj = session.getAttribute("authUserId");
                if (authUserIdObj instanceof Integer) {
                    int userId = (Integer) authUserIdObj;
                    try {
                        new CartDAO().saveCart(userId, cart);
                        LOGGER.log(Level.FINE, "[CartController] Persisted cart for user {0} after remove: {1}", new Object[]{userId, cartSummary(cart)});
                    } catch (Exception ex) {
                        LOGGER.log(Level.WARNING, "[CartController] Failed saving cart for user " + userId + " after remove", ex);
                    }
                } else {
                    writeAnonCartCookie(response, cart);
                }

                response.sendRedirect(request.getContextPath() + "/cart?skipMerge=1");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private boolean refreshCartItems(
            Map<Integer, CartItem> cart,
            CartDAO dao) {

        if (cart == null || cart.isEmpty()) {
            return false;
        }

        boolean changed = false;

        Iterator<Map.Entry<Integer, CartItem>> iterator
                = cart.entrySet().iterator();

        while (iterator.hasNext()) {
            Map.Entry<Integer, CartItem> entry
                    = iterator.next();

            CartItem currentItem = entry.getValue();

            if (currentItem == null
                    || currentItem.getVariantId() <= 0) {

                iterator.remove();
                changed = true;
                continue;
            }

            CartItem databaseItem
                    = dao.getActiveVariantCartItem(
                            currentItem.getVariantId()
                    );

            if (databaseItem == null) {
                iterator.remove();
                changed = true;
                continue;
            }

            if (!hasSameAuthoritativeData(
                    currentItem,
                    databaseItem
            )) {
                copyAuthoritativeData(
                        currentItem,
                        databaseItem
                );

                changed = true;
            }
        }

        return changed;
    }

    private boolean hasSameAuthoritativeData(
            CartItem currentItem,
            CartItem databaseItem) {

        return currentItem.getProductId()
                == databaseItem.getProductId()
                && Objects.equals(
                        currentItem.getProductName(),
                        databaseItem.getProductName()
                )
                && Objects.equals(
                        currentItem.getAttributes(),
                        databaseItem.getAttributes()
                )
                && Objects.equals(
                        currentItem.getPrice(),
                        databaseItem.getPrice()
                )
                && Objects.equals(
                        currentItem.getImageUrl(),
                        databaseItem.getImageUrl()
                )
                && Objects.equals(
                        currentItem.getColor(),
                        databaseItem.getColor()
                )
                && Objects.equals(
                        currentItem.getSize(),
                        databaseItem.getSize()
                );
    }

    private void copyAuthoritativeData(
            CartItem target,
            CartItem source) {

        target.setVariantId(source.getVariantId());
        target.setProductId(source.getProductId());
        target.setProductName(source.getProductName());
        target.setAttributes(source.getAttributes());
        target.setPrice(source.getPrice());
        target.setImageUrl(source.getImageUrl());
        target.setColor(source.getColor());
        target.setSize(source.getSize());
    }

    private int parsePositiveInt(String value) {
        int parsedValue = parseInteger(value, 0);
        return parsedValue > 0 ? parsedValue : 0;
    }

    private int parseInteger(
            String value,
            int defaultValue) {

        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static String cartSummary(Map<Integer, CartItem> cart) {
        if (cart == null || cart.isEmpty()) {
            return "[]";
        }
        StringJoiner joiner = new StringJoiner(" | ");
        for (CartItem it : cart.values()) {
            String name = it.getProductName() == null ? "(null)" : it.getProductName();
            String img = it.getImageUrl() == null ? "(no-image)" : it.getImageUrl();
            joiner.add("v:" + it.getVariantId() + ", p:" + it.getProductId() + ", q:" + it.getQuantity() + ", name:" + name + ", img:" + img);
        }
        return "[" + joiner.toString() + "]";
    }

    private boolean syncCartWithStock(Map<Integer, CartItem> cart, CartDAO dao) {
        if (cart == null || cart.isEmpty()) {
            return false;
        }

        boolean changed = false;
        Set<Integer> variantIds = new HashSet<>();
        for (CartItem item : cart.values()) {
            if (item != null && item.getVariantId() > 0) {
                variantIds.add(item.getVariantId());
            }
        }
        Map<Integer, Integer> stocksByVariantId = dao.getAvailableStockByVariantIds(variantIds);
        Iterator<Map.Entry<Integer, CartItem>> iterator = cart.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Integer, CartItem> entry = iterator.next();
            CartItem item = entry.getValue();
            if (item == null) {
                iterator.remove();
                changed = true;
                continue;
            }

            int stock = stocksByVariantId.getOrDefault(item.getVariantId(), 0);
            if (stock <= 0) {
                iterator.remove();
                changed = true;
                continue;
            }

            if (item.getQuantity() < 1) {
                item.setQuantity(1);
                changed = true;
            }

            if (item.getQuantity() > stock) {
                item.setQuantity(stock);
                changed = true;
            }
        }

        return changed;
    }

    private void persistCart(HttpSession session, HttpServletResponse response,
            Map<Integer, CartItem> cart, Object authUserIdObj) {
        if (authUserIdObj instanceof Integer) {
            int userId = (Integer) authUserIdObj;
            try {
                new CartDAO().saveCart(userId, cart);
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "[CartController] Failed saving stock-adjusted cart for user " + userId, ex);
            }
            return;
        }

        writeAnonCartCookie(response, cart);
    }

    private String buildAddToCartRedirect(HttpServletRequest request, boolean success) {
        String referer = request.getHeader("Referer");
        String contextPath = request.getContextPath();
        String target = (referer != null && !referer.trim().isEmpty())
                ? referer
                : contextPath + "/home";
        String separator = target.contains("?") ? "&" : "?";
        return target + separator + (success ? "cartAdded=1" : "cartError=1");
    }

    // Anonymous cart cookie helpers
    private Map<Integer, CartItem> readAnonCartCookie(HttpServletRequest request) {
        Map<Integer, CartItem> result = new HashMap<>();
        if (request.getCookies() == null) {
            return result;
        }
        for (Cookie c : request.getCookies()) {
            if ("anonCart".equals(c.getName())) {
                String val = c.getValue();
                if (val == null || val.isEmpty()) {
                    return result;
                }
                try {
                    String decoded = URLDecoder.decode(val, StandardCharsets.UTF_8.name());
                    String[] items = decoded.split("\\|");
                    for (String item : items) {
                        if (item.trim().isEmpty()) {
                            continue;
                        }
                        String[] f = item.split("\\^", -1);
                        int variantId = Integer.parseInt(f[0]);
                        int productId = Integer.parseInt(f[1]);
                        int quantity = Integer.parseInt(f[2]);
                        java.math.BigDecimal price = java.math.BigDecimal.ZERO;
                        try {
                            price = new java.math.BigDecimal(f[3]);
                        } catch (Exception ex) {
                        }
                        String productName = f.length > 4 ? URLDecoder.decode(f[4], StandardCharsets.UTF_8.name()) : "";
                        String imageUrl = f.length > 5 ? URLDecoder.decode(f[5], StandardCharsets.UTF_8.name()) : "";
                        String attributes = f.length > 6 ? URLDecoder.decode(f[6], StandardCharsets.UTF_8.name()) : "";

                        CartItem it = new CartItem();
                        it.setVariantId(variantId);
                        it.setProductId(productId);
                        it.setQuantity(quantity);
                        it.setPrice(price);
                        it.setProductName(productName);
                        it.setImageUrl(imageUrl);
                        it.setAttributes(attributes);
                        result.put(variantId, it);
                    }
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "[CartController] Failed to parse anonCart cookie", ex);
                }
            }
        }
        return result;
    }

    private void writeAnonCartCookie(HttpServletResponse response, Map<Integer, CartItem> cart) {
        if (cart == null) {
            cart = new HashMap<>();
        }
        StringJoiner sj = new StringJoiner("|");
        for (CartItem it : cart.values()) {
            StringBuilder b = new StringBuilder();
            b.append(it.getVariantId()).append('^');
            b.append(it.getProductId()).append('^');
            b.append(it.getQuantity()).append('^');
            b.append(it.getPrice() != null ? it.getPrice().toString() : "0").append('^');
            b.append(it.getProductName() != null ? URLEncoder.encode(it.getProductName(), StandardCharsets.UTF_8) : "").append('^');
            b.append(it.getImageUrl() != null ? URLEncoder.encode(it.getImageUrl(), StandardCharsets.UTF_8) : "").append('^');
            b.append(it.getAttributes() != null ? URLEncoder.encode(it.getAttributes(), StandardCharsets.UTF_8) : "");
            sj.add(b.toString());
        }
        try {
            String encoded = URLEncoder.encode(sj.toString(), StandardCharsets.UTF_8.name());
            Cookie c = new Cookie("anonCart", encoded);
            c.setPath("/");
            c.setHttpOnly(false);
            c.setMaxAge(7 * 24 * 3600); // 7 days
            response.addCookie(c);
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "[CartController] Failed to write anonCart cookie", ex);
        }
    }
}