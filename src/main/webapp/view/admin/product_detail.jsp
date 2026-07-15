<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Details - Admin Panel</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </head>
    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>
        <div class="container admin-page">
            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/admin/manage-product" class="btn btn-sm btn-secondary">&larr; Back to Product List</a>
            </div>

            <c:if test="${param.status == 'success'}">
                <div class="d-none" data-product-toast data-product-toast-type="success">Action performed successfully!</div>
            </c:if>
            <c:if test="${param.status == 'error'}">
                <div class="d-none" data-product-toast data-product-toast-type="error">An error occurred while processing the request. Please check inputs.</div>
            </c:if>

            <div class="page-header">
                <div>
                    <h1 class="page-title">Product Details</h1>
                    <p class="page-subtitle mb-0">Inspect the product master record and its current variants.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${product.id}" class="btn btn-primary">
                    <i class="fa-solid fa-pen-to-square me-1"></i>Edit Info
                </a>
            </div>

            <div class="card card-main admin-card mb-4">
                <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">Product Core Profile</h4>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 text-center border-right">
                            <c:choose>
                                <c:when test="${not empty product.mainImageUrl}">
                                    <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}" alt="Main Image" class="img-fluid rounded img-thumbnail" />
                                </c:when>
                                <c:otherwise>
                                    <div class="bg-light d-flex align-items-center justify-content-center rounded" style="height: 180px;">
                                        <span class="text-muted">No Image Available</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="col-md-9">
                            <h3>${product.productName} <span class="badge badge-secondary text-sm" style="font-size: 14px;">ID: #${product.id}</span></h3>
                            <p class="text-muted font-italic mb-2">Slug URL: ${product.slug}</p>
                            <div class="row mb-3">
                                <div class="col-sm-4"><strong>Status:</strong> 
                                    <span class="badge ${product.status == 'ACTIVE' ? 'badge-success' : 'badge-warning'}">${product.status}</span>
                                </div>
                            </div>
                            <p><strong>Short Description:</strong> ${product.shortDescription}</p>
                            <p><strong>Long Description:</strong> ${product.longDescription}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card card-main admin-card mb-4">
                <div class="card-header bg-dark text-white">
                    <h5 class="mb-0">Current Stock Variants</h5>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover table-striped mb-0 admin-table">
                        <thead class="thead-light">
                            <tr>
                                <th>Variant ID</th>
                                <th>SKU Code</th>
                                <th>Combination Details</th>
                                <th>Stock Qty</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="variant" items="${variants}">
                                <tr>
                                    <td>#${variant.id}</td>
                                    <td><strong class="text-monospace text-primary">${variant.sku}</strong></td>
                                    <td>${variant.attributeDetails}</td>
                                    <td>
                                        <span class="badge ${variant.stockQuantity > 0 ? 'badge-success' : 'badge-secondary'}">
                                            ${variant.stockQuantity} Available
                                        </span>
                                    </td>
                                    <td class="align-middle text-center" style="width: 180px;">

                                        <div class="dropdown d-inline-block">
                                            <%-- Nút hiển thị trạng thái hiện tại --%>
                                            <button class="btn btn-sm dropdown-toggle status-dropdown-btn ${variant.status == 'ACTIVE' ? 'btn-success' : 'btn-danger'}" 
                                                    type="button" 
                                                    id="dropdownStatus-${variant.id}" 
                                                    data-bs-toggle="dropdown" 
                                                    aria-expanded="false"
                                                    style="font-size: 0.85rem; padding: 4px 12px; border-radius: 20px; font-weight: 500; min-width: 100px;">
                                                ${variant.status == 'ACTIVE' ? 'Active' : 'Inactive'}
                                            </button>

                                            <%-- Menu chọn trạng thái --%>
                                            <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="dropdownStatus-${variant.id}" style="border-radius: 8px; font-size: 0.9rem;">
                                                <li>
                                                    <a class="dropdown-item d-flex align-items-center py-2 ${variant.status == 'ACTIVE' ? 'disabled bg-light' : ''}" 
                                                       href="javascript:void(0)" 
                                                       onclick="changeVariantStatus('${variant.id}', 'ACTIVE', '${product.id}')">
                                                        <span class="badge bg-success me-2" style="width: 10px; height: 10px; border-radius: 50%;"></span> Active
                                                    </a>
                                                </li>
                                                <li>
                                                    <a class="dropdown-item d-flex align-items-center py-2 ${variant.status != 'ACTIVE' ? 'disabled bg-light' : ''}" 
                                                       href="javascript:void(0)" 
                                                       onclick="changeVariantStatus('${variant.id}', 'INACTIVE', '${product.id}')">
                                                        <span class="badge bg-danger me-2" style="width: 10px; height: 10px; border-radius: 50%;"></span> Inactive
                                                    </a>
                                                </li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty variants}">
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">No variants created for this product profile yet.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card card-main admin-card">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0">Add New Configuration Variant</h5>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="ADD_VARIANT" />
                        <input type="hidden" name="productId" value="${product.id}" />

                        <div class="row">
                            <div class="col-md-4 form-group">
                                <label for="skuCode">SKU Code <span class="text-danger">*</span></label>
                                <input type="text" id="skuCode" name="skuCode" class="form-control" placeholder="e.g., SHIRT-L-BLACK" required />
                            </div>
                            <div class="col-md-3 form-group">
                                <label for="color">Color Attribute</label>
                                <input type="text" id="color" name="color" class="form-control" placeholder="e.g., Black, White, Red" />
                            </div>
                            <div class="col-md-2 form-group">
                                <label for="size">Size Attribute</label>
                                <input type="text" id="size" name="size" class="form-control" placeholder="e.g., S, M, L, XL" />
                            </div>
                            <div class="col-md-3 form-group">
                                <label for="varStatus">Initial Status</label>
                                <select id="varStatus" name="status" class="form-control">
                                    <option value="ACTIVE">Active </option>
                                    <option value="INACTIVE">Inactive</option>
                                </select>
                            </div>
                        </div>



                        <button type="submit" class="btn btn-success px-4">Save & Generate Variant</button>
                    </form>
                </div>
            </div>
        </div>

        <form id="masterStatusForm"
      action="${pageContext.request.contextPath}/admin/manage-product"
      method="POST"
      class="d-none">

    <input type="hidden" name="action" value="UPDATE_VARIANT_STATUS">
    <input type="hidden" name="productId" id="submitProductId">
    <input type="hidden" name="variantId" id="submitVariantId">
    <input type="hidden" name="status" id="submitVariantStatus">
