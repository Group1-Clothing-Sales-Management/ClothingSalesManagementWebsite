<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Create Stock Import - Admin Area</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet"/>
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
            .form-label {
                font-weight: 600;
                color: #374151;
                margin-bottom: 0.4rem;
            }
            /* Thẩm mỹ cho danh sách tìm kiếm gợi ý */
            .search-results-box {
                position: absolute;
                width: 100%;
                max-height: 250px;
                overflow-y: auto;
                z-index: 1050;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                border-radius: 0 0 6px 6px;
                display: none;
            }
            .search-results-box .list-group-item {
                cursor: pointer;
            }
            .search-results-box .list-group-item:hover {
                background-color: #f0f7ff;
            }
        </style>
    </head>
    <body>
        <div class="wrapper">
            <%-- Sidebar Component --%>
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeTab" value="inventory" />
            </jsp:include>

            <div class="main-content">
                <div class="container-fluid">

                    <div class="mb-4">
                        <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-arrow-left me-2"></i>Back to Stock Logs
                        </a>
                    </div>

                    <%-- Alert Notifications --%>
                    <c:if test="${param.status eq 'error'}">
                        <div class="alert alert-danger"><strong>Error!</strong> Transaction failed to commit database. Please try again.</div>
                    </c:if>
                    <c:if test="${param.status eq 'invalid'}">
                        <div class="alert alert-warning"><strong>Invalid Input!</strong> Please check numeric formats or missing fields.</div>
                    </c:if>

                    <div class="row justify-content-center">
                        <div class="col-xl-8 col-lg-10">
                            <div class="card shadow-sm border-0 rounded-3 p-4">
                                <div class="border-bottom pb-3 mb-4">
                                    <h4 class="fw-bold text-dark mb-1"><i class="fa-solid fa-square-plus me-2 text-success"></i>New Stock Inflow Import</h4>
                                    <p class="text-muted small mb-0">Search and add physical inventory batches to a specific product variant item</p>
                                </div>

                                <form action="${pageContext.request.contextPath}/admin/inventory?action=create" method="POST" autocomplete="off">

                                    <div class="mb-4 position-relative">
                                        <label class="form-label">Search Product Variant Item *</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                            <input type="text" id="variantSearchInput" class="form-control fw-semibold" placeholder="Type product name, color, or size to search..." required />
                                            <button class="btn btn-outline-secondary d-none" type="button" id="clearSearchBtn"><i class="fa-solid fa-xmark"></i></button>
                                        </div>

                                        <input type="hidden" id="hiddenVariantId" name="variantId" required />

                                        <div id="searchResults" class="list-group search-results-box border"></div>
                                        <div class="form-text text-muted">Type to filter. This prevents misclicks when handling a massive catalog.</div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label">Batch Code *</label>
                                        <input type="text" id="batchCode" name="batchCode" class="form-control bg-light fw-bold text-primary" readonly required />
                                        <div class="form-text">This system auto-generates a unique code for tracking FIFO constraints.</div>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label class="form-label">Initial Quantity *</label>
                                            <input type="number" name="quantity" class="form-control" placeholder="e.g., 100" min="1" required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Cost Price ($) *</label>
                                            <input type="number" name="costPrice" class="form-control" placeholder="e.g., 15.50" step="0.01" min="0" required />
                                        </div>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label class="form-label">New Sale Price ($) *</label>
                                            <input type="number" name="salePrice" class="form-control" placeholder="e.g., 29.99" step="0.01" min="0" required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Transaction Note</label>
                                            <input type="text" name="note" class="form-control" placeholder="e.g., Summer batch import from Supplier A" />
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 border-top pt-3 mt-4">
                                        <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-light px-4">Cancel</a>
                                        <button type="submit" class="btn btn-success px-4 fw-bold">Confirm & Process Import</button>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            const variantData = [
            <c:forEach var="v" items="${activeVariants}" varStatus="status">
            {
            id: "${v.id}",
                    name: "${v.attributeDetails.replace('"', '\\"')}"
            }${!status.last ? ',' : ''}
            </c:forEach>
            ];
        </script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // 1. Logic sinh mã Batch Code tự động
                var now = new Date();
                var year = now.getFullYear();
                var month = String(now.getMonth() + 1).padStart(2, '0');
                var day = String(now.getDate()).padStart(2, '0');
                var hours = String(now.getHours()).padStart(2, '0');
                var minutes = String(now.getMinutes()).padStart(2, '0');
                var generatedCode = "BATCH-" + year + month + day + "-" + hours + minutes;
                document.getElementById("batchCode").value = generatedCode;

                // 2. Logic Tìm kiếm Autocomplete tối ưu UI
                const searchInput = document.getElementById("variantSearchInput");
                const hiddenIdInput = document.getElementById("hiddenVariantId");
                const resultsBox = document.getElementById("searchResults");
                const clearBtn = document.getElementById("clearSearchBtn");

                searchInput.addEventListener("input", function () {
                    const keyword = this.value.trim().toLowerCase();
                    resultsBox.innerHTML = "";

                    if (keyword.length === 0) {
                        resultsBox.style.display = "none";
                        clearBtn.classList.add("d-none");
                        return;
                    }

                    clearBtn.classList.remove("d-none");

                    // Tiến hành lọc mảng dữ liệu mà không cần gửi request liên tục lên DB
                    const filtered = variantData.filter(item => item.name.toLowerCase().includes(keyword));

                    if (filtered.length > 0) {
                        filtered.forEach(item => {
                            const btn = document.createElement("button");
                            btn.type = "button";
                            btn.className = "list-group-item list-group-item-action text-start fw-semibold py-2.5";
                            btn.innerHTML = `<i class="fa-solid fa-shirt me-2 text-secondary"></i>\${item.name}`;

                            // Hành động khi người dùng nhấp chọn sản phẩm gợi ý
                            btn.addEventListener("click", function () {
                                searchInput.value = item.name;
                                hiddenIdInput.value = item.id;
                                resultsBox.style.display = "none";
                                searchInput.classList.add("is-valid");
                            });
                            resultsBox.appendChild(btn);
                        });
                        resultsBox.style.display = "block";
                    } else {
                        resultsBox.innerHTML = `<div class="list-group-item text-muted text-center py-3">No matching items found</div>`;
                        resultsBox.style.display = "block";
                    }
                });

                // Xóa nhanh thanh tìm kiếm
                clearBtn.addEventListener("click", function () {
                    searchInput.value = "";
                    hiddenIdInput.value = "";
                    resultsBox.innerHTML = "";
                    resultsBox.style.display = "none";
                    this.classList.add("d-none");
                    searchInput.classList.remove("is-valid");
                });

                // Đóng hộp kết quả khi nhấn chuột ra ngoài
                document.addEventListener("click", function (e) {
                    if (e.target !== searchInput && e.target !== resultsBox) {
                        resultsBox.style.display = "none";
                    }
                });
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>