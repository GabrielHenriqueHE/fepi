
from django import forms
from dvdrental.models import Customer, Category

class CustomerForm(forms.ModelForm):
    class Meta:
        model = Customer
        # fields = '__all__'
        fields = ['first_name', 'last_name', 'email', 'address', 'activebool', 'store_id', 'create_date']

class CategoryForm(forms.ModelForm):

    class Meta:
        model = Category
        fields = '__all__'