</form>
    </body>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
                   function changeVariantStatus(variantId, nextStatus, productId) {
    const isActivating = nextStatus === 'ACTIVE';
    const actionText = isActivating ? 'activate' : 'deactivate';

    Swal.fire({
        title: isActivating ? 'Activate Variant?' : 'Deactivate Variant?',
        text: `Are you sure you want to ${actionText} this variant?`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: isActivating ? '#198754' : '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: isActivating
                ? 'Yes, activate it'
                : 'Yes, deactivate it',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (!result.isConfirmed) {
            return;
        }

        document.getElementById('submitProductId').value = productId;
        document.getElementById('submitVariantId').value = variantId;
        document.getElementById('submitVariantStatus').value = nextStatus;
        document.getElementById('masterStatusForm').submit();
    });
}

                   // Hiển thị Toast thông báo thành công sau khi trang reload lại
                   document.addEventListener("DOMContentLoaded", function () {
                       const Toast = Swal.mixin({
                           toast: true,
                           position: 'top-end',
                           showConfirmButton: false,
                           timer: 3000,
                           timerProgressBar: true,
                           didOpen: (toast) => {
                               toast.addEventListener('mouseenter', Swal.stopTimer);
                               toast.addEventListener('mouseleave', Swal.resumeTimer);
                           }
                       });

                       document.querySelectorAll('[data-product-toast]').forEach(function (node) {
                           const type = node.getAttribute('data-product-toast-type') || 'info';
                           const message = (node.textContent || '').trim();
                           if (message) {
                               Toast.fire({
                                   icon: type,
                                   title: message
                               });
                           }
                           node.remove();
                       });

                       const urlParams = new URLSearchParams(window.location.search);
                       if (urlParams.get('success') === 'StatusUpdated') {
                           Toast.fire({
                               icon: 'success',
                               title: 'Variant status updated successfully'
                           });
                       }
                   });
    </script>
</html>
