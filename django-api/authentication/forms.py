from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm, UsernameField
from django.forms import EmailField


class NewUserForm(UserCreationForm):
    class Meta:
        model = get_user_model()
        fields = ('username', 'email')
        field_classes = {
            'username': UsernameField,
            'email': EmailField
        }
