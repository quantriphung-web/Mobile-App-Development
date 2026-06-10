# Kế hoạch thực hiện cải tiến Database và Tái cấu trúc Backend

Tài liệu này ghi lại chi tiết các bước thiết kế cơ sở dữ liệu và cấu trúc lại mã nguồn Spring Boot backend để hỗ trợ các thực thể mới, đổi tên bảng người dùng cũ, chuyển khóa chính sang định dạng UUID và tích hợp cơ chế tự động thiết lập người tạo/người cập nhật mặc định.

---

## 1. Phân tích & Hướng giải quyết xung đột

### Kiểu dữ liệu tham chiếu khóa ngoại của `Role`
Trong yêu cầu gốc, bảng `roles` sử dụng khóa chính dạng `UUID` nhưng cột `role_id` trong `staff_accounts` lại dùng dạng số nguyên `INTEGER`. Điều này gây ra xung đột kiểu dữ liệu trong PostgreSQL (khóa ngoại bắt buộc phải trùng kiểu dữ liệu với cột được tham chiếu).
- **Giải pháp**: Đồng bộ hóa kiểu dữ liệu khóa chính của `roles` và khóa ngoại `role_id` của `staff_accounts` thành kiểu `UUID` để đảm bảo tính nhất quán trên toàn bộ cơ sở dữ liệu.

### Cơ chế tự động gán `created_by` và `updated_by`
- **Yêu cầu**: Cột `created_by` và `updated_by` tự động lấy ID của thực thể `StaffAccount` đầu tiên trong hệ thống nếu không truyền tham số này thủ công.
- **Giải pháp**: Xây dựng lớp trung gian `SpringContext` để lấy repository trong các hàm kiểm tra vòng đời của Hibernate (`@PrePersist`, `@PreUpdate`). Khi lưu một thực thể, nếu các trường kiểm toán này bị bỏ trống, hệ thống sẽ tự động tìm kiếm tài khoản staff có thời gian tạo sớm nhất để gán làm mặc định. Nếu đó là tài khoản đầu tiên (chưa có dữ liệu), hệ thống sẽ gán tham chiếu đến chính nó.

---

## 2. Các thay đổi và cấu trúc mã nguồn

### Các lớp Thực thể (`src/main/java/com/authapp/model`)
1. **`Role.java`**:
   - Ánh xạ bảng `roles`. Khóa chính dạng `UUID` tự sinh tự động thông qua `@GeneratedValue(strategy = GenerationType.UUID)`.
2. **`StaffAccount.java`** (Được phát triển từ thực thể `User.java` cũ):
   - Đổi tên thực thể `User` thành `StaffAccount` và đổi tên bảng ánh xạ thành `staff_accounts`.
   - Thay đổi kiểu khóa chính `id` từ dạng số tự tăng `Long` sang dạng chuỗi `UUID`.
   - Bổ sung quan hệ `@ManyToOne` liên kết với bảng `Role`.
   - Bổ sung và đồng bộ hóa các trường thông tin: `first_name`, `last_name`, `phone_number`, `password_hash`, `active`, `image`, `placeholder`.
   - Bổ sung quan hệ tự tham chiếu `@ManyToOne` cho `created_by` và `updated_by`.
   - Giữ lại các thuộc tính cũ (`emailVerified`, `provider`, `providerId`) phục vụ liên kết bảo mật mạng xã hội Google và Facebook.
3. **`RefreshToken.java`**:
   - Điều chỉnh kiểu thực thể liên kết từ `User` sang `StaffAccount` để tương thích khóa ngoại `UUID`.
4. **`Category.java`**:
   - Ánh xạ bảng `categories` hỗ trợ phân mục phân cấp dạng cây (`parent_id`).
   - Tích hợp kiểm toán tự động tìm tài khoản staff đầu tiên trong `@PrePersist` và `@PreUpdate`.
