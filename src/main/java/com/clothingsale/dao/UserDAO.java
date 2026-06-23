package com.clothingsale.dao;

import com.clothingsale.model.User;
import com.clothingsale.util.DBConnection;
import com.clothingsale.util.SecurityUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class UserDAO {

    private static final String FIND_BY_USERNAME_SQL
            = "SELECT u.id, u.username, u.password, u.full_name, u.email, u.phone, u.avatar_url, "
            + "u.status, u.created_at, u.updated_at, u.role_id, r.role_name "
            + "FROM [User] u "
            + "LEFT JOIN Role r ON u.role_id = r.id "
            + "WHERE u.username = ?";

        private static final String FIND_BY_USERNAME_OR_EMAIL_SQL
            = "SELECT u.id, u.username, u.password, u.full_name, u.email, u.phone, u.avatar_url, "
            + "u.status, u.created_at, u.updated_at, u.role_id, r.role_name "
            + "FROM [User] u "
            + "LEFT JOIN Role r ON u.role_id = r.id "
            + "WHERE u.username = ? OR u.email = ?";

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

    public User findByUsernameOrEmail(String input) {
        if (input == null || input.trim().isEmpty()) return null;
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return null;
            try (PreparedStatement ps = conn.prepareStatement(FIND_BY_USERNAME_OR_EMAIL_SQL)) {
                ps.setString(1, input.trim());
                ps.setString(2, input.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapUser(rs);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public User findById(int id) {
        if (id <= 0) {
            return null;
        }

        String sql = "SELECT u.id, u.username, u.password, u.full_name, u.email, u.phone, u.avatar_url, "
                + "u.status, u.created_at, u.updated_at, u.role_id, r.role_name "
                + "FROM [User] u "
                + "LEFT JOIN Role r ON u.role_id = r.id "
                + "WHERE u.id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public boolean isEmailUsedByOtherUser(String email, int currentUserId) {
        if (email == null || email.trim().isEmpty() || currentUserId <= 0) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM [User] WHERE email = ? AND id <> ?";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email.trim());
                ps.setInt(2, currentUserId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() && rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public boolean updateCustomerProfile(User user) {
        if (user == null || user.getId() <= 0
                || user.getFullName() == null || user.getFullName().trim().isEmpty()
                || user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE [User] "
                + "SET full_name = ?, email = ?, phone = ?, avatar_url = ?, updated_at = GETDATE() "
                + "WHERE id = ? AND role_id = (SELECT id FROM Role WHERE role_name = 'CUSTOMER')";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, user.getFullName().trim());
                ps.setString(2, user.getEmail().trim());
                ps.setString(3, normalizeNullable(user.getPhone()));
                ps.setString(4, normalizeNullable(user.getAvatarUrl()));
                ps.setInt(5, user.getId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private String normalizeNullable(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
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

    public boolean createCustomer(User user, String plainPassword) {
        if (user == null || user.getUsername() == null || user.getUsername().trim().isEmpty()
                || user.getEmail() == null || user.getEmail().trim().isEmpty()
                || plainPassword == null || plainPassword.isEmpty()) {
            return false;
        }

        String insertSql = "INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) "
                + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', (SELECT id FROM Role WHERE role_name = 'CUSTOMER'))";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return false;

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, user.getUsername().trim());
                ps.setString(2, SecurityUtil.hashPassword(plainPassword));
                ps.setString(3, user.getFullName());
                ps.setString(4, user.getEmail().trim());
                ps.setString(5, user.getPhone());

                int updated = ps.executeUpdate();
                return updated > 0;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    /**
     * Create a customer in PENDING status and return generated user id, or -1 on failure
     */
    public int createCustomerPending(User user, String plainPassword) {
        if (user == null || user.getUsername() == null || user.getUsername().trim().isEmpty()
                || user.getEmail() == null || user.getEmail().trim().isEmpty()
                || plainPassword == null || plainPassword.isEmpty()) {
            return -1;
        }

        String insertSql = "INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) "
                + "VALUES (?, ?, ?, ?, ?, 'PENDING', (SELECT id FROM Role WHERE role_name = 'CUSTOMER'))";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return -1;

            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getUsername().trim());
                ps.setString(2, SecurityUtil.hashPassword(plainPassword));
                ps.setString(3, user.getFullName());
                ps.setString(4, user.getEmail().trim());
                ps.setString(5, user.getPhone());

                int updated = ps.executeUpdate();
                if (updated > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            return keys.getInt(1);
                        }
                    }
                }
                return -1;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return -1;
        }
    }

    public boolean createSecurityToken(int userId, String tokenValue, java.sql.Timestamp expiry) {
        String insert = "INSERT INTO Security_Token (user_id, token_type, token_value, expiry_date, is_used) "
                + "VALUES (?, 'EMAIL_VERIFICATION', ?, ?, 0)";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(insert)) {
                ps.setInt(1, userId);
                ps.setString(2, tokenValue);
                ps.setTimestamp(3, expiry);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public boolean verifyTokenForUser(int userId, String tokenValue) {
        String select = "SELECT id, expiry_date, is_used FROM Security_Token WHERE user_id = ? AND token_value = ? AND token_type = 'EMAIL_VERIFICATION'";
        String markUsed = "UPDATE Security_Token SET is_used = 1 WHERE id = ?";
        String activateUser = "UPDATE [User] SET status = 'ACTIVE' WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return false;

            try (PreparedStatement ps = conn.prepareStatement(select)) {
                ps.setInt(1, userId);
                ps.setString(2, tokenValue);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int tokenId = rs.getInt("id");
                        java.sql.Timestamp expiry = rs.getTimestamp("expiry_date");
                        boolean isUsed = rs.getBoolean("is_used");
                        if (isUsed) return false;
                        if (expiry != null && expiry.before(new java.sql.Timestamp(System.currentTimeMillis()))) return false;

                        // mark token used
                        try (PreparedStatement ps2 = conn.prepareStatement(markUsed)) {
                            ps2.setInt(1, tokenId);
                            ps2.executeUpdate();
                        }

                        // activate user
                        try (PreparedStatement ps3 = conn.prepareStatement(activateUser)) {
                            ps3.setInt(1, userId);
                            ps3.executeUpdate();
                        }

                        return true;
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
        return false;
    }
}
