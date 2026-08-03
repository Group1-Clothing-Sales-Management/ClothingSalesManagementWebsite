//package com.clothingsale.util;
//
//import java.sql.Connection;
//import java.sql.DriverManager;
//import java.sql.SQLException;
//
//public class DBConnection {
//
//    private static final String JDBC_URL
//            = "jdbc:sqlserver://localhost:1433;databaseName=ClothesShopDB;encrypt=true;trustServerCertificate=true;";
//
//    private static final String USER = "sa";
//    private static final String PASSWORD = "123456";
//    private static final boolean DRIVER_LOADED = loadDriver();
//
//    private static boolean loadDriver() {
//        try {
//            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
//            return true;
//        } catch (ClassNotFoundException e) {
//            System.err.println("Could not find SQL Server JDBC driver.");
//            e.printStackTrace();
//            return false;
//        }
//    }
//
//    public static Connection getConnection() {
//        if (!DRIVER_LOADED) {
//            return null;
//        }
//
//        try {
//            return DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
//        } catch (SQLException e) {
//            System.err.println("Database connection failed. Check DB name, user, or password.");
//            e.printStackTrace();
//            return null;
//        }
//    }
//
//    public static void closeConnection(Connection conn) {
//        try {
//            if (conn != null && !conn.isClosed()) {
//                conn.close();
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//    }
//
//    public static void main(String[] args) {
//        System.out.println("Checking database connection...");
//
//        Connection testConn = DBConnection.getConnection();
//
//        if (testConn != null) {
//            System.out.println("Connection test succeeded.");
//            DBConnection.closeConnection(testConn);
//            System.out.println("Test connection closed.");
//        } else {
//            System.err.println("Connection test failed.");
//        }
//    }
//}
package com.clothingsale.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    private static final String JDBC_URL = "jdbc:sqlserver://localhost:1433;databaseName=ClothesShopDB;encrypt=true;trustServerCertificate=true;";
    private static final String USER = "sa";
    private static final String PASSWORD = "123456";
    private static final boolean DRIVER_LOADED = loadDriver();

    /** Nạp SQL Server JDBC Driver. */
    private static boolean loadDriver() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return true;
        } catch (ClassNotFoundException e) {
            System.err.println("Could not find SQL Server JDBC driver.");
            e.printStackTrace();
            return false;
        }
    }

    /** Mở kết nối và cấu hình phiên SQL Server. */
    public static Connection getConnection() {
        if (!DRIVER_LOADED) {
            return null;
        }

        Connection connection = null;
        try {
            connection = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            configureSession(connection);
            return connection;
        } catch (SQLException e) {
            closeConnection(connection);
            System.err.println("Database connection failed. Check DB name, user, password, or SQL session settings.");
            e.printStackTrace();
            return null;
        }
    }

    /** Bật các SET option bắt buộc cho indexed computed column. */
    private static void configureSession(Connection connection) throws SQLException {
        String sql = "SET ANSI_NULLS ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET QUOTED_IDENTIFIER ON; SET NUMERIC_ROUNDABORT OFF;";
        try (Statement statement = connection.createStatement()) {
            statement.execute(sql);
        }
    }

    /** Đóng kết nối an toàn. */
    public static void closeConnection(Connection connection) {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** Kiểm tra kết nối database. */
    public static void main(String[] args) {
        System.out.println("Checking database connection...");
        Connection testConnection = DBConnection.getConnection();

        if (testConnection != null) {
            System.out.println("Connection test succeeded.");
            DBConnection.closeConnection(testConnection);
            System.out.println("Test connection closed.");
        } else {
            System.err.println("Connection test failed.");
        }
    }
}
