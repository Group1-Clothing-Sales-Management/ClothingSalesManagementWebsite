package com.clothingsale.listener;

import com.clothingsale.util.ProductImageStorage;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.IOException;
import java.nio.file.Path;

/** Ensures the configured product upload directory exists at startup. */
@WebListener
public class ProductUploadDirectoryListener
        implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        try {
            Path uploadDirectory = ProductImageStorage.getUploadDirectory();
            event.getServletContext().log(
                    "Product image upload directory: " + uploadDirectory
            );
        } catch (IOException e) {
            event.getServletContext().log(
                    "Could not create the product image upload directory.",
                    e
            );
            throw new IllegalStateException(
                    "Product image upload directory is unavailable.",
                    e
            );
        }
    }
}
