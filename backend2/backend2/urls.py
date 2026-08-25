"""
URL configuration for backend2 — OpenID Connect Provider.

OIDC Endpoints (via django-oidc-provider):
  GET  /.well-known/openid-configuration  — Discovery document
  GET  /openid/authorize                  — Authorization endpoint
  POST /openid/token                      — Token endpoint
  GET  /openid/userinfo                   — UserInfo endpoint
  GET  /openid/end-session               — End session endpoint
  GET  /openid/introspect                 — Token introspection
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("openid/", include("oidc_provider.urls", namespace="oidc_provider")),
]
