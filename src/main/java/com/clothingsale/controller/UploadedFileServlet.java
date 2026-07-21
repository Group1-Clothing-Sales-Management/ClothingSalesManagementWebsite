package com.clothingsale.controller;

import com.clothingsale.util.UserUploadStorage;
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
import java.util.Locale;

/** Serves avatar and refund-proof images stored outside the WAR. */
@WebServlet(
        name = "UploadedFileServlet",
        urlPatterns = {"/uploads/*"}
)
public class UploadedFileServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String relativePath = pathInfo.replace('\\', '/');
        if (relativePath.contains("..") || !isSupportedImage(relativePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path file = null;
        try {
            Path externalFile = UserUploadStorage.resolveFile(relativePath);
            if (Files.isRegularFile(externalFile)) {
                file = externalFile;
            }
        } catch (IOException ignored) {
            // The deployed application's upload directory may not exist yet.
        }

        if (file != null) {
            streamFile(response, file);
            return;
        }

        // Preserve files uploaded by older deployments into the exploded WAR.
        String resourcePath = "/uploads/"
                + relativePath.replaceFirst("^/", "");
        try (InputStream inputStream = getServletContext()
                .getResourceAsStream(resourcePath)) {
            if (inputStream == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            response.setContentType(contentTypeFor(relativePath));
            response.setHeader("Cache-Control", "private, max-age=3600");
            copy(inputStream, response.getOutputStream());
        }
    }

    private void streamFile(
            HttpServletResponse response,
            Path file
    ) throws IOException {
        response.setContentType(contentTypeFor(file.getFileName().toString()));
        response.setContentLengthLong(Files.size(file));
        response.setHeader("Cache-Control", "private, max-age=3600");
        try (OutputStream outputStream = response.getOutputStream()) {
            Files.copy(file, outputStream);
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

    private boolean isSupportedImage(String path) {
        String lowerPath = path.toLowerCase(Locale.ROOT);
        return lowerPath.endsWith(".jpg")
                || lowerPath.endsWith(".jpeg")
                || lowerPath.endsWith(".png")
                || lowerPath.endsWith(".gif")
                || lowerPath.endsWith(".webp")
                || lowerPath.endsWith(".svg");
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
