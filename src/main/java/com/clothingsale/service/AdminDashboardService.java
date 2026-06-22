package com.clothingsale.service;

import com.clothingsale.dao.AdminDashboardDAO;
import com.clothingsale.model.DashboardStats;

public class AdminDashboardService {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    public DashboardStats getDashboardOverview() {
        return dashboardDAO.getDashboardOverviewStats();
    }
}
