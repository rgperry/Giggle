from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json

import base64
from django.views.decorators.http import require_http_methods
from .utils import generate_image, analyze_sentiment
from io import BytesIO

@require_http_methods(["GET"])
def generate_meme(request):
    """
    Endpoint to generate a meme based on description
    """
    description = request.GET.get('description', '')
    img = generate_image(description)
    
    if img:
        response = HttpResponse(content_type='image/png')
        img.save(response, 'PNG')
        response['Content-Disposition'] = 'attachment; filename="meme.png"'
        return response
    else:
        return JsonResponse({"error": "Image generation failed"}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def redo_generation(request):
    """
    Endpoint to redo meme generation
    """
    import json
    data = json.loads(request.body)
    description = data.get('description', '')
    
    img = generate_image(description)
    if img:
        img_io = BytesIO()
        img.save(img_io, 'PNG')
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
        return JsonResponse({"imageFile": img_base64})
    else:
        return JsonResponse({"error": "Image generation failed"}, status=500)

@require_http_methods(["GET"])
def get_sentiment(request):
    """
    Endpoint to get sentiment analysis
    """
    message = request.GET.get('message', '')
    sentiment = analyze_sentiment(message)
    return JsonResponse({"sentiment": sentiment})
