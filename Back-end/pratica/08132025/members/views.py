from django.http.response import HttpResponse
from django.template import loader
from django.shortcuts import render

# Create your views here.
def hello_members(request):
    template = loader.get_template('myfirst.html')
    return HttpResponse(template.render())
