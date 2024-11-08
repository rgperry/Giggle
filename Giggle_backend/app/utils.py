import openai
import requests
from io import BytesIO
from PIL import Image
import base64
from django.conf import settings

openai.api_key = settings.OPENAI_API_KEY

def generate_image(description):
    """
    Generates an image based on a description. Uses OpenAI's API.
    Note: This function requires openai==0.28 due to API changes in later versions.
    """
    if not description:
        print("Error: Description is empty.")
        return None
    
    try:
        # For text-to-image generation, use openai.Image.create (available in openai==0.28)
        response = openai.Image.create(
            prompt=description,
            n=1,
            size="512x512"
        )
        
        image_url = response['data'][0]['url']
        image_response = requests.get(image_url)
        img = Image.open(BytesIO(image_response.content))
        return img
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def analyze_sentiment(message):
    """
    Calls the OpenAI API to perform sentiment analysis on a given message.
    Uses openai.ChatCompletion with gpt-3.5-turbo model.
    """
    if not message:
        print("Error: Message is empty.")
        return "Error in analyzing sentiment"
    
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "Analyze the sentiment of the following message."},
                {"role": "user", "content": message}
            ],
            max_tokens=50,
            temperature=0.5
        )
        sentiment = response.choices[0].message['content'].strip()
        return sentiment
    except Exception as e:
        print(f"An error occurred: {e}")
        return "Error in analyzing sentiment"

def extract_tags(image, num_tags=10):
    """
    Extracts tags for an image using OpenAI's API. Returns a list of tags.
    """
    try:
        # Convert image to base64 to send in prompt
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        
        # Send image description request to OpenAI's model
        prompt = f"Generate {num_tags} descriptive tags for this image."
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a tagging assistant."},
                {"role": "user", "content": f"{prompt} Image data: {img_base64}"}
            ],
            max_tokens=50,
            temperature=0.5
        )
        tags = response.choices[0].message['content'].strip().split(',')
        return [tag.strip() for tag in tags][:num_tags]
    except Exception as e:
        print(f"An error occurred in extract_tags: {e}")
        return ["error"]

def extract_content(image, content_length=200):
    """
    Extracts a text description for an image. Uses OpenAI's API.
    """
    try:
        # Convert image to base64
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        
        # Create prompt for content description
        prompt = f"Describe this image in up to {content_length} characters."
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an image description assistant."},
                {"role": "user", "content": f"{prompt} Image data: {img_base64}"}
            ],
            max_tokens=100,
            temperature=0.5
        )
        content = response.choices[0].message['content'].strip()
        return content[:content_length]
    except Exception as e:
        print(f"An error occurred in extract_content: {e}")
        return "error in content extraction"