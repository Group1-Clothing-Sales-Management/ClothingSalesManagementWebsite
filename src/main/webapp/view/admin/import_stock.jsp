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
            /* Cấu trúc wrapper đồng bộ giúp sidebar không bị vỡ */
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

        <div class="wrapper">
            <%-- Sidebar Component chuẩn cấu trúc --%>
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeTab" value="inventory" />
            </jsp:include>

            <div class="main-content">
                <div class="container-fluid" style="max-w: 960px; margin: 0 auto;">

                    <div class="mb-4">
                        <a href="${pageContext.request.contextPath}/admin/inventory?action=list" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-arrow-left me-2"></i>Back to Inventory List
                        </a>
                    </div>

                    <%-- Status Notifications Banner --%>
                    <c:if test="${param.status eq 'error'}">
                        <div class="alert alert-danger role="alert">
                            <strong>System Error!</strong> Transaction failed to commit to database. Please try again.
                        </div>
                    </c:if>
                    <c:if test="${param.status eq 'invalid'}">
                        <div class="alert alert-warning" role="alert">
                            <strong>Invalid Input!</strong> Data format parsing failed. Check numeric parameters.
                        </div>
                    </c:if>

                    <div class="card shadow-sm border-0 p-4 bg-white rounded-3">
                        <div class="border-b pb-3 mb-4">
                            <h2 class="h5 fw-bold text-dark mb-1">
                                <i class="fa-solid fa-square-plus me-2 text-success"></i>New Physical Stock Import Inflow
                            </h2>
                            <p class="text-muted small mb-0">Search and register structured inventory items to track FIFO batch logging constraints.</p>
                        </div>

                        <form id="importStockForm" action="${pageContext.request.contextPath}/admin/inventory" method="POST" autocomplete="off">
                            <input type="hidden" name="action" value="IMPORT" />
                            <input type="hidden" id="hiddenVariantId" name="variantId" />

                            <div class="position-relative mb-4">
                                <label class="form-label fw-bold text-secondary">Search Clothing Variant Item *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                    <input type="text" id="variantSearchInput" required
                                           placeholder="Type to filter product variant by name, SKU, size, or color..."
                                           class="form-control py-2">
                                    <button type="button" id="clearSearchBtn" class="btn btn-outline-secondary d-none">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>
                                <div id="searchResults" class="search-results-box d-none custom-scrollbar"></div>
                            </div>

                            <div id="contextPricePanel" class="alert alert-info d-none align-items-center mb-4">
                                <i class="fa-solid fa-circle-info me-2"></i>
                                <span><strong>Current Reference:</strong> Cost Price: <span id="refCost" class="fw-bold"></span>$ | Retail Selling Price: <span id="refSale" class="fw-bold"></span>$</span>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-4">
                                    <label class="form-label fw-bold text-secondary">Batch Code *</label>
                                    <input type="text" id="batchCode" name="batchCode" readonly required class="form-control bg-light text-primary fw-bold">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold text-secondary">Inflow Quantity *</label>
                                    <input type="number" name="quantity" min="1" required placeholder="e.g., 100" class="form-control">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold text-secondary">Cost Price ($) *</label>
                                    <input type="number" id="costPrice" name="costPrice" step="0.01" min="0" required placeholder="e.g., 15.50" class="form-control">
                                </div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-secondary">New Sale Price ($) *</label>
                                    <input type="number" id="salePrice" name="salePrice" step="0.01" min="0" required placeholder="e.g., 29.99" class="form-control">
                                    <span class="text-muted d-block mt-1" style="font-size: 0.75rem;">Updating this value alters the general storefront listing price index.</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-secondary">Transaction Note</label>
                                    <input type="text" name="note" placeholder="e.g., Import batch from Supplier Alpha" class="form-control">
                                </div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                                <a href="${pageContext.request.contextPath}/admin/inventory?action=list" class="btn btn-outline-secondary px-4">Cancel</a>
                                <button type="submit" class="btn btn-success fw-bold px-4">Confirm & Process Import</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Chuỗi dữ liệu biến thể JSON
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
            ]; // ĐÃ SỬA: Xóa dấu đóng ngoặc vuông thừa lỗi cú pháp ở đây

            document.addEventListener("DOMContentLoaded", function () {
                // 1. Tự động sinh mã Batch Code
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

                // 2. Logic Autocomplete tìm kiếm sản phẩm nâng cao
                const searchInput = document.getElementById("variantSearchInput");
                const hiddenIdInput = document.getElementById("hiddenVariantId");
                const resultsBox = document.getElementById("searchResults");
                const clearBtn = document.getElementById("clearSearchBtn");
                const contextPricePanel = document.getElementById("contextPricePanel");
                const refCost = document.getElementById("refCost");
                const refSale = document.getElementById("refSale");
                const costPriceInput = document.getElementById("costPrice");
                const salePriceInput = document.getElementById("salePrice");

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
                            btn.innerHTML = `<i class="fa-solid fa-shirt me-2 text-secondary"></i> \${item.displayName} <span class="badge bg-light text-secondary font-mono ms-1">\${item.sku}</span>`;

                            btn.addEventListener("click", function () {
                                searchInput.value = item.displayName + " (" + item.sku + ")";
                                hiddenIdInput.value = item.id;
                                resultsBox.classList.add("d-none");

                                if (refCost)
                                    refCost.innerText = item.oldCost;
                                if (refSale)
                                    refSale.innerText = item.oldSale;
                                if (costPriceInput)
                                    costPriceInput.value = item.oldCost;
                                if (salePriceInput)
                                    salePriceInput.value = item.oldSale;
                                if (contextPricePanel)
                                    contextPricePanel.classList.replace("d-none", "d-flex");
                            });
                            resultsBox.appendChild(btn);
                        });
                        resultsBox.classList.remove("d-none");
                    } else {
                        resultsBox.innerHTML = `<div class="p-3 text-center text-muted small">No matching variant configurations found</div>`;
                        resultsBox.classList.remove("d-none");
                    }
                });

                if (clearBtn) {
                    clearBtn.addEventListener("click", function () {
                        searchInput.value = "";
                        hiddenIdInput.value = "";
                        resultsBox.innerHTML = "";
                        resultsBox.classList.add("d-none");
                        this.classList.add("d-none");
                        if (contextPricePanel)
                            contextPricePanel.classList.replace("d-flex", "d-none");
                    });
                }

                document.addEventListener("click", function (e) {
                    if (e.target !== searchInput && e.target !== resultsBox) {
                        resultsBox.classList.add("d-none");
                    }
                });

                // 3. Logic Validate dữ liệu trước khi gửi Form
                const form = document.getElementById("importStockForm");
                if (form) {
                    form.addEventListener("submit", function (e) {
                        const selectedId = hiddenIdInput.value;
                        const costVal = parseFloat(costPriceInput.value);
                        const saleVal = parseFloat(salePriceInput.value);

                        if (!selectedId) {
                            e.preventDefault();
                            Swal.fire({
                                title: 'Product Variant Required!',
                                text: 'Please search and select a specific configuration from the dynamic recommendation dropdown list.',
                                icon: 'warning',
                                confirmButtonColor: '#2563eb'
                            });
                            return;
                        }

                        if (saleVal < costVal) {
                            e.preventDefault();
                            Swal.fire({
                                title: 'Pricing Conflict Detected!',
                                text: 'The newly specified Selling Price cannot fall below the base Stock Cost Price to maintain margin profitability.',
                                icon: 'error',
                                confirmButtonColor: '#dc2626'
                            });
                            return;
                        }
                    });
                }
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>