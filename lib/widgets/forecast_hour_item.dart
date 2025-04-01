import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/colors/colors.dart';

class ForecastHourItem extends StatelessWidget {
  final String time;
  final String temperature;
  final String weatherIcon;
  
  const ForecastHourItem({
    Key? key,
    required this.time,
    required this.temperature, 
    required this.weatherIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 10),
                Image.network(weatherIcon),
                const SizedBox(height: 10),
                Text(
                  '$temperature°C',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
