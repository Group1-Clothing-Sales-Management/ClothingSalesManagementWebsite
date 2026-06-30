<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Product - Admin Panel</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    </head>
    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="products" />
        </jsp:include>

        <div class="admin-page">
        <div class="container-fluid">
            <div class="card mb-4">
                <div class="card-header bg-dark text-white">
                    <h4 class="mb-0">Edit Product Information</h4>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="UPDATE" />
                        <input type="hidden" name="productId" value="${product.id}" />

                        <h5 class="text-primary border-bottom pb-2">General Specification</h5>
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label for="productName">Product Name</label>
                                <input type="text" class="form-control" id="productName" name="productName" value="${product.productName}" required />
                            </div>
                            <div class="form-group col-md-3">
                                <label for="brandId">Brand</label>
                                <select class="form-control" id="brandId" name="brandId">
                                    <c:forEach var="brand" items="${brands}">
                                        <option value="${brand.id}" ${brand.id == product.brandId ? 'selected' : ''}>${brand.brandName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group col-md-3">
                                <label for="categoryId">Category</label>
                                <select class="form-control" id="categoryId" name="categoryId">
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${cat.id == product.categoryId ? 'selected' : ''}>${cat.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Current Product Image</label>
                                <div class="mb-2">
                                    <c:choose>
                                        <c:when test="${not empty product.mainImageUrl}">
                                            <img src="${pageContext.request.contextPath}/uploads/product/${product.mainImageUrl}" alt="Product Image" style="max-height: 120px;" class="img-thumbnail" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No image uploaded</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <label for="productImage">Upload New Image</label>
                                <input type="file" class="form-control-file" id="productImage" name="productImage" />
                            </div>
                            <div class="form-group col-md-6">
                                <label for="status">Product Visibility Status</label>
                                <select class="form-control" id="status" name="status">
                                    <option value="ACTIVE" ${product.status == 'ACTIVE' ? 'selected' : ''}>Active (Show on store)</option>
                                    <option value="INACTIVE" ${product.status == 'INACTIVE' ? 'selected' : ''}>Inactive (Hide from store)</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="shortDescription">Short Description</label>
                            <input type="text" class="form-control" id="shortDescription" name="shortDescription" value="${product.shortDescription}" />
                        </div>
                        <div class="form-group">
                            <label for="longDescription">Long Description</label>
                            <textarea class="form-control" id="longDescription" name="longDescription" rows="3">${product.longDescription}</textarea>
                        </div>

                        <button type="submit" class="btn btn-primary">Save General Info</button>
                        <a href="${pageContext.request.contextPath}/admin/manage-product?action=view&id=${product.id}" class="btn btn-secondary">Cancel</a>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-header bg-secondary text-white">
                    <h5 class="mb-0">Variants Status Control Center</h5>
                </div>
                <div class="card-body p-0">
                    <table class="table table-bordered table-striped mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>SKU Code</th>
                                <th>Attributes</th>
                                <th>Stock Qty</th>
                                <th>Sales Status</th>
                                <th style="width: 150px;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="variant" items="${variants}" varStatus="loop">
                                <tr>
                            <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="UPDATE" />
                                <input type="hidden" name="productId" value="${product.id}" />
                                <input type="hidden" name="variants[0].id" value="${variant.id}" />

                                <td><code class="text-dark font-weight-bold">${variant.sku}</code></td>
                                <td>${variant.attributeDetails}</td>
                                <td>
                                    <span class="badge ${variant.stockQuantity > 0 ? 'badge-success' : 'badge-danger'}">
                                        ${variant.stockQuantity} items
                                    </span>
                                </td>
                                <td>
                                    <select name="variants[0].status" class="form-control form-control-sm">
                                        <option value="ACTIVE" ${variant.status == 'ACTIVE' ? 'selected' : ''}>Active (On Sale)</option>
                                        <option value="INACTIVE" ${variant.status == 'INACTIVE' ? 'selected' : ''}>Inactive (Stop Selling)</option>
                                    </select>
                                </td>
                                <td>
                                    <button type="submit" class="btn btn-sm btn-success btn-block">Update Status</button>
                                </td>
                            </form>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty variants}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-3">No variants configured for this product yet.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
    </body>
</html>
