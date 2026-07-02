package com.clothingsale.service;

import com.clothingsale.dao.StaffReportDAO;
import com.clothingsale.model.StaffReport;

public class StaffReportService {
    private final StaffReportDAO staffReportDAO = new StaffReportDAO();

    public StaffReport generateRevenueReport(String startDate, String endDate, String timePeriod, String categoryId) {
        if (timePeriod == null || timePeriod.isEmpty()) {
            timePeriod = "daily";
        }
        return staffReportDAO.getRevenueReport(startDate, endDate, timePeriod, categoryId);
    }
}