5. **`Product.java`**:
   - Ánh xạ bảng `products` chứa các thuộc tính liên quan đến quản lý sản phẩm.
   - Định cấu hình các ràng buộc kiểm tra đặc biệt (CHECK constraints) ở mức thực thể thông qua annotation `@org.hibernate.annotations.Check`:
     - Ràng buộc: `compare_price > sale_price OR compare_price = 0`
     - Ràng buộc kiểu sản phẩm: `product_type IN ('simple', 'variable')`
   - Tích hợp tự động điền thông tin người tạo/người sửa.
6. **`ProductCategory.java`**:
   - Ánh xạ bảng liên kết nhiều-nhiều trung gian giữa thực thể `Product` và `Category`.

### Các lớp Quản trị dữ liệu (`src/main/java/com/authapp/repository`)
- Xóa bỏ `UserRepository.java` cũ và thay thế bằng `StaffAccountRepository.java` kế thừa `JpaRepository<StaffAccount, UUID>`.
- Cấu hình lại các hàm tìm kiếm theo email và hàm hỗ trợ tìm tài khoản đầu tiên `findFirstByOrderByCreatedAtAsc()`.
- Cập nhật kiểu thực thể tham chiếu trong `RefreshTokenRepository.java`.
- Khởi tạo đầy đủ các repository mới: `RoleRepository`, `CategoryRepository`, `ProductRepository`, `ProductCategoryRepository`.

### Các lớp Nghiệp vụ & Bảo mật (`src/main/java/com/authapp/security` & `service` & `controller`)
- **`CustomUserDetailsService.java`**: Sửa phương thức `loadUserById` nhận tham số truyền vào là `UUID` và truy cập từ `StaffAccountRepository`.
- **`OAuth2AuthenticationSuccessHandler.java`**: Thay đổi cách tìm nạp và cập nhật người dùng thông qua thực thể `StaffAccount`.
- **`CustomOAuth2UserService.java`**: Bổ sung hàm xử lý phân tách họ và tên tài khoản từ thông tin đăng nhập Google/Facebook. Thiết lập các trường kiểm toán tự tham chiếu nếu đăng ký tài khoản đầu tiên qua OAuth2.
- **`RefreshTokenService.java`**: Thay đổi chữ ký các hàm dịch vụ (`createRefreshToken`, `deleteByUserId`) để sử dụng kiểu dữ liệu `UUID`.
- **`AuthService.java`**:
   - Đồng bộ hóa các luồng xử lý đăng ký, đăng nhập email/mật khẩu cũng như cơ chế đăng nhập từ Google và Facebook.
   - Thêm thuật toán kiểm soát gán người tạo mặc định cho tài khoản được đăng ký local.
- **`AuthController.java`**: Đồng bộ hóa toàn bộ các điểm cuối API: `/api/auth/login`, `/api/auth/register`, `/api/auth/refresh`, `/api/auth/logout`, `/api/auth/me` sang cấu hình của `StaffAccount`.
- **`AuthResponse.java`**: Thay đổi thuộc tính ID người dùng trong cấu trúc phản hồi JSON DTO sang định dạng dữ liệu `UUID`.

---

## 3. Quy trình xác thực hệ thống

### Kiểm tra tính hợp lệ cơ sở dữ liệu
- Khi khởi chạy dự án, kiểm tra xem PostgreSQL đã tạo đúng và đủ 6 bảng: `roles`, `staff_accounts`, `refresh_tokens`, `categories`, `products`, `product_categories`.
- Kiểm tra các ràng buộc khóa ngoại (foreign key) giữa các bảng.
- Xác nhận các ràng buộc `CHECK` của bảng `products` được thiết lập chính xác trên hệ quản trị cơ sở dữ liệu.

### Kiểm thử luồng nghiệp vụ
1. **Đăng ký tài khoản đầu tiên (Local)**:
   - Gửi yêu cầu đến `/api/auth/register`.
   - Xác nhận cơ sở dữ liệu đã gán thành công khóa chính là chuỗi `UUID`.
   - Xác nhận trường `created_by` và `updated_by` trong bảng `staff_accounts` tự động chứa giá trị trùng với khóa chính `id` của chính nó.
