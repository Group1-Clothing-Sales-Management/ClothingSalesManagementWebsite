package com.clothingsale.service;

import com.clothingsale.dao.UserDAO;
import com.clothingsale.model.User;
import com.clothingsale.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Service phụ trách toàn bộ nghiệp vụ màn hình quản lý nhân viên.
 * Lớp này tách phần kiểm tra dữ liệu ra khỏi Servlet để controller gọn hơn
 * và dễ đọc hơn khi phải xử lý nhiều nhánh add/update/delete.
 */
public class AdminManageStaffService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[\\w.-]+@[\\w.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");

    private final UserDAO userDAO = new UserDAO();

    /**
     * Lấy danh sách staff theo từ khóa tìm kiếm.
     * Controller chỉ cần chuyển keyword xuống đây, còn query DB do DAO xử lý.
     */
    public List<User> getStaffs(String keyword) {
        return userDAO.getAllStaffs(keyword);
    }

    /**
     * Tìm 1 staff theo id để phục vụ màn hình chỉnh sửa.
     */
    public User getStaffById(int id) {
        User staff = userDAO.findById(id);
        if (staff == null || staff.getRoleName() == null || !"STAFF".equalsIgnoreCase(staff.getRoleName())) {
            return null;
        }
        return staff;
    }

    /**
     * Tạo mới tài khoản nhân viên.
     * Trả về map lỗi rỗng nếu thành công, hoặc map có nội dung nếu dữ liệu không hợp lệ / ghi DB thất bại.
     */
    public Map<String, String> createStaff(User staff, String rawPassword) {
        Map<String, String> errors = validateNewStaff(staff, rawPassword);
        if (!errors.isEmpty()) {
            return errors;
        }

        // DAO sẽ tự hash mật khẩu và insert role STAFF, service chỉ chịu trách nhiệm điều phối.
        if (!userDAO.createStaff(staff, rawPassword)) {
            errors.put("general", "Không thể tạo tài khoản staff. Vui lòng thử lại.");
        }
        return errors;
    }

    /**
     * Cập nhật thông tin hồ sơ staff.
     */
    public Map<String, String> updateStaff(User staff) {
        Map<String, String> errors = validateUpdateStaff(staff);
        if (!errors.isEmpty()) {
            return errors;
        }

        // Username và password không đổi trong màn hình này, chỉ cập nhật hồ sơ và trạng thái.
        if (!userDAO.updateStaffProfile(staff)) {
            errors.put("general", "Không thể cập nhật tài khoản staff. Vui lòng thử lại.");
        }
        return errors;
    }

    /**
     * Xóa mềm staff bằng cách khóa tài khoản.
     * Không xóa cứng vì tài khoản staff có thể đã xuất hiện trong nhiều bảng nghiệp vụ.
     */
    public boolean deleteStaffAccount(int id) {
        User staff = getStaffById(id);
        if (staff == null) {
            return false;
        }

        String sql = "UPDATE [User] SET status = 'LOCKED', updated_at = GETDATE() "
                + "WHERE id = ? AND role_id = (SELECT id FROM Role WHERE role_name = 'STAFF')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    /**
     * Kiểm tra dữ liệu khi tạo mới.
     * Mỗi nhánh lỗi được gắn vào một key riêng để JSP hiển thị đúng ngay dưới field tương ứng.
     */
    private Map<String, String> validateNewStaff(User staff, String rawPassword) {
        Map<String, String> errors = new HashMap<>();

        if (staff == null) {
            errors.put("general", "Dữ liệu staff không hợp lệ.");
            return errors;
        }

        if (isBlank(staff.getUsername())) {
            errors.put("username", "Tên đăng nhập không được để trống.");
        } else if (staff.getUsername().trim().length() < 4) {
            errors.put("username", "Tên đăng nhập phải có ít nhất 4 ký tự.");
        } else if (userDAO.findByUsername(staff.getUsername().trim()) != null) {
            errors.put("username", "Tên đăng nhập đã tồn tại.");
        }

        if (isBlank(rawPassword)) {
            errors.put("password", "Mật khẩu không được để trống.");
        } else if (rawPassword.length() < 6) {
            errors.put("password", "Mật khẩu phải có ít nhất 6 ký tự.");
        }

        validateProfileFields(staff, errors, 0);
        return errors;
    }

    /**
     * Kiểm tra dữ liệu khi cập nhật.
     * Username không cho đổi trong form nên chỉ còn lại họ tên, email, phone và status.
     */
    private Map<String, String> validateUpdateStaff(User staff) {
        Map<String, String> errors = new HashMap<>();

        if (staff == null || staff.getId() <= 0) {
            errors.put("general", "Không xác định được staff cần cập nhật.");
            return errors;
        }

        validateProfileFields(staff, errors, staff.getId());
        return errors;
    }

    /**
     * Gom các kiểm tra chung của profile lại một chỗ để tránh lặp code giữa add và update.
     * excludeId = 0 dùng cho tạo mới, còn > 0 dùng để loại trừ chính tài khoản đang sửa.
     */
    private void validateProfileFields(User staff, Map<String, String> errors, int excludeId) {
        if (isBlank(staff.getFullName())) {
            errors.put("fullName", "Họ tên không được để trống.");
        }

        if (isBlank(staff.getEmail())) {
            errors.put("email", "Email không được để trống.");
        } else if (!isValidEmail(staff.getEmail())) {
            errors.put("email", "Email không đúng định dạng.");
        } else if (excludeId <= 0 ? userDAO.findByEmail(staff.getEmail().trim()) != null
                : userDAO.isEmailUsedByOtherUser(staff.getEmail().trim(), excludeId)) {
            errors.put("email", "Email này đã được sử dụng bởi tài khoản khác.");
        }

        if (!isBlank(staff.getPhone())) {
            if (!isValidPhone(staff.getPhone())) {
                errors.put("phone", "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0.");
            }
        }

        String status = staff.getStatus();
        if (isBlank(status)) {
            // Khi tạo mới, nếu người dùng không chọn trạng thái thì tự hiểu là ACTIVE.
            staff.setStatus("ACTIVE");
        } else if (!isAllowedStatus(status)) {
            errors.put("status", "Trạng thái không hợp lệ.");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    private boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    private boolean isAllowedStatus(String status) {
        String normalized = status == null ? "" : status.trim().toUpperCase();
        return "ACTIVE".equals(normalized) || "INACTIVE".equals(normalized) || "LOCKED".equals(normalized);
    }
}
