import unittest

from services.event_classifier import EventClassifier


class EventClassifierTests(unittest.TestCase):
    def test_returns_model_labels_and_scores_without_keyword_fallback(self):
        classifier = EventClassifier()
        classifier._pipeline = lambda *_args, **_kwargs: {
            'labels': ['formal', 'casual', 'sports', 'outdoor', 'general'],
            'scores': [0.91, 0.03, 0.02, 0.01, 0.03],
        }
        result = classifier.classify('I have an important presentation at work tomorrow.')
        self.assertEqual(result['event_type'], 'formal')
        self.assertEqual(result['confidence'], 0.91)
        self.assertEqual(result['scores']['formal'], 0.91)


if __name__ == '__main__':
    unittest.main()
