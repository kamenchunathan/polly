from graphene_django.types import DjangoObjectType
from django.contrib.auth import get_user_model

UserModel = get_user_model()


class User(DjangoObjectType):
    class Meta:
        model = UserModel
        fields = ('id', 'username')
