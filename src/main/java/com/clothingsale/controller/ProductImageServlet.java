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

    private static final int BUFFER_SIZE = 8192;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String fileName = extractFileName(
                request.getPathInfo()
        );

        if (fileName == null
                || !isSupportedImage(fileName)) {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND
            );
            return;
        }

        Path imageFile;

        try {
            imageFile = ProductImageStorage.resolveFile(
                    fileName
            );
        } catch (IOException exception) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        if (Files.isRegularFile(imageFile)) {
            streamExternalFile(
                    request,
                    response,
                    imageFile
            );
            return;
        }

        /*
         * Chỉ dùng cho ảnh cũ từng được đóng gói trong web application.
         * Ảnh mới do Admin upload sẽ được đọc từ:
         * <project-root>/upload/product/
         */
        try (InputStream inputStream
                = openBundledImage(fileName)) {

            if (inputStream == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND
                );
                return;
            }

            prepareImageResponse(
                    response,
                    fileName
            );

            copy(
                    inputStream,
                    response.getOutputStream()
            );
        }
    }

    private String extractFileName(String pathInfo) {
        if (pathInfo == null
                || pathInfo.trim().isEmpty()) {

            return null;
        }

        try {
            String normalizedPath
                    = pathInfo.replace('\\', '/');

            Path path = Paths.get(normalizedPath);
            Path name = path.getFileName();

            if (name == null) {
                return null;
            }

            String fileName = name.toString().trim();

            if (fileName.isEmpty()
                    || ".".equals(fileName)
                    || "..".equals(fileName)) {

                return null;
            }

            return fileName;

        } catch (Exception exception) {
            return null;
        }
    }

    private void streamExternalFile(
            HttpServletRequest request,
            HttpServletResponse response,
            Path imageFile
    ) throws IOException {

        long lastModified
                = Files.getLastModifiedTime(
                        imageFile
                ).toMillis();

        long ifModifiedSince
                = request.getDateHeader(
                        "If-Modified-Since"
                );

        /*
         * HTTP date chỉ chính xác tới giây.
         */
        if (ifModifiedSince >= 0
                && lastModified / 1000
                <= ifModifiedSince / 1000) {

            response.setStatus(
                    HttpServletResponse.SC_NOT_MODIFIED
            );
            return;
        }

        String fileName
                = imageFile.getFileName().toString();

        prepareImageResponse(
                response,
                fileName
        );

        response.setDateHeader(
                "Last-Modified",
                lastModified
        );

        response.setContentLengthLong(
                Files.size(imageFile)
        );

        try (InputStream inputStream
                = Files.newInputStream(imageFile)) {

            copy(
                    inputStream,
                    response.getOutputStream()
            );
        }
    }

    private void prepareImageResponse(
            HttpServletResponse response,
            String fileName
    ) {
        response.setContentType(
                contentTypeFor(fileName)
        );

        /*
         * Không giữ ảnh cũ sau khi Admin ghi đè file cùng tên.
         * Các URL có ?v=updatedAt vẫn tiếp tục hoạt động bình thường.
         */
        response.setHeader(
                "Cache-Control",
                "no-cache, max-age=0, must-revalidate"
        );

        response.setHeader(
                "X-Content-Type-Options",
                "nosniff"
        );
    }

    private InputStream openBundledImage(
            String fileName
    ) {
        InputStream inputStream
                = getServletContext().getResourceAsStream(
                        "/upload/product/" + fileName
                );

        if (inputStream == null) {
            inputStream
                    = getServletContext().getResourceAsStream(
                            "/upload/" + fileName
                    );
        }

        if (inputStream == null) {
            inputStream
                    = getServletContext().getResourceAsStream(
                            "/uploads/product/" + fileName
                    );
        }

        return inputStream;
    }

    private void copy(
            InputStream inputStream,
            OutputStream outputStream
    ) throws IOException {

        byte[] buffer = new byte[BUFFER_SIZE];
        int count;

        while ((count = inputStream.read(buffer)) != -1) {
            outputStream.write(
                    buffer,
                    0,
                    count
            );
        }

        outputStream.flush();
    }

    private boolean isSupportedImage(
            String fileName
    ) {
        String lowerName
                = fileName.toLowerCase(Locale.ROOT);

        return lowerName.endsWith(".jpg")
                || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".png")
                || lowerName.endsWith(".gif")
                || lowerName.endsWith(".webp")
                || lowerName.endsWith(".svg");
    }

    private String contentTypeFor(
            String fileName
    ) {
        String lowerName
                = fileName.toLowerCase(Locale.ROOT);

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