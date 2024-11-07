from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
import base64
from io import BytesIO
from .utils import generate_image, analyze_sentiment

@require_http_methods(["GET"])
def generate_meme(request):
    """
    Endpoint to generate a meme based on description.
    """
    description = request.GET.get('description', '').strip()
    if not description:
        return JsonResponse({"error": "Description cannot be empty"}, status=400)
    
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
    Endpoint to redo meme generation.
    """
    try:
        data = json.loads(request.body)
        description = data.get('description', '').strip()
        if not description:
            return JsonResponse({"error": "Description cannot be empty"}, status=400)
        
        img = generate_image(description)
        if img:
            img_io = BytesIO()
            img.save(img_io, 'PNG')
            img_io.seek(0)
            img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
            return JsonResponse({"imageFile": img_base64})
        else:
            return JsonResponse({"error": "Image generation failed"}, status=500)
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON data"}, status=400)

@require_http_methods(["GET"])
def get_sentiment(request):
    """
    Endpoint to get sentiment analysis.
    """
    message = request.GET.get('message', '').strip()
    if not message:
        return JsonResponse({"error": "Message cannot be empty"}, status=400)
    
    sentiment = analyze_sentiment(message)
    return JsonResponse({"sentiment": sentiment})

