package com.clothingsale.controller;

import com.clothingsale.util.ProductImageStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

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

        String fileName = Paths.get(pathInfo.replace('\\', '/'))
                .getFileName()
                .toString();

        if (fileName.isEmpty() || !isSupportedImage(fileName)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path imageFile;

        try {
            imageFile = ProductImageStorage.resolveFile(fileName);
        } catch (IOException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        if (Files.isRegularFile(imageFile)) {
            streamFile(response, imageFile);
            return;
        }

        // Seed images are packaged in the WAR under /upload. This fallback
        // keeps them available even when Tomcat's working directory is not
        // the project directory.
        try (InputStream inputStream = openBundledImage(fileName)) {
            if (inputStream == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            response.setContentType(contentTypeFor(fileName));
            response.setHeader("Cache-Control", "public, max-age=86400");
            copy(inputStream, response.getOutputStream());
        }
    }

    private InputStream openBundledImage(String fileName) {
        InputStream inputStream = getServletContext()
                .getResourceAsStream("/upload/" + fileName);
        if (inputStream == null) {
            // Compatibility with deployments created before the upload
            // directory was moved outside the web application.
            inputStream = getServletContext()
                    .getResourceAsStream("/uploads/product/" + fileName);
        }
        return inputStream;
    }

    private void streamFile(
            HttpServletResponse response,
            Path imageFile
    ) throws IOException {
        response.setContentType(contentTypeFor(imageFile.getFileName().toString()));
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

    private void copy(InputStream inputStream, OutputStream outputStream)
            throws IOException {
        try (OutputStream output = outputStream) {
            byte[] buffer = new byte[8192];
            int count;
            while ((count = inputStream.read(buffer)) != -1) {
                output.write(buffer, 0, count);
            }
        }
    }

    private boolean isSupportedImage(String fileName) {
        String lowerName = fileName.toLowerCase(Locale.ROOT);
        return lowerName.endsWith(".jpg")
                || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".png")
                || lowerName.endsWith(".gif")
                || lowerName.endsWith(".webp")
                || lowerName.endsWith(".svg");
    }

    private String contentTypeFor(String fileName) {
        String lowerName = fileName.toLowerCase(Locale.ROOT);
        if (lowerName.endsWith(".png")) {
            return "image/png";
        }
        if (lowerName.endsWith(".gif")) {
            return "image/gif";
        }
        if (lowerName.endsWith(".webp")) {
            return "image/webp";
        }
        if (lowerName.endsWith(".svg")) {
            return "image/svg+xml";
        }
        return "image/jpeg";
    }
}
