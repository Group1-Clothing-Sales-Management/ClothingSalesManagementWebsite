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
            var collapseButton = shell.querySelector('[data-admin-sidebar-collapse]');
            var collapsePreference = false;
            var collapseStorageKey = 'clothingSale.adminSidebarCollapsed';

            try {
                collapsePreference = window.localStorage.getItem(collapseStorageKey) === 'true';
            } catch (ignored) {
                collapsePreference = false;
            }

            function setSidebarOpen(isOpen) {
                shell.classList.toggle('is-sidebar-open', isOpen);
                document.body.classList.toggle('admin-sidebar-open', isOpen);
                if (toggle) {
                    toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
                    toggle.setAttribute('aria-label', isOpen ? 'Close navigation' : 'Open navigation');
                }
            }

            function renderDesktopCollapse() {
                var isCollapsed = window.innerWidth >= 768 && collapsePreference;
                shell.classList.toggle('is-sidebar-collapsed', isCollapsed);

                if (collapseButton) {
                    collapseButton.setAttribute('aria-expanded', isCollapsed ? 'false' : 'true');
                    collapseButton.setAttribute(
                        'aria-label',
                        isCollapsed ? 'Expand navigation' : 'Collapse navigation'
                    );
                    collapseButton.setAttribute(
                        'title',
                        isCollapsed ? 'Expand navigation' : 'Collapse navigation'
                    );
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

            if (collapseButton) {
                collapseButton.addEventListener('click', function () {
                    collapsePreference = !collapsePreference;
                    try {
                        window.localStorage.setItem(collapseStorageKey, String(collapsePreference));
                    } catch (ignored) {
                        // The layout still works when storage is unavailable.
                    }
                    renderDesktopCollapse();
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
                renderDesktopCollapse();
            });

            renderDesktopCollapse();
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
