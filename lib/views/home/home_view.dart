import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/forecast_hour_item.dart';
import '../../colors/colors.dart';
import 'dart:ui';
import 'package:weather_app/widgets/search_bar.dart';
import 'package:weather_app/widgets/forecast_day_item.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/widgets/history_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  Position? currentPosition;
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _hourlyTabController;

  String formatDateTime(DateTime dateTime) {
    // Danh sách thứ trong tuần
    List<String> weekdays = [
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
    ];

    // Lấy tên thứ trong tuần
    String weekday = weekdays[dateTime.weekday % 7]; 

    // Định dạng giờ phút
    String time = DateFormat('HH:mm').format(dateTime);

    return '$weekday, ${dateTime.day}/${dateTime.month}/${dateTime.year} - $time';
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _initHourlyTabController() {
    final hourlyData = weatherData!['forecast']['forecastday'][0]['hour'];
    final pageCount = (hourlyData.length / 3).ceil();
    _hourlyTabController = TabController(
      length: pageCount,
      vsync: this
    );
  }

  @override
  void dispose() {
    _hourlyTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Không thể truy cập vị trí');
        }
      }

      setState(() {
        isLoading = true;
      });

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high
      );
      
      currentPosition = position;
      // Gọi API thời tiết với tọa độ
      await _fetchWeatherData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      if (currentPosition != null) {
        final data = await _weatherService.fetchWeather(
          '${currentPosition!.latitude},${currentPosition!.longitude}'
        );
        setState(() {
          weatherData = data;
          isLoading = false;
          _initHourlyTabController();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy dữ liệu thời tiết: $e')),
      );
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final results = await _weatherService.searchLocations(query);
    
    setState(() {
      searchResults = results;
      isSearching = false;
    });
  }

  List<Widget> _buildHourlyForecastPages() {
    final List<Widget> pages = [];
    final hourlyData = weatherData!['forecast']['forecastday'][0]['hour'];
    
    for (var i = 0; i < hourlyData.length; i += 3) {
      final pageItems = <Widget>[];
      
      for (var j = i; j < i + 3 && j < hourlyData.length; j++) {
        final hourData = hourlyData[j];
        final time = DateTime.parse(hourData['time']);
        
        pageItems.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ForecastHourItem(
                time: DateFormat('HH:mm').format(time),
                temperature: hourData['temp_c'].toString(),
                weatherIcon: weatherData?['forecast']?['forecastday']?[0]?['hour']?[j]?['condition']?['icon'] ?? '',
              ),
            ),
          ),
        );
      }
      
      pages.add(
        Row(
          children: pageItems,
        ),
      );
    }
    
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg_4.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 350,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomSearchBar(
                                    searchController: _searchController,
                                    onLocationSelected: (location) async {
                                      final data = await _weatherService.fetchWeather(location['name']);
                                      setState(() {
                                        weatherData = data;
                                        searchResults = [];
                                      });
                                    },
                                    onLocationButtonPressed: _getCurrentLocation,
                                    onSearch: _searchLocations,
                                  ),
                                  Center(
                                    child: Image.network(
                                      weatherData?['current']?['condition']?['icon'] ?? '',
                                      width: 200,
                                      height: 200,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.wb_cloudy_rounded, size: 200, color: Colors.white);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 24, color: AppColors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              weatherData?['location']?['name'] ?? 'Loading...',
                                              style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w500)
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${weatherData?['current']?['temp_c']?.toString() ?? '0'}°C',
                                          style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)
                                        ),
                                        const SizedBox(height: 10),
                                        Text(formatDateTime(DateTime.parse(weatherData?['location']?['localtime'] ?? 'Loading...')), style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Divider(color: AppColors.white, height: 1),
                                  const SizedBox(height: 20),
                                  HistoryButton(
                                    weatherService: _weatherService,
                                    onLocationSelected: (data) {
                                      setState(() {
                                        weatherData = data;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (searchResults.isNotEmpty)
                        Positioned(
                          top: 75,
                          left: 20,
                          right: 20,
                          child: Material(
                            elevation: 8,
                            color: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final location = searchResults[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '${location['name']}, ${location['country']}',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                    onTap: () async {
                                      _searchController.text = location['name'];
                                      final data = await _weatherService.fetchWeather(location['name']);
                                      setState(() {
                                        weatherData = data;
                                        searchResults = [];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Forecast", style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Temperature - ${weatherData?['current']?['temp_c']?.toString() ?? 'loading...'}°C', 
                                          style: TextStyle(
                                            color: AppColors.white, 
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                        const SizedBox(height: 10),
                                        Text('Wind Speed - ${weatherData?['current']?['wind_kph']?.toString() ?? 'loading...'} km/h', 
                                          style: TextStyle(
                                            color: AppColors.white, 
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                        const SizedBox(height: 10),
                                        Text('Humidity - ${weatherData?['current']?['humidity']?.toString() ?? 'loading...'} %', 
                                          style: TextStyle(
                                            color: AppColors.white, 
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                        const SizedBox(height: 10),
                                        Text('Sunrise - ${weatherData?['forecast']?['forecastday']?[0]?['astro']?['sunrise'] ?? 'loading...'}', 
                                          style: TextStyle(
                                            color: AppColors.white, 
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                        const SizedBox(height: 10),
                                        Text('Sunset - ${weatherData?['forecast']?['forecastday']?[0]?['astro']?['sunset'] ?? 'loading...'}', 
                                          style: TextStyle(
                                            color: AppColors.white, 
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Hourly Forecast", 
                                      style: TextStyle(
                                        color: AppColors.white, 
                                        fontSize: 28, 
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
                                          onPressed: () {
                                            if (_hourlyTabController.index > 0) {
                                              _hourlyTabController.animateTo(_hourlyTabController.index - 1);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward_ios, color: AppColors.white),
                                          onPressed: () {
                                            if (_hourlyTabController.index < _hourlyTabController.length - 1) {
                                              _hourlyTabController.animateTo(_hourlyTabController.index + 1);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: weatherData?['forecast']?['forecastday']?.isNotEmpty ?? false
                                    ? TabBarView(
                                        controller: _hourlyTabController,
                                        children: _buildHourlyForecastPages(),
                                      )
                                    : Center(child: Text('Không có dữ liệu', style: TextStyle(color: AppColors.white))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('The Next Day Forecast', style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: (weatherData?['forecast']?['forecastday']?.length ?? 0) - 1,
                                    itemBuilder: (context, index) {
                                      final dayData = weatherData!['forecast']['forecastday'][index + 1];
                                      final date = DateTime.parse(dayData['date']);
                                      final weekday = DateFormat('EEEE').format(date); 
                                      
                                      return ForecastDayItem(
                                        day: weekday,
                                        date: dayData['date'],
                                        temperature: dayData['day']['avgtemp_c'].toString(),
                                        humidity: '${dayData['day']['avghumidity']}%',
                                        windSpeed: '${dayData['day']['maxwind_kph']} km/h',
                                        rainChance: '${dayData['day']['daily_chance_of_rain']}%',
                                        weatherIcon: dayData['day']['condition']['icon'], 
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


