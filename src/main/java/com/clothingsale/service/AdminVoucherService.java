package com.clothingsale.service;

import com.clothingsale.dao.AdminVoucherDAO;
import com.clothingsale.model.Voucher;
import java.math.BigDecimal;
import java.util.List;

public class AdminVoucherService {

    private final AdminVoucherDAO voucherDAO = new AdminVoucherDAO();

    // 1. Lấy danh sách Voucher (Đã có - Giữ nguyên)
    public List<Voucher> getAllVouchers(String search, String statusFilter) {
        return voucherDAO.getAllVouchers(search, statusFilter);
    }

    // 2. Lấy chi tiết Voucher theo ID (BỔ SUNG THÊM)
    public Voucher getVoucherById(int id) {
        return voucherDAO.getVoucherById(id);
    }

    // 3. Thêm mới Voucher (Đã có - Giữ nguyên)
    public String createVoucher(Voucher voucher) {
        // 1. Kiểm tra trùng mã code
        if (voucherDAO.checkCodeExists(voucher.getCode())) {
            return "Mã voucher '" + voucher.getCode() + "' đã tồn tại trên hệ thống!";
        }

        // 2. Kiểm tra ràng buộc logic loại giảm giá
        if ("PERCENTAGE".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0
                    || voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                return "Giá trị giảm theo phần trăm phải lớn hơn 0 và không vượt quá 100%!";
            }
            if (voucher.getMaxDiscountAmount() == null) {
                return "Vui lòng nhập số tiền giảm tối đa cho loại giảm giá phần trăm!";
            }
        } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
            if (voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
                return "Số tiền giảm cố định phải lớn hơn 0đ!";
            }
            // Nếu giảm tiền cố định, số tiền giảm tối đa chính là giá trị voucher
            voucher.setMaxDiscountAmount(voucher.getDiscountValue());
        }

        // 3. Kiểm tra logic ngày tháng hợp lệ
        if (voucher.getStartDate() == null || voucher.getEndDate() == null) {
            return "Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc!";
        }
        if (voucher.getEndDate().before(voucher.getStartDate())) {
            return "Ngày kết thúc phải diễn ra sau ngày bắt đầu!";
        }

        // 4. Kiểm tra giới hạn số lượng
        if (voucher.getUsageLimit() <= 0) {
            return "Giới hạn lượt sử dụng phải là số nguyên dương lớn hơn 0!";
        }

        // Thực hiện ghi nhận vào Database
        boolean isSuccess = voucherDAO.insertVoucher(voucher);
        return isSuccess ? "SUCCESS" : "Đã xảy ra lỗi hệ thống khi thêm mới voucher!";
    }

    public String updateVoucher(Voucher voucher) {
        // Kiểm tra xem voucher có tồn tại hay không
        Voucher currentDB = voucherDAO.getVoucherById(voucher.getId());
        if (currentDB == null) {
            return "Voucher không tồn tại hoặc đã bị xóa!";
        }

        java.util.Date now = new java.util.Date();

        // Chặn chỉnh sửa nếu voucher đã kết thúc hoặc đã hết lượt sử dụng hoàn toàn
        if (currentDB.getUsedCount() >= currentDB.getUsageLimit() || now.after(currentDB.getEndDate())) {
            return "Không thể chỉnh sửa voucher đã hết hạn hoặc đã sử dụng hết.";
        }

        int savedCount = voucherDAO.getTotalSavedCount(voucher.getId());

        // Nếu Admin cố tình set số lượng phát hành mới nhỏ hơn số khách đã lưu
        if (voucher.getUsageLimit() < savedCount) {
            return "Lỗi: Đã có " + savedCount + " khách hàng thu thập voucher này. Bạn chỉ có thể thiết lập số lượng tối thiểu là " + savedCount + " để bảo vệ quyền lợi khách hàng.";
        }

        if (voucher.getEndDate().before(voucher.getStartDate())) {
            return "Ngày kết thúc phải diễn ra sau ngày bắt đầu.";
        }

        // Nếu Admin rút ngắn thời gian kết thúc (newEndDate < oldEndDate)
        if (voucher.getEndDate().before(currentDB.getEndDate())) {
            // Tính toán mốc thời gian an toàn (Hiện tại + 48 tiếng)
            long safeBufferMillis = 48L * 60 * 60 * 1000;
            java.util.Date safeLimitTime = new java.util.Date(now.getTime() + safeBufferMillis);

            // Nếu ngày kết thúc mới bị ép xuống quá gấp (nhỏ hơn mốc 48h tới)
            if (voucher.getEndDate().before(safeLimitTime)) {
                return "Lỗi: Không thể rút ngắn thời hạn quá gấp. Hạn sử dụng mới phải cách thời điểm hiện tại tối thiểu 2 ngày để khách hàng đã lưu kịp sử dụng.";
            }
        }

        if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
            voucher.setMaxDiscountAmount(voucher.getDiscountValue());
        }

        boolean isSuccess = voucherDAO.updateVoucher(voucher);
        return isSuccess ? "SUCCESS" : "Lỗi hệ thống khi cập nhật voucher.";
    }

    // 5. Tiến trình dừng voucher sớm có lộ trình đệm (Đã có - Giữ nguyên)
    public String terminateVoucherEarly(int id, int daysLeft, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return "Please provide a reason for early termination.";
        }
        if (daysLeft < 0) {
            return "Grace period days cannot be negative.";
        }

        // Đọc thông tin kiểm tra từ DB
        Voucher currentDB = voucherDAO.getVoucherById(id);
        if (currentDB == null) {
            return "Voucher not found.";
        }

        // Tính toán mốc thời gian end_date mới: Hiện tại + số ngày đệm
        long extraMillis = (long) daysLeft * 24 * 60 * 60 * 1000;
        java.sql.Timestamp newEndDate = new java.sql.Timestamp(System.currentTimeMillis() + extraMillis);

        // Ràng buộc bảo vệ: Nếu ngày đệm tính ra lại vượt quá cả ngày hết hạn ban đầu -> Báo lỗi
        if (newEndDate.after(currentDB.getEndDate())) {
            return "The grace period extends past the original end date. No adjustments made.";
        }

        boolean isSuccess = voucherDAO.terminateVoucherEarly(id, newEndDate, reason.trim());
        return isSuccess ? "SUCCESS" : "System error occurred while updating the database.";
    }

    public int getTotalSavedCount(int id) {
        return voucherDAO.getTotalSavedCount(id);
    }
}
