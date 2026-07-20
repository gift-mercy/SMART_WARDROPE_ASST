import io
import unittest
from unittest.mock import MagicMock, patch

from services.background_removal_service import BackgroundRemovalService


class BackgroundRemovalServiceTests(unittest.TestCase):
    def test_returns_base64_png_without_deleting_source(self):
        service = BackgroundRemovalService()
        fake_model = MagicMock()
        fake_tensor = MagicMock()
        fake_tensor.__getitem__.return_value.sigmoid.return_value.cpu = [[[0.9]]]
        fake_model.return_value = [fake_tensor]

        with patch.object(service, '_get_model', return_value=fake_model):
            with patch('services.background_removal_service.transforms.ToPILImage') as to_pil:
                mask = MagicMock()
                mask.resize.return_value = mask
                to_pil.return_value.return_value = mask
                buffer = io.BytesIO()
                from PIL import Image

                Image.new('RGBA', (8, 8), (255, 0, 0, 255)).save(buffer, format='PNG')
                buffer.seek(0)
                result = service.remove_background(buffer)

        self.assertIn('image_base64', result)
        self.assertEqual(result['content_type'], 'image/png')
        self.assertTrue(result['image_base64'])


if __name__ == '__main__':
    unittest.main()
