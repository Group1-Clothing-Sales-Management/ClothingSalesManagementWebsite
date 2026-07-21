package com.clothingsale.dao;

import com.clothingsale.model.ReturnReportRow;
import com.clothingsale.model.ReturnRequest;
import com.clothingsale.model.ReturnRequestItem;
import com.clothingsale.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho nghiệp vụ đổi trả.
 * Các thao tác thay đổi nhiều bảng đều dùng một transaction để dữ liệu không bị dở dang.
 */
public class ReturnRequestDAO {

    /** Lấy các dòng hàng của đơn thuộc đúng khách đang đăng nhập. */
    public List<ReturnRequestItem> getCustomerOrderItems(int userId, int orderId) {
        List<ReturnRequestItem> items = new ArrayList<>();
        String sql = "SELECT od.id, od.variant_id, od.product_name_snapshot, od.variant_attributes_snapshot, "
                + "od.quantity, od.price "
                + "FROM Order_Detail od JOIN [Order] o ON o.id = od.order_id "
                + "WHERE od.order_id = ? AND o.user_id = ? ORDER BY od.id";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapOrderItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    /** Kiểm tra nhanh đơn có tồn tại và thuộc khách hay không. */
    public boolean customerOwnsOrder(int userId, int orderId) {
        String sql = "SELECT COUNT(*) FROM [Order] WHERE id = ? AND user_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Không cho tạo thêm yêu cầu đang xử lý cho cùng một đơn để tránh hoàn tiền hai lần. */
    public boolean hasOpenRequest(int orderId) {
        String sql = "SELECT COUNT(*) FROM Return_Request WHERE order_id = ? "
                + "AND status IN ('PENDING','INFO_REQUIRED','APPROVED','RECEIVED','REFUND_PENDING')";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    /** Tạo header, các dòng sản phẩm và lịch sử PENDING trong cùng một transaction. */
    public int createRequest(String code, int userId, int orderId, String type, String reason,
            String customerNote, String bankId, String bankName, String accountName,
            String accountNumber, Map<Integer, Integer> quantities) throws SQLException {
        String orderSql = "SELECT o.order_status, o.total_payment, od.id, od.variant_id, "
                + "od.product_name_snapshot, od.variant_attributes_snapshot, od.quantity, od.price "
                + "FROM [Order] o JOIN Order_Detail od ON od.order_id = o.id "
                + "WHERE o.id = ? AND o.user_id = ?";
        String insertHeader = "INSERT INTO Return_Request(request_code, order_id, customer_id, request_type, reason, customer_note, "
                + "refund_amount, refund_bank_id, refund_bank_name, refund_account_name, refund_account_number, refund_transfer_description) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItem = "INSERT INTO Return_Request_Item(return_request_id, order_detail_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, unit_price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        String insertHistory = "INSERT INTO Return_Request_History(return_request_id, old_status, new_status, note, changed_by) VALUES (?, NULL, 'PENDING', ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                BigDecimal refund = BigDecimal.ZERO;
                int requestId = 0;
                try (PreparedStatement ps = con.prepareStatement(orderSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int detailId = rs.getInt("id");
                            Integer requested = quantities.get(detailId);
                            if (requested == null || requested <= 0) {
                                continue;
                            }
                            int ordered = rs.getInt("quantity");
                            if (requested > ordered) {
                                throw new SQLException("The returned quantity cannot exceed the ordered quantity.");
                            }
                            refund = refund.add(rs.getBigDecimal("price").multiply(BigDecimal.valueOf(requested)));
                        }
                    }
                }
                if (refund.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new SQLException("Please select at least one product to return.");
                }

                try (PreparedStatement ps = con.prepareStatement(insertHeader, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, code);
                    ps.setInt(2, orderId);
                    ps.setInt(3, userId);
                    ps.setString(4, type);
                    ps.setString(5, reason);
                    ps.setString(6, customerNote);
                    ps.setBigDecimal(7, refund);
                    ps.setString(8, bankId);
                    ps.setString(9, bankName);
                    ps.setString(10, accountName);
                    ps.setString(11, accountNumber);
                    // Nội dung chuyển khoản cố định theo yêu cầu: mã đơn hàng kèm chữ trả hàng.
                    ps.setString(12, "REFUND " + getOrderCode(con, orderId));
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Could not create the return request.");
                        }
                        requestId = keys.getInt(1);
                    }
                }

                try (PreparedStatement read = con.prepareStatement(orderSql);
                        PreparedStatement add = con.prepareStatement(insertItem)) {
                    read.setInt(1, orderId);
                    read.setInt(2, userId);
                    try (ResultSet rs = read.executeQuery()) {
                        while (rs.next()) {
                            Integer requested = quantities.get(rs.getInt("id"));
                            if (requested == null || requested <= 0) {
                                continue;
                            }
                            add.setInt(1, requestId);
                            if (rs.getObject("id") == null) add.setNull(2, java.sql.Types.INTEGER); else add.setInt(2, rs.getInt("id"));
                            if (rs.getObject("variant_id") == null) add.setNull(3, java.sql.Types.INTEGER); else add.setInt(3, rs.getInt("variant_id"));
                            add.setString(4, rs.getString("product_name_snapshot"));
                            add.setString(5, rs.getString("variant_attributes_snapshot"));
                            add.setInt(6, requested);
                            add.setBigDecimal(7, rs.getBigDecimal("price"));
                            add.addBatch();
                        }
                    }
                    add.executeBatch();
                }
                try (PreparedStatement ps = con.prepareStatement(insertHistory)) {
                    ps.setInt(1, requestId);
                    ps.setString(2, "Customer submitted a return request.");
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
                con.commit();
                return requestId;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /** Lấy mã đơn hàng trong cùng transaction để nội dung chuyển khoản không bị giả mạo từ form. */
    private String getOrderCode(Connection con, int orderId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT order_code FROM [Order] WHERE id=?")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new SQLException("Order not found.");
                return rs.getString(1);
            }
        }
    }

    public List<ReturnRequest> getCustomerRequests(int userId) {
        return getRequests("rr.customer_id = ?", userId, null);
    }

    /**
     * Tự động hủy các yêu cầu đã Approved nhưng sau 3 ngày vẫn chưa nhận được hàng.
     * Hàm được gọi khi đọc dữ liệu và bởi listener định kỳ của ứng dụng.
     */
    public int cancelExpiredApprovedRequests() throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                List<Integer> expiredIds = new ArrayList<>();
                String findSql = "SELECT id FROM Return_Request WITH (UPDLOCK, ROWLOCK) "
                        + "WHERE status='APPROVED' AND COALESCE(reviewed_at, requested_at) <= DATEADD(DAY, -3, GETDATE())";
                try (PreparedStatement ps = con.prepareStatement(findSql); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) expiredIds.add(rs.getInt(1));
                }
                for (Integer id : expiredIds) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE Return_Request SET status='CANCELLED', staff_note=? WHERE id=? AND status='APPROVED'")) {
                        ps.setString(1, "Automatically cancelled because the store did not receive the returned package within 3 days.");
                        ps.setInt(2, id);
                        if (ps.executeUpdate() == 1) {
                            // Không có người thao tác trực tiếp nên changed_by được lưu là NULL.
                            addHistory(con, id, "APPROVED", "CANCELLED",
                                    "The return package was not received within 3 days.", null);
                        }
                    }
                }
                con.commit();
                return expiredIds.size();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<ReturnRequest> getStaffRequests(String keyword, String status) {
        String filter = "(? IS NULL OR ? = '' OR rr.request_code LIKE ? OR rr.order_id = TRY_CONVERT(INT, ? ) OR u.full_name LIKE ? OR o.order_code LIKE ?)"
                + " AND (? IS NULL OR ? = '' OR rr.status = ?)";
        List<ReturnRequest> result = new ArrayList<>();
        String sql = baseRequestSql() + " WHERE " + filter + " ORDER BY rr.requested_at DESC, rr.id DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            String key = keyword == null ? "" : keyword.trim();
            String normalizedStatus = status == null ? "" : status.trim().toUpperCase();
            int i = 1;
            ps.setString(i++, key); ps.setString(i++, key); ps.setString(i++, "%" + key + "%"); ps.setString(i++, key); ps.setString(i++, "%" + key + "%"); ps.setString(i++, "%" + key + "%");
            ps.setString(i++, normalizedStatus); ps.setString(i++, normalizedStatus); ps.setString(i, normalizedStatus);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) result.add(mapRequest(rs)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }

    public ReturnRequest getById(int id) {
        String sql = baseRequestSql() + " WHERE rr.id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ReturnRequest request = mapRequest(rs);
                    request.setItems(getItems(id));
                    return request;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** Khách bổ sung thông tin theo yêu cầu của Staff và đưa hồ sơ về hàng chờ kiểm tra. */
    public boolean supplementInfo(int requestId, int customerId, String note) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String current = null;
                try (PreparedStatement ps = con.prepareStatement("SELECT rr.status FROM Return_Request rr WHERE rr.id=? AND rr.customer_id=?")) {
                    ps.setInt(1, requestId);
                    ps.setInt(2, customerId);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) current = rs.getString(1); }
                }
                if (!"INFO_REQUIRED".equals(current) || note == null || note.trim().isEmpty()) {
                    con.rollback();
                    return false;
                }
                try (PreparedStatement ps = con.prepareStatement("UPDATE Return_Request SET customer_note=CONCAT(ISNULL(customer_note,''), CHAR(13)+CHAR(10), 'Additional information: ', ?), status='PENDING' WHERE id=? AND customer_id=? AND status='INFO_REQUIRED'")) {
                    ps.setString(1, note.trim()); ps.setInt(2, requestId); ps.setInt(3, customerId);
                    if (ps.executeUpdate() != 1) { con.rollback(); return false; }
                }
                addHistory(con, requestId, current, "PENDING", note.trim(), customerId);
                con.commit();
                return true;
            } catch (SQLException e) { con.rollback(); throw e; } finally { con.setAutoCommit(true); }
        }
    }

    private List<ReturnRequest> getRequests(String where, int userId, String unused) {
        List<ReturnRequest> result = new ArrayList<>();
        String sql = baseRequestSql() + " WHERE " + where + " ORDER BY rr.requested_at DESC, rr.id DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) result.add(mapRequest(rs)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }

    public List<ReturnRequestItem> getItems(int requestId) {
        List<ReturnRequestItem> result = new ArrayList<>();
        String sql = "SELECT ri.*, ISNULL(pv.stock_quantity, 0) AS current_stock FROM Return_Request_Item ri "
                + "LEFT JOIN Product_Variant pv ON pv.id = ri.variant_id WHERE ri.return_request_id = ? ORDER BY ri.id";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) result.add(mapReturnItem(rs)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }

    /** Staff đổi trạng thái kiểm tra, yêu cầu bổ sung hoặc từ chối. */
    public boolean review(int requestId, int staffId, String status, String note) throws SQLException {
        return changeStatus(requestId, staffId, status, note, null, null);
    }

    /** Duyệt yêu cầu và lưu QR/nội dung chuyển khoản được tạo ở service. */
    public boolean review(int requestId, int staffId, String status, String note,
            String qrUrl, String transferDescription) throws SQLException {
        return changeStatus(requestId, staffId, status, note, qrUrl, transferDescription);
    }

    /** Ghi nhận hàng đã nhận và cộng tồn kho đúng một lần. */
    public boolean receive(int requestId, int staffId, String note) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Đổi trạng thái trước trong cùng transaction để hai nhân viên bấm đồng thời
                // không thể cùng cộng tồn kho cho một yêu cầu.
                try (PreparedStatement ps = con.prepareStatement("UPDATE Return_Request SET status='RECEIVED', received_by=?, received_at=GETDATE(), staff_note=? WHERE id=? AND status='APPROVED'")) {
                    ps.setInt(1, staffId); ps.setString(2, note); ps.setInt(3, requestId);
                    if (ps.executeUpdate() != 1) { con.rollback(); return false; }
                }
                List<ReturnRequestItem> items = getItems(requestId);
                for (ReturnRequestItem item : items) {
                    if (item.getVariantId() <= 0) continue;
                    String update = "UPDATE Product_Variant SET stock_quantity = stock_quantity + ? WHERE id = ?";
                    try (PreparedStatement ps = con.prepareStatement(update)) { ps.setInt(1, item.getQuantity()); ps.setInt(2, item.getVariantId()); ps.executeUpdate(); }
                    String log = "INSERT INTO Inventory_Log(variant_id, user_id, product_name_snapshot, quantity_before, change_quantity, quantity_after, transaction_type, reference_type, reference_id, note) "
                            + "SELECT pv.id, ?, p.product_name, pv.stock_quantity - ?, ?, pv.stock_quantity, 'RETURN_IN', 'RETURN_REQUEST', ?, ? "
                            + "FROM Product_Variant pv JOIN Product p ON p.id = pv.product_id WHERE pv.id = ?";
                    try (PreparedStatement ps = con.prepareStatement(log)) {
                        ps.setInt(1, staffId); ps.setInt(2, item.getQuantity()); ps.setInt(3, item.getQuantity()); ps.setInt(4, requestId); ps.setString(5, note); ps.setInt(6, item.getVariantId()); ps.executeUpdate();
                    }
                }
                addHistory(con, requestId, "APPROVED", "RECEIVED", note, staffId);
                con.commit();
                return true;
            } catch (SQLException e) { con.rollback(); throw e; } finally { con.setAutoCommit(true); }
        }
    }

    public boolean requestRefund(int requestId, int staffId, String note) throws SQLException {
        return changeStatus(requestId, staffId, "REFUND_PENDING", note, null, null);
    }

    /** Admin duyệt hoàn tiền và cập nhật Payment/Order trong cùng transaction. */
    public boolean approveRefund(int requestId, int adminId, String note) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String code = "";
                int orderId = 0;
                try (PreparedStatement ps = con.prepareStatement("SELECT order_id, request_code FROM Return_Request WHERE id=?")) { ps.setInt(1, requestId); try (ResultSet rs = ps.executeQuery()) { if (!rs.next()) throw new SQLException("Return request not found."); orderId=rs.getInt(1); code=rs.getString(2); } }
                // Claim trạng thái trước để thao tác hoàn tiền có tính idempotent khi bị bấm lặp.
                try (PreparedStatement ps = con.prepareStatement("UPDATE Return_Request SET status='COMPLETED', refunded_by=?, refunded_at=GETDATE(), staff_note=? WHERE id=? AND status='REFUND_PENDING'")) { ps.setInt(1, adminId); ps.setString(2, note); ps.setInt(3, requestId); if (ps.executeUpdate() != 1) { con.rollback(); return false; } }
                try (PreparedStatement ps = con.prepareStatement("UPDATE Payment SET payment_status='REFUNDED', transaction_reference=?, payment_date=GETDATE() WHERE order_id=?")) { ps.setString(1, "REFUND-" + code); ps.setInt(2, orderId); ps.executeUpdate(); }
                try (PreparedStatement ps = con.prepareStatement("UPDATE [Order] SET order_status='RETURNED', updated_at=GETDATE() WHERE id=?")) { ps.setInt(1, orderId); ps.executeUpdate(); }
                addHistory(con, requestId, "REFUND_PENDING", "COMPLETED", note, adminId);
                con.commit();
                return true;
            } catch (SQLException e) { con.rollback(); throw e; } finally { con.setAutoCommit(true); }
        }
    }

    /**
     * Xác nhận đã chuyển khoản và lưu ảnh chứng từ.
     * Chỉ cho phép xác nhận sau khi Staff đã bấm Confirm products received.
     */
    public boolean confirmRefund(int requestId, int operatorId, String note, String proofPath) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String code = null;
                int orderId = 0;
                String current = null;
                try (PreparedStatement ps = con.prepareStatement(
                        // Khóa dòng trong transaction để không thể cộng tồn kho hai lần khi hai người cùng xác nhận.
                        "SELECT order_id, request_code, status FROM Return_Request WITH (UPDLOCK, ROWLOCK) WHERE id=?")) {
                    ps.setInt(1, requestId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Return request not found.");
                        orderId = rs.getInt("order_id");
                        code = rs.getString("request_code");
                        current = rs.getString("status");
                    }
                }
                if (!"RECEIVED".equals(current)) {
                    con.rollback();
                    return false;
                }
                if (proofPath == null || proofPath.trim().isEmpty()) {
                    throw new SQLException("Please upload the bank transfer proof image.");
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Return_Request SET status='COMPLETED', refunded_by=?, refunded_at=GETDATE(), "
                        + "refund_confirmed_by=?, refund_confirmed_at=GETDATE(), refund_proof_path=?, staff_note=? "
                        + "WHERE id=? AND status='RECEIVED'")) {
                    ps.setInt(1, operatorId);
                    ps.setInt(2, operatorId);
                    ps.setString(3, proofPath);
                    ps.setString(4, note);
                    ps.setInt(5, requestId);
                    if (ps.executeUpdate() != 1) { con.rollback(); return false; }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Payment SET payment_status='REFUNDED', transaction_reference=?, payment_date=GETDATE() WHERE order_id=?")) {
                    ps.setString(1, "REFUND-" + code);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE [Order] SET order_status='RETURNED', updated_at=GETDATE() WHERE id=?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                addHistory(con, requestId, current, "COMPLETED", note, operatorId);
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public boolean rejectRefund(int requestId, int adminId, String note) throws SQLException {
        return changeStatus(requestId, adminId, "REJECTED", note, null, null);
    }

    private boolean changeStatus(int requestId, int userId, String target, String note,
            String qrUrl, String transferDescription) throws SQLException {
        String current = getStatus(requestId);
        if (current == null || !canChange(current, target)) return false;
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                addHistory(con, requestId, current, target, note, userId);
                String sql = "UPDATE Return_Request SET status=?, staff_note=?, reviewed_by=?, reviewed_at=GETDATE(), "
                        + "refund_requested_by=CASE WHEN ?='REFUND_PENDING' THEN ? ELSE refund_requested_by END, "
                        + "refund_requested_at=CASE WHEN ?='REFUND_PENDING' THEN GETDATE() ELSE refund_requested_at END"
                        + ("APPROVED".equals(target) ? ", refund_qr_url=?, refund_transfer_description=?" : "")
                        + " WHERE id=? AND status=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    int i = 1;
                    ps.setString(i++, target); ps.setString(i++, note); ps.setInt(i++, userId);
                    ps.setString(i++, target); ps.setInt(i++, userId); ps.setString(i++, target);
                    if ("APPROVED".equals(target)) {
                        ps.setString(i++, qrUrl);
                        ps.setString(i++, transferDescription);
                    }
                    ps.setInt(i++, requestId); ps.setString(i, current);
                    if (ps.executeUpdate() != 1) throw new SQLException("The request was already updated.");
                }
                con.commit(); return true;
            } catch (SQLException e) { con.rollback(); throw e; } finally { con.setAutoCommit(true); }
        }
    }

    private boolean canChange(String current, String target) {
        if ("PENDING".equals(current) || "INFO_REQUIRED".equals(current)) return "APPROVED".equals(target) || "REJECTED".equals(target) || "INFO_REQUIRED".equals(target);
        if ("RECEIVED".equals(current)) return "REFUND_PENDING".equals(target);
        return "REFUND_PENDING".equals(current) && "REJECTED".equals(target);
    }

    private String getStatus(int id) throws SQLException {
        String sql = "SELECT status FROM Return_Request WHERE id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    private void addHistory(Connection con, int id, String oldStatus, String newStatus, String note, Integer userId) throws SQLException {
        String sql = "INSERT INTO Return_Request_History(return_request_id, old_status, new_status, note, changed_by) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, oldStatus);
            ps.setString(3, newStatus);
            ps.setString(4, note);
            if (userId == null) ps.setNull(5, java.sql.Types.INTEGER); else ps.setInt(5, userId);
            ps.executeUpdate();
        }
    }

    public Map<String, Integer> getStatusCounts() {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) total FROM Return_Request GROUP BY status";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getString(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public BigDecimal getTotalRefunded() {
        String sql = "SELECT ISNULL(SUM(refund_amount), 0) FROM Return_Request WHERE status = 'COMPLETED'";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    public List<ReturnReportRow> getReportRows() {
        List<ReturnReportRow> result = new ArrayList<>();
        String sql = "SELECT ri.product_name_snapshot, pv.sku, SUM(ri.quantity) quantity_returned, MAX(ISNULL(pv.stock_quantity,0)) current_stock, SUM(ri.quantity * ri.unit_price) refund_amount "
                + "FROM Return_Request_Item ri JOIN Return_Request rr ON rr.id=ri.return_request_id LEFT JOIN Product_Variant pv ON pv.id=ri.variant_id "
                + "WHERE rr.status='COMPLETED' GROUP BY ri.product_name_snapshot, pv.sku ORDER BY quantity_returned DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ReturnReportRow row = new ReturnReportRow();
                row.setProductName(rs.getString(1));
                row.setSku(rs.getString(2));
                row.setQuantityReturned(rs.getInt(3));
                row.setCurrentStock(rs.getInt(4));
                row.setRefundAmount(rs.getBigDecimal(5));
                result.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    private String baseRequestSql() {
        return "SELECT rr.*, o.order_code, u.full_name customer_name, u.email customer_email FROM Return_Request rr "
                + "JOIN [Order] o ON o.id=rr.order_id LEFT JOIN [User] u ON u.id=rr.customer_id";
    }

    private ReturnRequest mapRequest(ResultSet rs) throws SQLException {
        ReturnRequest request = new ReturnRequest();
        request.setId(rs.getInt("id"));
        request.setRequestCode(rs.getString("request_code"));
        request.setOrderId(rs.getInt("order_id"));
        request.setOrderCode(rs.getString("order_code"));
        request.setCustomerId(rs.getInt("customer_id"));
        request.setCustomerName(rs.getString("customer_name"));
        request.setCustomerEmail(rs.getString("customer_email"));
        request.setRequestType(rs.getString("request_type"));
        request.setReason(rs.getString("reason"));
        request.setCustomerNote(rs.getString("customer_note"));
        request.setStaffNote(rs.getString("staff_note"));
        request.setRefundAmount(rs.getBigDecimal("refund_amount"));
        request.setStatus(rs.getString("status"));
        request.setRequestedAt(rs.getTimestamp("requested_at"));
        request.setReviewedAt(rs.getTimestamp("reviewed_at"));
        request.setReceivedAt(rs.getTimestamp("received_at"));
        request.setRefundRequestedAt(rs.getTimestamp("refund_requested_at"));
        request.setRefundedAt(rs.getTimestamp("refunded_at"));
        request.setRefundBankId(rs.getString("refund_bank_id"));
        request.setRefundBankName(rs.getString("refund_bank_name"));
        request.setRefundAccountName(rs.getString("refund_account_name"));
        request.setRefundAccountNumber(rs.getString("refund_account_number"));
        request.setRefundQrUrl(rs.getString("refund_qr_url"));
        request.setRefundTransferDescription(rs.getString("refund_transfer_description"));
        request.setRefundProofPath(rs.getString("refund_proof_path"));
        int confirmedBy = rs.getInt("refund_confirmed_by");
        request.setRefundConfirmedBy(rs.wasNull() ? null : confirmedBy);
        request.setRefundConfirmedAt(rs.getTimestamp("refund_confirmed_at"));
        return request;
    }

    private ReturnRequestItem mapOrderItem(ResultSet rs) throws SQLException {
        ReturnRequestItem item = new ReturnRequestItem();
        item.setOrderDetailId(rs.getInt("id"));
        item.setVariantId(rs.getInt("variant_id"));
        item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
        item.setVariantAttributesSnapshot(rs.getString("variant_attributes_snapshot"));
        item.setOrderedQuantity(rs.getInt("quantity"));
        item.setQuantity(1);
        item.setUnitPrice(rs.getBigDecimal("price"));
        return item;
    }

    private ReturnRequestItem mapReturnItem(ResultSet rs) throws SQLException {
        ReturnRequestItem item = new ReturnRequestItem();
        item.setId(rs.getInt("id"));
        item.setReturnRequestId(rs.getInt("return_request_id"));
        item.setOrderDetailId(rs.getInt("order_detail_id"));
        item.setVariantId(rs.getInt("variant_id"));
        item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
        item.setVariantAttributesSnapshot(rs.getString("variant_attributes_snapshot"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setCurrentStock(rs.getInt("current_stock"));
        return item;
    }
}
