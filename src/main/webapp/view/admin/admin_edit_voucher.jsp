<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Voucher - Admin Panel</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <style>
            .voucher-form-card {
                border: 0;
                border-radius: 16px;
                box-shadow: 0 12px 32px rgba(15, 23, 42, .07);
            }
            .form-section {
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 20px;
                background: #fff;
            }
            .form-section-title {
                font-size: 15px;
                font-weight: 800;
                color: #111827;
                margin-bottom: 16px;
            }
            .scope-help {
                border: 1px solid #bfdbfe;
                background: #eff6ff;
                color: #1e3a8a;
                border-radius: 10px;
                padding: 12px 14px;
                font-size: 13px;
                line-height: 1.55;
            }
            .scope-preview {
                border-left: 4px solid #2563eb;
                background: #f8fafc;
                border-radius: 8px;
                padding: 11px 13px;
                margin-top: 10px;
                font-size: 13px;
            }
            .scope-mode-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 12px;
                margin-bottom: 18px;
            }
            .scope-mode-card {
                position: relative;
                display: flex;
                gap: 12px;
                align-items: flex-start;
                padding: 14px 16px;
                border: 1px solid #dbe3ee;
                border-radius: 12px;
                cursor: pointer;
                transition: .18s ease;
                background: #fff;
            }
            .scope-mode-card:hover {
                border-color: #93c5fd;
                background: #f8fbff;
            }
            .scope-mode-card:has(input:checked) {
                border-color: #2563eb;
                background: #eff6ff;
                box-shadow: 0 0 0 3px rgba(37, 99, 235, .08);
            }
            .scope-mode-card input {
                margin-top: 3px;
            }
            .scope-mode-title {
                display: block;
                font-weight: 800;
                color: #172033;
            }
            .scope-mode-note {
                display: block;
                margin-top: 2px;
                color: #64748b;
                font-size: 12px;
            }
            .category-scope-panel {
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                background: #f8fafc;
            }
            .category-multi-select {
                position: relative;
            }
            .category-select-trigger {
                width: 100%;
                min-height: 42px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                padding: 9px 12px;
                border: 1px solid #ced7e3;
                border-radius: 9px;
                background: #fff;
                color: #172033;
                text-align: left;
            }
            .category-select-trigger:focus {
                border-color: #86b7fe;
                box-shadow: 0 0 0 .25rem rgba(13, 110, 253, .15);
                outline: 0;
            }
            .category-multi-select.is-open .category-select-trigger {
                border-color: #2563eb;
            }
            .category-select-menu {
                position: absolute;
                top: calc(100% + 6px);
                left: 0;
                right: 0;
                z-index: 1055;
                display: none;
                border: 1px solid #dbe3ee;
                border-radius: 12px;
                background: #fff;
                box-shadow: 0 18px 45px rgba(15, 23, 42, .16);
                overflow: hidden;
            }
            .category-multi-select.is-open .category-select-menu {
                display: block;
            }
            .category-select-toolbar {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 10px 12px;
                border-bottom: 1px solid #eef2f7;
                background: #f8fafc;
            }
            .category-select-options {
                max-height: 245px;
                overflow-y: auto;
                padding: 8px;
            }
            .category-option {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 11px;
                border-radius: 8px;
                cursor: pointer;
                margin: 0;
            }
            .category-option:hover {
                background: #f1f5f9;
            }
            .category-option:has(input:checked) {
                background: #eff6ff;
                color: #1d4ed8;
                font-weight: 700;
            }
            .category-option input {
                width: 16px;
                height: 16px;
                flex: 0 0 auto;
            }
            .selected-category-chips {
                display: flex;
                flex-wrap: wrap;
                gap: 7px;
                margin-top: 11px;
            }
            .category-chip {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 9px;
                border-radius: 999px;
                background: #e8f0ff;
                color: #1d4ed8;
                font-size: 12px;
                font-weight: 700;
            }
            .category-chip button {
                border: 0;
                padding: 0;
                background: transparent;
                color: inherit;
                line-height: 1;
            }
            @media (max-width: 767px) {
                .scope-mode-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="discounts" />
        </jsp:include>

        <jsp:useBean id="now" class="java.util.Date" />
        <c:set var="isUpcoming" value="${now.time < voucher.startDate.time}" />
        <c:set var="isExpired" value="${now.time > voucher.endDate.time or voucher.usedCount >= voucher.usageLimit}" />
        <c:set var="isActive" value="${not isUpcoming and not isExpired}" />
        <fmt:formatDate var="formattedStart" value="${voucher.startDate}" pattern="yyyy-MM-dd'T'HH:mm" />
        <fmt:formatDate var="formattedEnd" value="${voucher.endDate}" pattern="yyyy-MM-dd'T'HH:mm" />

        <div class="admin-page voucher-form-page">
            <div class="container-fluid">
                <div class="page-header">
                    <jsp:include page="/view/admin/common/page_heading.jsp">
                        <jsp:param name="icon" value="fa-solid fa-pen-to-square"/>
                        <jsp:param name="title" value="Edit Voucher"/>
                    </jsp:include>
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error"><c:out value="${errorMessage}"/></div>
                </c:if>

                <div class="card voucher-form-card">
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/admin/voucher"
                              method="post" id="editVoucherForm">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${voucher.id}">
                            <input type="hidden" name="code" value="${fn:escapeXml(voucher.code)}">

                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
                                <div>
                                    <span class="badge text-bg-light border text-dark fs-6 px-3 py-2">
                                        <i class="fa-solid fa-tag me-2"></i><c:out value="${voucher.code}"/>
                                    </span>
                                </div>
                                <c:choose>
                                    <c:when test="${isExpired}"><span class="badge text-bg-secondary px-3 py-2">Expired / Exhausted</span></c:when>
                                    <c:when test="${isUpcoming}"><span class="badge text-bg-info px-3 py-2">Upcoming</span></c:when>
                                    <c:otherwise><span class="badge text-bg-success px-3 py-2">Active</span></c:otherwise>
                                </c:choose>
                            </div>

                            <div class="form-section mb-4">
                                <div class="form-section-title">
                                    <i class="fa-solid fa-circle-info me-2 text-primary"></i>Campaign information
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-8">
                                        <label for="title" class="form-label fw-bold">Campaign Title <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="title" name="title"
                                               required maxlength="200" value="${fn:escapeXml(voucher.title)}"
                                               ${isExpired ? 'readonly' : ''}>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Usage Progress</label>
                                        <div class="form-control bg-light">${voucher.usedCount} / ${voucher.usageLimit} used</div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-section mb-4">
                                <div class="form-section-title">
                                    <i class="fa-solid fa-percent me-2 text-primary"></i>Discount configuration
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label for="discountType" class="form-label fw-bold">Discount Type</label>
                                        <select class="form-select" id="discountType" name="discountType" ${isActive || isExpired ? 'disabled' : ''}>
                                            <option value="PERCENTAGE" ${voucher.discountType == 'PERCENTAGE' ? 'selected' : ''}>Percentage (%)</option>
                                            <option value="FIXED_AMOUNT" ${voucher.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed Amount (₫)</option>
                                        </select>
                                        <c:if test="${isActive || isExpired}">
                                            <input type="hidden" name="discountType" value="${voucher.discountType}">
                                        </c:if>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="discountValue" class="form-label fw-bold">Discount Value</label>
                                        <input type="number" class="form-control" id="discountValue" name="discountValue"
                                               required min="1" step="0.01" value="${voucher.discountValue}"
                                               ${isActive || isExpired ? 'readonly' : ''}>
                                    </div>
                                    <div class="col-md-4" id="maxDiscountGroup">
                                        <label for="maxDiscountAmount" class="form-label fw-bold">Maximum Discount (₫)</label>
                                        <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount"
                                               min="1" step="1" value="${voucher.maxDiscountAmount}"
                                               ${isActive || isExpired ? 'readonly' : ''}>
                                    </div>
                                </div>

                                <div class="row g-3 mt-1">
                                    <div class="col-md-4">
                                        <label for="minOrderValue" class="form-label fw-bold">Minimum Eligible Spend (₫)</label>
                                        <input type="number" class="form-control" id="minOrderValue" name="minOrderValue"
                                               min="0" step="1" value="${voucher.minOrderValue}"
                                               ${isActive || isExpired ? 'readonly' : ''}>
                                        <div class="form-text">Only products inside the selected scope count toward this amount.</div>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="usageLimit" class="form-label fw-bold">Total Supply Limit</label>
                                        <input type="number" class="form-control" id="usageLimit" name="usageLimit"
                                               required min="${voucher.usedCount > 0 ? voucher.usedCount : 1}"
                                               value="${voucher.usageLimit}" ${isExpired ? 'readonly' : ''}>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="limitPerUser" class="form-label fw-bold">Limit Per Customer</label>
                                        <input type="number" class="form-control" id="limitPerUser" name="limitPerUser"
                                               required min="1" value="${voucher.limitPerUser}"
                                               ${isActive || isExpired ? 'readonly' : ''}>
                                    </div>
                                </div>
                            </div>

                            <div class="form-section mb-4">
                                <div class="form-section-title">
                                    <i class="fa-solid fa-layer-group me-2 text-primary"></i>Applicable scope
                                </div>

                                <c:choose>
                                    <c:when test="${isActive || isExpired}">
                                        <input type="hidden" name="scopeType" value="${empty voucher.categoryId ? 'GLOBAL' : 'CATEGORY'}">
                                        <c:if test="${not empty voucher.categoryId}">
                                            <input type="hidden" name="parentCategoryId" value="${voucher.categoryId}">
                                            <c:forEach var="selectedId" items="${voucher.selectedCategoryIds}">
                                                <input type="hidden" name="categoryIds" value="${selectedId}">
                                            </c:forEach>
                                        </c:if>

                                        <div class="category-scope-panel">
                                            <c:choose>
                                                <c:when test="${empty voucher.categoryId}">
                                                    <div class="d-flex align-items-center gap-3">
                                                        <span class="rounded-circle bg-primary-subtle text-primary d-inline-flex align-items-center justify-content-center" style="width:42px;height:42px;">
                                                            <i class="fa-solid fa-store"></i>
                                                        </span>
                                                        <div>
                                                            <div class="fw-bold">Entire Store</div>
                                                            <div class="small text-secondary">This voucher applies to all products.</div>
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="row g-3">
                                                        <div class="col-lg-5">
                                                            <label class="form-label fw-bold">Parent Category</label>
                                                            <input type="text" class="form-control bg-white" value="${fn:escapeXml(voucher.categoryName)}" readonly>
                                                        </div>
                                                        <div class="col-lg-7">
                                                            <label class="form-label fw-bold">Applicable Categories</label>
                                                            <div class="selected-category-chips mt-0">
                                                                <c:forEach var="selectedName" items="${voucher.selectedCategoryNames}">
                                                                    <span class="category-chip"><c:out value="${selectedName}"/></span>
                                                                </c:forEach>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="form-text mt-2">The scope is locked after the campaign starts.</div>
                                    </c:when>

                                    <c:otherwise>
                                        <div class="scope-mode-grid">
                                            <label class="scope-mode-card">
                                                <input type="radio" name="scopeType" value="GLOBAL"
                                                       ${empty voucher.categoryId ? 'checked' : ''}>
                                                <span>
                                                    <span class="scope-mode-title">Entire Store</span>
                                                    <span class="scope-mode-note">All products can use this voucher.</span>
                                                </span>
                                            </label>
                                            <label class="scope-mode-card">
                                                <input type="radio" name="scopeType" value="CATEGORY"
                                                       ${not empty voucher.categoryId ? 'checked' : ''}>
                                                <span>
                                                    <span class="scope-mode-title">Selected Categories</span>
                                                    <span class="scope-mode-note">Choose one parent group, then select one or more child categories.</span>
                                                </span>
                                            </label>
                                        </div>

                                        <div id="categoryScopePanel" class="category-scope-panel ${empty voucher.categoryId ? 'd-none' : ''}">
                                            <div class="row g-3">
                                                <div class="col-lg-5">
                                                    <label for="parentCategoryId" class="form-label fw-bold">Parent Category <span class="text-danger">*</span></label>
                                                    <select class="form-select" id="parentCategoryId" name="parentCategoryId">
                                                        <option value="">Select parent category</option>
                                                        <c:forEach var="root" items="${categoryList}">
                                                            <option value="${root.id}" ${voucher.categoryId == root.id ? 'selected' : ''}>
                                                                <c:out value="${root.categoryName}"/>
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                    <div class="form-text">Changing the parent clears the previously selected child categories.</div>
                                                </div>

                                                <div class="col-lg-7">
                                                    <label class="form-label fw-bold">Applicable Child Categories <span class="text-danger">*</span></label>
                                                    <div class="category-multi-select" id="categoryMultiSelect">
                                                        <button type="button" class="category-select-trigger" id="categorySelectTrigger">
                                                            <span id="categorySelectText">Select child categories</span>
                                                            <i class="fa-solid fa-chevron-down small"></i>
                                                        </button>
                                                        <div class="category-select-menu" id="categorySelectMenu">
                                                            <div class="category-select-toolbar">
                                                                <span class="small fw-bold text-secondary">Click an item again to remove it</span>
                                                                <div class="d-flex gap-2">
                                                                    <button type="button" class="btn btn-sm btn-link text-decoration-none p-0" id="selectAllCategories">Select all</button>
                                                                    <button type="button" class="btn btn-sm btn-link text-danger text-decoration-none p-0" id="clearCategories">Clear</button>
                                                                </div>
                                                            </div>
                                                            <div class="category-select-options">
                                                                <c:forEach var="root" items="${categoryList}">
                                                                    <div class="category-option-group d-none" data-parent-id="${root.id}">
                                                                        <c:choose>
                                                                            <c:when test="${not empty root.children}">
                                                                                <c:forEach var="child" items="${root.children}">
                                                                                    <label class="category-option">
                                                                                        <input type="checkbox" name="categoryIds" value="${child.id}"
                                                                                               data-category-name="${fn:escapeXml(child.categoryName)}" disabled>
                                                                                        <span><c:out value="${child.categoryName}"/></span>
                                                                                    </label>
                                                                                </c:forEach>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <label class="category-option">
                                                                                    <input type="checkbox" name="categoryIds" value="${root.id}"
                                                                                           data-category-name="${fn:escapeXml(root.categoryName)}" disabled>
                                                                                    <span><c:out value="${root.categoryName}"/></span>
                                                                                </label>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </c:forEach>
                                                                <div class="small text-secondary px-2 py-3" id="emptyParentMessage">Select a parent category first.</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="selected-category-chips" id="selectedCategoryChips"></div>
                                                </div>
                                            </div>

                                            <div class="scope-preview mt-3">
                                                <strong>Selected scope:</strong>
                                                <span id="scopePreviewText">No category selected</span>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="scope-help mt-3">
                                    <div class="fw-bold mb-1"><i class="fa-solid fa-circle-question me-1"></i>Scope rule</div>
                                    The parent category is used only to group the options. The voucher applies only to the child categories selected below. Selecting all children includes all current children only.
                                </div>
                            </div>

                            <div class="form-section mb-4">
                                <div class="form-section-title">
                                    <i class="fa-regular fa-calendar me-2 text-primary"></i>Validity period
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="startDate" class="form-label fw-bold">Start Date & Time</label>
                                        <input type="datetime-local" class="form-control" id="startDate" name="startDate"
                                               required value="${formattedStart}" ${isActive || isExpired ? 'readonly' : ''}>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="endDate" class="form-label fw-bold">End Date & Time</label>
                                        <input type="datetime-local" class="form-control" id="endDate" name="endDate"
                                               required value="${formattedEnd}" ${isExpired ? 'readonly' : ''}>
                                        <div class="form-text">Changing the end date requires at least a 48-hour buffer from now.</div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-2 justify-content-end">
                                <a href="${pageContext.request.contextPath}/admin/voucher?action=list"
                                   class="btn btn-outline-secondary px-4">Back</a>
                                <c:if test="${not isExpired}">
                                    <button type="submit" class="btn btn-primary px-5 fw-bold">
                                        <i class="fa-solid fa-floppy-disk me-2"></i>Save Changes
                                    </button>
                                </c:if>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const type = document.getElementById("discountType");
                const maxGroup = document.getElementById("maxDiscountGroup");
                const maxInput = document.getElementById("maxDiscountAmount");
                const discountInput = document.getElementById("discountValue");
                const form = document.getElementById("editVoucherForm");

                const scopeRadios = document.querySelectorAll('input[name="scopeType"]');
                const categoryScopePanel = document.getElementById("categoryScopePanel");
                const parentSelect = document.getElementById("parentCategoryId");
                const multiSelect = document.getElementById("categoryMultiSelect");
                const trigger = document.getElementById("categorySelectTrigger");
                const triggerText = document.getElementById("categorySelectText");
                const chips = document.getElementById("selectedCategoryChips");
                const scopePreview = document.getElementById("scopePreviewText");
                const emptyParentMessage = document.getElementById("emptyParentMessage");
                const selectAllButton = document.getElementById("selectAllCategories");
                const clearButton = document.getElementById("clearCategories");
                const initialSelectedIds = [
                    <c:forEach var="categoryId" items="${voucher.selectedCategoryIds}" varStatus="status">
                        ${categoryId}${status.last ? '' : ','}
                    </c:forEach>
                ].map(String);

                function refreshDiscountFields() {
                    if (!type) return;
                    const fixed = type.value === "FIXED_AMOUNT";
                    maxGroup.style.display = fixed ? "none" : "block";
                    if (!maxInput.readOnly) maxInput.required = !fixed;
                    discountInput.step = fixed ? "1" : "0.01";
                }

                function isCategoryScope() {
                    const selected = document.querySelector('input[name="scopeType"]:checked');
                    return selected && selected.value === "CATEGORY";
                }

                function allCategoryInputs() {
                    return Array.from(document.querySelectorAll('input[name="categoryIds"]'))
                            .filter(input => input.type === "checkbox");
                }

                function activeCategoryInputs() {
                    return allCategoryInputs().filter(input => !input.disabled);
                }

                function selectedInputs() {
                    return activeCategoryInputs().filter(input => input.checked);
                }

                function showParentGroup(clearSelection) {
                    if (!parentSelect) return;
                    const parentId = parentSelect.value;
                    document.querySelectorAll(".category-option-group").forEach(group => {
                        const active = group.dataset.parentId === parentId;
                        group.classList.toggle("d-none", !active);
                        group.querySelectorAll('input[name="categoryIds"]').forEach(input => {
                            input.disabled = !active || !isCategoryScope();
                            if (clearSelection || !active) input.checked = false;
                        });
                    });
                    emptyParentMessage.classList.toggle("d-none", Boolean(parentId));
                    refreshSelectionDisplay();
                }

                function refreshScopeMode() {
                    if (!categoryScopePanel || !parentSelect) return;
                    const categoryMode = isCategoryScope();
                    categoryScopePanel.classList.toggle("d-none", !categoryMode);
                    parentSelect.disabled = !categoryMode;

                    if (!categoryMode) {
                        allCategoryInputs().forEach(input => {
                            input.checked = false;
                            input.disabled = true;
                        });
                        multiSelect.classList.remove("is-open");
                        scopePreview.textContent = "Entire Store";
                        chips.innerHTML = "";
                        triggerText.textContent = "Select child categories";
                        return;
                    }
                    showParentGroup(false);
                }

                function refreshSelectionDisplay() {
                    if (!parentSelect || !chips || !scopePreview) return;
                    const selected = selectedInputs();
                    const parentOption = parentSelect.options[parentSelect.selectedIndex];
                    const parentName = parentOption && parentOption.value
                            ? parentOption.textContent.trim()
                            : "";

                    triggerText.textContent = selected.length === 0
                            ? "Select child categories"
                            : selected.length + (selected.length === 1 ? " category selected" : " categories selected");
                    chips.innerHTML = "";

                    selected.forEach(input => {
                        const chip = document.createElement("span");
                        chip.className = "category-chip";
                        chip.innerHTML = '<span></span><button type="button" aria-label="Remove category"><i class="fa-solid fa-xmark"></i></button>';
                        chip.querySelector("span").textContent = input.dataset.categoryName;
                        chip.querySelector("button").addEventListener("click", function () {
                            input.checked = false;
                            refreshSelectionDisplay();
                        });
                        chips.appendChild(chip);
                    });

                    if (!isCategoryScope()) {
                        scopePreview.textContent = "Entire Store";
                    } else if (!parentName) {
                        scopePreview.textContent = "No parent category selected";
                    } else if (selected.length === 0) {
                        scopePreview.textContent = parentName + " — no child category selected";
                    } else {
                        scopePreview.textContent = parentName + " → "
                                + selected.map(input => input.dataset.categoryName).join(", ");
                    }
                }

                if (scopeRadios.length && parentSelect) {
                    scopeRadios.forEach(radio => radio.addEventListener("change", refreshScopeMode));
                    parentSelect.addEventListener("change", function () {
                        showParentGroup(true);
                        multiSelect.classList.remove("is-open");
                    });

                    trigger.addEventListener("click", function () {
                        if (!parentSelect.value) {
                            window.showAppToast("Select a parent category first.", "error", {title: "Category scope"});
                            return;
                        }
                        multiSelect.classList.toggle("is-open");
                    });

                    allCategoryInputs().forEach(input => input.addEventListener("change", refreshSelectionDisplay));
                    selectAllButton.addEventListener("click", function () {
                        activeCategoryInputs().forEach(input => input.checked = true);
                        refreshSelectionDisplay();
                    });
                    clearButton.addEventListener("click", function () {
                        activeCategoryInputs().forEach(input => input.checked = false);
                        refreshSelectionDisplay();
                    });
                    document.addEventListener("click", function (event) {
                        if (!multiSelect.contains(event.target)) {
                            multiSelect.classList.remove("is-open");
                        }
                    });

                    refreshScopeMode();
                    if (parentSelect.value) {
                        showParentGroup(false);
                        activeCategoryInputs().forEach(input => {
                            input.checked = initialSelectedIds.includes(input.value);
                        });
                        refreshSelectionDisplay();
                    }
                }

                if (type && !type.disabled) type.addEventListener("change", refreshDiscountFields);
                refreshDiscountFields();

                if (form) {
                    form.addEventListener("submit", function (event) {
                        const start = new Date(document.getElementById("startDate").value);
                        const end = new Date(document.getElementById("endDate").value);
                        const originalEnd = new Date("${formattedEnd}");
                        const minEnd = new Date(Date.now() + 48 * 60 * 60 * 1000);

                        if (parentSelect && isCategoryScope() && !parentSelect.value) {
                            event.preventDefault();
                            window.showAppToast("Please select a parent category.", "error", {title: "Validation error"});
                            return;
                        }

                        if (parentSelect && isCategoryScope() && selectedInputs().length === 0) {
                            event.preventDefault();
                            window.showAppToast("Please select at least one applicable child category.", "error", {title: "Validation error"});
                            return;
                        }

                        if (end <= start) {
                            event.preventDefault();
                            window.showAppToast("Campaign end date must occur after the start date.", "error", {title: "Validation error"});
                            return;
                        }

                        if (end.getTime() !== originalEnd.getTime() && end < minEnd) {
                            event.preventDefault();
                            window.showAppToast("The new end date must be at least 48 hours from now.", "error", {title: "Validation error"});
                        }
                    });
                }
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>