import unittest

from services.recommendation_service import RecommendationEngine


class RecommendationEngineTests(unittest.TestCase):
    def test_formal_event_recommends_only_supplied_formal_items(self):
        result = RecommendationEngine().recommend(
            classification={'event_type': 'formal', 'confidence': 0.91},
            weather={'temperature': 28, 'condition': 'Sunny'},
            wardrobe=[
                {'id': '1', 'name': 'White Shirt', 'category': 'Shirt', 'color': 'White', 'style': 'Formal'},
                {'id': '2', 'name': 'Black Trousers', 'category': 'Trousers', 'color': 'Black', 'style': 'Formal'},
                {'id': '3', 'name': 'Formal Shoes', 'category': 'Shoes', 'color': 'Black', 'style': 'Formal'},
            ],
            preference='balanced',
        )
        self.assertTrue(result['success'])
        self.assertEqual({item['id'] for item in result['recommended_items']}, {'1', '2', '3'})
        self.assertEqual(result['ai_confidence'], 0.91)


if __name__ == '__main__':
    unittest.main()
