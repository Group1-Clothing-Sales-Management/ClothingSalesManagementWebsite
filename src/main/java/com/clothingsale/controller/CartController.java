package com.clothingsale.controller;

import com.clothingsale.dao.CartDAO;
import com.clothingsale.model.CartItem;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
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

			LOGGER.log(Level.FINE, "[CartController] GET view - session cart before merge: {0}", cartSummary(cart));

			// merge persisted cart for authenticated users (skip when immediate redirect after POST)
			Object authUserIdObj = session.getAttribute("authUserId");
			String skipMerge = request.getParameter("skipMerge");
			boolean shouldSkipMerge = "1".equals(skipMerge) || "true".equalsIgnoreCase(skipMerge);
			if (authUserIdObj instanceof Integer) {
				int userId = (Integer) authUserIdObj;
				try {
					Map<Integer, CartItem> dbCart = new CartDAO().loadCart(userId);
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
							new CartDAO().saveCart(userId, cart);
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
			request.setAttribute("items", items);
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
				String variantIdStr = request.getParameter("variantId");
				String productIdStr = request.getParameter("productId");
				String productName = request.getParameter("productName");
				String attributes = request.getParameter("attributes");
				String priceStr = request.getParameter("price");
				String qtyStr = request.getParameter("quantity");
				String imageUrl = request.getParameter("imageUrl");

				int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
				int productId = Integer.parseInt(productIdStr != null ? productIdStr : "0");
				int quantity = 1;
				try { quantity = Integer.parseInt(qtyStr); } catch (Exception e) {}
				BigDecimal price = BigDecimal.ZERO;
				try { price = new BigDecimal(priceStr); } catch (Exception e) {}

CartDAO dao = new CartDAO();

int stock = dao.getAvailableStock(variantId);

if (stock <= 0) {
    session.setAttribute("cartMessage",
            "Sản phẩm đã hết hàng.");
    response.sendRedirect(request.getContextPath() + "/cart");
    return;
}

CartItem item = cart.get(variantId);

if (item == null) {

    if (quantity > stock) {
        session.setAttribute("cartMessage",
                "Chỉ còn " + stock + " sản phẩm trong kho.");
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    item = new CartItem();
    item.setVariantId(variantId);
    item.setProductId(productId);
    item.setProductName(productName);
    item.setAttributes(attributes);
    item.setPrice(price);
    item.setQuantity(quantity);
    item.setImageUrl(imageUrl);

    cart.put(variantId, item);

} else {

    int newQty = item.getQuantity() + quantity;

    if (newQty > stock) {
        session.setAttribute("cartMessage",
                "Chỉ còn " + stock + " sản phẩm trong kho.");
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    item.setQuantity(newQty);
}

session.setAttribute("cartMessage",
        "Thêm vào giỏ hàng thành công.");

				LOGGER.log(Level.FINE, "[CartController] Cart after add: {0}", cartSummary(cart));

				authUserIdObj = session.getAttribute("authUserId");
				if (authUserIdObj instanceof Integer) {
					int userId = (Integer) authUserIdObj;
					try {
						new CartDAO().saveCart(userId, cart);
						LOGGER.log(Level.FINE, "[CartController] Persisted cart for user {0} after add: {1}", new Object[]{userId, cartSummary(cart)});
					} catch (Exception ex) {
						LOGGER.log(Level.WARNING, "[CartController] Failed saving cart for user " + userId + " after add", ex);
					}
				} else {
					// anonymous user -> persist cart in cookie
					writeAnonCartCookie(response, cart);
				}

				response.sendRedirect(request.getContextPath() + "/cart?skipMerge=1");
				break;
			}

			case "update": {
				String variantIdStr = request.getParameter("variantId");
				String qtyStr = request.getParameter("quantity");
				int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
				int quantity = 1;
				try { quantity = Integer.parseInt(qtyStr); } catch (Exception e) {}

				CartDAO dao = new CartDAO();

int stock = dao.getAvailableStock(variantId);

CartItem item = cart.get(variantId);

if (item != null) {

    if (quantity <= 0) {

        cart.remove(variantId);

        session.setAttribute("cartMessage",
                "Xóa sản phẩm khỏi giỏ hàng thành công.");

    } else {

        if (quantity > stock) {

            session.setAttribute("cartMessage",
                    "Chỉ còn " + stock + " sản phẩm trong kho.");

            response.sendRedirect(
                    request.getContextPath() + "/cart");

            return;
        }

        item.setQuantity(quantity);

        session.setAttribute("cartMessage",
                "Cập nhật giỏ hàng thành công.");
    }
}

				LOGGER.log(Level.FINE, "[CartController] Cart after update: {0}", cartSummary(cart));

				authUserIdObj = session.getAttribute("authUserId");
				if (authUserIdObj instanceof Integer) {
					int userId = (Integer) authUserIdObj;
					try {
						new CartDAO().saveCart(userId, cart);
						LOGGER.log(Level.FINE, "[CartController] Persisted cart for user {0} after update: {1}", new Object[]{userId, cartSummary(cart)});
					} catch (Exception ex) {
						LOGGER.log(Level.WARNING, "[CartController] Failed saving cart for user " + userId + " after update", ex);
					}
				} else {
					writeAnonCartCookie(response, cart);
				}

				response.sendRedirect(request.getContextPath() + "/cart?skipMerge=1");
				break;
			}

			case "remove": {
				String variantIdStr = request.getParameter("variantId");
				int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
				cart.remove(variantId);

                                session.setAttribute("cartMessage",
                                    "Xóa sản phẩm khỏi giỏ hàng thành công.");

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

	private static String cartSummary(Map<Integer, CartItem> cart) {
		if (cart == null || cart.isEmpty()) return "[]";
		StringJoiner joiner = new StringJoiner(" | ");
		for (CartItem it : cart.values()) {
			String name = it.getProductName() == null ? "(null)" : it.getProductName();
			String img = it.getImageUrl() == null ? "(no-image)" : it.getImageUrl();
			joiner.add("v:" + it.getVariantId() + ", p:" + it.getProductId() + ", q:" + it.getQuantity() + ", name:" + name + ", img:" + img);
		}
		return "[" + joiner.toString() + "]";
	}

	// Anonymous cart cookie helpers

	private Map<Integer, CartItem> readAnonCartCookie(HttpServletRequest request) {
		Map<Integer, CartItem> result = new HashMap<>();
		if (request.getCookies() == null) return result;
		for (Cookie c : request.getCookies()) {
			if ("anonCart".equals(c.getName())) {
				String val = c.getValue();
				if (val == null || val.isEmpty()) return result;
				try {
					String decoded = URLDecoder.decode(val, StandardCharsets.UTF_8.name());
					String[] items = decoded.split("\\|");
					for (String item : items) {
						if (item.trim().isEmpty()) continue;
						String[] f = item.split("\\^", -1);
						int variantId = Integer.parseInt(f[0]);
						int productId = Integer.parseInt(f[1]);
						int quantity = Integer.parseInt(f[2]);
						java.math.BigDecimal price = java.math.BigDecimal.ZERO;
						try { price = new java.math.BigDecimal(f[3]); } catch (Exception ex) {}
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
		if (cart == null) cart = new HashMap<>();
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
