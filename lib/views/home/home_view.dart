// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../colors/colors.dart';
import 'dart:html' as html;
import 'dart:ui';
import 'package:weather_app/widgets/search_bar.dart';
import 'package:weather_app/widgets/forecast_day_item.dart';
import 'package:weather_app/widgets/history_button.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import 'package:weather_app/widgets/subscribe_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _hourlyTabController;
  int _visibleDays = 4;
  final ScrollController _forecastScrollController = ScrollController();
  bool _showNavigation = false;

  @override
  void initState() {
    super.initState();
    _hourlyTabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().getCurrentLocation();
      _checkConfirmation();
    });
  }

  void _checkConfirmation() {
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters['confirmed'] == 'true') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác nhận đăng ký thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        html.window.history.pushState({}, '', uri.path);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final weatherProvider = context.watch<WeatherProvider>();
    if (weatherProvider.weatherData != null) {
      _initHourlyTabController();
    }
  }

  void _initHourlyTabController() {
    final weatherProvider = context.read<WeatherProvider>();
    final hourlyData = weatherProvider.weatherData!['forecast']['forecastday'][0]['hour'];
    final pageCount = (hourlyData.length / 3).ceil();
    _hourlyTabController.dispose();
    _hourlyTabController = TabController(length: pageCount, vsync: this);
  }

  @override
  void dispose() {
    _hourlyTabController.dispose();
    _searchController.dispose();
    _forecastScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    
    if (weatherProvider.isLoading) {
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
                              // ignore: duplicate_ignore
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
                                      await weatherProvider.fetchWeatherByLocation(location['name']);
                                      _searchController.clear();
                                    },
                                    onLocationButtonPressed: () {
                                      weatherProvider.getCurrentLocation();
                                      _searchController.clear();
                                    },
                                    onSearch: weatherProvider.searchLocations,
                                  ),
                                  const SizedBox(height: 20),
                                  HistoryButton(
                                    weatherService: weatherProvider.weatherService,
                                    onLocationSelected: (data) {
                                      weatherProvider.weatherData = data;
                                      _searchController.clear();
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  const SubscribeButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (weatherProvider.searchResults.isNotEmpty)
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
                                itemCount: weatherProvider.searchResults.length,
                                itemBuilder: (context, index) {
                                  final location = weatherProvider.searchResults[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '${location['name']}, ${location['country']}',
                                      style: const TextStyle(color: AppColors.white),
                                    ),
                                    onTap: () async {
                                      _searchController.text = location['name'];
                                      await weatherProvider.fetchWeatherByLocation(location['name']);
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // Today's Forecast Section
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${weatherProvider.weatherData?['location']?['name'] ?? 'Loading...'} (${DateFormat('yyyy-MM-dd').format(DateTime.parse(weatherProvider.weatherData?['location']?['localtime'] ?? DateTime.now().toString()))})',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Temperature: ${weatherProvider.weatherData?['current']?['temp_c']?.toString() ?? 'loading...'}°C',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Wind: ${weatherProvider.weatherData?['current']?['wind_kph']?.toString() ?? 'loading...'} M/S',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Humidity: ${weatherProvider.weatherData?['current']?['humidity']?.toString() ?? 'loading...'}%',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 50),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                weatherProvider.weatherData?['current']?['condition']?['icon'] ?? '',
                                                width: 80,
                                                height: 80,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.cloud,
                                                    color: AppColors.white,
                                                    size: 80,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                weatherProvider.weatherData?['current']?['condition']?['text'] ?? 'loading...',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _showNavigation ? 'Next Day Forecast' : '4-Day Forecast',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  if (_showNavigation) ...[
                                                    IconButton(
                                                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                                                      onPressed: () {
                                                        _forecastScrollController.animateTo(
                                                          _forecastScrollController.offset - 261,
                                                          duration: const Duration(milliseconds: 300),
                                                          curve: Curves.easeInOut,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white),
                                                      onPressed: () {
                                                        _forecastScrollController.animateTo(
                                                          _forecastScrollController.offset + 261,
                                                          duration: const Duration(milliseconds: 300),
                                                          curve: Curves.easeInOut,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                  if ((weatherProvider.weatherData?['forecast']?['forecastday']?.length ?? 0) > _visibleDays + 1)
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _visibleDays += 3;
                                                          _showNavigation = true;
                                                          if (_visibleDays > (weatherProvider.weatherData?['forecast']?['forecastday']?.length ?? 0) - 1) {
                                                            _visibleDays = (weatherProvider.weatherData?['forecast']?['forecastday']?.length ?? 0) - 1;
                                                          }
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Load More',
                                                        style: TextStyle(
                                                          color: AppColors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Expanded(
                                            child: ListView.builder(
                                              controller: _forecastScrollController,
                                              scrollDirection: Axis.horizontal,
                                              physics: _showNavigation 
                                                ? const AlwaysScrollableScrollPhysics()
                                                : const NeverScrollableScrollPhysics(),
                                              itemCount: _visibleDays,
                                              itemBuilder: (context, index) {
                                                if (index >= (weatherProvider.weatherData?['forecast']?['forecastday']?.length ?? 0) - 1) {
                                                  return const SizedBox.shrink();
                                                }
                                                final dayData = weatherProvider.weatherData!['forecast']['forecastday'][index + 1];
                                                final date = DateTime.parse(dayData['date']);
                                                final weekday = DateFormat('EEEE').format(date);
                                                
                                                return ForecastDayItem(
                                                  day: weekday,
                                                  date: dayData['date'],
                                                  temperature: dayData['day']['avgtemp_c'].toString(),
                                                  humidity: '${dayData['day']['avghumidity']}%',
                                                  windSpeed: '${dayData['day']['maxwind_kph']} M/S',
                                                  rainChance: '${dayData['day']['daily_chance_of_rain']}%',
                                                  weatherIcon: dayData['day']['condition']['icon'],
                                                  isLastItem: index == _visibleDays - 1,
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
                            ],
                          ),
                        ),
                      ],
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


