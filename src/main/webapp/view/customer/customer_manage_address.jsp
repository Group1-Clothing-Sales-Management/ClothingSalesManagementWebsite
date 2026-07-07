<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Manage Address</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
              rel="stylesheet">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <style>

            body{
                background:#f5f7fb;
                font-family:'Segoe UI',sans-serif;
            }

            .page-title{
                font-size:34px;
                font-weight:700;
                color:#212529;
            }

            .page-subtitle{
                color:#6c757d;
            }

            .address-card{
                background:white;
                border-radius:18px;
                padding:22px;
                margin-bottom:20px;
                box-shadow:0 5px 20px rgba(0,0,0,.06);
                transition:.25s;
            }

            .address-card:hover{
                transform:translateY(-3px);
                box-shadow:0 10px 30px rgba(0,0,0,.12);
            }

            .user-name{
                font-size:20px;
                font-weight:700;
            }

            .info{
                color:#6c757d;
                margin-top:10px;
            }

            .badge-default{
                background:#16a34a;
                padding:8px 14px;
                border-radius:30px;
                color:white;
                font-size:13px;
            }

            .action-btn{
                border-radius:12px;
                padding:8px 18px;
            }

            .btn-add{
                border-radius:12px;
                padding:10px 22px;
            }

            .modal-content{
                border-radius:18px;
                border:none;
            }

            .form-control{
                border-radius:12px;
            }

            textarea{
                resize:none;
            }

        </style>
    </head>

    <body>

        <div class="container mt-4">

            <div class="d-flex justify-content-between align-items-center mb-3">

                <div>

                    <div class="page-title">
                        My Addresses
                    </div>

                    <div class="page-subtitle">
                        Manage your shipping addresses
                    </div>

                </div>
                <c:if test="${from eq 'checkout'}">

                    <a href="${pageContext.request.contextPath}/customer/checkout"
                       class="btn btn-success">

                        ← Back To Checkout

                    </a>

                </c:if>
                <button class="btn btn-primary"
                        data-bs-toggle="modal"
                        data-bs-target="#addAddressModal">
                    Add Address
                </button>
            </div>

            <div class="row">

                <c:forEach items="${addresses}" var="a">

                    <div class="col-lg-6">

                        <div class="address-card">

                            <div class="d-flex justify-content-between">

                                <div>

                                    <div class="user-name">

                                        <i class="bi bi-person-circle"></i>

                                        ${a.recipientName}

                                    </div>

                                    <div class="info">

                                        <i class="bi bi-telephone-fill"></i>

                                        ${a.recipientPhone}

                                    </div>

                                    <div class="info">

                                        <i class="bi bi-geo-alt-fill"></i>

                                        ${a.addressDetail}

                                    </div>

                                    <div class="info">

                                        Ward ID :
                                        <b>${a.wardId}</b>

                                    </div>

                                </div>

                                <div>

                                    <c:if test="${a['default']}">

                                        <span class="badge-default">

                                            <i class="bi bi-check-circle-fill"></i>

                                            Default

                                        </span>

                                    </c:if>

                                </div>

                            </div>

                            <hr>

                            <div class="d-flex gap-2 justify-content-end">

                                <button
                                    class="btn btn-warning action-btn"
                                    data-bs-toggle="modal"
                                    data-bs-target="#editModal${a.id}">

                                    <i class="bi bi-pencil-square"></i>

                                    Edit

                                </button>

                                <a
                                    href="${pageContext.request.contextPath}/customer/address?action=delete&id=${a.id}&from=${from}"
                                    class="btn btn-danger action-btn"
                                    onclick="return confirm('Delete address?')">

                                    <i class="bi bi-trash"></i>

                                    Delete

                                </a>

                                <c:if test="${!a['default']}">

                                    <a
                                        href="${pageContext.request.contextPath}/customer/address?action=setDefault&id=${a.id}&from=${from}"
                                        class="btn btn-success action-btn">

                                        <i class="bi bi-star-fill"></i>

                                        Set Default

                                    </a>

                                </c:if>

                            </div>

                        </div>

                    </div>

                </c:forEach>

            </div>

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
                            <input type="hidden"
                                   name="from"
                                   value="${from}">

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

                        <input type="hidden"
                               name="from"
                               value="${from}">

                        <div class="modal-header border-0">

                            <h4 class="fw-bold">

                                <i class="bi bi-house-add-fill"></i>

                                Add Address

                            </h4>

                            <button
                                type="button"
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

                        <div class="modal-footer border-0">

                            <button
                                class="btn btn-success px-4">

                                Save Address

                            </button>

                        </div>

                    </form>

                </div>

            </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    </body>
</html>