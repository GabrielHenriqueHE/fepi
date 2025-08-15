from django.http import HttpResponse
from django.template import loader
from django.shortcuts import get_object_or_404

from dvdrental.models import Customer, City, Rental, Country

def customers(request):
    customers = Customer.objects.all().values()
    template = loader.get_template('all_customers.html')
    context = {
        'customers': customers
    }
    return HttpResponse(template.render(context=context, request=request))

def cities(request):
    cities = City.objects.all().values()
    template = loader.get_template('all_cities.html')
    context = {
        'cities': cities
    }
    return HttpResponse(template.render(context=context, request=request))

def details(request, id):
    details = Rental.objects.filter(customer_id=id)
    customer = get_object_or_404(Customer, pk=id)

    template = loader.get_template('customer_details.html')
    context = {
        'details': details,
        'customer_name': f"{customer.first_name} {customer.last_name}"
    }

    return HttpResponse(template.render(context=context, request=request))

def countries(request):
    countries = Country.objects.all().values()

    template = loader.get_template('all_countries.html')
    context = {
        'countries': countries
    }

    return HttpResponse(template.render(context=context, request=request))

def country_cities(request, id):
    country = get_object_or_404(Country, pk=id)
    cities = City.objects.filter(country_id=id)

    template = loader.get_template('country_cities.html')
    context = {
        'country': country,
        'cities': cities
    }

    return HttpResponse(template.render(context=context, request=request))
