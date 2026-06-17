<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Manage Address</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
    </head>

    <body>

        <div class="container mt-4">

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2>My Addresses</h2>

                <button class="btn btn-primary"
                        data-bs-toggle="modal"
                        data-bs-target="#addAddressModal">
                    Add Address
                </button>
            </div>

            <table class="table table-bordered table-hover">

                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Recipient</th>
                        <th>Phone</th>
                        <th>Ward</th>
                        <th>Address</th>
                        <th>Default</th>
                        <th width="250">Action</th>
                    </tr>
                </thead>

                <tbody>

                    <c:forEach items="${addresses}" var="a">

                        <tr>

                            <td>${a.id}</td>

                            <td>${a.recipientName}</td>

                            <td>${a.recipientPhone}</td>

                            <td>${a.wardId}</td>

                            <td>${a.addressDetail}</td>

                            <td>

                                <c:if test="${a['default']}">
                                    <span class="badge bg-success">
                                        Default
                                    </span>
                                </c:if>

                                <c:if test="${!a['default']}">
                                    <span class="badge bg-secondary">
                                        Normal
                                    </span>
                                </c:if>

                            </td>

                            <td>

                                <button class="btn btn-warning btn-sm"
                                        data-bs-toggle="modal"
                                        data-bs-target="#editModal${a.id}">
                                    Edit
                                </button>

                                <a href="${pageContext.request.contextPath}/customer/address?action=delete&id=${a.id}"
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Delete this address?')">
                                    Delete
                                </a>

                                <c:if test="${!a['default']}">

                                    <a href="${pageContext.request.contextPath}/customer/address?action=setDefault&id=${a.id}"
                                       class="btn btn-success btn-sm">

                                        Set Default

                                    </a>

                                </c:if>

                            </td>

                        </tr>

                    </c:forEach>

                </tbody>

            </table>

        </div>

        <!-- EDIT MODALS -->

        <c:forEach items="${addresses}" var="a">

            <div class="modal fade"
                 id="editModal${a.id}"
                 tabindex="-1">

                <div class="modal-dialog">

                    <div class="modal-content">

                        <form method="post"
                              action="${pageContext.request.contextPath}/customer/address?action=update">

                            <div class="modal-header">

                                <h5 class="modal-title">
                                    Edit Address
                                </h5>

                                <button type="button"
                                        class="btn-close"
                                        data-bs-dismiss="modal">
                                </button>

                            </div>

                            <div class="modal-body">

                                <input type="hidden"
                                       name="id"
                                       value="${a.id}">

                                <div class="mb-3">

                                    <label class="form-label">
                                        Recipient Name
                                    </label>

                                    <input type="text"
                                           name="recipientName"
                                           value="${a.recipientName}"
                                           class="form-control"
                                           required>

                                </div>

                                <div class="mb-3">

                                    <label class="form-label">
                                        Phone
                                    </label>

                                    <input type="text"
                                           name="recipientPhone"
                                           value="${a.recipientPhone}"
                                           class="form-control"
                                           required>

                                </div>

                                <div class="mb-3">

                                    <label class="form-label">
                                        Ward ID
                                    </label>

                                    <input type="text"
                                           name="wardId"
                                           value="${a.wardId}"
                                           class="form-control"
                                           required>

                                </div>

                                <div class="mb-3">

                                    <label class="form-label">
                                        Address Detail
                                    </label>

                                    <textarea name="addressDetail"
                                              class="form-control"
                                              rows="3">${a.addressDetail}</textarea>

                                </div>

                                <div class="form-check">

                                    <input class="form-check-input"
                                           type="checkbox"
                                           name="isDefault"
                                           ${a['default'] ? 'checked' : ''}>

                                    <label class="form-check-label">
                                        Set as default
                                    </label>

                                </div>

                            </div>

                            <div class="modal-footer">

                                <button type="submit"
                                        class="btn btn-primary">

                                    Update

                                </button>

                            </div>

                        </form>

                    </div>

                </div>

            </div>

        </c:forEach>

        <!-- ADD MODAL -->

        <div class="modal fade"
             id="addAddressModal"
             tabindex="-1">

            <div class="modal-dialog">

                <div class="modal-content">

                    <form method="post"
                          action="${pageContext.request.contextPath}/customer/address?action=insert">

                        <div class="modal-header">

                            <h5 class="modal-title">
                                Add Address
                            </h5>

                            <button type="button"
                                    class="btn-close"
                                    data-bs-dismiss="modal">
                            </button>

                        </div>

                        <div class="modal-body">

                            <div class="mb-3">

                                <label class="form-label">
                                    Recipient Name
                                </label>

                                <input type="text"
                                       name="recipientName"
                                       class="form-control"
                                       required>

                            </div>

                            <div class="mb-3">

                                <label class="form-label">
                                    Phone
                                </label>

                                <input type="text"
                                       name="recipientPhone"
                                       class="form-control"
                                       required>

                            </div>

                            <div class="mb-3">

                                <label class="form-label">
                                    Ward ID
                                </label>

                                <input type="text"
                                       name="wardId"
                                       class="form-control"
                                       required>

                            </div>

                            <div class="mb-3">

                                <label class="form-label">
                                    Address Detail
                                </label>

                                <textarea name="addressDetail"
                                          class="form-control"
                                          rows="3"></textarea>

                            </div>

                            <div class="form-check">

                                <input class="form-check-input"
                                       type="checkbox"
                                       name="isDefault">

                                <label class="form-check-label">
                                    Set as default
                                </label>

                            </div>

                        </div>

                        <div class="modal-footer">

                            <button type="submit"
                                    class="btn btn-success">

                                Save

                            </button>

                        </div>

                    </form>

                </div>

            </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    </body>
</html>