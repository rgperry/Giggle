import openai
import requests
from io import BytesIO
from PIL import Image
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

