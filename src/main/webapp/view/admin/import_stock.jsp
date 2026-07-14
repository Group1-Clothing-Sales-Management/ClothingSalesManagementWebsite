<%@ page contentType="text/html;charset=UTF-8"
         language="java"
         pageEncoding="UTF-8" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Create Stock Receipt</title>

        <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
            rel="stylesheet">

        <link
            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            rel="stylesheet">

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <style>
            body {
                background: #f8f9fa;
                font-family: system-ui, -apple-system, sans-serif;
            }

            .main-content {
                width: 100%;
                min-height: 100vh;
                padding: 25px;
            }

            .page-heading {
                color: #1f2937;
                font-size: 1.55rem;
                font-weight: 750;
            }

            .content-card {
                border: 0;
                border-radius: 14px;
                box-shadow: 0 4px 18px rgba(15, 23, 42, .06);
            }

            .section-heading {
                color: #374151;
                font-size: 1rem;
                font-weight: 750;
            }

            .helper-text {
                color: #6b7280;
                font-size: .875rem;
            }

            .reference-panel {
                height: 100%;
                padding: 16px;
                background: #f8fbff;
                border: 1px solid #dbeafe;
                border-radius: 10px;
            }

            .receipt-table th {
                color: #4b5563;
                font-size: .82rem;
                white-space: nowrap;
            }

            .receipt-table td {
                vertical-align: middle;
            }

            .money {
                font-variant-numeric: tabular-nums;
            }

            .required::after {
                content: " *";
                color: #dc3545;
            }
            .summary-card {
                position: static;
                margin-bottom: 24px;
            }

            .variant-list {
                height: 320px;
                max-height: 320px;
                overflow-y: auto;
                background: #ffffff;
                border: 1px solid #dee2e6;
                border-radius: 10px;
            }

            .variant-option {
                width: 100%;
                min-height: 56px;
                padding: 14px 16px;
                display: flex;
                align-items: center;
                color: #1f2937;
                text-align: left;
                background: #ffffff;
                border: 0;
                border-bottom: 1px solid #e9ecef;
                transition:
                    background-color .15s ease,
                    color .15s ease,
                    box-shadow .15s ease;
            }

            .variant-option:last-child {
                border-bottom: 0;
            }

            .variant-option:hover:not(:disabled) {
                background: #eff6ff;
            }

            .variant-option.active {
                color: #ffffff;
                background: #2563eb;
                box-shadow: inset 4px 0 0 #1e40af;
            }

            .variant-option:disabled {
                color: #94a3b8;
                cursor: not-allowed;
                background: #f1f5f9;
            }

            .variant-option-name {
                overflow: hidden;
                font-size: .95rem;
                font-weight: 650;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .selected-variant-card {
                width: 100%;
                height: 100%;
                min-height: 320px;
                padding: 20px;
                background: #f8fbff;
                border: 1px solid #bfdbfe;
                border-radius: 12px;
            }

            .selected-variant-title {
                color: #1e3a8a;
                font-size: 1.1rem;
                font-weight: 750;
                line-height: 1.45;
                overflow-wrap: anywhere;
            }

            .selected-variant-empty {
                min-height: 275px;
                color: #64748b;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
                text-align: center;
            }

            .selected-variant-badges {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;
            }

            .selected-variant-badges .badge {
                margin: 0 !important;
                padding: 7px 9px;
                font-size: .8rem;
            }

            .variant-information-row {
                padding: 10px 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 15px;
                border-bottom: 1px solid #e5e7eb;
            }

            .variant-information-row:last-child {
                border-bottom: 0;
            }




        </style>
    </head>

    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="inventory"/>
        </jsp:include>

        <div class="main-content admin-page">
            <div class="container-fluid">

                <c:if test="${not empty inventoryFlashMessage}">
                    <div class="alert alert-danger">
                        <c:out value="${inventoryFlashMessage}"/>
                    </div>
                </c:if>

                <div class="d-flex flex-wrap
                     justify-content-between
                     align-items-center
                     gap-3 mb-4">

                    <div>
                        <div class="small fw-semibold
                             text-primary text-uppercase mb-1">
                            Inventory / Stock Receipts
                        </div>

                        <h1 class="page-heading mb-1">
                            <i class="fa-solid
                               fa-truck-ramp-box
                               me-2 text-primary"></i>
                            Create Stock Receipt
                        </h1>

                        <p class="helper-text mb-0">
                            Save the receipt as a draft first.
                            Inventory changes only after confirmation.
                        </p>
                    </div>

                    <a href="${pageContext.request.contextPath}/admin/inventory?action=list"
                       class="btn btn-outline-secondary px-4">
                        <i class="fa-solid fa-arrow-left me-2"></i>
                        Back to Receipts
                    </a>
                </div>

                <c:if test="${empty supplierList}">
                    <div class="alert alert-warning">
                        <i class="fa-solid
                           fa-triangle-exclamation me-2"></i>

                        <strong>No active suppliers found.</strong>
                        Add or activate a supplier before creating a receipt.
                    </div>
                </c:if>

                <form id="receiptForm"
                      action="${pageContext.request.contextPath}/admin/inventory"
                      method="post"
                      novalidate>

                    <input type="hidden"
                           name="action"
                           value="CREATE_DRAFT">

                    <!-- Receipt information -->
                    <div class="card content-card mb-4">
                        <div class="card-body p-4">

                            <div class="mb-4">
                                <div class="section-heading">
                                    <i class="fa-solid
                                       fa-file-invoice
                                       me-2 text-primary"></i>
                                    Receipt Information
                                </div>

                                <div class="helper-text">
                                    Supplier and vendor document information.
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-lg-4">
                                    <label for="supplierId"
                                           class="form-label
                                           fw-semibold required">
                                        Supplier
                                    </label>

                                    <select id="supplierId"
                                            name="supplierId"
                                            class="form-select"
                                            required
                                            ${empty supplierList
                                              ? 'disabled'
                                              : ''}>

                                        <option value="">
                                            Select a supplier
                                        </option>

                                        <c:forEach var="supplier"
                                                   items="${supplierList}">
                                            <option value="${supplier.id}">
                                                <c:out value="${supplier.supplierName}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-lg-4">
                                    <label for="vendorReference"
                                           class="form-label fw-semibold">
                                        Vendor Reference
                                    </label>

                                    <input id="vendorReference"
                                           name="vendorReference"
                                           type="text"
                                           maxlength="100"
                                           class="form-control"
                                           placeholder="Invoice or delivery note number">
                                </div>

                                <div class="col-lg-4">
                                    <label for="note"
                                           class="form-label fw-semibold">
                                        Internal Note
                                    </label>

                                    <input id="note"
                                           name="note"
                                           type="text"
                                           maxlength="500"
                                           class="form-control"
                                           placeholder="Optional note">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Add receipt item -->
                    <div class="card content-card mb-4">
                        <div class="card-body p-4">

                            <div class="mb-4">
                                <div class="section-heading">
                                    <i class="fa-solid
                                       fa-boxes-stacked
                                       me-2 text-success"></i>
                                    Add Receipt Item
                                </div>

                                <div class="helper-text">
                                    Select a product variant and enter its import cost.
                                    The current sale price will not be changed.
                                </div>
                            </div>

                            <div class="row g-4 align-items-stretch">

                                <!-- Search list -->
                                <div class="col-xl-7">

                                    <label for="variantSearch"
                                           class="form-label fw-semibold">
                                        Search Product Variant
                                    </label>

                                    <div class="input-group mb-2">
                                        <span class="input-group-text bg-white">
                                            <i class="fa-solid
                                               fa-magnifying-glass
                                               text-muted"></i>
                                        </span>

                                        <input id="variantSearch"
                                               type="search"
                                               class="form-control"
                                               placeholder="Search by product name, size, or color"
                                               autocomplete="off">
                                    </div>

                                    <div id="variantList"
                                         class="variant-list">

                                        <c:forEach var="variant"
                                                   items="${activeVariants}">

                                            <button type="button"
                                                    class="variant-option"
                                                    data-id="${variant.id}"
                                                    data-name="${fn:escapeXml(
                                                                 variant.attributeDetails
                                                                 )}"
                                                    data-sku="${fn:escapeXml(
                                                                variant.sku
                                                                )}"
                                                    data-size="${fn:escapeXml(
                                                                 variant.size
                                                                 )}"
                                                    data-color="${fn:escapeXml(
                                                                  variant.color
                                                                  )}"
                                                    data-stock="${variant.stockQuantity}"
                                                    data-cost="${variant.costPrice}"
                                                    data-sale="${variant.salePrice}">

                                                <div class="variant-option-name">
                                                    <c:out value="${variant.attributeDetails}"/>
                                                </div>
                                            </button>

                                        </c:forEach>

                                        <div id="noVariantResult"
                                             class="d-none text-center
                                             text-muted py-5">

                                            <i class="fa-solid
                                               fa-magnifying-glass
                                               fs-4 mb-2"></i>

                                            <div>
                                                No matching product variants.
                                            </div>
                                        </div>

                                        <c:if test="${empty activeVariants}">
                                            <div class="text-center
                                                 text-muted py-5">
                                                No active product variants found.
                                            </div>
                                        </c:if>

                                    </div>
                                </div>

                                <!-- Selected variant -->
                                <div class="col-xl-5">

                                    <label class="form-label fw-semibold">
                                        Selected Product
                                    </label>

                                    <div class="selected-variant-card">

                                        <div id="selectedVariantEmpty"
                                             class="selected-variant-empty">

                                            <i class="fa-regular
                                               fa-hand-pointer
                                               fs-2 mb-3"></i>

                                            <div class="fw-semibold mb-1">
                                                No variant selected
                                            </div>

                                            <small>
                                                Click a product variant from the search results.
                                            </small>
                                        </div>

                                        <div id="selectedVariantDetails"
                                             class="d-none">

                                            <div class="small
                                                 text-uppercase
                                                 text-muted
                                                 fw-semibold mb-2">
                                                Selected Product
                                            </div>

                                            <div id="selectedVariantName"
                                                 class="selected-variant-title mb-3">
                                            </div>

                                            <div class="selected-variant-badges mb-3">

                                                <span class="badge
                                                      text-bg-light
                                                      border">
                                                    SKU:
                                                    <span id="selectedSku"></span>
                                                </span>

                                                <span class="badge
                                                      text-bg-light
                                                      border">
                                                    Size:
                                                    <span id="selectedSize"></span>
                                                </span>

                                                <span class="badge
                                                      text-bg-light
                                                      border">
                                                    Color:
                                                    <span id="selectedColor"></span>
                                                </span>

                                            </div>

                                            <div class="border-top pt-2">

                                                <div class="variant-information-row">
                                                    <span class="text-muted">
                                                        Current stock
                                                    </span>

                                                    <strong id="currentStock">
                                                        0 pcs
                                                    </strong>
                                                </div>

                                                <div class="variant-information-row">
                                                    <span class="text-muted">
                                                        Average cost
                                                    </span>

                                                    <strong id="currentCost"
                                                            class="money">
                                                        0 VND
                                                    </strong>
                                                </div>

                                                <div class="variant-information-row">
                                                    <span class="text-muted">
                                                        Current sale price
                                                    </span>

                                                    <strong id="currentSale"
                                                            class="money text-primary">
                                                        0 VND
                                                    </strong>
                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Quantity -->
                                <div class="col-lg-4 col-md-6">

                                    <label for="quantity"
                                           class="form-label fw-semibold required">
                                        Quantity
                                    </label>

                                    <input id="quantity"
                                           type="number"
                                           min="1"
                                           max="1000000"
                                           step="1"
                                           class="form-control"
                                           placeholder="Enter quantity">
                                </div>

                                <!-- Unit cost -->
                                <div class="col-lg-4 col-md-6">

                                    <label for="unitCost"
                                           class="form-label fw-semibold required">
                                        Unit Cost (VND)
                                    </label>

                                    <input id="unitCost"
                                           type="number"
                                           min="0.01"
                                           step="0.01"
                                           class="form-control"
                                           placeholder="Enter import cost">
                                </div>

                                <!-- Add button -->
                                <div class="col-lg-4 d-flex align-items-end">

                                    <button id="addItemButton"
                                            type="button"
                                            class="btn btn-primary
                                            w-100 px-4">

                                        <i class="fa-solid fa-plus me-2"></i>
                                        Add Item
                                    </button>
                                </div>

                            </div>
                        </div>
                    </div>

                    <!-- Draft items -->
                    <div class="card content-card mb-4">
                        <div class="card-body p-0">

                            <div class="p-4 border-bottom
                                 d-flex justify-content-between
                                 align-items-center">

                                <div>
                                    <div class="section-heading">
                                        Draft Items
                                    </div>

                                    <div class="helper-text">
                                        Review items before saving.
                                    </div>
                                </div>

                                <span class="badge text-bg-primary">
                                    <span id="itemCount">0</span>
                                    item(s)
                                </span>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-hover
                                       receipt-table mb-0">

                                    <thead class="table-light">
                                        <tr>
                                            <th class="text-center">#</th>
                                            <th>Product Variant</th>
                                            <th>SKU</th>
                                            <th class="text-center">
                                                Quantity
                                            </th>
                                            <th class="text-end">
                                                Unit Cost
                                            </th>
                                            <th class="text-end">
                                                Line Total
                                            </th>
                                            <th class="text-center">
                                                Action
                                            </th>
                                        </tr>
                                    </thead>

                                    <tbody id="receiptItemsBody">

                                        <tr id="emptyItemsRow">
                                            <td colspan="7"
                                                class="text-center
                                                text-muted py-5">

                                                <i class="fa-regular
                                                   fa-rectangle-list
                                                   fs-3 d-block mb-2"></i>

                                                Add at least one product variant.
                                            </td>
                                        </tr>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Summary -->
                    <div class="card content-card summary-card">
                        <div class="card-body p-4
                             d-flex flex-wrap
                             justify-content-between
                             align-items-center gap-3">

                            <div>
                                <div class="small text-muted">
                                    Total Import Cost
                                </div>

                                <div id="grandTotal"
                                     class="fs-3 fw-bold money">
                                    0 VND
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/admin/inventory?action=list"
                                   class="btn btn-outline-secondary px-4">
                                    Cancel
                                </a>

                                <button id="saveDraftButton"
                                        type="submit"
                                        class="btn btn-success px-4"
                                        disabled>

                                    <i class="fa-regular
                                       fa-floppy-disk me-2"></i>
                                    Save Draft Receipt
                                </button>
                            </div>
                        </div>
                    </div>

                </form>
            </div>
        </div>

        <jsp:include page="/view/admin/common/admin_layout_end.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {

                const variantButtons = Array.from(
                        document.querySelectorAll('.variant-option')
                        );

                const variantSearch =
                        document.getElementById('variantSearch');

                const selectedVariantEmpty =
                        document.getElementById('selectedVariantEmpty');

                const selectedVariantDetails =
                        document.getElementById('selectedVariantDetails');

                const selectedVariantName =
                        document.getElementById('selectedVariantName');

                const selectedSku =
                        document.getElementById('selectedSku');

                const selectedSize =
                        document.getElementById('selectedSize');

                const selectedColor =
                        document.getElementById('selectedColor');

                const currentStock =
                        document.getElementById('currentStock');

                const currentCost =
                        document.getElementById('currentCost');

                const currentSale =
                        document.getElementById('currentSale');

                const noVariantResult =
                        document.getElementById('noVariantResult');

                const quantityInput =
                        document.getElementById('quantity');

                const unitCostInput =
                        document.getElementById('unitCost');

                const addItemButton =
                        document.getElementById('addItemButton');

                const tableBody =
                        document.getElementById('receiptItemsBody');

                const emptyRow =
                        document.getElementById('emptyItemsRow');

                const itemCount =
                        document.getElementById('itemCount');

                const grandTotal =
                        document.getElementById('grandTotal');

                const saveDraftButton =
                        document.getElementById('saveDraftButton');

                const receiptForm =
                        document.getElementById('receiptForm');

                const supplierSelect =
                        document.getElementById('supplierId');

                const items = new Map();

                let selectedVariant = null;

                const numberFormatter = new Intl.NumberFormat(
                        'en-US',
                        {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2
                        }
                );

                function formatVnd(value) {
                    const numberValue = Number(value || 0);

                    return numberFormatter.format(numberValue) + ' VND';
                }

                function escapeHtml(value) {
                    return String(value || '')
                            .replaceAll('&', '&amp;')
                            .replaceAll('<', '&lt;')
                            .replaceAll('>', '&gt;')
                            .replaceAll('"', '&quot;')
                            .replaceAll("'", '&#039;');
                }

                /*
                 * Cho phép tìm kiếm tiếng Việt không dấu.
                 * Ví dụ: "ao blazer" vẫn tìm được "Áo Blazer".
                 */
                function normalizeText(value) {
                    return String(value || '')
                            .normalize('NFD')
                            .replace(/[\u0300-\u036f]/g, '')
                            .replace(/đ/g, 'd')
                            .replace(/Đ/g, 'D')
                            .toLowerCase()
                            .trim();
                }

                function showSelectedVariant() {
                    if (!selectedVariant) {
                        selectedVariantEmpty.classList.remove('d-none');
                        selectedVariantDetails.classList.add('d-none');
                        return;
                    }

                    selectedVariantEmpty.classList.add('d-none');
                    selectedVariantDetails.classList.remove('d-none');

                    selectedVariantName.textContent =
                            selectedVariant.name;

                    selectedSku.textContent =
                            selectedVariant.sku || 'N/A';

                    selectedSize.textContent =
                            selectedVariant.size || 'N/A';

                    selectedColor.textContent =
                            selectedVariant.color || 'N/A';

                    currentStock.textContent =
                            selectedVariant.stock + ' pcs';

                    currentCost.textContent =
                            formatVnd(selectedVariant.cost);

                    currentSale.textContent =
                            formatVnd(selectedVariant.sale);

                    /*
                     * Dùng giá vốn hiện tại làm giá nhập gợi ý.
                     * Admin vẫn có thể sửa lại.
                     */
                    unitCostInput.value =
                            selectedVariant.cost > 0
                            ? selectedVariant.cost.toFixed(2)
                            : '';
                }

                function clearSelectedVariant() {
                    selectedVariant = null;

                    variantButtons.forEach(function (button) {
                        button.classList.remove('active');
                    });

                    quantityInput.value = '';
                    unitCostInput.value = '';

                    showSelectedVariant();
                }

                function filterVariants() {
                    const keyword = normalizeText(
                            variantSearch.value
                            );

                    let visibleCount = 0;

                    variantButtons.forEach(function (button) {
                        const searchableText = normalizeText(
                                [
                                    button.dataset.name,
                                    button.dataset.size,
                                    button.dataset.color,
                                    button.dataset.sku
                                ].join(' ')
                                );

                        const matched =
                                keyword === ''
                                || searchableText.includes(keyword);

                        button.classList.toggle(
                                'd-none',
                                !matched
                                );

                        if (matched) {
                            visibleCount++;
                        }
                    });

                    if (noVariantResult) {
                        noVariantResult.classList.toggle(
                                'd-none',
                                visibleCount > 0
                                );
                    }
                }

                function setVariantAddedState(
                        variantId,
                        isAdded
                        ) {
                    const button = variantButtons.find(
                            function (variantButton) {
                                return String(variantButton.dataset.id)
                                        === String(variantId);
                            }
                    );

                    if (!button) {
                        return;
                    }

                    button.disabled = isAdded;

                    button.classList.toggle(
                            'opacity-50',
                            isAdded
                            );

                    button.classList.remove('active');

                    if (isAdded) {
                        button.setAttribute(
                                'title',
                                'This variant is already in the receipt.'
                                );
                    } else {
                        button.removeAttribute('title');
                    }
                }

                function renderItems() {
                    tableBody
                            .querySelectorAll('tr[data-item-row]')
                            .forEach(function (row) {
                                row.remove();
                            });

                    emptyRow.classList.toggle(
                            'd-none',
                            items.size > 0
                            );

                    let rowNumber = 1;
                    let totalAmount = 0;

                    items.forEach(function (item) {
                        const lineTotal =
                                item.quantity * item.unitCost;

                        totalAmount += lineTotal;

                        const row =
                                document.createElement('tr');

                        row.dataset.itemRow = 'true';

                        row.innerHTML =
                                '<td class="text-center text-muted">'
                                + rowNumber++
                                + '</td>'

                                + '<td>'
                                + '<div class="fw-semibold">'
                                + escapeHtml(item.name)
                                + '</div>'

                                + '<div class="small text-muted mt-1">'
                                + 'Size: '
                                + escapeHtml(item.size || 'N/A')
                                + ' | Color: '
                                + escapeHtml(item.color || 'N/A')
                                + '</div>'
                                + '</td>'

                                + '<td>'
                                + '<span class="badge text-bg-light border">'
                                + escapeHtml(item.sku)
                                + '</span>'
                                + '</td>'

                                + '<td class="text-center fw-semibold">'
                                + item.quantity
                                + '</td>'

                                + '<td class="text-end money">'
                                + formatVnd(item.unitCost)
                                + '</td>'

                                + '<td class="text-end fw-bold money">'
                                + formatVnd(lineTotal)
                                + '</td>'

                                + '<td class="text-center">'

                                + '<button type="button" '
                                + 'class="btn btn-sm btn-outline-danger" '
                                + 'data-remove-id="'
                                + item.variantId
                                + '" '
                                + 'title="Remove item">'

                                + '<i class="fa-solid fa-trash"></i>'

                                + '</button>'

                                + '<input type="hidden" '
                                + 'name="variantId[]" '
                                + 'value="'
                                + item.variantId
                                + '">'

                                + '<input type="hidden" '
                                + 'name="quantity[]" '
                                + 'value="'
                                + item.quantity
                                + '">'

                                + '<input type="hidden" '
                                + 'name="unitCost[]" '
                                + 'value="'
                                + item.unitCost.toFixed(2)
                                + '">'

                                + '</td>';

                        tableBody.appendChild(row);
                    });

                    itemCount.textContent = items.size;

                    grandTotal.textContent =
                            formatVnd(totalAmount);

                    saveDraftButton.disabled =
                            items.size === 0
                            || !supplierSelect
                            || !supplierSelect.value;
                }

                /*
                 * Tìm kiếm variant.
                 */
                variantSearch.addEventListener(
                        'input',
                        filterVariants
                        );

                /*
                 * Chọn variant trong danh sách.
                 */
                variantButtons.forEach(function (button) {

                    button.addEventListener(
                            'click',
                            function () {

                                if (button.disabled) {
                                    return;
                                }

                                variantButtons.forEach(
                                        function (variantButton) {
                                            variantButton.classList.remove(
                                                    'active'
                                                    );
                                        }
                                );

                                button.classList.add('active');

                                const sku =
                                        button.dataset.sku || '';

                                const skuParts =
                                        sku.split('-');

                                let size =
                                        (button.dataset.size || '').trim();

                                let color =
                                        (button.dataset.color || '').trim();

                                /*
                                 * JavaScript fallback cho dữ liệu cũ.
                                 */
                                if (!size && skuParts.length >= 1) {
                                    size =
                                            skuParts[skuParts.length - 1];
                                }

                                if (!color && skuParts.length >= 2) {
                                    const colorCode =
                                            skuParts[skuParts.length - 2]
                                            .toUpperCase();

                                    const colorMap = {
                                        BLK: 'Black',
                                        WHT: 'White',
                                        GRY: 'Gray',
                                        GR: 'Gray',
                                        RED: 'Red',
                                        BLU: 'Blue',
                                        NVY: 'Navy',
                                        GRN: 'Green',
                                        BRN: 'Brown',
                                        BEI: 'Beige',
                                        PNK: 'Pink'
                                    };

                                    color =
                                            colorMap[colorCode] || colorCode;
                                }

                                selectedVariant = {
                                    id: Number(button.dataset.id),
                                    name: button.dataset.name || '',
                                    sku: sku,
                                    size: size,
                                    color: color,
                                    stock: Number(button.dataset.stock || 0),
                                    cost: Number(button.dataset.cost || 0),
                                    sale: Number(button.dataset.sale || 0)
                                };

                                showSelectedVariant();

                                quantityInput.focus();
                            }
                    );
                });

                /*
                 * Thêm variant vào phiếu.
                 */
                addItemButton.addEventListener(
                        'click',
                        function () {

                            if (!selectedVariant) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Select a product variant',
                                    text: 'Click a product variant from the search results.'
                                });

                                return;
                            }

                            const quantity =
                                    Number(quantityInput.value);

                            const unitCost =
                                    Number(unitCostInput.value);

                            if (!Number.isInteger(quantity)
                                    || quantity <= 0) {

                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Invalid quantity',
                                    text: 'Quantity must be a positive whole number.'
                                });

                                quantityInput.focus();
                                return;
                            }

                            if (quantity > 1000000) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Quantity is too large',
                                    text: 'Quantity must not exceed 1,000,000.'
                                });

                                quantityInput.focus();
                                return;
                            }

                            if (!Number.isFinite(unitCost)
                                    || unitCost <= 0) {

                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Invalid unit cost',
                                    text: 'Unit cost must be greater than zero.'
                                });

                                unitCostInput.focus();
                                return;
                            }

                            const itemKey =
                                    String(selectedVariant.id);

                            if (items.has(itemKey)) {
                                Swal.fire({
                                    icon: 'info',
                                    title: 'Variant already added',
                                    text: 'Each product variant can appear only once in a receipt.'
                                });

                                return;
                            }

                            items.set(
                                    itemKey,
                                    {
                                        variantId: selectedVariant.id,
                                        name: selectedVariant.name,
                                        sku: selectedVariant.sku,
                                        size: selectedVariant.size,
                                        color: selectedVariant.color,
                                        quantity: quantity,
                                        unitCost: unitCost
                                    }
                            );

                            setVariantAddedState(
                                    selectedVariant.id,
                                    true
                                    );

                            variantSearch.value = '';

                            filterVariants();
                            clearSelectedVariant();
                            renderItems();
                        }
                );

                /*
                 * Cho phép nhấn Enter trong Quantity hoặc Unit Cost
                 * để thêm sản phẩm.
                 */
                [quantityInput, unitCostInput].forEach(
                        function (input) {
                            input.addEventListener(
                                    'keydown',
                                    function (event) {
                                        if (event.key === 'Enter') {
                                            event.preventDefault();
                                            addItemButton.click();
                                        }
                                    }
                            );
                        }
                );

                /*
                 * Xóa sản phẩm khỏi receipt.
                 */
                tableBody.addEventListener(
                        'click',
                        function (event) {

                            const removeButton =
                                    event.target.closest(
                                            '[data-remove-id]'
                                            );

                            if (!removeButton) {
                                return;
                            }

                            const variantId =
                                    removeButton.dataset.removeId;

                            items.delete(
                                    String(variantId)
                                    );

                            setVariantAddedState(
                                    variantId,
                                    false
                                    );

                            renderItems();
                        }
                );

                /*
                 * Supplier thay đổi thì cập nhật trạng thái nút Save.
                 */
                if (supplierSelect) {
                    supplierSelect.addEventListener(
                            'change',
                            renderItems
                            );
                }

                /*
                 * Xác nhận lưu phiếu nháp.
                 */
                receiptForm.addEventListener(
                        'submit',
                        function (event) {
                            event.preventDefault();

                            if (!supplierSelect
                                    || !supplierSelect.value) {

                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Supplier required',
                                    text: 'Select an active supplier.'
                                });

                                return;
                            }

                            if (items.size === 0) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'No receipt items',
                                    text: 'Add at least one product variant.'
                                });

                                return;
                            }

                            Swal.fire({
                                title: 'Save this receipt as a draft?',
                                text: 'Inventory and sale prices will not change yet.',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: 'Save Draft',
                                cancelButtonText: 'Continue Editing',
                                confirmButtonColor: '#198754'
                            }).then(function (result) {

                                if (!result.isConfirmed) {
                                    return;
                                }

                                saveDraftButton.disabled = true;

                                saveDraftButton.innerHTML =
                                        '<span class="spinner-border '
                                        + 'spinner-border-sm me-2"></span>'
                                        + 'Saving...';

                                /*
                                 * submit() trực tiếp để không chạy lại
                                 * sự kiện submit lần thứ hai.
                                 */
                                receiptForm.submit();
                            });
                        }
                );

                /*
                 * Trạng thái ban đầu:
                 * không tự chọn sản phẩm đầu tiên.
                 */
                filterVariants();
                showSelectedVariant();
                renderItems();
            });
        </script>

    </body>
</html>