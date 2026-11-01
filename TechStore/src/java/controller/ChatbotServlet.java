package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@WebServlet(name = "ChatbotServlet", urlPatterns = {"/api/chat"})
public class ChatbotServlet extends HttpServlet {

    // API Key chuẩn từ cURL của bạn
    private static final String GEMINI_API_KEY = "YOUR_API_KEY_HERE";

  


    
    // URL chuẩn theo cURL của Google (bỏ ?key= trên URL)
    private static final String GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        // 1. Đọc câu hỏi người dùng gửi lên
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String userMessage = sb.toString().trim();
        if (userMessage.isEmpty()) {
            response.getWriter().write("{\"reply\":\"Bạn chưa nhập câu hỏi nào cả!\"}");
            return;
        }

        // 2. Ngữ cảnh tư vấn bán hàng cho TechStore
        String systemInstruction = "Bạn là TechBot - trợ lý tư vấn bán hàng của TechStore. "
                + "TechStore chuyên bán: iPhone, Samsung, MacBook, Laptop, Phụ kiện, Màn hình. "
                + "Chính sách: Bảo hành 12 tháng, COD toàn quốc, cho kiểm tra hàng trước khi thanh toán. "
                + "Hãy trả lời ngắn gọn, thân thiện bằng tiếng Việt. ";

        String prompt = systemInstruction + "\\nKhách hàng hỏi: " + escapeJson(userMessage);
        String requestBody = "{\"contents\": [{\"parts\": [{\"text\": \"" + prompt + "\"}]}]}";

        try {
            // 3. Tạo request gửi header X-goog-api-key y hệt cURL
            HttpRequest apiRequest = HttpRequest.newBuilder()
                    .uri(URI.create(GEMINI_URL))
                    .header("Content-Type", "application/json")
                    .header("X-goog-api-key", GEMINI_API_KEY) // <-- HEADER CHUẨN CỦA GOOGLE
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> apiResponse = httpClient.send(apiRequest, HttpResponse.BodyHandlers.ofString());
            String responseBody = apiResponse.body();

            // In ra tab Output của NetBeans để bạn dễ theo dõi
            System.out.println(">>> GEMINI STATUS CODE: " + apiResponse.statusCode());
            System.out.println(">>> GEMINI RESPONSE: " + responseBody);

            // 4. Trích xuất câu trả lời text
            String replyText = extractTextFromGemini(responseBody);

            // 5. Trả về cho giao diện
            response.getWriter().write("{\"reply\": \"" + escapeJson(replyText) + "\"}");

        } catch (InterruptedException e) {
            response.setStatus(500);
            response.getWriter().write("{\"reply\":\"Hệ thống bot đang bận, bạn vui lòng thử lại sau ít phút!\"}");
        }
    }

    private String extractTextFromGemini(String json) {
        if (json == null) return "Xin lỗi, không có phản hồi từ máy chủ.";

        // Tìm vị trí của "text": "
        int textIndex = json.indexOf("\"text\":");
        if (textIndex != -1) {
            int quoteStart = json.indexOf("\"", textIndex + 7);
            if (quoteStart != -1) {
                int start = quoteStart + 1;
                int end = start;
                while (end < json.length()) {
                    if (json.charAt(end) == '"' && json.charAt(end - 1) != '\\') {
                        break;
                    }
                    end++;
                }
                if (end < json.length()) {
                    return json.substring(start, end)
                               .replace("\\n", "\n")
                               .replace("\\\"", "\"")
                               .replace("\\\\", "\\");
                }
            }
        }
        return "Xin lỗi, TechBot chưa thể xử lý câu trả lời lúc này. Bạn thử lại nhé!";
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}