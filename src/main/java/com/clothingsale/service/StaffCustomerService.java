package com.clothingsale.service;

import com.clothingsale.dao.StaffCustomerDAO;
import com.clothingsale.model.StaffCustomer;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mindrot.jbcrypt.BCrypt;

public class StaffCustomerService {

    private final StaffCustomerDAO dao = new StaffCustomerDAO();

    public List<StaffCustomer> getCustomers(String keyword) {
        return dao.getAllCustomers(keyword);
    }

    public StaffCustomer getCustomerById(int id) {
        return dao.getCustomerById(id);
    }

    public Map<String, String> addCustomer(StaffCustomer c, String rawPassword) {
        Map<String, String> errors = validateNewCustomer(c, rawPassword);
        if (!errors.isEmpty()) {
            return errors;
        }

        String hashed = hashPassword(rawPassword);
        if (!dao.addCustomer(c, hashed)) {
            errors.put("general", "Failed to add the customer. Please try again.");
        }
        return errors;
    }

    public Map<String, String> updateCustomer(StaffCustomer c) {
        Map<String, String> errors = validateUpdateCustomer(c);
        if (!errors.isEmpty()) {
            return errors;
        }

        if (!dao.updateCustomer(c)) {
            errors.put("general", "Update failed. Please try again.");
        }
        return errors;
    }

    private Map<String, String> validateNewCustomer(StaffCustomer c, String rawPassword) {
        Map<String, String> errors = new HashMap<>();

        if (isBlank(c.getUsername())) {
            errors.put("username", "Username cannot be empty.");
        } else if (dao.isUsernameExists(c.getUsername())) {
            errors.put("username", "Username already exists.");
        }

        // Validate password
        if (isBlank(rawPassword)) {
            errors.put("password", "Password cannot be empty.");
        } else if (rawPassword.length() < 6) {
            errors.put("password", "Password must be at least 6 characters.");
        }

        if (isBlank(c.getFullName())) {
            errors.put("fullName", "Full name cannot be empty.");
        }

        if (isBlank(c.getEmail())) {
            errors.put("email", "Email cannot be empty.");
        } else if (!isValidEmail(c.getEmail())) {
            errors.put("email", "Invalid email format.");
        } else if (dao.isEmailExists(c.getEmail(), 0)) {
            errors.put("email", "This email is already used by another account.");
        }

        if (isBlank(c.getPhone())) {
            errors.put("phone", "Phone number cannot be empty.");
        } else if (!isValidPhone(c.getPhone())) {
            errors.put("phone", "Invalid phone number format (10 digits, starting with 0).");
        } else if (dao.isPhoneExists(c.getPhone(), 0)) {
            errors.put("phone", "This phone number is already used by another account.");
        }

        return errors;
    }

    private Map<String, String> validateUpdateCustomer(StaffCustomer c) {
        Map<String, String> errors = new HashMap<>();

        if (isBlank(c.getFullName())) {
            errors.put("fullName", "Full name cannot be empty.");
        }

        if (isBlank(c.getEmail())) {
            errors.put("email", "Email cannot be empty.");
        } else if (!isValidEmail(c.getEmail())) {
            errors.put("email", "Invalid email format.");
        } else if (dao.isEmailExists(c.getEmail(), c.getId())) {
            errors.put("email", "This email is already used by another account.");
        }

        if (isBlank(c.getPhone())) {
            errors.put("phone", "Phone number cannot be empty.");
        } else if (!isValidPhone(c.getPhone())) {
            errors.put("phone", "Invalid phone number format (10 digits, starting with 0).");
        } else if (dao.isPhoneExists(c.getPhone(), c.getId())) {
            errors.put("phone", "This phone number is already used by another account.");
        }

        if (isBlank(c.getStatus())) {
            errors.put("status", "Status cannot be empty.");
        }

        return errors;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$");
    }

    private boolean isValidPhone(String phone) {
        return phone.matches("^0\\d{9}$");
    }

    private String hashPassword(String raw) {
        return BCrypt.hashpw(raw, BCrypt.gensalt(12));
    }
}