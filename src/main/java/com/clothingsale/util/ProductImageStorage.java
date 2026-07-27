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

    private static final String UPLOAD_DIRECTORY_NAME
            = "upload";

    private static final String PRODUCT_DIRECTORY_NAME
            = "product";

    private ProductImageStorage() {
    }

    public static Path getUploadDirectory() throws IOException {
        Path productUploadDirectory = resolveUploadDirectory();

        Files.createDirectories(productUploadDirectory);

        return productUploadDirectory;
    }

    private static Path resolveUploadDirectory() {
        String configuredDirectory
                = System.getProperty(DIRECTORY_PROPERTY);

        if (configuredDirectory == null
                || configuredDirectory.trim().isEmpty()) {

            configuredDirectory = System.getenv(
                    DIRECTORY_ENVIRONMENT_VARIABLE
            );
        }

        Path productUploadDirectory;

        if (configuredDirectory != null
                && !configuredDirectory.trim().isEmpty()) {

            Path configuredPath = Paths.get(
                    configuredDirectory.trim()
            ).toAbsolutePath().normalize();

            /*
             * Cho phép cấu hình theo một trong hai cách:
             * - .../upload
             * - .../upload/product
             */
            if (configuredPath.getFileName() != null
                    && PRODUCT_DIRECTORY_NAME.equalsIgnoreCase(
                            configuredPath.getFileName().toString()
                    )) {

                productUploadDirectory = configuredPath;

            } else {

                productUploadDirectory = configuredPath.resolve(
                        PRODUCT_DIRECTORY_NAME
                );
            }

        } else {

            Path projectRoot = findProjectRoot();

            productUploadDirectory = projectRoot
                    .resolve(UPLOAD_DIRECTORY_NAME)
                    .resolve(PRODUCT_DIRECTORY_NAME);
        }

        return productUploadDirectory
                .toAbsolutePath()
                .normalize();
    }

    private static Path findProjectRoot() {
        Path rootFromUserDirectory = findProjectRootFrom(
                Paths.get(System.getProperty("user.dir", "."))
        );

        if (rootFromUserDirectory != null) {
            return rootFromUserDirectory;
        }

        try {
            Path codeLocation = Paths.get(
                    ProductImageStorage.class
                            .getProtectionDomain()
                            .getCodeSource()
                            .getLocation()
                            .toURI()
            );

            Path rootFromCodeLocation
                    = findProjectRootFrom(codeLocation);

            if (rootFromCodeLocation != null) {
                return rootFromCodeLocation;
            }

        } catch (Exception ignored) {
            // Sử dụng user.dir làm phương án cuối.
        }

        return Paths.get(
                System.getProperty("user.dir", ".")
        ).toAbsolutePath().normalize();
    }

    private static Path findProjectRootFrom(Path startPath) {
        if (startPath == null) {
            return null;
        }

        Path current = startPath
                .toAbsolutePath()
                .normalize();

        if (Files.isRegularFile(current)) {
            current = current.getParent();
        }

        while (current != null) {
            boolean hasPom = Files.isRegularFile(
                    current.resolve("pom.xml")
            );

            boolean hasSourceDirectory = Files.isDirectory(
                    current.resolve("src")
            );

            if (hasPom && hasSourceDirectory) {
                return current;
            }

            current = current.getParent();
        }

        return null;
    }

    public static Path resolveFile(String fileName)
            throws IOException {

        String safeFileName = extractSafeFileName(fileName);

        Path uploadDirectory = getUploadDirectory();

        Path targetFile = uploadDirectory
                .resolve(safeFileName)
                .normalize();

        if (!targetFile.startsWith(uploadDirectory)) {
            throw new IOException("Invalid image file path");
        }

        return targetFile;
    }

    /**
     * Finds an existing runtime image without creating directories. Besides
     * the current upload/product layout, this also supports images written to
     * the legacy upload directory by older deployments.
     */
    public static Path findExistingFile(String fileName)
            throws IOException {

        String safeFileName = extractSafeFileName(fileName);
        Path productDirectory = resolveUploadDirectory();

        Path currentFile = resolveInside(
                productDirectory,
                safeFileName
        );

        if (Files.isRegularFile(currentFile)) {
            return currentFile;
        }

        Path directoryName = productDirectory.getFileName();
        if (directoryName != null
                && PRODUCT_DIRECTORY_NAME.equalsIgnoreCase(
                        directoryName.toString()
                )) {

            Path legacyDirectory = productDirectory.getParent();
            if (legacyDirectory != null) {
                Path legacyFile = resolveInside(
                        legacyDirectory,
                        safeFileName
                );

                if (Files.isRegularFile(legacyFile)) {
                    return legacyFile;
                }
            }
        }

        return null;
    }

    private static Path resolveInside(
            Path directory,
            String safeFileName
    ) throws IOException {

        Path normalizedDirectory = directory
                .toAbsolutePath()
                .normalize();

        Path targetFile = normalizedDirectory
                .resolve(safeFileName)
                .normalize();

        if (!targetFile.startsWith(normalizedDirectory)) {
            throw new IOException("Invalid image file path");
        }

        return targetFile;
    }

    private static String extractSafeFileName(String fileName)
            throws IOException {

        if (fileName == null || fileName.trim().isEmpty()) {
            throw new IOException("Image file name is empty");
        }

        String normalizedName = fileName
                .trim()
                .replace('\\', '/');

        int queryIndex = normalizedName.indexOf('?');
        if (queryIndex >= 0) {
            normalizedName = normalizedName.substring(0, queryIndex);
        }

        int fragmentIndex = normalizedName.indexOf('#');
        if (fragmentIndex >= 0) {
            normalizedName = normalizedName.substring(0, fragmentIndex);
        }

        String safeFileName = Paths.get(normalizedName)
                .getFileName()
                .toString();

        if (safeFileName.isBlank()
                || ".".equals(safeFileName)
                || "..".equals(safeFileName)) {

            throw new IOException("Invalid image file name");
        }

        return safeFileName;
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

    /** Builds a stable image name shared by every Size of one Color. */
    public static String buildColorImageName(
            int productId,
            String color,
            String extension) {

        validateId(productId, "Product ID");

        return "p"
                + productId
                + "_color_"
                + normalizeNamePart(color)
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