2. **Đăng ký tài khoản thứ hai (Local)**:
   - Đăng ký tài khoản tiếp theo.
   - Kiểm tra xem `created_by` và `updated_by` của tài khoản này có tự động tham chiếu đến ID của tài khoản đầu tiên hay không.
3. **Đăng nhập và Refresh Token**:
   - Đăng nhập qua `/api/auth/login` để lấy cặp token.
   - Sử dụng refresh token gửi đến `/api/auth/refresh` để nhận access token mới dạng `UUID` tương thích.
4. **Đăng nhập liên kết mạng xã hội**:
   - Thực hiện kiểm tra luồng login của Google hoặc Facebook để đảm bảo dữ liệu đăng ký tự động chia tách họ tên chuẩn xác và lưu dạng UUID không lỗi.

---

## 4. Giai đoạn 2: Nâng cấp tính năng Tags và ProductTags

### Phân tích yêu cầu & Thiết kế Database

#### 1. Bảng `tags`
Bảng lưu trữ thông tin nhãn (tag) cho sản phẩm.
- `id` (UUID, khóa chính): Tự động sinh UUID.
- `tag_name` (VARCHAR(255), NOT NULL): Tên của tag.
- `icon` (TEXT): Chuỗi icon đại diện cho tag.
- `created_at` / `updated_at` (TIMESTAMPTZ, NOT NULL): Thời gian tạo/cập nhật.
- `created_by` / `updated_by` (UUID, khóa ngoại): Liên kết đến bảng `staff_accounts` để lưu dấu vết người quản trị thao tác. Tự động gán nếu trống.

#### 2. Bảng `product_tags`
Bảng trung gian liên kết Nhiều-Nhiều giữa sản phẩm và nhãn tag.
- **Ràng buộc cột**:
  - `product_id` (UUID, NOT NULL): Tham chiếu tới `products(id)`.
  - `tag_id` (UUID, NOT NULL): Tham chiếu tới `tags(id)`.
- **Khóa chính**: Không dùng cột `id` UUID tự sinh riêng lẻ. Khóa chính sẽ là khóa chính hỗn hợp (composite key) của `(product_id, tag_id)` để đảm bảo tính duy nhất và đúng yêu cầu thiết kế tối giản.

---

### ---

### Lựa chọn thiết kế (Quyết định thống nhất)

> [!IMPORTANT]
> Dự án thống nhất chọn **Phương án A: Sử dụng `@ManyToMany` trực tiếp** trên thực thể `Product` để ánh xạ bảng trung gian `product_tags` chỉ gồm đúng 2 cột `product_id` và `tag_id`.
> - Xóa bỏ lớp thực thể `ProductTag.java` và repository `ProductTagRepository.java` (đã tạo nhầm ở bước trước).
> - Quản lý mối quan hệ Nhiều-Nhiều trực tiếp giữa `Product` và `Tag` thông qua `@ManyToMany` trong `Product.java`.

---

### Các thay đổi và cấu trúc mã nguồn mới

#### Lớp Thực thể (`src/main/java/com/authapp/model`)
1. **[NEW] [Tag.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/model/Tag.java)**:
   - Khai báo `@Entity` và `@Table(name = "tags")`.
   - Các cột: `id` (UUID), `tagName` (mapping `tag_name`), `icon`, `createdAt`, `updatedAt`, `createdBy`, `updatedBy`.
   - Sử dụng `@PrePersist` và `@PreUpdate` để tự động điền `createdAt`, `updatedAt`, và gọi `resolveAuditor()` để thiết lập tài khoản staff đầu tiên làm mặc định cho `createdBy`/`updatedBy` nếu không được truyền.
