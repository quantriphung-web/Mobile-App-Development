# backend

Flutter auth app + Express API + PostgreSQL + JWT.

## Flow

```text
[Flutter] login / signup
        |
[Backend Express] validate request and check PostgreSQL
        |
[PostgreSQL] store / verify user
        |
[Backend Express] create JWT token
        |
[Flutter] save token to SharedPreferences as auth_token
        |
[Postman] GET /me with Bearer token returns username
```

## PostgreSQL

Create a database named `backend`. The Express server creates this table
automatically when it starts:

```sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Express backend

Install Node.js first, then run:

```powershell
cd server
copy .env.example .env
npm install
npm run dev
```

Edit `server/.env`:

```env
PORT=3000
DATABASE_URL=postgres://postgres:your_password@localhost:5432/backend
JWT_SECRET=change_this_secret
JWT_EXPIRES_IN=1d
```

API routes:

```text
POST http://localhost:3000/signup
POST http://localhost:3000/login
GET  http://localhost:3000/me
```

Signup body:

```json
{
  "username": "demo",
  "email": "demo@example.com",
  "password": "123456"
}
```

Login body:

```json
{
  "email": "demo@example.com",
  "password": "123456"
}
```

Both return:

```json
{
  "token": "...",
  "user": {
    "id": 1,
    "username": "demo",
    "email": "demo@example.com"
  }
}
```

Postman `/me`:

```text
GET http://localhost:3000/me
Authorization: Bearer YOUR_TOKEN
```

Response:

```json
{
  "id": 1,
  "username": "demo",
  "email": "demo@example.com"
}
```

## Flutter

Install Flutter dependencies:

```powershell
flutter pub get
```

Run on Windows/web:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Run on Android emulator:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```
