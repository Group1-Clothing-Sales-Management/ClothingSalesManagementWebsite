<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Stock Batch Import - Admin Area</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet"/>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            body {
                background-color: #f8f9fa;
                font-family: system-ui, -apple-system, sans-serif;
                overflow-x: hidden;
            }
            .wrapper {
                display: flex;
                width: 100%;
                align-items: stretch;
            }
            .main-content {
                width: 100%;
                padding: 25px;
                min-height: 100vh;
                background-color: #f8f9fa;
            }
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background-color: #cbd5e1;
                border-radius: 4px;
            }
            .search-results-box {
                position: absolute;
                left: 0;
                right: 0;
                z-index: 1050;
                max-height: 250px;
                overflow-y: auto;
                background: white;
                border: 1px solid #dee2e6;
                border-radius: 0.375rem;
                box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            }
        </style>
    </head>
    <body>

        <jsp:include page="/view/admin/common/admin_layout_start.jsp">
            <jsp:param name="activeTab" value="inventory" />
        </jsp:include>

        <div class="main-content admin-page">
            <div class="container-fluid" style="max-width: 1100px; margin: 0 auto;">
                <c:if test="${param.status eq 'error'}">
                    <div class="d-none" data-admin-toast data-admin-toast-type="error">Unable to process the stock import. Please try again.</div>
                </c:if>
                <div class="card card-main admin-card p-4 mb-4">
                    <div class="border-bottom pb-3 mb-4">
                        <h2 class="page-title mb-1" style="font-size: 1.15rem;">
                            <i class="fa-solid fa-square-plus me-2 text-success"></i>Stock Inflow Management
                        </h2>
                        <p class="page-subtitle small mb-0">Select items, specify pricing metrics, and add them to the temporary batch queuing registry pool.</p>
                    </div>

                    <div class="row g-3">
                        <div class="col-12 position-relative mb-2">
                            <label class="form-label fw-bold text-secondary">Search Clothing Variant Item *</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                <input type="text" id="variantSearchInput" placeholder="Type to filter product variant by name, SKU, size, or color..." class="form-control py-2">
                                <button type="button" id="clearSearchBtn" class="btn btn-outline-secondary d-none"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <div id="searchResults" class="search-results-box d-none custom-scrollbar"></div>
                            <input type="hidden" id="tempVariantId">
                            <input type="hidden" id="tempDisplayName">
                            <input type="hidden" id="tempSku">
                        </div>

                        <div id="contextPricePanel" class="alert alert-info d-none align-items-center mb-2">
                            <i class="fa-solid fa-circle-info me-2"></i>
                            <span><strong>Current Reference:</strong> Cost Price: <span id="refCost" class="fw-bold"></span>$ | Retail Selling Price: <span id="refSale" class="fw-bold"></span>$</span>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold text-secondary">Inflow Quantity *</label>
                            <input type="number" id="inputQuantity" min="1" placeholder="e.g., 100" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold text-secondary">Cost Price ($) *</label>
                            <input type="number" id="inputCostPrice" step="0.01" min="0" placeholder="e.g., 15.50" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold text-secondary">New Sale Price ($) *</label>
                            <input type="number" id="inputSalePrice" step="0.01" min="0" placeholder="e.g., 29.99" class="form-control">
                        </div>

                        <div class="col-12 d-flex justify-content-end mt-3">
                            <button type="button" id="addToQueueBtn" class="btn btn-primary fw-bold px-4">
                                <i class="fa-solid fa-plus me-2"></i>Add to Queue List
                            </button>
                        </div>
                    </div>
                </div>

                <form id="importStockForm" action="${pageContext.request.contextPath}/admin/inventory" method="POST">
                    <input type="hidden" name="action" value="IMPORT" />

                    <div class="card card-main admin-card p-4 bg-white rounded-3">

                        <div class="row g-3 mb-4">
                            <div class="col-md-3">
                                <label class="form-label fw-bold text-secondary">Supplier (Nhà Cung Cấp) *</label>
                                <select name="supplierId" class="form-select border-primary" required>
                                    <option value="">-- Select Supplier --</option>
                                    <c:forEach var="sup" items="${supplierList}">
                                        <option value="${sup.id}">${sup.supplierName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label fw-bold text-secondary">Batch Reference Header</label>
                                <input type="text" id="batchCode" name="batchCode" readonly required class="form-control bg-light text-primary fw-bold">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-secondary">Global Transaction Note / Vendor Ref</label>
                                <input type="text" name="note" placeholder="e.g., Bulk import container delivery batch..." class="form-control">
                            </div>
                        </div>

                        <h5 class="fw-bold text-dark mb-3 flex items-center" style="font-size: 1rem;">
                            <i class="fa-solid fa-list-check me-2 text-primary"></i>Staged Batch Items Queue Checklist
                        </h5>

                        <div class="table-responsive mb-4 border rounded">
                            <table class="table table-hover align-middle mb-0 admin-table" id="queueTable">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-center" style="width: 60px;">#</th>
                                        <th>Product Variant Details / Structural Specification Reference</th>
                                        <th class="text-center" style="width: 120px;">Qty</th>
                                        <th class="text-end" style="width: 140px;">Cost Unit</th>
                                        <th class="text-end" style="width: 140px;">Retail Sale Unit</th>
                                        <th class="text-end" style="width: 150px;">Subtotal</th>
                                        <th class="text-center" style="width: 80px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="queueTableBody">
                                    <tr id="emptyRowPlaceholder">
                                        <td colspan="7" class="text-center py-4 text-muted small">
                                            <i class="fa-solid fa-cubes fs-4 mb-2 d-block text-secondary"></i>
                                            No items added to the staging import queue checklist pool yet.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                            <div>
                                <span class="fs-5 text-secondary">Total Import Value: </span>
                                <span class="fs-4 fw-bold text-danger" id="displayTotalAmount">$0.00</span>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/admin/inventory?action=list" class="btn btn-outline-secondary px-4">Cancel</a>
                                <button type="submit" id="submitFormBtn" class="btn btn-success fw-bold px-4" disabled>
                                    <i class="fa-solid fa-cloud-arrow-up me-2"></i>Process Import Batch
                                </button>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
        </div>
        <jsp:include page="/view/admin/common/admin_layout_end.jsp" />

        <script>
            // Synchronized Core In-Memory JSON Dataset
            const variantData = [
            <c:forEach items="${activeVariants}" var="v" varStatus="status">
            {
            id: "${v.id}",
                  sku: "${v.sku}",
                  oldCost: "${v.costPrice}",
                  oldSale: "${v.salePrice}",
                  displayName: "<c:out value='${v.attributeDetails}' default='Standard Item Variant' />"
            }${!status.last ? ',' : ''}
            </c:forEach>
            ];

            document.addEventListener("DOMContentLoaded", function () {
                // 1. Generate Uniform Batch Code Header Reference String
                const now = new Date();
                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                const day = String(now.getDate()).padStart(2, '0');
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(now.getMinutes()).padStart(2, '0');
                const batchField = document.getElementById("batchCode");
                if (batchField) {
                    batchField.value = "BATCH-" + year + month + day + "-" + hours + minutes;
                }

                // 2. Setup Autocomplete Controls
                const searchInput = document.getElementById("variantSearchInput");
                const resultsBox = document.getElementById("searchResults");
                const clearBtn = document.getElementById("clearSearchBtn");
                const contextPricePanel = document.getElementById("contextPricePanel");

                // Temp Storage fields to bind picked values
                const tempVariantId = document.getElementById("tempVariantId");
                const tempDisplayName = document.getElementById("tempDisplayName");
                const tempSku = document.getElementById("tempSku");

                const inputQuantity = document.getElementById("inputQuantity");
                const inputCostPrice = document.getElementById("inputCostPrice");
                const inputSalePrice = document.getElementById("inputSalePrice");

                searchInput.addEventListener("input", function () {
                    const keyword = this.value.trim().toLowerCase();
                    resultsBox.innerHTML = "";

                    if (keyword.length === 0) {
                        resultsBox.classList.add("d-none");
                        clearBtn.classList.add("d-none");
                        return;
                    }
                    clearBtn.classList.remove("d-none");

                    const filtered = variantData.filter(item =>
                        item.displayName.toLowerCase().includes(keyword) || item.sku.toLowerCase().includes(keyword)
                    );

                    if (filtered.length > 0) {
                        filtered.forEach(item => {
                            const btn = document.createElement("button");
                            btn.type = "button";
                            btn.className = "dropdown-item text-wrap py-2 border-bottom text-start";

                            btn.innerHTML = '<i class="fa-solid fa-shirt me-2 text-secondary"></i> ' + item.displayName + ' <span class="badge bg-light text-secondary font-mono ms-1">' + item.sku + '</span>';

                            btn.addEventListener("click", function () {
                                searchInput.value = item.displayName + " (" + item.sku + ")";
                                tempVariantId.value = item.id;
                                tempDisplayName.value = item.displayName;
                                tempSku.value = item.sku;
                                resultsBox.classList.add("d-none");

                                document.getElementById("refCost").innerText = item.oldCost;
                                document.getElementById("refSale").innerText = item.oldSale;
                                inputCostPrice.value = item.oldCost;
                                inputSalePrice.value = item.oldSale;
                                contextPricePanel.classList.replace("d-none", "d-flex");
                            });
                            resultsBox.appendChild(btn);
                        });
                        resultsBox.classList.remove("d-none");
                    } else {
                        resultsBox.innerHTML = '<div class="p-3 text-center text-muted small">No matching variant configurations found</div>';
                        resultsBox.classList.remove("d-none");
                    }
                });

                clearBtn.addEventListener("click", function () {
                    searchInput.value = "";
                    tempVariantId.value = "";
                    tempDisplayName.value = "";
                    tempSku.value = "";
                    resultsBox.innerHTML = "";
                    resultsBox.classList.add("d-none");
                    this.classList.add("d-none");
                    contextPricePanel.classList.replace("d-flex", "d-none");
                });

                document.addEventListener("click", function (e) {
                    if (e.target !== searchInput && e.target !== resultsBox)
                        resultsBox.classList.add("d-none");
                });

                // 3. MANAGEMENT OF DYNAMIC CLIENT-SIDE QUEUE STAGING LIST
                const addToQueueBtn = document.getElementById("addToQueueBtn");
                const queueTableBody = document.getElementById("queueTableBody");
                const emptyRowPlaceholder = document.getElementById("emptyRowPlaceholder");
                const submitFormBtn = document.getElementById("submitFormBtn");

                let itemIndex = 0;

                addToQueueBtn.addEventListener("click", function () {
                    const vId = tempVariantId.value;
                    const dName = tempDisplayName.value;
                    const sku = tempSku.value;
                    const qty = parseInt(inputQuantity.value);
                    const cost = parseFloat(inputCostPrice.value);
                    const sale = parseFloat(inputSalePrice.value);

                    // Inputs Guard Validations
                    if (!vId) {
                        Swal.fire('Product Required', 'Please search and pick a configuration from the search dropdown filter box first.', 'warning');
                        return;
                    }
                    if (isNaN(qty) || qty <= 0) {
                        Swal.fire('Invalid Quantity', 'Please provide a valid strictly positive non-zero inflow batch quantity amount.', 'warning');
                        return;
                    }
                    if (isNaN(cost) || cost < 0 || isNaN(sale) || sale < 0) {
                        Swal.fire('Invalid Pricing', 'Cost prices and storefront market target price variables cannot hold negative markers.', 'warning');
                        return;
                    }
                    if (sale < cost) {
                        Swal.fire('Margin Conflict', 'Retail market listing price parameters cannot fall behind base wholesale production cost values.', 'error');
                        return;
                    }

                    // Remove initial empty baseline indicator
                    if (emptyRowPlaceholder)
                        emptyRowPlaceholder.remove();

                    itemIndex++;
                    const subtotal = (qty * cost).toFixed(2);

                    const tr = document.createElement("tr");
                    tr.id = "queue-row-" + itemIndex;
                    tr.innerHTML = '<td class="text-center fw-bold text-muted font-mono">' + itemIndex + '</td>' +
                            '<td>' +
                            '<div class="fw-bold text-dark">' + dName + '</div>' +
                            '<small class="text-muted font-mono">SKU: ' + sku + '</small>' +
                            '<input type="hidden" name="variantId[]" value="' + vId + '">' +
                            '<input type="hidden" name="quantity[]" value="' + qty + '">' +
                            '<input type="hidden" name="costPrice[]" value="' + cost.toFixed(2) + '">' +
                            '<input type="hidden" name="salePrice[]" value="' + sale.toFixed(2) + '">' +
                            '</td>' +
                            '<td class="text-center bg-light fw-bold">' + qty + ' pcs</td>' +
                            '<td class="text-end font-mono">$' + cost.toFixed(2) + '</td>' +
                            '<td class="text-end font-mono text-primary fw-bold">$' + sale.toFixed(2) + '</td>' +
                            '<td class="text-end font-mono fw-bold text-dark">$' + subtotal + '</td>' +
                            '<td class="text-center">' +
                            '<button type="button" class="btn btn-sm btn-outline-danger remove-queue-btn"><i class="fa-solid fa-trash-can"></i></button>' +
                            '</td>';

                    // Bind internal instant line deletion command handler click
                    tr.querySelector(".remove-queue-btn").addEventListener("click", function () {
                        tr.remove();
                        checkTableState();
                    });

                    queueTableBody.appendChild(tr);
                    checkTableState();

                    // Flush fields
                    searchInput.value = "";
                    tempVariantId.value = "";
                    tempDisplayName.value = "";
                    tempSku.value = "";
                    inputQuantity.value = "";
                    inputCostPrice.value = "";
                    inputSalePrice.value = "";
                    clearBtn.classList.add("d-none");
                    contextPricePanel.classList.replace("d-flex", "d-none");
                });

                function checkTableState() {
                    const rows = queueTableBody.querySelectorAll("tr:not(#emptyRowPlaceholder)");
                    let grandTotal = 0.0; // BỔ SUNG: Tính tổng tiền phiếu nhập

                    if (rows.length > 0) {
                        submitFormBtn.removeAttribute("disabled");
                    } else {
                        submitFormBtn.setAttribute("disabled", "true");
                        if (!queueTableBody.contains(emptyRowPlaceholder)) {
                            queueTableBody.appendChild(emptyRowPlaceholder);
                        }
                    }

                    rows.forEach((row, idx) => {
                        row.firstElementChild.innerText = idx + 1;

                        // BỔ SUNG: Trích xuất và tính tổng tiền dựa vào DOM
                        const itemQty = parseFloat(row.querySelector("input[name='quantity[]']").value);
                        const itemCost = parseFloat(row.querySelector("input[name='costPrice[]']").value);
                        grandTotal += (itemQty * itemCost);
                    });

                    // BỔ SUNG: Render tổng tiền ra giao diện
                    document.getElementById("displayTotalAmount").innerText = "$" + grandTotal.toFixed(2);
                }

                // 4. TRANSACTION CONFIRMATION INTERCEPT POPEVENT CONTROL
                const form = document.getElementById("importStockForm");
                form.addEventListener("submit", function (e) {
                    e.preventDefault();

                    Swal.fire({
                        title: 'Are you sure you want to import this stock batch?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#198754',
                        cancelButtonColor: '#6c757d',
                        confirmButtonText: 'Yes, proceed',
                        cancelButtonText: 'Cancel'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            form.submit();
                        }
                    });
                });
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>