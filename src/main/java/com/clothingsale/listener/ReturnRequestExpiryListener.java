package com.clothingsale.listener;

import com.clothingsale.service.ReturnRequestService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/** Tự động kiểm tra và hủy request Approved quá 3 ngày chưa nhận được hàng. */
@WebListener
public class ReturnRequestExpiryListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private final ReturnRequestService service = new ReturnRequestService();

    @Override
    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread thread = new Thread(r, "return-request-expiry");
            thread.setDaemon(true);
            return thread;
        });
        // Chạy ngay khi ứng dụng khởi động, sau đó lặp lại mỗi giờ.
        scheduler.scheduleWithFixedDelay(service::expireUnreceivedApprovedRequests, 0, 1, TimeUnit.HOURS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) scheduler.shutdownNow();
    }
}
