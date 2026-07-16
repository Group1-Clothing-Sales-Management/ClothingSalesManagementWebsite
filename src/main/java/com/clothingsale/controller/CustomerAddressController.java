package com.clothingsale.controller;

import com.clothingsale.model.UserAddress;
import com.clothingsale.model.Province;
import com.clothingsale.model.District;
import com.clothingsale.model.Ward;

import java.io.PrintWriter;
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
 
        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {

            case "provinces":
                getProvinces(response);
                return;

            case "districts":
                getDistricts(request, response);
                return;

            case "wards":
                getWards(request, response);
                return;
        }

        Integer userId = getCustomerUserId(request, response);

        if (userId == null) {
            return;
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
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer userId = getCustomerUserId(request, response);
        if (userId == null) {
            return;
        }

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

        request.setAttribute("provinces", service.getAllProvinces());

        String from = request.getParameter("from");

        request.setAttribute("from", from);

        request.getRequestDispatcher(
                "/view/customer/customer_manage_address.jsp")
                .forward(request, response);
    }

    private Integer getCustomerUserId(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        Object userIdObj = session == null
                ? null
                : session.getAttribute("authUserId");
        String roleName = session == null
                ? null
                : (String) session.getAttribute("authRoleName");

        if (!(userIdObj instanceof Integer)
                || !"CUSTOMER".equalsIgnoreCase(roleName)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login?error=unauthorized");

            return null;
        }

        return (Integer) userIdObj;
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
                "/view/customer/customer_manage_address.jsp")
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

        String from = request.getParameter("from");

        String redirect = request.getContextPath() + "/customer/address";

        if ("checkout".equals(from)) {
            redirect += "?from=checkout";
        }

        response.sendRedirect(redirect);
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

        String from = request.getParameter("from");

        String redirect = request.getContextPath() + "/customer/address";

        if ("checkout".equals(from)) {
            redirect += "?from=checkout";
        }

        response.sendRedirect(redirect);
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

            service.deleteAddress(userId, id);
        }

        String from = request.getParameter("from");

        String redirect = request.getContextPath() + "/customer/address";

        if ("checkout".equals(from)) {
            redirect += "?from=checkout";
        }

        response.sendRedirect(redirect);
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

        String from = request.getParameter("from");

        String redirect = request.getContextPath() + "/customer/address";

        if ("checkout".equals(from)) {
            redirect += "?from=checkout";
        }

        response.sendRedirect(redirect);
    }

    private void getProvinces(HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        List<Province> list = service.getAllProvinces();

        PrintWriter out = response.getWriter();

        out.print("[");

        for (int i = 0; i < list.size(); i++) {

            Province p = list.get(i);

            out.print("{");

            out.print("\"id\":\"" + p.getId() + "\",");

            out.print("\"name\":\""
                    + p.getProvinceName().replace("\"", "\\\"")
                    + "\"");

            out.print("}");

            if (i < list.size() - 1) {
                out.print(",");
            }
        }

        out.print("]");
        out.flush();
        out.close();
    }

    private void getDistricts(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        String provinceId = request.getParameter("provinceId");

        List<District> list
                = service.getDistrictsByProvince(provinceId);

        PrintWriter out = response.getWriter();

        out.print("[");

        for (int i = 0; i < list.size(); i++) {

            District d = list.get(i);

            out.print("{");

            out.print("\"id\":\"" + d.getId() + "\",");

            out.print("\"name\":\""
                    + d.getDistrictName().replace("\"", "\\\"")
                    + "\"");

            out.print("}");

            if (i < list.size() - 1) {
                out.print(",");
            }
        }

        out.print("]");
        out.flush();
        out.close();
    }

    private void getWards(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        String districtId
                = request.getParameter("districtId");

        List<Ward> list
                = service.getWardsByDistrict(districtId);

        PrintWriter out = response.getWriter();

        out.print("[");

        for (int i = 0; i < list.size(); i++) {

            Ward w = list.get(i);

            out.print("{");

            out.print("\"id\":\"" + w.getId() + "\",");

            out.print("\"name\":\""
                    + w.getWardName().replace("\"", "\\\"")
                    + "\"");

            out.print("}");

            if (i < list.size() - 1) {
                out.print(",");
            }
        }

        out.print("]");
        out.flush();
        out.close();
    }
}
