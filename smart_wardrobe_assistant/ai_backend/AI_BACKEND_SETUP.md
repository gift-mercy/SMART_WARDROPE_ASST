# AI Backend Setup and Testing Guide

## Current Status: ✅ FULLY IMPLEMENTED

The AI functionality is **already fully implemented** in your project. No code changes are needed.

## Architecture Overview

```
Flutter Mobile Application
│
│ HTTP (localhost:8000)
▼
Python AI Backend (ai_backend/)
│
├── Background Removal AI (briaai/RMBG-2.0)
├── Clothing Analysis AI (patrickjohncyh/fashion-clip)
├── Calendar Event Classification AI (facebook/bart-large-mnli)
└── Recommendation Engine (AI + Rule-based)
│
▼
JSON Response
│
▼
Flutter Application
```

## Files That Already Exist

### Python Backend
- `app.py` - Flask API with all endpoints
- `services/event_classifier.py` - BART-MNLI zero-shot classification
- `services/recommendation_service.py` - AI + rule-based recommendations
- `services/background_removal_service.py` - RMBG-2.0 background removal
- `services/fashion_ai_service.py` - Fashion-CLIP clothing analysis
- `requirements.txt` - All dependencies

### Flutter Integration
- `lib/services/ai_service.dart` - HTTP client for AI backend
- `lib/models/recommendation_model.dart` - Has AI fields (aiEventType, aiWeatherSummary, confidenceScore)
- `lib/providers/recommendation_provider.dart` - Has generateAIRecommendation()
- `lib/screens/wardrobe/add_clothing_screen.dart` - Integrates clothing analysis
- `lib/screens/camera/background_removal_preview_screen.dart` - Integrates background removal
- `lib/screens/recommendations/recommendation_screen.dart` - Displays AI context

## Setup Instructions

### 1. Install Python Dependencies

```bash
cd ai_backend
.venv\Scripts\pip.exe install -r requirements.txt
```

### 2. Start the AI Backend

**Option A: Using the batch file (Windows)**
```bash
cd ai_backend
start_backend.bat
```

**Option B: Direct Python**
```bash
cd ai_backend
.venv\Scripts\python.exe app.py
```

The server will start on `http://localhost:8000`

**First run**: The server will download pretrained models (BART-MNLI, Fashion-CLIP, RMBG-2.0). This requires internet access and may take several minutes.

### 3. Configure Flutter Backend URL

The Flutter app defaults to `http://10.0.2.2:8000` for Android emulator.

For physical device testing, update the URL in `lib/services/ai_service.dart`:
```dart
AiService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'http://YOUR_PC_IP:8000';
```

## Testing the Backend

### Test Health Endpoint
```bash
curl http://localhost:8000/health
```

Expected response:
```json
{"success": true, "service": "smart-wardrobe-ai"}
```

### Test Event Classification
```bash
curl -X POST http://localhost:8000/api/classify-event ^
  -H "Content-Type: application/json" ^
  -d "{\"event_text\": \"Business presentation tomorrow\"}"
```

Expected response:
```json
{
  "success": true,
  "event_type": "formal",
  "confidence": 0.85,
  "scores": {...}
}
```

## Complete Demo Workflow

### 1. Add Clothing with AI
1. Open Wardrobe screen
2. Tap "Add Clothing"
3. Take or select photo
4. AI removes background (RMBG-2.0)
5. Preview and confirm
6. AI suggests category/style (Fashion-CLIP)
7. Edit if needed
8. Save to wardrobe

### 2. Get AI Recommendation
1. Open Calendar
2. Select event (e.g., "Business Presentation")
3. Open Recommendation screen
4. AI classifies event (BART-MNLI)
5. Weather is retrieved
6. Wardrobe is analyzed
7. Recommendation displayed with:
   - AI event type and confidence
   - Weather summary
   - Recommended outfit from your wardrobe
   - Explanation

## AI Transparency

The app clearly distinguishes:
- **AI predictions**: "Pretrained model (BART-MNLI): event classified as formal"
- **Application logic**: "Selected clothing from your wardrobe that matches the event and current weather"

## Error Handling

The app handles:
- AI backend unavailable
- Model loading failure
- Image upload failure
- Background removal failure
- No suitable clothing
- No weather data

## Models Used

1. **Background Removal**: `briaai/RMBG-2.0`
2. **Clothing Analysis**: `patrickjohncyh/fashion-clip`
3. **Event Classification**: `facebook/bart-large-mnli`

All are pretrained models. No training required.

## Important Notes

- The backend must be running before using AI features
- First run requires internet to download models
- Models are cached locally after first download
- The backend runs on port 8000
- Flutter app connects to backend via HTTP
