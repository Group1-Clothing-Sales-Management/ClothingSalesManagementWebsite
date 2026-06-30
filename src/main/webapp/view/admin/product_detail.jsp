<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Product Details - Admin Panel</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
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
                                    <td>
                                        <span class="badge ${variant.status == 'ACTIVE' ? 'badge-success' : 'badge-danger'}">
                                            ${variant.status == 'ACTIVE' ? 'Active' : 'Inactive'}
                                        </span>
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
                                    <option value="ACTIVE">Active (Available for import)</option>
                                    <option value="INACTIVE">Inactive (Hidden)</option>
                                </select>
                            </div>
                        </div>

                        <div class="alert alert-warning py-2 mb-3" style="font-size: 13px;">
                            💡 <strong>Warehouse Stock Policy:</strong> To maintain exact inventory control, initial price values (Cost/Sale Price) and Stock quantities for this new variant will be set to <strong>0</strong>. Please use the <strong>Stock Import module</strong> when actual goods arrive to update physical counts and purchase records.
                        </div>

                        <button type="submit" class="btn btn-success px-4">Save & Generate Variant</button>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>