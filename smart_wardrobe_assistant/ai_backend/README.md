# Smart Wardrobe AI backend

This small Flask service runs pretrained models on a computer, not on the phone:

- `facebook/bart-large-mnli` — zero-shot calendar event classification (real model confidence).
- `briaai/RMBG-2.0` — background removal for clothing photos.
- `patrickjohncyh/fashion-clip` — optional clothing image suggestions (user confirms/edits).
- Application logic — wardrobe matching after the pretrained model classifies an event.

## Start it

From this folder on a computer with Python 3.10+:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

The first request for each model downloads weights from Hugging Face (internet required once). Check the server with `http://127.0.0.1:8000/health`.

For an Android emulator, the Flutter default backend address (`http://10.0.2.2:8000`) reaches this computer. For a physical device, run Flutter with your computer's LAN IP:

```powershell
flutter run --dart-define=AI_BACKEND_URL=http://192.168.1.10:8000
```

Do not expose this development server publicly. A deployed version needs HTTPS, authentication, and request limits.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/health` | Health check |
| POST | `/api/classify-event` | BART-MNLI event classification |
| POST | `/api/recommend-outfit` | Classify event + wardrobe matching |
| POST | `/api/remove-background` | RMBG-2.0 background removal |
| POST | `/api/analyze-clothing` | FashionCLIP category/style suggestions |

## Test plan

Run backend unit tests after installing requirements:

```powershell
python -m unittest discover -s tests
```

Manual acceptance tests:

1. `I have an important presentation at work tomorrow.` → `formal`.
2. `I am meeting friends for dinner.` → `casual`.
3. `I am going to the gym.` → `sports`.
4. Upload a clothing photo to `/api/remove-background` → PNG with transparent background.
5. Upload a clothing photo to `/api/analyze-clothing` → category/style suggestions.
6. Repeat a formal event with hot, cold, and rainy weather; formal clothing should remain preferred.
7. Remove matching items from the wardrobe payload; API returns `success: false`.
8. Stop `app.py`, refresh the Flutter Recommendations screen, confirm error + retry.

Example event request:

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8000/api/classify-event -ContentType application/json -Body '{"event_text":"I have an important presentation at work tomorrow."}'
```
