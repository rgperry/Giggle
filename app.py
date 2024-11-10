import openai
import os
from flask import Flask, request, jsonify, send_file
from io import BytesIO
from PIL import Image
import base64
import requests

openai.api_key = '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'

app = Flask(__name__)

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

# Endpoint to generate a meme
@app.route('/generateMeme', methods=['GET'])
def generate_meme():
    description = request.args.get('description', '')
    img = generate_image(description)
    
    if img:
        # Save to a BytesIO object to simulate file sending
        img_io = BytesIO()
        img.save(img_io, 'PNG')
        img_io.seek(0)
        return send_file(img_io, mimetype='image/png', as_attachment=True, attachment_filename='meme.png')
    else:
        return jsonify({"error": "Image generation failed"}), 500

# Endpoint to redo meme generation
@app.route('/redoGeneration', methods=['POST'])
def redo_generation():
    data = request.json
    description = data.get('description', '')
    
    img = generate_image(description)
    if img:
        # Convert image to bytes for JSON response
        img_io = BytesIO()
        img.save(img_io, 'PNG')
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
        return jsonify({"imageFile": img_base64})
    else:
        return jsonify({"error": "Image generation failed"}), 500

# Endpoint to get sentiment analysis
@app.route('/getSentiment', methods=['GET'])
def get_sentiment():
    message = request.args.get('message', '')
    sentiment = analyze_sentiment(message)
    return jsonify({"sentiment": sentiment})

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
