"""Pretrained BART-MNLI calendar event classifier."""

from __future__ import annotations

from transformers import pipeline


class ModelUnavailableError(RuntimeError):
    """The server could not load a required pretrained model."""


class EventClassifier:
    model_name = 'facebook/bart-large-mnli'
    labels = ('formal', 'casual', 'sports', 'outdoor', 'general')

    def __init__(self) -> None:
        self._pipeline = None

    def _get_pipeline(self):
        if self._pipeline is None:
            try:
                self._pipeline = pipeline(
                    'zero-shot-classification',
                    model=self.model_name,
                )
            except Exception as error:  # pragma: no cover - machine/network dependent
                raise ModelUnavailableError(
                    'The pretrained event-classification model could not be loaded. '
                    'Start the backend with internet access once so it can download the model.'
                ) from error
        return self._pipeline

    def classify(self, event_text: str) -> dict:
        result = self._get_pipeline()(event_text, candidate_labels=list(self.labels), multi_label=False)
        scores = {label: float(score) for label, score in zip(result['labels'], result['scores'])}
        return {
            'event_type': result['labels'][0],
            'confidence': float(result['scores'][0]),
            'scores': scores,
        }
