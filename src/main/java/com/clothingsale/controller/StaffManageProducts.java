package com.clothingsale.controller;

import com.clothingsale.model.Product;
import com.clothingsale.service.AdminManageProductService;
import com.clothingsale.model.StaffProductModel;
import com.clothingsale.service.StaffProductService;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffManageProducts", urlPatterns = { "/StaffManageProducts", "/staff/products" })
public class StaffManageProducts extends HttpServlet {

    private final StaffProductService staffProductService = new StaffProductService();
    private final AdminManageProductService productService = new AdminManageProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String action = request.getParameter("action");
        String sku = request.getParameter("sku");
        String productId = request.getParameter("id");

        try {
            if ("view".equals(action)) {
                Product product = findProduct(productId, sku);
                if (product != null) {
                    request.setAttribute("product", product);
                    request.setAttribute("variants", productService.getVariantsByProductId(product.getId()));
                    request.getRequestDispatcher("/view/staff/staff_view_product.jsp").forward(request, response);
                    return;
                }
            } else if ("edit".equals(action) && sku != null) {
                List<StaffProductModel> list = staffProductService.getAllProducts();
                for (StaffProductModel item : list) {
                    if (item.getSku().equalsIgnoreCase(sku)) {
                        request.setAttribute("product", item);
                        request.getRequestDispatcher("/view/staff/staff_edit_product.jsp").forward(request, response);
                        return;
                    }
                }
            }

            loadProductCatalog(request);
            request.getRequestDispatcher("/view/staff/staff_manage_products.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "E1: System error while loading data.");
            request.setAttribute("products", java.util.Collections.emptyList());
            request.getRequestDispatcher("/view/staff/staff_manage_products.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String currentStaff = getCurrentStaff(request);
        request.setAttribute("staffUser", currentStaff);

        String sku = request.getParameter("sku");
        String variantIdStr = request.getParameter("variantId");
        String newName = request.getParameter("productName");
        String color = request.getParameter("color");
        String size = request.getParameter("size");

        int variantId = 0;
        try {
            variantId = Integer.parseInt(variantIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid variant ID.");
            loadProductCatalog(request);
            request.getRequestDispatcher("/view/staff/staff_manage_products.jsp").forward(request, response);
            return;
        }

        String result = staffProductService.updateProductDetails(sku, variantId, newName, color, size, currentStaff);

        if (result.equals("SUCCESS")) {
            request.setAttribute("successMessage", "Product updated and inventory log saved successfully.");
        } else {
            request.setAttribute("errorMessage", result);
        }

        try {
            loadProductCatalog(request);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "E1: System error while reloading data.");
        }

        request.getRequestDispatcher("/view/staff/staff_manage_products.jsp").forward(request, response);
    }

    private void loadProductCatalog(HttpServletRequest request) {
        List<Product> products = productService.getAllProducts();
        for (Product product : products) {
            product.setVariants(productService.getVariantsByProductId(product.getId()));
        }
        request.setAttribute("products", products);
    }

    private Product findProduct(String productId, String sku) throws Exception {
        if (productId != null && !productId.trim().isEmpty()) {
            try {
                return productService.getProductById(Integer.parseInt(productId));
            } catch (NumberFormatException ignored) {
                return null;
            }
        }

        if (sku != null && !sku.trim().isEmpty()) {
            for (StaffProductModel item : staffProductService.getAllProducts()) {
                if (sku.equalsIgnoreCase(item.getSku())) {
                    return productService.getProductById(item.getId());
                }
            }
        }
        return null;
    }

    @Override
    public String getServletInfo() {
        return "Staff Manage Product Controller";
    }

    private String getCurrentStaff(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String username = (String) session.getAttribute("authUsername");
            String fullName = (String) session.getAttribute("authFullName");
            if (username != null && !username.trim().isEmpty())
                return username;
            if (fullName != null && !fullName.trim().isEmpty())
                return fullName;
        }
        return "staff01";
    }
}
