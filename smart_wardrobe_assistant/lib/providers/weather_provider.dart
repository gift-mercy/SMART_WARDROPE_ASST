// ============================================
// WEATHER_PROVIDER.DART
// ============================================
// Provider class for weather state management
// Handles loading states, errors, and weather data updates
// ============================================

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Weather state enum
enum WeatherState {
  initial,      // No data loaded yet
  loading,      // Currently fetching data
  loaded,       // Data successfully loaded
  error,        // Error occurred
  locationDenied, // Location permission denied
}

class WeatherProvider extends ChangeNotifier {
  // ============================================
  // STATE VARIABLES
  // ============================================

  WeatherState _state = WeatherState.initial;
  WeatherModel? _weather;
  String? _errorMessage;
  final WeatherService _weatherService = WeatherService.instance;

  // ============================================
  // GETTERS
  // ============================================

  WeatherState get state => _state;
  WeatherModel? get weather => _weather;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == WeatherState.loading;
  bool get hasError => _state == WeatherState.error;
  bool get hasData => _state == WeatherState.loaded && _weather != null;
  bool get isLocationDenied => _state == WeatherState.locationDenied;

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Fetch weather by current GPS location
  Future<void> fetchWeatherByLocation() async {
    _setState(WeatherState.loading);
    _errorMessage = null;

    try {
      // Try to get cached weather first
      final cachedWeather = await _weatherService.getLastCachedWeather();
      if (cachedWeather != null && !cachedWeather.isStale) {
        _weather = cachedWeather;
        _setState(WeatherState.loaded);
        print('Using cached weather: ${cachedWeather.cityName}');
        return;
      }

      // Fetch fresh weather data
      _weather = await _weatherService.fetchWeatherByCurrentLocation();
      _setState(WeatherState.loaded);
      print('Weather loaded: ${_weather!.cityName}');
    } catch (e) {
      print('Error in fetchWeatherByLocation: $e');
      
      // Check if it's a location permission error
      if (e.toString().contains('permission') || 
          e.toString().contains('denied')) {
        _errorMessage = 'Location access is required to show weather information.';
        _setState(WeatherState.locationDenied);
      } else if (e.toString().contains('Location services are disabled')) {
        _errorMessage = 'Please enable location services to see weather information.';
        _setState(WeatherState.error);
      } else if (e.toString().contains('timed out')) {
        _errorMessage = 'Request timed out. Please check your internet connection.';
        _setState(WeatherState.error);
      } else if (e.toString().contains('API key')) {
        _errorMessage = 'Weather service configuration error. Please contact support.';
        _setState(WeatherState.error);
      } else {
        _errorMessage = 'Unable to fetch weather data. Please try again later.';
        _setState(WeatherState.error);
      }

      // Try to load cached weather as fallback
      await _loadCachedWeatherAsFallback();
      
      // Re-throw the exception so initializeWeather can catch it and try the city fallback
      rethrow;
    }
  }

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String cityName) async {
    _setState(WeatherState.loading);
    _errorMessage = null;

    try {
      // Try to get cached weather first
      final cachedWeather = await _weatherService.getCachedWeather(cityName);
      if (cachedWeather != null && !cachedWeather.isStale) {
        _weather = cachedWeather;
        _setState(WeatherState.loaded);
        print('Using cached weather: ${cachedWeather.cityName}');
        return;
      }

      // Fetch fresh weather data
      _weather = await _weatherService.fetchWeatherByCity(cityName);
      _setState(WeatherState.loaded);
      print('Weather loaded: ${_weather!.cityName}');
    } catch (e) {
      print('Error in fetchWeatherByCity: $e');
      
      if (e.toString().contains('City not found')) {
        _errorMessage = 'City not found. Please check the city name.';
      } else if (e.toString().contains('timed out')) {
        _errorMessage = 'Request timed out. Please check your internet connection.';
      } else {
        _errorMessage = 'Unable to fetch weather data. Please try again later.';
      }
      
      _setState(WeatherState.error);

      // Try to load cached weather as fallback
      await _loadCachedWeatherAsFallback();
    }
  }

  /// Refresh weather data
  Future<void> refreshWeather() async {
    if (_weather != null) {
      // Refresh using the same method (location or city)
      await fetchWeatherByLocation();
    } else {
      await fetchWeatherByLocation();
    }
  }

  /// Load cached weather as fallback
  Future<void> _loadCachedWeatherAsFallback() async {
    try {
      final cachedWeather = await _weatherService.getLastCachedWeather();
      if (cachedWeather != null) {
        _weather = cachedWeather;
        // Keep error state but show cached data
        print('Using cached weather as fallback: ${cachedWeather.cityName}');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached weather: $e');
    }
  }

  /// Check location permission status
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await _weatherService.checkLocationPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _weatherService.requestLocationPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Permission granted, fetch weather
        await fetchWeatherByLocation();
        return true;
      }
      return false;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == WeatherState.error) {
      _setState(WeatherState.initial);
    }
  }

  /// Initialize weather (load cached data first, then fetch fresh)
  Future<void> initializeWeather() async {
    // Try to load cached weather immediately
    final cachedWeather = await _weatherService.getLastCachedWeather();
    if (cachedWeather != null) {
      _weather = cachedWeather;
      _setState(WeatherState.loaded);
      notifyListeners();
    }

    // Prioritize city-based weather for better reliability on emulators
    // Try default city (Kampala) first
    try {
      print('Attempting to fetch weather for default city (Kampala)...');
      await fetchWeatherByCity('Kampala');
      return; // Success! Exit early
    } catch (cityError) {
      print('Failed to fetch weather for default city: $cityError');
    }

    // If city fetch fails, try GPS location as fallback
    try {
      print('Falling back to GPS location...');
      await fetchWeatherByLocation();
    } catch (e) {
      print('Failed to get weather by location: $e');
      // Both methods failed, but we might have cached data
      if (_weather == null) {
        _errorMessage = 'Unable to fetch weather data. Please check your internet connection.';
        _setState(WeatherState.error);
      }
    }
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  /// Update state and notify listeners
  void _setState(WeatherState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _state = WeatherState.initial;
    _weather = null;
    _errorMessage = null;
    notifyListeners();
  }
}
