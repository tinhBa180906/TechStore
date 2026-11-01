# Hướng dẫn tích hợp VietQR vào TechStore

Cập nhật bàn giao Git: người dùng đã yêu cầu tạo nhánh `qrpayment` và commit bằng danh tính Git `tungthai2mai <210707450+tungthai2mai@users.noreply.github.com>`. Yêu cầu mới này thay thế ghi chú “chưa commit/không commit” của các phase trước cho bước bàn giao hiện tại. Chỉ đưa 21 file tính năng vào commit; hai báo cáo PDF/DOCX có sẵn ngoài project không được thêm. Không push nếu chưa được yêu cầu.

Cập nhật Admin/header: đưa thêm các thay đổi trong `web/css/admin-orders.css`, `web/js/admin-orders.js`, `web/WEB-INF/views/common/header.jsp` vào danh sách file cũ đã sửa (tổng hiện **10**, thay vì 7 trong baseline). Admin JSP/CSS/JS dùng v2: khung đối chiếu VietQR gọn, hộp xác nhận hiện mã đơn/số tiền/nội dung và checkbox đã nhận đủ tiền; vẫn POST csrf/orderId/confirmPayment tới servlet cũ, không đổi Java/SQL. Header dùng chung đã bỏ thanh đen giới thiệu/ngôn ngữ/tiền tệ; menu quản trị trong tài khoản vẫn còn. Deploy cả bốn file, giữ cấu hình ngân hàng. Test render Admin trong `tests/QRPaymentIntegrationTest.java` đã đổi từ nhãn tiếng Anh sang panel mới; không chạy bộ test kỳ vọng cấu hình trống trên tài khoản nhận tiền hiện tại.

Cập nhật UX chuyển khoản: triển khai đồng thời `payment-qr.jsp`, `order-history.jsp`, `payment-qr.css` **v3**. Trang QR có spinner khi gửi và thông báo có animation sau khi DB đã là PENDING_VERIFY; lịch sử đơn QR UNPAID có nút xanh “Tiếp tục thanh toán” ngay dưới trạng thái đơn, đơn chờ xác minh có “Xem trạng thái”. CSS giờ được nạp ở đúng hai trang này, selector vẫn giới hạn theo page và `qrpay-*`; không sửa CSS chung/Java/SQL. Không xác nhận PAID bằng hiệu ứng hoặc phía client. File nhận tiền không đổi.

Cập nhật giao diện: thêm `web/css/payment-qr.css` và chỉnh `payment-qr.jsp` cho thẻ thanh toán gọn, QR 210px desktop / 176px mobile, nút thao tác trong thẻ (mobile ghim dưới màn hình), sản phẩm thu gọn. Toàn bộ CSS mới giới hạn trong `.qr-payment-page`, chỉ trang QR nạp file; không sửa CSS chung/Java/SQL. Khi merge phải đưa cả JSP và CSS mới vào gói deploy. Tổng danh sách file mới hiện là **11**, gồm file CSS bổ sung dưới đây; các file source cũ thay đổi vẫn là 7.

Cập nhật cấu hình sau triển khai: người dùng đã cung cấp Techcombank (`TCB`), STK `38607102006`, chủ tài khoản `NGUYEN TUNG THAI`; source và bản local hiện dùng thông tin này. Những ghi chú “cấu hình trống” bên dưới mô tả baseline lúc kiểm thử ban đầu. Không chạy bộ test kỳ vọng thiếu cấu hình trực tiếp trên cấu hình nhận tiền hiện tại; bảo toàn cấu hình khi tích hợp. Chưa xác minh chủ tài khoản hoặc quét bằng app ngân hàng.

Các đường dẫn dưới đây tính từ thư mục project `TechStore/` (thư mục chứa build.xml); Git root nằm ở thư mục cha. Chưa commit, push hoặc merge nhánh nào trong nhiệm vụ VietQR. Hai báo cáo PDF/DOCX untracked có sẵn ở thư mục cha được giữ nguyên.

## 1. File tạo mới

