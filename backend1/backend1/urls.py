"""
URL configuration for backend1.
Exposes JWT token endpoints:
  POST /api/token/          — obtain access + refresh token
  POST /api/token/refresh/  — get new access token using refresh
"""

from django.contrib import admin
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
