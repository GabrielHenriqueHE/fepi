from django.http import HttpResponse
from django.template import loader

from dvdrental.models import Customer, City

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