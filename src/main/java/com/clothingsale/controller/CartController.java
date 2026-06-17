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

			// merge persisted cart for authenticated users
			Object authUserIdObj = session.getAttribute("authUserId");
			if (authUserIdObj instanceof Integer) {
				int userId = (Integer) authUserIdObj;
				try {
					Map<Integer, CartItem> dbCart = new CartDAO().loadCart(userId);
					LOGGER.log(Level.FINE, "[CartController] Loaded persisted cart for user {0}: {1}", new Object[]{userId, cartSummary(dbCart)});
					if (dbCart != null && !dbCart.isEmpty()) {
						for (CartItem dbItem : dbCart.values()) {
							CartItem existing = cart.get(dbItem.getVariantId());
							if (existing == null) {
								cart.put(dbItem.getVariantId(), dbItem);
							} else {
								existing.setQuantity(existing.getQuantity() + dbItem.getQuantity());
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

				CartItem item = cart.get(variantId);
				if (item == null) {
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
					item.setQuantity(item.getQuantity() + quantity);
				}

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
				}

				response.sendRedirect(request.getContextPath() + "/cart");
				break;
			}

			case "update": {
				String variantIdStr = request.getParameter("variantId");
				String qtyStr = request.getParameter("quantity");
				int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
				int quantity = 1;
				try { quantity = Integer.parseInt(qtyStr); } catch (Exception e) {}

				CartItem item = cart.get(variantId);
				if (item != null) {
					if (quantity <= 0) {
						cart.remove(variantId);
					} else {
						item.setQuantity(quantity);
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
				}

				response.sendRedirect(request.getContextPath() + "/cart");
				break;
			}

			case "remove": {
				String variantIdStr = request.getParameter("variantId");
				int variantId = Integer.parseInt(variantIdStr != null ? variantIdStr : "0");
				cart.remove(variantId);

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
				}

				response.sendRedirect(request.getContextPath() + "/cart");
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
}
