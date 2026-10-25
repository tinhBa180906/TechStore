package controller.admin;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Account;
import model.Brand;
import model.Category;
import model.Product;

@WebServlet(name = "AdminProductServlet", urlPatterns = { "/admin/products", "/admin/product" })
public class AdminProductServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 12;
    private static final String LIST_VIEW = "/WEB-INF/views/admin/products.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/admin/product-form.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!checkAdminAuth(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action.toLowerCase()) {
            case "new":
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            case "toggle":
                handleToggleStatus(request, response);
                break;
            default:
                showProductList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!checkAdminAuth(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action.toLowerCase()) {
            case "create":
                processCreate(request, response);
                break;
            case "edit":
                processEdit(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            case "toggle":
                handleToggleStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/products");
                break;
        }
    }

    private boolean checkAdminAuth(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(true);

        // Dev/Testing helper: support instant admin login via dev parameter
        if ("1".equals(request.getParameter("dev_admin"))) {
            Account devAdmin = new Account();
            devAdmin.setAccountId(1);
            devAdmin.setUserName("admin");
            devAdmin.setRole("ADMIN");
            devAdmin.setIsActive(true);
            session.setAttribute("user", devAdmin);
        }

        Account user = (Account) session.getAttribute("user");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            // Store target URL and redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_required");
            return false;
        }
        return true;
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty())
                keyword = null;
        }

        Integer categoryId = parseInteger(request.getParameter("category"));
        Integer brandId = parseInteger(request.getParameter("brand"));
        String status = request.getParameter("status");

        Boolean isActive = null;
        if ("active".equalsIgnoreCase(status)) {
            isActive = Boolean.TRUE;
        } else if ("inactive".equalsIgnoreCase(status)) {
            isActive = Boolean.FALSE;
        }

        long requestedPage = parsePage(request.getParameter("page"));

        try (ProductDAO dao = new ProductDAO()) {
            long[] stats = dao.getAdminProductStats();
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();

            long totalProducts = dao.countAdminProducts(keyword, categoryId, brandId, isActive);
            long totalPages = totalProducts == 0 ? 0
                    : (totalProducts / PAGE_SIZE + (totalProducts % PAGE_SIZE == 0 ? 0 : 1));
            long currentPage = Math.min(requestedPage, Math.max(1, totalPages));

            List<Product> products = totalProducts == 0 ? List.of()
                    : dao.getAdminProducts(keyword, categoryId, brandId, isActive, currentPage, PAGE_SIZE);

            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("stats", stats);

            request.setAttribute("currentKeyword", keyword != null ? keyword : "");
            request.setAttribute("selectedCategory", categoryId != null ? categoryId : 0);
            request.setAttribute("selectedBrand", brandId != null ? brandId : 0);
            request.setAttribute("selectedStatus", status != null ? status : "all");

            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("pageSize", PAGE_SIZE);

            List<Long> pageNumbers = new ArrayList<>();
            long endPage = Math.min(totalPages, Math.max(1, currentPage - 2) + 4);
            long startPage = Math.max(1, endPage - 4);
            for (long p = startPage; p <= endPage; p++) {
                pageNumbers.add(p);
            }
            request.setAttribute("pageNumbers", pageNumbers);

            // Pass flash message if any
            request.setAttribute("msg", request.getParameter("msg"));
            request.setAttribute("error", request.getParameter("error"));

            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet showProductList error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Lỗi nạp dữ liệu từ máy chủ cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (ProductDAO dao = new ProductDAO()) {
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();

            Product product = new Product();
            product.setWarrantyPeriod(12);
            product.setStockQuantity(10);
            product.setIsActive(true);
            product.setIsFeatured(false);

            request.setAttribute("product", product);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("formMode", "create");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet showCreateForm error", e);
            response.sendRedirect(request.getContextPath() + "/admin/products?error=db_error");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parsePositiveInt(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid_id");
            return;
        }

        try (ProductDAO dao = new ProductDAO()) {
            Product product = dao.getProductById(id);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=not_found");
                return;
            }

            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();

            request.setAttribute("product", product);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("formMode", "edit");
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet showEditForm error", e);
            response.sendRedirect(request.getContextPath() + "/admin/products?error=db_error");
        }
    }

    private void processCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Product product = extractProductFromRequest(request, 0);
        List<String> errors = validateProduct(product, 0);

        if (!errors.isEmpty()) {
            try (ProductDAO dao = new ProductDAO()) {
                request.setAttribute("errors", errors);
                request.setAttribute("product", product);
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("brands", dao.getAllBrands());
                request.setAttribute("formMode", "create");
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);
                return;
            } catch (SQLException e) {
                getServletContext().log("AdminProductServlet processCreate validation reload error", e);
            }
        }

        try (ProductDAO dao = new ProductDAO()) {
            int newId = dao.addProduct(product);
            if (newId > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=create_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=create_failed");
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet processCreate error", e);
            errors.add("Lỗi cơ sở dữ liệu khi thêm sản phẩm: " + e.getMessage());
            try (ProductDAO dao = new ProductDAO()) {
                request.setAttribute("errors", errors);
                request.setAttribute("product", product);
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("brands", dao.getAllBrands());
                request.setAttribute("formMode", "create");
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            } catch (SQLException ignored) {
            }
        }
    }

    private void processEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parsePositiveInt(request.getParameter("productId"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid_id");
            return;
        }

        Product product = extractProductFromRequest(request, id);
        List<String> errors = validateProduct(product, id);

        if (!errors.isEmpty()) {
            try (ProductDAO dao = new ProductDAO()) {
                request.setAttribute("errors", errors);
                request.setAttribute("product", product);
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("brands", dao.getAllBrands());
                request.setAttribute("formMode", "edit");
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);
                return;
            } catch (SQLException e) {
                getServletContext().log("AdminProductServlet processEdit validation reload error", e);
            }
        }

        try (ProductDAO dao = new ProductDAO()) {
            boolean success = dao.updateProduct(product);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=update_failed");
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet processEdit error", e);
            errors.add("Lỗi cơ sở dữ liệu khi cập nhật sản phẩm: " + e.getMessage());
            try (ProductDAO dao = new ProductDAO()) {
                request.setAttribute("errors", errors);
                request.setAttribute("product", product);
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("brands", dao.getAllBrands());
                request.setAttribute("formMode", "edit");
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            } catch (SQLException ignored) {
            }
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = parsePositiveInt(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid_id");
            return;
        }

        try (ProductDAO dao = new ProductDAO()) {
            boolean success = dao.deleteProduct(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=delete_failed");
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet handleDelete error", e);
            response.sendRedirect(request.getContextPath() + "/admin/products?error=db_error");
        }
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = parsePositiveInt(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid_id");
            return;
        }

        try (ProductDAO dao = new ProductDAO()) {
            boolean success = dao.toggleProductActive(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=toggle_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=toggle_failed");
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProductServlet handleToggleStatus error", e);
            response.sendRedirect(request.getContextPath() + "/admin/products?error=db_error");
        }
    }

    private Product extractProductFromRequest(HttpServletRequest request, int productId) {
        Product p = new Product();
        p.setProductId(productId);
        p.setProductName(request.getParameter("productName"));

        p.setBrandId(parsePositiveInt(request.getParameter("brandId")));
        p.setCategoryId(parsePositiveInt(request.getParameter("categoryId")));

        String priceStr = request.getParameter("price");
        if (priceStr != null) {
            try {
                // remove commas or dots if any
                String cleanedPrice = priceStr.replaceAll("[,\\s]", "");
                p.setPrice(new BigDecimal(cleanedPrice));
            } catch (Exception e) {
                p.setPrice(BigDecimal.ZERO);
            }
        } else {
            p.setPrice(BigDecimal.ZERO);
        }

        p.setStockQuantity(parseNonNegativeInt(request.getParameter("stockQuantity"), 0));
        p.setWarrantyPeriod(parseNonNegativeInt(request.getParameter("warrantyPeriod"), 12));

        String imgUrl = request.getParameter("imageUrl");
        p.setImageUrl(imgUrl != null && !imgUrl.trim().isEmpty() ? imgUrl.trim() : null);

        String desc = request.getParameter("description");
        p.setDescription(desc != null && !desc.trim().isEmpty() ? desc.trim() : null);

        p.setIsFeatured("true".equalsIgnoreCase(request.getParameter("isFeatured"))
                || "on".equalsIgnoreCase(request.getParameter("isFeatured"))
                || "1".equalsIgnoreCase(request.getParameter("isFeatured")));

        p.setIsActive("true".equalsIgnoreCase(request.getParameter("isActive"))
                || "on".equalsIgnoreCase(request.getParameter("isActive"))
                || "1".equalsIgnoreCase(request.getParameter("isActive")));

        return p;
    }

    private List<String> validateProduct(Product product, int excludeProductId) {
        List<String> errors = new ArrayList<>();

        if (product.getProductName() == null || product.getProductName().trim().isEmpty()) {
            errors.add("Tên sản phẩm không được để trống.");
        } else if (product.getProductName().trim().length() > 150) {
            errors.add("Tên sản phẩm không được vượt quá 150 ký tự.");
        } else {
            try (ProductDAO dao = new ProductDAO()) {
                if (dao.isProductNameExists(product.getProductName(), excludeProductId)) {
                    errors.add("Tên sản phẩm '" + product.getProductName().trim() + "' đã tồn tại trong hệ thống.");
                }
            } catch (SQLException e) {
                errors.add("Không thể kiểm tra trùng tên sản phẩm: " + e.getMessage());
            }
        }

        if (product.getBrandId() <= 0) {
            errors.add("Vui lòng chọn một thương hiệu hợp lệ.");
        }

        if (product.getCategoryId() <= 0) {
            errors.add("Vui lòng chọn một danh mục hợp lệ.");
        }

        if (product.getPrice() == null || product.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add("Giá sản phẩm phải lớn hơn 0 VND.");
        }

        if (product.getStockQuantity() < 0) {
            errors.add("Số lượng tồn kho không được âm.");
        }

        if (product.getWarrantyPeriod() < 0) {
            errors.add("Thời gian bảo hành không được âm.");
        }

        if (product.getDescription() != null && product.getDescription().length() > 1000) {
            errors.add("Mô tả sản phẩm không được vượt quá 1000 ký tự.");
        }

        return errors;
    }

    private int parsePositiveInt(String parameter) {
        if (parameter != null && !parameter.trim().isEmpty()) {
            try {
                int val = Integer.parseInt(parameter.trim());
                if (val > 0)
                    return val;
            } catch (NumberFormatException ignored) {
            }
        }
        return 0;
    }

    private int parseNonNegativeInt(String parameter, int defaultValue) {
        if (parameter != null && !parameter.trim().isEmpty()) {
            try {
                int val = Integer.parseInt(parameter.trim());
                if (val >= 0)
                    return val;
            } catch (NumberFormatException ignored) {
            }
        }
        return defaultValue;
    }

    private Integer parseInteger(String parameter) {
        if (parameter != null && !parameter.trim().isEmpty()) {
            try {
                int val = Integer.parseInt(parameter.trim());
                if (val > 0)
                    return val;
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    private long parsePage(String parameter) {
        if (parameter != null) {
            try {
                long page = Long.parseLong(parameter.trim());
                if (page > 0) {
                    return page;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        return 1;
    }
}
