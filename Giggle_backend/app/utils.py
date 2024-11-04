import openai
import requests
from io import BytesIO
from PIL import Image
from django.conf import settings

openai.api_key = settings.OPENAI_API_KEY

def generate_image(description):
    """
    Generates an image based on a description using DALL-E or a similar OpenAI image model.
    """
    try:
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
    """
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an assistant that analyzes sentiment in messages."},
                {"role": "user", "content": f"Analyze the sentiment of this message: {message}"}
            ],
            max_tokens=50,
            temperature=0.5
        )
        sentiment = response.choices[0].message['content'].strip()
        return sentiment
    except Exception as e:
        print(f"An error occurred: {e}")
        return "Error in analyzing sentiment"
