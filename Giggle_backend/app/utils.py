import openai
from openai import OpenAI
import requests
from io import BytesIO
from PIL import Image
import base64
from django.conf import settings
import random

# OpenAI Vision/images api reference: https://platform.openai.com/docs/api-reference/images
def generate_image(description):
    """
    Generates an image based on a description using OpenAI's updated API.
    """
    if not description:
        print("Error: Description is empty.")
        return None

    style = random.choice(["vivid", "natural"])
    try:
        client = OpenAI(api_key=settings.OPENAI_API_KEY)
        response = client.images.generate(
            model="dall-e-3",
            prompt=description,
            size="1024x1024",
            response_format="b64_json",
            quality="standard",
            n=1,
            style= style,
        )

        image_b64 = response.data[0].b64_json
        return image_b64
    except openai.error.AuthenticationError as e:
        print(f"Authentication Error: {e}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Image fetch error: {e}")
        return None
    except Exception as e:
        print(f"An error occurred in generate_image: {e}")
        return None

def regenerate_image(image_data):
    """
    Regenerate an image by creating a variation using OpenAI's DALL-E API.
    """
    try:
        # # Ensure the image is in the correct format (PNG)
        #img = Image.open(BytesIO(image_data))
        
        # # Save the image to a BytesIO object as PNG
        image_file = BytesIO()
        image_data.save(image_file, format="PNG")
        image_file.seek(0)  # Reset the file pointer to the beginning

        # Call the OpenAI API with the file-like object
        client = openai.Client(api_key=settings.OPENAI_API_KEY)
        response = client.images.create_variation(
            model="dall-e-2",
            image=image_file,  # Pass the file-like object
            n=1,
            response_format="b64_json",
            size="1024x1024"
        )
        # Extract the image URL from the response
        image_b64 = response.data[0].b64_json
        return image_b64  # Return the Base64 string
    except Exception as e:
        print(f"An error occurred in regenerate_image: {e}")
        return "Error in regenerating image"

# OpenAI Chat reference: https://platform.openai.com/docs/api-reference/chat 
def analyze_sentiment(message):
    """
    Calls the OpenAI API to perform sentiment analysis on a given message.
    """
    if not message:
        print("Error: Message is empty.")
        return "Error in analyzing sentiment"

    try:
        client = OpenAI(api_key=settings.OPENAI_API_KEY)
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {
                    "role": "user",
                    "content": "You are tasked with generating 10 descriptive tags for the following message. You can generate more if you think it is necessary"
                    " The message that we will give you will be sent in a conversation. For context, We have a list of tags for memes stored in a database. The tags that you generate "
                    " will be used in order to find a meme that matches the sentiment/emotion of the text message. So if the message is 'I'm really excited to see you', some of the tags "
                    " you generate are smile, happy, excited, good. Those are a few examples"
                    " Here is the message: {message}"
                    " Return the tags in a comma separated list. I repeat your response to this message should ONLY be " 
                    "a list of the tags that you have generated, separated by commas. No brackets necessary"
                }
            ]
        )
        tags = response.choices[0].message.content.strip().split(',')
        return [tag.strip() for tag in tags]
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
        client = OpenAI(api_key=settings.OPENAI_API_KEY)
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
                    "text": f"You are tasked with generate {num_tags} descriptive tags for this image."
                    "For some context, this image will most likely be a meme" 
                    "Make sure to take into account the emotion/sentiment of the image, as well as the content" 
                    "of the image. If there is any text or key info also make a descriptive tag for it. "
                    "If there are any notable people or celebrities in the image make a tag for it. "
                    "Also don't give any tags that could apply to any meme, like humor or relatable content for example. "
                    "Don't include any general info in the tag like ___ meme. Just give the ___" 
                    " Return the tags in a comma separated list. I repeat your response to this message should ONLY be " 
                    "a list of the tags that you have generated, separated by commas. No brackets necessary", },
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
        client = OpenAI(api_key=settings.OPENAI_API_KEY)
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
    