package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

@WebServlet(name = "ProductServlet", urlPatterns = {"/home"})
public class ProductServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 10;
    private static final String HOME_VIEW = "/WEB-INF/views/home.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        request.setAttribute("products", List.of());
        request.setAttribute("featuredProducts", List.of());
        request.setAttribute("bestSellingProducts", List.of());
        request.setAttribute("newProducts", List.of());
        request.setAttribute("pageNumbers", List.of());
        request.setAttribute("currentPage", 1L);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalProducts", 0L);
        request.setAttribute("totalPages", 0L);
        request.setAttribute("firstProduct", 0L);
        request.setAttribute("lastProduct", 0L);

        long requestedPage = parsePage(request.getParameter("page"));
        long totalProducts;
        long totalPages;
        long currentPage;
        List<Product> products;
        List<Product> featuredProducts;
        List<Product> bestSellingProducts;
        List<Product> newProducts;

        // No DAO or JDBC connection is shared between servlet requests.
        try (ProductDAO dao = new ProductDAO()) {
            totalProducts = dao.countActiveProducts();
            totalPages = totalProducts / PAGE_SIZE + (totalProducts % PAGE_SIZE == 0 ? 0 : 1);
            currentPage = Math.min(requestedPage, Math.max(1, totalPages));
            products = totalProducts == 0 ? List.of() : dao.getProducts(currentPage, PAGE_SIZE);
            featuredProducts = dao.getFeaturedProducts(3);
            bestSellingProducts = dao.getBestSellingProducts(6);
            newProducts = dao.getNewProducts(3);
        } catch (SQLException exception) {
            getServletContext().log("Unable to load the public product catalog.", exception);
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            request.setAttribute("dataLoadError",
                    "Hiện chưa thể tải sản phẩm. Vui lòng thử lại sau.");
            request.getRequestDispatcher(HOME_VIEW).forward(request, response);
            return;
        }

        request.setAttribute("products", products);
        request.setAttribute("featuredProducts", featuredProducts);
        request.setAttribute("bestSellingProducts", bestSellingProducts);
        request.setAttribute("newProducts", newProducts);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalPages", totalPages);
        long firstProduct = totalProducts == 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1;
        request.setAttribute("firstProduct", firstProduct);
        request.setAttribute("lastProduct", products.isEmpty() ? 0 : firstProduct + products.size() - 1);

        // A bounded page window also handles very large valid page parameters.
        List<Long> pageNumbers = new ArrayList<>();
        long endPage = Math.min(totalPages, Math.max(1, currentPage - 2) + 4);
        long startPage = Math.max(1, endPage - 4);
        for (long page = startPage; page <= endPage; page++) {
            pageNumbers.add(page);
        }
        request.setAttribute("pageNumbers", pageNumbers);
        request.getRequestDispatcher(HOME_VIEW).forward(request, response);
    }

    private long parsePage(String parameter) {
        if (parameter != null) {
            try {
                long page = Long.parseLong(parameter.trim());
                if (page > 0) {
                    return page;
                }
            } catch (NumberFormatException ignored) {
                // Missing, malformed, negative or overflowing input falls back to page 1.
            }
        }
        return 1;
    }
}
