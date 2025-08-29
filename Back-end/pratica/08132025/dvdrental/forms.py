from django.utils import timezone
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
        fields = ['name']

    # def __init__(self, *args, **kwargs):
    #     super().__init__(*args, **kwargs)
        
    #     self.fields['last_update'].initial = timezone.now()
