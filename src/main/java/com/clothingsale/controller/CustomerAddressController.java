package com.clothingsale.controller;

import com.clothingsale.model.UserAddress;
import com.clothingsale.service.CustomerOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/customer/address")
public class CustomerAddressController extends HttpServlet {

    private final CustomerOrderService service
            = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        int userId = (Integer) session.getAttribute("authUserId");

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {

            case "delete":
                deleteAddress(request, response, userId);
                break;

            case "setDefault":
                setDefaultAddress(request, response, userId);
                break;

            default:
                listAddresses(request, response, userId);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        int userId = (Integer) session.getAttribute("authUserId");

        String action = request.getParameter("action");

        if ("insert".equals(action)) {

            insertAddress(request, response, userId);

        } else if ("update".equals(action)) {

            updateAddress(request, response, userId);

        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/address");
        }
    }

    private void listAddresses(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws ServletException, IOException {

        List<UserAddress> addresses
                = service.getAddressesByUserId(userId);

        request.setAttribute("addresses", addresses);

        String from = request.getParameter("from");

        request.setAttribute("from", from);

        request.getRequestDispatcher(
                "/view/customer/CustomerManageAddress.jsp")
                .forward(request, response);
    }

    private void editAddress(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws ServletException, IOException {

        int id = Integer.parseInt(
                request.getParameter("id"));

        UserAddress address
                = service.getAddressById(id);

        if (address == null
                || address.getUserId() != userId) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/address");

            return;
        }

        request.setAttribute("address", address);

        request.getRequestDispatcher(
                "/view/customer/CustomerManageAddress.jsp")
                .forward(request, response);
    }

    private void insertAddress(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws IOException {
        System.out.println("INSERT ADDRESS CALLED");
        UserAddress address = new UserAddress();

        address.setUserId(userId);
        address.setRecipientName(
                request.getParameter("recipientName"));

        address.setRecipientPhone(
                request.getParameter("recipientPhone"));

        address.setWardId(
                request.getParameter("wardId"));

        address.setAddressDetail(
                request.getParameter("addressDetail"));

        address.setDefault(
                request.getParameter("isDefault")
                != null);

        service.addAddress(address);

        response.sendRedirect(
                request.getContextPath()
                + "/customer/address");
    }

    private void updateAddress(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws IOException {

        int id = Integer.parseInt(
                request.getParameter("id"));

        UserAddress oldAddress
                = service.getAddressById(id);

        if (oldAddress == null
                || oldAddress.getUserId() != userId) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/address");

            return;
        }

        UserAddress address = new UserAddress();

        address.setId(id);
        address.setUserId(userId);

        address.setRecipientName(
                request.getParameter("recipientName"));

        address.setRecipientPhone(
                request.getParameter("recipientPhone"));

        address.setWardId(
                request.getParameter("wardId"));

        address.setAddressDetail(
                request.getParameter("addressDetail"));

        address.setDefault(
                request.getParameter("isDefault")
                != null);

        service.updateAddress(address);

        response.sendRedirect(
                request.getContextPath()
                + "/customer/address");
    }

    private void deleteAddress(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws IOException {

        int id = Integer.parseInt(
                request.getParameter("id"));

        UserAddress address
                = service.getAddressById(id);

        if (address != null
                && address.getUserId() == userId) {

            service.deleteAddress(id, id);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/customer/address");
    }

    private void setDefaultAddress(HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws IOException {

        int id = Integer.parseInt(
                request.getParameter("id"));

        UserAddress address
                = service.getAddressById(id);

        if (address != null
                && address.getUserId() == userId) {

            service.setDefaultAddress(
                    userId,
                    id);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/customer/address");
    }
}
