package com.clothingsale.util;

import java.security.SecureRandom;

public final class OtpUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    private OtpUtil() {
    }

    public static String generateSixDigitCode() {
        return String.format("%06d", RANDOM.nextInt(1_000_000));
    }
}
