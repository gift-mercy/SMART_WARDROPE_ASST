// ============================================
// WEATHER_MODEL.DART
// ============================================
// Model class for weather data from API
// Parses JSON response from OpenWeatherMap API
// ============================================

class WeatherModel {
  final String cityName;
  final double temperature; // in Celsius
  final String condition; // e.g., "Clear", "Clouds", "Rain"
  final String description; // e.g., "clear sky", "light rain"
  final String icon; // Weather icon code from API
  final int humidity;
  final double windSpeed;
  final DateTime timestamp;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });

  /// Factory constructor to create WeatherModel from JSON
  /// JSON structure from OpenWeatherMap API
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  /// Convert WeatherModel to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'city': cityName,
      'temperature': temperature,
      'weather_condition': condition,
      'updated_at': timestamp.toIso8601String(),
    };
  }

  /// Factory constructor to create WeatherModel from database
  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      cityName: map['city'] ?? 'Unknown',
      temperature: (map['temperature'] as num).toDouble(),
      condition: map['weather_condition'] ?? 'Unknown',
      description: map['weather_condition'] ?? '',
      icon: _getIconFromCondition(map['weather_condition'] ?? ''),
      humidity: 0,
      windSpeed: 0.0,
      timestamp: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Helper method to get weather icon code from condition
  static String _getIconFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '01d';
      case 'clouds':
        return '02d';
      case 'rain':
        return '10d';
      case 'drizzle':
        return '09d';
      case 'thunderstorm':
        return '11d';
      case 'snow':
        return '13d';
      case 'mist':
      case 'fog':
        return '50d';
      default:
        return '01d';
    }
  }

  /// Get weather emoji based on condition
  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '☀️';
    }
  }

  /// Get user-friendly weather description
  String get friendlyDescription {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Perfect weather for light clothing.';
      case 'clouds':
        return 'Partly cloudy, bring a light jacket.';
      case 'rain':
        return 'It\'s raining! Don\'t forget an umbrella.';
      case 'drizzle':
        return 'Light rain, consider a raincoat.';
      case 'thunderstorm':
        return 'Stormy weather, stay safe indoors.';
      case 'snow':
        return 'Snow outside! Wear warm clothes.';
      case 'mist':
      case 'fog':
        return 'Misty conditions, drive carefully.';
      default:
        return 'Check the weather before heading out.';
    }
  }

  /// Check if weather data is stale (older than 1 hour)
  bool get isStale {
    return DateTime.now().difference(timestamp).inHours >= 1;
  }

  /// Format temperature for display
  String get temperatureDisplay => '${temperature.round()}°C';

  @override
  String toString() {
    return 'WeatherModel(city: $cityName, temp: ${temperatureDisplay}, condition: $condition)';
  }
}
