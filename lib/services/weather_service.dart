import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = dotenv.env['WEATHER_API_KEY'] ?? ''; 
  final String baseUrl = 'http://api.weatherapi.com/v1';

  String getIconUrl(String? iconCode) {
    if (iconCode == null) return '';
    // WeatherAPI trả về icon dạng "//cdn.weatherapi.com/weather/64x64/day/116.png"
    // Cần thêm https: vào đầu URL
    return 'https:$iconCode';
  }

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    final url = Uri.parse('$baseUrl/search.json?key=$apiKey&q=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Lỗi tìm kiếm địa điểm: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final url = Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$city&days=1&aqi=no');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Chuyển đổi URL icon cho current weather
        if (data['current']?['condition']?['icon'] != null) {
          data['current']['condition']['icon'] = 
              getIconUrl(data['current']['condition']['icon']);
        }
        
        // Chuyển đổi URL icon cho forecast
        if (data['forecast']?['forecastday']?.isNotEmpty) {
          for (var hour in data['forecast']['forecastday'][0]['hour']) {
            if (hour['condition']?['icon'] != null) {
              hour['condition']['icon'] = getIconUrl(hour['condition']['icon']);
            }
          }
        }
        return data;
      } else {
        print('Lỗi: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return null;
    }
  }
}
