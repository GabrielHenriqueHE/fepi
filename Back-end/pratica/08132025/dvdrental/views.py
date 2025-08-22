from django.http import HttpResponse
from django.template import loader
from django.shortcuts import get_object_or_404, redirect, render

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
        'customer_name': f"{customer.first_name} {customer.last_name}",
        'customer_id': customer.customer_id
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

def edit_customer(request, id):
    customer = get_object_or_404(Customer, pk=id)
    if (request.method) == 'POST':
        customer.first_name = request.POST.get('first_name')
        customer.last_name = request.POST.get('last_name')
        customer.email = request.POST.get('email')

        customer.save()

        return redirect('/customers')
    return render(request, 'edit_customer.html', {'customer': customer})

def edit_city(request, id):
    city = get_object_or_404(City, pk=id)
    if (request.method) == 'POST':
        city.city = request.POST.get('city')

        city.save()
        
        return redirect('/cities')
    return render(request, 'edit_city.html', {'city': city})