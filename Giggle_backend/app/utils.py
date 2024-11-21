import openai
from openai import OpenAI
import requests
from io import BytesIO
from PIL import Image
import base64
from django.conf import settings


openai.api_key = settings.OPENAI_API_KEY 

client = OpenAI(api_key=settings.OPENAI_API_KEY)

def generate_image(description):
    """
    Generates an image based on a description using OpenAI's updated API.
    """
    if not description:
        print("Error: Description is empty.")
        return None

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
    except openai.error.AuthenticationError as e:
        print(f"Authentication Error: {e}")
        return None
    except Exception as e:
        print(f"An error occurred in generate_image: {e}")
        return None

def analyze_sentiment(message):
    """
    Calls the OpenAI API to perform sentiment analysis on a given message.
    """
    if not message:
        print("Error: Message is empty.")
        return "Error in analyzing sentiment"

    try:
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a helpful assistant, and ."},
                {
                    "role": "user",
                    "content": "Anaylze the following message based on it's content and sentiment, and generate a short description of its sentiment"
                }
            ]
        )
        return completion.choices[0].message
    except openai.error.AuthenticationError as e:
        print(f"Authentication Error: {e}")
        return "Authentication error in analyzing sentiment"
    except Exception as e:
        print(f"An error occurred in analyze_sentiment: {e}")
        return "Error in analyzing sentiment"


def extract_tags(image_data, num_tags=10):
    """
    Extracts tags for an image using OpenAI's updated API.
    """
    try:
        image = Image.open(image_data).resize((512, 512))
        buffered = BytesIO()
        image.save(buffered, format="JPEG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')

        prompt = f"Generate {num_tags} descriptive tags for this image. Return the tags in a comma separated list."
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                "role": "user",
                "content": [
                    {
                    "type": "text",
                    "text": f"You are tasked with generate {num_tags} descriptive tags for this image." 
                        "Make sure to take into account the emotion/sentiment of the image, as well as the content" 
                        "of the image. If there is any text or key info also make a descriptive tag for it."
                        " Return the tags in a comma separated list. I repeat your response to this message should ONLY be "
                         "a list of the tags that you have generated, separated by commas. No brackets necessary",
                    },
                    {
                    "type": "image_url",
                    "image_url": {
                        "url":  f"data:image/jpeg;base64,{img_base64}"
                    },
                    },
                ],
                }
            ],
            )
        tags = response.choices[0].message.content.strip().split(',')
        return [tag.strip() for tag in tags][:num_tags]
    except Exception as e:
        print(f"An error occurred in extract_tags: {e}")
        return [f"error is {e}"]


def extract_content(image_data, content_length=200):
    """
    Extracts a text description for an image using OpenAI's updated API.
    """
    try:
        image = Image.open(image_data).resize((512, 512))
        buffered = BytesIO()
        image.save(buffered, format="JPEG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                "role": "user",
                "content": [
                    {
                    "type": "text",
                    "text": f"You are tasked with generating a {content_length} word description of what"
                    " is going on in this meme. In your description please analyze the sentiment, and if there is "
                    " any text in the image, include it in your description of the meme.",
                    },
                    {
                    "type": "image_url",
                    "image_url": {
                        "url":  f"data:image/jpeg;base64,{img_base64}"
                    },
                    },
                ],
                }
            ],
            )
        return response.choices[0].message.content.strip()
    except Exception as e:
        print(f"An error occurred in extract_content: {e}")
        return [f"error is {e}"]
    
