package com.clothingsale.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/** Stores non-product user uploads outside the deployed application. */
public final class UserUploadStorage {

    private static final String DIRECTORY_PROPERTY
            = "clothingsale.user.upload.dir";
    private static final String DIRECTORY_ENVIRONMENT_VARIABLE
            = "CLOTHINGSALE_USER_UPLOAD_DIR";

    private UserUploadStorage() {
    }

    public static Path getUploadDirectory() throws IOException {
        String configuredDirectory = System.getProperty(DIRECTORY_PROPERTY);
        if (configuredDirectory == null
                || configuredDirectory.trim().isEmpty()) {
            configuredDirectory = System.getenv(
                    DIRECTORY_ENVIRONMENT_VARIABLE
            );
        }

        Path uploadDirectory = configuredDirectory != null
                && !configuredDirectory.trim().isEmpty()
                ? Paths.get(configuredDirectory.trim())
                : Paths.get(System.getProperty("user.dir"), "uploads");

        uploadDirectory = uploadDirectory.toAbsolutePath().normalize();
        Files.createDirectories(uploadDirectory);
        return uploadDirectory;
    }

    public static Path resolveFile(String relativePath) throws IOException {
        if (relativePath == null || relativePath.trim().isEmpty()) {
            throw new IOException("Upload file path is empty");
        }

        String safeRelativePath = relativePath.replace('\\', '/');
        while (safeRelativePath.startsWith("/")) {
            safeRelativePath = safeRelativePath.substring(1);
        }

        Path uploadDirectory = getUploadDirectory();
        Path targetFile = uploadDirectory
                .resolve(safeRelativePath)
                .normalize();

        if (!targetFile.startsWith(uploadDirectory)) {
            throw new IOException("Invalid upload file path");
        }

        return targetFile;
    }
}
