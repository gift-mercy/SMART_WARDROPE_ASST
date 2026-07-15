// ============================================
// WEATHER_SERVICE.DART
// ============================================
// Service class for fetching weather data from OpenWeatherMap API
// Handles API calls, location services, and error handling
// ============================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';

class WeatherService {
  // OpenWeatherMap API configuration
  // Sign up at: https://openweathermap.org/api
  static const String _apiKey = '9553412c7611a827959fb7df94b98711'; // Replace with your actual API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Singleton pattern
  WeatherService._privateConstructor();
  static final WeatherService instance = WeatherService._privateConstructor();

  // ============================================
  // LOCATION SERVICES
  // ============================================

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current GPS position
  /// Throws exception if location services are disabled or permission denied
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. '
        'Please enable location access in app settings.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // ============================================
  // WEATHER API CALLS
  // ============================================

  /// Fetch weather data by GPS coordinates
  Future<WeatherModel> fetchWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Build API URL
      final url = Uri.parse(
        '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      print('Fetching weather from: $url');

      // Make HTTP GET request
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Weather API request timed out. Please try again.');
        },
      );

      print('Weather API response status: ${response.statusCode}');

      // Check response status
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        print('Weather data received: ${data['name']}');

        // Create WeatherModel from JSON
        final weather = WeatherModel.fromJson(data);

        // Cache weather data in database
        await _cacheWeatherData(weather);

        return weather;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        throw Exception('Location not found. Please try again.');
      } else {
        throw Exception('Failed to fetch weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      rethrow;
    }
  }

  /// Fetch weather data using current GPS location
  Future<WeatherModel> fetchWeatherByCurrentLocation() async {
    try {
      // Get current position
      Position position = await getCurrentPosition();

      print('Got location: ${position.latitude}, ${position.longitude}');

      // Fetch weather using coordinates
      return await fetchWeatherByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error fetching weather by location: $e');
      rethrow;
    }
  }

  /// Fetch weather data by city name
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    try {
      // Build API URL
      final url = Uri.parse(
        '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric',
      );

      print('Fetching weather for city: $cityName');

      // Make HTTP GET request
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Weather API request timed out. Please try again.');
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Create WeatherModel from JSON
        final weather = WeatherModel.fromJson(data);

        // Cache weather data in database
        await _cacheWeatherData(weather);

        return weather;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else {
        throw Exception('Failed to fetch weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather by city: $e');
      rethrow;
    }
  }

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  /// Cache weather data in local database
  Future<void> _cacheWeatherData(WeatherModel weather) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if cache exists for this city
      final existing = await db.query(
        TableNames.weatherCache,
        where: 'city = ?',
        whereArgs: [weather.cityName],
      );

      if (existing.isNotEmpty) {
        // Update existing cache
        await db.update(
          TableNames.weatherCache,
          weather.toMap(),
          where: 'city = ?',
          whereArgs: [weather.cityName],
        );
        print('Updated weather cache for ${weather.cityName}');
      } else {
        // Insert new cache
        await db.insert(
          TableNames.weatherCache,
          weather.toMap(),
        );
        print('Cached weather data for ${weather.cityName}');
      }
    } catch (e) {
      print('Error caching weather data: $e');
      // Don't throw - caching is optional
    }
  }

  /// Get cached weather data
  Future<WeatherModel?> getCachedWeather(String cityName) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        TableNames.weatherCache,
        where: 'city = ?',
        whereArgs: [cityName],
      );

      if (results.isNotEmpty) {
        final weather = WeatherModel.fromMap(results.first);

        // Check if cache is still valid (less than 1 hour old)
        if (!weather.isStale) {
          print('Using cached weather for ${weather.cityName}');
          return weather;
        } else {
          print('Cached weather is stale for ${weather.cityName}');
        }
      }

      return null;
    } catch (e) {
      print('Error getting cached weather: $e');
      return null;
    }
  }

  /// Get last cached weather (any city)
  Future<WeatherModel?> getLastCachedWeather() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        TableNames.weatherCache,
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (results.isNotEmpty) {
        return WeatherModel.fromMap(results.first);
      }

      return null;
    } catch (e) {
      print('Error getting last cached weather: $e');
      return null;
    }
  }

  /// Clear weather cache
  Future<void> clearCache() async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(TableNames.weatherCache);
      print('Weather cache cleared');
    } catch (e) {
      print('Error clearing weather cache: $e');
    }
  }
}
