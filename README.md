# Flutter Samples

คอลเลกชัน Flutter Sample Apps จาก Flutter team ที่รวมตัวอย่างโปรเจคหลากหลาย เพื่อใช้เป็นแนวทางการพัฒนาแอปพลิเคชัน Flutter ในรูปแบบต่าง ๆ

---

## 🛠️ สิ่งที่ต้องติดตั้งก่อน

| เครื่องมือ | เวอร์ชันที่รองรับ |
|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | `>=3.9.0` |
| [Dart SDK](https://dart.dev/get-dart) | `>=3.9.0` |
| [Git](https://git-scm.com/) | ล่าสุด |

ตรวจสอบการติดตั้ง Flutter ด้วยคำสั่ง:

```bash
flutter doctor
```

---

## 📥 Clone โปรเจค

```bash
git clone https://github.com/AnupolKL/compass_app.git
cd compass_app
```

---

## 📂 โปรเจคที่มีให้

| โปรเจค | คำอธิบาย |
|---|---|
| `compass_app` | แอปวางแผนการเดินทาง (Featured App) |
| `animations` | ตัวอย่างการทำ Animation |
| `material_3_demo` | ตัวอย่าง Material Design 3 |
| `navigation_and_routing` | ตัวอย่าง Navigation & Routing |
| `testing_app` | ตัวอย่างการเขียน Test |
| `platform_design` | ตัวอย่าง Adaptive UI (iOS/Android) |
| `form_app` | ตัวอย่างการสร้าง Form |
| `date_planner` | ตัวอย่างแอปวางแผนตาราง |
| `google_maps` | ตัวอย่างการใช้ Google Maps |
| `web_embedding` | ตัวอย่าง Flutter บนเว็บ |

---

## 🚀 วิธีรันโปรเจค

### ▶️ รัน Compass App (แนะนำ)

**โหมด Development** (ใช้ข้อมูลจาก JSON ไฟล์ ไม่ต้องรัน Server):

```bash
cd compass_app/app
flutter run --target lib/main_development.dart
```

**โหมด Staging** (ต้องรัน Server ก่อน):

```bash
# Terminal 1 — รัน Server
cd compass_app/server
dart run
# Server จะรันที่ http://localhost:8080

# Terminal 2 — รัน Flutter App
cd compass_app/app
flutter run --target lib/main_staging.dart
```

---

### ▶️ รันโปรเจคอื่น ๆ

เปลี่ยนไปยังโฟลเดอร์ของโปรเจคที่ต้องการ แล้วรันด้วยคำสั่งมาตรฐาน:

```bash
cd <ชื่อโปรเจค>
flutter pub get
flutter run
```

**ตัวอย่าง:**

```bash
# รัน animations
cd animations
flutter pub get
flutter run

# รัน material_3_demo
cd material_3_demo
flutter pub get
flutter run
```

---

## 🧪 รัน Tests (สำหรับ Compass App)

**Unit / Widget Tests:**

```bash
cd compass_app/app
flutter test
```

**Integration Tests (ใช้ข้อมูล Local):**

```bash
cd compass_app/app
flutter test integration_test/app_local_data_test.dart
```

**Integration Tests (ใช้ Server):**

```bash
cd compass_app/app
flutter test integration_test/app_server_data_test.dart
```

> ⚠️ **หมายเหตุ:** อย่ารัน `flutter test integration_test` รวมกันทั้งหมด เพราะจะเกิด Error  
> ดูรายละเอียดที่ [flutter/flutter#101031](https://github.com/flutter/flutter/issues/101031)

---

## 📱 รันบน Device / Emulator เฉพาะ

```bash
# ดูรายการ Device ที่เชื่อมต่อ
flutter devices

# รันบน Device ที่ระบุ
flutter run -d <device_id>
```

---

## 📄 License

โปรเจคนี้อยู่ภายใต้ [BSD 3-Clause License](./LICENSE)
