<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/view/admin/common/admin_layout_start.jsp" />

<div class="container-fluid px-4 mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Voucher Details: ${voucher.code}</h1>
        <a href="${pageContext.request.getContextPath()}/admin/voucher?action=list" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to list
        </a>
    </div>

    <div class="row">
        <div class="col-xl-6 col-md-12 mb-4">
            <div class="card shadow h-100 py-2">
                <div class="card-body">
                    <h5 class="font-weight-bold text-primary mb-3">Configuration Information</h5>
                    <table class="table table-bordered">
                        <tr>
                            <th width="35%">Campaign Title</th>
                            <td><strong>${voucher.title}</strong></td>
                        </tr>
                        <tr>
                            <th>Discount Type</th>
                            <td>
                                <c:choose>
                                    <c:when test="${voucher.discountType == 'PERCENTAGE'}">Percentage (%)</c:when>
                                    <c:otherwise>Fixed Amount (VND)</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Discount Value</th>
                            <td class="text-danger font-weight-bold">
                                <c:choose>
                                    <c:when test="${voucher.discountType == 'PERCENTAGE'}">
                                <fmt:formatNumber value="${voucher.discountValue}" maxFractionDigits="0"/>%
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/> ₫
                            </c:otherwise>
                        </c:choose>
                        </td>
                        </tr>
                        <tr>
                            <th>Maximum Discount</th>
                            <td>
                                <c:choose>
                                    <c:when test="${voucher.maxDiscountAmount != null}">
                                <fmt:formatNumber value="${voucher.maxDiscountAmount}" pattern="#,###"/> ₫
                            </c:when>
                            <c:otherwise>Unlimited</c:otherwise>
                        </c:choose>
                        </td>
                        </tr>
                        <tr>
                            <th>Minimum Order Value</th>
                            <td><fmt:formatNumber value="${voucher.minOrderValue}" pattern="#,###"/> ₫</td>
                        </tr>
                        <tr>
                            <th>Validity Period</th>
                            <td>
                                <span class="text-success">From: <fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy HH:mm"/></span><br>
                                <span class="text-danger">To: <fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        <div class="col-xl-6 col-md-12 mb-4">
            <div class="card shadow h-100 py-2">
                <div class="card-body">
                    <h5 class="font-weight-bold text-success mb-4">System Quantity Status</h5>

                    <div class="row text-center mb-4">
                        <div class="col-6 mb-3">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Limit</div>
                            <div class="h3 mb-0 font-weight-bold text-gray-800">${voucher.usageLimit}</div>
                        </div>
                        <div class="col-6 mb-3">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Total Saved</div>
                            <div class="h3 mb-0 font-weight-bold text-gray-800">${totalSaved}</div>
                        </div>
                        <div class="col-6">
                            <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Used in Orders</div>
                            <div class="h3 mb-0 font-weight-bold text-gray-800">${voucher.usedCount}</div>
                        </div>
                        <div class="col-6">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Available to Collect</div>
                            <div class="h3 mb-0 font-weight-bold text-gray-800">${voucher.usageLimit - totalSaved}</div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <h6 class="font-weight-bold text-xs">Actual Usage Rate (Used / Total Limit):</h6>
                        <div class="progress progress-sm mr-2">
                            <div class="progress-bar bg-danger" role="progressbar" 
                                 style="width: ${(voucher.usageLimit > 0) ? (voucher.usedCount * 100.0 / voucher.usageLimit) : 0}%"></div>
                        </div>
                    </div>

                    <div class="alert alert-info mt-4 text-xs" role="alert">
                        <i class="fas fa-info-circle"></i> <strong>Operational Tip:</strong> When reducing the total limit on the update page, the new limit cannot be lower than the number of vouchers already collected by customers (<strong>${totalSaved}</strong> items).
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/admin/common/admin_layout_end.jsp" />