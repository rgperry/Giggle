from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
import base64
from io import BytesIO
from .utils import generate_image, analyze_sentiment, extract_tags, extract_content
from django.core.files.storage import FileSystemStorage
import time

@require_http_methods(["GET"])
def generate_meme(request):
    """
    Endpoint to generate a meme based on description.
    """
    description = request.GET.get('description', '').strip()
    if not description:
        return JsonResponse({"error": "Description cannot be empty"}, status=400)

    try:
        img = generate_image(description)
        if img:
            response = HttpResponse(content_type='image/png')
            img.save(response, 'PNG')
            response['Content-Disposition'] = 'attachment; filename="meme.png"'
            return response
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
    
    try:
        sentiment = analyze_sentiment(message)
        return JsonResponse({"sentiment": sentiment})
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
            
        # no longer need to do this
        # # Parse the request body
        # data = json.loads(request.body)

        # Handle multiple images
        images = []
        if 'image' in request.FILES:
            images.append(request.FILES['image'])
        else:
            return JsonResponse({"error": "No image file provided"}, status=400)

        
        # Validate input: limit batch size to 10 images
        if len(images) > 10:
            return JsonResponse({"error": "Batch size exceeds limit of 10 images"}, status=400)
        
        response_data = []
        for image_file in images:
            # image_id = image_data.get('Id')
            # image_base64 = image_data.get('imageFile')

            # # Validate fields
            # if not image_id or not image_base64:
            #     return JsonResponse({"error": f"Invalid data for image ID {image_id}"}, status=400)

            # # Decode the base64 image
            # try:
            #     image_bytes = base64.b64decode(image_base64)
            #     image = BytesIO(image_bytes)
            # except Exception:
            #     return JsonResponse({"error": f"Invalid base64 encoding for image ID {image_id}"}, status=400)
       
            # Process the image to extract tags and content
            try:
                tags = extract_tags(image_file, num_tags=num_tags)  # Custom function to generate tags
                content = extract_content(image_file, content_length=content_length)  # Custom function to generate content
                response_data.append({
                    # "id": image_id,
                    "tags": tags,   
                    "content": content
                })
            except Exception as e:
                # print(f"Error processing image ID {image_id}: {e}")
                response_data.append({
                    # "id": image_id,
                    "error": "Failed to process image"
                })
        
        return JsonResponse(response_data, safe=False)
            
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON data"}, status=400)
    except ValueError:
        return JsonResponse({"error": "Invalid parameters for numTags or contentLength"}, status=400)
    except Exception as e:
        print(f"Unexpected error in image_info: {e}")
        return JsonResponse({"error": f"Internal Server Error {e}"}, status=500)

