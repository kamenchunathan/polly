from django.contrib.auth.backends import BaseBackend
from django.utils import  timezone

from .models import ApiToken

class ExpiringTokenAuthentication(BaseBackend):
    def authenticate(self, request, key=None):
        if key is None:
             header_parts = request.headers.get('Authorization').split(' ')           

             if len(header_parts) < 2:
                 return

             key = header_parts[1]
             
        try:
            token = ApiToken.objects.get(key=key)
        except:
            return None

        if timezone.now() > token.expires():
            return None

        return token.user
        
    
