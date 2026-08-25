# backend1 — Django JWT Authentication Server

Django REST API พร้อม JWT authentication ผ่าน `djangorestframework-simplejwt`

## Endpoints

| Method | URL | คำอธิบาย |
|--------|-----|----------|
| POST | `/api/token/` | ขอ access + refresh token |
| POST | `/api/token/refresh/` | ต่ออายุ access token ด้วย refresh token |
| GET/POST | `/admin/` | Django admin panel |

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

# 4. สร้าง default user (admin / admin123)
python manage.py seed_users

# 5. รัน server
python manage.py runserver
```

Server จะรันที่ `http://localhost:8000`

## ทดสอบด้วย curl

```bash
# ขอ token
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"admin\", \"password\": \"admin123\"}"

# ตัวอย่าง response
# {
#   "access":  "<access_token>",
#   "refresh": "<refresh_token>"
# }

# ต่ออายุ access token
curl -X POST http://localhost:8000/api/token/refresh/ \
  -H "Content-Type: application/json" \
  -d "{\"refresh\": \"<refresh_token>\"}"
```

## โครงสร้างโปรเจกต์

```
backend1/
├── manage.py
├── requirements.txt
├── backend1/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
└── api/
    ├── __init__.py
    └── management/
        └── commands/
            └── seed_users.py
```
