# TechStore PRJ301 — Database mới (Nhóm 1)

**Thành viên:** Nguyễn Tùng Thái — Vũ Hồng Quang — Khuất Bá Tình.

## File
- `TechStore_PRJ301_Full_Create_Seed.sql`: tạo database `TechStore_PRJ301` **hoàn toàn từ đầu**, 8 bảng + 2 views + procedure hủy đơn + dữ liệu mẫu.
- `PasswordUtil.java`: lớp mã hóa và kiểm tra mật khẩu PBKDF2. Copy vào package `util` trong dự án NetBeans (Java 11/17+).

## Chạy trong SQL Server Management Studio
1. Mở SSMS, kết nối đúng SQL Server.
2. Mở file `.sql` bằng File > Open > File; nhấn **Execute (F5)** để chạy toàn bộ.
3. Refresh Databases -> `TechStore_PRJ301` -> Tables.
4. Cuối script có câu SQL kiểm tra số dòng và báo cáo doanh thu.
5. Trong Java sửa `DBContext` dùng databaseName=`TechStore_PRJ301`.

## Bảng
1. Brand — thương hiệu.
2. Category — danh mục.
3. Customer — hồ sơ người mua.
4. UserAccount — đăng ký/đăng nhập, admin/customer, mật khẩu hash.
5. Product — sản phẩm, ảnh, giá, kho, nổi bật, trạng thái.
6. Invoice — đơn hàng và trạng thái.
7. InvoiceDetail — các sản phẩm đã đặt, giữ giá tại thời điểm mua.
8. ProductReview — tùy chọn: đánh giá sao và bình luận.

## Tài khoản demo (LOCAL ONLY)
- `admin` / `Admin@123456` — ADMIN.
- `customer1` / `Customer@123456` — CUSTOMER.
- `customer2` / `Customer@123456` — CUSTOMER.
- `customer3` / `Customer@123456` — CUSTOMER.

**QUAN TRỌNG:** SQL chỉ lưu PBKDF2 hash, không lưu password plaintext. Login Java phải gọi `PasswordUtil.verifyPassword(password, storedHash)`. Khi đăng ký/đổi mật khẩu, gọi `PasswordUtil.hashPassword(password)` và lưu kết quả. Thay thông tin demo trước khi triển khai công khai.

## Checkout bắt buộc theo transaction
**Không có trigger tự trừ kho** nhằm tránh bị trừ 2 lần.

1. Bắt đầu JDBC transaction: `connection.setAutoCommit(false)`.
2. Đối với từng sản phẩm, chạy `UPDATE Product SET StockQuantity=StockQuantity-? WHERE ProductID=? AND IsActive=1 AND StockQuantity>=?`.
3. `executeUpdate()` phải trả về 1; nếu trả 0, rollback vì hết hàng.
4. Insert Invoice (PENDING), đọc `getGeneratedKeys()` cho InvoiceID.
5. Insert InvoiceDetail với `UnitPrice` lấy từ DB, không tin giá từ client.
6. Commit sau khi tất cả chi tiết thành công; thất bại thì rollback. Nếu có nhiều mặt hàng, nên xử lý theo thứ tự ProductID cố định để giảm deadlock.
7. Hủy đơn của khách (`PENDING`): gọi `EXEC dbo.sp_CancelPendingOrder @InvoiceID=?, @CustomerID=?`. Procedure sẽ hoàn trả kho đúng một lần.

**Lưu ý:** Mọi tham số ID, giá, số lượng đều phải kiểm tra ở server. Cập nhật trạng thái `COMPLETED` chỉ từ luồng Admin có xác thực; doanh thu và bán chạy chỉ tính những đơn `COMPLETED`.

## Query học tập
```sql
USE TechStore_PRJ301;
SELECT TOP 10 * FROM dbo.vw_ProductCatalog WHERE IsActive=1 ORDER BY ProductID;
SELECT * FROM dbo.vw_OrderTotals ORDER BY DateCreated DESC;
SELECT TOP 5 ProductName,UnitsSold FROM dbo.vw_ProductCatalog ORDER BY UnitsSold DESC;
```

## Khác biệt so với SRS cũ
SRS trước mô tả 12 bảng của đồ án CSD, với thẻ thành viên và bảo hành. **Database mới chủ động tối giản còn 8 bảng**. Khi chốt SRS, phải đổi mục 2.1/4.1/4.2/4.4 và bỏ hoặc để ngoài phạm vi FR-27 (Membership/Warranty), thay vì ghi là hệ thống đã có những bảng đó.

## Lưu ý triển khai
- `ImageURL` của dữ liệu mẫu là NULL: JSP hiện ảnh mặc định nếu NULL.
- Giá trong SQL là **dữ liệu ví dụ**, không phải bảng giá cập nhật của hãng.
- SQL tạo 9 đơn lịch sử `COMPLETED` để test thống kê; số lượng `StockQuantity` là tồn kho hiện tại và không bị trừ lại.
- Dữ liệu chỉ được kiểm tra tĩnh, cần thực thi và kiểm tra trên SQL Server thật của nhóm.
