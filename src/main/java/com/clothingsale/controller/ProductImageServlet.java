package com.clothingsale.controller;

import com.clothingsale.util.ProductImageStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet(
        name = "ProductImageServlet",
        urlPatterns = {"/media/product/*"}
)
public class ProductImageServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND
            );
            return;
        }

        String fileName = Paths.get(pathInfo)
                .getFileName()
                .toString();

        Path imageFile;

        try {
            imageFile = ProductImageStorage.resolveFile(fileName);
        } catch (IOException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        if (!Files.isRegularFile(imageFile)) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND
            );
            return;
        }

        String contentType = Files.probeContentType(imageFile);

        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(imageFile));
        response.setHeader(
                "Cache-Control",
                "public, max-age=86400"
        );

        try (OutputStream outputStream
                = response.getOutputStream()) {

            Files.copy(imageFile, outputStream);
        }
    }
}
