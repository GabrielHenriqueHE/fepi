from dvdrental.models import Customer, Country

from django.contrib import admin

class CustomerAdmin(admin.ModelAdmin):
    list_display = ("first_name", "last_name", "last_update")

class CountryAdmin(admin.ModelAdmin):
    list_display = ("country_id", "country", "last_update")

# Register your models here.
admin.site.register(Customer, CustomerAdmin)
admin.site.register(Country, CountryAdmin)