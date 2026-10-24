# Phân tích TechStore: hiện trạng, frontend và CRUD

Ngày phân tích: 24/10/2026. Repository: https://github.com/tinhBa180906/TechStore

Đã clone trực tiếp vào `D:\Fall2026\PRJ301\PRJ301_Project`, nhánh `main`, commit `0679283b32280a2a4e3c70c8e39f814fcfc8c8ef`. Có 47 file được Git theo dõi tại commit này. Thư mục mở bằng NetBeans là `TechStore/` bên trong workspace.

## 1. Nguồn yêu cầu và giới hạn phân tích

- `TechStore/TechStore_Group1_SRS_PRJ301.docx`: SRS v1.0, bản nháp ngày 22/10/2026; mô tả yêu cầu, không phải xác nhận tính năng đã hoàn thành.
- `TechStore/README_TechStore_PRJ301.md`: hướng dẫn database mới và các điểm cần cập nhật so với SRS cũ.
- `TechStore/TechStore_PRJ301_Full_Create_Seed.sql`: schema và dữ liệu mẫu hiện có.
- Mã Java, JSP, CSS và cấu hình NetBeans tại commit trên.

Đã đọc mã nguồn và trích nội dung DOCX để đối chiếu. Chưa build/deploy Tomcat hoặc thực thi SQL Server. Các nhận xét về lỗi là kết quả kiểm tra tĩnh. Các PDF và tài liệu gốc được SRS viện dẫn không nằm trong repo, nên chưa thể xác nhận yêu cầu chấm điểm nằm ngoài SRS này.

## 2. Trong repo có gì?

```text
PRJ301_Project/
├── README.md
└── TechStore/
    ├── TechStore_Group1_SRS_PRJ301.docx
    ├── TechStore_PRJ301_Full_Create_Seed.sql
    ├── README_TechStore_PRJ301.md
    ├── build.xml, nbproject/       # NetBeans + Ant
    ├── src/java/
    │   ├── controller/            # Auth, Product, Cart, Order
    │   │   └── admin/             # Dashboard, Product, User, Order
    │   ├── dao/                   # AccountDAO, ProductDAO, OrderDAO
    │   ├── dal/DBContext.java     # JDBC SQL Server
    │   ├── model/                 # Account, Product, CartItem, Order, OrderDetail
    │   └── util/PasswordUtil.java
    └── web/
        ├── index.jsp
        ├── css/style.css
        ├── META-INF/context.xml
        └── WEB-INF/views/         # 8 trang khách hàng, 5 trang admin
```

Kiến trúc dự kiến: trình duyệt → Servlet → DAO/JDBC → SQL Server; Servlet chuyển dữ liệu sang JSP. HttpSession lưu đăng nhập và giỏ hàng.

Công nghệ theo SRS/cấu hình: Java 17, Jakarta Servlet/JSP, Tomcat 10.1, SQL Server, NetBeans/Ant, HTML/CSS/JavaScript. Context path `/TechStore`. Không có dự án React/Vue, `package.json` hay cấu hình Spring/Maven/Gradle trong repo. Bootstrap được SRS cho phép, không bắt buộc; hiện chưa được tích hợp.

## 3. Hiện trạng thực tế

| Thành phần | Đã có | Còn thiếu / vấn đề |
|---|---|---|
| Database | Script 8 bảng, khóa ngoại, CHECK, indexes, 2 views, procedure hủy đơn, seed | Chưa xác minh thực thi trên SQL Server |
| Model | 5 lớp dữ liệu với thuộc tính/getter/setter | Chưa có model riêng cho Customer, Brand, Category; có thể bổ sung theo cách thiết kế DAO |
| Mật khẩu | PasswordUtil có hash/verify PBKDF2-HMAC-SHA256 | Chưa nối vào luồng đăng ký/đăng nhập |
| JDBC | DBContext có đoạn mở kết nối | Thông số cố định theo máy tác giả; chưa có quản lý vòng đời kết nối rõ ràng |
| AccountDAO | Có 2 phương thức tìm tài khoản và kiểm tra trùng | Có lỗi đọc ResultSet và bind tham số; chưa có CRUD đầy đủ |
| ProductDAO, OrderDAO | Có file/lớp | Chưa có phương thức nghiệp vụ |
| Controller | 8 lớp có tên Servlet | Đều rỗng, chưa kế thừa HttpServlet, chưa có mapping/doGet/doPost |
| Frontend | 13 JSP trong views và index.jsp | Tất cả vẫn là Hello World; chưa có form, danh sách hay dữ liệu động |
| CSS/JS/ảnh | Có file style.css | CSS chỉ có comment; chưa có file JS/ảnh được theo dõi |

