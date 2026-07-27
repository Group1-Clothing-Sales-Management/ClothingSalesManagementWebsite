(function (window, document) {
    "use strict";

    var timers = new WeakMap();
    var typeMeta = {
        success: { label: "Success", icon: "fa-solid fa-check" },
        error: { label: "Error", icon: "fa-solid fa-xmark" },
        warning: { label: "Warning", icon: "fa-solid fa-exclamation" },
        info: { label: "Info", icon: "fa-solid fa-circle-info" }
    };

    function normalizeType(type) {
        var value = String(type || "info").toLowerCase();
        return typeMeta[value] ? value : "info";
    }

    function getToastStack() {
        var stack = document.getElementById("appToastStack");
        if (!stack) {
            stack = document.createElement("div");
            stack.id = "appToastStack";
            stack.className = "app-toast-stack";
            stack.setAttribute("aria-live", "polite");
            stack.setAttribute("aria-atomic", "false");
            document.body.appendChild(stack);
        }
        return stack;
    }

    function removeToast(toast) {
        if (!toast || !toast.parentNode || toast.classList.contains("is-removing")) {
            return;
        }
        toast.classList.add("is-removing");
        toast.style.animation = "app-toast-out .18s ease-in both";
        window.setTimeout(function () {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 180);
    }

    function showAppToast(message, type, options) {
        message = String(message || "").trim();
        if (!message) {
            return null;
        }

        options = options || {};
        var normalizedType = normalizeType(type);
        var meta = typeMeta[normalizedType];
        var toast = document.createElement("div");
        toast.className = "app-toast app-toast--" + normalizedType;
        toast.setAttribute("role", normalizedType === "error" ? "alert" : "status");

        var icon = document.createElement("span");
        icon.className = "app-toast__icon";
        var iconElement = document.createElement("i");
        iconElement.className = meta.icon;
        iconElement.setAttribute("aria-hidden", "true");
        icon.appendChild(iconElement);

        var content = document.createElement("div");
        content.className = "app-toast__content";
        var title = document.createElement("div");
        title.className = "app-toast__title";
        title.textContent = options.title || meta.label;
        var body = document.createElement("div");
        body.className = "app-toast__message";
        body.textContent = message;
        content.appendChild(title);
        content.appendChild(body);

        var close = document.createElement("button");
        close.type = "button";
        close.className = "app-toast__close";
        close.setAttribute("aria-label", "Dismiss notification");
        close.innerHTML = '<i class="fa-solid fa-xmark" aria-hidden="true"></i>';
        close.addEventListener("click", function () {
            window.clearTimeout(timers.get(toast));
            removeToast(toast);
        });

        toast.appendChild(icon);
        toast.appendChild(content);
        toast.appendChild(close);
        getToastStack().appendChild(toast);

        var delay = Number(options.duration || 4200);
        var timer = window.setTimeout(function () { removeToast(toast); }, delay);
        timers.set(toast, timer);
        toast.addEventListener("mouseenter", function () {
            window.clearTimeout(timers.get(toast));
        });
        toast.addEventListener("mouseleave", function () {
            timers.set(toast, window.setTimeout(function () { removeToast(toast); }, 1400));
        });
        return toast;
    }

    function getConfirmDialog() {
        var backdrop = document.getElementById("appConfirmBackdrop");
        if (backdrop) {
            return backdrop;
        }

        backdrop = document.createElement("div");
        backdrop.id = "appConfirmBackdrop";
        backdrop.className = "app-confirm-backdrop";
        backdrop.hidden = true;
        backdrop.innerHTML =
            '<div class="app-confirm-dialog" role="dialog" aria-modal="true" aria-labelledby="appConfirmTitle" aria-describedby="appConfirmMessage">'
            + '<div class="app-confirm-body"><div class="d-flex align-items-start gap-3">'
            + '<span class="app-confirm-icon"><i class="fa-solid fa-circle-question" aria-hidden="true"></i></span>'
            + '<div class="flex-grow-1"><h2 class="app-confirm-title" id="appConfirmTitle"></h2>'
            + '<p class="app-confirm-message" id="appConfirmMessage"></p></div>'
            + '<button type="button" class="app-confirm-close" aria-label="Close"></button></div></div>'
            + '<div class="app-confirm-actions"><button type="button" class="app-confirm-cancel">Cancel</button>'
            + '<button type="button" class="app-confirm-submit">Continue</button></div></div>';
        document.body.appendChild(backdrop);
        return backdrop;
    }

    function confirmAppAction(message, options) {
        options = options || {};
        var backdrop = getConfirmDialog();
        var dialog = backdrop.querySelector(".app-confirm-dialog");
        var title = backdrop.querySelector(".app-confirm-title");
        var body = backdrop.querySelector(".app-confirm-message");
        var submit = backdrop.querySelector(".app-confirm-submit");
        var cancel = backdrop.querySelector(".app-confirm-cancel");
        var close = backdrop.querySelector(".app-confirm-close");
        var previousFocus = document.activeElement;

        title.textContent = options.title || "Please confirm";
        body.textContent = message || "Are you sure you want to continue?";
        submit.textContent = options.confirmLabel || "Continue";
        submit.classList.toggle("is-danger", options.danger === true);
        backdrop.hidden = false;
        document.body.classList.add("app-confirm-open");
        window.requestAnimationFrame(function () { backdrop.classList.add("is-open"); });

        return new Promise(function (resolve) {
            var settled = false;
            function finish(value) {
                if (settled) return;
                settled = true;
                backdrop.classList.remove("is-open");
                document.body.classList.remove("app-confirm-open");
                window.setTimeout(function () { backdrop.hidden = true; }, 180);
                if (previousFocus && typeof previousFocus.focus === "function") previousFocus.focus();
                resolve(value);
            }
            submit.onclick = function () { finish(true); };
            cancel.onclick = function () { finish(false); };
            close.onclick = function () { finish(false); };
            backdrop.onclick = function (event) { if (event.target === backdrop) finish(false); };
            dialog.onkeydown = function (event) {
                if (event.key === "Escape") { event.preventDefault(); finish(false); }
                if (event.key === "Enter" && event.target.tagName !== "TEXTAREA") { event.preventDefault(); finish(true); }
            };
            window.setTimeout(function () { submit.focus(); }, 20);
        });
    }

    function processToastNodes() {
        document.querySelectorAll("[data-app-toast], [data-admin-toast]").forEach(function (node) {
            var message = (node.textContent || "").trim();
            var type = node.getAttribute("data-app-toast-type") || node.getAttribute("data-admin-toast-type") || "info";
            if (message) showAppToast(message, type);
            if (node.parentNode) node.parentNode.removeChild(node);
        });
    }

    function handleConfirmation(event) {
        var target = event.target.closest("[data-confirm]");
        if (!target || target.dataset.confirming === "true") return;
        var message = target.getAttribute("data-confirm");
        if (!message) return;
        event.preventDefault();
        event.stopImmediatePropagation();
        target.dataset.confirming = "true";
        var form = target.tagName === "FORM" ? target : target.form;
        confirmAppAction(message, {
            title: target.getAttribute("data-confirm-title") || "Please confirm",
            confirmLabel: target.getAttribute("data-confirm-label") || "Continue",
            danger: target.getAttribute("data-confirm-danger") === "true"
        }).then(function (confirmed) {
            delete target.dataset.confirming;
            if (!confirmed) return;
            if (form) {
                if (typeof form.requestSubmit === "function") {
                    form.requestSubmit(target.tagName === "BUTTON" ? target : undefined);
                } else {
                    form.submit();
                }
            } else if (target.tagName === "A") {
                window.location.href = target.href;
            }
        });
    }

    window.showAppToast = showAppToast;
    window.showAdminToast = showAppToast;
    window.showCustomerToast = showAppToast;
    window.confirmAppAction = confirmAppAction;

    document.addEventListener("click", handleConfirmation, true);
    document.addEventListener("submit", handleConfirmation, true);
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", processToastNodes);
    } else {
        processToastNodes();
    }
}(window, document));