2. **[DELETE] [ProductTag.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/model/ProductTag.java)**: Xóa bỏ thực thể này.
3. **[MODIFY] [Product.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/model/Product.java)**:
   - Khai báo `@ManyToMany` với `Tag` kèm `@JoinTable`:
     ```java
     @ManyToMany(fetch = FetchType.LAZY)
     @JoinTable(
         name = "product_tags",
         joinColumns = @JoinColumn(name = "product_id"),
         inverseJoinColumns = @JoinColumn(name = "tag_id")
     )
     private List<Tag> tags = new ArrayList<>();
     ```

#### Lớp Repository (`src/main/java/com/authapp/repository`)
1. **[NEW] [TagRepository.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/repository/TagRepository.java)**:
   - Kế thừa `JpaRepository<Tag, UUID>`.
   - Khai báo hàm `Optional<Tag> findByTagName(String tagName);`
2. **[DELETE] [ProductTagRepository.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/repository/ProductTagRepository.java)**: Xóa bỏ repository này.

#### Lớp DTO (`src/main/java/com/authapp/dto`)
1. **[NEW] [TagRequest.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/dto/TagRequest.java)**:
   - Chứa `tagName` và `icon`.
2. **[NEW] [TagResponse.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/dto/TagResponse.java)**:
   - Chứa `id`, `tagName`, `icon`, `createdAt`, `updatedAt`.
3. **[MODIFY] [ProductRequest.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/dto/ProductRequest.java)**:
   - Thêm trường `private List<UUID> tagIds;` để nhận danh sách nhãn khi tạo/sửa sản phẩm.
4. **[MODIFY] [ProductResponse.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/dto/ProductResponse.java)**:
   - Thêm trường `private List<TagResponse> tags;` để phản hồi danh sách nhãn kèm theo sản phẩm.

#### Lớp Service (`src/main/java/com/authapp/service`)
1. **[NEW] [TagService.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/service/TagService.java)**:
   - Nghiệp vụ CRUD cho `Tag`: `getAll()`, `getById()`, `create()`, `update()`, `delete()`.
2. **[MODIFY] [ProductService.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/service/ProductService.java)**:
   - Cập nhật hàm `create()` và `update()` để gán trực tiếp danh sách `tags` tìm nạp từ `tagRepository` dựa trên `tagIds` từ request.
   - Cập nhật hàm `toResponse()` để điền thông tin danh sách `tags` của sản phẩm lấy từ mối quan hệ `@ManyToMany`.
   - Bổ sung hàm `addTag(UUID productId, UUID tagId)` và `removeTag(UUID productId, UUID tagId)`.

#### Lớp Controller (`src/main/java/com/authapp/controller`)
1. **[NEW] [TagController.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/controller/TagController.java)**:
   - Các endpoint CRUD cho `Tag`.
