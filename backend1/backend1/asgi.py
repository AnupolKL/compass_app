"""ASGI config for backend1 project."""

import os
from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend1.settings")
application = get_asgi_application()
