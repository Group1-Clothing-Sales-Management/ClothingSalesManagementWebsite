package com.clothingsale.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.Normalizer;
import java.util.Locale;

public final class ProductImageStorage {

    private static final String DIRECTORY_PROPERTY
            = "clothingsale.upload.dir";

    private static final String DIRECTORY_ENVIRONMENT_VARIABLE
            = "CLOTHINGSALE_UPLOAD_DIR";

    private ProductImageStorage() {
    }

    public static Path getUploadDirectory() throws IOException {
        String configuredDirectory
                = System.getProperty(DIRECTORY_PROPERTY);

        if (configuredDirectory == null
                || configuredDirectory.trim().isEmpty()) {

            configuredDirectory = System.getenv(
                    DIRECTORY_ENVIRONMENT_VARIABLE
            );
        }

        Path uploadDirectory;

        if (configuredDirectory != null
                && !configuredDirectory.trim().isEmpty()) {

            uploadDirectory = Paths.get(
                    configuredDirectory.trim()
            );

        } else {
            uploadDirectory = Paths.get(
                    System.getProperty("user.dir"),
                    "upload"
            );
        }

        uploadDirectory
                = uploadDirectory.toAbsolutePath().normalize();

        Files.createDirectories(uploadDirectory);

        return uploadDirectory;
    }

    public static Path resolveFile(String fileName)
            throws IOException {

        if (fileName == null || fileName.trim().isEmpty()) {
            throw new IOException("Image file name is empty");
        }

        String safeFileName = Paths.get(fileName)
                .getFileName()
                .toString();

        if (safeFileName.isBlank()) {
            throw new IOException("Invalid image file name");
        }

        Path uploadDirectory = getUploadDirectory();

        Path targetFile = uploadDirectory
                .resolve(safeFileName)
                .normalize();

        if (!targetFile.startsWith(uploadDirectory)) {
            throw new IOException("Invalid image file path");
        }

        return targetFile;
    }

    /*
     * Ví dụ:
     * p1_main_00.jpg
     * p1_main_01.jpg
     */
    public static String buildProductImageName(
            int productId,
            int imageIndex,
            String extension) {

        validateId(productId, "Product ID");

        if (imageIndex < 0) {
            throw new IllegalArgumentException(
                    "Image index cannot be negative"
            );
        }

        return "p"
                + productId
                + "_main_"
                + String.format(
                        Locale.ROOT,
                        "%02d",
                        imageIndex
                )
                + "."
                + normalizeExtension(extension);
    }

    /*
     * Ví dụ:
     * p1_v5_m_black.jpg
     */
    public static String buildVariantImageName(
            int productId,
            int variantId,
            String size,
            String color,
            String extension) {

        validateId(productId, "Product ID");
        validateId(variantId, "Variant ID");

        String safeSize = normalizeNamePart(size);
        String safeColor = normalizeNamePart(color);

        return "p"
                + productId
                + "_v"
                + variantId
                + "_"
                + safeSize
                + "_"
                + safeColor
                + "."
                + normalizeExtension(extension);
    }

    public static String normalizeExtension(String extension) {
        if (extension == null || extension.isBlank()) {
            throw new IllegalArgumentException(
                    "Image extension is required"
            );
        }

        String normalized = extension
                .trim()
                .toLowerCase(Locale.ROOT);

        if (normalized.startsWith(".")) {
            normalized = normalized.substring(1);
        }

        if ("jpeg".equals(normalized)) {
            normalized = "jpg";
        }

        if (!"jpg".equals(normalized)
                && !"png".equals(normalized)
                && !"webp".equals(normalized)) {

            throw new IllegalArgumentException(
                    "Unsupported image extension"
            );
        }

        return normalized;
    }

    private static String normalizeNamePart(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(
                    "Size and color are required"
            );
        }

        String normalized = Normalizer.normalize(
                value.trim(),
                Normalizer.Form.NFD
        );

        normalized = normalized
                .replaceAll("\\p{M}+", "")
                .replace('đ', 'd')
                .replace('Đ', 'd')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "_")
                .replaceAll("^_+|_+$", "");

        if (normalized.isBlank()) {
            throw new IllegalArgumentException(
                    "Invalid image name value"
            );
        }

        return normalized;
    }

    private static void validateId(int id, String fieldName) {
        if (id <= 0) {
            throw new IllegalArgumentException(
                    fieldName + " must be greater than zero"
            );
        }
    }
}