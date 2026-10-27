package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;

@WebServlet(name = "ProductServlet", urlPatterns = {"/home", "/product-detail", "/products", "/search"})
public class ProductServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 10;
    private static final String HOME_VIEW = "/WEB-INF/views/home.jsp";
    private static final String PRODUCTS_VIEW = "/WEB-INF/views/products.jsp";
    private static final String DETAIL_VIEW = "/WEB-INF/views/product-detail.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String servletPath = request.getServletPath();
        if ("/product-detail".equalsIgnoreCase(servletPath)) {
            handleProductDetail(request, response);
        } else if ("/products".equalsIgnoreCase(servletPath) || "/search".equalsIgnoreCase(servletPath)) {
            handleSearch(request, response);
        } else {
            String keyword = request.getParameter("q");
            String cat = request.getParameter("category");
            String brand = request.getParameter("brand");
            String price = request.getParameter("price");
            if (keyword != null || cat != null || brand != null || price != null) {
                String qs = request.getQueryString();
                response.sendRedirect(request.getContextPath() + "/products" + (qs != null ? "?" + qs : ""));
                return;
            }
            handleHome(request, response);
        }
    }

    private void handleProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        int productId = 0;
        if (idParam != null) {
            try {
                productId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        if (productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try (ProductDAO dao = new ProductDAO()) {
            Product product = dao.getProductById(productId);
            if (product == null || !product.isActive()) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            List<Product> relatedProducts = dao.getRelatedProducts(product.getCategoryId(), product.getProductId(), 4);
            request.setAttribute("product", product);
            request.setAttribute("relatedProducts", relatedProducts);
            request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
        } catch (SQLException exception) {
            getServletContext().log("Unable to load product detail for ID: " + productId, exception);
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    private void handleHome(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> featuredProducts = List.of();
        List<Product> bestSellingProducts = List.of();
        List<Product> newProducts = List.of();
        List<Category> categories = List.of();
        List<Brand> brands = List.of();

        try (ProductDAO dao = new ProductDAO()) {
            categories = dao.getAllCategories();
            brands = dao.getAllBrands();
            featuredProducts = dao.getFeaturedProducts(3);
            bestSellingProducts = dao.getBestSellingProducts(6);
            newProducts = dao.getNewProducts(3);
        } catch (SQLException exception) {
            getServletContext().log("Unable to load home page products.", exception);
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            request.setAttribute("dataLoadError", "Hiện chưa thể tải sản phẩm. Vui lòng thử lại sau.");
            request.getRequestDispatcher(HOME_VIEW).forward(request, response);
            return;
        }

        request.setAttribute("featuredProducts", featuredProducts);
        request.setAttribute("bestSellingProducts", bestSellingProducts);
        request.setAttribute("newProducts", newProducts);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.getRequestDispatcher(HOME_VIEW).forward(request, response);
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("products", List.of());
        request.setAttribute("categories", List.of());
        request.setAttribute("brands", List.of());
        request.setAttribute("pageNumbers", List.of());
        request.setAttribute("currentPage", 1L);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalProducts", 0L);
        request.setAttribute("totalPages", 0L);
        request.setAttribute("firstProduct", 0L);
        request.setAttribute("lastProduct", 0L);

        // Parse query params
        String keyword = request.getParameter("q");
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) {
                keyword = null;
            }
        }

        Integer categoryId = parseInteger(request.getParameter("category"));
        Integer brandId = parseInteger(request.getParameter("brand"));
        String priceRange = request.getParameter("price");
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;

        if ("under10".equalsIgnoreCase(priceRange)) {
            maxPrice = new BigDecimal("10000000");
        } else if ("10to20".equalsIgnoreCase(priceRange)) {
            minPrice = new BigDecimal("10000000");
            maxPrice = new BigDecimal("20000000");
        } else if ("above20".equalsIgnoreCase(priceRange)) {
            minPrice = new BigDecimal("20000000");
        }

        String sort = request.getParameter("sort");
        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        }

        long requestedPage = parsePage(request.getParameter("page"));
        long totalProducts;
        long totalPages;
        long currentPage;
        List<Product> products;
        List<Category> categories;
        List<Brand> brands;

        try (ProductDAO dao = new ProductDAO()) {
            categories = dao.getAllCategories();
            brands = dao.getAllBrands();

            totalProducts = dao.countFilteredProducts(keyword, categoryId, brandId, minPrice, maxPrice);
            totalPages = totalProducts == 0 ? 0 : (totalProducts / PAGE_SIZE + (totalProducts % PAGE_SIZE == 0 ? 0 : 1));
            currentPage = Math.min(requestedPage, Math.max(1, totalPages));

            products = totalProducts == 0 ? List.of()
                    : dao.getFilteredProducts(keyword, categoryId, brandId, minPrice, maxPrice, sort, currentPage, PAGE_SIZE);
        } catch (SQLException exception) {
            getServletContext().log("Unable to load product search catalog.", exception);
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            request.setAttribute("dataLoadError", "Hiện chưa thể tải danh sách tìm kiếm sản phẩm. Vui lòng thử lại sau.");
            request.getRequestDispatcher(PRODUCTS_VIEW).forward(request, response);
            return;
        }

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);

        // Retain search / filter state for the JSP form
        request.setAttribute("currentKeyword", keyword != null ? keyword : "");
        request.setAttribute("selectedCategory", categoryId != null ? categoryId : 0);
        request.setAttribute("selectedBrand", brandId != null ? brandId : 0);
        request.setAttribute("selectedPrice", priceRange != null ? priceRange : "all");
        request.setAttribute("selectedSort", sort);

        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalPages", totalPages);
        long firstProduct = totalProducts == 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1;
        request.setAttribute("firstProduct", firstProduct);
        request.setAttribute("lastProduct", products.isEmpty() ? 0 : firstProduct + products.size() - 1);

        List<Long> pageNumbers = new ArrayList<>();
        long endPage = Math.min(totalPages, Math.max(1, currentPage - 2) + 4);
        long startPage = Math.max(1, endPage - 4);
        for (long page = startPage; page <= endPage; page++) {
            pageNumbers.add(page);
        }
        request.setAttribute("pageNumbers", pageNumbers);
        request.getRequestDispatcher(PRODUCTS_VIEW).forward(request, response);
    }

    private Integer parseInteger(String parameter) {
        if (parameter != null && !parameter.trim().isEmpty()) {
            try {
                int val = Integer.parseInt(parameter.trim());
                if (val > 0) {
                    return val;
                }
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