Kết luận: dự án đang ở giai đoạn tạo cấu trúc và chuẩn bị database/model. Chưa có luồng website hay CRUD hoàn chỉnh có thể suy ra từ mã nguồn hiện tại.

## 4. Yêu cầu frontend bắt buộc theo SRS (P1)

| Màn hình / file hiện có | Nội dung cần làm | Yêu cầu |
|---|---|---|
| `home.jsp` | Thanh điều hướng; sản phẩm nổi bật, mới và bán chạy từ SQL; tìm theo tên; lọc danh mục/thương hiệu/khoảng giá; sắp xếp giá tăng/giảm và mới nhất | FR-07–10 |
| Catalog trong `home.jsp` hoặc trang riêng | Phân trang phía server, 10 sản phẩm/trang, giữ nguyên bộ lọc và từ khóa khi chuyển trang | FR-10 |
| `product-detail.jsp` | Ảnh, tên, thương hiệu, danh mục, giá, tồn kho, mô tả, thời hạn bảo hành, thêm giỏ; sản phẩm liên quan theo danh mục/thương hiệu | FR-11–12 |
| `register.jsp` | Username, email, mật khẩu và thông tin khách hàng bắt buộc; báo trùng và sai dữ liệu | FR-01 |
| `login.jsp` + thao tác đăng xuất | Đăng nhập bằng username/mật khẩu; thông báo chung khi sai; logout kết thúc session | FR-02–03 |
| `profile.jsp` | Sửa hồ sơ; đổi mật khẩu có nhập mật khẩu hiện tại | FR-04 |
| `cart.jsp` | Danh sách hàng, số lượng, giá, thành tiền/tổng tiền; thêm, cập nhật, xóa; phản hồi khi hết hàng | FR-13–14 |
| `checkout.jsp` | Yêu cầu đăng nhập khách hàng; người nhận, điện thoại, địa chỉ; xác nhận COD và kết quả đặt hàng | FR-15–16 |
| `order-history.jsp` | Đơn của chính khách hàng, trạng thái, chi tiết từng sản phẩm; hủy đơn PENDING | FR-17–18 |
| `admin/products.jsp`, `admin/product-form.jsp` | Danh sách, xem, thêm, sửa, ngừng kinh doanh; cập nhật tồn kho, xem hàng ít tồn | FR-19, FR-22 |
| `admin/users.jsp` | Danh sách/chi tiết, tạo, sửa, vô hiệu hóa tài khoản khách hàng; cần bổ sung form hoặc modal | FR-20 |
| `admin/orders.jsp` | Danh sách/chi tiết đơn và cập nhật trạng thái được phép | FR-21 |
| `admin/dashboard.jsp` | Số đơn, doanh thu, giá trị đơn trung bình, bán chạy, thống kê tồn kho | FR-23 |

Chưa có JSP riêng cho chi tiết đơn và form tài khoản admin; có thể bổ sung hoặc hiển thị trong trang hiện có. Đây là gợi ý tổ chức giao diện, không phải quy định tên file trong SRS.

Các yêu cầu giao diện dùng chung (SRS mục 5–7):

- Nhãn tiếng Việt, UTF-8; giá VND; ngày `dd/MM/yyyy`; giờ theo Việt Nam.
- Lỗi validation đặt gần trường tương ứng; thông báo thành công/thất bại dễ hiểu.
- Bố cục dùng tốt ở kích thước laptop thông thường, không cuộn ngang toàn trang. SRS không đặt yêu cầu riêng về ứng dụng mobile.
- Catalog/tìm kiếm phản hồi trong 3 giây với dữ liệu mẫu và tải demo thông thường.
- Hiển thị ảnh thay thế nếu `ImageURL` NULL, vì seed hiện chưa cung cấp ảnh sản phẩm.
- Escape dữ liệu người dùng khi render HTML. Ẩn nút theo vai trò cần đi kèm kiểm tra quyền ở server.

SRS chưa quy định màu chủ đạo, font, mockup, hiệu ứng, thư viện frontend bắt buộc hoặc pixel-perfect layout. Nhóm có thể tự chọn phong cách trong các ràng buộc trên.

## 5. Phạm vi CRUD

CRUD = Create (thêm), Read (đọc), Update (sửa), Delete (xóa). Với sản phẩm/tài khoản trong yêu cầu này, thao tác xóa được thể hiện bằng vô hiệu hóa.

