package com.clothingsale.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Cấu hình kết nối SQL Server
    private static final String JDBC_URL = 
        "jdbc:sqlserver://localhost:1433;databaseName=ClothingSale;encrypt=true;trustServerCertificate=true;";
    
    private static final String USER = "sa";           // ← Thay bằng user của bạn
    private static final String PASSWORD = "123456";   // ← Thay bằng password của bạn

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            System.out.println("✅ Kết nối Database ClothingSale thành công!");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Không tìm thấy Driver SQL Server!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("❌ Lỗi kết nối Database! Kiểm tra tên DB, user, password.");
            e.printStackTrace();
        }
        return conn;
    }

    // Đóng connection an toàn
    public static void closeConnection(Connection conn) {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}