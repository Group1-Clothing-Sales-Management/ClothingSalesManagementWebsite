<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit Product - Admin Panel</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <style>
            .product-preview { width: 180px; height: 180px; object-fit: cover; border-radius: 10px; }
            .form-note { font-size: 13px; color: #6c757d; }
        </style>
    </head>
    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="admin-page">
            <div class="container-fluid py-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h2 class="mb-1">Edit Product</h2>
                        <p class="text-muted mb-0">Update general product information and the main image.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/manage-product?action=view&id=${product.id}" class="btn btn-outline-secondary">
                        <i class="fa-solid fa-arrow-left mr-1"></i>Back to Details
                    </a>
                </div>

                <c:choose>
                    <c:when test="${param.status == 'product-updated'}">
                        <div class="alert alert-success"><i class="fa-solid fa-circle-check mr-1"></i>Product information was updated successfully.</div>
                    </c:when>
                    <c:when test="${param.status == 'name-required'}">
                        <div class="alert alert-danger">Product name is required.</div>
                    </c:when>
                    <c:when test="${param.status == 'name-too-long'}">
                        <div class="alert alert-danger">Product name must not exceed 150 characters.</div>
                    </c:when>
                    <c:when test="${param.status == 'category-required'}">
                        <div class="alert alert-danger">Please select a valid category.</div>
                    </c:when>
                    <c:when test="${param.status == 'invalid-status'}">
                        <div class="alert alert-danger">The selected product status is invalid.</div>
                    </c:when>
                    <c:when test="${param.status == 'invalid-image'}">
                        <div class="alert alert-danger">Only JPG, JPEG, PNG, and WEBP images are supported.</div>
                    </c:when>
                    <c:when test="${param.status == 'image-upload-failed'}">
                        <div class="alert alert-danger">The image could not be saved. Please check the upload directory and try again.</div>
                    </c:when>
                    <c:when test="${param.status == 'update-failed'}">
                        <div class="alert alert-danger">Product information could not be updated.</div>
                    </c:when>
                    <c:when test="${param.status == 'invalid-request'}">
                        <div class="alert alert-danger">The submitted product data is invalid.</div>
                    </c:when>
                </c:choose>

                <div class="card shadow-sm border-0">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0"><i class="fa-solid fa-box mr-2"></i>Product Information</h5>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="UPDATE_PRODUCT">
                            <input type="hidden" name="productId" value="${product.id}">

                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="form-group">
                                        <label for="productName" class="font-weight-bold">Product Name <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="productName" name="productName" maxlength="150" value="${product.productName}" required>
                                    </div>

                                    <div class="row">
                                        <div class="form-group col-md-6">
                                            <label for="categoryId" class="font-weight-bold">Category <span class="text-danger">*</span></label>
                                            <select class="form-control" id="categoryId" name="categoryId" required>
                                                <option value="">-- Select Category --</option>
                                                <c:forEach var="category" items="${categories}">
                                                    <option value="${category.id}" ${category.id == product.categoryId ? 'selected' : ''}>${category.categoryName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="form-group col-md-6">
                                            <label for="brandId" class="font-weight-bold">Brand</label>
                                            <select class="form-control" id="brandId" name="brandId">
                                                <option value="">-- No Brand --</option>
                                                <c:forEach var="brand" items="${brands}">
                                                    <option value="${brand.id}" ${brand.id == product.brandId ? 'selected' : ''}>${brand.brandName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="status" class="font-weight-bold">Product Status</label>
                                        <select class="form-control" id="status" name="status" required>
                                            <option value="ACTIVE" ${product.status == 'ACTIVE' ? 'selected' : ''}>Active — Visible on storefront</option>
                                            <option value="INACTIVE" ${product.status == 'INACTIVE' ? 'selected' : ''}>Inactive — Hidden from storefront</option>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="shortDescription" class="font-weight-bold">Short Description</label>
                                        <input type="text" class="form-control" id="shortDescription" name="shortDescription" maxlength="255" value="${product.shortDescription}">
                                    </div>

                                    <div class="form-group mb-0">
                                        <label for="longDescription" class="font-weight-bold">Long Description</label>
                                        <textarea class="form-control" id="longDescription" name="longDescription" rows="6">${product.longDescription}</textarea>
                                    </div>
                                </div>

                                <div class="col-lg-4 mt-4 mt-lg-0">
                                    <label class="font-weight-bold d-block">Main Product Image</label>
                                    <div class="text-center border rounded p-3 mb-3 bg-light">
                                        <c:choose>
                                            <c:when test="${not empty product.mainImageUrl}">
                                                <img id="imagePreview" src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}" alt="Product Image" class="product-preview img-thumbnail">
                                            </c:when>
                                            <c:otherwise>
                                                <img id="imagePreview" alt="Product Image Preview" class="product-preview img-thumbnail d-none">
                                                <div id="emptyImagePreview" class="text-muted py-5"><i class="fa-regular fa-image fa-3x mb-2 d-block"></i>No image uploaded</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="form-group">
                                        <input type="file" class="form-control-file" id="productImage" name="productImage" accept="image/jpeg,image/png,image/webp">
                                        <div class="form-note mt-2">Leave this field empty to keep the current image. Maximum file size: 10 MB.</div>
                                    </div>
                                </div>
                            </div>

                            <hr>
                            <div class="d-flex justify-content-end">
                                <a href="${pageContext.request.contextPath}/admin/manage-product?action=view&id=${product.id}" class="btn btn-light border mr-2">Cancel</a>
                                <button type="submit" class="btn btn-primary px-4"><i class="fa-solid fa-floppy-disk mr-1"></i>Save Changes</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
        <script>
            document.getElementById('productImage').addEventListener('change', function () {
                const file = this.files[0];
                if (!file) return;

                const preview = document.getElementById('imagePreview');
                const emptyPreview = document.getElementById('emptyImagePreview');
                preview.src = URL.createObjectURL(file);
                preview.classList.remove('d-none');
                if (emptyPreview) emptyPreview.classList.add('d-none');
            });
        </script>
    </body>
</html>