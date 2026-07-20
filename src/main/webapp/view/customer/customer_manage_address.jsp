<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Manage Addresses</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
              rel="stylesheet">

        <style>
            body {
                background: #f5f6f8;
            }

            .address-page {
                min-height: 650px;
            }

            .page-title {
                font-size: 28px;
                font-weight: 700;
                color: #212529;
            }

            .address-card {
                background: #ffffff;
                border: 1px solid #e4e7eb;
                border-radius: 12px;
                padding: 20px;
                height: 100%;
                transition: 0.2s ease;
            }

            .address-card:hover {
                border-color: #b8bdc5;
                box-shadow: 0 5px 18px rgba(0, 0, 0, 0.06);
            }

            .address-card.default-address {
                border: 2px solid #198754;
            }

            .recipient-name {
                font-size: 18px;
                font-weight: 700;
                color: #212529;
            }

            .recipient-phone {
                color: #6c757d;
            }

            .address-content {
                color: #495057;
                line-height: 1.6;
            }

            .default-badge {
                font-size: 12px;
            }

            .empty-address {
                background: #ffffff;
                border: 1px dashed #ced4da;
                border-radius: 12px;
                padding: 60px 20px;
                text-align: center;
            }

            .empty-address i {
                font-size: 48px;
                color: #adb5bd;
                margin-bottom: 16px;
            }

            .modal-content {
                border: none;
                border-radius: 14px;
            }

            .modal-header {
                border-bottom: 1px solid #edf0f2;
            }

            .modal-footer {
                border-top: 1px solid #edf0f2;
            }

            .form-label {
                font-weight: 600;
            }

            .required-mark {
                color: #dc3545;
            }

            .address-api-error {
                margin-top: 8px;
                font-size: 14px;
                color: #dc3545;
            }
        </style>
    </head>

    <body>

        <jsp:include page="/view/customer/common/header.jsp"/>

        <c:set var="contextPath" value="${pageContext.request.contextPath}"/>

        <div class="container address-page py-5">

            <div class="d-flex flex-column flex-md-row
                 justify-content-between align-items-md-center gap-3 mb-4">

                <div>
                    <h1 class="page-title mb-1">My Addresses</h1>

                    <p class="text-muted mb-0">
                        Manage your delivery addresses.
                    </p>
                </div>

                <button type="button"
                        class="btn btn-dark px-4"
                        data-bs-toggle="modal"
                        data-bs-target="#addAddressModal">

                    <i class="fa-solid fa-plus me-2"></i>
                    Add New Address
                </button>
            </div>

            <c:if test="${not empty addressSuccess}">
                <div class="alert alert-success alert-dismissible fade show"
                     role="alert">

                    <i class="fa-solid fa-circle-check me-2"></i>
                    <c:out value="${addressSuccess}"/>

                    <button type="button"
                            class="btn-close"
                            data-bs-dismiss="alert">
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty addressError}">
                <div class="alert alert-danger alert-dismissible fade show"
                     role="alert">

                    <i class="fa-solid fa-circle-exclamation me-2"></i>
                    <c:out value="${addressError}"/>

                    <button type="button"
                            class="btn-close"
                            data-bs-dismiss="alert">
                    </button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty addresses}">
                    <div class="empty-address">
                        <i class="fa-solid fa-location-dot"></i>

                        <h4>No address found</h4>

                        <p class="text-muted mb-4">
                            Add a delivery address to make checkout faster.
                        </p>

                        <button type="button"
                                class="btn btn-dark"
                                data-bs-toggle="modal"
                                data-bs-target="#addAddressModal">

                            Add Address
                        </button>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="row g-4">

                        <c:forEach items="${addresses}" var="address">

                            <div class="col-lg-6">

                                <div class="address-card
                                     ${address.isDefault()
                                       ? 'default-address'
                                       : ''}">

                                    <div class="d-flex justify-content-between
                                         align-items-start gap-3">

                                        <div>
                                            <div class="recipient-name">
                                                <c:out value="${address.recipientName}"/>
                                            </div>

                                            <div class="recipient-phone mt-1">
                                                <i class="fa-solid fa-phone me-1"></i>
                                                <c:out value="${address.recipientPhone}"/>
                                            </div>
                                        </div>

                                        <c:if test="${address.isDefault()}">
                                            <span class="badge bg-success default-badge">
                                                Default
                                            </span>
                                        </c:if>
                                    </div>

                                    <hr>

                                    <div class="address-content">
                                        <i class="fa-solid fa-location-dot me-2"></i>

                                        <c:out value="${address.addressDetail}"/>

                                        <c:if test="${not empty address.wardName}">
                                            ,
                                            <c:out value="${address.wardName}"/>
                                        </c:if>

                                        <%-- District chỉ hiển thị cho địa chỉ cũ --%>
                                        <c:if test="${not empty address.districtName}">
                                            ,
                                            <c:out value="${address.districtName}"/>
                                        </c:if>

                                        <c:if test="${not empty address.provinceName}">
                                            ,
                                            <c:out value="${address.provinceName}"/>
                                        </c:if>
                                    </div>

                                    <div class="d-flex flex-wrap gap-2 mt-4">

                                        <button type="button"
                                                class="btn btn-outline-dark btn-sm"
                                                data-bs-toggle="modal"
                                                data-bs-target="#editAddressModal${address.id}">

                                            <i class="fa-solid fa-pen me-1"></i>
                                            Edit
                                        </button>

                                        <c:if test="${not address.isDefault()}">

                                            <c:url var="setDefaultUrl"
                                                   value="/customer/address">

                                                <c:param name="action"
                                                         value="setDefault"/>

                                                <c:param name="id"
                                                         value="${address.id}"/>

                                                <c:if test="${not empty from}">
                                                    <c:param name="from"
                                                             value="${from}"/>
                                                </c:if>
                                            </c:url>

                                            <a href="${setDefaultUrl}"
                                               class="btn btn-outline-success btn-sm">

                                                <i class="fa-solid fa-check me-1"></i>
                                                Set Default
                                            </a>
                                        </c:if>

                                        <c:url var="deleteAddressUrl"
                                               value="/customer/address">

                                            <c:param name="action"
                                                     value="delete"/>

                                            <c:param name="id"
                                                     value="${address.id}"/>

                                            <c:if test="${not empty from}">
                                                <c:param name="from"
                                                         value="${from}"/>
                                            </c:if>
                                        </c:url>

                                        <a href="${deleteAddressUrl}"
                                           class="btn btn-outline-danger btn-sm"
                                           onclick="return confirm(
                                                   'Are you sure you want to remove this address?'
                                                   );">

                                            <i class="fa-solid fa-trash me-1"></i>
                                            Delete
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <%-- Modal cập nhật địa chỉ --%>
                            <div class="modal fade address-modal"
                                 id="editAddressModal${address.id}"
                                 tabindex="-1"
                                 aria-hidden="true">

                                <div class="modal-dialog modal-lg modal-dialog-centered">

                                    <div class="modal-content">

                                        <form method="post"
                                              action="${contextPath}/customer/address"
                                              class="needs-validation"
                                              novalidate>

                                            <input type="hidden"
                                                   name="action"
                                                   value="update">

                                            <input type="hidden"
                                                   name="id"
                                                   value="${address.id}">

                                            <input type="hidden"
                                                   name="from"
                                                   value="${fn:escapeXml(from)}">

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

                                                <div class="row g-3">

                                                    <div class="col-md-6">

                                                        <label class="form-label">
                                                            Recipient Name
                                                            <span class="required-mark">*</span>
                                                        </label>

                                                        <input type="text"
                                                               name="recipientName"
                                                               class="form-control"
                                                               value="${fn:escapeXml(address.recipientName)}"
                                                               minlength="2"
                                                               maxlength="100"
                                                               required>

                                                        <div class="invalid-feedback">
                                                            Recipient name must contain
                                                            2 to 100 characters.
                                                        </div>
                                                    </div>

                                                    <div class="col-md-6">

                                                        <label class="form-label">
                                                            Phone Number
                                                            <span class="required-mark">*</span>
                                                        </label>

                                                        <input type="tel"
                                                               name="recipientPhone"
                                                               class="form-control"
                                                               value="${fn:escapeXml(address.recipientPhone)}"
                                                               maxlength="15"
                                                               pattern="(0|\+84|84)(3|5|7|8|9)[0-9]{8}"
                                                               required>

                                                        <div class="invalid-feedback">
                                                            Enter a valid Vietnamese
                                                            phone number.
                                                        </div>
                                                    </div>

                                                    <div class="col-12 address-location">

                                                        <div class="row g-3">

                                                            <div class="col-md-6">

                                                                <label class="form-label">
                                                                    Province
                                                                    <span class="required-mark">*</span>
                                                                </label>

                                                                <select name="provinceCode"
                                                                        class="form-select province-select"
                                                                        data-selected="${fn:escapeXml(address.provinceCode)}"
                                                                        required>

                                                                    <option value="">
                                                                        Loading provinces...
                                                                    </option>
                                                                </select>

                                                                <div class="invalid-feedback">
                                                                    Select a province.
                                                                </div>
                                                            </div>

                                                            <div class="col-md-6">

                                                                <label class="form-label">
                                                                    Ward / Commune
                                                                    <span class="required-mark">*</span>
                                                                </label>

                                                                <select name="wardCode"
                                                                        class="form-select ward-select"
                                                                        data-selected="${fn:escapeXml(address.wardCode)}"
                                                                        required
                                                                        disabled>

                                                                    <option value="">
                                                                        Select Province first
                                                                    </option>
                                                                </select>

                                                                <div class="invalid-feedback">
                                                                    Select a ward or commune.
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="address-api-error d-none"></div>
                                                    </div>

                                                    <c:if test="${not empty address.districtName}">
                                                        <div class="col-12">

                                                            <div class="alert alert-warning mb-0">

                                                                <i class="fa-solid
                                                                   fa-triangle-exclamation
                                                                   me-2">
                                                                </i>

                                                                This address was saved
                                                                using the previous
                                                                administrative system.

                                                                Please select the current
                                                                Province and Ward before
                                                                saving.
                                                            </div>
                                                        </div>
                                                    </c:if>

                                                    <div class="col-12">

                                                        <label class="form-label">
                                                            Detailed Address
                                                            <span class="required-mark">*</span>
                                                        </label>

                                                        <textarea name="addressDetail"
                                                                  class="form-control"
                                                                  rows="3"
                                                                  minlength="5"
                                                                  maxlength="255"
                                                                  placeholder="House number, street, building..."
                                                                  required><c:out value="${address.addressDetail}"/></textarea>

                                                        <div class="invalid-feedback">
                                                            Address detail must contain
                                                            5 to 255 characters.
                                                        </div>
                                                    </div>

                                                    <div class="col-12">

                                                        <div class="form-check">

                                                            <input type="checkbox"
                                                                   name="isDefault"
                                                                   value="true"
                                                                   class="form-check-input"
                                                                   id="editDefault${address.id}"
                                                                   <c:if test="${address.isDefault()}">
                                                                       checked
                                                                   </c:if>>

                                                            <label class="form-check-label"
                                                                   for="editDefault${address.id}">

                                                                Set as default address
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="modal-footer">

                                                <button type="button"
                                                        class="btn btn-light"
                                                        data-bs-dismiss="modal">

                                                    Cancel
                                                </button>

                                                <button type="submit"
                                                        class="btn btn-dark">

                                                    Save Changes
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

            
        </div>

        <%-- Modal thêm địa chỉ --%>
        <div class="modal fade address-modal"
             id="addAddressModal"
             tabindex="-1"
             aria-hidden="true">

            <div class="modal-dialog modal-lg modal-dialog-centered">

                <div class="modal-content">

                    <form method="post"
                          action="${contextPath}/customer/address"
                          class="needs-validation"
                          id="addAddressForm"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="insert">

                        <input type="hidden"
                               name="from"
                               value="${fn:escapeXml(from)}">

                        <div class="modal-header">

                            <h5 class="modal-title">
                                Add New Address
                            </h5>

                            <button type="button"
                                    class="btn-close"
                                    data-bs-dismiss="modal">
                            </button>
                        </div>

                        <div class="modal-body">

                            <div class="row g-3">

                                <div class="col-md-6">

                                    <label class="form-label">
                                        Recipient Name
                                        <span class="required-mark">*</span>
                                    </label>

                                    <input type="text"
                                           name="recipientName"
                                           class="form-control"
                                           minlength="2"
                                           maxlength="100"
                                           required>

                                    <div class="invalid-feedback">
                                        Recipient name must contain
                                        2 to 100 characters.
                                    </div>
                                </div>

                                <div class="col-md-6">

                                    <label class="form-label">
                                        Phone Number
                                        <span class="required-mark">*</span>
                                    </label>

                                    <input type="tel"
                                           name="recipientPhone"
                                           class="form-control"
                                           maxlength="15"
                                           pattern="(0|\+84|84)(3|5|7|8|9)[0-9]{8}"
                                           placeholder="Example: 0912345678"
                                           required>

                                    <div class="invalid-feedback">
                                        Enter a valid Vietnamese phone number.
                                    </div>
                                </div>

                                <div class="col-12 address-location">

                                    <div class="row g-3">

                                        <div class="col-md-6">

                                            <label class="form-label">
                                                Province
                                                <span class="required-mark">*</span>
                                            </label>

                                            <select name="provinceCode"
                                                    class="form-select province-select"
                                                    required>

                                                <option value="">
                                                    Loading provinces...
                                                </option>
                                            </select>

                                            <div class="invalid-feedback">
                                                Select a province.
                                            </div>
                                        </div>

                                        <div class="col-md-6">

                                            <label class="form-label">
                                                Ward / Commune
                                                <span class="required-mark">*</span>
                                            </label>

                                            <select name="wardCode"
                                                    class="form-select ward-select"
                                                    required
                                                    disabled>

                                                <option value="">
                                                    Select Province first
                                                </option>
                                            </select>

                                            <div class="invalid-feedback">
                                                Select a ward or commune.
                                            </div>
                                        </div>
                                    </div>

                                    <div class="address-api-error d-none"></div>
                                </div>

                                <div class="col-12">

                                    <label class="form-label">
                                        Detailed Address
                                        <span class="required-mark">*</span>
                                    </label>

                                    <textarea name="addressDetail"
                                              class="form-control"
                                              rows="3"
                                              minlength="5"
                                              maxlength="255"
                                              placeholder="House number, street, building..."
                                              required></textarea>

                                    <div class="invalid-feedback">
                                        Address detail must contain
                                        5 to 255 characters.
                                    </div>
                                </div>

                                <div class="col-12">

                                    <div class="form-check">

                                        <input type="checkbox"
                                               name="isDefault"
                                               value="true"
                                               class="form-check-input"
                                               id="addDefaultAddress">

                                        <label class="form-check-label"
                                               for="addDefaultAddress">

                                            Set as default address
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">

                            <button type="button"
                                    class="btn btn-light"
                                    data-bs-dismiss="modal">

                                Cancel
                            </button>

                            <button type="submit"
                                    class="btn btn-dark">

                                Add Address
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <jsp:include page="/view/customer/common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js">
        </script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {

                const addressApiUrl =
                        "${pageContext.request.contextPath}/customer/address";

                let provinceRequestPromise = null;

                function requestProvinces() {
                    if (!provinceRequestPromise) {
                        provinceRequestPromise = fetchJson(
                                addressApiUrl + "?action=provinces"
                                ).catch(function (error) {
                            provinceRequestPromise = null;
                            throw error;
                        });
                    }

                    return provinceRequestPromise;
                }

                async function initializeAddressLocation(container) {
                    if (!container) {
                        return;
                    }

                    const provinceSelect =
                            container.querySelector(".province-select");

                    const wardSelect =
                            container.querySelector(".ward-select");

                    if (!provinceSelect || !wardSelect) {
                        return;
                    }

                    if (container.dataset.initialized === "true") {
                        return;
                    }

                    clearApiError(container);

                    provinceSelect.disabled = true;
                    wardSelect.disabled = true;

                    provinceSelect.innerHTML =
                            '<option value="">Loading provinces...</option>';

                    wardSelect.innerHTML =
                            '<option value="">Select Province first</option>';

                    const selectedProvince =
                            provinceSelect.dataset.selected || "";

                    const selectedWard =
                            wardSelect.dataset.selected || "";

                    try {
                        const provinces = await requestProvinces();

                        renderOptions(
                                provinceSelect,
                                provinces,
                                "Select Province",
                                selectedProvince
                                );

                        provinceSelect.disabled = false;

                        if (selectedProvince
                                && optionExists(
                                        provinceSelect,
                                        selectedProvince
                                        )) {

                            provinceSelect.value =
                                    String(selectedProvince);

                            await loadWards(
                                    container,
                                    provinceSelect,
                                    wardSelect,
                                    selectedWard
                                    );
                        }

                        provinceSelect.addEventListener(
                                "change",
                                async function () {

                                    clearApiError(container);

                                    await loadWards(
                                            container,
                                            provinceSelect,
                                            wardSelect,
                                            ""
                                            );
                                }
                        );

                        container.dataset.initialized = "true";

                    } catch (error) {
                        provinceSelect.innerHTML =
                                '<option value="">Cannot load provinces</option>';

                        provinceSelect.disabled = true;
                        wardSelect.disabled = true;

                        showApiError(container, error.message);
                    }
                }

                async function loadWards(
                        container,
                        provinceSelect,
                        wardSelect,
                        selectedWard) {

                    const provinceCode =
                            provinceSelect.value;

                    wardSelect.disabled = true;

                    if (!provinceCode) {
                        wardSelect.innerHTML =
                                '<option value="">Select Province first</option>';

                        return;
                    }

                    wardSelect.innerHTML =
                            '<option value="">Loading wards...</option>';

                    try {
                        const wards = await fetchJson(
                                addressApiUrl
                                + "?action=wards&provinceCode="
                                + encodeURIComponent(provinceCode)
                                );

                        renderOptions(
                                wardSelect,
                                wards,
                                "Select Ward / Commune",
                                selectedWard
                                );

                        wardSelect.disabled = false;

                        if (selectedWard
                                && optionExists(
                                        wardSelect,
                                        selectedWard
                                        )) {

                            wardSelect.value =
                                    String(selectedWard);
                        } else {
                            wardSelect.value = "";
                        }

                    } catch (error) {
                        wardSelect.innerHTML =
                                '<option value="">Cannot load wards</option>';

                        wardSelect.disabled = true;

                        showApiError(container, error.message);
                    }
                }

                function renderOptions(
                        select,
                        items,
                        placeholder,
                        selectedValue) {

                    select.innerHTML = "";

                    select.appendChild(
                            new Option(placeholder, "")
                            );

                    if (!Array.isArray(items)) {
                        return;
                    }

                    items.forEach(function (item) {
                        const option = new Option(
                                item.name,
                                item.code
                                );

                        if (String(item.code)
                                === String(selectedValue)) {
                            option.selected = true;
                        }

                        select.appendChild(option);
                    });
                }

                function optionExists(select, value) {
                    return Array.from(select.options)
                            .some(function (option) {
                                return String(option.value)
                                        === String(value);
                            });
                }

                async function fetchJson(url) {
                    const response = await fetch(url, {
                        method: "GET",
                        headers: {
                            "Accept": "application/json"
                        }
                    });

                    let responseBody = null;

                    try {
                        responseBody = await response.json();
                    } catch (error) {
                        responseBody = null;
                    }

                    if (!response.ok) {
                        throw new Error(
                                responseBody && responseBody.message
                                ? responseBody.message
                                : "Address service is unavailable."
                                );
                    }

                    return responseBody;
                }

                function showApiError(container, message) {
                    const errorElement =
                            container.querySelector(
                                    ".address-api-error"
                                    );

                    if (!errorElement) {
                        return;
                    }

                    errorElement.textContent = message;
                    errorElement.classList.remove("d-none");
                }

                function clearApiError(container) {
                    const errorElement =
                            container.querySelector(
                                    ".address-api-error"
                                    );

                    if (!errorElement) {
                        return;
                    }

                    errorElement.textContent = "";
                    errorElement.classList.add("d-none");
                }

                document.querySelectorAll(".address-modal")
                        .forEach(function (modalElement) {

                            modalElement.addEventListener(
                                    "show.bs.modal",
                                    function () {

                                        const locationContainer =
                                                modalElement.querySelector(
                                                        ".address-location"
                                                        );

                                        initializeAddressLocation(
                                                locationContainer
                                                );
                                    }
                            );
                        });

                const addAddressModal =
                        document.getElementById("addAddressModal");

                if (addAddressModal) {
                    addAddressModal.addEventListener(
                            "hidden.bs.modal",
                            function () {

                                const form =
                                        document.getElementById(
                                                "addAddressForm"
                                                );

                                if (!form) {
                                    return;
                                }

                                form.reset();
                                form.classList.remove(
                                        "was-validated"
                                        );

                                const provinceSelect =
                                        form.querySelector(
                                                ".province-select"
                                                );

                                const wardSelect =
                                        form.querySelector(
                                                ".ward-select"
                                                );

                                if (provinceSelect) {
                                    provinceSelect.value = "";
                                }

                                if (wardSelect) {
                                    wardSelect.innerHTML =
                                            '<option value="">'
                                            + 'Select Province first'
                                            + '</option>';

                                    wardSelect.disabled = true;
                                }
                            }
                    );
                }

                document.querySelectorAll(
                        ".needs-validation"
                        ).forEach(function (form) {

                    form.addEventListener(
                            "submit",
                            function (event) {

                                if (!form.checkValidity()) {
                                    event.preventDefault();
                                    event.stopPropagation();
                                }

                                form.classList.add(
                                        "was-validated"
                                        );
                            }
                    );
                });
            });
        </script>

    </body>
</html>