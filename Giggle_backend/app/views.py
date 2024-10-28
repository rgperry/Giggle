from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json

def getchatts(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    response = {"Hello"}
    return JsonResponse(response)
# Create your views here
@csrf_exempt
def postchatt(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    username = json_data['username']
    message = json_data['message']

    return JsonResponse({})
