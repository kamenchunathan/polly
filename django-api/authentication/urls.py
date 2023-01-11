from django.urls import path

from . import views

app_name = "api_auth"
urlpatterns = [
    path('api-token/', views.get_api_key, name='api-key'),
    path('signup/', views.sign_up, name='signup'),
    path('user/', views.user_details, name='user-details'),
]