- `database/QR_Payment_Migration.sql`: migration cộng thêm, chạy lại được.
- `src/java/util/VietQRUtil.java`: cấu hình, kiểm tra số tiền và Quick Link.
- `web/WEB-INF/vietqr.properties`: cấu hình nhận tiền, cố ý để trống.
- `web/WEB-INF/views/payment-qr.jsp`: trang thanh toán/trạng thái VietQR.
- `web/css/payment-qr.css`: giao diện riêng trang VietQR, không tác động CSS trang khác.
- `tests/QRPaymentIntegrationTest.java`: kiểm thử Java/JDBC/HTTP với fixture riêng.
- `tests/Run-QRPaymentChecks.ps1`: compile và chạy test, không tự deploy/migrate.
- `README_QR_PAYMENT.md`: cách thiết lập và giới hạn VietQR.
- `QR_PAYMENT_CHANGELOG.md`: thay đổi và kiểm tra theo từng phase 1–9.
- `QR_PAYMENT_TEST_RESULTS.md`: kết quả thực tế, gồm những kiểm tra chưa chạy.
- `QR_PAYMENT_MERGE_GUIDE.md`: tài liệu này.

Không đưa `build/` hoặc class kiểm thử vào WAR/source merge.

## 2. File có sẵn đã chỉnh sửa

| File | Nội dung cần giữ khi giải quyết conflict |
| --- | --- |
| `src/java/model/Order.java` | paymentStatus và getter/setter. |
| `src/java/dao/OrderDAO.java` | Checkout nhận paymentMethod, đọc PaymentStatus, lấy đơn theo owner, yêu cầu xác minh và xác nhận tiền, chặn hoàn tất QR chưa PAID. |
| `src/java/controller/OrderServlet.java` | GET/POST QR, chọn COD/QR, kiểm tra cấu hình, token một lần, PRG theo phương thức. |
| `src/java/controller/admin/AdminOrderServlet.java` | POST confirmPayment có kiểm tra ADMIN/CSRF, thông báo sau redirect. |
| `web/WEB-INF/views/checkout.jsp` | Hai radio phương thức, COD mặc định, checkoutToken. |
| `web/WEB-INF/views/order-history.jsp` | Phương thức/trạng thái thật, liên kết QR, ẩn hủy QR đã PAID. |
| `web/WEB-INF/views/admin/orders.jsp` | Phương thức/trạng thái/nội dung đối chiếu, nút Confirm Payment, bảo vệ hủy/hoàn tất. |
| `web/css/admin-orders.css` | Khung đối chiếu và hộp xác nhận nhận tiền, selector giới hạn Admin. |
| `web/js/admin-orders.js` | Dialog, checkbox đối chiếu, phản hồi gửi form; giữ nguyên bộ lọc cũ. |
| `web/WEB-INF/views/common/header.jsp` | Bỏ thanh đen giới thiệu/ngôn ngữ/VND; giữ header/menu chính. |

Không sửa DBContext, CartServlet, OrderSupport, AuthServlet, OrderDetail, CSS/JS có sẵn, script tạo database gốc hoặc cấu trúc MVC/build.xml. Không thêm Spring, Maven, SDK, bảng Payment/Transaction, reviews hay PDF.

## 3. Method thêm/sửa

