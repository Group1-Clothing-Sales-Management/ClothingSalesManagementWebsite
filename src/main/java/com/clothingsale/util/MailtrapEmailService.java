package com.clothingsale.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Properties;

public class MailtrapEmailService {

    private static final String DEFAULT_FROM_EMAIL = "no-reply@clothing-sale.local";
    private static final String DEFAULT_FROM_NAME = "Clothing Sale";

    public void sendVerificationCode(String toEmail, String recipientName, String code, int expiryMinutes)
            throws MessagingException {
        validateArguments(toEmail, code, expiryMinutes);

        SmtpConfig config = SmtpConfig.fromEnv();
        Properties props = new Properties();
        props.put("mail.smtp.host", config.host);
        props.put("mail.smtp.port", String.valueOf(config.port));
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", String.valueOf(config.useStartTls));
        props.put("mail.smtp.starttls.required", String.valueOf(config.useStartTls));
        props.put("mail.smtp.ssl.enable", String.valueOf(config.useSsl));
        props.put("mail.smtp.ssl.trust", config.host);
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(config.username, config.password);
            }
        });

        MimeMessage message = new MimeMessage(session);
        try {
            message.setFrom(new InternetAddress(config.fromEmail, config.fromName, StandardCharsets.UTF_8.name()));
        } catch (UnsupportedEncodingException ex) {
            throw new MessagingException("Unable to configure sender name", ex);
        }

        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail, false));
        message.setSentDate(new Date());
        message.setSubject("Your Clothing Sale verification code", StandardCharsets.UTF_8.name());
        message.setContent(buildHtmlBody(recipientName, code, expiryMinutes), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private String buildHtmlBody(String recipientName, String code, int expiryMinutes) {
        String safeName = recipientName == null || recipientName.trim().isEmpty()
                ? "customer"
                : escapeHtml(recipientName.trim());

        return "<!doctype html>"
                + "<html><body style=\"font-family:Arial,sans-serif;color:#1f2937;line-height:1.6\">"
                + "<h2 style=\"margin:0 0 12px\">Verify your Clothing Sale account</h2>"
                + "<p>Hello " + safeName + ",</p>"
                + "<p>Your verification code is:</p>"
                + "<div style=\"font-size:30px;font-weight:700;letter-spacing:6px;padding:14px 18px;"
                + "display:inline-block;border:1px solid #d1d5db;border-radius:10px;background:#f9fafb\">"
                + escapeHtml(code)
                + "</div>"
                + "<p style=\"margin-top:16px\">This code expires in " + expiryMinutes + " minutes.</p>"
                + "<p>If you did not request this account, you can ignore this email.</p>"
                + "</body></html>";
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private void validateArguments(String toEmail, String code, int expiryMinutes) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            throw new IllegalArgumentException("Recipient email is required.");
        }
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Verification code is required.");
        }
        if (expiryMinutes <= 0) {
            throw new IllegalArgumentException("Expiry minutes must be greater than zero.");
        }
    }

    private static final class SmtpConfig {
        private final String host;
        private final int port;
        private final String username;
        private final String password;
        private final String fromEmail;
        private final String fromName;
        private final boolean useStartTls;
        private final boolean useSsl;

        private SmtpConfig(String host, int port, String username, String password, String fromEmail, String fromName) {
            this.host = host;
            this.port = port;
            this.username = username;
            this.password = password;
            this.fromEmail = fromEmail;
            this.fromName = fromName;
            this.useSsl = port == 465;
            this.useStartTls = !this.useSsl;
        }

        private static SmtpConfig fromEnv() {
            String host = firstNonBlank(
                    EnvConfig.get("MAILTRAP_HOST"),
                    EnvConfig.get("SMTP_HOST"));
            String username = firstNonBlank(
                    EnvConfig.get("MAILTRAP_USERNAME"),
                    EnvConfig.get("SMTP_USERNAME"));
            String password = firstNonBlank(
                    EnvConfig.get("MAILTRAP_PASSWORD"),
                    EnvConfig.get("SMTP_PASSWORD"));
            String fromEmail = firstNonBlank(
                    EnvConfig.get("MAILTRAP_FROM_EMAIL"),
                    EnvConfig.get("SMTP_FROM_EMAIL"),
                    username,
                    DEFAULT_FROM_EMAIL);
            String fromName = firstNonBlank(
                    EnvConfig.get("MAILTRAP_FROM_NAME"),
                    EnvConfig.get("SMTP_FROM_NAME"),
                    DEFAULT_FROM_NAME);
            int port = EnvConfig.getInt("MAILTRAP_PORT", EnvConfig.getInt("SMTP_PORT", -1));

            if (host == null || host.trim().isEmpty()) {
                throw new IllegalStateException("Missing SMTP host. Set MAILTRAP_HOST or SMTP_HOST.");
            }
            if (port <= 0) {
                throw new IllegalStateException("Missing SMTP port. Set MAILTRAP_PORT or SMTP_PORT.");
            }
            if (username == null || username.trim().isEmpty()) {
                throw new IllegalStateException("Missing SMTP username. Set MAILTRAP_USERNAME or SMTP_USERNAME.");
            }
            if (password == null || password.trim().isEmpty()) {
                throw new IllegalStateException("Missing SMTP password. Set MAILTRAP_PASSWORD or SMTP_PASSWORD.");
            }

            return new SmtpConfig(host.trim(), port, username.trim(), password.trim(), fromEmail.trim(), fromName.trim());
        }

        private static String firstNonBlank(String... values) {
            if (values == null) {
                return null;
            }

            for (String value : values) {
                if (value != null && !value.trim().isEmpty()) {
                    return value.trim();
                }
            }
            return null;
        }
    }
}
