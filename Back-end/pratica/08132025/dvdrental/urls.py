from django.urls import path, include

from . import views

urlpatterns = [
    path('customers/', views.customers, name='customers'),
    path('cities/', views.cities, name='cities')
]