- `Order.getPaymentStatus()` / `setPaymentStatus(String)`; giữ nguyên constructor/signature cũ.
- `OrderDAO.checkout(int, Map<Integer,CartItem>, String, String, String, String paymentMethod)` mới; signature cũ gọi overload với COD.
- `OrderDAO.getOrder(int invoiceId, Integer customerId)` mới: customerId khác null lọc ownership ngay trong SQL; null chỉ dùng sau kiểm tra ADMIN.
- `OrderDAO.requestPaymentVerification(int invoiceId, int customerId)` mới: UNPAID -> PENDING_VERIFY, không chuyển PAID.
- `OrderDAO.confirmPayment(int invoiceId)` mới: boolean cho biết có thay đổi hay đã PAID; chỉ gọi sau kiểm tra ADMIN.
- `OrderDAO.getOrders()` / `readOrder()` đọc PaymentStatus bằng join Invoice với view cũ; `updateStatus()` chỉ cho QR COMPLETED khi PAID, không đổi quy trình COD.
- `OrderServlet.doGet()` / `doPost()` mở rộng, giữ mapping cũ. GET checkout cấp token; POST thành công tiêu thụ token sau commit dưới session lock. Không tin giá/trạng thái do client gửi.
- `AdminOrderServlet.doGet()` / `doPost()` mở rộng action xác nhận tiền và flash notice.
- `VietQRUtil.load(ServletContext)`, constructor nhận bank/account/name, `amountVnd(BigDecimal)`, `transferContent(int)`, `imageUrl(int, BigDecimal)`, getter chi tiết người nhận; private helper encode/validate placeholder.
- SQL `dbo.sp_CancelPendingOrder` giữ transaction/hoàn kho cũ, thêm điều kiện từ chối QR PAID trong cùng UPDATE khóa Invoice.
- Các method trong `tests/` chỉ phục vụ kiểm thử, không phải API ứng dụng và không deploy.

## 4. Servlet mapping và request

| Method / URL | Đầu vào | Quyền / hành vi |
| --- | --- | --- |
| GET `/payment-qr?orderId=...` (mới) | InvoiceID thực | CUSTOMER sở hữu hoặc ADMIN; đọc DB, không ghi; COD/không sở hữu trả 404. |
| POST `/payment-qr` (mới) | csrf, orderId, action=transferred | CUSTOMER chủ đơn; chỉ yêu cầu xác minh. |
| POST `/checkout` (cũ) | Thông tin giao hàng, csrf, checkoutToken; paymentMethod COD/QR | Mặc định COD nếu thiếu; trạng thái luôn UNPAID từ server; QR chuyển tới GET trang QR, COD tới /orders. |
| POST `/admin/orders` (cũ, action mới) | csrf, orderId, action=confirmPayment | ADMIN; chỉ đổi PaymentStatus; GET không xác nhận tiền. |
| POST `/admin/orders` (cũ) | csrf, orderId, status | Giữ chuyển trạng thái đơn hiện tại, QR chưa PAID không được hoàn tất. |

Không đổi tên bất kỳ mapping cũ nào. Tất cả thao tác ghi thanh toán dùng PreparedStatement và kiểm tra trạng thái trong SQL, không nhận PaymentStatus tùy ý.

## 5. JSP và giao diện

Sửa đúng ba JSP cũ ở mục 2, thêm `payment-qr.jsp` vào cùng thư mục views. Trang QR dùng orders.css và CSS nhỏ trong trang; không thêm framework. Admin đang dùng card nên Payment Method/Status được thêm thành trường trong card, không viết lại thành bảng. QR không hiển thị cho đơn CANCELLED hoặc PAID; ảnh lỗi vẫn giữ thông tin nhận tiền và hướng dẫn chuyển thủ công. Reload không tạo hóa đơn mới.

## 6. SQL cần chạy

1. Backup database development nếu cần và kiểm tra đúng instance/local DB.
2. Chạy **chỉ** `database/QR_Payment_Migration.sql` bằng SSMS hoặc `sqlcmd -b -i ...` với cấu hình kết nối của máy.
3. Kiểm tra Invoice có PaymentStatus, CHECK cho COD/QR và UNPAID/PENDING_VERIFY/PAID; thủ tục hủy có guard PAID QR.
4. Deploy Java/JSP sau migration. Script đã chạy và chạy lại thành công trên local trong nhiệm vụ này; máy thành viên khác vẫn cần chạy.

Migration đọc sys.check_constraints để tìm CHECK chỉ cho COD và dùng đúng tên thật khi thay. Thêm **một cột** PaymentStatus có default UNPAID và hai CHECK; không đổi view, PK/FK hoặc schema bảng khác. Không xóa hóa đơn, không đặt PAID cho lịch sử COD. Thủ tục hủy vẫn hoàn kho đúng một lần. Không chạy script create/seed gốc để upgrade vì script đó có thể phá dữ liệu và khôi phục constraint/procedure cũ.

## 7. Cấu hình VietQR

Điền trong `web/WEB-INF/vietqr.properties`:

