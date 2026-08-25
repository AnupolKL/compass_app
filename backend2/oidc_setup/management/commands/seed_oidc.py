"""
Management command: python manage.py seed_oidc
Creates:
  1. Superuser (admin / admin123)
  2. OIDC Client for frontend2 Flutter app
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "Seed default user and OIDC Client for testing"

    def handle(self, *args, **options):
        self._create_user()
        self._create_oidc_client()

    def _create_user(self):
        User = get_user_model()
        username, password = "admin", "admin123"
        if User.objects.filter(username=username).exists():
            self.stdout.write(self.style.WARNING(f"User '{username}' already exists — skipped."))
        else:
            User.objects.create_superuser(username=username, email="admin@example.com", password=password)
            self.stdout.write(self.style.SUCCESS(f"Superuser '{username}' created. Password: {password}"))

    def _create_oidc_client(self):
        try:
            from oidc_provider.models import Client, ResponseType
        except ImportError:
            self.stdout.write(self.style.ERROR("django-oidc-provider not installed — run pip install -r requirements.txt"))
            return

        client_id = "flutter-frontend2"
        if Client.objects.filter(client_id=client_id).exists():
            self.stdout.write(self.style.WARNING(f"OIDC Client '{client_id}' already exists — skipped."))
            return

        client = Client()
        client.name = "Flutter Frontend2"
        client.client_id = client_id
        client.client_secret = "flutter-frontend2-secret"
        client.response_types.set(ResponseType.objects.filter(value="code"))
        client.redirect_uris = ["com.example.frontend2://callback"]
        client.scope = ["openid", "email", "profile"]
        client.client_type = "public"
        client.save()

        self.stdout.write(self.style.SUCCESS(
            f"\nOIDC Client created:\n"
            f"  client_id:     {client.client_id}\n"
            f"  client_secret: {client.client_secret}\n"
            f"  redirect_uri:  com.example.frontend2://callback\n"
        ))
