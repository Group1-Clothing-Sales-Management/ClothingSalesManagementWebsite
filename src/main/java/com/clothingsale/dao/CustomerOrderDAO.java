package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.model.Shipment;
import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Province;
import com.clothingsale.model.District;
import com.clothingsale.model.Ward;
import com.clothingsale.model.Voucher;
import com.clothingsale.model.VoucherUsage;
import com.clothingsale.model.ReturnRequest;

import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringJoiner;

public class CustomerOrderDAO {

    private final CartDAO cartDAO
            = new CartDAO();

    public List<CartItem> getCartItems(
            int userId) {

        return new ArrayList<>(
                cartDAO.loadCart(userId)
                        .values());
    }

    public List<CartItem> getCartItems(
            int userId,
            Set<Integer> selectedVariantIds) {

        List<CartItem> items = getCartItems(userId);

        if (selectedVariantIds == null) {
            return items;
        }

        List<CartItem> filtered = new ArrayList<>();

        for (CartItem item : items) {
            if (item != null
                    && selectedVariantIds.contains(
                            item.getVariantId())) {

                filtered.add(item);
            }
        }

        return filtered;
    }

    //=====================Order==========================
    public BigDecimal getCartTotal(int userId) {

        String sql
                = "SELECT SUM(c.quantity * pv.sale_price) total "
                + "FROM Cart c "
                + "JOIN Product_Variant pv ON c.variant_id = pv.id "
                + "WHERE c.user_id=?";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                BigDecimal total = rs.getBigDecimal("total");

                return total == null
                        ? BigDecimal.ZERO
                        : total;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    public BigDecimal getCartTotal(
            int userId,
            Set<Integer> selectedVariantIds) {

        if (selectedVariantIds == null) {
            return getCartTotal(userId);
        }

        BigDecimal total = BigDecimal.ZERO;

        for (CartItem item : getCartItems(
                userId,
                selectedVariantIds)) {

            if (item == null
                    || item.getPrice() == null) {
                continue;
            }

            total = total.add(
                    item.getPrice()
                            .multiply(
                                    BigDecimal.valueOf(
                                            item.getQuantity())));
        }

        return total;
    }

    public List<Order> getOrdersByUserId(
            int userId) {

        List<Order> list
                = new ArrayList<>();

        String sql = "SELECT o.id, o.order_code, o.user_id, o.voucher_id, o.shipment_id, "
                + "       o.recipient_name, o.recipient_phone, o.ward_id, o.address_detail, "
                + "       o.total_items_price, o.discount_amount, o.shipping_fee, o.total_payment, "
                + "       o.order_status, o.note, o.created_at, o.updated_at, "
                + "       v.code AS voucher_code, v.title AS voucher_title, "
                + "       s.shipping_status, p.payment_status, p.payment_method, "
                + "       rr.id AS return_request_id, rr.reason AS return_reason, rr.status AS return_status, "
                + "       rr.requested_at AS return_requested_at, rr.reviewed_by AS return_reviewed_by, "
                + "       rr.reviewed_at AS return_reviewed_at, rr.admin_note AS return_admin_note "
                + "FROM [Order] o "
                + "LEFT JOIN Voucher v ON o.voucher_id = v.id "
                + "LEFT JOIN Shipment s ON o.shipment_id = s.id "
                + "LEFT JOIN Payment p ON o.id = p.order_id "
                + "OUTER APPLY (SELECT TOP 1 * FROM Return_Request rr "
                + "             WHERE rr.order_id = o.id ORDER BY rr.requested_at DESC, rr.id DESC) rr "
                + "WHERE o.user_id = ? "
                + "ORDER BY o.created_at DESC";

        try (
                 Connection con
                = DBConnection.getConnection();  PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs
                    = ps.executeQuery();

            while (rs.next()) {

                Order o
                        = new Order();

                o.setId(
                        rs.getInt("id"));

                o.setOrderCode(
                        rs.getString("order_code"));

                o.setUserId(
                        rs.getInt("user_id"));
                o.setVoucherId(
                        rs.getInt("voucher_id"));
                o.setVoucherCode(
                        rs.getString("voucher_code"));
                o.setVoucherTitle(
                        rs.getString("voucher_title"));
                o.setTotalItemsPrice(
                        rs.getBigDecimal("total_items_price"));
                o.setDiscountAmount(
                        rs.getBigDecimal("discount_amount"));
                o.setShippingFee(
                        rs.getBigDecimal("shipping_fee"));
                o.setTotalPayment(
                        rs.getBigDecimal(
                                "total_payment"));

                o.setOrderStatus(
                        rs.getString(
                                "order_status"));

                o.setShipmentId(
                        rs.getInt("shipment_id"));
                o.setShippingStatus(
                        rs.getString("shipping_status"));
                o.setPaymentStatus(
                        rs.getString("payment_status"));
                o.setPaymentMethod(
                        rs.getString("payment_method"));
                o.setReturnRequest(mapReturnRequest(rs));

                o.setCreatedAt(
                        rs.getTimestamp(
                                "created_at"));

                list.add(o);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return list;
    }

    public List<OrderDetail> getOrderDetailsByOrderId(
            int orderId,
            int userId) {

        List<OrderDetail> list = new ArrayList<>();

        String sql = "SELECT od.id, od.order_id, od.variant_id, "
                + "od.product_name_snapshot, od.variant_attributes_snapshot, "
                + "od.quantity, od.price, "
                + "pv.product_id, pv.sale_price AS current_price, pv.stock_quantity, "
                + "pv.status AS variant_status, "
                + "p.product_name AS current_product_name, p.status AS product_status, "
                + "img.image_url AS current_image_url "
                + "FROM Order_Detail od "
                + "JOIN [Order] o ON od.order_id = o.id "
                + "LEFT JOIN Product_Variant pv ON od.variant_id = pv.id "
                + "LEFT JOIN Product p ON pv.product_id = p.id "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "WHERE od.order_id = ? "
                + "AND o.user_id = ? "
                + "ORDER BY od.id ASC";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            try ( ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    list.add(mapOrderDetail(rs));
                }
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return list;
    }

    public Map<Integer, List<OrderDetail>> getOrderDetailsByOrderIds(
            int userId,
            List<Integer> orderIds) {

        Map<Integer, List<OrderDetail>> detailsByOrderId = new LinkedHashMap<>();
        List<Integer> cleanOrderIds = new ArrayList<>();

        if (orderIds != null) {
            for (Integer orderId : orderIds) {
                if (orderId != null && orderId > 0 && !cleanOrderIds.contains(orderId)) {
                    cleanOrderIds.add(orderId);
                    detailsByOrderId.put(orderId, new ArrayList<>());
                }
            }
        }

        if (cleanOrderIds.isEmpty()) {
            return detailsByOrderId;
        }

        String sql = "SELECT od.id, od.order_id, od.variant_id, "
                + "od.product_name_snapshot, od.variant_attributes_snapshot, "
                + "od.quantity, od.price, "
                + "pv.product_id, pv.sale_price AS current_price, pv.stock_quantity, "
                + "pv.status AS variant_status, "
                + "p.product_name AS current_product_name, p.status AS product_status, "
                + "img.image_url AS current_image_url "
                + "FROM Order_Detail od "
                + "JOIN [Order] o ON od.order_id = o.id "
                + "LEFT JOIN Product_Variant pv ON od.variant_id = pv.id "
                + "LEFT JOIN Product p ON pv.product_id = p.id "
                + "LEFT JOIN Product_Image img ON p.id = img.product_id AND img.is_main = 1 "
                + "WHERE o.user_id = ? "
                + "AND od.order_id IN (" + placeholders(cleanOrderIds.size()) + ") "
                + "ORDER BY od.order_id DESC, od.id ASC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            for (int i = 0; i < cleanOrderIds.size(); i++) {
                ps.setInt(i + 2, cleanOrderIds.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = mapOrderDetail(rs);
                    detailsByOrderId
                            .computeIfAbsent(detail.getOrderId(), ignored -> new ArrayList<>())
                            .add(detail);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return detailsByOrderId;
    }

    private OrderDetail mapOrderDetail(ResultSet rs) throws SQLException {
        OrderDetail detail = new OrderDetail();

        detail.setId(rs.getInt("id"));
        detail.setOrderId(rs.getInt("order_id"));
        detail.setVariantId(rs.getInt("variant_id"));
        detail.setProductNameSnapshot(rs.getString("product_name_snapshot"));
        detail.setVariantAttributesSnapshot(rs.getString("variant_attributes_snapshot"));
        detail.setQuantity(rs.getInt("quantity"));
        detail.setPrice(rs.getBigDecimal("price"));
        detail.setProductId(rs.getInt("product_id"));
        detail.setCurrentProductName(rs.getString("current_product_name"));
        detail.setCurrentPrice(rs.getBigDecimal("current_price"));
        detail.setCurrentStock(rs.getInt("stock_quantity"));
        detail.setCurrentProductStatus(rs.getString("product_status"));
        detail.setCurrentVariantStatus(rs.getString("variant_status"));
        detail.setCurrentImageUrl(rs.getString("current_image_url"));

        BigDecimal price = detail.getPrice() != null
                ? detail.getPrice()
                : BigDecimal.ZERO;
        detail.setLineTotal(
                price.multiply(BigDecimal.valueOf(detail.getQuantity())));

        boolean activeProduct
                = "ACTIVE".equalsIgnoreCase(detail.getCurrentProductStatus());
        boolean activeVariant
                = "ACTIVE".equalsIgnoreCase(detail.getCurrentVariantStatus());
        boolean hasStock = detail.getCurrentStock() > 0;

        detail.setReorderable(
                detail.getVariantId() > 0
                && activeProduct
                && activeVariant
                && hasStock);

        if (detail.getVariantId() <= 0) {
            detail.setReorderNote("Variant no longer exists");
        } else if (!activeProduct || !activeVariant) {
            detail.setReorderNote("Product is no longer active");
        } else if (!hasStock) {
            detail.setReorderNote("Out of stock");
        } else {
            detail.setReorderNote("Available");
        }

        return detail;
    }

    private ReturnRequest mapReturnRequest(ResultSet rs) throws SQLException {
        int id = rs.getInt("return_request_id");
        if (rs.wasNull()) {
            return null;
        }

        ReturnRequest request = new ReturnRequest();
        request.setId(id);
        request.setReason(rs.getString("return_reason"));
        request.setStatus(rs.getString("return_status"));
        request.setRequestedAt(rs.getTimestamp("return_requested_at"));

        int reviewedBy = rs.getInt("return_reviewed_by");
        request.setReviewedBy(rs.wasNull() ? null : reviewedBy);
        request.setReviewedAt(rs.getTimestamp("return_reviewed_at"));
        request.setAdminNote(rs.getString("return_admin_note"));
        return request;
    }

    private String placeholders(int count) {
        StringJoiner joiner = new StringJoiner(",");
        for (int i = 0; i < count; i++) {
            joiner.add("?");
        }
        return joiner.toString();
    }

    private int createOrder(
            Connection con,
            int userId,
            Voucher voucher,
            UserAddress address,
            BigDecimal subtotal,
            BigDecimal discount,
            BigDecimal shippingFee,
            BigDecimal totalPayment,
            String note,
            Shipment shipment)
            throws SQLException {

        String sql = "INSERT INTO [Order] "
                + "("
                + "order_code,"
                + "user_id,"
                + "voucher_id,"
                + "shipment_id," // 👈 THÊM
                + "recipient_name,"
                + "recipient_phone,"
                + "ward_id,"
                + "address_detail,"
                + "total_items_price,"
                + "discount_amount,"
                + "shipping_fee,"
                + "total_payment,"
                + "order_status,"
                + "note"
                + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        PreparedStatement ps = con.prepareStatement(
                sql,
                Statement.RETURN_GENERATED_KEYS
        );

        String orderCode = "ORD" + System.currentTimeMillis();

        ps.setString(1, orderCode);
        ps.setInt(2, userId);

        if (voucher == null) {
            ps.setNull(3, Types.INTEGER);
        } else {
            ps.setInt(3, voucher.getId());
        }

        // SHIPMENT
        if (shipment == null) {
            ps.setNull(4, Types.INTEGER);
        } else {
            ps.setInt(4, shipment.getId());
        }

        ps.setString(5, address.getRecipientName());
        ps.setString(6, address.getRecipientPhone());
        ps.setString(7, address.getWardId());
        ps.setString(8, address.getAddressDetail());

        ps.setBigDecimal(9, subtotal);
        ps.setBigDecimal(10, discount);
        ps.setBigDecimal(11, shippingFee);
        ps.setBigDecimal(12, totalPayment);

        ps.setString(13, "PENDING");
        ps.setString(14, note);

        ps.executeUpdate();

        ResultSet rs = ps.getGeneratedKeys();
        if (rs.next()) {
            return rs.getInt(1);
        }

        throw new SQLException("Create order failed");
    }

    private BigDecimal calculateDiscount(Voucher voucher, BigDecimal subtotal) {

        if (voucher == null) {
            return BigDecimal.ZERO;
        }

        if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount;

        if (isPercentageDiscount(voucher.getDiscountType())) {

            discount = subtotal.multiply(voucher.getDiscountValue())
                    .divide(BigDecimal.valueOf(100));

            if (voucher.getMaxDiscountAmount() != null
                    && discount.compareTo(voucher.getMaxDiscountAmount()) > 0) {
                discount = voucher.getMaxDiscountAmount();
            }

        } else {
            discount = voucher.getDiscountValue();
        }

        return discount.min(subtotal).max(BigDecimal.ZERO);
    }

    private boolean isPercentageDiscount(String discountType) {
        return "PERCENTAGE".equalsIgnoreCase(discountType)
                || "PERCENT".equalsIgnoreCase(discountType);
    }

    public boolean placeOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note,
            String paymentMethod,
            String carrierName,
            Set<Integer> selectedVariantIds) {

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            List<CartItem> cartItems = getCartItems(userId, selectedVariantIds);

            if (cartItems.isEmpty()) {
                con.rollback();
                return false;
            }

            UserAddress address = getAddressById(addressId);
            if (address == null || address.getUserId() != userId) {
                con.rollback();
                return false;
            }

            for (CartItem item : cartItems) {
                int availableStock = cartDAO.getAvailableStock(item.getVariantId());
                if (availableStock < item.getQuantity()) {
                    con.rollback();
                    return false;
                }
            }

            // ===== SUBTOTAL =====
            BigDecimal subtotal = BigDecimal.ZERO;
            for (CartItem item : cartItems) {
                subtotal = subtotal.add(
                        item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }

            // ===== VOUCHER =====
            Voucher voucher = getVoucherByCode(voucherCode);
            if (voucher != null
                    && (hasUserUsedVoucher(userId, voucher.getId())
                    || !voucherAppliesToItems(con, voucher, cartItems)
                    || subtotal.compareTo(voucher.getMinOrderValue()) < 0)) {
                voucher = null;
            }
            BigDecimal discount = calculateDiscount(voucher, subtotal);

            BigDecimal shippingFee = BigDecimal.valueOf(30000);
            BigDecimal totalPayment = subtotal.subtract(discount).add(shippingFee);

            // ===== 1. CREATE SHIPMENT (MỚI) =====
            Shipment shipment = new Shipment();
            shipment.setCarrierName(carrierName);
            shipment.setShippingStatus("PENDING_PICKUP");

            int shipmentId = createShipment(con, carrierName);
            shipment.setId(shipmentId);

            // ===== 2. CREATE ORDER (CÓ shipmentId) =====
            int orderId = createOrder(
                    con,
                    userId,
                    voucher,
                    address,
                    subtotal,
                    discount,
                    shippingFee,
                    totalPayment,
                    note,
                    shipment
            );

            // ===== 3. ORDER DETAIL =====
            for (CartItem item : cartItems) {
                createOrderDetail(con, orderId, item);
                decreaseStock(con, item.getVariantId(), item.getQuantity());
            }

            // ===== 4. PAYMENT =====
            createPayment(con, orderId, paymentMethod, totalPayment);

            if (voucher != null) {
                try ( PreparedStatement ps = con.prepareStatement(
                        "UPDATE Voucher SET used_count = used_count + 1 WHERE id=? AND used_count < usage_limit")) {
                    ps.setInt(1, voucher.getId());
                    if (ps.executeUpdate() == 0) {
                        throw new SQLException("Voucher usage limit reached");
                    }
                }
                recordVoucherUsage(con, userId, voucher.getId(), orderId, discount);
            }

            // ===== 5. CLEAR CART =====
            if (selectedVariantIds == null) {
                clearCart(con, userId);
            } else {
                clearCartItems(con, userId, selectedVariantIds);
            }

            con.commit();
            return true;

        } catch (Exception e) {
            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception ex) {
            }
            e.printStackTrace();
            return false;

        } finally {
            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception ex) {
            }
        }
    }

    public boolean placeBuyNowOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note,
            String paymentMethod,
            String carrierName,
            List<CartItem> cartItems) {

        Connection con = null;

        try {

            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            if (cartItems == null || cartItems.isEmpty()) {
                con.rollback();
                return false;
            }

            UserAddress address = getAddressById(addressId);

            if (address == null || address.getUserId() != userId) {
                con.rollback();
                return false;
            }

            // ===== CHECK STOCK =====
            for (CartItem item : cartItems) {

                int availableStock
                        = cartDAO.getAvailableStock(item.getVariantId());

                if (availableStock < item.getQuantity()) {
                    con.rollback();
                    return false;
                }

            }

            // ===== SUBTOTAL =====
            BigDecimal subtotal = BigDecimal.ZERO;

            for (CartItem item : cartItems) {

                subtotal = subtotal.add(
                        item.getPrice().multiply(
                                BigDecimal.valueOf(item.getQuantity()))
                );

            }

            // ===== VOUCHER =====
            Voucher voucher = getVoucherByCode(voucherCode);

            if (voucher != null
                    && (hasUserUsedVoucher(userId, voucher.getId())
                    || !voucherAppliesToItems(con, voucher, cartItems)
                    || subtotal.compareTo(voucher.getMinOrderValue()) < 0)) {

                voucher = null;

            }

            BigDecimal discount
                    = calculateDiscount(voucher, subtotal);

            BigDecimal shippingFee
                    = BigDecimal.valueOf(30000);

            BigDecimal totalPayment
                    = subtotal.subtract(discount)
                            .add(shippingFee);

            // ===== CREATE SHIPMENT =====
            Shipment shipment = new Shipment();

            shipment.setCarrierName(carrierName);
            shipment.setShippingStatus("PENDING_PICKUP");

            int shipmentId
                    = createShipment(con, carrierName);

            shipment.setId(shipmentId);

            // ===== CREATE ORDER =====
            int orderId
                    = createOrder(
                            con,
                            userId,
                            voucher,
                            address,
                            subtotal,
                            discount,
                            shippingFee,
                            totalPayment,
                            note,
                            shipment);

            // ===== CREATE ORDER DETAILS =====
            for (CartItem item : cartItems) {

                createOrderDetail(
                        con,
                        orderId,
                        item);

                decreaseStock(
                        con,
                        item.getVariantId(),
                        item.getQuantity());

            }

            // ===== PAYMENT =====
            createPayment(
                    con,
                    orderId,
                    paymentMethod,
                    totalPayment);

            // ===== UPDATE VOUCHER =====
            if (voucher != null) {

                try ( PreparedStatement ps = con.prepareStatement(
                        "UPDATE Voucher "
                        + "SET used_count = used_count + 1 "
                        + "WHERE id=? "
                        + "AND used_count < usage_limit")) {

                    ps.setInt(1, voucher.getId());

                    if (ps.executeUpdate() == 0) {
                        throw new SQLException("Voucher usage limit reached");
                    }

                }
                recordVoucherUsage(con, userId, voucher.getId(), orderId, discount);

            }

            // ===== BUY NOW KHÔNG CLEAR CART =====
            con.commit();

            return true;

        } catch (Exception e) {

            try {

                if (con != null) {
                    con.rollback();
                }

            } catch (Exception ex) {
            }

            e.printStackTrace();

            return false;

        } finally {

            try {

                if (con != null) {
                    con.close();
                }

            } catch (Exception ex) {
            }

        }

    }