| Đối tượng | Create | Read | Update | Delete / vô hiệu hóa | Quyền và phạm vi |
|---|---|---|---|---|---|
| Product | Thêm sản phẩm | Catalog/chi tiết, danh sách admin | Sửa thông tin, giá, ảnh, danh mục, thương hiệu, tồn kho | `IsActive=0`; giữ dòng đã được đơn hàng tham chiếu | Admin ghi; Guest/Customer đọc catalog đang hoạt động; FR-19,22 |
| UserAccount + Customer | Khách tự đăng ký; admin tạo khách hàng | Hồ sơ của mình; admin xem khách hàng | Sửa hồ sơ, đổi mật khẩu; admin sửa thông tin khách hàng | Vô hiệu hóa tài khoản qua `IsActive=0` | FR-01,04,20; không suy rộng thành quyền tự nâng role |
| Giỏ hàng trong session | Thêm hàng | Xem giỏ/tổng | Đổi số lượng | Bỏ hàng | Customer; FR-13–14; không có bảng Cart trong SQL |
| Invoice + InvoiceDetail | Checkout tạo đơn và chi tiết | Khách xem đơn của mình; admin xem đơn | Khách hủy PENDING; admin đổi trạng thái hợp lệ | Không yêu cầu xóa vật lý; giữ lịch sử | FR-15–18,21; không phải CRUD tự do mọi trường |
| Tồn kho | Không có yêu cầu CRUD phiếu nhập kho riêng | Số lượng/hàng ít tồn | Admin bổ sung kho; hệ thống trừ/hoàn khi đặt/hủy | Không áp dụng | FR-22; không được âm kho |
| Brand, Category | Chưa có yêu cầu màn hình CRUD riêng | Dữ liệu bộ lọc và chọn khi sửa/thêm sản phẩm | Chưa có yêu cầu CRUD riêng | Chưa có yêu cầu CRUD riêng | Cần đọc dữ liệu; không tự coi CRUD hai bảng này là P1 |
| ProductReview | Đánh giá sao và bình luận | Hiện trên chi tiết | SRS chưa yêu cầu | SRS chưa yêu cầu | FR-25, tùy chọn P2 |

Form sản phẩm cần bám schema: ProductName, BrandID, CategoryID, Description, Price, StockQuantity, WarrantyPeriod, ImageURL, IsFeatured, IsActive. ID/ngày tạo do hệ thống quản lý. Giá > 0, tồn kho >= 0, bảo hành >= 0; phải kiểm tra cả ở server.

Luồng tài khoản khách hàng phải cập nhật đúng liên kết `UserAccount.CustomerID → Customer.CustomerID`. Đăng ký/tạo khách hàng nên dùng transaction vì ghi hai bảng. Mật khẩu lưu qua PasswordUtil, không lưu nguyên văn.

## 6. Ràng buộc nghiệp vụ khi nối frontend với CRUD

1. Chỉ tài khoản active được đăng nhập; username/email duy nhất. Khu vực admin phải kiểm tra vai trò phía server. Khách chỉ được thao tác hồ sơ/đơn của mình (FR-05, BR-01,05,06).
2. Giỏ hàng lưu trạng thái trong session; số lượng phải dương. Không tin giá, tổng tiền, CustomerID hoặc role do trình duyệt gửi.
3. Checkout dùng cùng một JDBC transaction: kiểm tra dữ liệu/giá từ DB, trừ tồn có điều kiện `StockQuantity >= quantity` và `IsActive=1`, tạo Invoice PENDING, tạo InvoiceDetail với giá tại thời điểm mua; chỉ commit khi tất cả thành công. Bất kỳ bước nào lỗi đều rollback. Không thêm trigger trừ kho lần nữa.
4. Gọi `dbo.sp_CancelPendingOrder` để hủy đơn PENDING và hoàn kho đúng một lần. Procedure kiểm tra InvoiceID + CustomerID + trạng thái. Java vẫn phải xác thực chủ đơn hoặc quyền admin trước khi gọi.
5. Các giá trị trạng thái là `PENDING`, `CONFIRMED`, `COMPLETED`, `CANCELLED`. Không cho đơn CANCELLED hoàn thành sau đó. Cần thống nhất các chuyển trạng thái được phép; procedure hiện có chỉ xử lý hủy PENDING, chưa xử lý hủy CONFIRMED.
6. Doanh thu và lượng bán chạy chỉ tính đơn COMPLETED. Giá InvoiceDetail giữ nguyên khi giá Product thay đổi. Không xóa vật lý sản phẩm đã bán hoặc lịch sử đơn hàng.
7. Dùng PreparedStatement cho dữ liệu đầu vào. Quy tắc sắp xếp động nên chọn từ danh sách cột/chiều hợp lệ. Đối chiếu IsActive khi hiển thị catalog và khi checkout.

## 7. Database mới và chỗ SRS cần sửa

SQL hiện tạo 8 bảng: Brand, Category, Customer, UserAccount, Product, Invoice, InvoiceDetail, ProductReview.

