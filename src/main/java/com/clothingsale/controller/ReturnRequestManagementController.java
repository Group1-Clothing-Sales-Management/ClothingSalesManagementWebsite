package com.clothingsale.controller;

import com.clothingsale.service.ReturnRequestService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.File;
import java.net.URI;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.UUID;
import jakarta.servlet.http.Part;

/**
 * Màn hình chung cho Staff và Admin.
 * Staff xử lý hồ sơ và xác nhận hàng; Admin duyệt bước hoàn tiền cuối cùng.
 */
@WebServlet(name = "ReturnRequestManagementController", urlPatterns = {"/staff/returns", "/admin/returns"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class ReturnRequestManagementController extends HttpServlet {

    private final ReturnRequestService service = new ReturnRequestService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!checkStaffOrAdmin(request, response)) return;
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            int id = parseId(request.getParameter("id"));
            request.setAttribute("returnRequest", service.getRequest(id));
            request.setAttribute("pageMode", "detail");
        } else {
            request.setAttribute("returnRequests", service.getStaffRequests(request.getParameter("keyword"), request.getParameter("status")));
            request.setAttribute("statusCounts", service.getStatusCounts());
            request.setAttribute("totalRefunded", service.getTotalRefunded());
            request.setAttribute("reportRows", service.getReportRows());
            request.setAttribute("pageMode", "list");
        }
        request.setAttribute("returnsBasePath", getBasePath(request));
        request.setAttribute("statusOptions", service.getStatusOptions());
        putFlash(request);
        request.getRequestDispatcher("/view/staff/staff_manage_returns.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!checkStaffOrAdmin(request, response)) return;
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        int userId = (Integer) session.getAttribute("authUserId");
        int requestId = parseId(request.getParameter("id"));
        String action = request.getParameter("action");
        String note = request.getParameter("note");
        String result;
        boolean admin = "ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("authRoleName")));

        // Staff dùng các action này để kiểm tra hồ sơ và xác nhận hàng đã về kho.
        if ("review".equalsIgnoreCase(action)) result = service.review(requestId, userId, request.getParameter("status"), note);
        else if ("receive".equalsIgnoreCase(action)) result = service.receive(requestId, userId, note);
        else if ("requestRefund".equalsIgnoreCase(action)) result = service.requestRefund(requestId, userId, note);
        else if ("confirmRefund".equalsIgnoreCase(action)) {
            // Cho phép dùng một ảnh upload hoặc một URL ảnh; không chấp nhận để trống cả hai.
            Part proofImage;
            try {
                proofImage = request.getPart("proofImage");
                String proofUrl = request.getParameter("proofUrl");
                boolean hasFile = hasUploadedFile(proofImage);
                boolean hasUrl = proofUrl != null && !proofUrl.trim().isEmpty();
                if (hasFile && hasUrl) {
                    result = "Please provide either an uploaded image or an image URL, not both.";
                } else if (!hasFile && !hasUrl) {
                    result = "Please upload the bank transfer proof image or provide an image URL.";
                } else if (hasFile) {
                    String validationError = validateProofImage(proofImage);
                    if (validationError != null) {
                        result = validationError;
                    } else {
                        String proofPath = saveRefundProof(proofImage, requestId);
                        result = service.confirmRefund(requestId, userId, note, proofPath);
                    }
                } else {
                    String validationError = validateProofUrl(proofUrl);
                    result = validationError == null
                            ? service.confirmRefund(requestId, userId, note, proofUrl.trim())
                            : validationError;
                }
            } catch (IOException | ServletException | IllegalArgumentException e) {
                result = e.getMessage() == null ? "Could not upload the refund proof image." : e.getMessage();
            }
        }
        // Chỉ Admin mới được ghi nhận tiền hoàn thành công hoặc từ chối khoản hoàn.
        else if (admin && "approveRefund".equalsIgnoreCase(action)) result = service.approveRefund(requestId, userId, note);
        else if (admin && "rejectRefund".equalsIgnoreCase(action)) result = service.rejectRefund(requestId, userId, note);
        else result = "You do not have permission for this action.";

        if (result.startsWith("SUCCESS:")) session.setAttribute("successMsg", result.substring("SUCCESS:".length()));
        else session.setAttribute("errorMsg", result);
        String returnMode = request.getParameter("returnMode");
        response.sendRedirect(getBasePath(request) + ("detail".equalsIgnoreCase(returnMode) ? "?action=view&id=" + requestId : ""));
    }

    private boolean checkStaffOrAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) { response.sendRedirect(request.getContextPath() + "/admin/login?error=unauthorized"); return false; }
        String role = String.valueOf(session.getAttribute("authRoleName"));
        if (!"STAFF".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied."); return false; }
        return true;
    }

    private void putFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false); if (session == null) return;
        Object ok=session.getAttribute("successMsg"); Object error=session.getAttribute("errorMsg");
        if(ok!=null){request.setAttribute("successMsg",ok);session.removeAttribute("successMsg");}
        if(error!=null){request.setAttribute("errorMsg",error);session.removeAttribute("errorMsg");}
    }
    private String getBasePath(HttpServletRequest request) { return request.getContextPath() + (request.getServletPath().startsWith("/admin") ? "/admin/returns" : "/staff/returns"); }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch(Exception e) { return 0; } }

    private String validateProofImage(Part part) {
        if (part.getSize() > 5 * 1024 * 1024) return "The refund proof image must be 5MB or smaller.";
        String contentType = part.getContentType() == null ? "" : part.getContentType().toLowerCase(Locale.ROOT);
        if (!("image/jpeg".equals(contentType) || "image/png".equals(contentType) || "image/webp".equals(contentType))) {
            return "The refund proof must be a JPG, PNG, or WEBP image.";
        }
        return null;
    }

    private boolean hasUploadedFile(Part part) {
        return part != null && part.getSubmittedFileName() != null
                && !part.getSubmittedFileName().trim().isEmpty() && part.getSize() > 0;
    }

    /** Chỉ nhận URL HTTP(S), tránh lưu các scheme nguy hiểm như javascript:. */
    private String validateProofUrl(String value) {
        if (value == null || value.trim().length() > 1000) return "The image URL is invalid or too long.";
        try {
            URI uri = URI.create(value.trim());
            String scheme = uri.getScheme();
            if (("http".equalsIgnoreCase(scheme) || "https".equalsIgnoreCase(scheme))
                    && uri.getHost() != null) return null;
        } catch (IllegalArgumentException ignored) {
            // Trả lỗi thân thiện cho người dùng thay vì để URI parser làm hỏng request.
        }
        return "Please provide a valid HTTP or HTTPS image URL.";
    }

    /** Lưu file với tên ngẫu nhiên, không dùng tên gốc để tránh path traversal và ghi đè file. */
    private String saveRefundProof(Part part, int requestId) throws IOException {
        String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String extension = ".jpg";
        int dot = original.lastIndexOf('.');
        if (dot >= 0 && dot < original.length() - 1) {
            String candidate = original.substring(dot).toLowerCase(Locale.ROOT);
            if (".png".equals(candidate) || ".webp".equals(candidate) || ".jpeg".equals(candidate) || ".jpg".equals(candidate)) extension = candidate;
        }
        String fileName = "refund-" + requestId + "-" + UUID.randomUUID() + extension;
        String basePath = getServletContext().getRealPath("");
        if (basePath == null) basePath = System.getProperty("user.dir");
        File directory = new File(basePath, "uploads" + File.separator + "refund");
        if (!directory.exists() && !directory.mkdirs()) throw new IOException("Could not create the refund upload directory.");
        part.write(new File(directory, fileName).getAbsolutePath());
        return "uploads/refund/" + fileName;
    }
}
