from django.urls import path

from . import views

urlpatterns = [
    path('customers/', views.customers, name='customers'),
    path('customers/filtered', views.filtered_customers, name='filtered_customers'),
    path('customers/<int:id>', views.details, name='details'),
    path('customers/<int:id>/edit', views.edit_customer, name='edit_customer'),
    path('cities/', views.cities, name='cities'),
    path('cities/<int:id>/edit', views.edit_city, name='edit_city'),
    path('countries', views.countries, name='countries'),
    path('countries/filtered', views.filtered_countries, name='filtered_countries'),
    path('countries/add', views.add_country, name='add_country'),
    path('countries/<int:id>', views.country_cities, name='country_cities'),
    path('categories/', views.list_categories, name='list_categories'),
    path('categories/add', views.add_category, name='add_category')
]