import json
import base64
import io
from django.test import TestCase, Client
from django.urls import reverse
from PIL import Image

class ViewsTestCase(TestCase):
    def setUp(self):
        # Initialize the test client
        self.client = Client()

    def test_generate_meme(self):
        # Test the generate_meme endpoint
        response = self.client.get(reverse('generate_meme'), {'description': 'A cat sitting on a laptop'})

        # Check if the response is successful
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'image/png')

    def test_generate_meme_error(self):
        # Test generate_meme without a description to simulate failure
        response = self.client.get(reverse('generate_meme'))
        self.assertEqual(response.status_code, 400)  # Updated to expect 400 instead of 500
        self.assertJSONEqual(response.content, {"error": "Description cannot be empty"})  # Updated error message

    def test_redo_generation(self):
        # Test the redo_generation endpoint
        data = json.dumps({"description": "A sunrise over a mountain"})
        response = self.client.post(reverse('redo_generation'), data, content_type='application/json')

        # Check if the response is successful and contains a base64 image
        self.assertEqual(response.status_code, 200)
        response_data = response.json()
        self.assertIn("imageFile", response_data)

        # Validate the image by decoding the base64 content
        image_data = base64.b64decode(response_data["imageFile"])
        image = Image.open(io.BytesIO(image_data))
        self.assertEqual(image.format, 'PNG')

    def test_redo_generation_invalid_data(self):
        # Test redo_generation with invalid JSON
        response = self.client.post(reverse('redo_generation'), "invalid json", content_type='application/json')
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "Invalid JSON data"})

    def test_get_sentiment(self):
        # Test the get_sentiment endpoint
        response = self.client.get(reverse('get_sentiment'), {'message': 'I love this!'})

        # Check if the response is successful
        self.assertEqual(response.status_code, 200)
        response_data = response.json()
        self.assertIn("sentiment", response_data)
        self.assertNotEqual(response_data["sentiment"], "Error in analyzing sentiment")

    def test_get_sentiment_no_message(self):
        # Test get_sentiment with no message to simulate failure
        response = self.client.get(reverse('get_sentiment'))
        self.assertEqual(response.status_code, 400)  # Updated to expect 400 instead of 500
        self.assertJSONEqual(response.content, {"error": "Message cannot be empty"})  # Updated error message