2. **[MODIFY] [ProductController.java](file:///d:/appLogin/java_backend/src/main/java/com/authapp/controller/ProductController.java)**:
   - Thêm các endpoint:
     - `POST /api/products/{productId}/tags/{tagId}`: Thêm tag vào sản phẩm.
     - `DELETE /api/products/{productId}/tags/{tagId}`: Xóa tag khỏi sản phẩm.

---

### Tài liệu Kiểm thử API Postman
Tạo mới 2 tài liệu kiểm thử:
1. **[NEW] [postman_api.md](file:///d:/appLogin/java_backend/implements/postman_api.md)**: Chứa thông tin mô tả chi tiết các HTTP request, URL, Headers và Request Body mẫu để thực hiện kiểm thử.
2. **[NEW] [check_postman_api.md](file:///d:/appLogin/java_backend/implements/check_postman_api.md)**: Chứa quy trình và kịch bản từng bước để gửi request và kiểm tra mã phản hồi (status code), cấu trúc JSON trả về.

---

### Quy trình xác thực hệ thống mới

#### Kiểm tra tính hợp lệ cơ sở dữ liệu
- Chạy hệ thống và xác nhận Hibernate tự động sinh thêm 2 bảng `tags` và `product_tags` với đúng kiểu dữ liệu và khóa ngoại.

#### Kiểm thử API (Manual Verification)
1. **Quản lý Tags**:
   - Tạo tag: `POST /api/tags` gửi body `{ "tagName": "Hot Sale", "icon": "fire" }`.
   - Kiểm tra xem `created_by` và `updated_by` có tự động điền tài khoản staff mặc định không.
   - Lấy danh sách tag: `GET /api/tags`.
2. **Tạo/Cập nhật Sản phẩm kèm Tags**:
   - Tạo sản phẩm mới kèm `tagIds`: `POST /api/products`.
   - Kiểm tra response có chứa danh sách `tags` không.
   - Kiểm tra DB trong bảng `product_tags` có lưu đúng cặp `product_id` và `tag_id`.
3. **Liên kết/Hủy liên kết Tag trực tiếp**:
   - Liên kết: `POST /api/products/{productId}/tags/{tagId}`.
   - Hủy liên kết: `DELETE /api/products/{productId}/tags/{tagId}`.

---

## 5. Giai đoạn 3: Tích hợp 28 Bảng dữ liệu còn lại từ exs201

### Phân tích yêu cầu & Thiết kế Database
Chúng ta sẽ bổ sung toàn bộ các thực thể, repository, service và controller còn thiếu từ dự án `exs201` sang `java_backend` (khoảng 28 bảng mới bao gồm: Suppliers, Coupons, Customers, Orders, Variants, v.v.).

#### Nguyên tắc chuyển đổi:
- **Giữ nguyên các thành phần cốt lõi đã có**: `StaffAccount`, `Role`, `Category`, `Product`, `Tag`, `RefreshToken` không bị ghi đè để bảo toàn logic OAuth2, phân quyền và JWT.
- **Đổi package**: Toàn bộ mã nguồn từ `com.nxdkhue.exs201` sẽ được chuyển sang `com.nxdkhue`.
- **Tự động điền dữ liệu audit**: Các bảng mới sẽ sử dụng `AuditDefaultsService` (của `exs201`) để tự động gán `createdBy` / `updatedBy` về tài khoản staff đầu tiên trong hệ thống dưới dạng `UUID`.

### Các thay đổi và cấu trúc mã nguồn

#### Thêm mới các Thực thể (`com.nxdkhue.model`)
- Attribute, AttributeValue, Card, CardItem, Country, Coupon, Customer, CustomerAddress, Gallery, Notification, Order, OrderItem, OrderStatus, ProductAttribute, ProductAttributeValue, ProductCoupon, ProductShippingInfo, ProductSupplier, ProductTag, Sell, ShippingCountryZone, ShippingRate, ShippingZone, Slideshow, Supplier, Variant, VariantOption, VariantValue

#### Thêm mới các Repository (`com.nxdkhue.repository`)
- Thêm mới 28 repository tương ứng với các thực thể trên kế thừa `JpaRepository`.

#### Thêm mới các Service & Service Implementation (`com.nxdkhue.service`)
- Thêm mới 28 interface dịch vụ và 28 lớp triển khai tương ứng.
- Thêm lớp hỗ trợ kiểm toán `AuditDefaultsService`.
- Thêm `ProductCategoryService` và `ProductCategoryServiceImpl` để hỗ trợ quan hệ bảng ProductCategory.

#### Thêm mới các Controller (`com.nxdkhue.controller`)
- Thêm mới 28 controller tương ứng để cung cấp các API CRUD.

#### Cập nhật các quan hệ Thực thể hiện tại
- **Product.java**: Bổ sung `@OneToMany` và `@OneToOne` trỏ đến `productCategories`, `productTags`, `galleries`, `variants`, `productAttributes`, `productCoupons`, `productShippingInfo`, `productSuppliers`, `sells`, `orderItems`, `cardItems`.
- **Category.java**: Bổ sung `@OneToMany` trỏ đến `productCategories`.
- **Tag.java**: Bổ sung `@OneToMany` trỏ đến `productTags`.

### Quy trình xác thực hệ thống
- Biên dịch thành công với Maven.
- Xác nhận khởi chạy Hibernate tạo thành công toàn bộ 34 bảng trên PostgreSQL database.

