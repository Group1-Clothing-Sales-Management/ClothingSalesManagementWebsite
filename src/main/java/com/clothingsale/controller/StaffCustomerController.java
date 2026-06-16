package com.clothingsale.controller;

import com.clothingsale.model.StaffCustomer;
import com.clothingsale.service.StaffCustomerService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/staff/customers")
public class StaffCustomerController extends HttpServlet {

    private final StaffCustomerService service = new StaffCustomerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isStaffLoggedIn(req, resp)) {
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                req.setAttribute("pageMode", "add");
                req.getRequestDispatcher("/StaffManageCustomers.jsp").forward(req, resp);
                break;

            case "edit":
                handleShowEdit(req, resp);
                break;

            default: // "list" or search
                handleList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isStaffLoggedIn(req, resp)) {
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("add".equals(action)) {
            handleAdd(req, resp);
        } else if ("update".equals(action)) {
            handleUpdate(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/staff/customers");
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = req.getParameter("keyword");
        List<StaffCustomer> customers = service.getCustomers(keyword);

        req.setAttribute("customers", customers);
        req.setAttribute("keyword", keyword);
        req.setAttribute("pageMode", "list");
        req.getRequestDispatcher("/StaffManageCustomers.jsp").forward(req, resp);
    }

    private void handleShowEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        StaffCustomer customer = (id > 0) ? service.getCustomerById(id) : null;

        if (customer == null) {
            req.setAttribute("errorMsg", "Customer not found.");
            handleList(req, resp);
            return;
        }

        req.setAttribute("customer", customer);
        req.setAttribute("pageMode", "edit");
        req.getRequestDispatcher("/StaffManageCustomers.jsp").forward(req, resp);
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        StaffCustomer c = buildFromRequest(req, 0);
        String password = req.getParameter("password");

        Map<String, String> errors = service.addCustomer(c, password);

        if (errors.isEmpty()) {
            req.getSession().setAttribute("successMsg", "Customer added successfully.");
            resp.sendRedirect(req.getContextPath() + "/staff/customers");
        } else {
            req.setAttribute("errors", errors);
            req.setAttribute("formData", c);
            req.setAttribute("pageMode", "add");
            req.getRequestDispatcher("/StaffManageCustomers.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        StaffCustomer c = buildFromRequest(req, id);

        Map<String, String> errors = service.updateCustomer(c);

        if (errors.isEmpty()) {
            req.getSession().setAttribute("successMsg", "Customer updated successfully.");
            resp.sendRedirect(req.getContextPath() + "/staff/customers");
        } else {
            req.setAttribute("errors", errors);
            req.setAttribute("customer", c);
            req.setAttribute("pageMode", "edit");
            req.getRequestDispatcher("/StaffManageCustomers.jsp").forward(req, resp);
        }
    }

    private StaffCustomer buildFromRequest(HttpServletRequest req, int id) {
        StaffCustomer c = new StaffCustomer();
        c.setId(id);
        c.setUsername(req.getParameter("username"));
        c.setFullName(req.getParameter("fullName"));
        c.setEmail(req.getParameter("email"));
        c.setPhone(req.getParameter("phone"));
        c.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "ACTIVE");
        return c;
    }

    private boolean isStaffLoggedIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/login?error=unauthorized");
            return false;
        }
        Object role = session.getAttribute("authRoleName");
        if (role == null
                || (!"ADMIN".equalsIgnoreCase(role.toString()) && !"STAFF".equalsIgnoreCase(role.toString()))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return false;
        }
        return true;
    }

    private int parseId(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }
}
