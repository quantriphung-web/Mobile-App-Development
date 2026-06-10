# 🚀 HƯỚNG DẪN CHẠY BACKEND TỪ A ĐẾN Z
## (Laptop + Điện thoại cùng WiFi)

---

## 📋 YÊU CẦU CÀI ĐẶT

### 1. Cài Java 17
- Tải tại: https://adoptium.net/temurin/releases/?version=17
- Chọn: Windows x64 → .msi
- Sau khi cài, mở Terminal kiểm tra:
  ```
  java -version
  ```
  Phải thấy: `openjdk 17.x.x`

### 2. Cài Maven
- Tải tại: https://maven.apache.org/download.cgi
- Chọn: apache-maven-3.9.x-bin.zip
- Giải nén vào C:\maven
- Thêm vào PATH: `C:\maven\bin`
- Kiểm tra:
  ```
  mvn -version
  ```

### 3. Cài PostgreSQL
- Tải tại: https://www.postgresql.org/download/
- Cài với password: `postgres`
- Port mặc định: 5432

### 4. Cài Visual Studio Code
- Tải tại: https://code.visualstudio.com
- Cài Extension Pack for Java (từ Microsoft)
- Cài Spring Boot Extension Pack

---

## 🗄️ BƯỚC 1: TẠO DATABASE

Mở pgAdmin (hoặc psql) và chạy:

```sql
CREATE DATABASE authdb;
```

Hoặc dùng Terminal:
```bash
psql -U postgres -c "CREATE DATABASE authdb;"
```

---

## ⚙️ BƯỚC 2: CẤU HÌNH APPLICATION.PROPERTIES

Mở file: `src/main/resources/application.properties`

Kiểm tra các dòng sau:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/authdb
spring.datasource.username=postgres
spring.datasource.password=postgres   ← đổi nếu bạn dùng password khác
```

---

## 🖥️ BƯỚC 3: MỞ PROJECT TRONG VSCODE

1. Mở VSCode
2. File → Open Folder → chọn thư mục `auth-backend`
3. VSCode sẽ tự nhận Maven project
4. Chờ download dependencies (lần đầu ~2-5 phút)

---

## ▶️ BƯỚC 4: CHẠY BACKEND

### Cách 1: Dùng Terminal trong VSCode (Ctrl + `)
```bash
mvn spring-boot:run
```

### Cách 2: Click nút Run
- Mở file `AuthBackendApplication.java`
- Click nút ▶️ "Run" phía trên hàm main()

### ✅ Backend chạy thành công khi thấy:
```
Started AuthBackendApplication in X.XXX seconds
Tomcat started on port(s): 8080
```

---

## 📱 BƯỚC 5: KẾT NỐI ĐIỆN THOẠI CÙNG WIFI

### 5.1 Tìm IP của laptop

**Windows:**
```bash
ipconfig
```
Tìm dòng: `IPv4 Address . . . . : 192.168.1.X`

**Mac/Linux:**
```bash
ifconfig | grep "inet "
```

### 5.2 Kiểm tra firewall
Đảm bảo port 8080 không bị chặn:

**Windows:** 
- Windows Defender Firewall → Allow an app → Add port 8080

### 5.3 Test kết nối
Trên trình duyệt điện thoại, mở:
```
http://192.168.1.X:8080/api/auth/health
```
Thấy `{"success":true,"message":"Server is running!"}` là thành công ✅

---

## 📲 BƯỚC 6: CẬP NHẬT FLUTTER

### 6.1 Copy file đã cập nhật
- Copy `flutter_updated/api_service.dart` → `your_flutter_app/lib/services/`
- Copy `flutter_updated/login_screen.dart` → `your_flutter_app/lib/screens/`
- Copy `flutter_updated/sign_up_screen.dart` → `your_flutter_app/lib/screens/`

