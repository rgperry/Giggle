import json
import base64
import io
from django.test import TestCase, Client
from django.urls import reverse
from PIL import Image
import tempfile
from django.core.files.uploadedfile import SimpleUploadedFile

class ViewsTestCase(TestCase):
    def setUp(self):
        # Initialize the test client
        self.client = Client()

    def create_test_image(self):
        # Create a simple image for testing
        image = Image.new("RGB", (100, 100), color="red")
        buffer = io.BytesIO()
        image.save(buffer, format="PNG")
        buffer.seek(0)
        return buffer

    # Old test cases
    def test_generate_meme(self):
        # Test the generate_meme endpoint
        response = self.client.get(reverse('generate_meme'), {'description': 'A cat'})

        # Check if the response is successful
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'image/png')

    def test_generate_meme_error(self):
        # Test generate_meme without a description to simulate failure
        response = self.client.get(reverse('generate_meme'))
        self.assertEqual(response.status_code, 400)  # Expecting a 400 error
        self.assertJSONEqual(response.content, {"error": "Description cannot be empty"})

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
        self.assertEqual(response.status_code, 400)  # Expecting a 400 error
        self.assertJSONEqual(response.content, {"error": "Message cannot be empty"})

    # New test cases for image_info
    def test_image_info_success(self):
        # Create a test image and encode it as base64
        image_buffer = self.create_test_image()
        image_base64 = base64.b64encode(image_buffer.getvalue()).decode('utf-8')

        # Prepare valid payload with image data
        payload = [
            {
                "Id": "test_image_1",
                "imageFile": image_base64
            }
        ]

        response = self.client.post(
            reverse('image_info'), 
            data=json.dumps(payload),
            content_type="application/json"
        )

        # Validate response
        self.assertEqual(response.status_code, 200)
        response_data = response.json()
        self.assertEqual(len(response_data), 1)
        self.assertIn("tags", response_data[0])
        self.assertIn("content", response_data[0])

    def test_image_info_invalid_base64(self):
        # Prepare payload with invalid base64 data
        payload = [
            {
                "Id": "test_image_2",
                "imageFile": "invalid_base64_data"
            }
        ]

        response = self.client.post(
            reverse('image_info'), 
            data=json.dumps(payload),
            content_type="application/json"
        )

        # Validate response
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.json())

    def test_image_info_batch_size_exceeded(self):
        # Create a valid image
        image_buffer = self.create_test_image()
        image_base64 = base64.b64encode(image_buffer.getvalue()).decode('utf-8')

        # Create payload exceeding the batch size limit
        payload = [{"Id": f"image_{i}", "imageFile": image_base64} for i in range(11)]

        response = self.client.post(
            reverse('image_info'), 
            data=json.dumps(payload),
            content_type="application/json"
        )

        # Validate response
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "Batch size exceeds limit of 10 images"})

    def test_image_info_missing_fields(self):
        # Prepare payload missing required fields
        payload = [
            {
                "imageFile": "some_base64_data"  # Missing the "Id" field
            }
        ]

        response = self.client.post(
            reverse('image_info'), 
            data=json.dumps(payload),
            content_type="application/json"
        )

        # Validate response
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.json())

    def test_image_info_invalid_json(self):
        # Send invalid JSON data
        response = self.client.post(
            reverse('image_info'), 
            data="Invalid JSON data",
            content_type="application/json"
        )

        # Validate response
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "Invalid JSON data"})

    def create_test_video(self):
        """
        temporary video file for testing.
        """
        temp_video = tempfile.NamedTemporaryFile(suffix=".mp4", delete=False)
        with open(temp_video.name, "wb") as video:
            video.write(b"\x00" * 1024 * 1024)  
        return temp_video.name


    def test_video_info_success(self):
        """
        Test the video_info endpoint 
        """
        video_path = self.create_test_video()
        with open(video_path, "rb") as video_file:
            response = self.client.post(
                reverse('video_info'),
                {
                    'video': SimpleUploadedFile("test_video.mp4", video_file.read(), content_type="video/mp4")
                },
                {'numTags': 5, 'frameSampleRate': 2},
            )


        self.assertEqual(response.status_code, 200)
        response_data = response.json()
        self.assertIn("tags", response_data)
        self.assertTrue(isinstance(response_data["tags"], list))
        self.assertGreater(len(response_data["tags"]), 0)

    def test_video_info_no_video(self):
        """
        Testing endpoint without providing a video file.
        """
        response = self.client.post(
            reverse('video_info'),
            data={},
            content_type="multipart/form-data"
        )
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "No video file provided"})

    def test_video_info_invalid_video_format(self):
        """
        Testing endpoint with invalid file format.
        """
        image_buffer = self.create_test_image()
        response = self.client.post(
            reverse('video_info'),
            {
                'video': SimpleUploadedFile(
                    "test_image.png",
                    image_buffer.getvalue(),
                    content_type="image/png"
                )
            },
            content_type="multipart/form-data"
        )
        self.assertEqual(response.status_code, 500) 
        response_data = response.json()
        self.assertIn("error", response_data)

    def test_video_info_invalid_json_payload(self):
        """
        testing with invalid JSON payload 
        """
        response = self.client.post(
            reverse('video_info'),
            data="Invalid JSON data",
            content_type="application/json"
        )
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "Invalid JSON data"})
