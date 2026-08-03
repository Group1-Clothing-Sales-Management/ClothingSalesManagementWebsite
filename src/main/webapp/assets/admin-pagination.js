(function () {
    "use strict";

    var DEFAULT_PAGE_SIZE = 10;

    function getRows(table) {
        if (!table.tBodies.length) {
            return [];
        }

        return Array.from(table.tBodies[0].rows).filter(function (row) {
            return row.dataset.paginationEmpty !== "true"
                    && row.cells.length > 0;
        });
    }

    function isVisibleAfterFilter(row) {
        return !row.classList.contains("d-none")
                && row.dataset.paginationExclude !== "true";
    }

    function addPageButton(controls, label, page, disabled, active, onClick) {
        var item = document.createElement("li");
        item.className = "page-item"
                + (disabled ? " disabled" : "")
                + (active ? " active" : "");

        var link = document.createElement("a");
        link.className = "page-link";
        link.href = "#";
        link.textContent = label;
        link.setAttribute("aria-label", label === "‹"
                ? "Previous page"
                : label === "›" ? "Next page" : "Page " + label);

        link.addEventListener("click", function (event) {
            event.preventDefault();
            if (!disabled) {
                onClick(page);
            }
        });

        item.appendChild(link);
        controls.appendChild(item);
    }

    function addEllipsis(controls) {
        var item = document.createElement("li");
        item.className = "page-item disabled";
        var span = document.createElement("span");
        span.className = "page-link";
        span.textContent = "…";
        item.appendChild(span);
        controls.appendChild(item);
    }

    function renderControls(controls, currentPage, totalPages, onClick) {
        controls.innerHTML = "";
        addPageButton(controls, "‹", currentPage - 1, currentPage === 1,
                false, onClick);

        var pages = [];
        if (totalPages <= 7) {
            for (var page = 1; page <= totalPages; page++) {
                pages.push(page);
            }
        } else {
            pages = [1];
            if (currentPage > 4) {
                pages.push("ellipsis");
            }
            var start = Math.max(2, currentPage - 1);
            var end = Math.min(totalPages - 1, currentPage + 1);
            for (var middle = start; middle <= end; middle++) {
                pages.push(middle);
            }
            if (currentPage < totalPages - 3) {
                pages.push("ellipsis");
            }
            pages.push(totalPages);
        }

        pages.forEach(function (page) {
            if (page === "ellipsis") {
                addEllipsis(controls);
            } else {
                addPageButton(controls, String(page), page, false,
                        page === currentPage, onClick);
            }
        });

        addPageButton(controls, "›", currentPage + 1,
                currentPage === totalPages, false, onClick);
    }

    function initTable(table) {
        if (table.dataset.paginationInitialized === "true"
                || !table.tBodies.length) {
            return;
        }

        table.dataset.paginationInitialized = "true";
        var pageSize = parseInt(
                table.dataset.paginationPageSize || DEFAULT_PAGE_SIZE,
                10
        );
        if (!Number.isFinite(pageSize) || pageSize < 1) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        var wrapper = table.closest(".table-responsive") || table;
        var existingInfo = table.closest(".card")
                ? table.closest(".card").querySelector("#paginationInfo")
                : null;
        var existingControls = table.closest(".card")
                ? table.closest(".card").querySelector("#paginationControls")
                : null;
        var pagination;
        var info;
        var controls;

        if (existingInfo && existingControls) {
            pagination = existingInfo.closest(".card-footer")
                    || existingInfo.parentElement;
            info = existingInfo;
            controls = existingControls;
        } else {
            pagination = document.createElement("div");
            pagination.className = "client-pagination d-flex justify-content-between"
                    + " align-items-center flex-wrap gap-2 px-3 py-3";
            pagination.innerHTML = "<small class=\"text-muted pagination-info\"></small>"
                    + "<nav aria-label=\"Table pages\"><ul class=\"pagination"
                    + " pagination-sm mb-0 pagination-controls\"></ul></nav>";
            wrapper.insertAdjacentElement("afterend", pagination);
            info = pagination.querySelector(".pagination-info");
            controls = pagination.querySelector(".pagination-controls");
        }
        var currentPage = 1;

        function render() {
            var rows = getRows(table);
            var visibleRows = rows.filter(isVisibleAfterFilter);
            var totalPages = Math.max(1, Math.ceil(visibleRows.length / pageSize));
            currentPage = Math.min(Math.max(currentPage, 1), totalPages);

            rows.forEach(function (row) {
                row.style.display = "none";
            });

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(start + pageSize, visibleRows.length);
            visibleRows.slice(start, end).forEach(function (row) {
                row.style.display = "";
            });

            pagination.classList.toggle("d-none", visibleRows.length <= pageSize);
            if (visibleRows.length > pageSize) {
                info.textContent = "Showing " + (start + 1) + "-" + end
                        + " of " + visibleRows.length + " "
                        + (table.dataset.paginationLabel || "items");
                renderControls(controls, currentPage, totalPages, function (page) {
                    currentPage = page;
                    render();
                });
            }
        }

        var observer = new MutationObserver(function (mutations) {
            var shouldRender = mutations.some(function (mutation) {
                return mutation.type === "childList"
                        || mutation.attributeName === "class";
            });
            if (shouldRender) {
                render();
            }
        });
        observer.observe(table.tBodies[0], {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ["class"]
        });

        render();
    }

    function initContainer(container) {
        if (container.dataset.paginationInitialized === "true") {
            return;
        }

        var selector = container.dataset.paginationItemSelector
                || ":scope > *";
        var controlsHost = document.querySelector(
                '[data-pagination-controls-for="'
                + container.id + '"]'
        );
        if (!controlsHost) {
            return;
        }

        container.dataset.paginationInitialized = "true";
        var pageSize = parseInt(
                container.dataset.paginationPageSize || DEFAULT_PAGE_SIZE,
                10
        );
        if (!Number.isFinite(pageSize) || pageSize < 1) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        var info = controlsHost.querySelector(".pagination-info");
        var controls = controlsHost.querySelector(".pagination-controls");
        var currentPage = 1;

        function render() {
            var items = Array.from(container.querySelectorAll(selector));
            var totalPages = Math.max(1, Math.ceil(items.length / pageSize));
            currentPage = Math.min(Math.max(currentPage, 1), totalPages);
            items.forEach(function (item) {
                item.style.display = "none";
            });

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(start + pageSize, items.length);
            items.slice(start, end).forEach(function (item) {
                item.style.display = "";
            });

            controlsHost.classList.toggle("d-none", items.length <= pageSize);
            if (items.length > pageSize) {
                info.textContent = "Showing " + (start + 1) + "-" + end
                        + " of " + items.length + " feedback items";
                renderControls(controls, currentPage, totalPages, function (page) {
                    currentPage = page;
                    render();
                });
            }
        }

        var observer = new MutationObserver(render);
        observer.observe(container, { childList: true, subtree: true });
        render();
    }

    function init() {
        var tables = Array.from(document.querySelectorAll(
                "table[data-client-pagination]"
        ));

        // The returns list is rendered in a legacy compact JSP line, so its
        // marker is inferred from its detail links.
        document.querySelectorAll("table.table-hover").forEach(function (table) {
            if (table.querySelector('a[href*="action=view"]')
                    && tables.indexOf(table) === -1) {
                tables.push(table);
            }
        });

        document.querySelectorAll("table").forEach(function (table) {
            var heading = table.tHead ? table.tHead.textContent : "";
            if (/Returned quantity/i.test(heading)
                    && tables.indexOf(table) === -1) {
                tables.push(table);
            }
        });

        tables.forEach(initTable);
        document.querySelectorAll("[data-client-pagination-container]")
                .forEach(initContainer);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
}());
