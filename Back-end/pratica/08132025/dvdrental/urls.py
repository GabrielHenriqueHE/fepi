from django.urls import path

from . import views

urlpatterns = [
    path('customers/', views.customers, name='customers'),
    path('customers/<int:id>', views.details, name='details'),
    path('customers/<int:id>/edit', views.edit_customer, name='edit_customer'),
    path('cities/', views.cities, name='cities'),
    path('cities/<int:id>/edit', views.edit_city, name='edit_city'),
    path('countries', views.countries, name='countries'),
    path('countries/<int:id>', views.country_cities, name='country_cities')
]