package com.clothingsale.dao;

import com.clothingsale.model.CartItem;
import com.clothingsale.model.Order;
import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Voucher;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerOrderDAO {

    private final CartDAO cartDAO
            = new CartDAO();

    public List<CartItem> getCartItems(
            int userId) {

        return new ArrayList<>(
                cartDAO.loadCart(userId)
                        .values());
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

    public int createOrder(
            Connection con,
            Order order)
            throws SQLException {

        String sql
                = "INSERT INTO [Order]("
                + "order_code,"
                + "user_id,"
                + "voucher_id,"
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
                + ")"
                + "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

        PreparedStatement ps
                = con.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS);

        ps.setString(1, order.getOrderCode());
        ps.setInt(2, order.getUserId());

        if (order.getVoucherId() == 0) {
            ps.setNull(3, Types.INTEGER);
        } else {
            ps.setInt(3, order.getVoucherId());
        }

        ps.setString(4, order.getRecipientName());
        ps.setString(5, order.getRecipientPhone());
        ps.setString(6, order.getWardId());
        ps.setString(7, order.getAddressDetail());

        ps.setBigDecimal(8, order.getTotalItemsPrice());
        ps.setBigDecimal(9, order.getDiscountAmount());
        ps.setBigDecimal(10, order.getShippingFee());
        ps.setBigDecimal(11, order.getTotalPayment());

        ps.setString(12, order.getOrderStatus());
        ps.setString(13, order.getNote());

        ps.executeUpdate();

        ResultSet rs = ps.getGeneratedKeys();

        if (rs.next()) {
            return rs.getInt(1);
        }

        return 0;
    }

    private BigDecimal calculateDiscount(
            Voucher voucher,
            BigDecimal subtotal) {

        if (voucher == null) {

            return BigDecimal.ZERO;
        }

        if (subtotal.compareTo(
                voucher.getMinOrderValue())
                < 0) {

            return BigDecimal.ZERO;
        }

        BigDecimal discount
                = BigDecimal.ZERO;

        if ("PERCENT".equalsIgnoreCase(
                voucher.getDiscountType())) {

            discount
                    = subtotal.multiply(
                            voucher.getDiscountValue())
                            .divide(
                                    BigDecimal.valueOf(
                                            100));

            if (voucher.getMaxDiscountAmount()
                    != null
                    && discount.compareTo(
                            voucher.getMaxDiscountAmount())
                    > 0) {

                discount
                        = voucher.getMaxDiscountAmount();
            }

        } else {

            discount
                    = voucher.getDiscountValue();
        }

        return discount;
    }

    public boolean placeOrder(
            int userId,
            int addressId,
            String voucherCode,
            String note) {

        Connection con = null;

        try {

            con = DBConnection.getConnection();

            con.setAutoCommit(false);

            List<CartItem> cartItems
                    = getCartItems(userId);

            if (cartItems.isEmpty()) {
                return false;
            }

            UserAddress address
                    = getAddressById(addressId);

            if (address == null) {
                return false;
            }

            BigDecimal subtotal
                    = BigDecimal.ZERO;

            for (CartItem item : cartItems) {

                subtotal = subtotal.add(
                        item.getPrice()
                                .multiply(
                                        BigDecimal.valueOf(
                                                item.getQuantity())));
            }

            Voucher voucher
                    = applyVoucher(voucherCode);

            BigDecimal discount
                    = calculateDiscount(
                            voucher,
                            subtotal);

            BigDecimal shippingFee
                    = BigDecimal.valueOf(30000);

            BigDecimal totalPayment
                    = subtotal
                            .subtract(discount)
                            .add(shippingFee);

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
                            note);

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

            clearCart(
                    con,
                    userId);

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

    private int createOrder(
            Connection con,
            int userId,
            Voucher voucher,
            UserAddress address,
            BigDecimal subtotal,
            BigDecimal discount,
            BigDecimal shippingFee,
            BigDecimal totalPayment,
            String note)
            throws SQLException {

        String sql = "INSERT INTO [Order] "
                + "( "
                + "    order_code, "
                + "    user_id, "
                + "    voucher_id, "
                + "    recipient_name, "
                + "    recipient_phone, "
                + "    ward_id, "
                + "    address_detail, "
                + "    total_items_price, "
                + "    discount_amount, "
                + "    shipping_fee, "
                + "    total_payment, "
                + "    order_status, "
                + "    note "
                + ") "
                + "VALUES "
                + "( "
                + "    ?,?,?,?,?,?,?,?,?,?,?,?,? "
                + ")";

        PreparedStatement ps
                = con.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS);

        String orderCode
                = "ORD"
                + System.currentTimeMillis();

        ps.setString(1, orderCode);

        ps.setInt(2, userId);

        if (voucher == null) {
            ps.setNull(3, Types.INTEGER);
        } else {
            ps.setInt(3, voucher.getId());
        }

        ps.setString(
                4,
                address.getRecipientName());

        ps.setString(
                5,
                address.getRecipientPhone());

        ps.setString(
                6,
                address.getWardId());

        ps.setString(
                7,
                address.getAddressDetail());

        ps.setBigDecimal(
                8,
                subtotal);

        ps.setBigDecimal(
                9,
                discount);

        ps.setBigDecimal(
                10,
                shippingFee);

        ps.setBigDecimal(
                11,
                totalPayment);

        ps.setString(
                12,
                "PENDING");

        ps.setString(
                13,
                note);

        ps.executeUpdate();

        ResultSet rs
                = ps.getGeneratedKeys();

        if (rs.next()) {
            return rs.getInt(1);
        }

        throw new SQLException();
    }

    public Voucher applyVoucher(
            String code) {

        if (code == null
                || code.trim().isEmpty()) {

            return null;
        }

        String sql
                = "SELECT * "
                + "FROM Voucher "
                + "WHERE code=? "
                + "AND GETDATE() "
                + "BETWEEN start_date "
                + "AND end_date";

        try (
                 Connection con
                = DBConnection.getConnection();  PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setString(1, code);

            ResultSet rs
                    = ps.executeQuery();

            if (rs.next()) {

                Voucher v
                        = new Voucher();

                v.setId(
                        rs.getInt("id"));

                v.setCode(
                        rs.getString("code"));

                v.setDiscountType(
                        rs.getString("discount_type"));

                v.setDiscountValue(
                        rs.getBigDecimal(
                                "discount_value"));

                v.setMaxDiscountAmount(
                        rs.getBigDecimal(
                                "max_discount_amount"));

                v.setMinOrderValue(
                        rs.getBigDecimal(
                                "min_order_value"));

                return v;
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return null;
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

    public void decreaseStock(
            Connection con,
            int variantId,
            int quantity)
            throws SQLException {

        String sql
                = "UPDATE Product_Variant "
                + "SET stock_quantity = stock_quantity - ? "
                + "WHERE id=?";

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(1, quantity);
        ps.setInt(2, variantId);

        ps.executeUpdate();
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
