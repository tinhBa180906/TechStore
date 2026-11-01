package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter tự động kiểm tra thời hạn đăng nhập 7 ngày (Absolute Timeout).
 */
@WebFilter(filterName = "SessionTimeoutFilter", urlPatterns = {"/*"})
public class SessionTimeoutFilter implements Filter {

    // 7 ngày quy đổi ra mili-giây: 7 * 24 * 60 * 60 * 1000 = 604,800,000 ms
    private static final long SEVEN_DAYS_MS = 7L * 24 * 60 * 60 * 1000;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        
        // Kiểm tra nếu người dùng đã đăng nhập và có session
        if (session != null && session.getAttribute("user") != null) {
            Long loginTime = (Long) session.getAttribute("loginTime");
            long currentTime = System.currentTimeMillis();

            // Nếu thời gian đã trôi qua vượt quá 7 ngày -> Hủy phiên đăng nhập
            if (loginTime != null && (currentTime - loginTime > SEVEN_DAYS_MS)) {
                session.invalidate(); // Xóa sạch session trên server
                
                // Đẩy người dùng về trang đăng nhập kèm báo lỗi
                resp.sendRedirect(req.getContextPath() + "/login?error=session_expired");
                return;
            }
        }

        // Cho phép request tiếp tục đi tới Servlet/JSP tiếp theo
        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}