    </div>
</div>
<div id="adminToastStack" class="admin-toast-stack" aria-live="polite" aria-atomic="true"></div>
<script>
    (function () {
        function setupAdminSidebar() {
            var shell = document.getElementById('adminShell');
            if (!shell) {
                return;
            }

            var toggle = shell.querySelector('[data-admin-sidebar-toggle]');
            var closeButton = shell.querySelector('[data-admin-sidebar-close]');

            function setSidebarOpen(isOpen) {
                shell.classList.toggle('is-sidebar-open', isOpen);
                document.body.classList.toggle('admin-sidebar-open', isOpen);
                if (toggle) {
                    toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
                    toggle.setAttribute('aria-label', isOpen ? 'Close navigation' : 'Open navigation');
                }
            }

            if (toggle) {
                toggle.addEventListener('click', function () {
                    setSidebarOpen(!shell.classList.contains('is-sidebar-open'));
                });
            }

            if (closeButton) {
                closeButton.addEventListener('click', function () {
                    setSidebarOpen(false);
                });
            }

            shell.querySelectorAll('.sidebar-nav a').forEach(function (link) {
                link.addEventListener('click', function () {
                    setSidebarOpen(false);
                });
            });

            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    setSidebarOpen(false);
                }
            });

            window.addEventListener('resize', function () {
                if (window.innerWidth >= 768) {
                    setSidebarOpen(false);
                }
            });
        }

        function getToastStack() {
            var stack = document.getElementById('adminToastStack');
            if (!stack) {
                stack = document.createElement('div');
                stack.id = 'adminToastStack';
                stack.className = 'admin-toast-stack';
                stack.setAttribute('aria-live', 'polite');
                stack.setAttribute('aria-atomic', 'true');
                document.body.appendChild(stack);
            }
            return stack;
        }

        function normalizeType(type) {
            var value = (type || 'info').toString().toLowerCase();
            if (value !== 'success' && value !== 'error' && value !== 'warning') {
                return 'info';
            }
            return value;
        }

        function typeLabel(type) {
            switch (type) {
                case 'success':
                    return 'Success';
                case 'error':
                    return 'Error';
                case 'warning':
                    return 'Warning';
                default:
                    return 'Info';
            }
        }

        function typeIcon(type) {
            switch (type) {
                case 'success':
                    return 'v';
                case 'error':
                    return 'x';
                case 'warning':
                    return '!';
                default:
                    return 'i';
            }
        }

        function removeToast(toast) {
            if (!toast || !toast.parentNode) {
                return;
            }
            toast.style.animation = 'admin-toast-in 160ms ease-out reverse both';
            window.setTimeout(function () {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 160);
        }

        function showAdminToast(message, type) {
            if (!message) {
                return null;
            }

            var normalizedType = normalizeType(type);
            var stack = getToastStack();
            var toast = document.createElement('div');
            toast.className = 'admin-toast admin-toast--' + normalizedType;

            var icon = document.createElement('div');
            icon.className = 'admin-toast__icon';
            icon.textContent = typeIcon(normalizedType);

            var content = document.createElement('div');
            content.className = 'admin-toast__content';

            var title = document.createElement('div');
            title.className = 'admin-toast__title';
            title.textContent = typeLabel(normalizedType);

            var body = document.createElement('div');
            body.className = 'admin-toast__message';
            body.textContent = message;

            content.appendChild(title);
            content.appendChild(body);

            var close = document.createElement('button');
            close.type = 'button';
            close.className = 'admin-toast__close';
            close.setAttribute('aria-label', 'Dismiss notification');
            close.textContent = 'x';
            close.addEventListener('click', function () {
                window.clearTimeout(timerId);
                removeToast(toast);
            });

            toast.appendChild(icon);
            toast.appendChild(content);
            toast.appendChild(close);
            stack.appendChild(toast);

            var timerId = window.setTimeout(function () {
                removeToast(toast);
            }, 3200);

            toast.addEventListener('mouseenter', function () {
                window.clearTimeout(timerId);
            });

            toast.addEventListener('mouseleave', function () {
                timerId = window.setTimeout(function () {
                    removeToast(toast);
                }, 1200);
            });

            return toast;
        }

        function processAdminToastNodes() {
            document.querySelectorAll('[data-admin-toast]').forEach(function (node) {
                var message = (node.textContent || '').trim();
                var type = node.getAttribute('data-admin-toast-type') || 'info';
                if (message) {
                    showAdminToast(message, type);
                }
                node.parentNode && node.parentNode.removeChild(node);
            });
        }

        window.showAdminToast = showAdminToast;

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function () {
                setupAdminSidebar();
                processAdminToastNodes();
            });
        } else {
            setupAdminSidebar();
            processAdminToastNodes();
        }
    })();
</script>
