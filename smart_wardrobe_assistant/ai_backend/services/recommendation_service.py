"""Transparent wardrobe matching after the pretrained model classifies an event."""

from __future__ import annotations


class RecommendationEngine:
    _event_terms = {
        'formal': ('formal', 'business', 'shirt', 'trouser', 'blazer', 'dress shoe'),
        'casual': ('casual', 'jean', 't-shirt', 'sneaker', 'polo'),
        'sports': ('sport', 'gym', 'athletic', 'trainer', 'track'),
        'outdoor': ('outdoor', 'jacket', 'boot', 'rain', 'hiking'),
        'general': (),
    }

    def recommend(self, *, classification: dict, weather: dict, wardrobe: list[dict], preference: str) -> dict:
        event_type = classification['event_type']
        temperature = float(weather['temperature'])
        condition = weather['condition']
        scored = []
        for item in wardrobe:
            if not item.get('id') or not item.get('name'):
                continue
            text = ' '.join(str(item.get(key, '')).lower() for key in ('name', 'category', 'color', 'style', 'season'))
            score = self._event_score(text, event_type)
            score += self._weather_score(text, temperature, condition)
            score += self._preference_score(text, preference)
            if score > 0:
                scored.append((score, item))

        scored.sort(key=lambda entry: entry[0], reverse=True)
        selected, categories = [], set()
        for _, item in scored:
            category = str(item.get('category', item['name'])).lower()
            if category in categories:
                continue
            selected.append({'id': str(item['id']), 'name': item['name']})
            categories.add(category)
            if len(selected) == 3:
                break

        if not selected:
            return {
                'success': False,
                'message': 'No suitable outfit could be found from your current wardrobe.',
                'event_type': event_type,
                'ai_confidence': classification['confidence'],
            }

        return {
            'success': True,
            'event_type': event_type,
            'ai_confidence': classification['confidence'],
            'weather_summary': f'{temperature:g}°C, {condition}',
            'recommended_items': selected,
            'reason': self._reason(event_type, temperature, condition),
        }

    def _event_score(self, text: str, event_type: str) -> int:
        terms = self._event_terms[event_type]
        return 60 if any(term in text for term in terms) else (10 if event_type == 'general' else 0)

    @staticmethod
    def _weather_score(text: str, temperature: float, condition: str) -> int:
        condition = condition.lower()
        if 'rain' in condition and any(term in text for term in ('rain', 'boot', 'jacket')):
            return 25
        if temperature >= 27 and any(term in text for term in ('short', 't-shirt', 'linen', 'light')):
            return 20
        if temperature <= 16 and any(term in text for term in ('jacket', 'coat', 'sweater', 'boot')):
            return 20
        return 5

    @staticmethod
    def _preference_score(text: str, preference: str) -> int:
        if preference == 'formal' and any(term in text for term in ('formal', 'business')):
            return 15
        if preference == 'casual' and 'casual' in text:
            return 15
        if preference == 'comfortable' and any(term in text for term in ('casual', 'sport', 'sneaker')):
            return 15
        return 0

    @staticmethod
    def _reason(event_type: str, temperature: float, condition: str) -> str:
        weather = 'warm' if temperature >= 24 else 'cold' if temperature <= 16 else 'mild'
        return (
            f'The pretrained AI model classified the event as {event_type}. '
            f'The selected items are from your wardrobe and suit the {weather} weather ({temperature:g}°C, {condition}).'
        )
