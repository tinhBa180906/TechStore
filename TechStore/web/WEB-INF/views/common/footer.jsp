<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<footer class="ts-footer">
    <div class="ts-container ts-footer-main">
        <div>
            <a class="ts-logo" href="${pageContext.request.contextPath}/home"
                aria-label="TechStore — Về đầu trang">
                <svg class="ts-logo-mark" viewBox="0 0 40 40" fill="none" aria-hidden="true">
                    <path
                        d="M19 6H11a6 6 0 0 0 0 12h18a6 6 0 0 1 0 12h-8M21 10h8a6 6 0 0 1 0 12H11a6 6 0 0 0 0 12h8M14 14V3m12 34V26"
                        stroke="currentColor" stroke-width="2.5" stroke-linecap="round" />
                </svg>
                <span><strong>TECHSTORE</strong><small>CÔNG NGHỆ CHO CUỘC SỐNG</small></span>
            </a>
            <p>Điện thoại, laptop, linh kiện và giải pháp công nghệ mỗi ngày.</p>
        </div>
        <nav aria-label="Điều hướng cuối trang">
            <a href="${pageContext.request.contextPath}/home#danh-muc">Danh mục</a>
            <a href="${pageContext.request.contextPath}/products">Sản phẩm</a>
            <a href="${pageContext.request.contextPath}/home#thuong-hieu">Thương hiệu</a>
            <c:if test="${not empty sessionScope.user and sessionScope.user.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/products">Admin CRUD Sản phẩm</a>
            </c:if>
        </nav>
    </div>
    <div class="ts-container ts-footer-bottom">
        <p>TechStore · Dự án PRJ301 · FPT University · Nhóm 1 · Khuất Bá Tình · Vũ Hồng Quang · Nguyễn Tùng Thái</p>
        <p>Ảnh sản phẩm: <a href="https://www.apple.com/" rel="noopener noreferrer" target="_blank">Apple</a>,
            <a href="https://www.sony.jp/headphone/" rel="noopener noreferrer" target="_blank">Sony</a>, <a
                href="https://www.mi.com/global/" rel="noopener noreferrer" target="_blank">Xiaomi</a>.</p>
    </div>
</footer>

<script>
    // Universal image fallback, mobile drawer & profile dropdown handler
    (() => {
        const showFallback = (img) => {
            if (img.dataset.failed) return;
            img.dataset.failed = 'true';
            img.hidden = true;
            const fallback = img.parentElement ? img.parentElement.querySelector('.ts-image-fallback') : null;
            if (fallback) fallback.hidden = false;
        };
        document.querySelectorAll('.ts-media img').forEach((img) => {
            img.addEventListener('error', () => showFallback(img), { once: true });
            if (img.complete && img.naturalWidth === 0) showFallback(img);
        });

        const menu = document.querySelector('.ts-mobile-menu');
        if (menu) {
            const summary = menu.querySelector('summary');
            menu.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
                menu.open = false;
            }));
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape' && menu.open) {
                    menu.open = false;
                    if (summary) summary.focus();
                }
            });
            document.addEventListener('click', (event) => {
                if (menu.open && !menu.contains(event.target)) {
                    menu.open = false;
                }
            });
        }

        const profileDropdown = document.querySelector('.ts-profile-dropdown');
        if (profileDropdown) {
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape' && profileDropdown.open) {
                    profileDropdown.open = false;
                }
            });
            document.addEventListener('click', (event) => {
                if (profileDropdown.open && !profileDropdown.contains(event.target)) {
                    profileDropdown.open = false;
                }
            });
        }
    })();
</script>

<!-- KHUNG CHATBOT TECHSTORE -->
<div id="tech-chat-widget">
    <!-- Nút tròn bật/tắt chat -->
    <button id="tech-chat-toggle" aria-label="Mở khung chat tư vấn" onclick="toggleTechChat()">
        💬
    </button>

    <!-- Hộp thoại chat -->
    <div id="tech-chat-box" style="display: none;">
        <div class="tech-chat-header">
            <div style="display:flex; align-items:center; gap:8px;">
                <span style="font-size: 20px;">🤖</span>
                <div>
                    <strong>TechBot AI</strong>
                    <div style="font-size: 11px; opacity: 0.85;">Trợ lý tư vấn TechStore</div>
                </div>
            </div>
            <button onclick="toggleTechChat()" style="background:none; border:none; color:white; font-size:18px; cursor:pointer;">✕</button>
        </div>

        <div id="tech-chat-messages" class="tech-chat-body">
            <div class="tech-msg tech-msg-bot">
                Xin chào! Tôi là <strong>TechBot</strong>. Bạn cần tư vấn điện thoại, laptop hay phụ kiện công nghệ nào hôm nay?
            </div>
        </div>

        <div class="tech-chat-footer">
            <input type="text" id="tech-chat-input" placeholder="Hỏi TechBot điều gì đó..." onkeydown="if(event.key==='Enter') sendTechMessage()">
            <button onclick="sendTechMessage()">Gửi</button>
        </div>
    </div>
</div>

<script>
    function toggleTechChat() {
        const box = document.getElementById("tech-chat-box");
        box.style.display = (box.style.display === "none" || box.style.display === "") ? "flex" : "none";
        if (box.style.display === "flex") {
            document.getElementById("tech-chat-input").focus();
        }
    }

    async function sendTechMessage() {
        const input = document.getElementById("tech-chat-input");
        const messageContainer = document.getElementById("tech-chat-messages");
        const query = input.value.trim();
        if (!query) return;

        // 1. Hiện tin nhắn của người dùng
        const userDiv = document.createElement("div");
        userDiv.className = "tech-msg tech-msg-user";
        userDiv.textContent = query;
        messageContainer.appendChild(userDiv);
        input.value = "";
        messageContainer.scrollTop = messageContainer.scrollHeight;

        // 2. Hiện trạng thái đang gõ
        const typingDiv = document.createElement("div");
        typingDiv.className = "tech-msg tech-msg-bot";
        typingDiv.id = "tech-typing-status";
        typingDiv.textContent = "TechBot đang soạn câu trả lời...";
        messageContainer.appendChild(typingDiv);
        messageContainer.scrollTop = messageContainer.scrollHeight;

        try {
            // 3. Gửi lên ChatbotServlet
            const res = await fetch("${pageContext.request.contextPath}/api/chat", {
                method: "POST",
                headers: { "Content-Type": "text/plain; charset=UTF-8" },
                body: query
            });
            const data = await res.json();
            typingDiv.remove();

            // 4. Hiện câu trả lời của Bot
            const botDiv = document.createElement("div");
            botDiv.className = "tech-msg tech-msg-bot";
            botDiv.innerHTML = data.reply.replace(/\n/g, "<br>");
            messageContainer.appendChild(botDiv);
        } catch (err) {
            typingDiv.textContent = "Chưa kết nối được với Bot. Vui lòng thử lại sau!";
        }
        messageContainer.scrollTop = messageContainer.scrollHeight;
    }
</script>