    private void createPayment(
            Connection con,
            int orderId,
            String method,
            BigDecimal amount) throws SQLException {

        String sql = "INSERT INTO Payment(order_id, payment_method, payment_status, amount) "
                + "VALUES(?,?,?,?)";

        try ( PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setString(2, method);

            if ("COD".equalsIgnoreCase(method)) {
                ps.setString(3, "UNPAID");
            } else {
                ps.setString(3, "UNPAID"); // VNPAY pending
            }

            ps.setBigDecimal(4, amount);

            ps.executeUpdate();
        }
    }

    private void recordVoucherUsage(Connection con, int userId, int voucherId, int orderId, BigDecimal discount)
            throws SQLException {

        String sql = "INSERT INTO Voucher_Usage "
                + "(user_id, voucher_id, order_id, discount_amount, status, used_at, note) "
                + "VALUES (?, ?, ?, ?, 'APPLIED', GETDATE(), ?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            ps.setInt(3, orderId);
            ps.setBigDecimal(4, discount == null ? BigDecimal.ZERO : discount);
            ps.setString(5, "Applied at checkout");
            ps.executeUpdate();
        }
    }

    private boolean voucherAppliesToItems(Connection con, Voucher voucher, List<CartItem> cartItems)
            throws SQLException {

        if (voucher == null || voucher.getCategoryId() == null) {
            return true;
        }

        List<Integer> productIds = new ArrayList<>();
        if (cartItems != null) {
            for (CartItem item : cartItems) {
                if (item != null && item.getProductId() > 0 && !productIds.contains(item.getProductId())) {
                    productIds.add(item.getProductId());
                }
            }
        }

        if (productIds.isEmpty()) {
            return false;
        }

        String sql = "WITH CategoryTree AS ("
                + "SELECT id FROM Category WHERE id = ? "
                + "UNION ALL "
                + "SELECT c.id FROM Category c JOIN CategoryTree ct ON c.parent_id = ct.id"
                + ") "
                + "SELECT TOP 1 1 FROM Product p "
                + "WHERE p.id IN (" + placeholders(productIds.size()) + ") "
                + "AND p.category_id IN (SELECT id FROM CategoryTree)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, voucher.getCategoryId());
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 2, productIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean isVoucherApplicableToItems(Voucher voucher, List<CartItem> cartItems) {
        try (Connection con = DBConnection.getConnection()) {
            return voucherAppliesToItems(con, voucher, cartItems);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private int createShipment(Connection con, String carrierName) throws SQLException {

        String sql = "INSERT INTO Shipment("
                + "carrier_name, shipping_status, tracking_code, shipping_cost"
                + ") VALUES(?,?,?,?)";

        try ( PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, carrierName);
            ps.setString(2, "PENDING_PICKUP");
            ps.setString(3, null);
            ps.setBigDecimal(4, BigDecimal.ZERO);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    public Voucher getVoucherByCode(String code) {

        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String sql
                = "SELECT v.*, c.category_name FROM Voucher v "
                + "LEFT JOIN Category c ON v.category_id = c.id "
                + "WHERE v.code=? "
                + "AND GETDATE() BETWEEN start_date AND end_date "
                + "AND used_count < usage_limit";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, code.trim());

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                Voucher v = new Voucher();

                v.setId(rs.getInt("id"));
                v.setCode(rs.getString("code"));
                v.setTitle(rs.getString("title"));
                v.setDiscountType(rs.getString("discount_type"));
                v.setDiscountValue(rs.getBigDecimal("discount_value"));
                v.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
                v.setMinOrderValue(rs.getBigDecimal("min_order_value"));
                v.setStartDate(rs.getTimestamp("start_date"));
                v.setEndDate(rs.getTimestamp("end_date"));
                v.setUsageLimit(rs.getInt("usage_limit"));
                v.setUsedCount(rs.getInt("used_count"));
                v.setLimitPerUser(rs.getInt("limit_per_user"));
                int categoryId = rs.getInt("category_id");
                v.setCategoryId(rs.wasNull() ? null : categoryId);
                v.setCategoryName(rs.getString("category_name"));

                return v;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Voucher> getVouchersForUser(int userId) {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT v.*, c.category_name, "
                + "(SELECT COUNT(*) FROM Voucher_Usage vu "
                + " WHERE vu.voucher_id = v.id AND vu.user_id = ? AND vu.status = 'APPLIED') AS user_used_count "
                + "FROM Voucher v "
                + "LEFT JOIN Category c ON v.category_id = c.id "
                + "ORDER BY v.end_date ASC";
        try ( Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher v = new Voucher();
                    v.setId(rs.getInt("id"));
                    v.setCode(rs.getString("code"));
                    v.setTitle(rs.getString("title"));
                    v.setDiscountType(rs.getString("discount_type"));
                    v.setDiscountValue(rs.getBigDecimal("discount_value"));
                    v.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
                    v.setMinOrderValue(rs.getBigDecimal("min_order_value"));
                    v.setStartDate(rs.getTimestamp("start_date"));
                    v.setEndDate(rs.getTimestamp("end_date"));
                    v.setUsageLimit(rs.getInt("usage_limit"));
                    v.setUsedCount(rs.getInt("used_count"));
                    v.setLimitPerUser(rs.getInt("limit_per_user"));
                    v.setTerminateReason(rs.getString("terminate_reason"));
                    int categoryId = rs.getInt("category_id");
                    v.setCategoryId(rs.wasNull() ? null : categoryId);
                    v.setCategoryName(rs.getString("category_name"));
                    v.setUserUsedCount(rs.getInt("user_used_count"));
                    vouchers.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        attachVoucherUsageHistory(userId, vouchers);
        return vouchers;
    }

    private boolean hasUserUsedVoucher(int userId, int voucherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Voucher_Usage vu "
                + "JOIN Voucher v ON vu.voucher_id = v.id "
                + "WHERE vu.user_id=? AND vu.voucher_id=? AND vu.status = 'APPLIED' "
                + "HAVING COUNT(*) >= ISNULL(MAX(v.limit_per_user), 1)";
        try ( Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            try ( ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void attachVoucherUsageHistory(int userId, List<Voucher> vouchers) {
        if (vouchers == null || vouchers.isEmpty()) {
            return;
        }

        Map<Integer, Voucher> voucherById = new LinkedHashMap<>();
        for (Voucher voucher : vouchers) {
            if (voucher != null) {
                voucherById.put(voucher.getId(), voucher);
            }
        }

        String sql = "SELECT vu.id, vu.user_id, vu.voucher_id, vu.order_id, o.order_code, "
                + "vu.discount_amount, vu.status, vu.used_at, vu.refunded_at, vu.note "
                + "FROM Voucher_Usage vu "
                + "JOIN [Order] o ON vu.order_id = o.id "
                + "WHERE vu.user_id = ? "
                + "ORDER BY vu.used_at DESC, vu.id DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = voucherById.get(rs.getInt("voucher_id"));
                    if (voucher == null) {
                        continue;
                    }

                    VoucherUsage usage = new VoucherUsage();
                    usage.setId(rs.getInt("id"));
                    usage.setUserId(rs.getInt("user_id"));
                    usage.setVoucherId(rs.getInt("voucher_id"));
                    usage.setOrderId(rs.getInt("order_id"));
                    usage.setOrderCode(rs.getString("order_code"));
                    usage.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    usage.setStatus(rs.getString("status"));
                    usage.setUsedAt(rs.getTimestamp("used_at"));
                    usage.setRefundedAt(rs.getTimestamp("refunded_at"));
                    usage.setNote(rs.getString("note"));
                    voucher.getUsageHistory().add(usage);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void createOrderDetail(
            Connection con,
            int orderId,
            CartItem item)
            throws SQLException {

        String sql
                = "INSERT INTO Order_Detail "
                + "("
                + "order_id,"
                + "variant_id,"
                + "product_name_snapshot,"
                + "variant_attributes_snapshot,"
                + "quantity,"
                + "price"
                + ") "
                + "VALUES(?,?,?,?,?,?)";

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(
                1,
                orderId);

        ps.setInt(
                2,
                item.getVariantId());

        ps.setString(
                3,
                item.getProductName());

        ps.setString(
                4,
                item.getAttributes());

        ps.setInt(
                5,
                item.getQuantity());

        ps.setBigDecimal(
                6,
                item.getPrice());

        ps.executeUpdate();
    }

    public boolean cancelOrder(
            int orderId,
            int userId) {

        String sql
                = "UPDATE [Order] "
                + "SET order_status='CANCELLED', updated_at=GETDATE() "
                + "WHERE id=? "
                + "AND user_id=? "
                + "AND order_status='PENDING'";

        try ( Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                try ( PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);

                    // The status transition is also the idempotency guard. A
                    // repeated cancel cannot restore the same stock twice.
                    if (ps.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }

                restoreStockForOrder(con, orderId);
                refundVoucherForOrder(con, orderId, "Order cancelled by customer");
                con.commit();
                return true;
            } catch (Exception transactionError) {
                con.rollback();
                throw transactionError;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean requestReturnOrder(int orderId, int userId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return false;
        }

        String loadSql = "SELECT order_status FROM [Order] WHERE id=? AND user_id=?";
        String existingSql = "SELECT COUNT(*) FROM Return_Request "
                + "WHERE order_id=? AND status IN ('PENDING', 'APPROVED')";
        String insertSql = "INSERT INTO Return_Request (order_id, user_id, reason, status, requested_at) "
                + "VALUES (?, ?, ?, 'PENDING', GETDATE())";
        String updateOrderSql = "UPDATE [Order] SET order_status='RETURN_REQUESTED', updated_at=GETDATE() "
                + "WHERE id=? AND user_id=? AND order_status IN ('DELIVERED', 'SUCCESS', 'COMPLETED', 'PAID')";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String currentStatus = null;
                try (PreparedStatement ps = con.prepareStatement(loadSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentStatus = rs.getString("order_status");
                        }
                    }
                }

                if (currentStatus == null
                        || !("DELIVERED".equalsIgnoreCase(currentStatus)
                        || "SUCCESS".equalsIgnoreCase(currentStatus)
                        || "COMPLETED".equalsIgnoreCase(currentStatus)
                        || "PAID".equalsIgnoreCase(currentStatus))) {
                    con.rollback();
                    return false;
                }

                try (PreparedStatement ps = con.prepareStatement(existingSql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            con.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    ps.setString(3, reason.trim());
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = con.prepareStatement(updateOrderSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    if (ps.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }

                con.commit();
                return true;
            } catch (Exception transactionError) {
                con.rollback();
                throw transactionError;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void refundVoucherForOrder(Connection con, int orderId, String note)
            throws SQLException {

        String selectSql = "SELECT voucher_id FROM Voucher_Usage "
                + "WHERE order_id=? AND status='APPLIED'";
        String updateUsageSql = "UPDATE Voucher_Usage "
                + "SET status='REFUNDED', refunded_at=GETDATE(), note=? "
                + "WHERE order_id=? AND status='APPLIED'";
        String decrementSql = "UPDATE Voucher "
                + "SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END "
                + "WHERE id=?";

        List<Integer> voucherIds = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(selectSql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    voucherIds.add(rs.getInt("voucher_id"));
                }
            }
        }

        if (voucherIds.isEmpty()) {
            return;
        }

        try (PreparedStatement ps = con.prepareStatement(updateUsageSql)) {
            ps.setString(1, note);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }

        try (PreparedStatement ps = con.prepareStatement(decrementSql)) {
            for (Integer voucherId : voucherIds) {
                if (voucherId == null) {
                    continue;
                }
                ps.setInt(1, voucherId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /**
     * Put back the quantities reserved when the order was created.
     */
    private void restoreStockForOrder(Connection con, int orderId)
            throws SQLException {

        String selectSql
                = "SELECT variant_id, quantity "
                + "FROM Order_Detail "
                + "WHERE order_id=?";
        String updateSql
                = "UPDATE Product_Variant "
                + "SET stock_quantity = stock_quantity + ? "
                + "WHERE id=?";

        try ( PreparedStatement select = con.prepareStatement(selectSql);  PreparedStatement update = con.prepareStatement(updateSql)) {

            select.setInt(1, orderId);

            try ( ResultSet rs = select.executeQuery()) {
                while (rs.next()) {
                    int variantId = rs.getInt("variant_id");
                    boolean variantIsNull = rs.wasNull();
                    int quantity = rs.getInt("quantity");

                    // Order_Detail keeps the row when a variant is deleted;
                    // there is no stock row left to restore in that case.
                    if (!variantIsNull && quantity > 0) {
                        update.setInt(1, quantity);
                        update.setInt(2, variantId);
                        update.addBatch();
                    }
                }
            }

            update.executeBatch();
        }
    }

    public void decreaseStock(
            Connection con,
            int variantId,
            int quantity)
            throws SQLException {

        String sql
                = "UPDATE Product_Variant "
                + "SET stock_quantity = stock_quantity - ? "
                + "WHERE id=? "
                + "AND status='ACTIVE' "
                + "AND stock_quantity >= ?";

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(1, quantity);
        ps.setInt(2, variantId);
        ps.setInt(3, quantity);

        if (ps.executeUpdate() == 0) {
            throw new SQLException("Not enough stock for variant " + variantId);
        }
    }

    public void clearCart(
            Connection con,
            int userId)
            throws SQLException {

        String sql
                = "DELETE FROM Cart "
                + "WHERE user_id=?";

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(1, userId);

        ps.executeUpdate();
    }

    public void clearCartItems(
            Connection con,
            int userId,
            Set<Integer> selectedVariantIds)
            throws SQLException {

        if (selectedVariantIds == null
                || selectedVariantIds.isEmpty()) {
            return;
        }

        String sql
                = "DELETE FROM Cart "
                + "WHERE user_id=? "
                + "AND variant_id=?";

        try ( PreparedStatement ps
                = con.prepareStatement(sql)) {

            for (Integer variantId : selectedVariantIds) {
                if (variantId == null) {
                    continue;
                }

                ps.setInt(1, userId);
                ps.setInt(2, variantId);
                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    //=====================Address========================
    public List<UserAddress> getAddressesByUserId(int userId) {

        List<UserAddress> list = new ArrayList<>();

        String sql
                = "SELECT ua.*, "
                + "w.ward_name, "
                + "w.district_id, "
                + "d.district_name, "
                + "d.province_id, "
                + "p.province_name "
                + "FROM User_Address ua "
                + "JOIN Ward w ON ua.ward_id = w.id "
                + "JOIN District d ON w.district_id = d.id "
                + "JOIN Province p ON d.province_id = p.id "
                + "WHERE ua.user_id = ? "
                + "ORDER BY ua.is_default DESC, ua.id DESC";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(rs.getString("recipient_name"));
                a.setRecipientPhone(rs.getString("recipient_phone"));
                a.setWardId(rs.getString("ward_id"));
                a.setDistrictId(rs.getString("district_id"));
                a.setProvinceId(rs.getString("province_id"));
                a.setWardName(rs.getString("ward_name"));
                a.setDistrictName(rs.getString("district_name"));
                a.setProvinceName(rs.getString("province_name"));

                a.setAddressDetail(rs.getString("address_detail"));

                a.setDefault(rs.getBoolean("is_default"));

                list.add(a);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public UserAddress getAddressById(int id) {

        String sql
                = "SELECT ua.*, "
                + "w.ward_name, "
                + "w.district_id, "
                + "d.district_name, "
                + "d.province_id, "
                + "p.province_name "
                + "FROM User_Address ua "
                + "JOIN Ward w ON ua.ward_id = w.id "
                + "JOIN District d ON w.district_id = d.id "
                + "JOIN Province p ON d.province_id = p.id "
                + "WHERE ua.id = ?";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(rs.getString("recipient_name"));
                a.setRecipientPhone(rs.getString("recipient_phone"));
                a.setWardId(rs.getString("ward_id"));
                a.setDistrictId(rs.getString("district_id"));
                a.setProvinceId(rs.getString("province_id"));
                a.setWardName(rs.getString("ward_name"));
                a.setDistrictName(rs.getString("district_name"));
                a.setProvinceName(rs.getString("province_name"));
                a.setAddressDetail(rs.getString("address_detail"));
                a.setDefault(rs.getBoolean("is_default"));

                return a;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Province> getAllProvinces() {

        List<Province> list = new ArrayList<>();

        String sql
                = "SELECT * FROM Province ORDER BY province_name";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Province p = new Province();

                p.setId(rs.getString("id"));
                p.setProvinceName(rs.getString("province_name"));
                p.setType(rs.getString("type"));

                list.add(p);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;

    }

    public List<District> getDistrictsByProvince(String provinceId) {

        List<District> list = new ArrayList<>();

        String sql
                = "SELECT * FROM District "
                + "WHERE province_id=? "
                + "ORDER BY district_name";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, provinceId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                District d = new District();

                d.setId(rs.getString("id"));
                d.setDistrictName(rs.getString("district_name"));
                d.setProvinceId(rs.getString("province_id"));
                d.setType(rs.getString("type"));

                list.add(d);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;

    }

    public List<Ward> getWardsByDistrict(String districtId) {

        List<Ward> list = new ArrayList<>();

        String sql
                = "SELECT * FROM Ward "
                + "WHERE district_id=? "
                + "ORDER BY ward_name";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, districtId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Ward w = new Ward();

                w.setId(rs.getString("id"));
                w.setWardName(rs.getString("ward_name"));
                w.setDistrictId(rs.getString("district_id"));
                w.setType(rs.getString("type"));

                list.add(w);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;

    }

    private int countAddressByUser(
            Connection con,
            int userId)
            throws SQLException {

        String sql
                = "SELECT COUNT(*) "
                + "FROM User_Address "
                + "WHERE user_id = ?";

        try (
                 PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    private void clearDefaultAddress(
            Connection con,
            int userId)
            throws SQLException {

        String sql
                = "UPDATE User_Address "
                + "SET is_default = 0 "
                + "WHERE user_id = ?";

        try (
                 PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public boolean addAddress(
            UserAddress address) {

        String sql
                = "INSERT INTO User_Address "
                + "("
                + "user_id,"
                + "recipient_name,"
                + "recipient_phone,"
                + "ward_id,"
                + "address_detail,"
                + "is_default"
                + ")"
                + "VALUES(?,?,?,?,?,?)";

        try (
                 Connection con
                = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            int count
                    = countAddressByUser(
                            con,
                            address.getUserId());

            if (count == 0) {

                address.setDefault(true);

            } else if (address.isDefault()) {

                clearDefaultAddress(
                        con,
                        address.getUserId());
            }

            try (
                     PreparedStatement ps
                    = con.prepareStatement(sql)) {

                ps.setInt(1,
                        address.getUserId());

                ps.setString(2,
                        address.getRecipientName());

                ps.setString(3,
                        address.getRecipientPhone());

                ps.setString(4,
                        address.getWardId());

                ps.setString(5,
                        address.getAddressDetail());

                ps.setBoolean(6,
                        address.isDefault());

                ps.executeUpdate();
            }

            con.commit();

            return true;

        } catch (Exception e) {

            e.printStackTrace();
        }

        return false;
    }

    public UserAddress getDefaultAddress(int userId) {

        String sql
                = "SELECT ua.*, "
                + "w.ward_name, "
                + "w.district_id, "
                + "d.district_name, "
                + "d.province_id, "
                + "p.province_name "
                + "FROM User_Address ua "
                + "JOIN Ward w ON ua.ward_id = w.id "
                + "JOIN District d ON w.district_id = d.id "
                + "JOIN Province p ON d.province_id = p.id "
                + "WHERE ua.user_id = ? "
                + "AND ua.is_default = 1";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(rs.getString("recipient_name"));
                a.setRecipientPhone(rs.getString("recipient_phone"));
                a.setWardId(rs.getString("ward_id"));
                a.setDistrictId(rs.getString("district_id"));
                a.setProvinceId(rs.getString("province_id"));
                a.setWardName(rs.getString("ward_name"));
                a.setDistrictName(rs.getString("district_name"));
                a.setProvinceName(rs.getString("province_name"));
                a.setAddressDetail(rs.getString("address_detail"));
                a.setDefault(rs.getBoolean("is_default"));

                return a;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateAddress(
            UserAddress address) {

        String sql
                = "UPDATE User_Address "
                + "SET recipient_name=?, "
                + "recipient_phone=?, "
                + "ward_id=?, "
                + "address_detail=?, "
                + "is_default=? "
                + "WHERE id=?";

        try (
                 Connection con
                = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            if (address.isDefault()) {

                clearDefaultAddress(
                        con,
                        address.getUserId());
            }

            try (
                     PreparedStatement ps
                    = con.prepareStatement(sql)) {

                ps.setString(
                        1,
                        address.getRecipientName());

                ps.setString(
                        2,
                        address.getRecipientPhone());

                ps.setString(
                        3,
                        address.getWardId());

                ps.setString(
                        4,
                        address.getAddressDetail());

                ps.setBoolean(
                        5,
                        address.isDefault());

                ps.setInt(
                        6,
                        address.getId());

                int rows
                        = ps.executeUpdate();

                con.commit();

                return rows > 0;
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return false;
    }

    public boolean setDefaultAddress(
            int userId,
            int addressId) {

        try (
                 Connection con
                = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            clearDefaultAddress(
                    con,
                    userId);

            String sql
                    = "UPDATE User_Address "
                    + "SET is_default = 1 "
                    + "WHERE id = ?";

            try (
                     PreparedStatement ps
                    = con.prepareStatement(sql)) {

                ps.setInt(
                        1,
                        addressId);

                ps.executeUpdate();
            }

            con.commit();

            return true;

        } catch (Exception e) {

            e.printStackTrace();
        }

        return false;
    }

    private Integer getAnotherAddressId(
            Connection con,
            int userId,
            int deletedId)
            throws SQLException {

        String sql
                = "SELECT TOP 1 id "
                + "FROM User_Address "
                + "WHERE user_id=? "
                + "AND id<>?";

        try (
                 PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, deletedId);

            ResultSet rs
                    = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt("id");
            }
        }

        return null;
    }

    public boolean deleteAddress(
            int userId,
            int addressId) {

        try (
                 Connection con
                = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            UserAddress address
                    = getAddressById(addressId);

            if (address == null) {

                return false;
            }

            String deleteSql
                    = "DELETE FROM User_Address "
                    + "WHERE id=?";

            try (
                     PreparedStatement ps
                    = con.prepareStatement(deleteSql)) {

                ps.setInt(1, addressId);

                ps.executeUpdate();
            }

            if (address.isDefault()) {

                Integer newDefaultId
                        = getAnotherAddressId(
                                con,
                                userId,
                                addressId);

                if (newDefaultId != null) {

                    String setSql
                            = "UPDATE User_Address "
                            + "SET is_default=1 "
                            + "WHERE id=?";

                    try (
                             PreparedStatement ps
                            = con.prepareStatement(setSql)) {

                        ps.setInt(
                                1,
                                newDefaultId);

                        ps.executeUpdate();
                    }
                }
            }

            con.commit();

            return true;

        } catch (Exception e) {

            e.printStackTrace();
        }

        return false;
    }
}
