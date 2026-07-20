"""Background removal using pretrained briaai/RMBG-2.0."""

from __future__ import annotations

import base64
import io

import torch
from PIL import Image
from torchvision import transforms
from transformers import AutoModelForImageSegmentation

from services.event_classifier import ModelUnavailableError


class BackgroundRemovalService:
    model_name = 'briaai/RMBG-2.0'
    image_size = (1024, 1024)

    def __init__(self) -> None:
        self._model = None
        self._device = 'cuda' if torch.cuda.is_available() else 'cpu'

    def _get_model(self):
        if self._model is None:
            try:
                torch.set_float32_matmul_precision('high')
                self._model = AutoModelForImageSegmentation.from_pretrained(
                    self.model_name,
                    trust_remote_code=True,
                ).eval().to(self._device)
            except Exception as error:  # pragma: no cover - machine/network dependent
                raise ModelUnavailableError(
                    'The pretrained background-removal model could not be loaded. '
                    'Start the backend with internet access once so it can download RMBG-2.0.'
                ) from error
        return self._model

    def remove_background(self, image_stream) -> dict:
        image = Image.open(image_stream).convert('RGB')
        transform_image = transforms.Compose([
            transforms.Resize(self.image_size),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        ])

        model = self._get_model()
        input_tensor = transform_image(image).unsqueeze(0).to(self._device)

        with torch.no_grad():
            preds = model(input_tensor)[-1].sigmoid().cpu()

        mask = transforms.ToPILImage()(preds[0].squeeze()).resize(image.size)
        result = image.copy()
        result.putalpha(mask)

        buffer = io.BytesIO()
        result.save(buffer, format='PNG')
        encoded = base64.b64encode(buffer.getvalue()).decode('ascii')
        return {
            'image_base64': encoded,
            'content_type': 'image/png',
        }
