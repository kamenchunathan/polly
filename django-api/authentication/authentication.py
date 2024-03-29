from django.contrib.auth.backends import BaseBackend
from django.utils import timezone

from .models import ApiToken


class ExpiringTokenAuthentication(BaseBackend):
    def authenticate(self, request, key=None, **kwargs):
        if request is None:
            return

        if key is None:
            auth_header = request.headers.get('Authorization')
            if auth_header is None:
                return

            header_parts = auth_header.split(' ')

            if len(header_parts) < 2:
                return

            key = header_parts[1]

        try:
            token = ApiToken.objects.get(key=key)
        except ExpiringTokenAuthentication.DoesNotExist:
            return

        if timezone.now() > token.expires():
            return

        return token.user
