package com.clothingsale.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Cấu hình kết nối SQL Server
    private static final String JDBC_URL
            = "jdbc:sqlserver://localhost:1433;databaseName=ClothesShopDB;encrypt=true;trustServerCertificate=true;";

    private static final String USER = "sa";
    private static final String PASSWORD = "123456";

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

    // Hàm main dùng để test kết nối trực tiếp
    public static void main(String[] args) {
        System.out.println("Đang kiểm tra kết nối...");

        // Gọi hàm getConnection() để mở kết nối
        Connection testConn = DBConnection.getConnection();

        // Kiểm tra kết quả
        if (testConn != null) {
            System.out.println(" Thử nghiệm thành công: Đối tượng Connection không bị null.");

            // Đóng kết nối sau khi test xong để giải phóng tài nguyên
            DBConnection.closeConnection(testConn);
            System.out.println("🔒 Đã đóng kết nối test an toàn.");
        } else {
            System.err.println(" Kết nối thất bại. Vui lòng kiểm tra lại cấu hình SQL Server hoặc Driver.");
        }
    }
}
