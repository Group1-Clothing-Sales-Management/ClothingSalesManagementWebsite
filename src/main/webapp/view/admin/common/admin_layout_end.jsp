</div>
</div>
<script src="${pageContext.request.contextPath}/assets/notification-ui.js"></script>
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

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function () {
                setupAdminSidebar();
            });
        } else {
            setupAdminSidebar();
        }
    })();
</script>
