# Nguyễn Tùng Thái — Cart, Orders & Statistics

## Luồng xử lý để thuyết trình

1. `CartServlet`: nhận thao tác thêm, sửa, xóa. Giỏ hàng là `Map<Integer, CartItem>` lưu trong Session; khóa là mã sản phẩm. Thêm sản phẩm đã có thì cộng số lượng.
2. `CartItem`: giữ sản phẩm và số lượng. Thành tiền = đơn giá × số lượng; dùng `BigDecimal` theo kiểu giá của Product có sẵn.
3. `OrderServlet`: kiểm tra đăng nhập, nhận thông tin giao hàng và gọi `OrderDAO.checkout()`. Thành công thì xóa giỏ và chuyển sang lịch sử.
4. `OrderDAO`: dùng `PreparedStatement` để trừ kho, thêm Invoice, lấy mã đơn vừa tạo và lặp để thêm InvoiceDetail. Transaction giúp các bước cùng thành công; có lỗi thì rollback.
5. Lịch sử chỉ truy vấn đơn theo CustomerID của tài khoản trong Session. Khách chỉ được hủy đơn PENDING của mình.
6. `AdminOrderServlet`: chỉ Admin được chuyển PENDING → CONFIRMED → COMPLETED hoặc hủy khi PENDING. Hủy sử dụng procedure hoàn kho đã có trong SQL của nhóm.
7. `AdminDashboardServlet`: lấy tổng số đơn, doanh thu đơn COMPLETED và sản phẩm bán chạy bằng COUNT, SUM, GROUP BY.

## Các phần hỗ trợ nhỏ

- `OrderSupport`: dùng chung việc lấy giỏ, tính tổng, kiểm tra tài khoản và token biểu mẫu. Token được lưu trong Session và gửi qua input hidden để kiểm tra khi POST.
- `synchronized` trên Session: xử lý lần lượt thay đổi giỏ cùng một phiên, hạn chế bấm đặt hàng hai lần cùng lúc. Đây là phần bảo vệ bổ sung, không phải luồng nghiệp vụ chính.
- JSP dùng EL/JSTL để lặp danh sách, kiểm tra điều kiện và định dạng tiền; CSS riêng ở `orders.css`.

## Demo khoảng 5 phút

1. Vào `/cart`, chọn sản phẩm, thêm hai lần để thấy cộng số lượng; sửa số lượng rồi xóa một dòng.
2. Đăng nhập Customer bằng chức năng của nhóm, vào `/checkout`, nhập thông tin và đặt hàng COD.
3. Vào `/orders` xem đơn và chi tiết. Thử hủy một đơn PENDING để minh họa hoàn kho.
4. Đăng nhập Admin, vào `/admin/orders`, xác nhận rồi hoàn tất một đơn khác.
5. Vào `/admin/dashboard`, chỉ ra doanh thu chỉ tính đơn hoàn tất và bảng sản phẩm bán chạy.

Không thêm framework hay thư viện mới. Các trang sản phẩm, đăng nhập và SQL của nhóm được giữ nguyên. Hiện trang giỏ có ô chọn sản phẩm riêng để demo đủ luồng mà không sửa trang của thành viên khác.
