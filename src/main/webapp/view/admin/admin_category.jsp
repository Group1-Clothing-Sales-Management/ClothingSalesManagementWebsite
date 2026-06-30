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
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="categories" />
        </jsp:include>

            <div class="container-fluid admin-page" style="flex: 1;">

                <div class="page-header">
                    <h2 class="page-title">
                        <i class="fa-solid fa-tags me-2"></i>Product Category Management
                    </h2>
                    <button type="button" class="btn btn-success d-flex align-items-center" 
                            data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="openAddModal()">
                        <i class="fa-solid fa-plus-circle me-2"></i>Add New Category
                    </button>
                </div>

                <c:if test="${param.status == 'success'}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="success">Action executed successfully!</div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error">An error occurred. Please try again!</div>
                </c:if>
                <c:if test="${param.status == 'duplicate'}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="warning"><strong>Duplicate Name!</strong> This category already exists.</div>
                </c:if>

                <div class="card card-main admin-card">
                    <div class="card-header bg-dark text-white d-flex align-items-center">
                        <i class="fa-solid fa-list me-2"></i>
                        <h5 class="card-title mb-0">Category List</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover table-bordered align-middle mb-0 admin-table">
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
                                        <tr>
                                            <td class="text-center text-muted fw-bold">${cat.id}</td>
                                            <td><span class="text-dark fw-medium">${cat.categoryName}</span></td>
                                            <td><code class="text-danger bg-danger-subtle px-2 py-1 rounded">${cat.slug}</code></td>
                                            <td class="text-center">
                                                <div class="d-inline-flex gap-2">
                                                    <button type="button" class="btn btn-sm btn-outline-primary"
                                                            data-bs-toggle="modal" data-bs-target="#categoryModal"
                                                            onclick="openEditModal('${cat.id}', '${cat.categoryName}', '${cat.slug}')">
                                                        <i class="fa-solid fa-pen me-1"></i>Edit
                                                    </button>
                                                    <form action="${pageContext.request.contextPath}/admin/manage-category" method="post" 
                                                          onsubmit="return confirm('Are you sure you want to delete this category?');" class="m-0">
                                                        <input type="hidden" name="action" value="DELETE">
                                                        <input type="hidden" name="categoryId" value="${cat.id}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger">
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
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <div class="modal fade" id="categoryModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="categoryModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow">
                    <form action="${pageContext.request.contextPath}/admin/manage-category" method="post">
                        
                        <input type="hidden" name="action" id="modalAction" value="ADD">
                        <input type="hidden" name="categoryId" id="modalCategoryId" value="">

                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title" id="categoryModalLabel">
                                <i class="fa-solid fa-tag me-2"></i><span id="modalTitleText">Add New Category</span>
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        
                        <div class="modal-body p-4">
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">Category Name</label>
                                <input type="text" name="categoryName" id="modalCategoryName" class="form-control" required placeholder="e.g., Spring Collection">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">Slug URL</label>
                                <input type="text" name="slug" id="modalSlug" class="form-control" required placeholder="e.g., spring-collection">
                            </div>
                        </div>
                        
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-success" id="modalSubmitBtn">
                                <i class="fa-solid fa-floppy-disk me-1"></i>Save Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            const modalTitleText = document.getElementById('modalTitleText');
            const modalAction = document.getElementById('modalAction');
            const modalCategoryId = document.getElementById('modalCategoryId');
            const modalCategoryName = document.getElementById('modalCategoryName');
            const modalSlug = document.getElementById('modalSlug');
            const modalSubmitBtn = document.getElementById('modalSubmitBtn');

            // Cấu hình khi mở chế độ THÊM MỚI
            function openAddModal() {
                modalTitleText.innerText = "Add New Category";
                modalAction.value = "ADD";
                modalCategoryId.value = "";
                modalCategoryName.value = "";
                modalSlug.value = "";
                
                modalSubmitBtn.className = "btn btn-success";
                modalSubmitBtn.innerHTML = '<i class="fa-solid fa-plus me-1"></i>Add New';
            }

            // Cấu hình khi mở chế độ CHỈNH SỬA
            function openEditModal(id, name, slug) {
                modalTitleText.innerText = "Edit Category: " + name;
                modalAction.value = "UPDATE";
                modalCategoryId.value = id;
                modalCategoryName.value = name;
                modalSlug.value = slug;
                
                modalSubmitBtn.className = "btn btn-primary";
                modalSubmitBtn.innerHTML = '<i class="fa-solid fa-rotate me-1"></i>Update Changes';
            }

            // Tự động sinh Slug mượt mà từ Category Name khi gõ
            modalCategoryName.addEventListener('input', function() {
                let text = this.value.toLowerCase();
                text = text.normalize('NFD').replace(/[\u0300-\u036f]/g, ''); // Bỏ dấu tiếng Việt
                text = text.replace(/[đĐ]/g, 'd');
                text = text.replace(/([^0-9a-z-\s])/g, ''); // Xóa kí tự đặc biệt
                text = text.replace(/(\s+)/g, '-'); // Đổi khoảng trắng sang dấu gạch ngang
                text = text.replace(/-+/g, '-');
                text = text.trim().replace(/^-+|-+$/g, ''); 
                modalSlug.value = text;
            });
        </script>
    </body>
</html>
