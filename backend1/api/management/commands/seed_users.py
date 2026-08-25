"""
Management command: python manage.py seed_users
Creates a default superuser for testing JWT endpoints.
"""

import os
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    help = "Seed a default superuser (admin / admin123) for testing"

    def handle(self, *args, **options):
        User = get_user_model()
        username = "admin"
        password = "admin123"
        email = "admin@example.com"

        if User.objects.filter(username=username).exists():
            self.stdout.write(self.style.WARNING(f"User '{username}' already exists — skipped."))
        else:
            User.objects.create_superuser(username=username, email=email, password=password)
            self.stdout.write(self.style.SUCCESS(f"Superuser '{username}' created. Password: {password}"))
