package com.clothingsale.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public final class EnvConfig {

    private static final Map<String, String> FILE_VALUES = loadEnvValues();

    private EnvConfig() {
    }

    public static String get(String key) {
        return get(key, null);
    }

    public static String get(String key, String defaultValue) {
        if (key == null || key.trim().isEmpty()) {
            return defaultValue;
        }

        String value = System.getProperty(key);
        if (isNotBlank(value)) {
            return value.trim();
        }

        value = System.getenv(key);
        if (isNotBlank(value)) {
            return value.trim();
        }

        value = FILE_VALUES.get(key);
        if (isNotBlank(value)) {
            return value.trim();
        }

        return defaultValue;
    }

    public static int getInt(String key, int defaultValue) {
        String value = get(key, null);
        if (!isNotBlank(value)) {
            return defaultValue;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private static Map<String, String> loadEnvValues() {
        Map<String, String> values = new HashMap<>();
        loadFromResource(values, "/.env");
        loadFromResource(values, "/env");
        loadFromResource(values, "/META-INF/mailtrap.env");
        loadFromFile(values, Path.of(".env"));
        loadFromFile(values, Path.of("src", "main", "resources", ".env"));
        loadFromFile(values, Path.of("src", "main", "resources", "META-INF", "mailtrap.env"));
        return Collections.unmodifiableMap(values);
    }

    private static void loadFromResource(Map<String, String> values, String resourcePath) {
        try (InputStream inputStream = EnvConfig.class.getResourceAsStream(resourcePath)) {
            if (inputStream != null) {
                load(values, inputStream);
            }
        } catch (IOException ignored) {
            // Ignore malformed optional env resources and continue with other sources.
        }
    }

    private static void loadFromFile(Map<String, String> values, Path path) {
        if (path == null || !Files.exists(path)) {
            return;
        }

        try (InputStream inputStream = Files.newInputStream(path)) {
            load(values, inputStream);
        } catch (IOException ignored) {
            // Optional file source only.
        }
    }

    private static void load(Map<String, String> values, InputStream inputStream) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) {
                    continue;
                }

                if (trimmed.startsWith("export ")) {
                    trimmed = trimmed.substring("export ".length()).trim();
                }

                int separator = trimmed.indexOf('=');
                if (separator <= 0) {
                    continue;
                }

                String key = trimmed.substring(0, separator).trim();
                String value = trimmed.substring(separator + 1).trim();
                if (value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) {
                    value = value.substring(1, value.length() - 1);
                } else if (value.startsWith("'") && value.endsWith("'") && value.length() >= 2) {
                    value = value.substring(1, value.length() - 1);
                }

                if (!key.isEmpty()) {
                    values.putIfAbsent(key, value);
                }
            }
        }
    }

    private static boolean isNotBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
