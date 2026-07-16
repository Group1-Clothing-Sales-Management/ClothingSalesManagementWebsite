package com.clothingsale.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String JDBC_URL
            = "jdbc:sqlserver://localhost:1433;databaseName=ClothesShopDB;encrypt=true;trustServerCertificate=true;";

    private static final String USER = "sa";
    private static final String PASSWORD = "123456";
    private static final boolean DRIVER_LOADED = loadDriver();

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

    public static Connection getConnection() {
        if (!DRIVER_LOADED) {
            return null;
        }

        try {
            return DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
        } catch (SQLException e) {
            System.err.println("Database connection failed. Check DB name, user, or password.");
            e.printStackTrace();
            return null;
        }
    }

    public static void closeConnection(Connection conn) {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        System.out.println("Checking database connection...");

        Connection testConn = DBConnection.getConnection();

        if (testConn != null) {
            System.out.println("Connection test succeeded.");
            DBConnection.closeConnection(testConn);
            System.out.println("Test connection closed.");
        } else {
            System.err.println("Connection test failed.");
        }
    }
}
