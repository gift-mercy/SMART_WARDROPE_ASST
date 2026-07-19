"""Optional FashionCLIP image assistant. It suggests fields; users confirm them."""

from __future__ import annotations

from PIL import Image
from transformers import pipeline

from services.event_classifier import ModelUnavailableError


class FashionAIService:
    model_name = 'patrickjohncyh/fashion-clip'
    categories = ('shirt', 't-shirt', 'trousers', 'jeans', 'dress', 'skirt', 'jacket', 'shoes', 'accessory')
    styles = ('formal', 'casual', 'sportswear', 'outdoor')
    colors = ('black', 'white', 'blue', 'brown', 'grey', 'green', 'red', 'yellow', 'pink', 'purple')

    def __init__(self) -> None:
        self._pipeline = None

    def _get_pipeline(self):
        if self._pipeline is None:
            try:
                self._pipeline = pipeline('zero-shot-image-classification', model=self.model_name)
            except Exception as error:  # pragma: no cover - machine/network dependent
                raise ModelUnavailableError(
                    'FashionCLIP could not be loaded. It is optional and requires a one-time model download.'
                ) from error
        return self._pipeline

    def analyze(self, image_stream) -> dict:
        image = Image.open(image_stream).convert('RGB')
        classifier = self._get_pipeline()
        category = classifier(image, candidate_labels=list(self.categories))[0]
        style = classifier(image, candidate_labels=list(self.styles))[0]
        color = classifier(image, candidate_labels=list(self.colors))[0]
        return {
            'suggestions': {
                'category': category['label'],
                'style': style['label'],
                'color': color['label'],
            },
            'confidence': {
                'category': float(category['score']),
                'style': float(style['score']),
                'color': float(color['score']),
            },
            'requires_user_confirmation': True,
        }