- `vw_ProductCatalog`: nối sản phẩm/thương hiệu/danh mục và số lượng đã bán của đơn COMPLETED.
- `vw_OrderTotals`: tổng tiền và tổng số lượng theo đơn.
- `sp_CancelPendingOrder`: hủy đơn PENDING của khách hàng và hoàn kho trong transaction.
- Seed có 4 danh mục, 10 thương hiệu, tài khoản demo và 9 đơn lịch sử COMPLETED. Số lượng tồn kho seed là tồn hiện tại, không trừ lại vì các đơn lịch sử này.

SRS mục 2.1, 4.1, 4.2, 4.4 và phụ lục vẫn dựa trên database cũ 12 bảng cùng các phần mở rộng. SQL mới không có Employee, Location, Customer_Phone, Brand_Phone, TierRule, MembershipCard hoặc WarrantyCard. Customer mới dùng FullName/Phone/DefaultAddress; Product dùng khóa ngoại CategoryID; UserAccount không có EmployeeID.

README trong TechStore yêu cầu chỉnh lại SRS theo database 8 bảng, đồng thời bỏ hoặc để ngoài phạm vi FR-27 về thành viên/bảo hành. Cần phân biệt: hiển thị thời hạn bảo hành trên Product (FR-11, có WarrantyPeriod) vẫn thuộc P1; quản lý phiếu bảo hành/tích điểm (FR-27) không có schema trong bản SQL này.

## 8. Lỗi và trở ngại đã thấy

| Vị trí | Nhận xét từ mã nguồn | Ảnh hưởng |
|---|---|---|
| `src/java/dao/AccountDAO.java:15–19` | Đọc cột ResultSet trước khi gọi `rs.next()` | Tìm tài khoản không đọc được dòng theo cách JDBC yêu cầu |
| `AccountDAO.java:19–21` | Gán CustomerID vào accountId; không gán AccountID thật và customerId | Sai định danh và liên kết tài khoản/khách hàng |
| `AccountDAO.java:42–43` | Cả name và email đều bind vị trí 1, thiếu vị trí 2 | Truy vấn kiểm tra trùng phát sinh lỗi; catch lại trả false, có thể báo nhầm là chưa tồn tại |
| `AccountDAO.java:27–28` | Gán role lặp | Dư thừa, cần dọn khi hoàn thiện |
| `src/java/controller/` | Lớp rỗng, chưa là HttpServlet thực sự | Chưa có URL nghiệp vụ và xử lý request |
| `nbproject/project.properties:29–32` | JAR tham chiếu đường dẫn tuyệt đối trên máy tác giả; repo không kèm thư viện | Cần cấu hình lại JDBC/JSTL để build trên máy khác |
| `nbproject/private/private.properties` | Đường dẫn Tomcat/NetBeans theo máy tác giả | Cần chọn lại server local |
| `src/java/dal/DBContext.java` | Thông tin đăng nhập/instance SQL cố định; lỗi kết nối được log nhưng không làm constructor thất bại | Phải cấu hình đúng máy; DAO có thể gặp connection null nếu kết nối lỗi |
| `web/` | Chưa có form/giao diện thật; ảnh seed NULL | Phần frontend phải triển khai gần như toàn bộ |

Không sửa các lỗi nghiệp vụ trong lần phân tích này. Mã nguồn clone giữ nguyên; chỉ thêm bản báo cáo này.

## 9. Mức ưu tiên và thứ tự triển khai đề xuất

P1 bắt buộc: FR-01–05 và FR-07–23. P2 tùy chọn: FR-06 (reset mật khẩu qua email), FR-24 (lọc thống kê theo thời gian), FR-25 (review), FR-26 (AJAX), FR-27 (thành viên/bảo hành theo dữ liệu cũ, cần loại khỏi phạm vi nếu giữ SQL mới).

Thứ tự đề xuất, không phải lịch bắt buộc trong SRS:

1. Chốt SRS theo SQL mới; cấu hình Java 17/Tomcat/JAR/DB; xác minh script trên SQL Server.
2. Sửa AccountDAO, làm đăng ký/đăng nhập/đăng xuất, hồ sơ, đổi mật khẩu và kiểm tra quyền.
3. Làm ProductDAO, catalog/chi tiết và CRUD sản phẩm admin, bổ sung dữ liệu Brand/Category cho bộ lọc/form.
4. Làm giỏ hàng → checkout transaction → lịch sử/chi tiết/hủy đơn.
5. Làm CRUD khách hàng admin, quản lý trạng thái đơn, cập nhật kho và dashboard.
6. Hoàn thiện thông báo/validation/định dạng giao diện; kiểm tra quyền, hết hàng, rollback, hủy lặp và giữ lịch sử giá; sau đó mới chọn P2.

Phạm vi hiện tại là phân tích repo. Chưa thực hiện cài thư viện, thay cấu hình, khởi tạo database hoặc triển khai các chức năng trên.
