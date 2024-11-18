import openai
import requests
from io import BytesIO
from PIL import Image
import base64
from django.conf import settings


openai.api_key = settings.OPENAI_API_KEY 


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
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a sentiment analysis assistant."},
                {"role": "user", "content": f"Analyze the sentiment of this message: {message}"}
            ],
            max_tokens=50,
            temperature=0.5
        )
        sentiment = response.choices[0].message['content'].strip()
        return sentiment
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
        image = Image.open(image_data)
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')

        prompt = f"Generate {num_tags} descriptive tags for this image. Return the tags in a comma separated list."
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a tagging assistant."},
                {"role": "user", "content": f"{prompt} Image data: {img_base64}"}
            ],
            max_tokens=100,
            temperature=0.5
        )
        tags = response.choices[0].message['content'].strip().split(',')
        return [tag.strip() for tag in tags][:num_tags]
    except openai.error.AuthenticationError as e:
        print(f"Authentication Error: {e}")
        return ["Authentication error"]
    except Exception as e:
        print(f"An error occurred in extract_tags: {e}")
        return [f"error is {e}"]


def extract_content(image_data, content_length=200):
    """
    Extracts a text description for an image using OpenAI's updated API.
    """
    try:
        image = Image.open(image_data)
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')

        prompt = f"Describe this image in up to {content_length} characters."
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an image description assistant."},
                {"role": "user", "content": f"{prompt} Image data: {img_base64}"}
            ],
            max_tokens=200,
            temperature=0.5
        )
        content = response.choices[0].message['content'].strip()
        return content[:content_length]
    except openai.error.AuthenticationError as e:
        print(f"Authentication Error: {e}")
        return "Authentication error in content extraction"
    except Exception as e:
        print(f"An error occurred in extract_content: {e}")
        return f"error in content extraction {e}"

