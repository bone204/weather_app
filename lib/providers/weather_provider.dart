import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  Position? _currentPosition;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  WeatherService get weatherService => _weatherService;

  set weatherData(Map<String, dynamic>? data) {
    _weatherData = data;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Không thể truy cập vị trí');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high
      );
      
      _currentPosition = position;
      await fetchWeatherData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchWeatherData() async {
    try {
      if (_currentPosition != null) {
        final data = await _weatherService.fetchWeather(
          '${_currentPosition!.latitude},${_currentPosition!.longitude}'
        );
        _weatherData = data;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    final results = await _weatherService.searchLocations(query);
    
    _searchResults = results;
    _isSearching = false;
    notifyListeners();
  }

  Future<void> fetchWeatherByLocation(String location) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final data = await _weatherService.fetchWeather(location);
      _weatherData = data;
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
} 