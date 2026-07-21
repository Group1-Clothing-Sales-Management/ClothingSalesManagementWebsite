package com.clothingsale.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public final class ProductImageStorage {

    /**
     * Product images are stored in the project-root upload directory,
     * alongside the src directory.
     */
    private static final Path UPLOAD_DIRECTORY
            = Paths.get(System.getProperty("user.dir"), "upload")
                    .toAbsolutePath()
                    .normalize();

    private ProductImageStorage() {
    }

    public static Path getUploadDirectory() throws IOException {
        Files.createDirectories(UPLOAD_DIRECTORY);
        return UPLOAD_DIRECTORY;
    }

    public static Path resolveFile(String fileName) throws IOException {
        if (fileName == null || fileName.trim().isEmpty()) {
            throw new IOException("Image file name is empty");
        }

        String safeFileName = Paths.get(fileName)
                .getFileName()
                .toString();

        Path uploadDirectory = getUploadDirectory();

        Path targetFile = uploadDirectory
                .resolve(safeFileName)
                .normalize();

        if (!targetFile.startsWith(uploadDirectory)) {
            throw new IOException("Invalid image file path");
        }

        return targetFile;
    }
}
