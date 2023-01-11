import json
from json import JSONDecodeError

from django.http import JsonResponse
from django.utils import timezone
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate

from .models import User, ApiToken
from .forms import NewUserForm


def get_or_create_token(user: User) -> ApiToken :
    try:
        user_token = ApiToken.objects.get(user=user)
    except ApiToken.DoesNotExist:
        user_token = ApiToken.objects.create(
            user=user,
            key=ApiToken.generate_new_key()
        )

    return user_token
 
@csrf_exempt
@require_POST
def get_api_key(request):
    try:
        user_data = json.loads(request.body)
    except JSONDecodeError:
        return JsonResponse(
            {'detail': 'Invalid Json'},
            status=400
        )

    username = user_data.get('username')
    password = user_data.get('password')

    if username is  None or password is None:
        return JsonResponse(
            {'detail': 'provide username and password'},
            status=400
        )

    user = authenticate(username=username, password=password)

    if user is None:
        return JsonResponse(
            {'detail': 'Invalid username or password'},
            status=400
        )

    token = get_or_create_token(user)

    if timezone.now() > token.expires():
        token.delete()
        token = ApiToken.objects.create(
            user=user, 
            key=ApiToken.generate_new_key()
        )
    
    return JsonResponse(
        {
            'detail': 'success',
            'token': token.key,
            'expires': token.expires()
        }
    )

@csrf_exempt
@require_POST
def sign_up(request):
    user_data = json.loads(request.body)
    user_form = NewUserForm(user_data)

    if not user_form.is_valid():
        return JsonResponse(
            {'detail': dict(user_form.errors)},
            status=400
        )

    user = user_form.save()
    return JsonResponse(
        {'detail': 'Successfully created new user',
         'user': {
            'username': user.username,
            'email': user.email
            }
        }
    )


