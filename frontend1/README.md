# frontend1 — Flutter JWT Authentication App

Flutter application สำหรับทดสอบการ authentication ด้วย **JWT** ผ่าน backend1

## Features

- 🔐 Login form เรียก `POST /api/token/`
- 💾 เก็บ access token และ refresh token ด้วย `shared_preferences`
- 🔄 ปุ่ม Refresh token เรียก `POST /api/token/refresh/`
- 🚪 Logout ล้าง token

## วิธีรัน

```bash
# 1. ติดตั้ง dependencies
flutter pub get

# 2. รัน app (ต้องมี emulator หรือ device)
flutter run
```

> **หมายเหตุ**: backend1 ต้องรันอยู่ก่อน
> - Android Emulator ใช้ `http://10.0.2.2:8000`
> - iOS Simulator ใช้ `http://localhost:8000`
> - Physical Device ใช้ IP จริงของเครื่อง เช่น `http://192.168.x.x:8000`

## การตั้งค่า Backend URL

แก้ค่า `_baseUrl` ใน `lib/main.dart`:

```dart
// ใน _LoginPageState
static const String _baseUrl = 'http://10.0.2.2:8000';  // Android Emulator
// static const String _baseUrl = 'http://localhost:8000'; // iOS Simulator
```

## Default Credentials

| รายการ | ค่า |
|--------|-----|
| Username | `admin` |
| Password | `admin123` |

(สร้างด้วย `python manage.py seed_users` ใน backend1)

## หน้าจอ

| หน้า | คำอธิบาย |
|------|----------|
| Login Page | Form กรอก username/password กด Login → เรียก `/api/token/` |
| Home Page | แสดง access token, ปุ่ม Refresh Token, ปุ่ม Logout |

## โครงสร้างโปรเจกต์

```
frontend1/
├── pubspec.yaml
├── lib/
│   └── main.dart
└── README.md
```
