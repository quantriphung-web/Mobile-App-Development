# Kế hoạch cải tiến và sửa đổi Backend (tasks.md)

Dưới đây là danh sách các đầu công việc chi tiết để thực hiện nâng cấp cơ sở dữ liệu và cấu trúc mã nguồn.

- [x] Tạo thư mục `implements` và file `tasks.md` <!-- id: 0 -->
- [x] Tạo Model `Role` và `RoleRepository` <!-- id: 1 -->
- [x] Chuyển đổi Model `User` thành `StaffAccount` (Sử dụng UUID làm khóa chính, thêm các thuộc tính mới, giữ lại các thuộc tính cũ của OAuth2) <!-- id: 2 -->
- [x] Cập nhật `RefreshToken` và `RefreshTokenRepository` theo kiểu UUID của `StaffAccount` <!-- id: 3 -->
- [x] Cấu hình lại Spring Security (`CustomUserDetailsService`, bộ lọc JWT) chuyển sang UUID và `StaffAccount` <!-- id: 4 -->
- [x] Cập nhật `AuthService` (Xử lý đăng ký, đăng nhập thường, Google, Facebook OAuth2) <!-- id: 5 -->
- [x] Viết hàm bổ trợ tự động tìm/gán `createdBy`/`updatedBy` lấy theo tài khoản staff đầu tiên làm mặc định <!-- id: 6 -->
- [x] Cập nhật `AuthController` (Đăng ký, Đăng nhập, Logout, Me) <!-- id: 7 -->
- [x] Tạo Model `Category` và `CategoryRepository` <!-- id: 8 -->
- [x] Tạo Model `Product` và `ProductRepository` (Có các ràng buộc CHECK) <!-- id: 9 -->
- [x] Tạo Model `ProductCategory` và `ProductCategoryRepository` <!-- id: 10 -->
- [x] Biên dịch dự án bằng Maven và kiểm tra sự chuẩn xác <!-- id: 11 -->
- [x] Tạo Model `Tag` và `TagRepository` <!-- id: 12 -->
- [x] Xóa bỏ Model `ProductTag` và `ProductTagRepository` (chuyển sang `@ManyToMany` trực tiếp) <!-- id: 13 -->
- [x] Tạo DTO `TagRequest` và `TagResponse` <!-- id: 14 -->
- [x] Tạo `TagService` để thực hiện các nghiệp vụ CRUD cho `Tag` <!-- id: 15 -->
- [x] Tạo `TagController` để quản lý API cho `Tag` (CRUD) <!-- id: 16 -->
- [x] Cập nhật `ProductRequest` và `ProductResponse` để tích hợp danh sách tag <!-- id: 17 -->
- [x] Cập nhật `ProductService` và `ProductController` để hỗ trợ liên kết tag cho sản phẩm <!-- id: 18 -->
- [x] Tạo tài liệu ví dụ API Postman `postman_api.md` <!-- id: 20 -->
- [x] Tạo tài liệu hướng dẫn kiểm thử `check_postman_api.md` <!-- id: 21 -->
- [x] Biên dịch dự án bằng Maven và kiểm thử chạy thực tế kiểm tra sự tạo bảng / API <!-- id: 19 -->
- [x] Sao chép 28 model mới từ `exs201` sang `java_backend` và đổi package thành `com.nxdkhue` <!-- id: 22 -->
- [x] Sao chép 28 repository mới từ `exs201` sang `java_backend` và đổi package thành `com.nxdkhue` <!-- id: 23 -->
- [x] Sao chép 28 service và service impl mới từ `exs201` (gồm `AuditDefaultsService`, `ProductCategoryService`) và đổi package <!-- id: 24 -->
- [x] Sao chép 28 controller mới từ `exs201` sang `java_backend` và đổi package thành `com.nxdkhue` <!-- id: 25 -->
- [x] Cập nhật các quan hệ `@OneToMany` trong `Product.java`, `Category.java`, `Tag.java` của `java_backend` <!-- id: 26 -->
- [x] Biên dịch toàn bộ dự án bằng Maven để kiểm tra tích hợp và tạo bảng <!-- id: 27 -->
- [x] Viết logic seeding tag và liên kết product-tag trong `DatabaseSeeder.java` để hiển thị sản phẩm trên frontend <!-- id: 28 -->


