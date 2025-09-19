import json

from django.contrib.auth import authenticate, login, logout, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm, PasswordChangeForm

from django.utils import timezone
from django.http import HttpResponse, JsonResponse
from django.template import loader
from django.shortcuts import get_object_or_404, redirect, render

from dvdrental.models import Address, Customer, City, Rental, Country, Category, Payment
from dvdrental.forms import CustomerForm, CategoryForm

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
    rentals = Rental.objects.filter(customer_id=id)
    customer = get_object_or_404(Customer, pk=id)

    template = loader.get_template('customer_details.html')
    context = {
        'rentals': rentals,
        'customer': customer,
        'customer_name': f"{customer.first_name} {customer.last_name}",
        'customer_id': customer.customer_id
    }

    return HttpResponse(template.render(context=context, request=request))

def countries(request):
    # countries = Country.objects.all().values()

    # template = loader.get_template('all_countries.html')
    # context = {
    #     'countries': countries
    # }

    return redirect('home')

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
    if request.method == 'POST':
        form = CustomerForm(request.POST, instance=customer)
        if form.is_valid():
            form.save()
            return redirect('customers')
        
    else:
        form = CustomerForm(instance=customer)

    context = {
        'form': form
    }

    return render(request, 'edit_customer.html', context=context)

def edit_city(request, id):
    city = get_object_or_404(City, pk=id)
    if (request.method) == 'POST':
        city.city = request.POST.get('city')

        city.save()
        
        return redirect('/cities')
    return render(request, 'edit_city.html', {'city': city})

def list_categories(request):
    categories = Category.objects.all()
    return render(request, 'categories_list.html', {'categories': categories})

def add_category(request):
    if request.method == 'POST':
        name = request.POST.get('name')

        category = Category(name=name, last_update=timezone.now())
        category.save()

        return redirect('/categories')
    return render(request, 'add_category.html')

def add_country(request):
    if request.method == 'POST':
        name = request.POST.get('name')

        country = Country(country=name, last_update=timezone.now())
        country.save()

        return redirect('/countries')
    return render(request, 'add_country.html')

# def filtered_customers(request):
#     #customers = Customer.objects.filter(first_name__contains='Karen')
#     #customers = Customer.objects.filter(first_name__contains='Karen').values()
#     #customers = Customer.objects.filter(last_name__icontains='mill').values()
#     #customers = Customer.objects.filter(first_name__endswith='s').values()
#     #customers = Customer.objects.filter(first_name__iendswith='s').values()
#     #customers = Customer.objects.filter(first_name__exact='Phyllis').values()
#     #customers = Customer.objects.filter(first_name__iexact='phyllis').values()
#     #customers = Customer.objects.filter(first_name__in=['Karen', 'Dennis', 'Nicholas']).values()
#     #customers = Customer.objects.filter(customer_id__gt=500).values()
#     #customers = Customer.objects.filter(customer_id__gte=500).values()
#     #customers = Customer.objects.filter(customer_id__lt=15).values()
#     customers = Customer.objects.filter(customer_id__lte=15).values()
    

#     template = loader.get_template('filtered_customers.html')
#     context = {
#         'customers': customers
#     }

#     return HttpResponse(template.render(context=context, request=request))


# def filtered_customers(request):
#     #customers = Customer.objects.filter(first_name__icontains='Maria', customer_id=7).values()
#     #customers = Customer.objects.filter(first_name__icontains='Maria').values() | Customer.objects.filter(customer_id=8).values()
#     customers = Customer.objects.filter(first_name__icontains='Maria').values() | Customer.objects.filter(customer_id=8).values()
    

#     template = loader.get_template('filtered_customers.html')
#     context = {
#         'customers': customers
#     }

#     return HttpResponse(template.render(context=context, request=request))

def filtered_customers(request):
    search_name = request.GET.get('search_name', '')

    customers = (
        Customer.objects.filter(first_name__icontains=search_name) if search_name 
        else Customer.objects.values())   

    template = loader.get_template('filtered_customers.html')
    context = {
        'customers': customers
    }

    return HttpResponse(template.render(context=context, request=request))

def filtered_countries(request):
    search_name = request.GET.get('search_name', '')

    countries = (
        Country.objects.filter(country__icontains=search_name).values() if search_name
        else Country.objects.values()
    )

    template = loader.get_template('filtered_countries.html')
    context = {
        'countries': countries
    }

    return HttpResponse(template.render(context=context, request=request))

