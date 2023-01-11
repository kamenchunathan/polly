import os
import binascii
import datetime

from django.contrib.auth.models import AbstractUser
from django.db import models 

from core.settings import TOKEN_LIFETIME

class User(AbstractUser):
    email = models.EmailField(unique=True, blank=False, null=False)


class ApiToken(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    key = models.CharField(
        'Key',
        max_length = 40,
        null = False
    )
    created_at = models.DateTimeField(auto_now_add=True)

    @classmethod
    def generate_new_key(cls):
        return binascii.hexlify(os.urandom(20)).decode()

    def expires(self) -> datetime.datetime:
        return self.created_at  + datetime.timedelta(seconds=TOKEN_LIFETIME)
    


   
