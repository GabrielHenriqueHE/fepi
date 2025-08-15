from django.urls import path

from . import views

urlpatterns = [
    path('customers/', views.customers, name='customers'),
    path('customers/details/<int:id>', views.details, name='details'),
    path('cities/', views.cities, name='cities'),
    path('countries', views.countries, name='countries'),
    path('countries/<int:id>', views.country_cities, name='country_cities')
]