<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Details - Admin Panel</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </head>
    <body>
        <div class="container mt-5">
            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/admin/manage-product" class="btn btn-sm btn-secondary">&larr; Back to Product List</a>
            </div>

            <c:if test="${param.status == 'success'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    Action performed successfully!
                </div>
            </c:if>
            <c:if test="${param.status == 'error'}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    An error occurred while processing the request. Please check inputs.
                </div>
            </c:if>
            <c:if test="${param.status == 'duplicate'}">
                <div class="d-none" data-product-toast data-product-toast-type="error">Biến thể hoặc tổ hợp Màu/Size này đã tồn tại trong hệ thống!</div>
            </c:if>

            <div class="card mb-4">
                <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">Product Core Profile</h4>
                    <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${product.id}" class="btn btn-sm btn-light">Edit Info</a>
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

            <div class="card mb-4">
                <div class="card-header bg-dark text-white">
                    <h5 class="mb-0">Current Stock Variants</h5>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover table-striped mb-0">
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
                                            <button class="btn btn-sm dropdown-toggle status-dropdown-btn ${variant.status == 'ACTIVE' || variant.status == 'Active' || variant.status == '1' ? 'btn-success' : 'btn-danger'}" 
                                                    type="button" 
                                                    id="dropdownStatus-${variant.id}" 
                                                    data-bs-toggle="dropdown" 
                                                    aria-expanded="false"
                                                    style="font-size: 0.85rem; padding: 4px 12px; border-radius: 20px; font-weight: 500; min-width: 100px;">
                                                ${variant.status == 'ACTIVE' || variant.status == 'Active' || variant.status == '1' ? 'Active' : 'Inactive'}
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="dropdownStatus-${variant.id}" style="border-radius: 8px; font-size: 0.9rem;">
                                                <li>
                                                    <a class="dropdown-menu-item dropdown-item d-flex align-items-center py-2 ${variant.status == 'ACTIVE' || variant.status == 'Active' || variant.status == '1' ? 'disabled bg-light' : ''}" 
                                                       href="javascript:void(0)" 
                                                       onclick="changeVariantStatus('${variant.id}', 'ACTIVE', '${product.id}')">
                                                        <span class="badge bg-success me-2" style="width: 10px; height: 10px; border-radius: 50%; p-0"> </span> Active
                                                    </a>
                                                </li>
                                                <li>
                                                    <a class="dropdown-menu-item dropdown-item d-flex align-items-center py-2 ${variant.status != 'ACTIVE' && variant.status != 'Active' && variant.status != '1' ? 'disabled bg-light' : ''}" 
                                                       href="javascript:void(0)" 
                                                       onclick="changeVariantStatus('${variant.id}', 'INACTIVE', '${product.id}')">
                                                        <span class="badge bg-danger me-2" style="width: 10px; height: 10px; border-radius: 50%; p-0"> </span> Inactive
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

            <div class="card">
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
                                <input type="text" id="skuCode" name="skuCode" class="form-control"required />
                            </div>
                            <div class="col-md-3 form-group">
                                <label for="color">Color Attribute</label>
                                <input type="text" id="color" name="color" class="form-control" placeholder="e.g., Black, White, Red" />
                            </div>
                            <div class="col-md-2 form-group">
                                <label for="size">Size Attribute</label>
                                <select id="size" name="size" class="form-control">
                                    <option value="S">S</option>
                                    <option value="M">M</option>
                                    <option value="L">L</option>
                                    <option value="XL">XL</option>
                                    <option value="XXL">XXL</option>
                                </select>
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

        <c:url value="/admin/products" var="adminProductUrl" />

        <form id="masterStatusForm" action="${adminProductUrl}" method="POST" style="display:none;">
            <input type="hidden" name="action" value="updateVariantStatus">
            <input type="hidden" name="productId" id="submitProductId">
            <input type="hidden" name="variantId" id="submitVariantId">
            <input type="hidden" name="newStatus" id="submitNewStatus">
        </form>
    </body>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
                   // Định nghĩa hàm đổi trạng thái biến thể
                   function changeVariantStatus(variantId, nextStatus, productId) {
                       const statusText = nextStatus === 'Active' ? 'Activate' : 'Deactivate';
                       const confirmButtonColor = nextStatus === 'Active' ? '#198754' : '#dc3545';
                       Swal.fire({
                           title: 'Change Status?',
                           text: `Are you sure you want to change this variant status to ${nextStatus}?`,
                           icon: 'question',
                           showCancelButton: true,
                           confirmButtonColor: confirmButtonColor,
                           cancelButtonColor: '#6c757d',
                           confirmButtonText: `Yes, ${statusText}!`,
                           cancelButtonText: 'Cancel',
                           background: '#ffffff',
                           customClass: {
                               popup: 'rounded-4 shadow-lg'
                           }
                       }).then((result) => {
                           if (result.isConfirmed) {
                               document.getElementById('submitProductId').value = productId;
                               document.getElementById('submitVariantId').value = variantId;
                               document.getElementById('submitNewStatus').value = nextStatus;
                               document.getElementById('masterStatusForm').submit();
                           }
                       });
                   }

                   // KHỐI XỬ LÝ CHÍNH KHI TRANG TẢI XONG
                   document.addEventListener("DOMContentLoaded", function () {

                       // 1. HIỂN THỊ TOAST THÔNG BÁO THÀNH CÔNG
                       const urlParams = new URLSearchParams(window.location.search);
                       const statusParam = urlParams.get('status');
                       if (urlParams.get('success') === 'StatusUpdated' || statusParam === 'success') {
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
                           Toast.fire({
                               icon: 'success',
                               title: 'Thao tác dữ liệu thành công!'
                           });
                       }

                       // 2. TỰ ĐỘNG TẠO MÃ SKU (CODE ĐÃ ĐƯỢC LÀM CHO AN TOÀN TUYỆT ĐỐI)
                       const colorInput = document.getElementById("color");
                       const sizeSelect = document.getElementById("size");
                       const skuCodeInput = document.getElementById("skuCode");

                       // Dùng nháy kép và escape an toàn của JSP
                       let productNameRaw = "<c:out value='${product.productName}' escapeXml='true' />";
                       if (!productNameRaw || productNameRaw.trim() === "") {
                           productNameRaw = "PROD"; // Giá trị mặc định nếu rỗng
                       }

                       function generateSingleSku() {
                           // Tiền tố tên sản phẩm
                           let prefix = productNameRaw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "-").substring(0, 8);
                           if (!prefix)
                               prefix = "PROD";

                           // Màu sắc
                           let colorVal = colorInput.value.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
                           if (!colorVal)
                               colorVal = "STANDARD";

                           // Kích cỡ
                           let sizeVal = sizeSelect.value;

                           // Cập nhật ô SKU
                           skuCodeInput.value = prefix + "-" + colorVal + "-" + sizeVal;
                       }

                       // Bắt sự kiện
                       if (colorInput && sizeSelect && skuCodeInput) {
                           colorInput.addEventListener("input", generateSingleSku);
                           sizeSelect.addEventListener("change", generateSingleSku);
                           generateSingleSku(); // Chạy ngay lần đầu để sinh chuỗi mặc định
                       }

                       // 3. KIỂM TRA TRÙNG LẶP THUỘC TÍNH (COLOR + SIZE)
                       // Lấy form một cách an toàn không dùng cú pháp '?.'
                       const variantActionInput = document.querySelector('form[action*="manage-product"] input[name="action"][value="ADD_VARIANT"]');
                       const variantForm = variantActionInput ? variantActionInput.form : null;

                       if (variantForm) {
                           variantForm.addEventListener("submit", function (e) {

                               let inputColor = (document.getElementById("color").value || "").trim();
                               if (!inputColor)
                                   inputColor = "Standard";

                               let inputSize = document.getElementById("size").value || "FreeSize";

                               const inputCombination = (inputColor + "|" + inputSize).toLowerCase().replace(/\s+/g, '');
                               let isDuplicateOnUi = false;

                               document.querySelectorAll(".admin-table tbody tr").forEach(function (row) {
                                   const cells = row.querySelectorAll("td");
                                   if (cells.length >= 3) {
                                       const existingCombination = cells[2].textContent.toLowerCase().replace(/\s+/g, '');
                                       if (existingCombination === inputCombination) {
                                           isDuplicateOnUi = true;
                                       }
                                   }
                               });

                               if (isDuplicateOnUi) {
                                   e.preventDefault();
                                   Swal.fire({
                                       icon: 'error',
                                       title: 'Trùng lặp thuộc tính!',
                                       text: 'Tổ hợp Màu sắc và Kích cỡ này đã tồn tại trong cấu hình của sản phẩm.',
                                       confirmButtonColor: '#dc3545'
                                   });
                               }
                           });
                       }
                   });
    </script> 
</html>