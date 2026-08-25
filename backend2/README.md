# backend2 — Django OpenID Connect (OIDC) Provider

Django server ที่ทำหน้าที่เป็น **OpenID Connect Provider** โดยใช้ `django-oidc-provider`

## OIDC Endpoints

| Method | URL | คำอธิบาย |
|--------|-----|----------|
| GET | `/.well-known/openid-configuration` | Discovery document |
| GET/POST | `/openid/authorize` | Authorization endpoint |
| POST | `/openid/token` | Token endpoint |
| GET | `/openid/userinfo` | UserInfo endpoint |
| POST | `/openid/introspect` | Token introspection |
| GET | `/openid/end-session` | End session (logout) |
| GET | `/openid/.well-known/jwks.json` | JWKS keys |

## วิธีติดตั้งและรัน

```bash
# 1. สร้าง virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux

# 2. ติดตั้ง dependencies
pip install -r requirements.txt

# 3. Migrate database
python manage.py migrate

# 4. Seed user + OIDC Client
python manage.py seed_oidc

# 5. รัน server บน port 8001
python manage.py runserver 8001
```

Server จะรันที่ `http://localhost:8001`

## ทดสอบ OIDC Discovery

```bash
curl http://localhost:8001/openid/.well-known/openid-configuration
```

ตัวอย่าง response:
```json
{
  "issuer": "http://localhost:8001",
  "authorization_endpoint": "http://localhost:8001/openid/authorize",
  "token_endpoint": "http://localhost:8001/openid/token",
  "userinfo_endpoint": "http://localhost:8001/openid/userinfo",
  "jwks_uri": "http://localhost:8001/openid/.well-known/jwks.json",
  ...
}
```

## ข้อมูล OIDC Client (สำหรับ frontend2)

| รายการ | ค่า |
|--------|-----|
| client_id | `flutter-frontend2` |
| client_secret | `flutter-frontend2-secret` |
| redirect_uri | `com.example.frontend2://callback` |
| scope | `openid email profile` |

## Authorization Flow

```
frontend2 → GET /openid/authorize?client_id=flutter-frontend2&...
         → Django login page (admin/admin123)
         → Redirect back to frontend2 with code
frontend2 → POST /openid/token (code exchange)
         → ได้ access_token + id_token
```

## โครงสร้างโปรเจกต์

```
backend2/
├── manage.py
├── requirements.txt
├── backend2/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
└── oidc_setup/
    ├── __init__.py
    ├── oidc_provider_settings.py
    └── management/
        └── commands/
            └── seed_oidc.py
```
