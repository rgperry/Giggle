from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
import base64
from io import BytesIO
from .utils import generate_image, regenerate_image, analyze_sentiment, extract_tags, extract_content
from django.core.files.storage import FileSystemStorage
import time

@require_http_methods(["GET"])
def generate_meme(request):
    """
    Endpoint to generate a meme based on description.
    Returns a Base64-encoded image.
    """
    description = request.GET.get('description', '').strip()
    if not description:
        return JsonResponse({"error": "Description cannot be empty"}, status=400)

    try:
        # Call the generate_image function
        base64_image = generate_image(description)
        if base64_image:
            return JsonResponse({"image": base64_image}, status=200)
        else:
            return JsonResponse({"error": "Image generation failed"}, status=500)
    except Exception as e:
        print(f"Error in generate_meme: {e}")
        return JsonResponse({"error": "Internal Server Error"}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def redo_generation(request):
    """
    Endpoint to redo meme generation.
    """
    try:
        # Handle image upload
        if 'image' not in request.FILES:
            return JsonResponse({"error": "No image file provided"}, status=400)
        
        # Get the uploaded image
        image = request.FILES['image'] 

        # Call the regenerate_image function
        base64_image = regenerate_image(image)
        if base64_image:
            return JsonResponse({"image": base64_image})
        else:
            return JsonResponse({"error": "Image regeneration failed"}, status=500)
    except Exception as e:
        print(f"Error in redo_generation: {e}")
        return JsonResponse({"error": "Internal Server Error"}, status=500)

@require_http_methods(["GET"])
def get_sentiment(request):
    """
    Endpoint to get sentiment analysis.
    """
    message = request.GET.get('message', '').strip()
    if not message:
        return JsonResponse({"error": "Message cannot be empty"}, status=400)
    
    tags = request.GET.get('tags', '').strip()
    if not tags:
        return JsonResponse({"error": "Tags cannot be empty"}, status=400)
    
    try:
        relevant_tags = analyze_sentiment(message, tags)
        return JsonResponse({"relevantTags": relevant_tags}, status=200)
    except Exception as e:
        print(f"Error in get_sentiment: {e}")
        return JsonResponse({"error": "Internal Server Error"}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def image_info(request):
    """
    Endpoint to get image info for multiple images.
    """
    try:
        # Read URL parameters
        num_tags = int(request.GET.get('numTags', 10))
        content_length = int(request.GET.get('contentLength', 200))
            
        # Handle image upload
        if 'image' not in request.FILES:
            return JsonResponse({"error": "No image file provided"}, status=400)
        
        image = request.FILES['image']
        
        try:
            # Process the image to extract tags and content
            tags = extract_tags(image, num_tags=num_tags)
            content = extract_content(image, content_length=content_length)
            
            response_data = {
                "tags": tags,
                "content": content
            }
            
            return JsonResponse(response_data, safe=False)
            
        except Exception as e:
            print(f"Error processing image: {str(e)}")
            return JsonResponse({
                "error": f"Failed to process image: {str(e)}"
            }, safe=False, status=500)
            
    except Exception as e:
        return JsonResponse({
            "error": f"Server error: {str(e)}"
        }, safe=False, status=500)
            
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON data"}, status=400)
    except ValueError:
        return JsonResponse({"error": "Invalid parameters for numTags or contentLength"}, status=400)
    except Exception as e:
        print(f"Unexpected error in image_info: {e}")
        return JsonResponse({"error": f"Internal Server Error {e}"}, status=500)

