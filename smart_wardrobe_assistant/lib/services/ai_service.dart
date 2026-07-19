import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/calendar_event_model.dart';
import '../models/clothing_item.dart';
import '../models/recommendation_model.dart';
import '../models/weather_model.dart';

class AiServiceException implements Exception {
  const AiServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AiRecommendationResponse {
  const AiRecommendationResponse({
    required this.success,
    required this.message,
    required this.eventType,
    required this.confidence,
    required this.weatherSummary,
    required this.itemIds,
    required this.reason,
  });

  factory AiRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['recommended_items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['id'].toString())
        .toSet();
    return AiRecommendationResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'general',
      confidence: (json['ai_confidence'] as num?)?.toDouble() ?? 0,
      weatherSummary: json['weather_summary'] as String? ?? '',
      itemIds: items,
      reason: json['reason'] as String? ?? '',
    );
  }

  final bool success;
  final String message;
  final String eventType;
  final double confidence;
  final String weatherSummary;
  final Set<String> itemIds;
  final String reason;
}

class AiEventClassification {
  const AiEventClassification({
    required this.eventType,
    required this.confidence,
  });

  factory AiEventClassification.fromJson(Map<String, dynamic> json) {
    return AiEventClassification(
      eventType: json['event_type'] as String? ?? 'general',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  final String eventType;
  final double confidence;
}

class AiClothingAnalysis {
  const AiClothingAnalysis({
    required this.category,
    required this.style,
    required this.color,
    required this.categoryConfidence,
    required this.styleConfidence,
    required this.colorConfidence,
  });

  factory AiClothingAnalysis.fromJson(Map<String, dynamic> json) {
    final suggestions = json['suggestions'] as Map<String, dynamic>? ?? const {};
    final confidence = json['confidence'] as Map<String, dynamic>? ?? const {};
    return AiClothingAnalysis(
      category: suggestions['category'] as String? ?? '',
      style: suggestions['style'] as String? ?? '',
      color: suggestions['color'] as String? ?? '',
      categoryConfidence: (confidence['category'] as num?)?.toDouble() ?? 0,
      styleConfidence: (confidence['style'] as num?)?.toDouble() ?? 0,
      colorConfidence: (confidence['color'] as num?)?.toDouble() ?? 0,
    );
  }

  final String category;
  final String style;
  final String color;
  final double categoryConfidence;
  final double styleConfidence;
  final double colorConfidence;
}

/// HTTP gateway to the local Python backend. No model runs on the phone.
class AiService {
  AiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment(
          'AI_BACKEND_URL',
          defaultValue: 'http://10.0.2.2:8000',
        );

  final http.Client _client;
  final String _baseUrl;

  Future<AiRecommendationResponse> recommendOutfit({
    required WeatherModel weather,
    required List<ClothingItem> wardrobe,
    CalendarEventModel? calendarEvent,
    required RecommendationPreference preference,
  }) async {
    final eventTitle = calendarEvent?.title ?? 'Everyday wardrobe recommendation';
    final payload = {
      'event': {'title': eventTitle},
      'weather': {
        'temperature': weather.temperature,
        'condition': weather.condition,
      },
      'wardrobe': wardrobe.map(_wardrobeJson).toList(growable: false),
      'preference': preference.name,
    };

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/recommend-outfit'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiServiceException(body['message'] as String? ?? 'The AI service is unavailable.');
      }
      return AiRecommendationResponse.fromJson(body);
    } on TimeoutException {
      throw const AiServiceException('The AI service took too long to respond. Please retry.');
    } on http.ClientException {
      throw const AiServiceException(
        'The AI backend is unavailable. Start ai_backend/app.py and check the backend URL.',
      );
    } on FormatException {
      throw const AiServiceException('The AI backend returned an invalid response.');
    }
  }

  Future<AiEventClassification> classifyEvent(String eventText) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/classify-event'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'event_text': eventText}),
          )
          .timeout(const Duration(seconds: 60));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300 || body['success'] != true) {
        throw AiServiceException(body['message'] as String? ?? 'Event classification failed.');
      }
      return AiEventClassification.fromJson(body);
    } on TimeoutException {
      throw const AiServiceException('Event classification timed out. Please retry.');
    } on http.ClientException {
      throw const AiServiceException(
        'The AI backend is unavailable. Start ai_backend/app.py and check the backend URL.',
      );
    } on FormatException {
      throw const AiServiceException('The AI backend returned an invalid response.');
    }
  }

  /// Sends an image to RMBG-2.0 and saves the returned PNG locally.
  /// The original [imagePath] is never deleted by this method.
  Future<String> removeBackground(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const AiServiceException('The selected image could not be found.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/remove-background'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamed = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300 || body['success'] != true) {
        throw AiServiceException(body['message'] as String? ?? 'Background removal failed.');
      }

      final encoded = body['image_base64'] as String?;
      if (encoded == null || encoded.isEmpty) {
        throw const AiServiceException('Background removal returned an empty image.');
      }

      final bytes = base64Decode(encoded);
      final directory = await getTemporaryDirectory();
      final outputPath = p.join(
        directory.path,
        'bg_removed_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } on TimeoutException {
      throw const AiServiceException('Background removal timed out. Please retry.');
    } on http.ClientException {
      throw const AiServiceException(
        'The AI backend is unavailable. Start ai_backend/app.py and check the backend URL.',
      );
    } on FormatException {
      throw const AiServiceException('The AI backend returned an invalid response.');
    }
  }

  Future<AiClothingAnalysis> analyzeClothing(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const AiServiceException('The selected image could not be found.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/analyze-clothing'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300 || body['success'] != true) {
        throw AiServiceException(body['message'] as String? ?? 'Clothing analysis failed.');
      }
      return AiClothingAnalysis.fromJson(body);
    } on TimeoutException {
      throw const AiServiceException('Clothing analysis timed out. Please retry.');
    } on http.ClientException {
      throw const AiServiceException(
        'The AI backend is unavailable. Start ai_backend/app.py and check the backend URL.',
      );
    } on FormatException {
      throw const AiServiceException('The AI backend returned an invalid response.');
    }
  }

  Map<String, dynamic> _wardrobeJson(ClothingItem item) => {
        'id': item.clothingId?.toString() ?? '',
        'name': item.clothingName,
        'category': item.categoryName ?? '',
        'color': item.colorName ?? '',
        'style': item.occasionName ?? '',
        'season': item.seasonName ?? '',
      };
}
