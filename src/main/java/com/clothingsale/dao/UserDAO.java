package com.clothingsale.dao;

import com.clothingsale.model.User;
import com.clothingsale.util.DBConnection;
import com.clothingsale.util.SecurityUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    private static final String FIND_BY_USERNAME_SQL
            = "SELECT u.id, u.username, u.password, u.full_name, u.email, u.phone, u.avatar_url, "
            + "u.status, u.created_at, u.updated_at, u.role_id, r.role_name "
            + "FROM [User] u "
            + "LEFT JOIN Role r ON u.role_id = r.id "
            + "WHERE u.username = ?";

    public User findByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(FIND_BY_USERNAME_SQL)) {
            ps.setString(1, username.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User authenticateInternalAccount(String username, String plainPassword) {
        User user = findByUsername(username);
        if (user == null || plainPassword == null) {
            return null;
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            return null;
        }

        String roleName = user.getRoleName();
        if (roleName == null
                || (!"ADMIN".equalsIgnoreCase(roleName) && !"STAFF".equalsIgnoreCase(roleName))) {
            return null;
        }

        if (isPasswordMatched(plainPassword, user.getPassword())) {
            return user;
        }

        return null;
    }

    private boolean isPasswordMatched(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }

        if (storedPassword.startsWith("$2")) {
            try {
                return SecurityUtil.checkPassword(plainPassword, storedPassword);
            } catch (IllegalArgumentException ex) {
                return false;
            }
        }

        return plainPassword.equals(storedPassword);
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        user.setRoleId(rs.getInt("role_id"));
        user.setRoleName(rs.getString("role_name"));
        return user;
    }
}
