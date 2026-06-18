<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Category Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="d-flex">
            <jsp:include page="sidebar.jsp" />

            <div class="container-fluid p-4" style="flex: 1;">

                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                    <h2 class="text-secondary fw-semibold">
                        <i class="fa-solid fa-tags me-2"></i>Product Category Management
                    </h2>
                </div>

                <c:if test="${param.status == 'success'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i>
                        <div>Action executed successfully!</div>
                        <button type="button" class="btn-close" data-vis="alert" aria-label="Close" onclick="this.parentElement.style.display = 'none';"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i>
                        <div>An error occurred. Please check your data input and try again!</div>
                        <button type="button" class="btn-close" data-vis="alert" aria-label="Close" onclick="this.parentElement.style.display = 'none';"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'duplicate'}">
                    <div class="alert alert-warning alert-dismissible fade show d-flex align-items-center" role="alert">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i>
                        <div><strong>Duplicate errors!</strong> This category name or URL (Slug) already exists in the system..</div>
                        <button type="button" class="btn-close" aria-label="Close" onclick="this.parentElement.style.display = 'none';"></button>
                    </div>
                </c:if>

                <div class="card shadow-sm mb-4">
                    <c:choose>
                        <%-- CASE 1: IN EDIT MODE --%>
                        <c:when test="${not empty category}">
                            <div class="card-header bg-primary text-white d-flex align-items-center">
                                <i class="fa-solid fa-pen-to-square me-2"></i>
                                <h5 class="card-title mb-0">Edit Category: <span class="badge bg-light text-primary">${category.categoryName}</span></h5>
                            </div>
                            <div class="card-body bg-light-subtle">
                                <form action="${pageContext.request.contextPath}/admin/manage-category" method="post" class="row g-3 align-items-end">
                                    <input type="hidden" name="action" value="UPDATE">
                                    <input type="hidden" name="categoryId" value="${category.id}">

                                    <div class="col-md-5">
                                        <label class="form-label fw-bold text-muted">Category Name</label>
                                        <input type="text" name="categoryName" class="form-control" value="${category.categoryName}" required>
                                    </div>

                                    <div class="col-md-5">
                                        <label class="form-label fw-bold text-muted">Slug URL</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-secondary-subtle text-muted"><i class="fa-solid fa-link"></i></span>
                                            <input type="text" name="slug" class="form-control" value="${category.slug}" required>
                                        </div>
                                    </div>

                                    <div class="col-md-2 d-flex gap-2">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fa-solid fa-floppy-disk me-1"></i>Save
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/manage-category" class="btn btn-outline-secondary w-100">
                                            Cancel
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </c:when>

                        <%-- CASE 2: DEFAULT MODE (ADD NEW CATEGORY) --%>
                        <c:otherwise>
                            <div class="card-header bg-success text-white d-flex align-items-center">
                                <i class="fa-solid fa-plus-circle me-2"></i>
                                <h5 class="card-title mb-0">Create New Category</h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/admin/manage-category" method="post" class="row g-3 align-items-end">
                                    <input type="hidden" name="action" value="ADD">

                                    <div class="col-md-5">
                                        <label class="form-label fw-bold text-muted">Category Name</label>
                                        <input type="text" name="categoryName" class="form-control" required placeholder="e.g., Men T-Shirt">
                                    </div>

                                    <div class="col-md-5">
                                        <label class="form-label fw-bold text-muted">Slug URL</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-secondary-subtle text-muted"><i class="fa-solid fa-link"></i></span>
                                            <input type="text" name="slug" class="form-control" required placeholder="e.g., men-t-shirt">
                                        </div>
                                    </div>

                                    <div class="col-md-2">
                                        <button type="submit" class="btn btn-success w-100">
                                            <i class="fa-solid fa-plus me-1"></i>Add New
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="card shadow-sm">
                    <div class="card-header bg-dark text-white d-flex align-items-center">
                        <i class="fa-solid fa-list me-2"></i>
                        <h5 class="card-title mb-0">Category List</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover table-bordered align-middle mb-0">
                                <thead class="table-secondary text-uppercase fs-7">
                                    <tr>
                                        <th style="width: 10%;" class="text-center">ID</th>
                                        <th style="width: 45%;">Category Name</th>
                                        <th style="width: 25%;">Slug URL</th>
                                        <th style="width: 20%;" class="text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="cat" items="${categories}">
                                        <tr class="${category.id == cat.id ? 'table-warning fw-semibold' : ''}">
                                            <td class="text-center text-muted fw-bold">${cat.id}</td>
                                            <td>
                                                <span class="text-dark">${cat.categoryName}</span>
                                            </td>
                                            <td>
                                                <code class="text-danger bg-danger-subtle px-2 py-1 rounded">${cat.slug}</code>
                                            </td>
                                            <td class="text-center">
                                                <div class="d-inline-flex gap-2">
                                                    <a href="${pageContext.request.contextPath}/admin/manage-category?action=edit&id=${cat.id}" 
                                                       class="btn btn-sm btn-outline-primary d-flex align-items-center">
                                                        <i class="fa-solid fa-pen me-1"></i>Edit
                                                    </a>

                                                    <form action="${pageContext.request.contextPath}/admin/manage-category" method="post" 
                                                          onsubmit="return confirm('Are you sure you want to delete this category? This action cannot be undone.');" class="m-0">
                                                        <input type="hidden" name="action" value="DELETE">
                                                        <input type="hidden" name="categoryId" value="${cat.id}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger d-flex align-items-center">
                                                            <i class="fa-solid fa-trash me-1"></i>Delete
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>