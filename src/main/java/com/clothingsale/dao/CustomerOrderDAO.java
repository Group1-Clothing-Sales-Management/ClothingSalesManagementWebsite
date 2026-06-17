package com.clothingsale.dao;

import com.clothingsale.model.UserAddress;
import com.clothingsale.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerOrderDAO {

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
