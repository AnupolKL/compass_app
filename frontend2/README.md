# frontend2 — Flutter OIDC Authentication App

Flutter application สำหรับทดสอบการ authentication ด้วย **OpenID Connect (OIDC)** ผ่าน backend2

## Features

- 🔐 OIDC Authorization Code Flow ผ่าน `flutter_appauth`
- 🌐 เปิด browser-based login ของ backend2
- 💾 เก็บ id_token, access_token, refresh_token
- 🚪 Logout

## วิธีรัน

```bash
# 1. ติดตั้ง dependencies
flutter pub get

# 2. รัน app
flutter run
```

> **หมายเหตุ**: backend2 ต้องรันอยู่ก่อนที่ `http://localhost:8001`
> - Android Emulator ใช้ `http://10.0.2.2:8001`
> - iOS Simulator ใช้ `http://localhost:8001`

## การตั้งค่า Backend URL

แก้ค่า `issuer` ใน `lib/main.dart`:

```dart
class OidcConfig {
  static const String issuer = 'http://10.0.2.2:8001';  // Android Emulator
  // static const String issuer = 'http://localhost:8001'; // iOS Simulator
  static const String clientId = 'flutter-frontend2';
  static const String clientSecret = 'flutter-frontend2-secret';
  static const String redirectUri = 'com.example.frontend2://callback';
  ...
}
```

## Android — ตั้งค่า redirect URI

ต้องเพิ่มใน `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'com.example.frontend2'
        ]
    }
}
```

## iOS — ตั้งค่า redirect URI

เพิ่มใน `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.example.frontend2</string>
    </array>
  </dict>
</array>
```

## OIDC Flow

```
1. ผู้ใช้กดปุ่ม "Login with OIDC"
2. App เปิด browser → backend2 authorization endpoint
3. ผู้ใช้ login ด้วย admin / admin123
4. backend2 redirect กลับมาที่ com.example.frontend2://callback
5. App แลก authorization code เป็น tokens
6. แสดง id_token และ access_token บนหน้า Home
```

## OIDC Client Settings (จาก seed_oidc ใน backend2)

| รายการ | ค่า |
|--------|-----|
| client_id | `flutter-frontend2` |
| client_secret | `flutter-frontend2-secret` |
| redirect_uri | `com.example.frontend2://callback` |
| scopes | `openid email profile` |

## โครงสร้างโปรเจกต์

```
frontend2/
├── pubspec.yaml
├── lib/
│   └── main.dart
└── README.md
```