```properties
vietqr.bankId=
vietqr.accountNo=
vietqr.accountName=
```

Ba giá trị phải thuộc **tài khoản nhận tiền hợp lệ của cửa hàng**. Không dùng tài khoản ngẫu nhiên hoặc tài khoản của người khác. Chưa có thông tin thì giữ trống: COD vẫn dùng được, QR checkout báo rõ và không tạo đơn. Không cần API key, password/OTP/token ngân hàng.

Copy file này vào `WEB-INF` của bản deploy; tránh ghi đè cấu hình hợp lệ của người khác khi merge/deploy. Khi deploy lại từ source, nhớ điền cấu hình đúng vì file mẫu đang trống. Giữ ngân hàng nhận tiền ổn định khi còn đơn chưa thanh toán; hệ thống không snapshot thông tin ngân hàng trên từng đơn.

Quick Link dùng `compact2.svg` theo [tài liệu chính thức hiện tại](https://www.vietqr.io/qr-dong), thay vì PNG trong ví dụ cũ. Amount từ detail trong DB, nguyên VND dương tối đa 13 chữ số; không làm tròn. Nội dung cố định `TECHSTORE<InvoiceID>`; không có PII khách. accountName được URL-encode UTF-8 và hiển thị trên ảnh; tiêu chuẩn QR không bảo đảm app ngân hàng tự điền tên từ tham số này. Kiểm tra tên người nhận trong app trước giao dịch.

## 8. Ảnh hưởng checkout COD

COD vẫn mặc định, giữ transaction tạo Invoice/InvoiceDetail, kiểm tra tồn kho/giá DB và redirect /orders. Có thêm UNPAID nhưng không suy đoán thu tiền COD theo trạng thái giao hàng. Form mới bắt buộc token một lần cho cả hai phương thức: phải deploy form và servlet cùng nhau; trang checkout cũ đang mở trước deploy cần tải lại.

Session lock + token + xóa cart sau commit ngăn submit lặp thông thường. Stock chỉ trừ trong checkout; không trừ khi mở QR/khách khai chuyển tiền/admin xác nhận. Nếu ghi detail thất bại, transaction rollback toàn bộ, gồm stock và Invoice.

## 9. Ảnh hưởng Admin Orders / hủy đơn

Admin đối chiếu giao dịch ngoài website, đúng số tiền và TECHSTORE<InvoiceID>, rồi dùng Confirm Payment. Có thể xác nhận từ UNPAID hoặc PENDING_VERIFY khi đã thấy tiền thực nhận. PAID chỉ là đã nhận tiền; vẫn phải xử lý CONFIRMED/COMPLETED riêng. Đơn QR đã PAID không thể hủy vì chưa có quy trình refund. Đơn QR chưa trả tiền không được COMPLETED. COD không bị thêm điều kiện này.

Không cho customer gọi URL Admin để xác nhận, không xác nhận bằng GET. Xác nhận lặp không ghi lại hoặc tác động stock. Thủ tục hủy và UPDATE PAID khóa cùng hàng Invoice, tránh vừa hủy vừa xác nhận thành công.

## 10. Kiểm tra sau merge

1. Build NetBeans bằng cấu hình local của thành viên, deploy Tomcat với JDBC/JSTL hiện có. Repo hiện thiếu `nbproject/build-impl.xml` (đã bị xóa/ignore từ trước), nên Ant mặc định chưa chạy được. Trong nhiệm vụ này toàn bộ Java đã compile bằng javac và toàn bộ JSP bằng Jasper với 0 lỗi; không chuyển loại project.
2. Chạy `tests/Run-QRPaymentChecks.ps1` theo `QR_PAYMENT_TEST_RESULTS.md` khi local Tomcat đã dùng source mới. Script không deploy/restart/migrate. Bộ test kỳ vọng cấu hình deploy còn trống cho case thiếu cấu hình. Chỉ chạy trên DB development; fixture riêng được dọn sau chạy, không reset identity.
3. Điền tài khoản nhận tiền hợp lệ sau đó kiểm tra UI COD/QR và quét để xem trước thông tin: số tiền, ngân hàng, tài khoản, nội dung đúng. Không cần chuyển tiền thật để kiểm tra autofill.
4. Kiểm tra khách A không xem được đơn B, khách chỉ có PENDING_VERIFY; admin xác nhận PAID, gửi lặp không đổi stock, đơn hủy/đã trả tiền không khuyến khích chuyển thêm.
5. Chặn ảnh img.vietqr.io trong trình duyệt để kiểm tra fallback và thử nút Copy. Những kiểm tra tương tác này chưa thực hiện trong phiên triển khai.

Kết quả đã chạy: 70 assertion PASS, migration lần đầu/lần hai PASS, Java/JSP compile PASS. Xem TEST_RESULTS để phân biệt PASS, FAIL (Ant metadata có sẵn bị thiếu), NOT RUN (ảnh/quét ngân hàng thật và tương tác trình duyệt).

## 11. Những giới hạn còn lại

- Chưa có tài khoản nhận tiền nên không bật QR thực tế trên local. Mã nguồn đã triển khai; cấu hình cần người triển khai điền.
- Chưa chạy quét QR bằng app ngân hàng hoặc kiểm tra UI tương tác/copy/image-fallback trong trình duyệt. Không có screenshot/ảnh demo và không có giao dịch thật.
- Không tự đối soát, webhook, polling, refund, hoặc auto-hủy đơn quá hạn. Đơn QR chưa trả tiền giữ tồn kho cho tới hủy theo cơ chế cũ.
- Chống lặp trong session phù hợp assignment, không cam kết exactly-once khi crash/mất kết nối ở thời điểm JDBC commit hoặc chạy nhiều server.
- Cấu hình nhận tiền dùng chung; nếu đổi bank/account, đơn QR cũ cũng hiển thị cấu hình mới (số tiền/nội dung đơn không đổi).
- Build Ant cần phục hồi metadata NetBeans local của dự án; không tạo lại cấu trúc project trong nhiệm vụ này.

## 12. Rollback code và database

Chưa thực hiện rollback. Không dùng reset/clean hoặc ghi đè thay đổi chưa commit của thành viên.

**Ưu tiên rollback không mất dữ liệu:** tạm khóa QR checkout bằng cách để cấu hình trống, giữ code đọc trạng thái/guard hủy và giữ migration cộng thêm. COD vẫn dùng được. Với đơn QR đã tồn tại, giữ trang trạng thái/Admin để đối chiếu tiếp; cân nhắc sửa tiến thay vì quay về giao diện cũ chỉ biết COD.

**Chỉ khi chưa có bất kỳ hóa đơn QR nào:** backup và kiểm tra `SELECT COUNT(*) FROM dbo.Invoice WHERE PaymentMethod='QR'` trả 0; kiểm tra không có PaymentStatus khác UNPAID trước khi cân nhắc xóa cột. Khôi phục đúng những hunk VietQR từ file ở mục 2 dựa trên version trước tính năng, giữ các sửa đổi khác; gỡ file mới khỏi gói deploy và rebuild sạch bằng IDE local. Có thể giữ cột/constraint mới vì code COD cũ vẫn đọc view cũ.

Nếu thực sự cần trả schema cũ trên development, thực hiện trong transaction sau backup/kiểm tra trên: khôi phục **chỉ** định nghĩa thủ tục hủy gốc từ source version trước migration (không chạy cả seed file), bỏ CK_Invoice_PaymentStatus và DF_Invoice_PaymentStatus, bỏ PaymentStatus, bỏ CK_Invoice_QRPaymentMethod, khôi phục CHECK chỉ COD theo schema gốc. Đọc sys.check_constraints/sys.default_constraints để dùng tên thật nếu môi trường đã thay đổi. Rollback nếu có bất kỳ lỗi nào. Không thao tác Product stock, InvoiceDetail hay Invoice/PK/FK; không xóa/chuyển QR thành COD để ép rollback. Nếu đã có QR/PAID, không xóa trạng thái hoặc khôi phục thủ tục hủy thiếu guard; phải giữ dữ liệu và lập phương án bảo toàn đối soát riêng.
