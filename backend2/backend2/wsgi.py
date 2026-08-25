"""WSGI config for backend2 project."""

import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend2.settings")
application = get_wsgi_application()
