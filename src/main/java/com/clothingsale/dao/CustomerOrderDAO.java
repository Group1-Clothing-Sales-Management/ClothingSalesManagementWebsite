package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.OrderDetail;
import com.clothingsale.model.Shipment;
import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Voucher;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

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
                + "       s.shipping_status, p.payment_status, p.payment_method "
                + "FROM [Order] o "
                + "LEFT JOIN Voucher v ON o.voucher_id = v.id "
                + "LEFT JOIN Shipment s ON o.shipment_id = s.id "
                + "LEFT JOIN Payment p ON o.id = p.order_id "
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

                    boolean activeProduct =
                            "ACTIVE".equalsIgnoreCase(detail.getCurrentProductStatus());
                    boolean activeVariant =
                            "ACTIVE".equalsIgnoreCase(detail.getCurrentVariantStatus());
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

                    list.add(detail);
                }
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return list;
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

        if ("PERCENTAGE".equalsIgnoreCase(voucher.getDiscountType())) {

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
            if (voucher != null && hasUserUsedVoucher(userId, voucher.getId())) {
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
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Voucher SET used_count = used_count + 1 WHERE id=? AND used_count < usage_limit")) {
                    ps.setInt(1, voucher.getId());
                    if (ps.executeUpdate() == 0) {
                        throw new SQLException("Voucher usage limit reached");
                    }
                }
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

    String sql =
        "SELECT * FROM Voucher " +
        "WHERE code=? " +
        "AND GETDATE() BETWEEN start_date AND end_date " +
        "AND used_count < usage_limit";

    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql)
    ) {

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

                return v;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Voucher> getVouchersForUser(int userId) {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT v.*, (SELECT COUNT(*) FROM [Order] o "
                + "WHERE o.voucher_id=v.id AND o.user_id=? AND o.order_status <> 'CANCELLED') AS user_used_count "
                + "FROM Voucher v ORDER BY v.end_date ASC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
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
                    v.setUserUsedCount(rs.getInt("user_used_count"));
                    vouchers.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return vouchers;
    }

    private boolean hasUserUsedVoucher(int userId, int voucherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM [Order] WHERE user_id=? AND voucher_id=? AND order_status <> 'CANCELLED'";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
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

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
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

        try (PreparedStatement select = con.prepareStatement(selectSql);
                PreparedStatement update = con.prepareStatement(updateSql)) {

            select.setInt(1, orderId);

            try (ResultSet rs = select.executeQuery()) {
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
                = "SELECT * "
                + "FROM User_Address "
                + "WHERE user_id = ? "
                + "ORDER BY is_default DESC, id DESC";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(
                        rs.getString("recipient_name"));

                a.setRecipientPhone(
                        rs.getString("recipient_phone"));

                a.setWardId(
                        rs.getString("ward_id"));

                a.setAddressDetail(
                        rs.getString("address_detail"));

                a.setDefault(
                        rs.getBoolean("is_default"));

                list.add(a);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public UserAddress getAddressById(int id) {

        String sql
                = "SELECT * "
                + "FROM User_Address "
                + "WHERE id = ?";

        try (
                 Connection con = DBConnection.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(
                        rs.getString("recipient_name"));

                a.setRecipientPhone(
                        rs.getString("recipient_phone"));

                a.setWardId(
                        rs.getString("ward_id"));

                a.setAddressDetail(
                        rs.getString("address_detail"));

                a.setDefault(
                        rs.getBoolean("is_default"));

                return a;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
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

    public UserAddress getDefaultAddress(
            int userId) {

        String sql
                = "SELECT * "
                + "FROM User_Address "
                + "WHERE user_id = ? "
                + "AND is_default = 1";

        try (
                 Connection con
                = DBConnection.getConnection();  PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                UserAddress a = new UserAddress();

                a.setId(rs.getInt("id"));
                a.setUserId(rs.getInt("user_id"));

                a.setRecipientName(
                        rs.getString("recipient_name"));

                a.setRecipientPhone(
                        rs.getString("recipient_phone"));

                a.setWardId(
                        rs.getString("ward_id"));

                a.setAddressDetail(
                        rs.getString("address_detail"));

                a.setDefault(
                        rs.getBoolean("is_default"));

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
