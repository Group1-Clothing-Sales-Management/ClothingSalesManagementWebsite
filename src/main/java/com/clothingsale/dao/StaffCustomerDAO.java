package com.clothingsale.dao;

import com.clothingsale.model.StaffCustomer;
import com.clothingsale.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffCustomerDAO {

    private static final int CUSTOMER_ROLE_ID = 3;

    // ----------------------------------------------------------------
    // GET ALL CUSTOMERS (with optional search keyword)
    // ----------------------------------------------------------------
    public List<StaffCustomer> getAllCustomers(String keyword) {
        List<StaffCustomer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, username, full_name, email, phone, avatar_url, status, " +
                        "       CONVERT(VARCHAR(19), created_at, 120) AS created_at, " +
                        "       CONVERT(VARCHAR(19), updated_at, 120) AS updated_at " +
                        "FROM [User] " +
                        "WHERE role_id = ? ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ");
        }
        sql.append("ORDER BY id DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, CUSTOMER_ROLE_ID);
            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(2, k);
                ps.setString(3, k);
                ps.setString(4, k);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ----------------------------------------------------------------
    // GET SINGLE CUSTOMER BY ID
    // ----------------------------------------------------------------
    public StaffCustomer getCustomerById(int id) {
        String sql = "SELECT id, username, full_name, email, phone, avatar_url, status, " +
                "       CONVERT(VARCHAR(19), created_at, 120) AS created_at, " +
                "       CONVERT(VARCHAR(19), updated_at, 120) AS updated_at " +
                "FROM [User] WHERE id = ? AND role_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, CUSTOMER_ROLE_ID);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ----------------------------------------------------------------
    // ADD NEW CUSTOMER (BR2, BR3)
    // ----------------------------------------------------------------
    public boolean addCustomer(StaffCustomer c, String hashedPassword) {
        String sql = "INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) " +
                "VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getUsername());
            ps.setString(2, hashedPassword);
            ps.setString(3, c.getFullName());
            ps.setString(4, c.getEmail());
            ps.setString(5, c.getPhone());
            ps.setInt(6, CUSTOMER_ROLE_ID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // UPDATE CUSTOMER (BR2, BR3)
    // ----------------------------------------------------------------
    public boolean updateCustomer(StaffCustomer c) {
        String sql = "UPDATE [User] SET full_name = ?, email = ?, phone = ?, status = ?, updated_at = GETDATE() " +
                "WHERE id = ? AND role_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getFullName());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getPhone());
            ps.setString(4, c.getStatus());
            ps.setInt(5, c.getId());
            ps.setInt(6, CUSTOMER_ROLE_ID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // CHECK DUPLICATE EMAIL (BR3)
    // ----------------------------------------------------------------
    public boolean isEmailExists(String email, int excludeId) {
        String sql = "SELECT COUNT(*) FROM [User] WHERE email = ? AND id <> ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // CHECK DUPLICATE PHONE (BR3)
    // ----------------------------------------------------------------
    public boolean isPhoneExists(String phone, int excludeId) {
        String sql = "SELECT COUNT(*) FROM [User] WHERE phone = ? AND id <> ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, phone);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // CHECK DUPLICATE USERNAME (BR3)
    // ----------------------------------------------------------------
    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM [User] WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // HELPER: map ResultSet row -> StaffCustomer
    // ----------------------------------------------------------------
    private StaffCustomer mapRow(ResultSet rs) throws SQLException {
        return new StaffCustomer(
                rs.getInt("id"),
                rs.getString("username"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("avatar_url"),
                rs.getString("status"),
                rs.getString("created_at"),
                rs.getString("updated_at"));
    }
}