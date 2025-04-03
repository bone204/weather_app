import 'package:flutter/material.dart';
import 'package:weather_app/colors/colors.dart';

class ForecastDayItem extends StatelessWidget {
  final String day;
  final String date;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String rainChance;
  final String weatherIcon;
  final bool isLastItem;

  const ForecastDayItem({
    Key? key,
    required this.day,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.weatherIcon,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isLastItem ? 0 : 16),
      width: 245,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date
            Text(
              '($date)',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Weather Icon
            Image.network(
              weatherIcon,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.cloud,
                  color: AppColors.white,
                  size: 60,
                );
              },
            ),
            Text(
              'Temp: $temperature°C',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            Text(
              'Wind: $windSpeed',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            Text(
              'Humidity: $humidity',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 