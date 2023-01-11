from django.contrib.auth.backends import BaseBackend
from django.utils import  timezone

from .models import ApiToken, User

class ExpiringTokenAuthentication(BaseBackend):
    def authenticate(self, request, key=None):
        try:
            token = ApiToken.objects.get(key=key)
        except:
            return None

        if timezone.now() > token.expires():
            return None

        return token.user
        
    
