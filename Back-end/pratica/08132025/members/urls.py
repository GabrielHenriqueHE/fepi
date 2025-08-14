from django.urls import path
from . import views

urlpatterns = [
    path('members/', views.hello_members, name='members')
]