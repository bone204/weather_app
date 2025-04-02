import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String apiKey = 'f3b63d0f85e842529d882310253103'; 
  final String baseUrl = 'https://api.weatherapi.com/v1';
  static const String _historyKey = 'weather_history';

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

  Future<void> saveToHistory(Map<String, dynamic> weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final historyItem = {
        'timestamp': now.toIso8601String(),
        'location': weatherData['location']['name'],
        'temperature': weatherData['current']['temp_c'],
        'condition': weatherData['current']['condition']['text'],
        'icon': weatherData['current']['condition']['icon'],
        'country': weatherData['location']['country'],
      };

      List<Map<String, dynamic>> history = await getHistory();
      
      // Kiểm tra xem địa điểm đã tồn tại chưa
      history.removeWhere((item) => item['location'] == historyItem['location']);
      // Thêm vào đầu danh sách
      history.insert(0, historyItem);
      
      await prefs.setString(_historyKey, jsonEncode(history));
    } catch (e) {
      print('Lỗi khi lưu lịch sử: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyStr = prefs.getString(_historyKey);
      if (historyStr != null) {
        final List<dynamic> decoded = jsonDecode(historyStr);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final todayHistory = List<Map<String, dynamic>>.from(decoded).where((item) {
          final itemDate = DateTime.parse(item['timestamp']);
          final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);
          return itemDay.isAtSameMomentAs(today);
        }).toList();

        if (todayHistory.isEmpty) {
          await prefs.remove(_historyKey);
        }

        return todayHistory;
      }
      return [];
    } catch (e) {
      print('Lỗi khi đọc lịch sử: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final data = await _fetchWeatherFromApi(city);
    if (data != null) {
      await saveToHistory(data);
    }
    return data;
  }

  Future<Map<String, dynamic>?> _fetchWeatherFromApi(String city) async {
    final url = Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$city&days=7&aqi=no');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['current']?['condition']?['icon'] != null) {
          data['current']['condition']['icon'] = 
              getIconUrl(data['current']['condition']['icon']);
        }
        
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
