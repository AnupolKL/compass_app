# Week12 — Django JWT + OpenID Connect + Flutter

Branch นี้ประกอบด้วย 4 โปรเจกต์แยกกัน:

| โฟลเดอร์ | ประเภท | คำอธิบาย |
|----------|--------|----------|
| `backend1/` | Django + SimpleJWT | REST API สำหรับ JWT authentication |
| `backend2/` | Django + django-oidc-provider | OpenID Connect (OIDC) Server |
| `frontend1/` | Flutter Web | Login ด้วย JWT ผ่าน backend1 |
| `frontend2/` | Flutter Web | Login ด้วย OIDC ผ่าน backend2 |

---

## สิ่งที่ต้องติดตั้งก่อน

- Python 3.10+
- Flutter SDK 3.x
- pip
- Google Chrome

---

## วิธีรัน backend1 (Django JWT)

```powershell
cd backend1

# ติดตั้ง dependencies
pip install -r requirements.txt

# สร้าง database
python manage.py migrate

# สร้าง default user (admin / admin123)
python manage.py seed_users

# รัน server ที่ port 8000
python manage.py runserver
```

เปิด browser ไปที่ `http://localhost:8000/admin/` เพื่อเข้า Django Admin

### Endpoints

| Method | URL | คำอธิบาย |
|--------|-----|----------|
| POST | `/api/token/` | รับ username/password → คืน access + refresh token |
| POST | `/api/token/refresh/` | รับ refresh token → คืน access token ใหม่ |

### ทดสอบด้วย PowerShell

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/api/token/" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"username": "admin", "password": "admin123"}'
```

---

## วิธีรัน backend2 (Django OIDC Provider)

> เปิด **terminal ใหม่** แยกจาก backend1

```powershell
cd backend2

# ติดตั้ง dependencies (รวม django-cors-headers)
pip install -r requirements.txt
pip install django-cors-headers

# สร้าง database
python manage.py migrate

# สร้าง default user + OIDC Client
python manage.py seed_oidc

# รัน server ที่ port 8001
python manage.py runserver 8001
```

เปิด browser ไปที่ `http://localhost:8001/openid/.well-known/openid-configuration` เพื่อตรวจสอบ OIDC Discovery

### OIDC Endpoints

| URL | คำอธิบาย |
|-----|----------|
| `/openid/.well-known/openid-configuration` | Discovery document |
| `/openid/authorize` | Authorization endpoint |
| `/openid/token` | Token endpoint |
| `/openid/userinfo` | UserInfo endpoint |

---

## วิธีรัน frontend1 (Flutter JWT App)

> ต้องให้ **backend1** รันอยู่ก่อน

```powershell
cd frontend1

# สร้าง platform files (ทำครั้งแรกครั้งเดียว)
flutter create .

# ติดตั้ง packages
flutter pub get

# รัน app บน Chrome
flutter run -d chrome
```

เปิด Chrome แล้วกรอก:
- **Username**: `admin`
- **Password**: `admin123`

กด Login → จะได้รับ access token และ refresh token จาก backend1

---

## วิธีรัน frontend2 (Flutter OIDC App)

> ต้องให้ **backend2** รันอยู่ก่อน

```powershell
cd frontend2

# สร้าง platform files (ทำครั้งแรกครั้งเดียว)
flutter create .

# ติดตั้ง packages
flutter pub get

# รัน app บน Chrome ที่ port 4200 (สำคัญ!)
flutter run -d chrome --web-port 4200
```

> ⚠️ **ต้องรันที่ port 4200 เท่านั้น** เพราะ backend2 ลงทะเบียน redirect_uri ไว้ที่ `http://localhost:4200`

กด **Login with OIDC** → browser จะ redirect ไปหน้า login ของ backend2 → กรอก `admin` / `admin123` → กด Login → redirect กลับมาพร้อม token

---

## สรุปการรันทั้งหมด (ต้องการ 4 terminal)

```
Terminal 1: cd backend1  → python manage.py runserver
Terminal 2: cd backend2  → python manage.py runserver 8001
Terminal 3: cd frontend1 → flutter run -d chrome
Terminal 4: cd frontend2 → flutter run -d chrome --web-port 4200
```

---

## วิธี Push ขึ้น GitHub

### 1. ตรวจสอบว่าอยู่ใน branch week12

```powershell
cd d:\Flutter_clone_compass_app\compass_app
git branch
# ต้องเห็น * week12
```

### 2. ดู remote ที่เชื่อมอยู่

```powershell
git remote -v
# ควรเห็น origin → https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

### 3. Push branch week12 ขึ้น GitHub

```powershell
git push -u origin week12
```

- ระบบจะขอ **username** และ **password (Personal Access Token)**
- ถ้ายังไม่มี PAT ให้สร้างที่: GitHub → Settings → Developer settings → Personal access tokens → Generate new token (เลือก scope: `repo`)

### 4. ตรวจสอบบน GitHub

เปิด `https://github.com/YOUR_USERNAME/YOUR_REPO/tree/week12` จะเห็น branch week12 พร้อม 4 โฟลเดอร์

### 5. Push ครั้งต่อไป (หลัง commit ใหม่)

```powershell
# แก้ไขไฟล์แล้ว...
git add .
git commit -m "week12: your commit message"
git push
```

---

## โครงสร้างโปรเจกต์

```
compass_app/          ← Git repository root (branch: week12)
├── backend1/         ← Django JWT Server (port 8000)
│   ├── manage.py
│   ├── requirements.txt
│   ├── backend1/
│   │   ├── settings.py
│   │   └── urls.py
│   └── api/
│       └── management/commands/seed_users.py
├── backend2/         ← Django OIDC Server (port 8001)
│   ├── manage.py
│   ├── requirements.txt
│   ├── backend2/
│   │   ├── settings.py
│   │   └── urls.py
│   └── oidc_setup/
│       └── management/commands/seed_oidc.py
├── frontend1/        ← Flutter JWT App (Chrome)
│   ├── pubspec.yaml
│   └── lib/main.dart
└── frontend2/        ← Flutter OIDC App (Chrome port 4200)
    ├── pubspec.yaml
    └── lib/main.dart
```