def add_customer(request):
    if request.method == 'POST':
        form = CustomerForm(request.POST)
        form.save()
        return redirect('customers')

    template = loader.get_template('customers_form.html')
    context = {
        'form': CustomerForm()
    }

    return HttpResponse(template.render(request=request, context=context))

def add_category(request):
    if request.method == 'POST':
        form = CategoryForm(request.POST)
        form.instance.last_update = timezone.now()

        form.save()
        return redirect('categories')
    
    template = loader.get_template('add_category.html')
    context = {
        'form': CategoryForm()
    }

    return HttpResponse(template.render(request=request, context=context))

def edit_category(request, id):
    category = get_object_or_404(Category, pk=id)
    if request.method == 'POST':
        form = CategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            return redirect('categories')
        
    else:
        form = CategoryForm(instance=category)

    context = {
        'form': form
    }

    return render(request, 'edit_category.html', context=context)

def customers_json(request, number):
    customers = list(Customer.objects.values()[0:number])

    payload = {
        "customers": customers
    }

    return JsonResponse(data=payload, safe=False)

def rental_details(request, id):
    rental = get_object_or_404(Rental, pk=id)
    customer = Customer.objects.filter(customer_id=rental.customer_id).first()

    payments = Payment.objects.filter(rental_id=rental.rental_id)

    context = {
        "customer": {
            "name": f"{customer.first_name} {customer.last_name}",
            "object": customer
        },
        "rental": rental,
        "payments": payments
    }


    template = loader.get_template("rental_details.html")

    return HttpResponse(template.render(request=request, context=context))

def rental_details_json(request, id):
    rentals = Rental.objects.filter(customer_id=id)
    customer = get_object_or_404(Customer, pk=id)
    template = loader.get_template('rental_modal_content.html')

    context = {
        "rentals": rentals,
        "customer_name": f"{customer.first_name} {customer.last_name}"
    }

    rendered_context = template.render(request=request, context=context)
    return JsonResponse({
        "html": rendered_context
    })

def payment(request, id):
    payments = Payment.objects.filter(rental_id=id)
    template = loader.get_template('payment.html')
    context = {
        "payments": payments
    }

    return HttpResponse(template.render(request=request, context=context))


def home(request):
    countries = Country.objects.all()

    context = {
        "countries": countries
    }
    
    template = loader.get_template("home.html")

    return HttpResponse(template.render(request=request, context=context))

def city_addresses(request, id):
    city = get_object_or_404(City, pk=id)

    addresses = Address.objects.filter(city_id=city.city_id)

    context = {
        "addresses": addresses
    }

    template = loader.get_template("city_addresses.html")

    return HttpResponse(template.render(request=request, context=context))

def create_user(request):
    if request.method == "POST":
        user_form = UserCreationForm(request.POST)
        if user_form.is_valid():
            user_form.save()
            return redirect('home')
        
    user_form = UserCreationForm()

    context = {
        "user_form": user_form
    }

    template = loader.get_template('user_cadastro.html')

    return HttpResponse(template.render(request=request, context=context))

def login_user(request):
    if request.method == "POST":
        username = request.POST["username"]
        password = request.POST["password"]

        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request=request, user=user)
            return redirect('user_authenticated')
    
    user_login_form = AuthenticationForm()

    context = {
        "user_login": user_login_form
    }

    template = loader.get_template('user_login.html')

    return HttpResponse(template.render(request=request, context=context))

@login_required(login_url="login_user")
def logout_user(request):
    logout(request=request)

    return redirect('home')

@login_required(login_url="login_user")
def change_password(request):
    if request.method == "POST":
        password_form = PasswordChangeForm(request.user, request.POST)
        if password_form.is_valid():
            user = password_form.save()
            update_session_auth_hash(request, user)
            return redirect('home')
        
    password_form = PasswordChangeForm(request.user)

    template = loader.get_template('user_change_password.html')
    context = {
        "password_form": password_form
    }

    return HttpResponse(template.render(request=request, context=context))

def user_authenticated(request):
    template = loader.get_template('user_authenticated.html')

    return HttpResponse(template.render(request=request))