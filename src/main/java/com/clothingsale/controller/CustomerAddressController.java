package com.clothingsale.controller;

import com.clothingsale.model.UserAddress;
import com.clothingsale.service.AddressApiService;
import com.clothingsale.service.AddressApiService.ResolvedAddress;
import com.clothingsale.service.CustomerOrderService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/customer/address")
public class CustomerAddressController extends HttpServlet {

    private final CustomerOrderService orderService
            = new CustomerOrderService();

    private final AddressApiService addressApiService
            = new AddressApiService();

    private final Gson gson = new Gson();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = trim(request.getParameter("action"));

        if ("provinces".equals(action)) {
            getProvinces(response);
            return;
        }

        if ("wards".equals(action)) {
            getWards(request, response);
            return;
        }

        Integer userId = getCustomerUserId(
                request,
                response
        );

        if (userId == null) {
            return;
        }

        switch (action) {
            case "delete":
                deleteAddress(request, response, userId);
                break;

            case "setDefault":
                setDefaultAddress(
                        request,
                        response,
                        userId
                );
                break;

            default:
                listAddresses(
                        request,
                        response,
                        userId
                );
                break;
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer userId = getCustomerUserId(
                request,
                response
        );

        if (userId == null) {
            return;
        }

        String action = trim(
                request.getParameter("action")
        );

        if ("insert".equals(action)) {
            insertAddress(request, response, userId);
        } else if ("update".equals(action)) {
            updateAddress(request, response, userId);
        } else {
            redirectToAddressPage(request, response);
        }
    }

    private void listAddresses(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws ServletException, IOException {

        List<UserAddress> addresses
                = orderService.getAddressesByUserId(userId);

        request.setAttribute("addresses", addresses);
        request.setAttribute(
                "from",
                request.getParameter("from")
        );

        moveFlashToRequest(
                request,
                "addressSuccess"
        );

        moveFlashToRequest(
                request,
                "addressError"
        );

        request.getRequestDispatcher(
                "/view/customer/customer_manage_address.jsp"
        ).forward(request, response);
    }

    private void insertAddress(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws IOException {

        try {
            UserAddress address
                    = buildAndValidateAddress(
                            request,
                            userId,
                            0
                    );

            boolean success
                    = orderService.addAddress(address);

            if (success) {
                setFlash(
                        request,
                        "addressSuccess",
                        "Address added successfully."
                );
            } else {
                setFlash(
                        request,
                        "addressError",
                        "Could not add address."
                );
            }

        } catch (IllegalArgumentException ex) {
            setFlash(
                    request,
                    "addressError",
                    ex.getMessage()
            );

        } catch (IOException ex) {
            setFlash(
                    request,
                    "addressError",
                    "Address API is temporarily unavailable."
            );
        }

        redirectToAddressPage(request, response);
    }

    private void updateAddress(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws IOException {

        Integer addressId = parsePositiveInteger(
                request.getParameter("id")
        );

        if (addressId == null) {
            setFlash(
                    request,
                    "addressError",
                    "Invalid address ID."
            );

            redirectToAddressPage(request, response);
            return;
        }

        UserAddress currentAddress
                = orderService.getAddressById(addressId);

        if (currentAddress == null
                || currentAddress.getUserId() != userId) {

            setFlash(
                    request,
                    "addressError",
                    "Address not found."
            );

            redirectToAddressPage(request, response);
            return;
        }

        try {
            UserAddress address
                    = buildAndValidateAddress(
                            request,
                            userId,
                            addressId
                    );

            boolean success
                    = orderService.updateAddress(address);

            if (success) {
                setFlash(
                        request,
                        "addressSuccess",
                        "Address updated successfully."
                );
            } else {
                setFlash(
                        request,
                        "addressError",
                        "Could not update address."
                );
            }

        } catch (IllegalArgumentException ex) {
            setFlash(
                    request,
                    "addressError",
                    ex.getMessage()
            );

        } catch (IOException ex) {
            setFlash(
                    request,
                    "addressError",
                    "Address API is temporarily unavailable."
            );
        }

        redirectToAddressPage(request, response);
    }

    private UserAddress buildAndValidateAddress(
            HttpServletRequest request,
            int userId,
            int addressId) throws IOException {

        String recipientName = trim(
                request.getParameter("recipientName")
        );

        String recipientPhone = normalizePhone(
                request.getParameter("recipientPhone")
        );

        String addressDetail = trim(
                request.getParameter("addressDetail")
        );

        String provinceCode = trim(
                request.getParameter("provinceCode")
        );

        String wardCode = trim(
                request.getParameter("wardCode")
        );

        if (recipientName.length() < 2
                || recipientName.length() > 100) {
            throw new IllegalArgumentException(
                    "Recipient name must contain 2 to 100 characters."
            );
        }

        if (!recipientPhone.matches(
                "^0[35789]\\d{8}$")) {
            throw new IllegalArgumentException(
                    "Invalid Vietnamese phone number."
            );
        }

        if (addressDetail.length() < 5
                || addressDetail.length() > 255) {
            throw new IllegalArgumentException(
                    "Address detail must contain 5 to 255 characters."
            );
        }

        ResolvedAddress resolvedAddress;

        try {
            resolvedAddress
                    = addressApiService.resolveAddress(
                            provinceCode,
                            wardCode
                    );
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException(
                    "Please select a valid province and ward."
            );
        }

        UserAddress address = new UserAddress();

        address.setId(addressId);
        address.setUserId(userId);
        address.setRecipientName(recipientName);
        address.setRecipientPhone(recipientPhone);
        address.setAddressDetail(addressDetail);

        address.setDefault(
                request.getParameter("isDefault") != null
        );

        address.setActive(true);

        address.setProvinceCode(
                resolvedAddress.getProvinceCode()
        );

        address.setProvinceName(
                resolvedAddress.getProvinceName()
        );

        address.setWardCode(
                resolvedAddress.getWardCode()
        );

        address.setWardName(
                resolvedAddress.getWardName()
        );

        // Địa chỉ mới không còn cấp huyện
        address.setDistrictCode(null);
        address.setDistrictName(null);

        // Không dùng FK ward_id cũ
        address.setWardId(null);

        return address;
    }

    private void deleteAddress(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws IOException {

        Integer addressId = parsePositiveInteger(
                request.getParameter("id")
        );

        if (addressId == null) {
            setFlash(
                    request,
                    "addressError",
                    "Invalid address ID."
            );

            redirectToAddressPage(request, response);
            return;
        }

        UserAddress address
                = orderService.getAddressById(addressId);

        boolean success = address != null
                && address.getUserId() == userId
                && orderService.deleteAddress(
                        userId,
                        addressId
                );

        if (success) {
            setFlash(
                    request,
                    "addressSuccess",
                    "Address removed successfully."
            );
        } else {
            setFlash(
                    request,
                    "addressError",
                    "Could not remove address."
            );
        }

        redirectToAddressPage(request, response);
    }

    private void setDefaultAddress(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws IOException {

        Integer addressId = parsePositiveInteger(
                request.getParameter("id")
        );

        if (addressId == null) {
            setFlash(
                    request,
                    "addressError",
                    "Invalid address ID."
            );

            redirectToAddressPage(request, response);
            return;
        }

        UserAddress address
                = orderService.getAddressById(addressId);

        boolean success = address != null
                && address.getUserId() == userId
                && orderService.setDefaultAddress(
                        userId,
                        addressId
                );

        if (success) {
            setFlash(
                    request,
                    "addressSuccess",
                    "Default address updated."
            );
        } else {
            setFlash(
                    request,
                    "addressError",
                    "Could not set default address."
            );
        }

        redirectToAddressPage(request, response);
    }

    private void getProvinces(
            HttpServletResponse response)
            throws IOException {

        try {
            writeJson(
                    response,
                    HttpServletResponse.SC_OK,
                    addressApiService.getProvinces()
            );

        } catch (IOException ex) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Address API is unavailable."
            );
        }
    }

    private void getWards(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        try {
            String provinceCode
                    = request.getParameter(
                            "provinceCode"
                    );

            writeJson(
                    response,
                    HttpServletResponse.SC_OK,
                    addressApiService.getWards(
                            provinceCode
                    )
            );

        } catch (IllegalArgumentException ex) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    ex.getMessage()
            );

        } catch (IOException ex) {
            writeErrorJson(
                    response,
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Address API is unavailable."
            );
        }
    }

    private Integer getCustomerUserId(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session
                = request.getSession(false);

        Object userIdObject = session == null
                ? null
                : session.getAttribute("authUserId");

        String roleName = session == null
                ? null
                : (String) session.getAttribute(
                        "authRoleName"
                );

        if (!(userIdObject instanceof Integer)
                || !"CUSTOMER".equalsIgnoreCase(
                        roleName
                )) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/customer/login?error=unauthorized"
            );

            return null;
        }