### 6.2 Đổi IP trong api_service.dart
Mở `lib/services/api_service.dart`, tìm dòng:
```dart
static const String baseUrl = 'http://192.168.1.X:8080/api';
```
Thay `192.168.1.X` bằng IP thực của laptop (từ bước 5.1)

### 6.3 Thêm dependencies vào pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.3
```

Chạy:
```bash
flutter pub get
```

### 6.4 Cấu hình Android để dùng HTTP (không phải HTTPS)
Tạo file `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">192.168.1.X</domain>
    </domain-config>
</network-security-config>
```

Thêm vào `android/app/src/main/AndroidManifest.xml` trong thẻ `<application`:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

---

## 🧪 BƯỚC 7: TEST API

### Test bằng curl (hoặc Postman):

**Register:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@gmail.com","password":"123456"}'
```

**Login:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@gmail.com","password":"123456"}'
```

**Get current user (cần Bearer token từ login):**
```bash
curl http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 🔑 BƯỚC 8: CẤU HÌNH OAUTH2 (tùy chọn)

### Google OAuth2:
1. Vào: https://console.cloud.google.com
2. Tạo project → Credentials → OAuth 2.0 Client ID
3. Application type: Web application
4. Authorized redirect URIs: `http://localhost:8080/login/oauth2/code/google`
5. Copy Client ID và Client Secret vào application.properties

### Facebook OAuth2:
1. Vào: https://developers.facebook.com
2. Tạo App → Facebook Login
3. Valid OAuth Redirect URIs: `http://localhost:8080/login/oauth2/code/facebook`
4. Copy App ID và App Secret vào application.properties

---

## 🐛 XỬ LÝ LỖI THƯỜNG GẶP

| Lỗi | Nguyên nhân | Cách sửa |
|-----|------------|---------|
| `Connection refused` | Backend chưa chạy | Chạy `mvn spring-boot:run` |
| `Could not connect to database` | PostgreSQL chưa chạy | Start PostgreSQL service |
| `Port 8080 already in use` | Port bị chiếm | Đổi `server.port=8081` |
| `Invalid email or password` | Sai thông tin | Kiểm tra lại |
| Flutter: `SocketException` | Sai IP hoặc firewall | Kiểm tra IP và port 8080 |
| Flutter: `cleartext not permitted` | Android chặn HTTP | Thêm network_security_config |

---

## 📁 CẤU TRÚC PROJECT

```
auth-backend/
├── pom.xml
├── src/main/java/com/nxdkhue/
│   ├── AuthBackendApplication.java
│   ├── controller/AuthController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   ├── RefreshTokenService.java
│   │   └── CustomOAuth2UserService.java
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── CustomUserDetailsService.java
│   │   └── oauth2/ (handlers + userInfo)
│   ├── model/ (User, RefreshToken, AuthProvider)
│   ├── repository/ (UserRepository, RefreshTokenRepository)
│   ├── dto/ (Request/Response classes)
│   ├── config/SecurityConfig.java
│   └── exception/ (handlers)
├── src/main/resources/application.properties
└── flutter_updated/
    ├── api_service.dart     ← THÊM VÀO lib/services/
    ├── login_screen.dart    ← THAY THẾ file cũ
    └── sign_up_screen.dart  ← THAY THẾ file cũ
```

---

## 🌐 API ENDPOINTS

| Method | URL | Mô tả | Auth |
|--------|-----|-------|------|
| POST | `/api/auth/register` | Đăng ký | ❌ |
| POST | `/api/auth/login` | Đăng nhập | ❌ |
| POST | `/api/auth/logout` | Đăng xuất | ✅ |
| POST | `/api/auth/refresh` | Refresh token | ❌ |
| GET  | `/api/auth/me` | Thông tin user | ✅ |
| GET  | `/api/auth/health` | Kiểm tra server | ❌ |
| GET  | `/oauth2/authorization/google` | Login Google | ❌ |
| GET  | `/oauth2/authorization/facebook` | Login Facebook | ❌ |
