from django.urls import path

from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('customers/', views.customers, name='customers'),
    path('customers/json/<int:number>', views.customers_json, name='customers_json'),
    path('customers/add', views.add_customer, name='add_customers'),
    path('customers/filtered', views.filtered_customers, name='filtered_customers'),
    path('customers/<int:id>', views.details, name='details'),
    path('customers/<int:id>/edit', views.edit_customer, name='edit_customer'),
    path('cities/', views.cities, name='cities'),
    path('cities/<int:id>/addresses', views.city_addresses, name='city_addresses'),
    path('cities/<int:id>/edit', views.edit_city, name='edit_city'),
    path('countries', views.countries, name='countries'),
    path('countries/filtered', views.filtered_countries, name='filtered_countries'),
    path('countries/add', views.add_country, name='add_country'),
    path('countries/<int:id>', views.country_cities, name='country_cities'),
    path('categories/', views.list_categories, name='categories'),
    path('categories/add', views.add_category, name='add_category'),
    path('categories/<int:id>/edit', views.edit_category, name='edit_category'),
    path('rentals/<int:id>', views.rental_details, name='rental_details'),
    path('rentals/<int:id>/json', views.rental_details_json, name='rental_details_json'),
    path('payment/<int:id>', views.payment, name='payment'),
    
    path('user/create', views.create_user, name="create_user"),
    path('user/login', views.login_user, name="login_user"),
    path('logout', views.logout_user, name="logout_user"),
    path('user/change-password', views.change_password, name="change_password"),
    path('authenticated', views.user_authenticated, name="user_authenticated")
]