        return (Integer) userIdObject;
    }

    private void redirectToAddressPage(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String url = request.getContextPath()
                + "/customer/address";

        if ("checkout".equals(
                request.getParameter("from"))) {
            url += "?from=checkout";
        }

        response.sendRedirect(url);
    }

    private void writeJson(
            HttpServletResponse response,
            int status,
            Object object) throws IOException {

        response.setStatus(status);
        response.setContentType(
                "application/json;charset=UTF-8"
        );

        response.getWriter().print(
                gson.toJson(object)
        );
    }

    private void writeErrorJson(
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        Map<String, String> result
                = new HashMap<>();

        result.put("message", message);

        writeJson(response, status, result);
    }

    private void setFlash(
            HttpServletRequest request,
            String name,
            String value) {

        request.getSession().setAttribute(
                name,
                value
        );
    }

    private void moveFlashToRequest(
            HttpServletRequest request,
            String name) {

        HttpSession session
                = request.getSession(false);

        if (session == null) {
            return;
        }

        Object value = session.getAttribute(name);

        if (value != null) {
            request.setAttribute(name, value);
            session.removeAttribute(name);
        }
    }

    private Integer parsePositiveInteger(
            String value) {

        try {
            int number = Integer.parseInt(
                    trim(value)
            );

            return number > 0 ? number : null;

        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String normalizePhone(String phone) {
        String result = trim(phone)
                .replaceAll("[\\s.()\\-]", "");

        if (result.startsWith("+84")
                && result.length() == 12) {
            result = "0" + result.substring(3);
        } else if (result.startsWith("84")
                && result.length() == 11) {
            result = "0" + result.substring(2);
        }

        return result;
    }

    private String trim(String value) {
        return value == null
                ? ""
                : value.trim();
    }
}
